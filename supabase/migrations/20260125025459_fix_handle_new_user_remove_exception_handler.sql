/*
  # Fix handle_new_user - Remove Exception Handler
  
  1. Problem
    - Function has EXCEPTION handler that swallows errors
    - We can't see what the real error is
    
  2. Solution
    - Remove EXCEPTION handler to see actual errors
    - This will help us debug the "Database error saving new user" issue
*/

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Insert profile
  INSERT INTO public.user_profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );
  
  -- Insert balance
  INSERT INTO public.user_balances (user_id, symbol, balance, locked_balance)
  VALUES (NEW.id, 'USDT', 10000, 0);
  
  RETURN NEW;
END;
$$;
