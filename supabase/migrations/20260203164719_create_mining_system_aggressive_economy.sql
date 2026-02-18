/*
  # High-Yield Mining System - Aggressive Economy Model
  
  1. New Tables
    - `mining_equipment_types`
      - Equipment catalog with high ROI rates
      - Hash rates and earning potential
      - Professional equipment metadata
    
    - `user_mining_equipment`
      - User-owned mining equipment
      - Purchase tracking and activation times
      - Level and upgrade system
    
    - `mining_earnings`
      - Real-time earnings tracking
      - Claim history and pending balances
      - Performance metrics
    
    - `mining_boosts`
      - Active boost tracking
      - Temporary multipliers
      - Expiration management
    
    - `mining_stats`
      - Daily statistics
      - Hash rate history
      - Performance analytics
  
  2. Security
    - Enable RLS on all tables
    - Users can only access their own mining data
    - Public read for equipment catalog
  
  3. Features
    - Free starter equipment (high yield)
    - Fast ROI (1-3 days)
    - Real-time earnings calculation
    - Upgrade and boost system
*/

-- Mining Equipment Types Catalog
CREATE TABLE IF NOT EXISTS mining_equipment_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL,
  hash_rate numeric NOT NULL, -- TH/s
  earning_rate numeric NOT NULL, -- EQT per hour
  price numeric NOT NULL, -- EQT cost
  electricity_cost numeric DEFAULT 0, -- EQT per hour
  rarity text DEFAULT 'common' CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
  icon text DEFAULT '⛏️',
  color text DEFAULT '#F0B90B',
  max_level integer DEFAULT 10,
  is_starter boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- User Mining Equipment
CREATE TABLE IF NOT EXISTS user_mining_equipment (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  equipment_type_id uuid REFERENCES mining_equipment_types(id) NOT NULL,
  level integer DEFAULT 1,
  purchased_at timestamptz DEFAULT now(),
  last_claim_at timestamptz DEFAULT now(),
  total_earned numeric DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Mining Earnings
CREATE TABLE IF NOT EXISTS mining_earnings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  equipment_id uuid REFERENCES user_mining_equipment(id) ON DELETE CASCADE,
  amount numeric NOT NULL,
  earning_type text DEFAULT 'mining' CHECK (earning_type IN ('mining', 'boost', 'bonus', 'referral')),
  claimed boolean DEFAULT false,
  claimed_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Mining Boosts
CREATE TABLE IF NOT EXISTS mining_boosts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  boost_type text NOT NULL,
  multiplier numeric NOT NULL,
  duration_hours integer NOT NULL,
  activated_at timestamptz DEFAULT now(),
  expires_at timestamptz NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Mining Stats (Daily Aggregates)
CREATE TABLE IF NOT EXISTS mining_stats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  stat_date date DEFAULT CURRENT_DATE,
  total_hash_rate numeric DEFAULT 0,
  total_earned numeric DEFAULT 0,
  total_claimed numeric DEFAULT 0,
  uptime_percentage numeric DEFAULT 100,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, stat_date)
);

-- Enable RLS
ALTER TABLE mining_equipment_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_mining_equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE mining_earnings ENABLE ROW LEVEL SECURITY;
ALTER TABLE mining_boosts ENABLE ROW LEVEL SECURITY;
ALTER TABLE mining_stats ENABLE ROW LEVEL SECURITY;

-- RLS Policies for mining_equipment_types (Public Read)
CREATE POLICY "Anyone can view equipment types"
  ON mining_equipment_types FOR SELECT
  TO public
  USING (true);

-- RLS Policies for user_mining_equipment
CREATE POLICY "Users can view own mining equipment"
  ON user_mining_equipment FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own mining equipment"
  ON user_mining_equipment FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own mining equipment"
  ON user_mining_equipment FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for mining_earnings
CREATE POLICY "Users can view own earnings"
  ON mining_earnings FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own earnings"
  ON mining_earnings FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own earnings"
  ON mining_earnings FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for mining_boosts
CREATE POLICY "Users can view own boosts"
  ON mining_boosts FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own boosts"
  ON mining_boosts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for mining_stats
CREATE POLICY "Users can view own stats"
  ON mining_stats FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own stats"
  ON mining_stats FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own stats"
  ON mining_stats FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Insert High-Yield Equipment Types (Aggressive Economy)
INSERT INTO mining_equipment_types (name, description, hash_rate, earning_rate, price, electricity_cost, rarity, icon, color, is_starter) VALUES
  -- FREE STARTER (Very profitable)
  ('CPU Miner', 'Free starter equipment - Great for beginners!', 5, 0.01, 0, 0.001, 'common', '💻', '#10B981', true),
  
  -- BUDGET TIER (Fast ROI)
  ('GPU Mining Rig', 'RTX 4090 setup - High efficiency', 50, 0.15, 1, 0.01, 'common', '🖥️', '#3B82F6', false),
  
  -- PROFESSIONAL TIER (Very fast ROI)
  ('ASIC Miner S19', 'Professional ASIC miner - Industry standard', 250, 0.8, 5, 0.05, 'rare', '⚡', '#F59E0B', false),
  
  -- ADVANCED TIER (Premium)
  ('Mining Container', 'Full container setup - Massive output', 1200, 4.5, 20, 0.2, 'epic', '🏭', '#8B5CF6', false),
  
  -- PRO TIER (High rollers)
  ('Industrial Farm', 'Complete mining farm - Maximum profit', 5000, 20, 80, 0.8, 'epic', '🏢', '#EC4899', false),
  
  -- LEGENDARY TIER (Exclusive)
  ('Quantum Mining Rig', 'Next-gen technology - Unmatched power', 25000, 120, 400, 3, 'legendary', '⚛️', '#F0B90B', false)
