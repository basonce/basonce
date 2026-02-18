/*
  # Update Mining Equipment Colors - Make Each Unique
  
  1. Overview
    - Give each mining equipment level a unique, vibrant color scheme
    - Colors should stand out and not conflict with other UI elements
    - Progressive color scheme from starter to VIP
    
  2. New Color Scheme
    - FREE: Gray (neutral starter)
    - Level 1: Emerald Green (fresh start, growth)
    - Level 2: Cyan/Teal (advanced, professional)
    - Level 3: Amber/Orange (elite, energetic)
    - Level 4: Rose/Pink (luxury, premium)
    - Level 5: Gold (ultimate VIP, wealth)
    
  3. Changes
    - Update color column for all 6 equipment types
    - Ensure gradients are smooth and attractive
*/

-- FREE CPU Miner: Gray (unchanged)
UPDATE mining_equipment_types
SET color = 'from-gray-400 to-gray-600'
WHERE name = 'CPU Miner' AND is_free = true;

-- LEVEL 1: Emerald Green (growth, fresh start)
UPDATE mining_equipment_types
SET color = 'from-emerald-400 to-emerald-600'
WHERE name = 'ASIC Miner S19' AND level = 1;

-- LEVEL 2: Cyan/Teal (professional, advanced)
UPDATE mining_equipment_types
SET color = 'from-cyan-400 to-cyan-600'
WHERE name = 'ASIC Miner S19 Pro' AND level = 2;

-- LEVEL 3: Amber/Orange (elite, energetic)
UPDATE mining_equipment_types
SET color = 'from-amber-400 to-amber-600'
WHERE name = 'ASIC Mining Farm' AND level = 3;

-- LEVEL 4: Rose/Pink (luxury, premium)
UPDATE mining_equipment_types
SET color = 'from-rose-400 to-rose-600'
WHERE name = 'Industrial Mining Station' AND level = 4;

-- LEVEL 5: Gold (ultimate VIP, wealth)
UPDATE mining_equipment_types
SET color = 'from-yellow-400 via-amber-500 to-yellow-600'
WHERE name = 'Quantum Mining Datacenter' AND level = 5;