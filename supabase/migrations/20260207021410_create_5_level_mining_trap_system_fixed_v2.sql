/*
  # 5-Level Mining Trap System with FREE Starter
  
  1. Overview
    - FREE CPU Miner: 3-hour trial to hook users ($30 earned, but $500 minimum withdrawal)
    - Level 1-5: Progressive trap system where users keep investing to reach withdrawal limits
    
  2. Changes
    - RESET mining_equipment_types to 6 items (FREE + 5 levels)
    - Add withdrawal_limit column to track minimum withdrawal per level
    - Add level column for progression tracking
    - Update mining durations and earnings to match trap strategy
    - Update rarity constraint to include 'free' and 'mythic'
    
  3. Psychological Trap Strategy
    - FREE: $30 earned, $500 minimum → Forces Level 1 purchase
    - Level 1: $225 earned, $2,000 minimum → Forces Level 2
    - Level 2: $600 earned, $4,000 minimum → Forces Level 3
    - Level 3: $1,400 earned, $8,000 minimum → Forces Level 4
    - Level 4: $3,000 earned, $15,000 minimum → Forces Level 5
    - Level 5: $8,400 earned, $25,000 minimum → Still can't withdraw!
    
  4. Total Investment vs Earnings
    - Total invested: $11,500
    - Total earned: $13,625
    - Still below $25,000 withdrawal limit!
    
  5. Security
    - All existing RLS policies remain active
    - Only equipment visibility changes
*/

-- Drop existing equipment and user equipment
TRUNCATE TABLE user_mining_equipment CASCADE;
TRUNCATE TABLE mining_equipment_types CASCADE;

-- Update rarity constraint to include 'free' and 'mythic'
ALTER TABLE mining_equipment_types 
DROP CONSTRAINT IF EXISTS mining_equipment_types_rarity_check;

ALTER TABLE mining_equipment_types 
ADD CONSTRAINT mining_equipment_types_rarity_check 
CHECK (rarity IN ('free', 'common', 'rare', 'epic', 'legendary', 'mythic'));

