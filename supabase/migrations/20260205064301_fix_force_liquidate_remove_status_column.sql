/*
  # Fix Force Liquidate - Remove Status Column

  ## Problem
  `force_liquidate_position` tries to insert `status` column into transactions table,
  but transactions table doesn't have a `status` column

  ## Solution
  Remove `status` from the INSERT statement in force_liquidate_position function

  ## Security
  - No changes to RLS policies
*/

-- Fix force_liquidate_position to not use status column
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
  v_balance_before decimal;
  v_balance_after decimal;
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

  -- Get current futures balance
  SELECT futures_balance INTO v_balance_before
  FROM user_balances
  WHERE user_id = v_position.user_id AND symbol = 'USDT';

  IF v_balance_before IS NULL THEN
    v_balance_before := 0;
  END IF;

  v_balance_after := GREATEST(0, v_balance_before - v_position.margin);

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
    futures_balance = v_balance_after,
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

  -- Record transaction (without status column)
  INSERT INTO transactions (
    user_id, type, symbol, amount, balance_before, balance_after, notes
  ) VALUES (
    v_position.user_id,
    'admin_deduct',
    'USDT',
    -v_position.margin,
    v_balance_before,
    v_balance_after,
    'Admin force liquidation: ' || v_position.symbol || ' ' || v_position.side
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
