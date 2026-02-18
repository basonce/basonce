/*
  # Fix Automatic User ID Assignment
  
  1. Problem
    - New users don't get a user_id assigned automatically
    - user_id field remains null for new signups
    
  2. Solution
    - Update handle_new_user() function to assign sequential user_id
    - Start from highest existing user_id + 1
    - Use COALESCE to handle empty table case
    
  3. Changes
    - Modified handle_new_user() function to include user_id generation
    - user_id will be auto-incremented starting from 100009
*/

-- Drop and recreate the function with user_id assignment
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  next_user_id INTEGER;
BEGIN
  -- Get the next user_id (highest + 1, or 100000 if table is empty)
  SELECT COALESCE(MAX(user_id), 99999) + 1 INTO next_user_id
  FROM public.user_profiles;
  
  -- Insert user profile with auto-generated user_id
  INSERT INTO public.user_profiles (id, email, full_name, user_id)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    next_user_id
  )
  ON CONFLICT (id) DO UPDATE
  SET user_id = EXCLUDED.user_id
  WHERE user_profiles.user_id IS NULL;
  
  -- Insert initial USDT balance
  INSERT INTO public.user_balances (user_id, symbol, balance, locked_balance)
  VALUES (NEW.id, 'USDT', 10000, 0)
  ON CONFLICT (user_id, symbol) DO NOTHING;
  
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RAISE WARNING 'Error in handle_new_user: %', SQLERRM;
  RETURN NEW;
END;
$$;