ON CONFLICT DO NOTHING;

-- Function to calculate pending earnings
CREATE OR REPLACE FUNCTION calculate_pending_earnings(p_user_id uuid)
RETURNS numeric AS $$
DECLARE
  total_pending numeric := 0;
  equipment_record RECORD;
  hours_elapsed numeric;
  base_earning numeric;
  boost_multiplier numeric := 1;
BEGIN
  -- Get active boosts
  SELECT COALESCE(SUM(multiplier), 0) INTO boost_multiplier
  FROM mining_boosts
  WHERE user_id = p_user_id
    AND is_active = true
    AND expires_at > now();
  
  IF boost_multiplier = 0 THEN
    boost_multiplier := 1;
  END IF;

  -- Calculate earnings for each equipment
  FOR equipment_record IN
    SELECT 
      ume.id,
      ume.last_claim_at,
      met.earning_rate,
      met.electricity_cost,
      ume.level
    FROM user_mining_equipment ume
    JOIN mining_equipment_types met ON ume.equipment_type_id = met.id
    WHERE ume.user_id = p_user_id
      AND ume.is_active = true
  LOOP
    -- Calculate hours elapsed since last claim
    hours_elapsed := EXTRACT(EPOCH FROM (now() - equipment_record.last_claim_at)) / 3600.0;
    
    -- Cap at 24 hours max accumulation
    IF hours_elapsed > 24 THEN
      hours_elapsed := 24;
    END IF;
    
    -- Base earning with level bonus (10% per level)
    base_earning := equipment_record.earning_rate * (1 + (equipment_record.level - 1) * 0.1);
    
    -- Apply boost and subtract electricity
    total_pending := total_pending + 
      ((base_earning * hours_elapsed * boost_multiplier) - (equipment_record.electricity_cost * hours_elapsed));
  END LOOP;

  RETURN GREATEST(total_pending, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to claim earnings
CREATE OR REPLACE FUNCTION claim_mining_earnings(p_user_id uuid)
RETURNS numeric AS $$
DECLARE
  pending_amount numeric;
  equipment_record RECORD;
BEGIN
  -- Calculate total pending
  pending_amount := calculate_pending_earnings(p_user_id);
  
  IF pending_amount <= 0 THEN
    RETURN 0;
  END IF;

  -- Update user balance
  UPDATE user_balances
  SET balance = balance + pending_amount,
      updated_at = now()
  WHERE user_id = p_user_id
    AND coin = 'EQT';

  -- Record earnings
  INSERT INTO mining_earnings (user_id, amount, earning_type, claimed, claimed_at)
  VALUES (p_user_id, pending_amount, 'mining', true, now());

  -- Update last_claim_at for all equipment
  UPDATE user_mining_equipment
  SET last_claim_at = now(),
      total_earned = total_earned + pending_amount
  WHERE user_id = p_user_id
    AND is_active = true;

  -- Update daily stats
  INSERT INTO mining_stats (user_id, stat_date, total_earned, total_claimed)
  VALUES (p_user_id, CURRENT_DATE, pending_amount, pending_amount)
  ON CONFLICT (user_id, stat_date)
  DO UPDATE SET
    total_earned = mining_stats.total_earned + EXCLUDED.total_earned,
    total_claimed = mining_stats.total_claimed + EXCLUDED.total_claimed;

  RETURN pending_amount;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to auto-assign free starter equipment
CREATE OR REPLACE FUNCTION assign_starter_mining_equipment()
RETURNS trigger AS $$
DECLARE
  starter_equipment_id uuid;
BEGIN
  -- Get the free starter equipment
  SELECT id INTO starter_equipment_id
  FROM mining_equipment_types
  WHERE is_starter = true
  LIMIT 1;

  IF starter_equipment_id IS NOT NULL THEN
    -- Give user the free starter equipment
    INSERT INTO user_mining_equipment (user_id, equipment_type_id, level, last_claim_at)
    VALUES (NEW.id, starter_equipment_id, 1, now());
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to give free equipment on user creation
DROP TRIGGER IF EXISTS assign_starter_equipment_trigger ON user_profiles;
CREATE TRIGGER assign_starter_equipment_trigger
  AFTER INSERT ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION assign_starter_mining_equipment();

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_mining_equipment_user ON user_mining_equipment(user_id);
CREATE INDEX IF NOT EXISTS idx_mining_earnings_user ON mining_earnings(user_id);
CREATE INDEX IF NOT EXISTS idx_mining_boosts_user_active ON mining_boosts(user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_mining_stats_user_date ON mining_stats(user_id, stat_date);