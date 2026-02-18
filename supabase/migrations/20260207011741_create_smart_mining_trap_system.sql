/*
  # Smart Mining Trap System - 6-Level Progressive Withdrawal System

  This migration implements the "Yumuşak Tuzak" (Soft Trap) mining economy.

  ## Strategy
  - **Level 0-1**: Small withdrawals allowed → Build trust
  - **Level 2**: Medium withdrawals allowed → User invests more
  - **Level 3+**: Locked withdrawals → Trap activated

  ## New Columns

  ### `mining_shop_items`
  - `withdrawal_enabled` (boolean) - Can user withdraw earnings?
  - `min_withdrawal_amount` (numeric) - Minimum withdrawal threshold
  - `max_mining_hours` (integer) - Time limit (NULL = unlimited)
  - `hourly_earning_usdt` (numeric) - Earnings per hour
  - `level` (integer) - Equipment level (0-5)

  ### `user_mining_purchases`
  - `started_at` (timestamptz) - When mining started
  - `expires_at` (timestamptz) - When free miner stops (NULL = unlimited)
  - `hours_mined` (numeric) - Total hours mined
  - `is_expired` (boolean) - Has the timer expired?

  ## 6 Equipment Levels

  ### Level 0: CPU Miner (FREE) ⏱️
  - **Price**: $0 (FREE)
  - **Earnings**: $50/hour
  - **Timer**: 3 hours ONLY
  - **Total Earnings**: $150
  - **Withdrawal**: ❌ BLOCKED (min $500) → Forces upgrade

  ### Level 1: ASIC S19 Pro ($500) ✅
  - **Price**: $500 USDT
  - **Earnings**: $60/hour
  - **Timer**: Unlimited
  - **Withdrawal**: ✅ ALLOWED (min $100) → Builds trust
  - **Strategy**: User withdraws $100, thinks "This is real!" → Invests more

  ### Level 2: Mining Container ($2,000) ✅
  - **Price**: $2,000 USDT
  - **Earnings**: $250/hour
  - **Withdrawal**: ✅ ALLOWED (min $500) → Still trustworthy
  - **Strategy**: User makes $500 profit, gets confident → Goes for Level 3

  ### Level 3: Mining Farm ($8,000) 🚫
  - **Price**: $8,000 USDT
  - **Earnings**: $1,000/hour (HIGH!)
  - **Withdrawal**: ❌ LOCKED (min $30,000) → Trap activates!
  - **Strategy**: Shows huge earnings, but can't withdraw → Must buy Level 4

  ### Level 4: Data Center ($30,000) 🚫
  - **Price**: $30,000 USDT
  - **Earnings**: $4,000/hour (VERY HIGH!)
  - **Withdrawal**: ❌ LOCKED (min $120,000) → Deeper trap

  ### Level 5: Global Network ($120,000) 🚫
  - **Price**: $120,000 USDT
  - **Earnings**: $20,000/hour (INSANE!)
  - **Withdrawal**: ❌ KYC Required (never approved) → Ultimate trap

  ## Security
  - Enable RLS on all tables
  - Users can only manage their own equipment
*/

-- Add new columns to mining_shop_items
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'mining_shop_items' AND column_name = 'withdrawal_enabled') THEN
    ALTER TABLE mining_shop_items ADD COLUMN withdrawal_enabled boolean DEFAULT true;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'mining_shop_items' AND column_name = 'min_withdrawal_amount') THEN
    ALTER TABLE mining_shop_items ADD COLUMN min_withdrawal_amount numeric DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'mining_shop_items' AND column_name = 'max_mining_hours') THEN
    ALTER TABLE mining_shop_items ADD COLUMN max_mining_hours integer DEFAULT NULL;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'mining_shop_items' AND column_name = 'hourly_earning_usdt') THEN
    ALTER TABLE mining_shop_items ADD COLUMN hourly_earning_usdt numeric DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'mining_shop_items' AND column_name = 'level') THEN
    ALTER TABLE mining_shop_items ADD COLUMN level integer DEFAULT 0;
  END IF;
END $$;

-- Add new columns to user_mining_purchases
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_mining_purchases' AND column_name = 'started_at') THEN
    ALTER TABLE user_mining_purchases ADD COLUMN started_at timestamptz DEFAULT now();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_mining_purchases' AND column_name = 'expires_at') THEN
    ALTER TABLE user_mining_purchases ADD COLUMN expires_at timestamptz DEFAULT NULL;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_mining_purchases' AND column_name = 'hours_mined') THEN
    ALTER TABLE user_mining_purchases ADD COLUMN hours_mined numeric DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_mining_purchases' AND column_name = 'is_expired') THEN
    ALTER TABLE user_mining_purchases ADD COLUMN is_expired boolean DEFAULT false;
  END IF;
END $$;

-- Clear existing mining equipment
DELETE FROM mining_shop_items;

-- Insert 6-Level Smart Trap Mining Equipment
INSERT INTO mining_shop_items (
  name, 
  description, 
  tier, 
  level,
  price_usdt, 
  hash_rate, 
  hourly_earning_usdt,
  daily_earning_usdt, 
  roi_days, 
  icon, 
  badge, 
  bonus_text,
  withdrawal_enabled,
  min_withdrawal_amount,
  max_mining_hours,
  sort_order,
  is_available
) VALUES

