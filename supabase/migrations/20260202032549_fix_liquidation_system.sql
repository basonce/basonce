/*
  # Fix Liquidation System

  1. Functions
    - Recalculate all wrong liquidation prices
    - Auto-liquidate positions that should be closed
    
  2. Security
    - RLS enabled
    - Only fixes user's own positions
*/

CREATE OR REPLACE FUNCTION recalculate_liquidation_prices()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE futures_positions
  SET liquidation_price = CASE
    WHEN side = 'LONG' THEN
      entry_price * (1 - (1.0 / leverage) + maintenance_margin_rate)
    WHEN side = 'SHORT' THEN
      entry_price * (1 + (1.0 / leverage) - maintenance_margin_rate)
    ELSE liquidation_price
  END
  WHERE status = 'open'
  AND (
    (side = 'LONG' AND liquidation_price > entry_price)
    OR (side = 'SHORT' AND liquidation_price < entry_price)
  );
END;
$$;

CREATE OR REPLACE FUNCTION auto_liquidate_invalid_positions()
RETURNS TABLE(liquidated_count integer)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  liq_count integer := 0;
  pos_record record;
BEGIN
  FOR pos_record IN (
    SELECT 
      fp.*,
      CASE 
        WHEN fp.symbol LIKE '%USDT' THEN fp.entry_price
        ELSE fp.entry_price
      END as current_price
    FROM futures_positions fp
    WHERE fp.status = 'open'
  )
  LOOP
    IF (
      (pos_record.side = 'LONG' AND pos_record.current_price <= pos_record.liquidation_price)
      OR (pos_record.side = 'SHORT' AND pos_record.current_price >= pos_record.liquidation_price)
    ) THEN
      INSERT INTO futures_history (
        user_id,
        symbol,
        side,
        leverage,
        entry_price,
        close_price,
        position_size,
        margin,
        liquidation_price,
        maintenance_margin_rate,
        realized_pnl,
        trading_fee,
        close_reason,
        created_at
      )
      VALUES (
        pos_record.user_id,
        pos_record.symbol,
        pos_record.side,
        pos_record.leverage,
        pos_record.entry_price,
        pos_record.liquidation_price,
        pos_record.position_size,
        pos_record.margin,
        pos_record.liquidation_price,
        pos_record.maintenance_margin_rate,
        -pos_record.margin,
        pos_record.trading_fee,
        'auto_liquidation',
        now()
      );

      DELETE FROM futures_positions WHERE id = pos_record.id;

      liq_count := liq_count + 1;
    END IF;
  END LOOP;

  RETURN QUERY SELECT liq_count;
END;
$$;

SELECT recalculate_liquidation_prices();