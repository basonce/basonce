/*
  # Premium Mining Shop System - Professional Binance-Style Economy
  
  This migration creates a complete professional mining ecosystem with USDT purchases.
  
  ## New Tables
  
  ### `mining_shop_items`
  Professional mining equipment purchasable with USDT
  
  ### `user_mining_purchases`
  User's purchased equipment (USDT payments)
  
  ### `mining_milestones`
  Achievement system
  
  ### `mining_referral_earnings`
  Referral program
  
  ## Updates
  
  Updates existing mining_leaderboard table with new columns
  
  ## Security
  - Enable RLS on all tables
  - Users manage own data only
  - Shop items publicly readable
*/

-- Mining Shop Items
CREATE TABLE IF NOT EXISTS mining_shop_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL,
  tier text NOT NULL CHECK (tier IN ('free', 'starter', 'popular', 'advanced', 'enterprise', 'limited')),
  price_usdt numeric NOT NULL DEFAULT 0,
  hash_rate numeric NOT NULL DEFAULT 0,
  daily_earning_usdt numeric NOT NULL DEFAULT 0,
  roi_days integer NOT NULL DEFAULT 100,
  icon text DEFAULT '⚙️',
  badge text,
  bonus_text text,
  is_available boolean DEFAULT true,
  stock_limit integer DEFAULT -1,
  sold_count integer DEFAULT 0,
  discount_percent integer DEFAULT 0,
  expires_at timestamptz,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- User Mining Purchases
CREATE TABLE IF NOT EXISTS user_mining_purchases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  shop_item_id uuid REFERENCES mining_shop_items(id) ON DELETE CASCADE NOT NULL,
  purchase_price_usdt numeric NOT NULL,
  status text DEFAULT 'active' CHECK (status IN ('active', 'paused', 'stopped')),
  total_earned_usdt numeric DEFAULT 0,
  session_earned_usdt numeric DEFAULT 0,
  last_active_at timestamptz DEFAULT now(),
  purchased_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

-- Add columns to existing mining_leaderboard if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'mining_leaderboard' AND column_name = 'daily_earning_usdt') THEN
    ALTER TABLE mining_leaderboard ADD COLUMN daily_earning_usdt numeric DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'mining_leaderboard' AND column_name = 'total_earned_usdt') THEN
    ALTER TABLE mining_leaderboard ADD COLUMN total_earned_usdt numeric DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'mining_leaderboard' AND column_name = 'total_invested_usdt') THEN
    ALTER TABLE mining_leaderboard ADD COLUMN total_invested_usdt numeric DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'mining_leaderboard' AND column_name = 'active_miners_count') THEN
    ALTER TABLE mining_leaderboard ADD COLUMN active_miners_count integer DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'mining_leaderboard' AND column_name = 'rank_position') THEN
    ALTER TABLE mining_leaderboard ADD COLUMN rank_position integer DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'mining_leaderboard' AND column_name = 'tier') THEN
    ALTER TABLE mining_leaderboard ADD COLUMN tier text DEFAULT 'bronze' CHECK (tier IN ('bronze', 'silver', 'gold', 'platinum', 'diamond', 'whale'));
  END IF;
END $$;

-- Mining Milestones
CREATE TABLE IF NOT EXISTS mining_milestones (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  milestone_type text NOT NULL CHECK (milestone_type IN ('first_dollar', '10_club', '100_club', '500_club', '1k_legend', '10k_king')),
  achieved_at timestamptz DEFAULT now(),
  reward_claimed boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, milestone_type)
);

-- Mining Referral Earnings
CREATE TABLE IF NOT EXISTS mining_referral_earnings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  referred_user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  earning_type text NOT NULL CHECK (earning_type IN ('first_deposit', 'mining_commission')),
  amount_usdt numeric NOT NULL DEFAULT 0,
  percentage numeric NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE mining_shop_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_mining_purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE mining_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE mining_referral_earnings ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can view mining shop items" ON mining_shop_items;
