/*
  # Add realized_pnl to futures_positions
  
  1. Changes
    - Add `realized_pnl` column to track closed position profit/loss
    - Default to 0 for new positions
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'futures_positions' AND column_name = 'realized_pnl'
  ) THEN
    ALTER TABLE futures_positions ADD COLUMN realized_pnl numeric DEFAULT 0;
  END IF;
END $$;
