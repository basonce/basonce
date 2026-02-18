/*
  # EarnQuest (EQ) Döngüsel Fiyat Sistemi

  1. Yeni Tablolar
    - `earnquest_price`
      - `id` (bigint, primary key) - Tek kayıt ID (her zaman 1)
      - `current_price` (decimal) - Şu anki fiyat
      - `start_price` (decimal) - Başlangıç fiyatı (0.01 USDT)
      - `initial_price_of_cycle` (decimal) - Bu döngünün başlangıç fiyatı
      - `target_multiplier` (decimal) - Hedef çarpan (50.78 = %4978)
      - `change_percentage` (decimal) - Döngü başından bu yana değişim %
      - `high_24h` (decimal) - 24 saatlik en yüksek
      - `low_24h` (decimal) - 24 saatlik en düşük
      - `market_cap` (decimal) - Market cap
      - `total_supply` (bigint) - Toplam supply
      - `last_reset_at` (timestamptz) - Son sıfırlama zamanı
      - `updated_at` (timestamptz) - Son güncelleme zamanı
      - `created_at` (timestamptz) - Oluşturulma zamanı

  2. Güvenlik
    - RLS açık
    - Herkes okuyabilir
    - Sadece sistem güncelleyebilir (service role)

  3. Özellikler
    - Fiyat %4978 artışa ulaşınca otomatik sıfırlanır
    - Tüm kullanıcılar aynı fiyatı görür
    - Gerçek zamanlı güncelleme
*/

-- EarnQuest fiyat tablosu
CREATE TABLE IF NOT EXISTS earnquest_price (
  id bigint PRIMARY KEY DEFAULT 1,
  current_price decimal(18, 8) NOT NULL DEFAULT 0.01,
  start_price decimal(18, 8) NOT NULL DEFAULT 0.01,
  initial_price_of_cycle decimal(18, 8) NOT NULL DEFAULT 0.01,
  target_multiplier decimal(10, 2) NOT NULL DEFAULT 50.78,
  change_percentage decimal(10, 2) NOT NULL DEFAULT 0,
  high_24h decimal(18, 8) NOT NULL DEFAULT 0.01,
  low_24h decimal(18, 8) NOT NULL DEFAULT 0.01,
  market_cap decimal(20, 2) NOT NULL DEFAULT 10000000,
  total_supply bigint NOT NULL DEFAULT 1000000000,
  last_reset_at timestamptz DEFAULT now(),
  last_24h_reset_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  CONSTRAINT single_row_only CHECK (id = 1)
);

-- Tek kayıt olduğundan emin ol
INSERT INTO earnquest_price (id) VALUES (1)
ON CONFLICT (id) DO NOTHING;

-- RLS politikaları
ALTER TABLE earnquest_price ENABLE ROW LEVEL SECURITY;

-- Herkes okuyabilir
CREATE POLICY "Anyone can read EarnQuest price"
  ON earnquest_price
  FOR SELECT
  TO public
  USING (true);

-- Sadece authenticated kullanıcılar güncelleyebilir (edge function için)
CREATE POLICY "Service role can update EarnQuest price"
  ON earnquest_price
  FOR UPDATE
  TO authenticated
  USING (id = 1)
  WITH CHECK (id = 1);

-- Fiyatı sıfırlama fonksiyonu
CREATE OR REPLACE FUNCTION reset_earnquest_price()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE earnquest_price
  SET 
    current_price = start_price,
    initial_price_of_cycle = start_price,
    change_percentage = 0,
    high_24h = start_price,
    low_24h = start_price,
    market_cap = start_price * total_supply,
    last_reset_at = now(),
    updated_at = now()
  WHERE id = 1;
END;
$$;

-- 24 saatlik istatistikleri sıfırlama fonksiyonu
CREATE OR REPLACE FUNCTION reset_earnquest_24h_stats()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_price_val decimal(18, 8);
BEGIN
  SELECT current_price INTO current_price_val FROM earnquest_price WHERE id = 1;
  
  UPDATE earnquest_price
  SET 
    high_24h = current_price_val,
    low_24h = current_price_val,
    last_24h_reset_at = now(),
    updated_at = now()
  WHERE id = 1;
END;
$$;

-- Realtime için yayınlamayı etkinleştir
ALTER PUBLICATION supabase_realtime ADD TABLE earnquest_price;

-- İndeksler
CREATE INDEX IF NOT EXISTS idx_earnquest_price_updated_at ON earnquest_price(updated_at DESC);
