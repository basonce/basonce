/*
  # Gerçek Zamanlı PnL Sistemi

  1. Yeni Tablolar
    - `daily_portfolio_snapshots`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key)
      - `snapshot_date` (date) - Snapshot günü
      - `total_value_usdt` (decimal) - O günün başlangıç toplam portföy değeri (USDT cinsinden)
      - `balances` (jsonb) - O gündeki tüm coin bakiyeleri ve fiyatları
      - `created_at` (timestamptz)

  2. Güvenlik
    - RLS aktif
    - Kullanıcılar sadece kendi snapshot'larını görebilir

  3. Özellikler
    - Her gün 00:00'da otomatik snapshot alınır
    - Snapshot tüm coin bakiyelerini ve o anki fiyatlarını kaydeder
    - Frontend gerçek zamanlı hesaplama yapar

  4. PnL Hesaplama Mantığı
    - Şu anki toplam portföy değeri = USDT + (her coin × şu anki fiyatı)
    - Günlük başlangıç değeri = snapshot'taki total_value_usdt
    - PnL = Şu anki değer - Başlangıç değeri
    - Yüzde = (PnL / Başlangıç değeri) × 100
*/

-- Günlük portföy snapshot tablosu
CREATE TABLE IF NOT EXISTS daily_portfolio_snapshots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  snapshot_date date NOT NULL DEFAULT CURRENT_DATE,
  total_value_usdt decimal(18, 8) NOT NULL DEFAULT 0,
  balances jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, snapshot_date)
);

-- RLS politikaları
ALTER TABLE daily_portfolio_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own snapshots"
  ON daily_portfolio_snapshots
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own snapshots"
  ON daily_portfolio_snapshots
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Günlük snapshot alma fonksiyonu
CREATE OR REPLACE FUNCTION create_daily_portfolio_snapshot()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_record record;
  user_balances jsonb;
  total_value decimal;
BEGIN
  -- Her kullanıcı için snapshot al
  FOR user_record IN (
    SELECT DISTINCT user_id
    FROM user_balances
    WHERE balance > 0
  ) LOOP
    -- Kullanıcının tüm bakiyelerini topla
    SELECT jsonb_object_agg(symbol, jsonb_build_object(
      'balance', balance,
      'last_price', COALESCE(
        (SELECT price FROM user_trades 
         WHERE user_id = user_record.user_id 
           AND symbol = ub.symbol 
         ORDER BY created_at DESC 
         LIMIT 1),
        0
      )
    ))
    INTO user_balances
    FROM user_balances ub
    WHERE ub.user_id = user_record.user_id
      AND ub.balance > 0;

    -- USDT toplam değerini hesapla (USDT + diğer coinlerin değeri)
    SELECT COALESCE(
      (SELECT balance FROM user_balances WHERE user_id = user_record.user_id AND symbol = 'USDT'),
      0
    ) + COALESCE(
      (SELECT SUM(
        ub.balance * COALESCE(
          (SELECT price FROM user_trades 
           WHERE user_id = user_record.user_id 
             AND symbol = ub.symbol 
           ORDER BY created_at DESC 
           LIMIT 1),
          0
        )
      )
      FROM user_balances ub
      WHERE ub.user_id = user_record.user_id
        AND ub.symbol != 'USDT'
        AND ub.balance > 0),
      0
    )
    INTO total_value;

    -- Snapshot kaydet
    INSERT INTO daily_portfolio_snapshots (
      user_id,
      snapshot_date,
      total_value_usdt,
      balances
    ) VALUES (
      user_record.user_id,
      CURRENT_DATE,
      total_value,
      COALESCE(user_balances, '{}'::jsonb)
    )
    ON CONFLICT (user_id, snapshot_date) DO UPDATE SET
      total_value_usdt = EXCLUDED.total_value_usdt,
      balances = EXCLUDED.balances;
  END LOOP;
END;
$$;

-- Kullanıcının bugünkü snapshot'ını getiren fonksiyon
CREATE OR REPLACE FUNCTION get_today_portfolio_snapshot(user_id_param uuid)
RETURNS TABLE(
  snapshot_date date,
  total_value_usdt decimal,
  balances jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Eğer bugünkü snapshot yoksa, oluştur
  IF NOT EXISTS (
    SELECT 1 FROM daily_portfolio_snapshots
    WHERE user_id = user_id_param
      AND snapshot_date = CURRENT_DATE
  ) THEN
    PERFORM create_daily_portfolio_snapshot();
  END IF;

  -- Snapshot'ı döndür
  RETURN QUERY
  SELECT 
    dps.snapshot_date,
    dps.total_value_usdt,
    dps.balances
  FROM daily_portfolio_snapshots dps
  WHERE dps.user_id = user_id_param
    AND dps.snapshot_date = CURRENT_DATE;
END;
$$;

-- İndeksler
CREATE INDEX IF NOT EXISTS idx_daily_snapshots_user_date 
  ON daily_portfolio_snapshots(user_id, snapshot_date DESC);

-- Grant permissions
GRANT EXECUTE ON FUNCTION create_daily_portfolio_snapshot() TO authenticated;
GRANT EXECUTE ON FUNCTION get_today_portfolio_snapshot(uuid) TO authenticated;
