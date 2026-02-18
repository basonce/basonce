/*
  # Create User Profile Function
  
  1. Problem
    - After signup, session might not be immediately available
    - RLS policies block profile/balance creation
    
  2. Solution
    - Create a SECURITY DEFINER function that bypasses RLS
    - Can be called via supabase.rpc() from frontend
    
  3. Security
    - Function checks that user is authenticated
    - Only allows creating profile for authenticated user's own ID
*/

CREATE OR REPLACE FUNCTION create_user_profile_and_balance(
  user_email text,
  user_full_name text DEFAULT ''
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_id_val uuid;
  result json;
BEGIN
  -- Get the authenticated user's ID
  user_id_val := auth.uid();
  
  IF user_id_val IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  
  -- Insert profile (SECURITY DEFINER bypasses RLS)
  INSERT INTO user_profiles (id, email, full_name)
  VALUES (user_id_val, user_email, user_full_name)
  ON CONFLICT (id) DO NOTHING;
  
  -- Insert initial balance (SECURITY DEFINER bypasses RLS)
  INSERT INTO user_balances (user_id, symbol, balance, locked_balance)
  VALUES (user_id_val, 'USDT', 10000, 0)
  ON CONFLICT (user_id, symbol) DO NOTHING;
  
  result := json_build_object(
    'success', true,
    'user_id', user_id_val
  );
  
  RETURN result;
  
EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'Error creating profile: %', SQLERRM;
END;
$$;
