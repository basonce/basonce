/*
  # Crypto Coins and Networks System

  1. New Tables
    - `supported_coins`
      - `id` (uuid, primary key)
      - `symbol` (text) - Coin symbol like USDT, BTC, ETH
      - `name` (text) - Full name like Tether, Bitcoin
      - `icon_url` (text) - URL to coin icon
      - `is_trending` (boolean) - Show in trending section
      - `sort_order` (integer) - Display order
      - `is_active` (boolean) - Enable/disable coin
      - `created_at` (timestamptz)

    - `supported_networks`
      - `id` (uuid, primary key)
      - `coin_id` (uuid) - Reference to supported_coins
      - `network_name` (text) - Network name like BSC, Polygon, Tron
      - `network_code` (text) - Short code like BEP20, TRC20, ERC20
      - `chain_id` (text) - Blockchain chain ID
      - `contract_address` (text) - Token contract address
      - `min_deposit` (decimal) - Minimum deposit amount
      - `min_withdrawal` (decimal) - Minimum withdrawal amount
      - `withdrawal_fee` (decimal) - Network fee for withdrawal
      - `confirmations_required` (integer) - Block confirmations needed
      - `estimated_arrival_minutes` (integer) - Estimated arrival time
      - `is_active` (boolean) - Enable/disable network
      - `is_mainnet` (boolean) - Mainnet or testnet
      - `sort_order` (integer) - Display order
      - `created_at` (timestamptz)

    - `user_coin_history`
      - `id` (uuid, primary key)
      - `user_id` (uuid) - Reference to auth.users
      - `coin_id` (uuid) - Reference to supported_coins
      - `last_used_at` (timestamptz) - Track when user last used this coin
      - `usage_count` (integer) - How many times user used this coin

  2. Security
    - Enable RLS on all tables
    - Admin-only policies for coins and networks management
    - User can read their own coin history
    - User can update their own coin history

  3. Indexes
    - Index on coin symbols for fast search
    - Index on user_id for history queries
*/

-- Create supported_coins table
CREATE TABLE IF NOT EXISTS supported_coins (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  symbol text UNIQUE NOT NULL,
  name text NOT NULL,
  icon_url text,
  is_trending boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Create supported_networks table
CREATE TABLE IF NOT EXISTS supported_networks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  coin_id uuid REFERENCES supported_coins(id) ON DELETE CASCADE,
  network_name text NOT NULL,
  network_code text NOT NULL,
  chain_id text,
  contract_address text,
  min_deposit decimal(20, 8) DEFAULT 0,
  min_withdrawal decimal(20, 8) DEFAULT 0,
  withdrawal_fee decimal(20, 8) DEFAULT 0,
  confirmations_required integer DEFAULT 1,
  estimated_arrival_minutes integer DEFAULT 5,
  is_active boolean DEFAULT true,
  is_mainnet boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  UNIQUE(coin_id, network_code)
);

-- Create user_coin_history table
CREATE TABLE IF NOT EXISTS user_coin_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  coin_id uuid REFERENCES supported_coins(id) ON DELETE CASCADE,
  last_used_at timestamptz DEFAULT now(),
  usage_count integer DEFAULT 1,
  UNIQUE(user_id, coin_id)
);

-- Enable RLS
ALTER TABLE supported_coins ENABLE ROW LEVEL SECURITY;
ALTER TABLE supported_networks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_coin_history ENABLE ROW LEVEL SECURITY;

-- Policies for supported_coins (everyone can read, only admins can modify)
CREATE POLICY "Anyone can view active coins"
  ON supported_coins FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "Admins can manage coins"
  ON supported_coins FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
      AND user_profiles.is_active = true
    )
  );

-- Policies for supported_networks
CREATE POLICY "Anyone can view active networks"
  ON supported_networks FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "Admins can manage networks"
  ON supported_networks FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
      AND user_profiles.is_active = true
    )
  );

