/*
  # Update Mining Economy - 67% Profit for All Equipment (Correct Columns)
  
  1. Overview
    - Update all mining equipment to provide exactly 67% net profit
    - Formula: Total Earnings = Investment × 1.67
    - Net Profit = Investment × 0.67
    
  2. New Economics (All equipment 67% ROI)
    - FREE CPU: $0 → $30 (3 hours) = $10/hour
    - Level 1: $500 → $835 (72 hours) = $11.60/hour, $278.40/day
    - Level 2: $1,000 → $1,670 (96 hours) = $17.40/hour, $417.60/day
    - Level 3: $2,000 → $3,340 (96 hours) = $34.80/hour, $835.20/day
    - Level 4: $3,000 → $5,010 (120 hours) = $41.75/hour, $1,002/day
    - Level 5: $5,000 → $8,350 (168 hours) = $49.70/hour, $1,192.80/day
    
  3. Changes
    - Update earning_rate (hourly earnings)
    - Update daily_earning (24-hour earnings)
    - Update withdrawal_limit (total max earnings)
*/

-- FREE CPU Miner: $30 in 3 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 10.00,
  daily_earning = 240.00,
  withdrawal_limit = 30.00
WHERE name = 'CPU Miner' AND is_free = true;

-- LEVEL 1: $500 → $835 total (67% profit) in 72 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 11.60,
  daily_earning = 278.40,
  withdrawal_limit = 835.00
WHERE name = 'ASIC Miner S19' AND level = 1;

-- LEVEL 2: $1,000 → $1,670 total (67% profit) in 96 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 17.40,
  daily_earning = 417.60,
  withdrawal_limit = 1670.00
WHERE name = 'ASIC Miner S19 Pro' AND level = 2;

-- LEVEL 3: $2,000 → $3,340 total (67% profit) in 96 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 34.80,
  daily_earning = 835.20,
  withdrawal_limit = 3340.00
WHERE name = 'ASIC Mining Farm' AND level = 3;

-- LEVEL 4: $3,000 → $5,010 total (67% profit) in 120 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 41.75,
  daily_earning = 1002.00,
  withdrawal_limit = 5010.00
WHERE name = 'Industrial Mining Station' AND level = 4;

-- LEVEL 5: $5,000 → $8,350 total (67% profit) in 168 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 49.70,
  daily_earning = 1192.80,
  withdrawal_limit = 8350.00
WHERE name = 'Quantum Mining Datacenter' AND level = 5;