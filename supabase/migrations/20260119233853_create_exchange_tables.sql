/*
  # Basonce Cryptocurrency Exchange Database Schema

  ## Overview
  This migration creates the core database structure for a cryptocurrency exchange platform
  similar to Basonce, with support for multiple cryptocurrencies, user wallets, trading,
  and order management.

  ## New Tables

  ### 1. profiles
  User profile information linked to auth.users
  - `id` (uuid, primary key) - Links to auth.users.id
  - `username` (text, unique) - Unique username
  - `full_name` (text) - User's full name
  - `avatar_url` (text) - Profile picture URL
  - `created_at` (timestamptz) - Account creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### 2. cryptocurrencies
  Available cryptocurrencies on the platform
  - `id` (uuid, primary key) - Unique identifier
  - `symbol` (text, unique) - Currency symbol (BTC, ETH, USDT, etc.)
  - `name` (text) - Full name of cryptocurrency
  - `icon_url` (text) - Icon/logo URL
  - `current_price` (decimal) - Current price in USD
  - `price_change_24h` (decimal) - 24h price change percentage
  - `market_cap` (decimal) - Market capitalization
  - `volume_24h` (decimal) - 24h trading volume
  - `is_active` (boolean) - Whether trading is enabled
  - `created_at` (timestamptz) - When added to platform

  ### 3. wallets
  User wallet balances for each cryptocurrency
  - `id` (uuid, primary key) - Unique identifier
  - `user_id` (uuid) - Foreign key to auth.users
  - `currency_id` (uuid) - Foreign key to cryptocurrencies
  - `balance` (decimal) - Available balance
  - `locked_balance` (decimal) - Balance locked in orders
  - `created_at` (timestamptz) - Wallet creation time
  - `updated_at` (timestamptz) - Last update time

  ### 4. orders
  Buy and sell orders placed by users
  - `id` (uuid, primary key) - Unique identifier
  - `user_id` (uuid) - Foreign key to auth.users
  - `currency_id` (uuid) - Foreign key to cryptocurrencies
  - `order_type` (text) - 'buy' or 'sell'
  - `price` (decimal) - Order price per unit
  - `amount` (decimal) - Amount of cryptocurrency
  - `filled_amount` (decimal) - Amount already filled
  - `status` (text) - 'pending', 'partial', 'filled', 'cancelled'
  - `created_at` (timestamptz) - Order creation time
  - `updated_at` (timestamptz) - Last update time

  ### 5. trades
  Completed trade transactions
  - `id` (uuid, primary key) - Unique identifier
  - `buyer_id` (uuid) - Foreign key to auth.users (buyer)
  - `seller_id` (uuid) - Foreign key to auth.users (seller)
  - `currency_id` (uuid) - Foreign key to cryptocurrencies
  - `buy_order_id` (uuid) - Foreign key to orders
  - `sell_order_id` (uuid) - Foreign key to orders
  - `price` (decimal) - Trade execution price
  - `amount` (decimal) - Trade amount
  - `total` (decimal) - Total transaction value
  - `created_at` (timestamptz) - Trade execution time

  ## Security
  - Row Level Security (RLS) enabled on all tables
  - Users can only view and modify their own data
  - Public read access for cryptocurrencies table
  - Authenticated users can view completed trades

  ## Notes
  - All monetary values use DECIMAL type for precision
  - Timestamps use timestamptz for timezone awareness
  - Proper indexes added for query performance
  - Foreign key constraints ensure data integrity
*/

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username text UNIQUE NOT NULL,
  full_name text,
  avatar_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create cryptocurrencies table
CREATE TABLE IF NOT EXISTS cryptocurrencies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  symbol text UNIQUE NOT NULL,
  name text NOT NULL,
  icon_url text,
  current_price decimal(20, 8) DEFAULT 0,
  price_change_24h decimal(10, 2) DEFAULT 0,
  market_cap decimal(20, 2) DEFAULT 0,
  volume_24h decimal(20, 2) DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Create wallets table
