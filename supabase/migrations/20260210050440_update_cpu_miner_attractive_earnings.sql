/*
  # Update CPU Miner - Ultra Attractive Starter Equipment

  1. Changes
    - CPU Miner now earns $130 in just 3 hours
    - Hourly earning: $43.33/hour (extremely attractive for new users)
    - Daily earning: $1,040/day if it could run 24 hours
    - Mining duration: 3 hours
    - Low withdrawal limit: $100 (users can withdraw quickly)
    - Hash rate: 25 TH/s
    - This makes CPU Miner the most attractive starter option

  2. Strategy
    - Hook new users with impressive 3-hour earnings
    - Create urgency with limited duration
    - Low withdrawal threshold = fast gratification
    - Encourage upgrades to premium equipment
*/

-- Update CPU Miner to be ultra-attractive for new users
UPDATE mining_equipment_types
SET
  hash_rate = 25,
  earning_rate = 43.33,
  daily_earning = 1040.00,
  mining_duration_hours = 3,
  withdrawal_limit = 100,
  description = 'Professional mining equipment. Earn $130 in 3 hours! 67% ROI. Great entry point for serious miners.',
  icon = '⚡',
  badge = 'STARTER'
WHERE name = 'CPU Miner'
  AND is_free = true;

-- Also update any existing user CPU miners to use new rates
UPDATE user_mining_equipment ume
SET
  icon = '⚡'
FROM mining_equipment_types met
WHERE ume.equipment_type_id = met.id
  AND met.name = 'CPU Miner'
  AND met.is_free = true;
