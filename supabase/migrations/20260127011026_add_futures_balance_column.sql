/*
  # Add Futures Balance Column

  1. Changes
    - Add `futures_balance` column to `user_balances` table
    - Default value: 0
    - Type: numeric(20,8) to match balance column

  2. Purpose
    - Separate spot and futures balances for users
    - Enable spot-to-futures transfers
    - Track futures trading balance independently
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_balances' AND column_name = 'futures_balance'
  ) THEN
    ALTER TABLE user_balances ADD COLUMN futures_balance numeric(20,8) DEFAULT 0 NOT NULL;
  END IF;
END $$;
