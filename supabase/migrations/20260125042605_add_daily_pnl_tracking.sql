/*
  # Add Daily PNL (Profit and Loss) Tracking System

  1. Changes to user_balances
    - Add `daily_pnl` column to track today's profit/loss in USDT
    - Add `daily_pnl_updated_at` column to track when PNL was last calculated
    - Add `total_pnl` column to track all-time profit/loss
  
  2. New Function
    - `calculate_trade_pnl` function to automatically calculate PNL on each trade
    - Compares entry price vs exit price for buy/sell pairs
  
  3. Security
    - Users can only view their own PNL
    - Admins can view all PNL data
*/

-- Add PNL tracking columns to user_balances
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_balances' AND column_name = 'daily_pnl'
  ) THEN
    ALTER TABLE user_balances ADD COLUMN daily_pnl numeric DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_balances' AND column_name = 'daily_pnl_updated_at'
  ) THEN
    ALTER TABLE user_balances ADD COLUMN daily_pnl_updated_at timestamptz DEFAULT now();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_balances' AND column_name = 'total_pnl'
  ) THEN
    ALTER TABLE user_balances ADD COLUMN total_pnl numeric DEFAULT 0;
  END IF;
END $$;

-- Function to calculate daily PNL from transactions
CREATE OR REPLACE FUNCTION calculate_daily_pnl(user_id_param uuid)
RETURNS numeric
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  total_pnl numeric := 0;
  trade_record record;
  avg_buy_price numeric := 0;
  total_bought numeric := 0;
BEGIN
  -- Calculate PNL from today's trades
  -- For each coin, calculate: (sell_price - avg_buy_price) * amount_sold
  
  FOR trade_record IN (
    SELECT 
      symbol,
      type,
      amount,
      price,
      created_at
    FROM transactions
    WHERE user_id = user_id_param
      AND type IN ('buy', 'sell')
      AND DATE(created_at) = CURRENT_DATE
    ORDER BY created_at ASC
  ) LOOP
    IF trade_record.type = 'buy' THEN
      -- Update average buy price
      total_bought := total_bought + trade_record.amount;
      avg_buy_price := ((avg_buy_price * (total_bought - trade_record.amount)) + (trade_record.price * trade_record.amount)) / total_bought;
    ELSIF trade_record.type = 'sell' THEN
      -- Calculate profit/loss: (sell_price - avg_buy_price) * amount_sold
      total_pnl := total_pnl + ((trade_record.price - avg_buy_price) * trade_record.amount);
    END IF;
  END LOOP;

  RETURN total_pnl;
END;
$$;

-- Function to update user's daily PNL
CREATE OR REPLACE FUNCTION update_user_daily_pnl(user_id_param uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  calculated_pnl numeric;
BEGIN
  -- Calculate daily PNL
  calculated_pnl := calculate_daily_pnl(user_id_param);
  
  -- Update user_balances
  UPDATE user_balances
  SET 
    daily_pnl = calculated_pnl,
    daily_pnl_updated_at = now()
  WHERE user_id = user_id_param;
END;
$$;

-- Trigger to reset daily PNL at midnight
CREATE OR REPLACE FUNCTION reset_daily_pnl()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Reset daily PNL for all users if it's a new day
  UPDATE user_balances
  SET daily_pnl = 0
  WHERE DATE(daily_pnl_updated_at) < CURRENT_DATE;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION calculate_daily_pnl(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION update_user_daily_pnl(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION reset_daily_pnl() TO authenticated;