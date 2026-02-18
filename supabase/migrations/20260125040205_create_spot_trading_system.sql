/*
  # Spot Trading System

  ## Overview
  Complete spot trading system for buying and selling cryptocurrencies with real-time balance updates.

  ## New Tables
  
  ### `spot_orders`
  - `id` (uuid, primary key)
  - `user_id` (uuid, foreign key to auth.users)
  - `symbol` (text) - Trading pair symbol (e.g., 'BTC', 'ETH')
  - `side` (text) - 'buy' or 'sell'
  - `type` (text) - 'market' or 'limit'
  - `price` (numeric) - Execution price
  - `quantity` (numeric) - Amount of coin
  - `total` (numeric) - Total in USDT
  - `status` (text) - 'filled', 'cancelled'
  - `created_at` (timestamptz)

  ### `user_trades`
  - `id` (uuid, primary key)
  - `user_id` (uuid, foreign key)
  - `order_id` (uuid, foreign key to spot_orders)
  - `symbol` (text)
  - `side` (text)
  - `price` (numeric)
  - `quantity` (numeric)
  - `total` (numeric)
  - `fee` (numeric)
  - `realized_pnl` (numeric) - Profit/loss for this trade
  - `created_at` (timestamptz)

  ### `user_positions`
  - Tracks average buy price and total quantity for PNL calculation
  - `id` (uuid, primary key)
  - `user_id` (uuid)
  - `symbol` (text)
  - `total_quantity` (numeric)
  - `average_price` (numeric)
  - `total_invested` (numeric)
  - `updated_at` (timestamptz)

  ## Functions
  
  ### `execute_spot_order`
  - Executes buy/sell orders
  - Updates user_balances
  - Creates trade records
  - Calculates PNL
  - Returns order details

  ## Security
  - RLS enabled on all tables
  - Users can only access their own orders and trades
*/

-- Create spot_orders table
CREATE TABLE IF NOT EXISTS spot_orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  symbol text NOT NULL,
  side text NOT NULL CHECK (side IN ('buy', 'sell')),
  type text NOT NULL DEFAULT 'market' CHECK (type IN ('market', 'limit')),
  price numeric(20, 8) NOT NULL,
  quantity numeric(20, 8) NOT NULL,
  total numeric(20, 8) NOT NULL,
  status text NOT NULL DEFAULT 'filled' CHECK (status IN ('filled', 'cancelled', 'pending')),
  created_at timestamptz DEFAULT now()
);

