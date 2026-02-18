/*
  # Fix Social Posts - Only Exclamation Marks

  1. Changes
    - Remove excessive exclamation marks
    - More natural trading comments
    - Everyone can make any profit (no level restrictions)
    - Mix of . and occasional !
*/

TRUNCATE TABLE social_posts;

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
  content TEXT;
  v_profile RECORD;
  
  coins TEXT[] := ARRAY['BTC', 'ETH', 'BNB', 'SOL', 'DOGE', 'XRP', 'ADA', 'MATIC', 'LINK', 'DOT', 'AVAX', 'UNI', 'ATOM', 'LTC', 'BCH'];
  
  bull_comments TEXT[] := ARRAY[
    'Breaking resistance. Opened position with tight stop loss',
    'Perfect entry on this breakout. Target locked in',
    'Market looking bullish here, took a position',
    'This setup is too good to pass. Entered long',
    'Following the trend. Risk/reward looks amazing',
    'Bounce from key support level. Going long here',
    'Momentum is strong. Riding this wave',
    'Chart pattern confirmed. Position opened',
    'Market structure is bullish. Entered position',
    'Technical indicators aligned. Great entry',
    'Pulled the trigger on this setup. Looks promising',
    'Consolidation breakout confirmed. Long position',
    'Price action looking clean. Entered here',
    'Key level held perfectly. Opened long',
    'Following my trading plan. Good R:R here',
    'Market sentiment shifting bullish. Positioned',
    'Volume confirms the move. Entered long',
    'This dip was perfect for entry. Going long',
    'Weekly timeframe bullish. Swing trade opened',
    'Algorithm signaled entry. Following the system'
  ];
  
  bear_comments TEXT[] := ARRAY[
    'Expecting pullback here. Opened short position',
    'Resistance rejected. Short looks good here',
    'Overbought conditions. Time to short',
    'Market topped out. Entered short position',
    'Bearish divergence forming. Going short',
    'Trend reversal likely. Short position opened',
    'Price exhausted at this level. Shorting here',
    'Distribution phase started. Opened short',
    'Market overheated. Short with tight stops',
    'Resistance confluence here. Short entry',
    'Momentum weakening. Short position taken',
    'Chart pattern bearish. Entered short',
    'Volume declining. Opened short position',
    'Key resistance holding. Short looks good',
    'Market structure turning bearish. Shorting',
    'Fibonacci resistance hit. Short entry',
    'Indicators showing weakness. Going short',
    'Supply zone reached. Short position',
    'Trend losing steam. Opened short here',
    'Technical setup bearish. Short entered'
  ];
  
  loss_comments TEXT[] := ARRAY[
    'Stop loss hit. Market too choppy today',
    'Got stopped out. Will wait for better setup',
    'Market moved against me. Closed for loss',
    'Stop loss executed. Risk management working',
    'Wrong direction. Taking the L and moving on',
    'Took a hit here. Happens in trading',
    'Market faked me out. Stopped out',
    'Entry was too early. Lesson learned',
    'Volatility killed my position. Closed',
    'News moved against me. Stop hit',
    'Exited for small loss. Better safe',
    'This one did not work out. Next trade',
    'Market conditions changed. Cut losses',
    'Risk management saved me here. Small loss',
    'Position went against plan. Closed',
    'Wrong timing on this trade. Loss taken',
    'Market unpredictable today. Stopped out',
    'Technical setup failed. Loss accepted',
    'Better to cut losses here. Reset',
    'Did not go as planned. On to the next'
  ];

BEGIN
  FOR i IN 1..5000 LOOP
    SELECT * INTO v_profile FROM anonymous_profiles ORDER BY random() LIMIT 1;
    
    coin_symbol := coins[1 + floor(random() * array_length(coins, 1))];
    trade_type := CASE WHEN random() < 0.55 THEN 'long' ELSE 'short' END;
    
    leverage := CASE 
      WHEN random() < 0.4 THEN 5 + floor(random() * 15)::INTEGER
      WHEN random() < 0.75 THEN 20 + floor(random() * 30)::INTEGER
      ELSE 50 + floor(random() * 75)::INTEGER
    END;
    
    entry_price := CASE coin_symbol
      WHEN 'BTC' THEN 95000 + (random() * 10000)
      WHEN 'ETH' THEN 3200 + (random() * 800)
      WHEN 'BNB' THEN 580 + (random() * 120)
      WHEN 'SOL' THEN 140 + (random() * 60)
      WHEN 'DOGE' THEN 0.30 + (random() * 0.10)
      WHEN 'XRP' THEN 0.50 + (random() * 0.20)
      WHEN 'ADA' THEN 0.85 + (random() * 0.25)
      WHEN 'MATIC' THEN 0.95 + (random() * 0.30)
      WHEN 'LINK' THEN 22 + (random() * 8)
      WHEN 'DOT' THEN 8 + (random() * 3)
      WHEN 'AVAX' THEN 38 + (random() * 12)
      WHEN 'UNI' THEN 12 + (random() * 5)
      WHEN 'ATOM' THEN 10 + (random() * 4)
      WHEN 'LTC' THEN 95 + (random() * 35)
      ELSE 100 + (random() * 50)
    END;
    
    is_bullish := random() < 0.65;
    
    IF is_bullish THEN
      profit_loss_percent := 5 + (random() * 45);
      
      IF trade_type = 'long' THEN
        exit_price := entry_price * (1 + profit_loss_percent / 100 / leverage);
        content := bull_comments[1 + floor(random() * array_length(bull_comments, 1))];
      ELSE
        exit_price := entry_price * (1 - profit_loss_percent / 100 / leverage);
        content := bear_comments[1 + floor(random() * array_length(bear_comments, 1))];
      END IF;
      
      profit_loss := (entry_price * leverage / 10) * (profit_loss_percent / 100);
    ELSE
      profit_loss_percent := -(2 + (random() * 18));
      
      IF trade_type = 'long' THEN
        exit_price := entry_price * (1 + profit_loss_percent / 100 / leverage);
      ELSE
        exit_price := entry_price * (1 - profit_loss_percent / 100 / leverage);
      END IF;
      
      profit_loss := (entry_price * leverage / 10) * (profit_loss_percent / 100);
      content := loss_comments[1 + floor(random() * array_length(loss_comments, 1))];
    END IF;
    
    INSERT INTO social_posts (
      username, avatar_url, content, coin_symbol, trade_type,
      entry_price, exit_price, profit_loss, profit_loss_percent,
      leverage, image_url, likes_count, comments_count, shares_count,
      is_bullish, created_at
    ) VALUES (
      v_profile.username, v_profile.avatar_url, content, coin_symbol, trade_type,
      entry_price, exit_price, profit_loss, profit_loss_percent,
      leverage, NULL,
      floor(random() * 500)::INTEGER,
      floor(random() * 150)::INTEGER,
      floor(random() * 80)::INTEGER,
      is_bullish,
      now() - (random() * interval '30 days')
    );
  END LOOP;
END $$;
