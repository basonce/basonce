/*
  # Revert to Old Profitable Earnings System

  1. Overview
    - Revert mining equipment earnings to old profitable system
    - CPU Miner remains unchanged (current $130 in 5 hours)
    - All other equipment uses old progressive profit margins
    
  2. Old Earnings Structure (CPU Miner excluded)
    - Level 1 (ASIC S19): $500 → $835 in 72h (67% ROI)
    - Level 2 (ASIC S19 Pro): $1,000 → $1,780 in 96h (78% ROI)
    - Level 3 (Mining Farm): $2,000 → $3,760 in 96h (88% ROI)
    - Level 4 (Industrial): $3,000 → $5,970 in 120h (99% ROI)
    - Level 5 (Quantum): $5,000 → $11,500 in 168h (130% ROI)
    
  3. Benefits
    - Higher ROI incentivizes upgrades
    - Progressive earnings encourage level progression
    - More attractive to users
*/

-- LEVEL 1: $500 → $835 total (67% profit) in 72 hours
-- Hourly: $11.60/hour | Daily: $278.40/day
UPDATE mining_equipment_types
SET 
  earning_rate = 11.60,
  daily_earning = 278.40,
  withdrawal_limit = 835.00
WHERE name = 'ASIC Miner S19' AND level = 1;

-- LEVEL 2: $1,000 → $1,780 total (78% profit) in 96 hours
-- Hourly: $18.54/hour | Daily: $444.96/day
UPDATE mining_equipment_types
SET 
  earning_rate = 18.54,
  daily_earning = 444.96,
  withdrawal_limit = 1780.00
WHERE name = 'ASIC Miner S19 Pro' AND level = 2;

-- LEVEL 3: $2,000 → $3,760 total (88% profit) in 96 hours
-- Hourly: $39.17/hour | Daily: $940.08/day
UPDATE mining_equipment_types
SET 
  earning_rate = 39.17,
  daily_earning = 940.08,
  withdrawal_limit = 3760.00
WHERE name = 'ASIC Mining Farm' AND level = 3;

-- LEVEL 4: $3,000 → $5,970 total (99% profit) in 120 hours
-- Hourly: $49.75/hour | Daily: $1,194.00/day
UPDATE mining_equipment_types
SET 
  earning_rate = 49.75,
  daily_earning = 1194.00,
  withdrawal_limit = 5970.00
WHERE name = 'Industrial Mining Station' AND level = 4;

-- LEVEL 5: $5,000 → $11,500 total (130% profit) in 168 hours
-- Hourly: $68.45/hour | Daily: $1,642.80/day
UPDATE mining_equipment_types
SET 
  earning_rate = 68.45,
  daily_earning = 1642.80,
  withdrawal_limit = 11500.00
WHERE name = 'Quantum Mining Datacenter' AND level = 5;
