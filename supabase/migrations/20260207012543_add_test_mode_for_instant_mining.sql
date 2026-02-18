/*
  # Add Test Mode for Instant Mining Testing
  
  1. Changes
    - Add test_mode column to user_mining_equipment
    - Add test_mode column to user_mining_sessions
    - Create function to reset user mining and add $10,000 USDT
    - When test_mode = true, timers are 180x faster (3 hours → 3 minutes)
  
  2. Purpose
    - Allow instant testing without waiting hours
    - Reset mining equipment for clean testing
    - Add balance for purchasing equipment
*/

-- Add test_mode to user_mining_equipment
ALTER TABLE user_mining_equipment 
ADD COLUMN IF NOT EXISTS test_mode boolean DEFAULT false;

-- Add test_mode to user_mining_sessions
ALTER TABLE user_mining_sessions 
ADD COLUMN IF NOT EXISTS test_mode boolean DEFAULT false;

-- Create function to reset user mining and add balance
CREATE OR REPLACE FUNCTION reset_user_mining_for_testing(target_user_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result jsonb;
BEGIN
  -- Delete all user mining equipment
  DELETE FROM user_mining_equipment WHERE user_id = target_user_id;
  
  -- Delete all user mining sessions
  DELETE FROM user_mining_sessions WHERE user_id = target_user_id;
  
  -- Update USDT balance to 10000
  INSERT INTO user_balances (user_id, coin_symbol, balance)
  VALUES (target_user_id, 'USDT', 10000)
  ON CONFLICT (user_id, coin_symbol)
  DO UPDATE SET balance = 10000;
  
  -- Update EQ balance to 0
  INSERT INTO user_balances (user_id, coin_symbol, balance)
  VALUES (target_user_id, 'EQ', 0)
  ON CONFLICT (user_id, coin_symbol)
  DO UPDATE SET balance = 0;
  
  result := jsonb_build_object(
    'success', true,
    'message', 'Mining reset complete. USDT balance set to $10,000. EQ balance reset to 0.',
    'usdt_balance', 10000,
    'eq_balance', 0
  );
  
  RETURN result;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION reset_user_mining_for_testing TO authenticated;

COMMENT ON FUNCTION reset_user_mining_for_testing IS 'Reset user mining equipment and sessions, set $10,000 USDT for testing';
