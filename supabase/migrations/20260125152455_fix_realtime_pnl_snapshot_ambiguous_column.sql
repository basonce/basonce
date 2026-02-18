/*
  # PnL Snapshot Fonksiyonunu Düzelt

  1. Değişiklikler
    - get_today_portfolio_snapshot fonksiyonundaki belirsiz kolon referansını düzelt
    - Alias kullanarak snapshot_date çakışmasını önle

  2. Not
    - Bu sadece fonksiyonu yeniden oluşturur, tabloda değişiklik yok
*/

-- Fonksiyonu düzelt
DROP FUNCTION IF EXISTS get_today_portfolio_snapshot(uuid);

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
    SELECT 1 FROM daily_portfolio_snapshots dps_check
    WHERE dps_check.user_id = user_id_param
      AND dps_check.snapshot_date = CURRENT_DATE
  ) THEN
    PERFORM create_daily_portfolio_snapshot();
  END IF;

  -- Snapshot'ı döndür
  RETURN QUERY
  SELECT 
    dps.snapshot_date AS snapshot_date,
    dps.total_value_usdt AS total_value_usdt,
    dps.balances AS balances
  FROM daily_portfolio_snapshots dps
  WHERE dps.user_id = user_id_param
    AND dps.snapshot_date = CURRENT_DATE;
END;
$$;

GRANT EXECUTE ON FUNCTION get_today_portfolio_snapshot(uuid) TO authenticated;
