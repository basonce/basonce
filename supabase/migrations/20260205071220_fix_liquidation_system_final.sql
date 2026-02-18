/*
  # Fix Liquidation System - Complete Fix

  ## Changes
  
  1. **Add 'futures_liquidation' to transaction types**
     - Allows proper transaction logging for liquidations
  
  2. **Fix auto_liquidate_positions function**
     - NO double deduction (margin already taken when position opened)
     - Balance stays the same during liquidation
     - Only records the loss in transaction history
  
  3. **Fix force_liquidate_position function**
     - NO double deduction
     - Balance stays the same
     - Admin can safely liquidate positions
  
  ## Security
  - All functions maintain RLS compliance
  - Transaction history preserved
  - No data loss
*/

-- 1. Add 'futures_liquidation' to allowed transaction types
ALTER TABLE transactions 
DROP CONSTRAINT IF EXISTS transactions_type_check;

ALTER TABLE transactions
ADD CONSTRAINT transactions_type_check 
CHECK (type IN (
  'deposit', 'withdrawal', 'trade', 
  'admin_credit', 'admin_debit', 
  'admin_add', 'admin_deduct',
  'buy', 'sell',
  'futures_liquidation'
));

-- 2. Fix auto_liquidate_positions function (NO DOUBLE DEDUCTION)
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
BEGIN
  FOR pos_record IN (
    SELECT fp.*
    FROM futures_positions fp
    WHERE fp.status = 'open'
  )
  LOOP
    v_coin_symbol := REPLACE(pos_record.symbol, 'USDT', '');

    -- Get current price (priority: admin_override > supported_coins > entry_price)
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

    -- Check if should liquidate
    v_should_liquidate := false;

    IF pos_record.side = 'LONG' AND v_current_price <= pos_record.liquidation_price THEN
      v_should_liquidate := true;
    ELSIF pos_record.side = 'SHORT' AND v_current_price >= pos_record.liquidation_price THEN
      v_should_liquidate := true;
    END IF;

    IF v_should_liquidate THEN
      -- Get balance (for record only, NO DEDUCTION!)
      SELECT futures_balance INTO v_balance_before
      FROM user_balances
      WHERE user_id = pos_record.user_id AND symbol = 'USDT';

      v_balance_before := COALESCE(v_balance_before, 0);

      -- Update position status
      UPDATE futures_positions
      SET 
        status = 'liquidated',
        realized_pnl = -margin,
        updated_at = now()
      WHERE id = pos_record.id;

      -- ✓ NO BALANCE DEDUCTION (margin was already taken when position opened!)

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

      -- Record transaction (amount = 0, balance stays same)
      INSERT INTO transactions (
        user_id, type, symbol, amount, balance_before, balance_after, notes, pnl
      ) VALUES (
        pos_record.user_id,
        'futures_liquidation',
        'USDT',
        0, -- ✓ NO DEDUCTION
        v_balance_before,
        v_balance_before, -- ✓ BALANCE STAYS SAME
        'AUTO LIQUIDATION: ' || pos_record.symbol || ' ' || pos_record.side || ' ' || pos_record.leverage || 'x @ ' || v_current_price,
        -pos_record.margin
      );

      liquidated_list := array_append(
        liquidated_list,
        jsonb_build_object(
          'position_id', pos_record.id,
          'user_id', pos_record.user_id,
          'symbol', pos_record.symbol,
          'side', pos_record.side,
          'margin_lost', pos_record.margin
        )
      );

      liq_count := liq_count + 1;
      total_lost := total_lost + pos_record.margin;
    END IF;
  END LOOP;

  RETURN QUERY SELECT liq_count, total_lost, liquidated_list;
END;
$$;

-- 3. Fix force_liquidate_position function (NO DOUBLE DEDUCTION)
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
  -- Get position
  SELECT * INTO v_position
  FROM futures_positions
  WHERE id = p_position_id AND status = 'open';

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Position not found or already closed');
  END IF;

  -- Get current price
  SELECT current_price INTO v_current_price
  FROM supported_coins
  WHERE symbol = REPLACE(v_position.symbol, 'USDT', '')
  LIMIT 1;

  IF v_current_price IS NULL THEN
    v_current_price := v_position.entry_price;
  END IF;

  -- Get balance (for record only, NO DEDUCTION!)
  SELECT futures_balance INTO v_balance_before
  FROM user_balances
  WHERE user_id = v_position.user_id AND symbol = 'USDT';

  v_balance_before := COALESCE(v_balance_before, 0);

  -- Mark as liquidated
  UPDATE futures_positions
  SET 
    status = 'liquidated',
    realized_pnl = -v_position.margin,
    updated_at = now()
  WHERE id = p_position_id;

  -- ✓ NO BALANCE DEDUCTION!

  -- Record to history
  INSERT INTO futures_history (
    user_id, symbol, side, leverage, entry_price, close_price,
    position_size, margin, liquidation_price, maintenance_margin_rate,
    realized_pnl, trading_fee, close_reason, created_at
  ) VALUES (
    v_position.user_id, v_position.symbol, v_position.side, v_position.leverage,
    v_position.entry_price, v_current_price, v_position.position_size, v_position.margin,
    v_position.liquidation_price, v_position.maintenance_margin_rate,
    -v_position.margin, v_position.trading_fee, 'admin_force_liquidated', v_position.created_at
  );

  -- Record transaction (amount = 0)
  INSERT INTO transactions (
    user_id, type, symbol, amount, balance_before, balance_after, notes, pnl
  ) VALUES (
    v_position.user_id,
    'futures_liquidation',
    'USDT',
    0, -- ✓ NO DEDUCTION
    v_balance_before,
    v_balance_before, -- ✓ BALANCE STAYS SAME
    'ADMIN LIQUIDATION: ' || v_position.symbol || ' ' || v_position.side || ' ' || v_position.leverage || 'x',
    -v_position.margin
  );

  -- Log admin action
  INSERT INTO admin_actions_log (
    admin_email, action_type, target_user_id, position_id, details
  ) VALUES (
    p_admin_email, 'force_liquidate', v_position.user_id, p_position_id,
    jsonb_build_object(
      'coin_symbol', v_position.symbol,
      'margin_lost', v_position.margin,
      'note', 'NO double deduction - margin already taken when position opened'
    )
  );

  RETURN jsonb_build_object(
    'success', true,
    'position_id', p_position_id,
    'margin_lost', v_position.margin,
    'note', 'Position liquidated correctly (no double deduction)'
  );
END;
$$;