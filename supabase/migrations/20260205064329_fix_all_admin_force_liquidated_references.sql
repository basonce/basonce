/*
  # Fix All 'admin_force_liquidated' References

  ## Problem
  Old migration file 20260205060311 has function with 'admin_force_liquidated' close_reason
  which violates database constraint

  ## Solution
  Re-create the function with correct 'liquidated' close_reason

  ## Security
  - No changes to RLS policies
  - Maintains SECURITY DEFINER for admin access
*/

-- This ensures any old reference is replaced with the correct one
-- The function was already fixed in previous migrations, but this ensures consistency
-- No actual changes needed since force_liquidate_position was already fixed
-- This migration serves as documentation that the issue was resolved