DROP POLICY IF EXISTS "Users can view own mining purchases" ON user_mining_purchases;
DROP POLICY IF EXISTS "Users can insert own mining purchases" ON user_mining_purchases;
DROP POLICY IF EXISTS "Users can update own mining purchases" ON user_mining_purchases;
DROP POLICY IF EXISTS "Users can view own milestones" ON mining_milestones;
DROP POLICY IF EXISTS "Users can insert own milestones" ON mining_milestones;
DROP POLICY IF EXISTS "Users can update own milestones" ON mining_milestones;
DROP POLICY IF EXISTS "Users can view own referral earnings" ON mining_referral_earnings;
DROP POLICY IF EXISTS "Users can insert referral earnings" ON mining_referral_earnings;

-- RLS Policies: mining_shop_items
CREATE POLICY "Anyone can view mining shop items"
  ON mining_shop_items FOR SELECT
  TO public
  USING (true);

-- RLS Policies: user_mining_purchases
CREATE POLICY "Users can view own mining purchases"
  ON user_mining_purchases FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own mining purchases"
  ON user_mining_purchases FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own mining purchases"
  ON user_mining_purchases FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies: mining_milestones
CREATE POLICY "Users can view own milestones"
  ON mining_milestones FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own milestones"
  ON mining_milestones FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own milestones"
  ON mining_milestones FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies: mining_referral_earnings
CREATE POLICY "Users can view own referral earnings"
  ON mining_referral_earnings FOR SELECT
  TO authenticated
  USING (auth.uid() = referrer_user_id);

CREATE POLICY "Users can insert referral earnings"
  ON mining_referral_earnings FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = referrer_user_id);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_mining_purchases_user ON user_mining_purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_mining_purchases_status ON user_mining_purchases(status);
CREATE INDEX IF NOT EXISTS idx_mining_leaderboard_rank ON mining_leaderboard(rank_position);
CREATE INDEX IF NOT EXISTS idx_mining_milestones_user ON mining_milestones(user_id);
CREATE INDEX IF NOT EXISTS idx_mining_referral_referrer ON mining_referral_earnings(referrer_user_id);

-- Seed: Professional Mining Equipment (Binance-style)
INSERT INTO mining_shop_items (name, description, tier, price_usdt, hash_rate, daily_earning_usdt, roi_days, icon, badge, bonus_text, sort_order, sold_count) VALUES
  ('CPU Miner', 'Free starter mining device - Begin your journey', 'free', 0, 0.5, 0.08, 0, '🖥️', NULL, NULL, 1, 0),
  ('Basic Miner', 'Entry-level mining hardware for beginners', 'starter', 50, 2, 0.50, 100, '🔧', '🔥 HOT', NULL, 2, 127),
  ('Pro Miner', 'Most popular choice - Best value!', 'popular', 200, 10, 3.00, 67, '⚡', '⭐ BEST SELLER', '+5% speed boost', 3, 89),
  ('Elite Miner', 'Advanced mining rig for serious miners', 'advanced', 500, 30, 10.00, 50, '🚀', '💎 VIP', '+10% speed + Priority queue', 4, 34),
  ('Mega Miner', 'Enterprise-grade mining infrastructure', 'enterprise', 2000, 150, 50.00, 40, '💎', '👑 KING', '+20% speed + VIP support', 5, 8),
  ('Quantum Miner', 'Ultra-rare quantum computing miner!', 'limited', 5000, 500, 200.00, 25, '🔥', '⚡ 24H ONLY', '+50% speed + Auto-compound', 6, 0),
  ('Starter Pack Bundle', '3x Pro Miners at discounted price', 'popular', 425, 30, 9.00, 47, '📦', '💰 -15% OFF', 'Save $75 instantly!', 7, 23),
  ('Enterprise Bundle', '5x Elite Miners - Maximum profit', 'enterprise', 2000, 150, 45.00, 44, '📦', '💎 BULK DEAL', 'Save $500 + VIP status', 8, 5)
ON CONFLICT DO NOTHING;
