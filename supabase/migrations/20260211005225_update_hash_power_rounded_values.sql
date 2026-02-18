/*
  # Update Hash Power Values - Clean Rounded Numbers
  
  1. Changes
    - Round all earning_rate values to clean 2 decimal places
    - Update descriptions to match new hourly rates
    
  2. Updated Values
    - CPU Miner: 43.33 → 43.30
    - GPU Miner Pro: 5.21 → 5.20
    - ASIC Miner Pro: 9.89 → 9.90
    - Mining Farm: 19.58 → 19.60
    - Industrial Mining Station: 41.46 → 41.50
    - Quantum Mining Datacenter: 68.45 → 68.50
*/

-- Update earning rates to clean rounded values
UPDATE mining_equipment_types SET 
  earning_rate = 43.30,
  description = 'FREE starter device! Mine for just 5 HOURS and earn $130! Start your mining empire NOW!'
WHERE level = 0;

UPDATE mining_equipment_types SET 
  earning_rate = 5.20,
  description = 'Professional GPU mining rig. Earn $250 total in 48 hours with $150 investment. 67% ROI in 2 days. Hourly: $5.20/hour.'
WHERE level = 1;

UPDATE mining_equipment_types SET 
  earning_rate = 9.90,
  description = 'Advanced ASIC mining system. Earn $712 total in 72 hours with $400 investment. 78% ROI in 3 days. Hourly: $9.90/hour.'
WHERE level = 2;

UPDATE mining_equipment_types SET 
  earning_rate = 19.60,
  description = 'Complete mining farm operation. Earn $1,880 total in 96 hours with $1,000 investment. 88% ROI in 4 days. Hourly: $19.60/hour.'
WHERE level = 3;

UPDATE mining_equipment_types SET 
  earning_rate = 41.50,
  description = 'Industrial-scale mining facility. Earn $4,975 total in 120 hours with $2,500 investment. 99% ROI in 5 days. Hourly: $41.50/hour.'
WHERE level = 4;

UPDATE mining_equipment_types SET 
  earning_rate = 68.50,
  description = 'Ultimate quantum-powered datacenter. Earn $11,500 total in 168 hours with $5,000 investment. 130% ROI in 7 days. Hourly: $68.50/hour.'
WHERE level = 5;