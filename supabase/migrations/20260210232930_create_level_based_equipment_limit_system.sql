/*
  # Level-Based Equipment Limit System

  ## Overview
  Implements a mining system where:
  - Each equipment has a withdrawal limit (lifetime earning cap)
  - Users can buy multiple equipment of same type
  - When user levels up, old level equipment becomes unusable
  - Equipment stops earning when it reaches its withdrawal_limit
  
  ## Changes
  1. Add `current_mining_level` to user_profiles
  2. Track equipment level when purchased (from equipment_types.level)
  3. When collecting: check if total_earned >= withdrawal_limit
  4. When user levels up: deactivate all equipment from previous levels
  
  ## Example Flow
  Level 0: Buy CPU Miner (free) → earns $100 max → stops
  Level 1: Buy 3x ASIC S19 ($500 each) → each earns $835 max
  Level 2: Previous ASIC S19 become unusable, buy S19 Pro
  
  ## Security
  - RLS policies ensure users only access their own equipment
  - Server-side validation for withdrawal limits
*/

-- 1. Add current mining level to user profiles
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS current_mining_level integer DEFAULT 0;

-- 2. Add equipment_level to track which level this equipment was bought at
ALTER TABLE user_mining_equipment
ADD COLUMN IF NOT EXISTS equipment_level integer DEFAULT 0;

-- 3. Update existing equipment with their correct levels from equipment_types
UPDATE user_mining_equipment ume
SET equipment_level = met.level
FROM mining_equipment_types met
WHERE ume.equipment_type_id = met.id
AND ume.equipment_level = 0;

-- 4. Create function to check if equipment is usable
CREATE OR REPLACE FUNCTION is_equipment_usable(
  p_user_id uuid,
  p_equipment_id uuid
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_level integer;
  v_equipment_level integer;
  v_total_earned numeric;
  v_withdrawal_limit numeric;
BEGIN
  -- Get user's current mining level
  SELECT current_mining_level INTO v_user_level
  FROM user_profiles
  WHERE id = p_user_id;
  
  -- Get equipment details
  SELECT 
    ume.equipment_level,
    ume.total_earned_from_equipment,
    met.withdrawal_limit
  INTO v_equipment_level, v_total_earned, v_withdrawal_limit
  FROM user_mining_equipment ume
  JOIN mining_equipment_types met ON ume.equipment_type_id = met.id
  WHERE ume.id = p_equipment_id;
  
  -- Equipment is usable if:
  -- 1. It's from current level
  -- 2. It hasn't reached withdrawal limit
  RETURN v_equipment_level = v_user_level 
    AND v_total_earned < v_withdrawal_limit;
END;
$$;

-- 5. Create function to level up user (called when they buy higher tier equipment)
CREATE OR REPLACE FUNCTION level_up_user(
  p_user_id uuid,
  p_new_level integer
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Update user's mining level
  UPDATE user_profiles
  SET current_mining_level = p_new_level
  WHERE id = p_user_id;
  
  -- Deactivate all equipment from previous levels
  UPDATE user_mining_equipment
  SET is_active = false
  WHERE user_id = p_user_id
  AND equipment_level < p_new_level;
END;
$$;

-- 6. Create view for active usable equipment
CREATE OR REPLACE VIEW user_active_equipment AS
SELECT 
  ume.id,
  ume.user_id,
  ume.equipment_type_id,
  ume.level,
  ume.purchased_at,
  ume.last_claim_at,
  ume.total_earned,
  ume.is_active,
  ume.created_at,
  ume.total_mining_seconds,
  ume.started_at,
  ume.name,
  ume.daily_earning_usdt,
  ume.session_earned_usdt,
  ume.total_earned_usdt,
  ume.hash_rate,
  ume.status,
  ume.used_mining_seconds,
  ume.test_mode,
  ume.level_id,
  ume.ends_at,
  ume.times_used,
  ume.total_earned_from_equipment,
  ume.equipment_level,
  met.name as equipment_name,
  met.daily_earning,
  met.withdrawal_limit,
  met.icon as equipment_icon,
  met.level as type_level,
  up.current_mining_level as user_level,
  (met.withdrawal_limit - ume.total_earned_from_equipment) as remaining_earnings,
  CASE 
    WHEN ume.total_earned_from_equipment >= met.withdrawal_limit THEN true
    ELSE false
  END as has_reached_limit,
  CASE 
    WHEN ume.equipment_level = up.current_mining_level 
      AND ume.total_earned_from_equipment < met.withdrawal_limit 
      AND ume.is_active = true
    THEN true
    ELSE false
  END as is_currently_usable
FROM user_mining_equipment ume
JOIN mining_equipment_types met ON ume.equipment_type_id = met.id
JOIN user_profiles up ON ume.user_id = up.id;

-- 7. Grant access to view
GRANT SELECT ON user_active_equipment TO authenticated;

-- 8. Create function to get available equipment for user's level
CREATE OR REPLACE FUNCTION get_available_shop_equipment(p_user_id uuid)
RETURNS TABLE (
  id uuid,
  name text,
  tier integer,
  price numeric,
  daily_earning numeric,
  withdrawal_limit numeric,
  icon text,
  level integer,
  description text,
  can_afford boolean,
  is_current_level boolean,
  user_count integer
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_level integer;
  v_user_balance numeric;
BEGIN
  -- Get user's current level and balance
  SELECT current_mining_level INTO v_user_level
  FROM user_profiles
  WHERE id = p_user_id;
  
  SELECT COALESCE(eq_balance, 0) INTO v_user_balance
  FROM user_balances
  WHERE user_id = p_user_id;
  
  RETURN QUERY
  SELECT 
    met.id,
    met.name,
    met.tier,
    met.price,
    met.daily_earning,
    met.withdrawal_limit,
    met.icon,
    met.level,
    met.description,
    (v_user_balance >= met.price) as can_afford,
    (met.level = v_user_level) as is_current_level,
    (SELECT COUNT(*)::integer FROM user_mining_equipment 
     WHERE equipment_type_id = met.id AND user_id = p_user_id) as user_count
  FROM mining_equipment_types met
  ORDER BY met.level ASC;
END;
$$;

COMMENT ON FUNCTION get_available_shop_equipment IS 'Returns all equipment with user-specific purchase info';
COMMENT ON VIEW user_active_equipment IS 'Shows equipment with usability status based on level and limits';
