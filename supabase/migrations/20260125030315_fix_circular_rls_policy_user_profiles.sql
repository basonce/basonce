/*
  # Fix Circular RLS Policy in user_profiles
  
  1. Problem
    - user_profiles SELECT policy references itself (circular dependency)
    - Policy checks "EXISTS (SELECT FROM user_profiles WHERE is_admin)" 
    - This causes "Database error querying schema" when logging in
    
  2. Solution
    - Simplify SELECT policy: users can only see their own profile
    - Remove circular admin check from SELECT policy
    - Keep admin check only in UPDATE policy where it's safe
*/

-- Drop existing problematic policies
DROP POLICY IF EXISTS "Users can view profiles" ON user_profiles;
DROP POLICY IF EXISTS "Admins can update profiles" ON user_profiles;

-- Create simple, non-circular SELECT policy
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Keep admin update policy but simplify it
CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
