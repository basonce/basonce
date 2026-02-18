/*
  # Fix Force Liquidate Close Reason Bug

  ## Problem
  `force_liquidate_position` function writes 'admin_force_liquidated' as close_reason,
  but the database constraint only allows: 'manual', 'liquidated', 'take_profit', 'stop_loss'

  ## Solution
  Change 'admin_force_liquidated' to 'liquidated' in the force_liquidate_position function

  ## Security
  - No changes to RLS policies
  - Function remains SECURITY DEFINER for admin use
*/

-- Fix force_liquidate_position function to use correct close_reason
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

  -- Record to futures_history with correct close_reason: 'liquidated' instead of 'admin_force_liquidated'
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
