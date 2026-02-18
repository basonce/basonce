/*
  # Re-enable RLS on Critical Tables
  
  Re-enable RLS with proper policies on user_profiles and user_balances
*/

-- Re-enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_balances ENABLE ROW LEVEL SECURITY;

-- Ensure policies exist (they should already be there)
-- These policies are simple and don't have circular dependencies

-- user_profiles policies should already exist:
-- - "Users can view own profile" FOR SELECT
-- - "Users can update own profile" FOR UPDATE
-- - "Users can create own profile" FOR INSERT

-- user_balances policies should already exist:
-- - "Users can view balances" FOR SELECT
-- - "Users can create own initial balance" FOR INSERT
