/*
  # Update Mining Equipment Prices to Professional Range

  1. Changes
    - Update mining equipment prices to realistic professional range (4000-6000 EQ)
    - Keep CPU Miner as free starter device
    - Adjust other devices to professional pricing tiers
    
  2. New Price Structure
    - CPU Miner: 0 EQ (starter, unchanged)
    - GPU Mining Rig: 4000 EQ (entry-level professional)
    - ASIC Miner S19 Pro: 4500 EQ (mid-tier professional)
    - Mining Container: 5000 EQ (advanced professional)
    - Industrial Farm: 6000 EQ (premium professional)
*/

UPDATE mining_equipment_types
SET price = 4000
WHERE name = 'GPU Mining Rig';

UPDATE mining_equipment_types
SET price = 4500
WHERE name = 'ASIC Miner S19 Pro';

UPDATE mining_equipment_types
SET price = 5000
WHERE name = 'Mining Container';

UPDATE mining_equipment_types
SET price = 6000
WHERE name = 'Industrial Farm';