/*
  # Günlük PnL Geçmişi Sistemi

  1. Yeni Tablolar
    - `daily_pnl_history`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to auth.users)
      - `date` (date) - İşlem günü
      - `daily_pnl` (decimal) - O günkü kar/zarar
      - `total_trades` (integer) - O günkü toplam işlem sayısı
      - `winning_trades` (integer) - Karlı işlem sayısı
      - `losing_trades` (integer) - Zararlı işlem sayısı
      - `created_at` (timestamptz)

  2. Güvenlik
    - RLS açık
    - Kullanıcılar sadece kendi geçmişlerini görebilir
    - Sistem otomatik kayıt oluşturur

  3. Özellikler
    - Günlük PnL 24 saat sonra history'ye kaydedilir
    - Geçmiş PnL'ler kaybolmaz
    - Total PnL sürekli devam eder
    - Her gün yeni bir kayıt
*/

-- Günlük PnL geçmişi tablosu
CREATE TABLE IF NOT EXISTS daily_pnl_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  date date NOT NULL,
  daily_pnl decimal(18, 8) DEFAULT 0,
  total_trades integer DEFAULT 0,
  winning_trades integer DEFAULT 0,
  losing_trades integer DEFAULT 0,
  starting_balance decimal(18, 8) DEFAULT 0,
  ending_balance decimal(18, 8) DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, date)
);

-- RLS politikaları
ALTER TABLE daily_pnl_history ENABLE ROW LEVEL SECURITY;

-- Kullanıcılar kendi geçmişlerini görebilir
CREATE POLICY "Users can view own PnL history"
  ON daily_pnl_history
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Sistem (authenticated) kayıt oluşturabilir
CREATE POLICY "System can insert PnL history"
  ON daily_pnl_history
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Günlük PnL'yi history'ye kaydet ve sıfırla fonksiyonu
CREATE OR REPLACE FUNCTION save_and_reset_daily_pnl()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_record record;
  trade_count integer;
  win_count integer;
  lose_count integer;
  start_balance decimal;
  end_balance decimal;
BEGIN
  -- Her kullanıcı için günlük PnL'yi kaydet
  FOR user_record IN (
    SELECT user_id, daily_pnl, total_pnl, daily_pnl_updated_at
    FROM user_balances
    WHERE DATE(daily_pnl_updated_at) < CURRENT_DATE
      AND daily_pnl IS NOT NULL
  ) LOOP
    -- O günkü işlem sayılarını hesapla
    SELECT 
      COUNT(*),
      COUNT(*) FILTER (WHERE pnl > 0),
      COUNT(*) FILTER (WHERE pnl < 0)
    INTO trade_count, win_count, lose_count
    FROM transactions
    WHERE user_id = user_record.user_id
      AND DATE(created_at) = DATE(user_record.daily_pnl_updated_at)
      AND type IN ('buy', 'sell', 'close_long', 'close_short');

    -- Başlangıç ve bitiş bakiyelerini al
    SELECT 
      COALESCE((SELECT balance FROM user_balances WHERE user_id = user_record.user_id AND symbol = 'USDT'), 0)
    INTO end_balance;
    
    start_balance := end_balance - user_record.daily_pnl;

    -- History'ye kaydet
    INSERT INTO daily_pnl_history (
      user_id,
      date,
      daily_pnl,
      total_trades,
      winning_trades,
      losing_trades,
      starting_balance,
      ending_balance
    ) VALUES (
      user_record.user_id,
      DATE(user_record.daily_pnl_updated_at),
      user_record.daily_pnl,
      COALESCE(trade_count, 0),
      COALESCE(win_count, 0),
      COALESCE(lose_count, 0),
      start_balance,
      end_balance
    )
    ON CONFLICT (user_id, date) DO UPDATE SET
      daily_pnl = EXCLUDED.daily_pnl,
      total_trades = EXCLUDED.total_trades,
      winning_trades = EXCLUDED.winning_trades,
      losing_trades = EXCLUDED.losing_trades,
      ending_balance = EXCLUDED.ending_balance;

    -- Günlük PnL'yi sıfırla ama total PnL'yi koru
    UPDATE user_balances
    SET 
      daily_pnl = 0,
      daily_pnl_updated_at = now()
    WHERE user_id = user_record.user_id;
  END LOOP;
END;
$$;

-- Günlük PnL'yi güncelle fonksiyonunu iyileştir
CREATE OR REPLACE FUNCTION update_user_daily_pnl_with_trade(
  user_id_param uuid,
  trade_pnl decimal
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Eğer yeni gün başladıysa önce eski günü kaydet
  IF EXISTS (
    SELECT 1 FROM user_balances
    WHERE user_id = user_id_param
      AND DATE(daily_pnl_updated_at) < CURRENT_DATE
  ) THEN
    PERFORM save_and_reset_daily_pnl();
  END IF;

  -- Günlük ve toplam PnL'yi güncelle
  UPDATE user_balances
  SET 
    daily_pnl = COALESCE(daily_pnl, 0) + trade_pnl,
    total_pnl = COALESCE(total_pnl, 0) + trade_pnl,
    daily_pnl_updated_at = now()
  WHERE user_id = user_id_param;
END;
$$;

-- İndeksler
CREATE INDEX IF NOT EXISTS idx_daily_pnl_history_user_date ON daily_pnl_history(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_daily_pnl_history_date ON daily_pnl_history(date DESC);

-- Grant permissions
GRANT EXECUTE ON FUNCTION save_and_reset_daily_pnl() TO authenticated;
GRANT EXECUTE ON FUNCTION update_user_daily_pnl_with_trade(uuid, decimal) TO authenticated;
