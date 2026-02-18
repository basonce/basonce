/*
  # Create 5000 Realistic Social Posts
  
  1. Purpose
    - Generate 5000 diverse realistic futures trading posts
    - Mix of profitable and loss positions
    - Various coins: BTC, ETH, BNB, SOL, DOGE, XRP, ADA, MATIC, LINK, DOT
    - Different leverage levels (5x-125x)
    - Random timestamps over last 30 days
    - Realistic trading scenarios and comments
    
  2. Implementation
    - Delete all existing posts first
    - Use PL/pgSQL loop to generate 5000 posts
    - Randomize all parameters for realistic variety
    - Professional trader names and avatars
    - Real market-like price movements and PnL
*/

-- Delete all existing posts
DELETE FROM social_posts;

-- Generate 5000 realistic futures trading posts
DO $$
DECLARE
  i INTEGER;
  coin_symbol TEXT;
  trade_type TEXT;
  entry_price NUMERIC;
  exit_price NUMERIC;
  profit_loss NUMERIC;
  profit_loss_percent NUMERIC;
  leverage INTEGER;
  is_bullish BOOLEAN;
  username TEXT;
  avatar_num INTEGER;
  content TEXT;
  random_hours INTEGER;
  
  -- Arrays for randomization
  coins TEXT[] := ARRAY['BTC', 'ETH', 'BNB', 'SOL', 'DOGE', 'XRP', 'ADA', 'MATIC', 'LINK', 'DOT', 'AVAX', 'UNI', 'ATOM', 'LTC', 'BCH'];
  usernames TEXT[] := ARRAY[
    'CryptoKing', 'TraderMike', 'BTCMaxi', 'EthWhale', 'DeFiTrader', 'AltcoinPro', 'SolanaMaxi', 'CryptoNinja',
    'BinanceTrader', 'DayTrader99', 'DogeArmy', 'MemeTrader', 'RippleTrader', 'CryptoWhale', 'Rekt_Trader',
    'NoobTrader', 'LeverageKing', 'SmartMoney', 'PatientTrader', 'TechAnalyst', 'SwingTrader', 'ScalpMaster',
    'TrendFollower', 'GridTrader', 'NewsTrader', 'RiskManager', 'ProTrader100', 'InstitutionalFlow', 'AlgoTrader',
    'OptionsTrader', 'MacroInvestor', 'ChartMaster', 'FuturesGuru', 'CryptoSensei', 'TradingBot', 'MarketMaker',
    'WhaleWatcher', 'DipBuyer', 'MoonShot', 'DiamondHands', 'PaperHands', 'FOMO_Trader', 'HODLer4Life',
    'CryptoBull', 'BearKiller', 'SwingKing', 'ScalpQueen', 'ChartWizard', 'TechnicalTrader', 'FundamentalGuy'
  ];
  bull_comments TEXT[] := ARRAY[
    'Breaking resistance! Opened position with tight stop loss.',
    'Perfect entry on this breakout! Target locked in.',
    'Market looking bullish here, took a position.',
    'This setup is too good to pass. Entered long.',
    'Following the trend. Risk/reward looks amazing.',
    'Bounce from key support level. Going long here.',
    'Momentum is strong! Riding this wave.',
    'Chart pattern confirmed. Position opened.',
    'Market structure is bullish. Entered position.',
    'Technical indicators aligned. Great entry.',
    'Pulled the trigger on this setup. Looks promising.',
    'Consolidation breakout confirmed. Long position.',
    'Price action looking clean. Entered here.',
    'Key level held perfectly. Opened long.',
    'Following my trading plan. Good R:R here.',
    'Market sentiment shifting bullish. Positioned.',
    'Volume confirms the move. Entered long.',
    'This dip was perfect for entry. Going long.',
    'Weekly timeframe bullish. Swing trade opened.',
    'Algorithm signaled entry. Following the system.'
  ];
  bear_comments TEXT[] := ARRAY[
    'Expecting pullback here. Opened short position.',
    'Resistance rejected. Short looks good here.',
    'Overbought conditions. Time to short.',
    'Market topped out. Entered short position.',
    'Bearish divergence forming. Going short.',
    'Trend reversal likely. Short position opened.',
    'Price exhausted at this level. Shorting here.',
    'Distribution phase started. Opened short.',
    'Market overheated. Short with tight stops.',
    'Resistance confluence here. Short entry.',
    'Momentum weakening. Short position taken.',
    'Chart pattern bearish. Entered short.',
    'Volume declining. Opened short position.',
    'Key resistance holding. Short looks good.',
    'Market structure turning bearish. Shorting.',
    'Fibonacci resistance hit. Short entry.',
    'Indicators showing weakness. Going short.',
    'Supply zone reached. Short position.',
    'Trend losing steam. Opened short here.',
    'Technical setup bearish. Short entered.'
  ];
  loss_comments TEXT[] := ARRAY[
    'Stop loss hit. Market too choppy today.',
    'Got stopped out. Will wait for better setup.',
    'Liquidated... Used too much leverage.',
    'Market moved against me. Closed for loss.',
    'Stop loss executed. Risk management working.',
    'Wrong direction. Cut my losses early.',
    'Market reversed on me. Stopped out.',
    'Volatility got me. Lesson learned.',
    'Took the L. Better setup next time.',
    'Wrong timing. Closed at small loss.',
    'Stop loss saved me from bigger loss.',
    'Market faked me out. Stopped.',
    'Position closed. Not my day.',
    'Whipsaw action. Got stopped out.',
    'Accepted the loss. Moving on.',
    'Risk management in action. Small loss.',
    'Market didnt respect the level. Stopped.',
    'Closed position. Wrong trade.',
    'Stop hit but capital preserved.',
    'Learning experience. On to next trade.'
  ];
  