CREATE TABLE IF NOT EXISTS wallets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  currency_id uuid REFERENCES cryptocurrencies(id) ON DELETE CASCADE NOT NULL,
  balance decimal(20, 8) DEFAULT 0,
  locked_balance decimal(20, 8) DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, currency_id)
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  currency_id uuid REFERENCES cryptocurrencies(id) ON DELETE CASCADE NOT NULL,
  order_type text NOT NULL CHECK (order_type IN ('buy', 'sell')),
  price decimal(20, 8) NOT NULL,
  amount decimal(20, 8) NOT NULL,
  filled_amount decimal(20, 8) DEFAULT 0,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'partial', 'filled', 'cancelled')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create trades table
CREATE TABLE IF NOT EXISTS trades (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  buyer_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  seller_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  currency_id uuid REFERENCES cryptocurrencies(id) ON DELETE CASCADE NOT NULL,
  buy_order_id uuid REFERENCES orders(id) ON DELETE SET NULL,
  sell_order_id uuid REFERENCES orders(id) ON DELETE SET NULL,
  price decimal(20, 8) NOT NULL,
  amount decimal(20, 8) NOT NULL,
  total decimal(20, 8) NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON wallets(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_currency_id ON orders(currency_id);
CREATE INDEX IF NOT EXISTS idx_trades_buyer_id ON trades(buyer_id);
CREATE INDEX IF NOT EXISTS idx_trades_seller_id ON trades(seller_id);
CREATE INDEX IF NOT EXISTS idx_trades_currency_id ON trades(currency_id);
CREATE INDEX IF NOT EXISTS idx_trades_created_at ON trades(created_at DESC);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE cryptocurrencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE trades ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Cryptocurrencies policies (public read, admin write)
CREATE POLICY "Anyone can view active cryptocurrencies"
  ON cryptocurrencies FOR SELECT
  TO authenticated
  USING (is_active = true);

-- Wallets policies
CREATE POLICY "Users can view own wallets"
  ON wallets FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own wallets"
  ON wallets FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can insert own wallets"
  ON wallets FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Orders policies
CREATE POLICY "Users can view own orders"
  ON orders FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own orders"
  ON orders FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own orders"
  ON orders FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Trades policies
CREATE POLICY "Users can view own trades"
  ON trades FOR SELECT
  TO authenticated
  USING (auth.uid() = buyer_id OR auth.uid() = seller_id);

CREATE POLICY "Authenticated users can view all trades"
  ON trades FOR SELECT
  TO authenticated
  USING (true);

-- Insert sample cryptocurrencies
INSERT INTO cryptocurrencies (symbol, name, current_price, price_change_24h, market_cap, volume_24h, is_active)
VALUES 
  ('BTC', 'Bitcoin', 94250.50, 2.45, 1850000000000, 45000000000, true),
  ('ETH', 'Ethereum', 3420.75, -1.23, 410000000000, 18000000000, true),
  ('USDT', 'Tether', 1.00, 0.01, 95000000000, 65000000000, true),
  ('BNB', 'Binance Coin', 615.30, 3.67, 89000000000, 2100000000, true),
  ('SOL', 'Solana', 145.80, 5.42, 68000000000, 3500000000, true),
  ('XRP', 'Ripple', 2.85, -2.15, 162000000000, 8500000000, true),
  ('ADA', 'Cardano', 1.05, 1.89, 37000000000, 1200000000, true),
  ('AVAX', 'Avalanche', 42.15, 4.23, 16500000000, 850000000, true),
  ('DOGE', 'Dogecoin', 0.32, -0.87, 47000000000, 2800000000, true),
  ('DOT', 'Polkadot', 7.65, 2.34, 11200000000, 450000000, true)
ON CONFLICT (symbol) DO NOTHING;