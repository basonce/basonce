/*
  # Fix Ambiguous Column Reference in get_all_active_positions (v2)
  
  1. Changes
    - Use fully qualified table names in subqueries
    - Fix "coin_symbol" ambiguous error
    - Fix typo in REPLACE function
*/

DROP FUNCTION IF EXISTS get_all_active_positions();

CREATE OR REPLACE FUNCTION get_all_active_positions()
RETURNS TABLE (
  position_id uuid,
  user_id uuid,
  user_email text,
  coin_symbol text,
  position_type text,
  entry_price decimal,
  current_price decimal,
  size_in_coin decimal,
  leverage integer,
  margin decimal,
  unrealized_pnl decimal,
  liquidation_price decimal,
  distance_to_liquidation_percent decimal,
  take_profit decimal,
  stop_loss decimal,
  opened_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    fp.id,
    fp.user_id,
    up.email,
    fp.symbol,
    fp.side,
    fp.entry_price,
    -- Priority: admin override > current_price > entry_price
    COALESCE(
      (SELECT apo.override_price 
       FROM admin_price_overrides apo
       WHERE apo.coin_symbol = REPLACE(fp.symbol, 'USDT', '') 
       AND apo.is_active = true 
       AND (apo.expires_at IS NULL OR apo.expires_at > now())
       ORDER BY apo.created_at DESC 
       LIMIT 1),
      sc.current_price,
      fp.entry_price
    ) as current_price,
    (fp.position_size / NULLIF(fp.entry_price, 0)) as size_in_coin,
    fp.leverage,
    fp.margin,
    fp.unrealized_pnl,
    fp.liquidation_price,
    CASE 
      WHEN COALESCE(
        (SELECT apo.override_price 
         FROM admin_price_overrides apo
         WHERE apo.coin_symbol = REPLACE(fp.symbol, 'USDT', '') 
         AND apo.is_active = true 
         AND (apo.expires_at IS NULL OR apo.expires_at > now())
         ORDER BY apo.created_at DESC 
         LIMIT 1),
        sc.current_price,
        fp.entry_price
      ) = 0 THEN 0
      WHEN fp.side = 'LONG' THEN
        ((COALESCE(
          (SELECT apo.override_price 
           FROM admin_price_overrides apo
           WHERE apo.coin_symbol = REPLACE(fp.symbol, 'USDT', '') 
           AND apo.is_active = true 
           AND (apo.expires_at IS NULL OR apo.expires_at > now())
           ORDER BY apo.created_at DESC 
           LIMIT 1),
          NULLIF(sc.current_price, 0),
          fp.entry_price
        ) - fp.liquidation_price) / NULLIF(COALESCE(
          (SELECT apo.override_price 
           FROM admin_price_overrides apo
           WHERE apo.coin_symbol = REPLACE(fp.symbol, 'USDT', '') 
           AND apo.is_active = true 
           AND (apo.expires_at IS NULL OR apo.expires_at > now())
           ORDER BY apo.created_at DESC 
           LIMIT 1),
          NULLIF(sc.current_price, 0),
          fp.entry_price
        ), 0) * 100)
      ELSE
        ((fp.liquidation_price - COALESCE(
          (SELECT apo.override_price 
           FROM admin_price_overrides apo
           WHERE apo.coin_symbol = REPLACE(fp.symbol, 'USDT', '') 
           AND apo.is_active = true 
           AND (apo.expires_at IS NULL OR apo.expires_at > now())
           ORDER BY apo.created_at DESC 
           LIMIT 1),
          NULLIF(sc.current_price, 0),
          fp.entry_price
        )) / NULLIF(COALESCE(
          (SELECT apo.override_price 
           FROM admin_price_overrides apo
           WHERE apo.coin_symbol = REPLACE(fp.symbol, 'USDT', '') 
           AND apo.is_active = true 
           AND (apo.expires_at IS NULL OR apo.expires_at > now())
           ORDER BY apo.created_at DESC 
           LIMIT 1),
          NULLIF(sc.current_price, 0),
          fp.entry_price
        ), 0) * 100)
    END as distance_to_liquidation_percent,
    fp.take_profit,
    fp.stop_loss,
    fp.created_at
  FROM futures_positions fp
  LEFT JOIN user_profiles up ON fp.user_id = up.id
  LEFT JOIN supported_coins sc ON REPLACE(fp.symbol, 'USDT', '') = sc.symbol
  WHERE fp.status = 'open'
  ORDER BY fp.created_at DESC;
END;
$$;
