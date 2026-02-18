/*
  # Give FREE CPU Miner to All Existing Users
  
  1. Changes
    - Give FREE CPU Miner to all existing users who don't have any equipment
    - Set test_mode: true for fast testing (60 seconds instead of 3 hours)
  
  2. Why
    - Existing users don't have FREE CPU Miner because trigger only runs on new signups
    - Now all users will see CPU Miner when they open Mine Tab
*/

-- Give FREE CPU Miner to users who don't have any equipment
INSERT INTO user_mining_equipment (
  user_id,
  equipment_type_id,
  icon,
  is_active,
  started_at,
  test_mode,
  status,
  mining_duration_seconds
)
SELECT 
  up.id,
  met.id,
  met.icon,
  false,
  NULL,
  true,
  'stopped',
  0
FROM user_profiles up
CROSS JOIN mining_equipment_types met
WHERE met.is_free = true
AND NOT EXISTS (
  SELECT 1 
  FROM user_mining_equipment ume 
  WHERE ume.user_id = up.id
);