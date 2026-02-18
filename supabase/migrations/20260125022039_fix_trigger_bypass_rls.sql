/*
  # Fix User Registration Trigger - Bypass RLS

  1. Problem
    - Trigger runs AFTER user signup
    - But user is not yet authenticated at trigger time
    - RLS policy blocks the INSERT
    - Result: "Database error saving new user"

  2. Solution
    - Recreate function to bypass RLS during trigger execution
    - Use direct INSERT without RLS check in trigger context

  3. Security
    - Function is SECURITY DEFINER (runs as owner)
    - Only called by trigger, not directly accessible
    - Safe because it only creates profile for the new user
*/

-- Drop and recreate the function to properly bypass RLS
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Insert into user_profiles without RLS check (SECURITY DEFINER allows this)
  INSERT INTO public.user_profiles (id, email, full_name)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', '')
  );
  
  -- Also create initial USDT balance
  INSERT INTO public.user_balances (user_id, symbol, balance, locked_balance)
  VALUES (new.id, 'USDT', 10000, 0)
  ON CONFLICT (user_id, symbol) DO NOTHING;
  
  RETURN new;
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();