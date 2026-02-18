/*
  # Fix Admin Position Control to Use Price Overrides
  
  1. Changes
    - Update `get_all_active_positions()` to check admin_price_overrides first
    - Update `force_liquidate_position()` to use admin_price_overrides
    
  2. Logic
    - Priority: admin_price_overrides > supported_coins.current_price > entry_price
    - When admin sets a price override, it will immediately affect position calculations
    - Liquidations will use the admin override price if active
*/

-- Fix get_all_active_positions() to use price overrides
DROP FUNCTION IF EXISTS get_all_active_positions();

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
    -- Priority: admin override > current_price > entry_price
    COALESCE(
      (SELECT override_price 
       FROM admin_price_overrides 
       WHERE coin_symbol = REPLACE(fp.symbol, 'USDT', '') 
       AND is_active = true 
       AND (expires_at IS NULL OR expires_at > now())
       ORDER BY created_at DESC 
       LIMIT 1),
      sc.current_price,
      fp.entry_price
    ) as current_price,
    (fp.position_size / NULLIF(fp.entry_price, 0)) as size_in_coin,
    fp.leverage,
    fp.margin,
    fp.unrealized_pnl,
    fp.liquidation_price,
    CASE 
      WHEN COALESCE(
        (SELECT override_price 
         FROM admin_price_overrides 
         WHERE coin_symbol = REPLACE(fp.symbol, 'USDT', '') 
         AND is_active = true 
         AND (expires_at IS NULL OR expires_at > now())
         ORDER BY created_at DESC 
         LIMIT 1),
        sc.current_price,
        fp.entry_price
      ) = 0 THEN 0
      WHEN fp.side = 'LONG' THEN
        ((COALESCE(
          (SELECT override_price 
           FROM admin_price_overrides 
           WHERE coin_symbol = REPLACE(fp.symbol, 'USDT', '') 
           AND is_active = true 
           AND (expires_at IS NULL OR expires_at > now())
           ORDER BY created_at DESC 
           LIMIT 1),
          NULLIF(sc.current_price, 0),
          fp.entry_price
        ) - fp.liquidation_price) / NULLIF(COALESCE(
          (SELECT override_price 
           FROM admin_price_overrides 
           WHERE coin_symbol = REPLACE(fp.symbol, 'USDT', '') 
           AND is_active = true 
           AND (expires_at IS NULL OR expires_at > now())
           ORDER BY created_at DESC 
           LIMIT 1),
          NULLIF(sc.current_price, 0),
          fp.entry_price
        ), 0) * 100)
      ELSE
        ((fp.liquidation_price - COALESCE(
          (SELECT override_price 
           FROM admin_price_overrides 
           WHERE coin_symbol = REPLACE(fp.symbol, 'USDT', '') 
           AND is_active = true 
           AND (expires_at IS NULL OR expires_at > now())
           ORDER BY created_at DESC 
           LIMIT 1),
          NULLIF(sc.current_price, 0),
          fp.entry_price
        )) / NULLIF(COALESCE(
          (SELECT override_price 
           FROM admin_price_overrides 
           WHERE coin_symbol = REPLACE(fp.symbol, 'USDT', '') 
           AND is_active = true 
           AND (expires_at IS NULL OR expires_at > now())
           ORDER BY created_at DESC 
           LIMIT 1),
          NULLIF(sc.current_price, 0),
          fp.entry_price
        ), 0) * 100)
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

-- Fix force_liquidate_position() to use price overrides
DROP FUNCTION IF EXISTS force_liquidate_position(uuid, text);

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
  v_coin_symbol text;
BEGIN
  -- Get position details
  SELECT * INTO v_position
  FROM futures_positions
  WHERE id = p_position_id AND status = 'open';

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Position not found or already closed');
  END IF;

  -- Extract coin symbol (remove USDT)
  v_coin_symbol := REPLACE(v_position.symbol, 'USDT', '');

  -- Priority: admin override > supported_coins.current_price > entry_price
  SELECT COALESCE(
    (SELECT override_price 
     FROM admin_price_overrides 
     WHERE coin_symbol = v_coin_symbol 
     AND is_active = true 
     AND (expires_at IS NULL OR expires_at > now())
     ORDER BY created_at DESC 
     LIMIT 1),
    (SELECT current_price 
     FROM supported_coins 
     WHERE symbol = v_coin_symbol 
     LIMIT 1),
    v_position.entry_price
  ) INTO v_current_price;

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
    -v_position.margin, v_position.trading_fee, 'admin_force_liquidated', v_position.created_at
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
      'liquidation_price', v_current_price,
      'used_override_price', EXISTS(
        SELECT 1 FROM admin_price_overrides 
        WHERE coin_symbol = v_coin_symbol 
        AND is_active = true 
        AND (expires_at IS NULL OR expires_at > now())
      )
    )
  );

  RETURN jsonb_build_object(
    'success', true,
    'position_id', p_position_id,
    'user_id', v_position.user_id,
    'liquidated_amount', v_position.margin,
    'liquidation_price', v_current_price
  );
END;
$$;
