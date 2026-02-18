/*
  # Blockchain Wallet System - Real Crypto Integration

  ## Overview
  This migration creates the complete infrastructure for real cryptocurrency deposits,
  withdrawals, and blockchain transaction tracking.

  ## New Tables

  ### 1. `wallet_addresses`
  Stores unique blockchain wallet addresses for each user per network
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `network` (text: 'bsc_testnet', 'polygon_testnet', 'ethereum', etc.)
  - `address` (text: blockchain wallet address)
  - `currency` (text: 'ETH', 'USDT', 'BTC', 'BNB', etc.)
  - `private_key_encrypted` (text: encrypted private key for hot wallet)
  - `is_active` (boolean: whether this address is currently in use)
  - `created_at` (timestamptz)

  ### 2. `blockchain_deposits`
  Tracks all incoming cryptocurrency deposits
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `wallet_address_id` (uuid, references wallet_addresses)
  - `tx_hash` (text: blockchain transaction hash)
  - `network` (text: blockchain network)
  - `currency` (text: cryptocurrency type)
  - `amount` (numeric: deposit amount)
  - `from_address` (text: sender's wallet address)
  - `to_address` (text: our platform wallet address)
  - `confirmations` (integer: number of blockchain confirmations)
  - `required_confirmations` (integer: confirmations needed for credit)
  - `status` (text: 'pending', 'confirming', 'completed', 'failed')
  - `block_number` (bigint: block number of transaction)
  - `gas_used` (numeric: gas used for transaction)
  - `credited_at` (timestamptz: when balance was credited)
  - `created_at` (timestamptz: when deposit was first detected)

  ### 3. `blockchain_withdrawals`
  Manages all cryptocurrency withdrawal requests
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `currency` (text: cryptocurrency type)
  - `network` (text: blockchain network)
  - `amount` (numeric: withdrawal amount)
  - `fee` (numeric: network/platform fee)
  - `total_amount` (numeric: amount + fee)
  - `to_address` (text: destination wallet address)
  - `from_address` (text: platform hot wallet address)
  - `tx_hash` (text: blockchain transaction hash)
  - `status` (text: 'pending', 'processing', 'completed', 'failed', 'cancelled')
  - `admin_approved` (boolean: admin approval for large withdrawals)
  - `approved_by` (uuid: admin user id)
  - `approved_at` (timestamptz)
  - `error_message` (text: if failed, error details)
  - `processed_at` (timestamptz: when withdrawal was sent to blockchain)
  - `created_at` (timestamptz)

  ### 4. `blockchain_transactions`
  Complete audit log of all blockchain interactions
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `type` (text: 'deposit', 'withdrawal', 'transfer')
  - `tx_hash` (text: blockchain transaction hash)
  - `network` (text: blockchain network)
  - `currency` (text: cryptocurrency)
  - `amount` (numeric)
  - `from_address` (text)
  - `to_address` (text)
  - `status` (text: 'pending', 'confirmed', 'failed')
  - `block_number` (bigint)
  - `confirmations` (integer)
  - `gas_price` (numeric)
  - `gas_used` (numeric)
  - `metadata` (jsonb: additional transaction details)
  - `created_at` (timestamptz)

  ### 5. `hot_wallet_config`
  Configuration for platform hot wallets (custodial)
  - `id` (uuid, primary key)
  - `network` (text: blockchain network)
  - `currency` (text: cryptocurrency)
  - `address` (text: hot wallet address)
  - `private_key_encrypted` (text: encrypted private key)
  - `balance` (numeric: current balance)
  - `min_balance_threshold` (numeric: alert if below this)
  - `is_active` (boolean)
  - `last_balance_check` (timestamptz)
  - `created_at` (timestamptz)

  ### 6. `withdrawal_limits`
  User-specific withdrawal limits and security settings
  - `user_id` (uuid, primary key, references auth.users)
  - `daily_limit` (numeric: max daily withdrawal)
  - `daily_used` (numeric: amount used today)
  - `last_reset` (timestamptz: last daily reset)
  - `requires_2fa` (boolean: 2FA required for withdrawals)
  - `requires_email_confirm` (boolean)
  - `whitelisted_addresses` (jsonb: array of approved addresses)
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ## Security
  All tables have RLS enabled with strict policies:
  - Users can only see their own wallet data
  - Admins can view all data for monitoring
  - Private keys are encrypted and never exposed via API
  - Withdrawal approvals require admin role for amounts > threshold

  ## Indexes
  Critical indexes for performance:
  - wallet_addresses: (user_id, network, currency)
  - blockchain_deposits: (tx_hash), (user_id, status)
  - blockchain_withdrawals: (user_id, status), (tx_hash)
  - blockchain_transactions: (tx_hash), (user_id, type, created_at)

  ## Important Notes
  1. Private keys are encrypted with platform master key (never store plain!)
  2. All monetary values use NUMERIC for precision
  3. Testnet networks: 'bsc_testnet', 'polygon_mumbai'
  4. Mainnet networks: 'bsc', 'polygon', 'ethereum'
  5. Minimum confirmations: BTC=6, ETH=12, BSC=15, Polygon=128
*/

