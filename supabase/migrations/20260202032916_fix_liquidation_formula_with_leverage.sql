/*
  # Fix Liquidation Formula with Leverage Check

  1. Updates
    - Recalculate liquidation prices with leverage-adjusted MMR
    - Ensure MMR < Initial Margin Rate
    
  2. Security
    - Safe for all positions
*/

CREATE OR REPLACE FUNCTION recalculate_liquidation_prices_v2()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE futures_positions
  SET liquidation_price = CASE
    WHEN side = 'LONG' THEN
      entry_price * (1 - (1.0 / leverage) + LEAST(maintenance_margin_rate, (1.0 / leverage) * 0.5))
    WHEN side = 'SHORT' THEN
      entry_price * (1 + (1.0 / leverage) - LEAST(maintenance_margin_rate, (1.0 / leverage) * 0.5))
    ELSE liquidation_price
  END,
  maintenance_margin_rate = CASE
    WHEN maintenance_margin_rate > (1.0 / leverage) * 0.5 THEN
      (1.0 / leverage) * 0.5
    ELSE maintenance_margin_rate
  END
  WHERE status = 'open';
END;
$$;

SELECT recalculate_liquidation_prices_v2();