-- Policies for user_coin_history
CREATE POLICY "Users can view own coin history"
  ON user_coin_history FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own coin history"
  ON user_coin_history FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own coin history"
  ON user_coin_history FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_coins_symbol ON supported_coins(symbol);
CREATE INDEX IF NOT EXISTS idx_coins_trending ON supported_coins(is_trending) WHERE is_trending = true;
CREATE INDEX IF NOT EXISTS idx_networks_coin_id ON supported_networks(coin_id);
CREATE INDEX IF NOT EXISTS idx_user_coin_history_user_id ON user_coin_history(user_id);

-- Insert popular coins
INSERT INTO supported_coins (symbol, name, icon_url, is_trending, sort_order, is_active) VALUES
  ('USDT', 'Tether', NULL, true, 1, true),
  ('BTC', 'Bitcoin', NULL, true, 2, true),
  ('ETH', 'Ethereum', NULL, true, 3, true),
  ('BNB', 'BNB', NULL, true, 4, true),
  ('TRX', 'Tron', NULL, true, 5, true),
  ('USDC', 'USD Coin', NULL, false, 6, true),
  ('SOL', 'Solana', NULL, false, 7, true),
  ('MATIC', 'Polygon', NULL, false, 8, true)
ON CONFLICT (symbol) DO NOTHING;

-- Insert networks for USDT
INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'BSC',
  'BEP20',
  '56',
  '0x55d398326f99059fF775485246999027B3197955',
  0.01,
  0.01,
  0.8,
  1,
  1,
  true,
  1
FROM supported_coins WHERE symbol = 'USDT'
ON CONFLICT (coin_id, network_code) DO NOTHING;

INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'Tron',
  'TRC20',
  NULL,
  'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t',
  0.01,
  0.01,
  1,
  1,
  1,
  true,
  2
FROM supported_coins WHERE symbol = 'USDT'
ON CONFLICT (coin_id, network_code) DO NOTHING;

INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'Ethereum',
  'ERC20',
  '1',
  '0xdac17f958d2ee523a2206206994597c13d831ec7',
  0.01,
  0.01,
  5,
  12,
  5,
  true,
  3
FROM supported_coins WHERE symbol = 'USDT'
ON CONFLICT (coin_id, network_code) DO NOTHING;

INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'Polygon',
  'Polygon',
  '137',
  '0xc2132D05D31c914a87C6611C10748AEb04B58e8F',
  0.01,
  0.01,
  0.5,
  1,
  2,
  true,
  4
FROM supported_coins WHERE symbol = 'USDT'
ON CONFLICT (coin_id, network_code) DO NOTHING;

-- Insert networks for BTC
INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'Bitcoin',
  'BTC',
  NULL,
  NULL,
  0.0001,
  0.0001,
  0.0003,
  3,
  30,
  true,
  1
FROM supported_coins WHERE symbol = 'BTC'
ON CONFLICT (coin_id, network_code) DO NOTHING;

-- Insert networks for ETH
INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'Ethereum',
  'ERC20',
  '1',
  NULL,
  0.001,
  0.001,
  0.003,
  12,
  5,
  true,
  1
FROM supported_coins WHERE symbol = 'ETH'
ON CONFLICT (coin_id, network_code) DO NOTHING;

-- Insert networks for BNB
INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'BSC',
  'BEP20',
  '56',
  NULL,
  0.001,
  0.001,
  0.0005,
  1,
  1,
  true,
  1
FROM supported_coins WHERE symbol = 'BNB'
ON CONFLICT (coin_id, network_code) DO NOTHING;

-- Insert networks for TRX
INSERT INTO supported_networks (coin_id, network_name, network_code, chain_id, contract_address, min_deposit, min_withdrawal, withdrawal_fee, confirmations_required, estimated_arrival_minutes, is_mainnet, sort_order)
SELECT 
  id,
  'Tron',
  'TRC20',
  NULL,
  NULL,
  1,
  1,
  1,
  1,
  1,
  true,
  1
FROM supported_coins WHERE symbol = 'TRX'
ON CONFLICT (coin_id, network_code) DO NOTHING;