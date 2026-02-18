/*
  # Create TP/SL and Leverage System

  1. New Tables
    - `futures_tpsl_orders`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `position_id` (uuid, references futures_positions)
      - `type` (text - 'tp' or 'sl')
      - `trigger_price` (numeric)
      - `order_price` (numeric)
      - `quantity` (numeric)
      - `status` (text - 'active', 'triggered', 'cancelled')
      - `created_at` (timestamptz)
      - `triggered_at` (timestamptz)

    - `leverage_settings`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `symbol` (text)
      - `leverage` (integer, 1-125)
      - `margin_mode` (text - 'cross' or 'isolated')
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to manage their own data
*/

-- Create futures_tpsl_orders table
CREATE TABLE IF NOT EXISTS futures_tpsl_orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  position_id uuid REFERENCES futures_positions(id) ON DELETE CASCADE NOT NULL,
  type text NOT NULL CHECK (type IN ('tp', 'sl')),
  trigger_price numeric NOT NULL CHECK (trigger_price > 0),
  order_price numeric CHECK (order_price > 0),
  quantity numeric NOT NULL CHECK (quantity > 0),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'triggered', 'cancelled')),
  created_at timestamptz DEFAULT now(),
  triggered_at timestamptz
);

-- Create leverage_settings table
CREATE TABLE IF NOT EXISTS leverage_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  symbol text NOT NULL,
  leverage integer NOT NULL DEFAULT 1 CHECK (leverage >= 1 AND leverage <= 125),
  margin_mode text NOT NULL DEFAULT 'cross' CHECK (margin_mode IN ('cross', 'isolated')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, symbol)
);

-- Enable RLS
ALTER TABLE futures_tpsl_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE leverage_settings ENABLE ROW LEVEL SECURITY;

-- Policies for futures_tpsl_orders
CREATE POLICY "Users can view own TP/SL orders"
  ON futures_tpsl_orders FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own TP/SL orders"
  ON futures_tpsl_orders FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own TP/SL orders"
  ON futures_tpsl_orders FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own TP/SL orders"
  ON futures_tpsl_orders FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Policies for leverage_settings
CREATE POLICY "Users can view own leverage settings"
  ON leverage_settings FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own leverage settings"
  ON leverage_settings FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own leverage settings"
  ON leverage_settings FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own leverage settings"
  ON leverage_settings FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_tpsl_orders_user_id ON futures_tpsl_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_tpsl_orders_position_id ON futures_tpsl_orders(position_id);
CREATE INDEX IF NOT EXISTS idx_tpsl_orders_status ON futures_tpsl_orders(status);
CREATE INDEX IF NOT EXISTS idx_leverage_settings_user_id ON leverage_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_leverage_settings_symbol ON leverage_settings(symbol);

-- Enable realtime for TP/SL orders
ALTER PUBLICATION supabase_realtime ADD TABLE futures_tpsl_orders;