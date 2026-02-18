/*
  # Fix Reset Mining Function Column Name
  
  1. Changes
    - Fix column name from coin_symbol to symbol in user_balances
    - This matches the actual database schema
*/

-- Drop old function
DROP FUNCTION IF EXISTS reset_user_mining_for_testing(uuid);

-- Recreate with correct column name
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
  INSERT INTO user_balances (user_id, symbol, balance)
  VALUES (target_user_id, 'USDT', 10000)
  ON CONFLICT (user_id, symbol)
  DO UPDATE SET balance = 10000;
  
  -- Update EQ balance to 0
  INSERT INTO user_balances (user_id, symbol, balance)
  VALUES (target_user_id, 'EQ', 0)
  ON CONFLICT (user_id, symbol)
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
