/*
  # Enable All Popular Coins for Futures Trading

  1. Changes
    - Enable futures trading for all major coins
    - BTC, ETH, BNB, SOL, MATIC, TRX, EQ (EarnQuest) and all others
    - Set proper binance_symbol for coins that were missing it
    
  2. Notes
    - All active coins will now show in Futures market selector
    - Real-time prices will be fetched from Binance
    - EarnQuest (EQ) will use its custom price system
*/

-- Enable futures trading for all major coins
UPDATE supported_coins SET 
  is_futures_enabled = true,
  binance_symbol = 'BTCUSDT'
WHERE symbol = 'BTC';

UPDATE supported_coins SET 
  is_futures_enabled = true,
  binance_symbol = 'ETHUSDT'
WHERE symbol = 'ETH';

UPDATE supported_coins SET 
  is_futures_enabled = true,
  binance_symbol = 'BNBUSDT'
WHERE symbol = 'BNB';

UPDATE supported_coins SET 
  is_futures_enabled = true,
  binance_symbol = 'SOLUSDT'
WHERE symbol = 'SOL';

UPDATE supported_coins SET 
  is_futures_enabled = true,
  binance_symbol = 'MATICUSDT'
WHERE symbol = 'MATIC';

UPDATE supported_coins SET 
  is_futures_enabled = true,
  binance_symbol = 'TRXUSDT'
WHERE symbol = 'TRX';

UPDATE supported_coins SET 
  is_futures_enabled = true
WHERE symbol = 'EQ';

-- Enable futures for remaining popular coins
UPDATE supported_coins SET 
  is_futures_enabled = true,
  binance_symbol = COALESCE(binance_symbol, symbol || 'USDT')
WHERE symbol IN ('XMR', 'THETA', 'XTZ', 'EOS', 'ZEC', 'DASH', 'NEO', 'IOTA', 
                 'CAKE', 'SNX', 'COMP', 'SUSHI', 'BAT', 'ENJ', 'CHZ', 
                 'ZIL', '1INCH', 'LRC', 'DAI')
  AND is_active = true;
