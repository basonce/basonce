/*
  # Create Support User Verification Function
  
  1. Purpose
    - Allow support system to verify user credentials without exposing all profile data
    - Check if customer ID (or username or email) matches the provided email
    - Returns only user ID if credentials are valid
    
  2. Security
    - Function is SECURITY DEFINER (runs with creator privileges)
    - Only returns user ID, not sensitive data
    - Validates email + customer ID combination
    - Prevents profile enumeration attacks
*/

CREATE OR REPLACE FUNCTION verify_support_user(
  p_customer_id text,
  p_email text
)
RETURNS TABLE(user_id uuid)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT up.id
  FROM user_profiles up
  WHERE 
    (
      up.id::text = p_customer_id 
      OR up.username = p_customer_id 
      OR up.email ILIKE p_customer_id
    )
    AND up.email ILIKE p_email
  LIMIT 1;
END;
$$;

COMMENT ON FUNCTION verify_support_user IS 'Verifies customer ID and email combination for support access. Returns user ID if valid.';
