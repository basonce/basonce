/*
  # Auto-Create User Profile and Balance on Signup
  
  1. Problem
    - Frontend RPC calls fail due to session issues
    - Manual insert blocked by RLS
    
  2. Solution
    - Database trigger that runs automatically when user signs up
    - Trigger has elevated privileges and bypasses RLS
    - No frontend involvement needed
    
  3. Security
    - Trigger only runs on INSERT to auth.users
    - Cannot be exploited by users
*/

-- Drop existing trigger if any
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

-- Create function that will be called by trigger
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Insert user profile (bypasses RLS because of SECURITY DEFINER)
  INSERT INTO public.user_profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  )
  ON CONFLICT (id) DO NOTHING;
  
  -- Insert initial USDT balance (bypasses RLS because of SECURITY DEFINER)
  INSERT INTO public.user_balances (user_id, symbol, balance, locked_balance)
  VALUES (NEW.id, 'USDT', 10000, 0)
  ON CONFLICT (user_id, symbol) DO NOTHING;
  
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Log error but don't fail the signup
  RAISE WARNING 'Error in handle_new_user: %', SQLERRM;
  RETURN NEW;
END;
$$;

-- Create trigger on auth.users table
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