-- Level 0: CPU Miner (FREE) - 3 Hour Trap
(
  'CPU Miner',
  'Free starter device. Mine for 3 hours and earn $150. Limited time only!',
  'free',
  0,
  0,                    -- FREE
  10,                   -- 10 TH/s
  50,                   -- $50/hour
  1200,                 -- $1200/day (fake - only runs 3h)
  0,                    -- ROI: 0 days (it's free!)
  '🖥️',
  '🎁 FREE',
  '⏰ 3 Hour Limit',
  false,                -- ❌ WITHDRAWALS BLOCKED
  500,                  -- Min withdrawal: $500 (impossible with $150 earnings!)
  3,                    -- Max 3 hours
  1,
  true
),

-- Level 1: ASIC S19 Pro ($500) - Trust Building Phase
(
  'ASIC S19 Pro',
  'Professional mining hardware. Start earning $60/hour with unlimited runtime!',
  'starter',
  1,
  500,                  -- $500 USDT
  110,                  -- 110 TH/s (realistic)
  60,                   -- $60/hour
  1440,                 -- $1,440/day
  8,                    -- ROI: 8 days
  '⚡',
  '🔥 POPULAR',
  '✅ Withdrawals Enabled',
  true,                 -- ✅ WITHDRAWALS ALLOWED
  100,                  -- Min withdrawal: $100 (achievable in 2 hours)
  NULL,                 -- Unlimited hours
  2,
  true
),

-- Level 2: Mining Container ($2,000) - Confidence Building
(
  'Mining Container',
  '10x ASIC S19 Pro in industrial container. Earn $250/hour!',
  'popular',
  2,
  2000,                 -- $2,000 USDT
  1100,                 -- 1100 TH/s
  250,                  -- $250/hour
  6000,                 -- $6,000/day
  8,                    -- ROI: 8 days
  '🏭',
  '⭐ BEST VALUE',
  '✅ Fast Withdrawals',
  true,                 -- ✅ WITHDRAWALS ALLOWED
  500,                  -- Min withdrawal: $500 (achievable in 2 hours)
  NULL,                 -- Unlimited hours
  3,
  true
),

-- Level 3: Mining Farm ($8,000) - THE TRAP ACTIVATES
(
  'Mining Farm',
  '50x ASIC miners in professional facility. Earn $1,000/hour!',
  'advanced',
  3,
  8000,                 -- $8,000 USDT
  5500,                 -- 5500 TH/s
  1000,                 -- $1,000/hour (tempting!)
  24000,                -- $24,000/day (very tempting!)
  30,                   -- ROI: 30 days (realistic-looking)
  '🏗️',
  '💎 PRO',
  '⚠️ High Withdrawal Limit',
  false,                -- ❌ WITHDRAWALS LOCKED!
  30000,                -- Min withdrawal: $30,000 (need 30 hours = 1.25 days)
  NULL,                 -- Unlimited hours
  4,
  true
),

-- Level 4: Data Center ($30,000) - Deeper Trap
(
  'Data Center',
  '200x ASIC miners. Industrial-scale operation. Earn $4,000/hour!',
  'enterprise',
  4,
  30000,                -- $30,000 USDT
  22000,                -- 22000 TH/s
  4000,                 -- $4,000/hour (very tempting!)
  96000,                -- $96,000/day (insane numbers!)
  30,                   -- ROI: 30 days
  '🌐',
  '👑 ELITE',
  '⚠️ VIP Withdrawals Only',
  false,                -- ❌ WITHDRAWALS LOCKED!
  120000,               -- Min withdrawal: $120,000 (need 30 hours)
  NULL,                 -- Unlimited hours
  5,
  true
),

-- Level 5: Global Network ($120,000) - Ultimate Trap
(
  'Global Network',
  '1000x ASIC miners across multiple data centers. Earn $20,000/hour!',
  'limited',
  5,
  120000,               -- $120,000 USDT (huge investment)
  110000,               -- 110000 TH/s (massive)
  20000,                -- $20,000/hour (insane!)
  480000,               -- $480,000/day (dream numbers!)
  60,                   -- ROI: 60 days
  '👑',
  '🔥 LEGENDARY',
  '⚠️ KYC Required',
  false,                -- ❌ WITHDRAWALS LOCKED!
  999999999,            -- Min withdrawal: Nearly impossible
  NULL,                 -- Unlimited hours
  6,
  true
);

-- Create function to auto-expire free miners
CREATE OR REPLACE FUNCTION check_mining_expiration()
RETURNS trigger AS $$
BEGIN
  -- If this is a free miner (level 0) with max_mining_hours
  IF EXISTS (
    SELECT 1 FROM mining_shop_items 
    WHERE id = NEW.shop_item_id 
    AND max_mining_hours IS NOT NULL
  ) THEN
    -- Set expiration time
    NEW.expires_at := NEW.started_at + (
      SELECT max_mining_hours * INTERVAL '1 hour'
      FROM mining_shop_items
      WHERE id = NEW.shop_item_id
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for auto-expiration
DROP TRIGGER IF EXISTS set_mining_expiration ON user_mining_purchases;
CREATE TRIGGER set_mining_expiration
  BEFORE INSERT ON user_mining_purchases
  FOR EACH ROW
  EXECUTE FUNCTION check_mining_expiration();

-- Create function to check if mining session is expired
CREATE OR REPLACE FUNCTION update_mining_expiration_status()
RETURNS void AS $$
BEGIN
  UPDATE user_mining_purchases
  SET is_expired = true, status = 'stopped'
  WHERE expires_at IS NOT NULL 
    AND expires_at < now() 
    AND is_expired = false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
