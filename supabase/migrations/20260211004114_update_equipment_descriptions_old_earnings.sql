/*
  # Update Equipment Descriptions for Old Earnings

  1. Overview
    - Update mining equipment descriptions to reflect old profitable earnings
    - Clear ROI information for each level
    - CPU Miner description remains unchanged
    
  2. Changes
    - Level 1: 67% ROI in 3 days
    - Level 2: 78% ROI in 4 days
    - Level 3: 88% ROI in 4 days
    - Level 4: 99% ROI in 5 days
    - Level 5: 130% ROI in 7 days
*/

-- LEVEL 1: ASIC Miner S19
UPDATE mining_equipment_types
SET description = 'Professional ASIC miner. Earn $835 total in 72 hours with $500 investment. 67% ROI in 3 days. Hourly: $11.60/hour.'
WHERE name = 'ASIC Miner S19' AND level = 1;

-- LEVEL 2: ASIC Miner S19 Pro
UPDATE mining_equipment_types
SET description = 'Advanced ASIC mining system. Earn $1,780 total in 96 hours with $1,000 investment. 78% ROI in 4 days. Hourly: $18.54/hour.'
WHERE name = 'ASIC Miner S19 Pro' AND level = 2;

-- LEVEL 3: ASIC Mining Farm
UPDATE mining_equipment_types
SET description = 'Complete mining farm operation. Earn $3,760 total in 96 hours with $2,000 investment. 88% ROI in 4 days. Hourly: $39.17/hour.'
WHERE name = 'ASIC Mining Farm' AND level = 3;

-- LEVEL 4: Industrial Mining Station
UPDATE mining_equipment_types
SET description = 'Industrial-scale mining facility. Earn $5,970 total in 120 hours with $3,000 investment. 99% ROI in 5 days. Hourly: $49.75/hour.'
WHERE name = 'Industrial Mining Station' AND level = 4;

-- LEVEL 5: Quantum Mining Datacenter
UPDATE mining_equipment_types
SET description = 'Ultimate quantum-powered datacenter. Earn $11,500 total in 168 hours with $5,000 investment. 130% ROI in 7 days. Hourly: $68.45/hour.'
WHERE name = 'Quantum Mining Datacenter' AND level = 5;
