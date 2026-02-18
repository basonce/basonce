/*
  # Drop All Auth Triggers
  
  Remove all triggers that run on auth.users to identify which one causes the issue
*/

-- Drop the triggers (Supabase will allow this from a migration)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS on_user_created_withdrawal_limits ON auth.users;

-- Also drop the problematic functions
DROP FUNCTION IF EXISTS handle_new_user();
DROP FUNCTION IF EXISTS create_default_withdrawal_limits();