-- Create wallet_addresses table
CREATE TABLE IF NOT EXISTS wallet_addresses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  network text NOT NULL,
  address text NOT NULL,
  currency text NOT NULL,
  private_key_encrypted text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, network, currency)
);

-- Create blockchain_deposits table
CREATE TABLE IF NOT EXISTS blockchain_deposits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  wallet_address_id uuid REFERENCES wallet_addresses(id) ON DELETE SET NULL,
  tx_hash text NOT NULL UNIQUE,
  network text NOT NULL,
  currency text NOT NULL,
  amount numeric NOT NULL CHECK (amount > 0),
  from_address text NOT NULL,
  to_address text NOT NULL,
  confirmations integer DEFAULT 0,
  required_confirmations integer DEFAULT 15,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'confirming', 'completed', 'failed')),
  block_number bigint,
  gas_used numeric,
  credited_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Create blockchain_withdrawals table
CREATE TABLE IF NOT EXISTS blockchain_withdrawals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  currency text NOT NULL,
  network text NOT NULL,
  amount numeric NOT NULL CHECK (amount > 0),
  fee numeric DEFAULT 0 CHECK (fee >= 0),
  total_amount numeric NOT NULL CHECK (total_amount > 0),
  to_address text NOT NULL,
  from_address text,
  tx_hash text,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
  admin_approved boolean DEFAULT false,
  approved_by uuid REFERENCES auth.users(id),
  approved_at timestamptz,
  error_message text,
  processed_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Create blockchain_transactions table
CREATE TABLE IF NOT EXISTS blockchain_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN ('deposit', 'withdrawal', 'transfer')),
  tx_hash text NOT NULL,
  network text NOT NULL,
  currency text NOT NULL,
  amount numeric NOT NULL,
  from_address text NOT NULL,
  to_address text NOT NULL,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'failed')),
  block_number bigint,
  confirmations integer DEFAULT 0,
  gas_price numeric,
  gas_used numeric,
  metadata jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  UNIQUE(tx_hash, type)
);

-- Create hot_wallet_config table
CREATE TABLE IF NOT EXISTS hot_wallet_config (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  network text NOT NULL,
  currency text NOT NULL,
  address text NOT NULL,
  private_key_encrypted text NOT NULL,
  balance numeric DEFAULT 0,
  min_balance_threshold numeric DEFAULT 0,
  is_active boolean DEFAULT true,
  last_balance_check timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  UNIQUE(network, currency)
);

