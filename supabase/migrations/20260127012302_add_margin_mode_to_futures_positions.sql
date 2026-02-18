/*
  # Add margin_mode to futures_positions
  
  1. Changes
    - Add `margin_mode` column to `futures_positions` table (cross or isolated)
    - Default to 'cross' for existing positions
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'futures_positions' AND column_name = 'margin_mode'
  ) THEN
    ALTER TABLE futures_positions ADD COLUMN margin_mode text DEFAULT 'cross' CHECK (margin_mode IN ('cross', 'isolated'));
  END IF;
END $$;
