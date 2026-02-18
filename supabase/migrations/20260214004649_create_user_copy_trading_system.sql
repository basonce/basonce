/*
  # Create User Copy Trading System

  1. New Tables
    - `user_copy_trades` - Tracks which users are copying which traders
      - `id` (uuid, primary key)
      - `user_id` (uuid) - The user who is copying
      - `trader_id` (uuid) - The copy_trader being copied
      - `investment_amount` (numeric) - USDT invested
      - `current_value` (numeric) - Current value of the copy
      - `pnl` (numeric) - Profit/loss so far
      - `roi` (numeric) - Return on investment percentage
      - `status` (text) - active, stopped, liquidated
      - `stop_loss_pct` (numeric) - Stop loss percentage
      - `take_profit_pct` (numeric) - Take profit percentage
      - `created_at` (timestamptz)
      - `stopped_at` (timestamptz)

    - `copy_trade_positions` - Individual positions opened by copy traders
      - `id` (uuid, primary key)
      - `copy_trade_id` (uuid) - References user_copy_trades
      - `user_id` (uuid) - The user
      - `coin_symbol` (text) - The coin traded
      - `side` (text) - buy or sell
      - `entry_price` (numeric) - Price at entry
      - `quantity` (numeric) - Amount of coin
      - `current_price` (numeric) - Latest price
      - `pnl` (numeric) - Position PnL
      - `status` (text) - open, closed
      - `opened_at` (timestamptz)
      - `closed_at` (timestamptz)

  2. Security
    - Enable RLS on both tables
    - Users can only see/manage their own copy trades
*/

CREATE TABLE IF NOT EXISTS user_copy_trades (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id),
  trader_id uuid NOT NULL REFERENCES copy_traders(id),
  investment_amount numeric NOT NULL DEFAULT 0,
  current_value numeric NOT NULL DEFAULT 0,
  pnl numeric NOT NULL DEFAULT 0,
  roi numeric NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'active',
  stop_loss_pct numeric DEFAULT NULL,
  take_profit_pct numeric DEFAULT NULL,
  copy_ratio numeric NOT NULL DEFAULT 1.0,
  created_at timestamptz NOT NULL DEFAULT now(),
  stopped_at timestamptz DEFAULT NULL
);

ALTER TABLE user_copy_trades ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own copy trades"
  ON user_copy_trades FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own copy trades"
  ON user_copy_trades FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own copy trades"
  ON user_copy_trades FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS copy_trade_positions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  copy_trade_id uuid NOT NULL REFERENCES user_copy_trades(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id),
  coin_symbol text NOT NULL,
  side text NOT NULL DEFAULT 'buy',
  entry_price numeric NOT NULL DEFAULT 0,
  quantity numeric NOT NULL DEFAULT 0,
  investment numeric NOT NULL DEFAULT 0,
  current_price numeric NOT NULL DEFAULT 0,
  pnl numeric NOT NULL DEFAULT 0,
  roi_pct numeric NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'open',
  opened_at timestamptz NOT NULL DEFAULT now(),
  closed_at timestamptz DEFAULT NULL
);

ALTER TABLE copy_trade_positions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own copy positions"
  ON copy_trade_positions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own copy positions"
  ON copy_trade_positions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own copy positions"
  ON copy_trade_positions FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION start_copy_trading(
  p_user_id uuid,
  p_trader_id uuid,
  p_investment numeric,
  p_stop_loss numeric DEFAULT NULL,
  p_take_profit numeric DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_copy_id uuid;
  v_trader copy_traders%ROWTYPE;
  v_balance numeric;
  v_position_amount numeric;
  v_num_positions int;
BEGIN
  SELECT * INTO v_trader FROM copy_traders WHERE id = p_trader_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Trader not found';
  END IF;

  SELECT usdt_balance INTO v_balance FROM user_balances WHERE user_id = p_user_id;
  IF v_balance IS NULL OR v_balance < p_investment THEN
    RAISE EXCEPTION 'Insufficient balance';
  END IF;

  UPDATE user_balances SET usdt_balance = usdt_balance - p_investment WHERE user_id = p_user_id;

  INSERT INTO user_copy_trades (user_id, trader_id, investment_amount, current_value, status, stop_loss_pct, take_profit_pct)
  VALUES (p_user_id, p_trader_id, p_investment, p_investment, 'active', p_stop_loss, p_take_profit)
  RETURNING id INTO v_copy_id;

  v_num_positions := 2 + floor(random() * 3)::int;
  
  FOR i IN 1..v_num_positions LOOP
    v_position_amount := p_investment / v_num_positions;
    
    INSERT INTO copy_trade_positions (
      copy_trade_id, user_id, coin_symbol, side, entry_price, 
      quantity, investment, current_price, status
    ) VALUES (
      v_copy_id, p_user_id, v_trader.coin_symbol, 'buy',
      0, 0, v_position_amount, 0, 'open'
    );
  END LOOP;

  UPDATE copy_traders 
  SET follower_count = follower_count + 1 
  WHERE id = p_trader_id;

  RETURN v_copy_id;
END;
$$;

CREATE OR REPLACE FUNCTION stop_copy_trading(
  p_user_id uuid,
  p_copy_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_copy user_copy_trades%ROWTYPE;
  v_return_amount numeric;
BEGIN
  SELECT * INTO v_copy FROM user_copy_trades WHERE id = p_copy_id AND user_id = p_user_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Copy trade not found';
  END IF;

  v_return_amount := GREATEST(v_copy.current_value, 0);

  UPDATE user_copy_trades 
  SET status = 'stopped', stopped_at = now() 
  WHERE id = p_copy_id;

  UPDATE copy_trade_positions 
  SET status = 'closed', closed_at = now() 
  WHERE copy_trade_id = p_copy_id AND status = 'open';

  UPDATE user_balances 
  SET usdt_balance = usdt_balance + v_return_amount 
  WHERE user_id = p_user_id;

  UPDATE copy_traders 
  SET follower_count = GREATEST(follower_count - 1, 0) 
  WHERE id = v_copy.trader_id;
END;
$$;
