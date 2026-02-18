/*
  # Fix User Balance Foreign Key Order Issue
  
  1. Problem
    - user_balances has foreign key to user_profiles
    - When trigger tries to insert both, FK check might fail
    
  2. Solution
    - Make the foreign key DEFERRABLE so it checks at transaction end
    - This allows profile and balance to be created in same transaction
*/

-- Drop existing foreign key
ALTER TABLE user_balances 
DROP CONSTRAINT IF EXISTS user_balances_user_id_fkey;

-- Recreate as DEFERRABLE INITIALLY DEFERRED
ALTER TABLE user_balances
ADD CONSTRAINT user_balances_user_id_fkey
FOREIGN KEY (user_id) 
REFERENCES user_profiles(id) 
ON DELETE CASCADE
DEFERRABLE INITIALLY DEFERRED;