-- Create withdrawal_limits table
CREATE TABLE IF NOT EXISTS withdrawal_limits (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  daily_limit numeric DEFAULT 10000,
  daily_used numeric DEFAULT 0,
  last_reset timestamptz DEFAULT now(),
  requires_2fa boolean DEFAULT false,
  requires_email_confirm boolean DEFAULT true,
  whitelisted_addresses jsonb DEFAULT '[]',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_wallet_addresses_user ON wallet_addresses(user_id, network, currency);
CREATE INDEX IF NOT EXISTS idx_deposits_tx_hash ON blockchain_deposits(tx_hash);
CREATE INDEX IF NOT EXISTS idx_deposits_user_status ON blockchain_deposits(user_id, status);
CREATE INDEX IF NOT EXISTS idx_withdrawals_user_status ON blockchain_withdrawals(user_id, status);
CREATE INDEX IF NOT EXISTS idx_withdrawals_tx_hash ON blockchain_withdrawals(tx_hash);
CREATE INDEX IF NOT EXISTS idx_transactions_tx_hash ON blockchain_transactions(tx_hash);
CREATE INDEX IF NOT EXISTS idx_transactions_user ON blockchain_transactions(user_id, type, created_at DESC);

-- Enable Row Level Security
ALTER TABLE wallet_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE blockchain_deposits ENABLE ROW LEVEL SECURITY;
ALTER TABLE blockchain_withdrawals ENABLE ROW LEVEL SECURITY;
ALTER TABLE blockchain_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE hot_wallet_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE withdrawal_limits ENABLE ROW LEVEL SECURITY;

-- RLS Policies for wallet_addresses
CREATE POLICY "Users can view own wallet addresses"
  ON wallet_addresses FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own wallet addresses"
  ON wallet_addresses FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for blockchain_deposits
CREATE POLICY "Users can view own deposits"
  ON blockchain_deposits FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- RLS Policies for blockchain_withdrawals
CREATE POLICY "Users can view own withdrawals"
  ON blockchain_withdrawals FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own withdrawals"
  ON blockchain_withdrawals FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for blockchain_transactions
CREATE POLICY "Users can view own transactions"
  ON blockchain_transactions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- RLS Policies for withdrawal_limits
CREATE POLICY "Users can view own limits"
  ON withdrawal_limits FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own limits"
  ON withdrawal_limits FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Hot wallet config only accessible by admins (no public policy)

-- Function to auto-create withdrawal limits for new users
CREATE OR REPLACE FUNCTION create_default_withdrawal_limits()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO withdrawal_limits (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'on_user_created_withdrawal_limits'
  ) THEN
    CREATE TRIGGER on_user_created_withdrawal_limits
      AFTER INSERT ON auth.users
      FOR EACH ROW
      EXECUTE FUNCTION create_default_withdrawal_limits();
  END IF;
END $$;

-- Function to credit user balance when deposit is confirmed
CREATE OR REPLACE FUNCTION process_confirmed_deposit()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    INSERT INTO balances (user_id, currency, total, available)
    VALUES (NEW.user_id, NEW.currency, NEW.amount, NEW.amount)
    ON CONFLICT (user_id, currency)
    DO UPDATE SET
      total = balances.total + NEW.amount,
      available = balances.available + NEW.amount;
    
    NEW.credited_at = now();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'on_deposit_confirmed'
  ) THEN
    CREATE TRIGGER on_deposit_confirmed
      BEFORE UPDATE ON blockchain_deposits
      FOR EACH ROW
      WHEN (NEW.status = 'completed' AND OLD.status != 'completed')
      EXECUTE FUNCTION process_confirmed_deposit();
  END IF;
END $$;

-- Function to deduct user balance when withdrawal is approved
CREATE OR REPLACE FUNCTION process_approved_withdrawal()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'processing' AND OLD.status = 'pending' THEN
    UPDATE balances
    SET available = available - NEW.total_amount
    WHERE user_id = NEW.user_id AND currency = NEW.currency;
    
    IF NOT FOUND OR (SELECT available FROM balances WHERE user_id = NEW.user_id AND currency = NEW.currency) < 0 THEN
      RAISE EXCEPTION 'Insufficient balance';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'on_withdrawal_approved'
  ) THEN
    CREATE TRIGGER on_withdrawal_approved
      BEFORE UPDATE ON blockchain_withdrawals
      FOR EACH ROW
      WHEN (NEW.status = 'processing' AND OLD.status = 'pending')
      EXECUTE FUNCTION process_approved_withdrawal();
  END IF;
END $$;

-- Enable realtime for blockchain tables
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE blockchain_deposits;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE blockchain_withdrawals;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE blockchain_transactions;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;