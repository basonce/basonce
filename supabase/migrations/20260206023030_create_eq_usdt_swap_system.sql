/*
  # EQ ↔ USDT Swap System

  1. Overview
    - Professional swap system for converting between EQ and USDT
    - Binance-style trading with real-time exchange rates
    - Transaction history tracking

  2. New Tables
    - `swap_transactions`
      - Records all swap operations
      - Tracks from/to coins and amounts
      - Exchange rate at time of swap
      - Timestamps for analytics

  3. Functions
    - `execute_swap()` - Performs atomic swap operation
      - Validates balances
      - Updates user_balances
      - Records transaction history
      - Returns success/error status

  4. Exchange Rate
    - 1 EQ = 0.50 USDT (configurable)
    - Can be updated via admin panel later

  5. Security
    - RLS enabled on all tables
    - Users can only swap their own funds
    - Atomic transactions prevent partial swaps
*/

-- Create swap transactions table
CREATE TABLE IF NOT EXISTS swap_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) NOT NULL,
  from_coin text NOT NULL,
  to_coin text NOT NULL,
  from_amount numeric NOT NULL,
  to_amount numeric NOT NULL,
  exchange_rate numeric NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE swap_transactions ENABLE ROW LEVEL SECURITY;

-- Users can view their own swap history
CREATE POLICY "Users can view own swap transactions"
  ON swap_transactions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Users can create swap transactions (via function)
CREATE POLICY "Users can create own swap transactions"
  ON swap_transactions
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Create swap execution function
CREATE OR REPLACE FUNCTION execute_swap(
  p_from_coin text,
  p_to_coin text,
  p_from_amount numeric
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_exchange_rate numeric;
  v_to_amount numeric;
  v_from_balance numeric;
  v_to_balance numeric;
BEGIN
  -- Get user ID
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
  END IF;

  -- Validate input
  IF p_from_amount <= 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invalid amount');
  END IF;

  -- Set exchange rate (1 EQ = 0.50 USDT)
  IF p_from_coin = 'EQ' AND p_to_coin = 'USDT' THEN
    v_exchange_rate := 0.50;
  ELSIF p_from_coin = 'USDT' AND p_to_coin = 'EQ' THEN
    v_exchange_rate := 2.0;  -- 1 USDT = 2 EQ
  ELSE
    RETURN jsonb_build_object('success', false, 'error', 'Unsupported swap pair');
  END IF;

  -- Calculate to_amount
  v_to_amount := p_from_amount * v_exchange_rate;

  -- Get current balances for from_coin
  IF p_from_coin = 'EQ' THEN
    SELECT COALESCE(eq_amount, 0) INTO v_from_balance
    FROM user_balances
    WHERE user_id = v_user_id AND symbol = 'USDT';
  ELSE
    SELECT COALESCE(balance, 0) INTO v_from_balance
    FROM user_balances
    WHERE user_id = v_user_id AND symbol = p_from_coin;
  END IF;

  -- Check sufficient balance
  IF v_from_balance < p_from_amount THEN
    RETURN jsonb_build_object('success', false, 'error', 'Insufficient balance');
  END IF;

  -- Perform the swap (atomic operation)
  IF p_from_coin = 'EQ' AND p_to_coin = 'USDT' THEN
    -- EQ to USDT
    UPDATE user_balances
    SET 
      eq_amount = COALESCE(eq_amount, 0) - p_from_amount,
      balance = COALESCE(balance, 0) + v_to_amount,
      updated_at = now()
    WHERE user_id = v_user_id AND symbol = 'USDT';
  ELSIF p_from_coin = 'USDT' AND p_to_coin = 'EQ' THEN
    -- USDT to EQ
    UPDATE user_balances
    SET 
      balance = COALESCE(balance, 0) - p_from_amount,
      eq_amount = COALESCE(eq_amount, 0) + v_to_amount,
      updated_at = now()
    WHERE user_id = v_user_id AND symbol = 'USDT';
  END IF;

  -- Record transaction
  INSERT INTO swap_transactions (
    user_id,
    from_coin,
    to_coin,
    from_amount,
    to_amount,
    exchange_rate
  ) VALUES (
    v_user_id,
    p_from_coin,
    p_to_coin,
    p_from_amount,
    v_to_amount,
    v_exchange_rate
  );

  RETURN jsonb_build_object(
    'success', true,
    'from_amount', p_from_amount,
    'to_amount', v_to_amount,
    'exchange_rate', v_exchange_rate
  );
END;
$$;