/*
  # Temporarily Disable RLS for Login Testing
  
  1. Purpose
    - Disable RLS on user_profiles to test if it's causing login failure
    - This is TEMPORARY to identify the root cause
    
  2. Changes
    - Disable RLS on user_profiles table
    
  WARNING: This is for testing only!
*/

ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
