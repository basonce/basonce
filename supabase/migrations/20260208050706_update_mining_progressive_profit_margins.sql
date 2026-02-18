/*
  # Update Mining Economy - Progressive Profit Margins
  
  1. Overview
    - Implement progressive profit margins that increase with equipment level
    - Higher levels provide better ROI to incentivize upgrades
    
  2. New Progressive Economics
    - FREE CPU: $0 → $30 (3 hours) - Starter bonus
    - Level 1: $500 → $835 (72h) = 67% profit
    - Level 2: $1,000 → $1,780 (96h) = 78% profit
    - Level 3: $2,000 → $3,760 (96h) = 88% profit
    - Level 4: $3,000 → $5,970 (120h) = 99% profit
    - Level 5: $5,000 → $11,500 (168h) = 130% profit
    
  3. Hourly Earnings Calculation
    - Level 1: $835 ÷ 72h = $11.60/hour
    - Level 2: $1,780 ÷ 96h = $18.54/hour
    - Level 3: $3,760 ÷ 96h = $39.17/hour
    - Level 4: $5,970 ÷ 120h = $49.75/hour
    - Level 5: $11,500 ÷ 168h = $68.45/hour
    
  4. Daily Earnings (24 hours)
    - Level 1: $278.40/day
    - Level 2: $444.96/day
    - Level 3: $940.08/day
    - Level 4: $1,194.00/day
    - Level 5: $1,642.80/day
*/

-- FREE CPU Miner: $30 in 3 hours (unchanged)
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

-- LEVEL 2: $1,000 → $1,780 total (78% profit) in 96 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 18.54,
  daily_earning = 444.96,
  withdrawal_limit = 1780.00
WHERE name = 'ASIC Miner S19 Pro' AND level = 2;

-- LEVEL 3: $2,000 → $3,760 total (88% profit) in 96 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 39.17,
  daily_earning = 940.08,
  withdrawal_limit = 3760.00
WHERE name = 'ASIC Mining Farm' AND level = 3;

-- LEVEL 4: $3,000 → $5,970 total (99% profit) in 120 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 49.75,
  daily_earning = 1194.00,
  withdrawal_limit = 5970.00
WHERE name = 'Industrial Mining Station' AND level = 4;

-- LEVEL 5: $5,000 → $11,500 total (130% profit) in 168 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 68.45,
  daily_earning = 1642.80,
  withdrawal_limit = 11500.00
WHERE name = 'Quantum Mining Datacenter' AND level = 5;