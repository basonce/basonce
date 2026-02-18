/*
  # Update Equipment Descriptions - 67% ROI Marketing
  
  1. Overview
    - Update all equipment descriptions to reflect new 67% profit margins
    - Clear, compelling marketing copy highlighting earnings and ROI
    
  2. New Descriptions
    - FREE CPU: $30 in 3 hours (Free starter)
    - Level 1: $500 → $835 in 72 hours (67% ROI)
    - Level 2: $1,000 → $1,670 in 96 hours (67% ROI)
    - Level 3: $2,000 → $3,340 in 96 hours (67% ROI)
    - Level 4: $3,000 → $5,010 in 120 hours (67% ROI)
    - Level 5: $5,000 → $8,350 in 168 hours (67% ROI)
*/

-- FREE CPU Miner
UPDATE mining_equipment_types
SET description = 'Start mining for free! Earn $30 in just 3 hours. Perfect for beginners to get started.'
WHERE name = 'CPU Miner' AND is_free = true;

-- Level 1: ASIC Miner S19
UPDATE mining_equipment_types
SET description = 'Professional mining equipment. Earn $835 in 72 hours! 67% ROI. Great entry point.'
WHERE name = 'ASIC Miner S19' AND level = 1;

-- Level 2: ASIC Miner S19 Pro
UPDATE mining_equipment_types
SET description = 'Advanced mining rig. Earn $1,670 in 96 hours! 67% ROI. Enhanced performance.'
WHERE name = 'ASIC Miner S19 Pro' AND level = 2;

-- Level 3: ASIC Mining Farm
UPDATE mining_equipment_types
SET description = 'Industrial-grade mining farm. Earn $3,340 in 96 hours! 67% ROI. Serious mining power.'
WHERE name = 'ASIC Mining Farm' AND level = 3;

-- Level 4: Industrial Mining Station
UPDATE mining_equipment_types
SET description = 'Powerful mining station. Earn $5,010 in 120 hours! 67% ROI. Enterprise-level mining.'
WHERE name = 'Industrial Mining Station' AND level = 4;

-- Level 5: Quantum Mining Datacenter
UPDATE mining_equipment_types
SET description = 'Ultimate quantum datacenter. Earn $8,350 in 168 hours! 67% ROI. Maximum profits.'
WHERE name = 'Quantum Mining Datacenter' AND level = 5;