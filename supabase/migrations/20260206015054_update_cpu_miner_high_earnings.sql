/*
  # Update CPU Miner for High-Speed Earnings
  
  1. Changes
    - Update CPU Miner to earn 50 USD in 5 hours (10 USD/hour = 240 USD/day)
    - Update all existing user CPU Miners to new rate
    - This creates an aggressive earning system for 5-hour mining sessions
  
  2. Notes
    - 5 hours = 50 USD target
    - Hourly rate = 10 USD/hour
    - Daily rate = 240 USD/day
*/

-- Update CPU Miner in user_mining_equipment
UPDATE user_mining_equipment
SET 
  hash_rate = 10,
  daily_earning_usdt = 240
WHERE name = 'CPU Miner';

-- Update CPU Miner in mining_shop_items if exists
UPDATE mining_shop_items
SET 
  hash_rate = 10,
  daily_earning_usdt = 240
WHERE name = 'CPU Miner';
