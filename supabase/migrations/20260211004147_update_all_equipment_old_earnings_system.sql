/*
  # Update ALL Equipment to Old Profitable Earnings System

  1. Overview
    - Apply old profitable earnings to current equipment lineup
    - CPU Miner stays at $130 in 5 hours (current system)
    - All other levels get old high ROI earnings
    
  2. New Structure with Old ROI Rates
    - Level 0 (FREE CPU): $0 → $130 in 5h (current - unchanged)
    - Level 1 (GPU Pro): $150 → $250 in 48h (67% ROI)
    - Level 2 (ASIC Pro): $400 → $712 in 72h (78% ROI)
    - Level 3 (Mining Farm): $1,000 → $1,880 in 96h (88% ROI)
    - Level 4 (Industrial): $2,500 → $4,975 in 120h (99% ROI)
    - Level 5 (Quantum): $5,000 → $11,500 in 168h (130% ROI)
    
  3. Benefits
    - Progressive profit margins (67% → 130%)
    - Attractive ROI at all levels
    - Clear upgrade path
*/

-- LEVEL 1: GPU Miner Pro - $150 → $250 (67% ROI) in 48 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 5.21,
  daily_earning = 125.00,
  withdrawal_limit = 250.00,
  description = 'Professional GPU mining rig. Earn $250 total in 48 hours with $150 investment. 67% ROI in 2 days. Hourly: $5.21/hour.'
WHERE name = 'GPU Miner Pro' AND level = 1;

-- LEVEL 2: ASIC Miner Pro - $400 → $712 (78% ROI) in 72 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 9.89,
  daily_earning = 237.33,
  withdrawal_limit = 712.00,
  description = 'Advanced ASIC mining system. Earn $712 total in 72 hours with $400 investment. 78% ROI in 3 days. Hourly: $9.89/hour.'
WHERE name = 'ASIC Miner Pro' AND level = 2;

-- LEVEL 3: Mining Farm - $1,000 → $1,880 (88% ROI) in 96 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 19.58,
  daily_earning = 470.00,
  withdrawal_limit = 1880.00,
  description = 'Complete mining farm operation. Earn $1,880 total in 96 hours with $1,000 investment. 88% ROI in 4 days. Hourly: $19.58/hour.'
WHERE name = 'Mining Farm' AND level = 3;

-- LEVEL 4: Industrial Mining Station - $2,500 → $4,975 (99% ROI) in 120 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 41.46,
  daily_earning = 995.00,
  withdrawal_limit = 4975.00,
  description = 'Industrial-scale mining facility. Earn $4,975 total in 120 hours with $2,500 investment. 99% ROI in 5 days. Hourly: $41.46/hour.'
WHERE name = 'Industrial Mining Station' AND level = 4;

-- LEVEL 5: Quantum Mining Datacenter - $5,000 → $11,500 (130% ROI) in 168 hours
UPDATE mining_equipment_types
SET 
  earning_rate = 68.45,
  daily_earning = 1642.80,
  withdrawal_limit = 11500.00,
  description = 'Ultimate quantum-powered datacenter. Earn $11,500 total in 168 hours with $5,000 investment. 130% ROI in 7 days. Hourly: $68.45/hour.'
WHERE name = 'Quantum Mining Datacenter' AND level = 5;
