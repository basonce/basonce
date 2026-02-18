/*
  # Automatic Liquidation System with Admin Override Support (Fixed v3)
  
  1. Changes
    - Create improved auto_liquidate_positions() function
    - Uses admin_price_overrides first, then supported_coins.current_price
    - Properly handles liquidation logic for LONG and SHORT positions
    - Updates user balances correctly
    - Records transactions with correct type 'admin_deduct'
    
  2. Logic
    - Checks all open positions
    - Gets real price from admin_price_overrides or supported_coins
    - If price triggers liquidation, closes position and deducts margin
*/

-- Drop old functions
DROP FUNCTION IF EXISTS auto_liquidate_invalid_positions();
DROP FUNCTION IF EXISTS auto_liquidate_positions();
DROP FUNCTION IF EXISTS check_and_liquidate();

-- Create new automatic liquidation function
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
      -- Get balance before
      SELECT futures_balance INTO v_balance_before
      FROM user_balances
      WHERE user_id = pos_record.user_id AND symbol = 'USDT';
      
      v_balance_before := COALESCE(v_balance_before, 0);
      v_balance_after := GREATEST(0, v_balance_before - pos_record.margin);
      
      -- Update position status
      UPDATE futures_positions
      SET 
        status = 'liquidated',
        realized_pnl = -margin,
        updated_at = now()
      WHERE id = pos_record.id;
      
      -- Deduct margin from user's futures balance
      UPDATE user_balances
      SET 
        futures_balance = v_balance_after,
        updated_at = now()
      WHERE user_id = pos_record.user_id AND symbol = 'USDT';
      
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
      
      -- Record transaction
      INSERT INTO transactions (
        user_id, type, symbol, amount, balance_before, balance_after, notes, pnl
      ) VALUES (
        pos_record.user_id,
        'admin_deduct',
        'USDT',
        -pos_record.margin,
        v_balance_before,
        v_balance_after,
        'AUTO LIQUIDATION: ' || pos_record.symbol || ' ' || pos_record.side || ' ' || pos_record.leverage || 'x @ ' || v_current_price,
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

-- Create a helper function to run liquidation check (can be called from edge functions)
CREATE OR REPLACE FUNCTION check_and_liquidate()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result record;
BEGIN
  SELECT * INTO result FROM auto_liquidate_positions();
  
  RETURN jsonb_build_object(
    'success', true,
    'liquidated_count', result.liquidated_count,
    'total_margin_lost', result.total_margin_lost,
    'liquidated_positions', result.liquidated_positions,
    'timestamp', now()
  );
END;
$$;

-- Run initial check
SELECT check_and_liquidate();
