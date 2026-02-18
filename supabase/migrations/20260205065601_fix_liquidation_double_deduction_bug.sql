/*
  # Fix Critical Liquidation Bug - Double Deduction

  ## Problem
  When liquidating a position, the system was deducting the margin AGAIN from the user's balance.
  But the margin was already taken when the position was opened!

  Example Bug:
  - User has 335 USDT
  - Opens 35 USDT margin position -> Balance becomes 300 USDT (35 locked in position)
  - Position gets liquidated -> System deducts 35 USDT AGAIN -> Balance becomes 265 USDT
  - User lost 70 USDT total instead of 35 USDT!

  ## Correct Logic
  - Margin is taken when position opens (spot -> futures transfer)
  - When liquidated, the margin is simply lost (already in position)
  - NO additional deduction from balance needed
  - Just close position and record the loss

  ## Solution
  Remove the balance deduction from both force_liquidate_position and auto_liquidate_positions
*/

-- Fix force_liquidate_position - DO NOT deduct from balance again
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

  -- Get current futures balance (for transaction record only)
  SELECT futures_balance INTO v_balance_before
  FROM user_balances
  WHERE user_id = v_position.user_id AND symbol = 'USDT';

  v_balance_before := COALESCE(v_balance_before, 0);
  v_balance_after := v_balance_before; -- No change to balance!

  -- Mark position as liquidated
  UPDATE futures_positions
  SET 
    status = 'liquidated',
    realized_pnl = -v_position.margin,
    updated_at = now()
  WHERE id = p_position_id;

  -- DO NOT deduct from balance - margin was already taken when position opened!
  -- The margin is lost but it's already "locked" in the position

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

  -- Record transaction (no balance change, just for history)
  INSERT INTO transactions (
    user_id, type, symbol, amount, balance_before, balance_after, notes, pnl
  ) VALUES (
    v_position.user_id,
    'futures_liquidation',
    'USDT',
    0, -- No balance change
    v_balance_before,
    v_balance_after,
    'LIQUIDATED: ' || v_position.symbol || ' ' || v_position.side || ' ' || v_position.leverage || 'x - Lost ' || v_position.margin || ' USDT margin',
    -v_position.margin
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
      'liquidation_price', v_current_price,
      'note', 'Margin was already deducted when position opened - no double deduction'
    )
  );

  RETURN jsonb_build_object(
    'success', true,
    'position_id', p_position_id,
    'user_id', v_position.user_id,
    'liquidated_amount', v_position.margin,
    'note', 'Position liquidated. Margin lost but not deducted again from balance.'
  );
END;
$$;

-- Fix auto_liquidate_positions - DO NOT deduct from balance again
CREATE OR REPLACE FUNCTION auto_liquidate_positions()
RETURNS TABLE(
  liquidated_count integer,
  total_margin_lost decimal,
  liquidated_positions jsonb[]
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  liq_count integer := 0;
  total_lost decimal := 0;
  pos_record record;
  v_current_price decimal;
  v_coin_symbol text;
  v_should_liquidate boolean;
  liquidated_list jsonb[] := ARRAY[]::jsonb[];
  v_balance_before decimal;
  v_balance_after decimal;
BEGIN
  -- Loop through all open positions
  FOR pos_record IN (
    SELECT fp.*
    FROM futures_positions fp
    WHERE fp.status = 'open'
  )
  LOOP
    -- Extract coin symbol (remove USDT)
    v_coin_symbol := REPLACE(pos_record.symbol, 'USDT', '');
    
    -- Get current price with priority: admin_override > supported_coins > entry_price
    SELECT COALESCE(
      (SELECT apo.override_price 
       FROM admin_price_overrides apo
       WHERE apo.coin_symbol = v_coin_symbol
       AND apo.is_active = true 
       AND (apo.expires_at IS NULL OR apo.expires_at > now())
       ORDER BY apo.created_at DESC 
       LIMIT 1),
      (SELECT sc.current_price 
       FROM supported_coins sc
       WHERE sc.symbol = v_coin_symbol 
       LIMIT 1),
      pos_record.entry_price
    ) INTO v_current_price;
    
    -- Check if position should be liquidated
    v_should_liquidate := false;
    
    IF pos_record.side = 'LONG' AND v_current_price <= pos_record.liquidation_price THEN
      v_should_liquidate := true;
    ELSIF pos_record.side = 'SHORT' AND v_current_price >= pos_record.liquidation_price THEN
      v_should_liquidate := true;
    END IF;
    
    -- Liquidate if needed
    IF v_should_liquidate THEN
      -- Get balance (for record only, no deduction)
      SELECT futures_balance INTO v_balance_before
      FROM user_balances
      WHERE user_id = pos_record.user_id AND symbol = 'USDT';
      
      v_balance_before := COALESCE(v_balance_before, 0);
      v_balance_after := v_balance_before; -- No change!
      
      -- Update position status
      UPDATE futures_positions
      SET 
        status = 'liquidated',
        realized_pnl = -margin,
        updated_at = now()
      WHERE id = pos_record.id;
      
      -- DO NOT deduct margin - it was already taken when position opened!
      
      -- Record to futures_history
      INSERT INTO futures_history (
        user_id, symbol, side, leverage, entry_price, close_price,
        position_size, margin, liquidation_price, maintenance_margin_rate,
        realized_pnl, trading_fee, close_reason, created_at
      ) VALUES (
        pos_record.user_id, pos_record.symbol, pos_record.side, pos_record.leverage,
        pos_record.entry_price, v_current_price, pos_record.position_size, pos_record.margin,
        pos_record.liquidation_price, pos_record.maintenance_margin_rate,
        -pos_record.margin, pos_record.trading_fee, 'liquidated', pos_record.created_at
      );
      
      -- Record transaction (no balance change)
      INSERT INTO transactions (
        user_id, type, symbol, amount, balance_before, balance_after, notes, pnl
      ) VALUES (
        pos_record.user_id,
        'futures_liquidation',
        'USDT',
        0, -- No balance change
        v_balance_before,
        v_balance_after,
        'AUTO LIQUIDATION: ' || pos_record.symbol || ' ' || pos_record.side || ' ' || pos_record.leverage || 'x @ ' || v_current_price || ' - Lost ' || pos_record.margin || ' USDT',
        -pos_record.margin
      );
      
      -- Add to liquidated list
      liquidated_list := array_append(
        liquidated_list,
        jsonb_build_object(
          'position_id', pos_record.id,
          'user_id', pos_record.user_id,
          'symbol', pos_record.symbol,
          'side', pos_record.side,
          'entry_price', pos_record.entry_price,
          'liquidation_price', pos_record.liquidation_price,
          'current_price', v_current_price,
          'margin_lost', pos_record.margin,
          'leverage', pos_record.leverage
        )
      );
      
      liq_count := liq_count + 1;
      total_lost := total_lost + pos_record.margin;
    END IF;
  END LOOP;
  
  RETURN QUERY SELECT liq_count, total_lost, liquidated_list;
END;
$$;
