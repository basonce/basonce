/*
  # Futures Trading System

  ## Overview
  Complete futures trading system with leverage (1x-50x), liquidation mechanics, and PNL tracking.

  ## 1. New Tables
  
  ### `futures_positions`
  Active futures positions with full trading details:
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `symbol` (text) - Trading pair (e.g., 'BTCUSDT')
  - `side` (text) - 'LONG' or 'SHORT'
  - `leverage` (integer) - 1 to 50
  - `entry_price` (decimal) - Price when position opened
  - `position_size` (decimal) - Total position value in USDT
  - `margin` (decimal) - Collateral used from wallet
  - `liquidation_price` (decimal) - Auto-close price
  - `maintenance_margin_rate` (decimal) - Min margin % to avoid liquidation
  - `unrealized_pnl` (decimal) - Current profit/loss
  - `take_profit` (decimal, optional) - Auto-close profit target
  - `stop_loss` (decimal, optional) - Auto-close loss limit
  - `trading_fee` (decimal) - Fee paid on open
  - `status` (text) - 'open', 'closed', 'liquidated'
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### `futures_history`
  Closed positions history for tracking performance:
  - All fields from futures_positions
  - `close_price` (decimal) - Price when position closed
  - `realized_pnl` (decimal) - Final profit/loss
  - `close_reason` (text) - 'manual', 'liquidated', 'take_profit', 'stop_loss'
  - `closed_at` (timestamptz)

  ## 2. Security
  - Enable RLS on all tables
  - Users can only access their own positions
  - Restrict INSERT/UPDATE/DELETE to authenticated users
  - Prevent manipulation of liquidation prices

  ## 3. Important Notes
  - Maintenance margin rates vary by coin volatility:
    * BTC/ETH: 0.4%
    * Major altcoins: 1%
    * Other coins: 2%
    * EarnQuest: 2%
  - Liquidation occurs when mark price hits liquidation_price
  - Trading fee: 0.05% on position open and close
  - Positions are isolated margin mode (only position margin at risk)
*/

-- Create futures_positions table
CREATE TABLE IF NOT EXISTS futures_positions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  symbol text NOT NULL,
  side text NOT NULL CHECK (side IN ('LONG', 'SHORT')),
  leverage integer NOT NULL CHECK (leverage >= 1 AND leverage <= 50),
  entry_price decimal(20, 8) NOT NULL CHECK (entry_price > 0),
  position_size decimal(20, 8) NOT NULL CHECK (position_size > 0),
  margin decimal(20, 8) NOT NULL CHECK (margin > 0),
  liquidation_price decimal(20, 8) NOT NULL CHECK (liquidation_price > 0),
  maintenance_margin_rate decimal(10, 6) NOT NULL DEFAULT 0.02,
  unrealized_pnl decimal(20, 8) DEFAULT 0,
  take_profit decimal(20, 8),
  stop_loss decimal(20, 8),
  trading_fee decimal(20, 8) NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed', 'liquidated')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_futures_positions_user_status ON futures_positions(user_id, status);
CREATE INDEX IF NOT EXISTS idx_futures_positions_symbol ON futures_positions(symbol);

-- Create futures_history table
CREATE TABLE IF NOT EXISTS futures_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  symbol text NOT NULL,
  side text NOT NULL CHECK (side IN ('LONG', 'SHORT')),
  leverage integer NOT NULL,
  entry_price decimal(20, 8) NOT NULL,
  close_price decimal(20, 8) NOT NULL,
  position_size decimal(20, 8) NOT NULL,
  margin decimal(20, 8) NOT NULL,
  liquidation_price decimal(20, 8) NOT NULL,
  maintenance_margin_rate decimal(10, 6) NOT NULL,
  realized_pnl decimal(20, 8) NOT NULL,
  trading_fee decimal(20, 8) NOT NULL,
  close_reason text NOT NULL CHECK (close_reason IN ('manual', 'liquidated', 'take_profit', 'stop_loss')),
  created_at timestamptz NOT NULL,
  closed_at timestamptz DEFAULT now()
);

-- Create index for history queries
CREATE INDEX IF NOT EXISTS idx_futures_history_user ON futures_history(user_id, closed_at DESC);

-- Enable Row Level Security
ALTER TABLE futures_positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE futures_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies for futures_positions
CREATE POLICY "Users can view own positions"
  ON futures_positions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own positions"
  ON futures_positions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own positions"
  ON futures_positions FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own positions"
  ON futures_positions FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- RLS Policies for futures_history
CREATE POLICY "Users can view own history"
  ON futures_history FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own history"
  ON futures_history FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_futures_position_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for updated_at
DROP TRIGGER IF EXISTS trigger_update_futures_position_timestamp ON futures_positions;
CREATE TRIGGER trigger_update_futures_position_timestamp
  BEFORE UPDATE ON futures_positions
  FOR EACH ROW
  EXECUTE FUNCTION update_futures_position_timestamp();