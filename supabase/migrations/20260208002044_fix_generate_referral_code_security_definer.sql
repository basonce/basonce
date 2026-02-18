/*
  # Fix Referral Code Generation Function
  
  1. Changes
    - Update generate_referral_code() to use SECURITY DEFINER
    - This allows the function to bypass RLS when checking for duplicate codes
    - Fixes "Database error saving new user" issue during signup
    
  2. Security
    - Function only reads from user_profiles to check for duplicates
    - No user input is used in the query
    - Safe to use SECURITY DEFINER in this context
*/

CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  code TEXT;
  exists BOOLEAN;
BEGIN
  LOOP
    code := upper(substring(md5(random()::text) from 1 for 8));
    
    SELECT EXISTS(SELECT 1 FROM user_profiles WHERE referral_code = code) INTO exists;
    
    IF NOT exists THEN
      RETURN code;
    END IF;
  END LOOP;
END;
$$;

COMMENT ON FUNCTION generate_referral_code IS 'Generates unique 8-character referral code, bypassing RLS to check duplicates';