-- Add new columns to mining_equipment_types
ALTER TABLE mining_equipment_types 
ADD COLUMN IF NOT EXISTS level INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS withdrawal_limit DECIMAL(20,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS daily_earning DECIMAL(20,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS mining_duration_hours INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS badge TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS is_free BOOLEAN DEFAULT false;

-- Insert FREE CPU MINER (auto-given to new users)
INSERT INTO mining_equipment_types (
  name, 
  description,
  icon, 
  hash_rate, 
  price, 
  earning_rate, 
  electricity_cost,
  rarity,
  color,
  level,
  withdrawal_limit,
  daily_earning,
  mining_duration_hours,
  badge,
  is_free,
  is_starter
) VALUES (
  'CPU Miner',
  'FREE 3-hour trial mining! Start earning immediately!',
  '💻',
  10.00,
  0,
  10.00,
  0,
  'free',
  'from-gray-400 to-gray-600',
  0,
  500.00,
  240.00,
  3,
  '🎁 FREE TRIAL',
  true,
  true
);

-- LEVEL 1: "ENTRY TRAP" - $500 investment
INSERT INTO mining_equipment_types (
  name, 
  description,
  icon, 
  hash_rate, 
  price, 
  earning_rate, 
  electricity_cost,
  rarity,
  color,
  level,
  withdrawal_limit,
  daily_earning,
  mining_duration_hours,
  badge,
  is_free,
  is_starter
) VALUES (
  'ASIC Miner S19',
  'Professional mining equipment. 15% daily returns! Unlock $2,000 withdrawal limit.',
  '⚡',
  95.00,
  500.00,
  3.125,
  75.00,
  'common',
  'from-yellow-400 to-yellow-600',
  1,
  2000.00,
  75.00,
  72,
  '⚡ STARTER',
  false,
  false
);

-- LEVEL 2: "CONFIDENCE TRAP" - $1,000 investment
INSERT INTO mining_equipment_types (
  name, 
  description,
  icon, 
  hash_rate, 
  price, 
  earning_rate, 
  electricity_cost,
  rarity,
  color,
  level,
  withdrawal_limit,
  daily_earning,
  mining_duration_hours,
  badge,
  is_free,
  is_starter
) VALUES (
  'ASIC Miner S19 Pro',
  'Advanced mining rig. 15% daily returns! Unlock $4,000 withdrawal limit.',
  '💎',
  110.00,
  1000.00,
  6.25,
  150.00,
  'rare',
  'from-blue-400 to-blue-600',
  2,
  4000.00,
  150.00,
  96,
  '💎 PRO',
  false,
  false
);

-- LEVEL 3: "SERIOUS PLAYER" - $2,000 investment
INSERT INTO mining_equipment_types (
  name, 
  description,
  icon, 
  hash_rate, 
  price, 
  earning_rate, 
  electricity_cost,
  rarity,
  color,
  level,
  withdrawal_limit,
  daily_earning,
  mining_duration_hours,
  badge,
  is_free,
  is_starter
) VALUES (
  'ASIC Mining Farm',
  'Industrial mining farm. 17.5% daily returns! Unlock $8,000 withdrawal limit.',
  '🔥',
  500.00,
  2000.00,
  14.583,
  350.00,
  'epic',
  'from-orange-400 to-orange-600',
  3,
  8000.00,
  350.00,
  96,
  '🏆 ELITE MINER',
  false,
  false
);

-- LEVEL 4: "HIGH ROLLER" - $3,000 investment
INSERT INTO mining_equipment_types (
  name, 
  description,
  icon, 
  hash_rate, 
  price, 
  earning_rate, 
  electricity_cost,
  rarity,
  color,
  level,
  withdrawal_limit,
  daily_earning,
  mining_duration_hours,
  badge,
  is_free,
  is_starter
) VALUES (
  'Industrial Mining Station',
  'Elite mining operation. 20% daily returns! Unlock $15,000 withdrawal limit.',
  '⚡',
  1000.00,
  3000.00,
  25.00,
  600.00,
  'legendary',
  'from-red-400 to-red-600',
  4,
  15000.00,
  600.00,
  120,
  '💎 DIAMOND MINER',
  false,
  false
);

-- LEVEL 5: "ULTIMATE VIP" - $5,000 investment
INSERT INTO mining_equipment_types (
  name, 
  description,
  icon, 
  hash_rate, 
  price, 
  earning_rate, 
  electricity_cost,
  rarity,
  color,
  level,
  withdrawal_limit,
  daily_earning,
  mining_duration_hours,
  badge,
  is_free,
  is_starter
) VALUES (
  'Quantum Mining Datacenter',
  'Ultimate VIP mining datacenter. 24% daily returns! Unlock $25,000 withdrawal limit.',
  '👑',
  10000.00,
  5000.00,
  50.00,
  1200.00,
  'mythic',
  'from-yellow-300 via-yellow-500 to-yellow-700',
  5,
  25000.00,
  1200.00,
  168,
  '👑 WHALE VIP',
  false,
  false
);

-- Add minimum_withdrawal_limit to user_profiles
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS minimum_withdrawal_limit DECIMAL(20,2) DEFAULT 500.00;

-- Function to auto-give FREE CPU Miner to new users
CREATE OR REPLACE FUNCTION give_free_cpu_miner()
RETURNS TRIGGER AS $$
DECLARE
  v_free_equipment_id UUID;
BEGIN
  -- Get the FREE CPU Miner equipment
  SELECT id INTO v_free_equipment_id
  FROM mining_equipment_types
  WHERE is_free = true
  LIMIT 1;
  
  -- Give it to the new user
  IF v_free_equipment_id IS NOT NULL THEN
    INSERT INTO user_mining_equipment (
      user_id,
      equipment_type_id,
      icon,
      is_active,
      started_at,
      ends_at
    )
    SELECT 
      NEW.id,
      v_free_equipment_id,
      icon,
      false,
      NULL,
      NULL
    FROM mining_equipment_types
    WHERE id = v_free_equipment_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-give FREE CPU Miner
DROP TRIGGER IF EXISTS auto_give_free_cpu_miner ON user_profiles;
CREATE TRIGGER auto_give_free_cpu_miner
  AFTER INSERT ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION give_free_cpu_miner();

-- Function to update user's withdrawal limit based on highest level owned
CREATE OR REPLACE FUNCTION update_user_withdrawal_limit()
RETURNS TRIGGER AS $$
DECLARE
  v_max_limit DECIMAL(20,2);
BEGIN
  -- Get the highest withdrawal limit from owned equipment
  SELECT COALESCE(MAX(met.withdrawal_limit), 500.00)
  INTO v_max_limit
  FROM user_mining_equipment ume
  JOIN mining_equipment_types met ON ume.equipment_type_id = met.id
  WHERE ume.user_id = NEW.user_id;
  
  -- Update user's minimum withdrawal limit
  UPDATE user_profiles
  SET minimum_withdrawal_limit = v_max_limit
  WHERE id = NEW.user_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update withdrawal limit when user buys new equipment
DROP TRIGGER IF EXISTS update_withdrawal_limit_on_purchase ON user_mining_equipment;
CREATE TRIGGER update_withdrawal_limit_on_purchase
  AFTER INSERT ON user_mining_equipment
  FOR EACH ROW
  EXECUTE FUNCTION update_user_withdrawal_limit();

-- Make mining_equipment_types public for shop browsing
DROP POLICY IF EXISTS "Anyone can view equipment types" ON mining_equipment_types;
CREATE POLICY "Anyone can view equipment types"
  ON mining_equipment_types
  FOR SELECT
  TO authenticated
  USING (true);