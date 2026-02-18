/*
  # Fix force_liquidate function - use correct close_reason
  
  ## Changes
  - Change close_reason from 'admin_force_liquidated' to 'liquidated'
*/

CREATE OR REPLACE FUNCTION force_liquidate_position(
  p_position_id uuid,
  p_admin_email text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_position record;
  v_current_price decimal;
  v_balance_before decimal;
BEGIN
  SELECT * INTO v_position
  FROM futures_positions
  WHERE id = p_position_id AND status = 'open';

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Position not found or already closed');
  END IF;

  SELECT current_price INTO v_current_price
  FROM supported_coins
  WHERE symbol = REPLACE(v_position.symbol, 'USDT', '')
  LIMIT 1;

  IF v_current_price IS NULL THEN
    v_current_price := v_position.entry_price;
  END IF;

  SELECT futures_balance INTO v_balance_before
  FROM user_balances
  WHERE user_id = v_position.user_id AND symbol = 'USDT';

  v_balance_before := COALESCE(v_balance_before, 0);

  UPDATE futures_positions
  SET 
    status = 'liquidated',
    realized_pnl = -v_position.margin,
    updated_at = now()
  WHERE id = p_position_id;

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

  INSERT INTO transactions (
    user_id, type, symbol, amount, balance_before, balance_after, notes, pnl
  ) VALUES (
    v_position.user_id,
    'futures_liquidation',
    'USDT',
    0,
    v_balance_before,
    v_balance_before,
    'ADMIN LIQUIDATION: ' || v_position.symbol || ' ' || v_position.side || ' ' || v_position.leverage || 'x',
    -v_position.margin
  );

  INSERT INTO admin_actions_log (
    admin_email, action_type, target_user_id, position_id, details
  ) VALUES (
    p_admin_email, 'force_liquidate', v_position.user_id, p_position_id,
    jsonb_build_object(
      'coin_symbol', v_position.symbol,
      'margin_lost', v_position.margin,
      'note', 'NO double deduction'
    )
  );

  RETURN jsonb_build_object(
    'success', true,
    'position_id', p_position_id,
    'margin_lost', v_position.margin
  );
END;
$$;