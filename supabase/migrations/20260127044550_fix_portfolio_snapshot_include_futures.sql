/*
  # Portföy Snapshot'ını Futures İçerecek Şekilde Güncelleme

  1. Değişiklikler
    - `create_daily_portfolio_snapshot` fonksiyonunu güncelle
    - Spot balance'ın yanı sıra futures_balance'ı da dahil et
    - Açık futures positions'lardan unrealized PNL'i hesapla ve ekle
  
  2. Güvenlik
    - Mevcut RLS politikaları korunuyor
    - SECURITY DEFINER ile fonksiyon çalışıyor
  
  3. Hesaplama Mantığı
    - Total Value = Spot Balances + Futures Balance + Futures Unrealized PNL
    - Snapshot günün başında alınır ve tüm gün referans olarak kullanılır
*/

-- Günlük snapshot alma fonksiyonunu güncelle (futures dahil)
CREATE OR REPLACE FUNCTION create_daily_portfolio_snapshot()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_record record;
  user_balances jsonb;
  total_value decimal;
  spot_value decimal;
  futures_balance_value decimal;
  futures_unrealized_pnl decimal;
BEGIN
  FOR user_record IN (
    SELECT DISTINCT user_id
    FROM user_balances
  ) LOOP
    user_balances := '{}'::jsonb;
    spot_value := 0;
    futures_balance_value := 0;
    futures_unrealized_pnl := 0;

    SELECT jsonb_object_agg(symbol, jsonb_build_object(
      'balance', balance,
      'futures_balance', futures_balance,
      'last_price', COALESCE(
        (SELECT price FROM user_trades 
         WHERE user_id = user_record.user_id 
           AND symbol = ub.symbol 
         ORDER BY created_at DESC 
         LIMIT 1),
        CASE WHEN symbol = 'USDT' THEN 1 ELSE 0 END
      )
    ))
    INTO user_balances
    FROM user_balances ub
    WHERE ub.user_id = user_record.user_id;

    SELECT 
      COALESCE(SUM(
        ub.balance * CASE 
          WHEN ub.symbol = 'USDT' THEN 1 
          ELSE COALESCE(
            (SELECT price FROM user_trades 
             WHERE user_id = user_record.user_id 
               AND symbol = ub.symbol 
             ORDER BY created_at DESC 
             LIMIT 1),
            0
          )
        END
      ), 0)
    INTO spot_value
    FROM user_balances ub
    WHERE ub.user_id = user_record.user_id;

    SELECT COALESCE(futures_balance, 0)
    INTO futures_balance_value
    FROM user_balances
    WHERE user_id = user_record.user_id
      AND symbol = 'USDT';

    SELECT COALESCE(SUM(unrealized_pnl), 0)
    INTO futures_unrealized_pnl
    FROM futures_positions
    WHERE user_id = user_record.user_id
      AND status = 'open';

    total_value := spot_value + futures_balance_value + futures_unrealized_pnl;

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

GRANT EXECUTE ON FUNCTION create_daily_portfolio_snapshot() TO authenticated;
