/*
  # Futures Trading'e PnL Entegrasyonu

  1. Değişiklikler
    - close_futures_position fonksiyonu oluşturulacak
    - Her position close sonrası PnL otomatik güncellenecek
    - Realized PnL hesaplanacak

  2. Özellikler
    - Long/Short pozisyonlarda PnL hesaplama
    - Günlük ve toplam PnL tracking
    - 24 saat sonra otomatik history'ye kaydetme
*/

-- Futures pozisyon kapatma fonksiyonu
CREATE OR REPLACE FUNCTION close_futures_position(
  p_user_id uuid,
  p_position_id uuid,
  p_close_price numeric,
  p_close_reason text DEFAULT 'manual'
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_position record;
  v_realized_pnl numeric;
  v_quantity numeric;
  v_close_fee numeric;
  v_margin_return numeric;
BEGIN
  SELECT * INTO v_position
  FROM futures_positions
  WHERE id = p_position_id AND user_id = p_user_id AND status = 'open';
  
  IF v_position IS NULL THEN
    RAISE EXCEPTION 'Position not found or already closed';
  END IF;
  
  v_quantity := v_position.position_size / v_position.entry_price;
  
  IF v_position.side = 'LONG' THEN
    v_realized_pnl := (p_close_price - v_position.entry_price) * v_quantity;
  ELSE
    v_realized_pnl := (v_position.entry_price - p_close_price) * v_quantity;
  END IF;
  
  v_close_fee := v_position.position_size * 0.0005;
  v_realized_pnl := v_realized_pnl - v_close_fee;
  
  v_margin_return := v_position.margin + v_realized_pnl;
  
  IF v_margin_return < 0 THEN
    v_margin_return := 0;
  END IF;
  
  UPDATE user_balances
  SET balance = balance + v_margin_return
  WHERE user_id = p_user_id AND symbol = 'USDT';
  
  INSERT INTO futures_history (
    user_id,
    symbol,
    side,
    leverage,
    entry_price,
    close_price,
    position_size,
    margin,
    liquidation_price,
    maintenance_margin_rate,
    realized_pnl,
    trading_fee,
    close_reason,
    created_at
  ) VALUES (
    v_position.user_id,
    v_position.symbol,
    v_position.side,
    v_position.leverage,
    v_position.entry_price,
    p_close_price,
    v_position.position_size,
    v_position.margin,
    v_position.liquidation_price,
    v_position.maintenance_margin_rate,
    v_realized_pnl,
    v_position.trading_fee + v_close_fee,
    p_close_reason,
    v_position.created_at
  );
  
  UPDATE futures_positions
  SET 
    status = 'closed',
    updated_at = now()
  WHERE id = p_position_id;
  
  INSERT INTO transactions (user_id, type, symbol, amount, notes, pnl)
  VALUES (
    p_user_id,
    CASE WHEN v_position.side = 'LONG' THEN 'close_long' ELSE 'close_short' END,
    v_position.symbol,
    v_position.position_size,
    format('Close %s %s position at %s USDT', v_position.side, v_position.symbol, p_close_price),
    v_realized_pnl
  );
  
  PERFORM update_user_daily_pnl_with_trade(p_user_id, v_realized_pnl);
  
  RETURN json_build_object(
    'success', true,
    'position_id', p_position_id,
    'realized_pnl', v_realized_pnl,
    'close_price', p_close_price,
    'margin_return', v_margin_return
  );
END;
$$;

-- Futures pozisyon açma fonksiyonu
CREATE OR REPLACE FUNCTION open_futures_position(
  p_user_id uuid,
  p_symbol text,
  p_side text,
  p_leverage integer,
  p_entry_price numeric,
  p_position_size numeric,
  p_maintenance_margin_rate numeric DEFAULT 0.02
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_margin numeric;
  v_trading_fee numeric;
  v_liquidation_price numeric;
  v_position_id uuid;
  v_usdt_balance numeric;
BEGIN
  v_margin := p_position_size / p_leverage;
  v_trading_fee := p_position_size * 0.0005;
  
  IF p_side = 'LONG' THEN
    v_liquidation_price := p_entry_price * (1 - (1.0 / p_leverage) + p_maintenance_margin_rate);
  ELSE
    v_liquidation_price := p_entry_price * (1 + (1.0 / p_leverage) + p_maintenance_margin_rate);
  END IF;
  
  SELECT balance INTO v_usdt_balance
  FROM user_balances
  WHERE user_id = p_user_id AND symbol = 'USDT';
  
  v_usdt_balance := COALESCE(v_usdt_balance, 0);
  
  IF v_usdt_balance < (v_margin + v_trading_fee) THEN
    RAISE EXCEPTION 'Insufficient USDT balance for margin and fee';
  END IF;
  
  UPDATE user_balances
  SET balance = balance - (v_margin + v_trading_fee)
  WHERE user_id = p_user_id AND symbol = 'USDT';
  
  INSERT INTO futures_positions (
    user_id,
    symbol,
    side,
    leverage,
    entry_price,
    position_size,
    margin,
    liquidation_price,
    maintenance_margin_rate,
    trading_fee
  ) VALUES (
    p_user_id,
    p_symbol,
    p_side,
    p_leverage,
    p_entry_price,
    p_position_size,
    v_margin,
    v_liquidation_price,
    p_maintenance_margin_rate,
    v_trading_fee
  )
  RETURNING id INTO v_position_id;
  
  INSERT INTO transactions (user_id, type, symbol, amount, notes)
  VALUES (
    p_user_id,
    CASE WHEN p_side = 'LONG' THEN 'open_long' ELSE 'open_short' END,
    p_symbol,
    p_position_size,
    format('Open %sx %s %s position at %s USDT', p_leverage, p_side, p_symbol, p_entry_price)
  );
  
  RETURN json_build_object(
    'success', true,
    'position_id', v_position_id,
    'margin', v_margin,
    'trading_fee', v_trading_fee,
    'liquidation_price', v_liquidation_price
  );
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION close_futures_position(uuid, uuid, numeric, text) TO authenticated;
GRANT EXECUTE ON FUNCTION open_futures_position(uuid, text, text, integer, numeric, numeric, numeric) TO authenticated;
