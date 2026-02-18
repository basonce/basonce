/*
  # Update Withdrawal System - Level 5 Only
  
  1. Changes
    - Update tier = level for all equipment
    - Set blocks_withdrawal = true for levels 0-4
    - Set blocks_withdrawal = false for level 5 only
    - Update withdrawal function to check level instead of tier
    
  2. Logic
    - Users can withdraw ONLY if they have Level 5 equipment
    - Global minimum: $10,000 total balance
    - All other levels are blocked from withdrawal
*/

-- Sync tier with level
UPDATE mining_equipment_types
SET tier = level;

-- Block withdrawal for all levels except 5
UPDATE mining_equipment_types
SET blocks_withdrawal = true
WHERE level < 5;

UPDATE mining_equipment_types
SET blocks_withdrawal = false
WHERE level = 5;

-- Update withdrawal function - simplified to check level 5
CREATE OR REPLACE FUNCTION can_user_withdraw_mining_earnings(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_has_level_5 BOOLEAN;
  v_total_balance NUMERIC;
BEGIN
  -- Check if user has Level 5 equipment
  SELECT EXISTS(
    SELECT 1
    FROM user_mining_equipment ume
    JOIN mining_equipment_types met ON ume.equipment_type_id = met.id
    WHERE ume.user_id = p_user_id
      AND met.level = 5
  ) INTO v_has_level_5;
  
  -- If no level 5, cannot withdraw
  IF NOT v_has_level_5 THEN
    RETURN false;
  END IF;
  
  -- Check if total balance is at least $10,000
  SELECT COALESCE(SUM(balance), 0)
  INTO v_total_balance
  FROM user_balances
  WHERE user_id = p_user_id;
  
  -- Can withdraw only if has Level 5 AND balance >= $10,000
  RETURN v_total_balance >= 10000;
END;
$$;

COMMENT ON FUNCTION can_user_withdraw_mining_earnings IS 'Returns true only if user has Level 5 equipment AND balance >= $10,000';