-- Create user_trades table
CREATE TABLE IF NOT EXISTS user_trades (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  order_id uuid REFERENCES spot_orders(id) ON DELETE SET NULL,
  symbol text NOT NULL,
  side text NOT NULL CHECK (side IN ('buy', 'sell')),
  price numeric(20, 8) NOT NULL,
  quantity numeric(20, 8) NOT NULL,
  total numeric(20, 8) NOT NULL,
  fee numeric(20, 8) DEFAULT 0,
  realized_pnl numeric(20, 8) DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Create user_positions table
CREATE TABLE IF NOT EXISTS user_positions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  symbol text NOT NULL,
  total_quantity numeric(20, 8) DEFAULT 0,
  average_price numeric(20, 8) DEFAULT 0,
  total_invested numeric(20, 8) DEFAULT 0,
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, symbol)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_spot_orders_user_id ON spot_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_spot_orders_symbol ON spot_orders(symbol);
CREATE INDEX IF NOT EXISTS idx_spot_orders_created_at ON spot_orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_trades_user_id ON user_trades(user_id);
CREATE INDEX IF NOT EXISTS idx_user_trades_symbol ON user_trades(symbol);
CREATE INDEX IF NOT EXISTS idx_user_trades_created_at ON user_trades(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_positions_user_id ON user_positions(user_id);

-- Enable RLS
ALTER TABLE spot_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_trades ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_positions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for spot_orders
CREATE POLICY "Users can view own orders"
  ON spot_orders FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own orders"
  ON spot_orders FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for user_trades
CREATE POLICY "Users can view own trades"
  ON user_trades FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own trades"
  ON user_trades FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for user_positions
CREATE POLICY "Users can view own positions"
  ON user_positions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own positions"
  ON user_positions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own positions"
  ON user_positions FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Function to execute spot order
CREATE OR REPLACE FUNCTION execute_spot_order(
  p_user_id uuid,
  p_symbol text,
  p_side text,
  p_price numeric,
  p_quantity numeric
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_total numeric;
  v_fee numeric;
  v_usdt_balance numeric;
  v_coin_balance numeric;
  v_order_id uuid;
  v_trade_id uuid;
  v_position record;
  v_realized_pnl numeric := 0;
  v_avg_buy_price numeric := 0;
BEGIN
  -- Calculate total and fee
  v_total := p_price * p_quantity;
  v_fee := v_total * 0.001; -- 0.1% fee
  
  -- Get current balances
  SELECT balance INTO v_usdt_balance
  FROM user_balances
  WHERE user_id = p_user_id AND symbol = 'USDT';
  
  SELECT balance INTO v_coin_balance
  FROM user_balances
  WHERE user_id = p_user_id AND symbol = p_symbol;
  
  -- Set defaults if NULL
  v_usdt_balance := COALESCE(v_usdt_balance, 0);
  v_coin_balance := COALESCE(v_coin_balance, 0);
  
  -- Validate balances
  IF p_side = 'buy' THEN
    IF v_usdt_balance < (v_total + v_fee) THEN
      RAISE EXCEPTION 'Insufficient USDT balance';
    END IF;
  ELSE -- sell
    IF v_coin_balance < p_quantity THEN
      RAISE EXCEPTION 'Insufficient % balance', p_symbol;
    END IF;
  END IF;
  
  -- Get current position for PNL calculation
  SELECT * INTO v_position
  FROM user_positions
  WHERE user_id = p_user_id AND symbol = p_symbol;
  
  -- Calculate realized PNL for sell orders
  IF p_side = 'sell' AND v_position IS NOT NULL THEN
    v_avg_buy_price := v_position.average_price;
    v_realized_pnl := (p_price - v_avg_buy_price) * p_quantity;
  END IF;
  
  -- Create order
  INSERT INTO spot_orders (user_id, symbol, side, price, quantity, total, status)
  VALUES (p_user_id, p_symbol, p_side, p_price, p_quantity, v_total, 'filled')
  RETURNING id INTO v_order_id;
  
  -- Create trade record
  INSERT INTO user_trades (user_id, order_id, symbol, side, price, quantity, total, fee, realized_pnl)
  VALUES (p_user_id, v_order_id, p_symbol, p_side, p_price, p_quantity, v_total, v_fee, v_realized_pnl)
  RETURNING id INTO v_trade_id;
  
  -- Update balances
  IF p_side = 'buy' THEN
    -- Deduct USDT
    UPDATE user_balances
    SET balance = balance - (v_total + v_fee)
    WHERE user_id = p_user_id AND symbol = 'USDT';
    
    -- Add coin
    INSERT INTO user_balances (user_id, symbol, balance)
    VALUES (p_user_id, p_symbol, p_quantity)
    ON CONFLICT (user_id, symbol)
    DO UPDATE SET balance = user_balances.balance + p_quantity;
    
    -- Update position
    INSERT INTO user_positions (user_id, symbol, total_quantity, average_price, total_invested)
    VALUES (
      p_user_id,
      p_symbol,
      p_quantity,
      p_price,
      v_total
    )
    ON CONFLICT (user_id, symbol)
    DO UPDATE SET
      total_quantity = user_positions.total_quantity + p_quantity,
      total_invested = user_positions.total_invested + v_total,
      average_price = (user_positions.total_invested + v_total) / (user_positions.total_quantity + p_quantity),
      updated_at = now();
      
  ELSE -- sell
    -- Deduct coin
    UPDATE user_balances
    SET balance = balance - p_quantity
    WHERE user_id = p_user_id AND symbol = p_symbol;
    
    -- Add USDT (minus fee)
    UPDATE user_balances
    SET balance = balance + (v_total - v_fee)
    WHERE user_id = p_user_id AND symbol = 'USDT';
    
    -- Update position
    UPDATE user_positions
    SET
      total_quantity = total_quantity - p_quantity,
      total_invested = CASE
        WHEN (total_quantity - p_quantity) <= 0 THEN 0
        ELSE total_invested - (average_price * p_quantity)
      END,
      average_price = CASE
        WHEN (total_quantity - p_quantity) <= 0 THEN 0
        ELSE average_price
      END,
      updated_at = now()
    WHERE user_id = p_user_id AND symbol = p_symbol;
  END IF;
  
  -- Create transaction record
  INSERT INTO transactions (user_id, type, symbol, amount, notes)
  VALUES (
    p_user_id,
    p_side,
    p_symbol,
    p_quantity,
    format('%s %s %s at %s USDT', UPPER(p_side), p_quantity, p_symbol, p_price)
  );
  
  -- Return result
  RETURN json_build_object(
    'success', true,
    'order_id', v_order_id,
    'trade_id', v_trade_id,
    'side', p_side,
    'symbol', p_symbol,
    'price', p_price,
    'quantity', p_quantity,
    'total', v_total,
    'fee', v_fee,
    'realized_pnl', v_realized_pnl
  );
END;
$$;