BEGIN
  FOR i IN 1..5000 LOOP
    -- Random coin selection
    coin_symbol := coins[1 + floor(random() * array_length(coins, 1))];
    
    -- Random trade type
    trade_type := CASE WHEN random() < 0.5 THEN 'long' ELSE 'short' END;
    
    -- Random leverage (higher chance for common leverage levels)
    leverage := CASE 
      WHEN random() < 0.3 THEN (ARRAY[10, 20, 25])[1 + floor(random() * 3)]
      WHEN random() < 0.7 THEN (ARRAY[30, 50, 75])[1 + floor(random() * 3)]
      ELSE (ARRAY[100, 125])[1 + floor(random() * 2)]
    END;
    
    -- 70% profitable, 30% loss
    is_bullish := random() < 0.7;
    
    -- Generate realistic prices based on coin
    entry_price := CASE coin_symbol
      WHEN 'BTC' THEN 95000 + random() * 10000
      WHEN 'ETH' THEN 3500 + random() * 700
      WHEN 'BNB' THEN 650 + random() * 100
      WHEN 'SOL' THEN 180 + random() * 40
      WHEN 'DOGE' THEN 0.35 + random() * 0.10
      WHEN 'XRP' THEN 2.70 + random() * 0.50
      WHEN 'ADA' THEN 0.85 + random() * 0.20
      WHEN 'MATIC' THEN 0.75 + random() * 0.20
      WHEN 'LINK' THEN 20 + random() * 8
      WHEN 'DOT' THEN 7.5 + random() * 2.5
      WHEN 'AVAX' THEN 35 + random() * 10
      WHEN 'UNI' THEN 12 + random() * 5
      WHEN 'ATOM' THEN 10 + random() * 4
      WHEN 'LTC' THEN 100 + random() * 30
      WHEN 'BCH' THEN 400 + random() * 100
      ELSE 100
    END;
    
    -- Generate realistic price movement (0.5% - 25%)
    profit_loss_percent := CASE
      WHEN is_bullish THEN 0.5 + random() * 24.5
      ELSE -(0.5 + random() * 12)
    END;
    
    -- Calculate exit price
    exit_price := entry_price * (1 + profit_loss_percent / 100);
    
    -- Calculate profit/loss (realistic position sizes)
    profit_loss := (500 + random() * 9500) * (profit_loss_percent / 100) * leverage;
    
    -- Random username and avatar
    username := usernames[1 + floor(random() * array_length(usernames, 1))];
    avatar_num := 1 + floor(random() * 70);
    
    -- Select appropriate comment based on trade outcome
    content := CASE
      WHEN NOT is_bullish THEN loss_comments[1 + floor(random() * array_length(loss_comments, 1))]
      WHEN trade_type = 'long' THEN bull_comments[1 + floor(random() * array_length(bull_comments, 1))]
      ELSE bear_comments[1 + floor(random() * array_length(bear_comments, 1))]
    END;
    
    -- Random timestamp (last 30 days)
    random_hours := floor(random() * 720);
    
    -- Insert the post
    INSERT INTO social_posts (
      username,
      avatar_url,
      content,
      coin_symbol,
      trade_type,
      entry_price,
      exit_price,
      profit_loss,
      profit_loss_percent,
      leverage,
      image_url,
      likes_count,
      comments_count,
      shares_count,
      is_bullish,
      created_at
    ) VALUES (
      username,
      'https://i.pravatar.cc/150?img=' || avatar_num,
      content || ' ' || coin_symbol || ' #' || leverage || 'x',
      coin_symbol,
      trade_type,
      entry_price,
      exit_price,
      profit_loss,
      profit_loss_percent,
      leverage,
      NULL,
      floor(random() * 500)::INTEGER,
      floor(random() * 100)::INTEGER,
      floor(random() * 50)::INTEGER,
      is_bullish,
      NOW() - (random_hours || ' hours')::INTERVAL
    );
  END LOOP;
END $$;