/*
  # Add order_id to futures_positions table

  ## Description
  Adds order_id column to link futures positions with their opening orders.

  ## Changes
  1. Schema Changes
    - Add `order_id` column to `futures_positions` table
    - Foreign key reference to `futures_orders(id)`
    - Nullable to support existing positions

  2. Notes
    - Existing positions will have NULL order_id
    - New positions will track their opening order
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'futures_positions' AND column_name = 'order_id'
  ) THEN
    ALTER TABLE futures_positions
      ADD COLUMN order_id uuid REFERENCES futures_orders(id) ON DELETE SET NULL;
    
    CREATE INDEX IF NOT EXISTS idx_futures_positions_order_id ON futures_positions(order_id);
  END IF;
END $$;
