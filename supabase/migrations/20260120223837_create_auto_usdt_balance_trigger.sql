/*
  # Auto-create USDT balance on user registration
  
  1. Changes
    - Creates a trigger function that automatically creates a USDT balance (0.00) when a new user profile is created
    - Adds trigger to user_profiles table to call this function on INSERT
  
  2. Purpose
    - Every new user automatically gets a USDT balance of 0.00
    - Admin can then add USDT to any user from the admin dashboard
    - Ensures all users have a USDT balance entry for easier management
*/

-- Create function to auto-create USDT balance
CREATE OR REPLACE FUNCTION create_initial_usdt_balance()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert USDT balance with 0.00 for new user
  INSERT INTO user_balances (user_id, symbol, balance, locked_balance)
  VALUES (NEW.id, 'USDT', 0.00, 0.00)
  ON CONFLICT (user_id, symbol) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if it exists
DROP TRIGGER IF EXISTS on_user_created_create_usdt_balance ON user_profiles;

-- Create trigger on user_profiles
CREATE TRIGGER on_user_created_create_usdt_balance
  AFTER INSERT ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION create_initial_usdt_balance();