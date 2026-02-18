/*
  # Fix Auto-Assignment of user_id and referral_code for New Users
  
  1. Problem
    - New users don't get user_id and referral_code automatically
    - handle_new_user() function doesn't assign these fields
    
  2. Solution
    - Update handle_new_user() to assign user_id from sequence
    - Update handle_new_user() to generate referral_code
    - Every new user will get:
      * user_id: from user_id_seq (e.g., 100009, 100010, etc.)
      * referral_code: unique 8-character code
      * default USDT balance: 10000
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
  VALUES (NEW.id, 'USDT', 10000, 0);
  
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION handle_new_user IS 'Auto-creates user profile with user_id, referral_code, and USDT balance for new signups';
