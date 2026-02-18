/*
  # Progression Trap Economy System - Perfect Balance
  
  1. Overview
    - Users CANNOT withdraw until they reach Level 5
    - Each level earns ALMOST enough to withdraw, forcing upgrades
    - Fast start (5h) creates immediate dopamine
    - Gradually increases time investment
    
  2. Level Progression Strategy
    - Level 0 (FREE): 5h → $130 (limit: $200) ❌ Cannot withdraw
    - Level 1 ($150): 12h → $180 (total: $310, limit: $400) ❌ Cannot withdraw  
    - Level 2 ($400): 24h → $500 (total: $810, limit: $1,000) ❌ Cannot withdraw
    - Level 3 ($1,000): 48h → $1,300 (total: $2,110, limit: $2,500) ❌ Cannot withdraw
    - Level 4 ($2,500): 72h → $2,800 (total: $4,910, limit: $5,000) ❌ SO CLOSE!
    - Level 5 ($5,000): 120h → $8,000 (total: $12,910, limit: $10,000) ✅ CAN WITHDRAW!
    
  3. Psychology
    - FOMO: Always "just a bit more needed"
    - Sunk Cost: "Already invested $X, can't stop now"
    - Quick Start: 5 hours = instant gratification
    - Progressive Lock-in: Each level makes previous investment "wasted" if stops
    
  4. Total Investment Path
    - Total spent: $9,050
    - Total earned: $12,910  
    - Net profit: $3,860 (but requires completing ALL levels)
    - Time: ~10 days total mining
*/

-- Update Level 0 (CPU Miner) - Fast Dopamine Hit
UPDATE mining_equipment_types 
SET 
  daily_earning = 624.00,  -- 624/day * 5h/24 = $130
  mining_duration_hours = 5,
  withdrawal_limit = 200.00,
  description = 'FREE starter device! Mine for just 5 HOURS and earn $130! Start your mining empire NOW!'
WHERE name = 'CPU Miner' AND level = 0;

-- Update Level 1 (GPU Miner) - First Upgrade Trap
UPDATE mining_equipment_types 
SET 
  name = 'GPU Miner Pro',
  price = 150.00,
  daily_earning = 360.00,  -- 360/day * 12h/24 = $180
  mining_duration_hours = 12,
  withdrawal_limit = 400.00,
  icon = '🎮',
  description = 'Upgrade to GPU! 12 hours mining = $180. Combined with your $130, you will have $310 total! (Need $400 to withdraw)'
WHERE level = 1;

-- Update Level 2 (ASIC Pro) - Medium Upgrade Trap  
UPDATE mining_equipment_types 
SET 
  name = 'ASIC Miner Pro',
  price = 400.00,
  daily_earning = 500.00,  -- 500/day * 24h/24 = $500
  mining_duration_hours = 24,
  withdrawal_limit = 1000.00,
  icon = '⚡',
  description = 'Professional ASIC! 24 hours = $500 earnings. Total becomes $810! Almost at $1,000 withdrawal threshold!'
WHERE level = 2;

-- Update Level 3 (Mining Farm) - Heavy Investment Trap
UPDATE mining_equipment_types 
SET 
  name = 'Mining Farm',
  price = 1000.00,
  daily_earning = 650.00,  -- 650/day * 48h/24 = $1,300
  mining_duration_hours = 48,
  withdrawal_limit = 2500.00,
  icon = '🏭',
  description = 'Industrial scale! 48 hours = $1,300. Your balance reaches $2,110! Just $390 more to unlock withdrawal!'
WHERE level = 3;

-- Update Level 4 (Industrial Station) - Critical Trap Point
UPDATE mining_equipment_types 
SET 
  name = 'Industrial Mining Station',
  price = 2500.00,
  daily_earning = 933.33,  -- 933.33/day * 72h/24 = $2,800
  mining_duration_hours = 72,
  withdrawal_limit = 5000.00,
  icon = '🏗️',
  description = 'MASSIVE POWER! 72 hours = $2,800. Balance: $4,910! SO CLOSE to $5,000! One more upgrade unlocks everything!'
WHERE level = 4;

-- Update Level 5 (Quantum Datacenter) - Final Victory
UPDATE mining_equipment_types 
SET 
  name = 'Quantum Mining Datacenter',
  price = 5000.00,
  daily_earning = 1600.00,  -- 1600/day * 120h/24 = $8,000
  mining_duration_hours = 120,
  withdrawal_limit = 10000.00,
  icon = '🌟',
  description = '🏆 ULTIMATE LEVEL! 120 hours (5 days) = $8,000! Total: $12,910! WITHDRAWAL UNLOCKED! You made it!'
WHERE level = 5;

-- Update all user equipment to new durations (preserve their progress)
UPDATE user_mining_equipment ume
SET daily_earning_usdt = met.daily_earning
FROM mining_equipment_types met
WHERE ume.equipment_type_id = met.id;

-- Update CPU Miner ends_at for active miners
UPDATE user_mining_equipment
SET ends_at = CASE 
    WHEN status = 'active' THEN started_at + interval '5 hours'
    ELSE NULL
  END
WHERE equipment_type_id = (SELECT id FROM mining_equipment_types WHERE name = 'CPU Miner');

COMMENT ON TABLE mining_equipment_types IS 'Progression trap system: Users must upgrade through all levels to withdraw';
