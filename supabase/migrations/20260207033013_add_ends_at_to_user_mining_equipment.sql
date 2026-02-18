/*
  # Add ends_at column to user_mining_equipment

  1. Changes
    - Add `ends_at` (timestamptz, nullable) column to `user_mining_equipment` table
    - This column stores when time-limited mining equipment expires
    - NULL means unlimited mining (permanent equipment)
*/

-- Add ends_at column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_mining_equipment' AND column_name = 'ends_at'
  ) THEN
    ALTER TABLE user_mining_equipment ADD COLUMN ends_at timestamptz DEFAULT NULL;
  END IF;
END $$;
