/*
  # Fix Support User Verification Function
  
  1. Problem
    - Previous function referenced non-existent 'username' column
    - user_profiles has 'user_id' (bigint) instead
    
  2. Solution
    - Update function to check user_id (numeric ID) instead of username
    - Support ID search by: UUID (id), numeric user_id, or email
    - Match with provided email
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
      OR up.user_id::text = p_customer_id 
      OR up.email ILIKE p_customer_id
    )
    AND up.email ILIKE p_email
  LIMIT 1;
END;
$$;

COMMENT ON FUNCTION verify_support_user IS 'Verifies customer ID (UUID, numeric user_id, or email) and email combination for support access. Returns user UUID if valid.';
