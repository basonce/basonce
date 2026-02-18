/*
  # Fix futures_history created_at column

  1. Changes
    - Add DEFAULT now() to created_at column in futures_history table
    - This fixes the issue where manual position closes fail due to NULL created_at

  2. Reason
    - The created_at column has NOT NULL constraint but no default value
    - When inserting from client with explicit timestamp, it sometimes fails
    - Adding DEFAULT ensures the column always has a value
*/

-- Add DEFAULT to created_at if it doesn't already have one
DO $$ 
BEGIN
  ALTER TABLE futures_history 
  ALTER COLUMN created_at SET DEFAULT now();
EXCEPTION 
  WHEN OTHERS THEN 
    NULL;
END $$;
