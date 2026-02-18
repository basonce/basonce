/*
  # Add Mining Timer and EQ Balance System
  
  1. New Columns
    - `user_mining_equipment.started_at` - Track when mining started (for 5-hour limit)
    - `user_mining_equipment.mining_duration_seconds` - Track total mining time
    - `user_balances.eq_amount` - EarnQuest token balance (earned from mining)
  
  2. Changes
    - Add started_at timestamp to track mining session start
    - Add mining duration tracking
    - Add EQ token balance (4x USDT earnings)
  
  3. Notes
    - Mining sessions limited to 5 hours (18000 seconds)
    - EQ earned at 4x USDT rate
    - After 5 hours, user must upgrade to continue
*/

-- Add columns to user_mining_equipment
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'user_mining_equipment' AND column_name = 'started_at'
  ) THEN
    ALTER TABLE user_mining_equipment ADD COLUMN started_at timestamptz;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'user_mining_equipment' AND column_name = 'mining_duration_seconds'
  ) THEN
    ALTER TABLE user_mining_equipment ADD COLUMN mining_duration_seconds integer DEFAULT 0;
  END IF;
END $$;

-- Add EQ balance to user_balances
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'user_balances' AND column_name = 'eq_amount'
  ) THEN
    ALTER TABLE user_balances ADD COLUMN eq_amount numeric DEFAULT 0;
  END IF;
END $$;
