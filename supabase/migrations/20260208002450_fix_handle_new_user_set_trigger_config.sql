/*
  # Fix handle_new_user Function - Add Trigger Config
  
  1. Changes
    - Update handle_new_user() to set app.is_trigger config
    - This allows the function to bypass RLS when creating initial balance
    - Fixes "Database error saving new user" issue
    
  2. Security
    - Function runs as SECURITY DEFINER (safe)
    - Only creates initial records for the new user
*/

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  -- Set trigger flag to bypass RLS
  PERFORM set_config('app.is_trigger', 'true', true);
  
  -- Create user profile
  INSERT INTO public.user_profiles (
    id, 
    email, 
    full_name,
    user_id,
    referral_code
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    nextval('user_id_seq'),
    generate_referral_code()
  );
  
  -- Create initial USDT balance
  INSERT INTO public.user_balances (user_id, symbol, balance, locked_balance)
  VALUES (NEW.id, 'USDT', 0, 0);
  
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION handle_new_user IS 'Auto-creates user profile with user_id, referral_code, and 0 USDT balance for new signups';
