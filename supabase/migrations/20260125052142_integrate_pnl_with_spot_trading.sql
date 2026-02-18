/*
  # Spot Trading'e PnL Entegrasyonu

  1. Değişiklikler
    - execute_spot_order fonksiyonu güncellenecek
    - Her trade sonrası PnL otomatik güncellenecek
    - Sell işlemlerinde realized PnL hesaplanacak

  2. Özellikler
    - Her trade sonrası otomatik PnL güncelleme
    - Günlük ve toplam PnL tracking
    - 24 saat sonra otomatik history'ye kaydetme
*/

-- execute_spot_order fonksiyonunu PnL ile güncelle
CREATE OR REPLACE FUNCTION execute_spot_order(
  p_user_id uuid,
  p_symbol text,
  p_side text,
  p_price numeric,
  p_quantity numeric
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_total numeric;
  v_fee numeric;
  v_usdt_balance numeric;
  v_coin_balance numeric;
  v_order_id uuid;
  v_trade_id uuid;
  v_position record;
  v_realized_pnl numeric := 0;
  v_avg_buy_price numeric := 0;
BEGIN
  v_total := p_price * p_quantity;
  v_fee := v_total * 0.001;
  
  SELECT balance INTO v_usdt_balance
  FROM user_balances
  WHERE user_id = p_user_id AND symbol = 'USDT';
  
  SELECT balance INTO v_coin_balance
  FROM user_balances
  WHERE user_id = p_user_id AND symbol = p_symbol;
  
  v_usdt_balance := COALESCE(v_usdt_balance, 0);
  v_coin_balance := COALESCE(v_coin_balance, 0);
  
  IF p_side = 'buy' THEN
    IF v_usdt_balance < (v_total + v_fee) THEN
      RAISE EXCEPTION 'Insufficient USDT balance';
    END IF;
  ELSE
    IF v_coin_balance < p_quantity THEN
      RAISE EXCEPTION 'Insufficient % balance', p_symbol;
    END IF;
  END IF;
  
  SELECT * INTO v_position
  FROM user_positions
  WHERE user_id = p_user_id AND symbol = p_symbol;
  
  IF p_side = 'sell' AND v_position IS NOT NULL THEN
    v_avg_buy_price := v_position.average_price;
    v_realized_pnl := (p_price - v_avg_buy_price) * p_quantity;
  END IF;
  
  INSERT INTO spot_orders (user_id, symbol, side, price, quantity, total, status)
  VALUES (p_user_id, p_symbol, p_side, p_price, p_quantity, v_total, 'filled')
  RETURNING id INTO v_order_id;
  
  INSERT INTO user_trades (user_id, order_id, symbol, side, price, quantity, total, fee, realized_pnl)
  VALUES (p_user_id, v_order_id, p_symbol, p_side, p_price, p_quantity, v_total, v_fee, v_realized_pnl)
  RETURNING id INTO v_trade_id;
  
  IF p_side = 'buy' THEN
    UPDATE user_balances
    SET balance = balance - (v_total + v_fee)
    WHERE user_id = p_user_id AND symbol = 'USDT';
    
    INSERT INTO user_balances (user_id, symbol, balance)
    VALUES (p_user_id, p_symbol, p_quantity)
    ON CONFLICT (user_id, symbol)
    DO UPDATE SET balance = user_balances.balance + p_quantity;
    
    INSERT INTO user_positions (user_id, symbol, total_quantity, average_price, total_invested)
    VALUES (p_user_id, p_symbol, p_quantity, p_price, v_total)
    ON CONFLICT (user_id, symbol)
    DO UPDATE SET
      total_quantity = user_positions.total_quantity + p_quantity,
      total_invested = user_positions.total_invested + v_total,
      average_price = (user_positions.total_invested + v_total) / (user_positions.total_quantity + p_quantity),
      updated_at = now();
      
  ELSE
    UPDATE user_balances
    SET balance = balance - p_quantity
    WHERE user_id = p_user_id AND symbol = p_symbol;
    
    UPDATE user_balances
    SET balance = balance + (v_total - v_fee)
    WHERE user_id = p_user_id AND symbol = 'USDT';
    
    UPDATE user_positions
    SET
      total_quantity = total_quantity - p_quantity,
      total_invested = CASE
        WHEN (total_quantity - p_quantity) <= 0 THEN 0
        ELSE total_invested - (average_price * p_quantity)
      END,
      average_price = CASE
        WHEN (total_quantity - p_quantity) <= 0 THEN 0
        ELSE average_price
      END,
      updated_at = now()
    WHERE user_id = p_user_id AND symbol = p_symbol;
  END IF;
  
  INSERT INTO transactions (user_id, type, symbol, amount, notes, pnl)
  VALUES (
    p_user_id,
    p_side,
    p_symbol,
    p_quantity,
    format('%s %s %s at %s USDT', UPPER(p_side), p_quantity, p_symbol, p_price),
    v_realized_pnl
  );
  
  IF p_side = 'sell' AND v_realized_pnl != 0 THEN
    PERFORM update_user_daily_pnl_with_trade(p_user_id, v_realized_pnl);
  END IF;
  
  RETURN json_build_object(
    'success', true,
    'order_id', v_order_id,
    'trade_id', v_trade_id,
    'side', p_side,
    'symbol', p_symbol,
    'price', p_price,
    'quantity', p_quantity,
    'total', v_total,
    'fee', v_fee,
    'realized_pnl', v_realized_pnl
  );
END;
$$;

-- Transactions tablosuna pnl kolonu ekle
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'transactions' AND column_name = 'pnl'
  ) THEN
    ALTER TABLE transactions ADD COLUMN pnl decimal(18, 8) DEFAULT 0;
  END IF;
END $$;
