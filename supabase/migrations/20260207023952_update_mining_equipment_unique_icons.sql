/*
  # Update Mining Equipment with Unique Icons
  
  1. Changes
    - Update each level's icon to be unique and visually distinct
    - Level 0 (FREE): 💻 CPU
    - Level 1: ⚡ ASIC Professional
    - Level 2: 🏭 Mining Farm
    - Level 3: 🔧 Industrial Rig
    - Level 4: 🏢 Data Center
    - Level 5: 🚀 Quantum Array
  
  2. Why
    - Each level should have a unique visual identity
    - Users need to see clear progression as they upgrade
*/

-- Update Level 0 (FREE CPU Miner)
UPDATE mining_equipment_types
SET icon = '💻'
WHERE level = 0;

-- Update Level 1 (ASIC Miner S19)
UPDATE mining_equipment_types
SET icon = '⚡'
WHERE level = 1;

-- Update Level 2 (Mining Farm Basic)
UPDATE mining_equipment_types
SET icon = '🏭'
WHERE level = 2;

-- Update Level 3 (Industrial Mining Rig)
UPDATE mining_equipment_types
SET icon = '🔧'
WHERE level = 3;

-- Update Level 4 (Mining Data Center)
UPDATE mining_equipment_types
SET icon = '🏢'
WHERE level = 4;

-- Update Level 5 (Quantum Mining Array)
UPDATE mining_equipment_types
SET icon = '🚀'
WHERE level = 5;

-- Update user_mining_equipment to match their equipment type icons
UPDATE user_mining_equipment ume
SET icon = met.icon
FROM mining_equipment_types met
WHERE ume.equipment_type_id = met.id;