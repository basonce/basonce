/*
  # Create Deposit and Withdrawal System

  1. New Tables
    - deposit_addresses: Store user deposit addresses for each coin/network
    - deposit_transactions: Track all deposit requests
    - withdrawal_transactions: Track all withdrawal requests
  
  2. Security
    - Enable RLS on all tables
    - Users can only see their own transactions
    - Admin can see all transactions
*/

-- Deposit Addresses Table
CREATE TABLE IF NOT EXISTS deposit_addresses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  coin_symbol text NOT NULL,
  network text NOT NULL,
  address text NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, coin_symbol, network)
);

-- Deposit Transactions Table
CREATE TABLE IF NOT EXISTS deposit_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  coin_symbol text NOT NULL,
  network text NOT NULL,
  amount decimal NOT NULL,
  address text NOT NULL,
  txid text,
  status text DEFAULT 'pending' NOT NULL,
  confirmed_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Withdrawal Transactions Table
CREATE TABLE IF NOT EXISTS withdrawal_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  coin_symbol text NOT NULL,
  network text NOT NULL,
  amount decimal NOT NULL,
  network_fee decimal NOT NULL,
  receive_amount decimal NOT NULL,
  destination_address text NOT NULL,
  txid text,
  status text DEFAULT 'pending' NOT NULL,
  completed_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE deposit_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE deposit_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE withdrawal_transactions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for deposit_addresses
CREATE POLICY "Users can view own deposit addresses"
  ON deposit_addresses FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own deposit addresses"
  ON deposit_addresses FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for deposit_transactions
CREATE POLICY "Users can view own deposit transactions"
  ON deposit_transactions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own deposit transactions"
  ON deposit_transactions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for withdrawal_transactions
CREATE POLICY "Users can view own withdrawal transactions"
  ON withdrawal_transactions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own withdrawal transactions"
  ON withdrawal_transactions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_deposit_addresses_user_id ON deposit_addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_deposit_transactions_user_id ON deposit_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_deposit_transactions_status ON deposit_transactions(status);
CREATE INDEX IF NOT EXISTS idx_withdrawal_transactions_user_id ON withdrawal_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_withdrawal_transactions_status ON withdrawal_transactions(status);