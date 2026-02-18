/*
  # Update Equipment Descriptions - Progressive ROI Marketing
  
  1. Overview
    - Update descriptions to highlight progressive profit margins
    - Each level emphasizes its unique ROI advantage
    
  2. Progressive Marketing
    - Level 1: 67% ROI - Entry point
    - Level 2: 78% ROI - Better returns
    - Level 3: 88% ROI - High profitability
    - Level 4: 99% ROI - Nearly double investment
    - Level 5: 130% ROI - Premium returns
*/

-- FREE CPU Miner
UPDATE mining_equipment_types
SET description = 'Start mining for free! Earn $30 in just 3 hours. Perfect for beginners to get started.'
WHERE name = 'CPU Miner' AND is_free = true;

-- Level 1: ASIC Miner S19 (67% ROI)
UPDATE mining_equipment_types
SET description = 'Professional mining equipment. Earn $835 in 72 hours! 67% ROI. Great entry point for serious miners.'
WHERE name = 'ASIC Miner S19' AND level = 1;

-- Level 2: ASIC Miner S19 Pro (78% ROI)
UPDATE mining_equipment_types
SET description = 'Advanced mining rig. Earn $1,780 in 96 hours! 78% ROI. Enhanced performance and better returns.'
WHERE name = 'ASIC Miner S19 Pro' AND level = 2;

-- Level 3: ASIC Mining Farm (88% ROI)
UPDATE mining_equipment_types
SET description = 'Industrial mining farm. Earn $3,760 in 96 hours! 88% ROI. Serious mining power with high profitability.'
WHERE name = 'ASIC Mining Farm' AND level = 3;

-- Level 4: Industrial Mining Station (99% ROI)
UPDATE mining_equipment_types
SET description = 'Powerful mining station. Earn $5,970 in 120 hours! 99% ROI. Nearly double your investment!'
WHERE name = 'Industrial Mining Station' AND level = 4;

-- Level 5: Quantum Mining Datacenter (130% ROI)
UPDATE mining_equipment_types
SET description = 'Ultimate quantum datacenter. Earn $11,500 in 168 hours! 130% ROI. Maximum profits guaranteed!'
WHERE name = 'Quantum Mining Datacenter' AND level = 5;