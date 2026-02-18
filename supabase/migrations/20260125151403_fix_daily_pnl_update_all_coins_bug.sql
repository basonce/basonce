/*
  # Daily PnL Güncelleme Hatası Düzeltmesi

  1. Sorun
    - update_user_daily_pnl_with_trade fonksiyonu TÜM coinlerin daily_pnl'ini güncelliyor
    - WHERE koşulunda symbol = 'USDT' eksik
    - Bu yüzden her trade'de tüm coinlerde aynı PnL yazılıyor

  2. Çözüm
    - Sadece USDT bakiyesindeki daily_pnl güncellenecek
    - Diğer coinler etkilenmeyecek

  3. Değişiklikler
    - update_user_daily_pnl_with_trade fonksiyonu düzeltildi
    - WHERE koşuluna symbol = 'USDT' eklendi
*/

-- Günlük PnL'yi güncelle fonksiyonunu düzelt
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
      AND symbol = 'USDT'
      AND DATE(daily_pnl_updated_at) < CURRENT_DATE
  ) THEN
    PERFORM save_and_reset_daily_pnl();
  END IF;

  -- Günlük ve toplam PnL'yi güncelle (SADECE USDT için)
  UPDATE user_balances
  SET 
    daily_pnl = COALESCE(daily_pnl, 0) + trade_pnl,
    total_pnl = COALESCE(total_pnl, 0) + trade_pnl,
    daily_pnl_updated_at = now()
  WHERE user_id = user_id_param 
    AND symbol = 'USDT';  -- ÖNEMLİ: Sadece USDT için güncelle!
END;
$$;

-- Mevcut yanlış PnL değerlerini temizle
UPDATE user_balances
SET 
  daily_pnl = 0,
  total_pnl = 0
WHERE symbol != 'USDT';
