/*
  # Create Futures Orders Table

  ## Short Description
  Creates a comprehensive futures orders table to track all user orders including stop, limit, and trailing orders.

  ## Changes
  1. New Tables
    - `futures_orders`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `symbol` (text) - Trading pair
      - `side` (text) - 'buy' or 'sell'
      - `type` (text) - 'limit', 'market', 'stop-limit', 'stop-market', 'trailing-stop'
      - `price` (numeric) - Limit price
      - `trigger_price` (numeric) - Stop/trigger price
      - `trailing_delta` (numeric) - Callback rate for trailing stop
      - `amount` (numeric) - Order size
      - `filled` (numeric) - Filled amount
      - `total` (numeric) - Total value
      - `leverage` (integer)
      - `margin_mode` (text)
      - `post_only` (boolean)
      - `reduce_only` (boolean)
      - `time_in_force` (text) - 'GTC', 'IOC', 'FOK'
      - `status` (text) - 'open', 'filled', 'cancelled', 'partially_filled'
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `futures_orders` table
    - Add policies for users to manage their own orders
*/

CREATE TABLE IF NOT EXISTS futures_orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  symbol text NOT NULL,
  side text NOT NULL CHECK (side IN ('buy', 'sell')),
  type text NOT NULL CHECK (type IN ('limit', 'market', 'stop-limit', 'stop-market', 'trailing-stop')),
  price numeric DEFAULT 0,
  trigger_price numeric,
  trailing_delta numeric,
  amount numeric NOT NULL,
  filled numeric DEFAULT 0,
  total numeric NOT NULL,
  leverage integer DEFAULT 20,
  margin_mode text DEFAULT 'cross' CHECK (margin_mode IN ('cross', 'isolated')),
  post_only boolean DEFAULT false,
  reduce_only boolean DEFAULT false,
  time_in_force text DEFAULT 'GTC' CHECK (time_in_force IN ('GTC', 'IOC', 'FOK')),
  status text DEFAULT 'open' CHECK (status IN ('open', 'filled', 'cancelled', 'partially_filled')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE futures_orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own orders"
  ON futures_orders FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own orders"
  ON futures_orders FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own orders"
  ON futures_orders FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own orders"
  ON futures_orders FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_futures_orders_user_id ON futures_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_futures_orders_status ON futures_orders(status);
CREATE INDEX IF NOT EXISTS idx_futures_orders_created_at ON futures_orders(created_at DESC);
