/*
  # Change New User Default Balance to Zero
  
  1. Changes
    - Update handle_new_user() function to give new users 0 USDT instead of 10000 USDT
    - New users will start with empty balance
    
  2. Security
    - No RLS changes needed
*/

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
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
  
  INSERT INTO public.user_balances (user_id, symbol, balance, locked_balance)
  VALUES (NEW.id, 'USDT', 0, 0);
  
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION handle_new_user IS 'Auto-creates user profile with user_id, referral_code, and 0 USDT balance for new signups';
