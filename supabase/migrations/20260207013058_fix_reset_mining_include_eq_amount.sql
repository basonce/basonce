/*
  # Fix Reset Mining to Update EQ Amount
  
  1. Changes
    - Update USDT balance with eq_amount = 0
    - This ensures EQ balance is properly reset
*/

-- Drop and recreate function with eq_amount update
DROP FUNCTION IF EXISTS reset_user_mining_for_testing(uuid);

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
  
  -- Update USDT balance to 10000 and reset eq_amount to 0
  INSERT INTO user_balances (user_id, symbol, balance, eq_amount)
  VALUES (target_user_id, 'USDT', 10000, 0)
  ON CONFLICT (user_id, symbol)
  DO UPDATE SET 
    balance = 10000,
    eq_amount = 0;
  
  -- Ensure EQ balance exists and is 0
  INSERT INTO user_balances (user_id, symbol, balance, eq_amount)
  VALUES (target_user_id, 'EQ', 0, 0)
  ON CONFLICT (user_id, symbol)
  DO UPDATE SET 
    balance = 0,
    eq_amount = 0;
  
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
GRANT EXECUTE ON FUNCTION reset_user_mining_for_testing(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION reset_user_mining_for_testing(uuid) TO anon;
