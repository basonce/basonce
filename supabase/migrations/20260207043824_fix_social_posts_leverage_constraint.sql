/*
  # Fix Social Posts Leverage Constraint

  1. Changes
    - Set minimum leverage to 1 instead of 0 for questions/analysis posts
*/

DROP FUNCTION IF EXISTS generate_random_social_posts();

CREATE OR REPLACE FUNCTION generate_random_social_posts()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  i integer;
  random_profile_id bigint;
  random_coin text;
  random_post_type text;
  random_pnl numeric;
  random_leverage integer;
  random_entry numeric;
  random_exit numeric;
  random_trade_type text;
  message_text text;
  random_likes integer;
  random_comments integer;
  random_shares integer;
  random_timestamp timestamptz;
  random_is_bullish boolean;
  random_pnl_percent numeric;
  profile_username text;
  profile_avatar text;
BEGIN
  FOR i IN 1..100 LOOP
    -- Get random profile with DiceBear avatar
    SELECT id, username, 'https://api.dicebear.com/7.x/personas/svg?seed=' || id
    INTO random_profile_id, profile_username, profile_avatar
    FROM anonymous_profiles
    ORDER BY random()
    LIMIT 1;
    
    -- Get random coin
    SELECT symbol INTO random_coin
    FROM supported_coins
    WHERE is_futures_enabled = true
    ORDER BY random()
    LIMIT 1;
    
    -- Determine post type
    random_post_type := (ARRAY['win', 'loss', 'analysis', 'question'])[floor(random() * 4 + 1)];
    
    -- Generate content based on type
    IF random_post_type = 'win' THEN
      random_pnl := round((random() * 9000 + 1000)::numeric, 2);
      random_leverage := (ARRAY[5, 10, 20, 25, 50, 75, 100, 125])[floor(random() * 8 + 1)];
      random_entry := round((random() * 50000 + 1000)::numeric, 2);
      random_exit := round((random_entry * (1 + (random() * 0.3 + 0.05)))::numeric, 2);
      random_trade_type := 'long';
      random_is_bullish := true;
      random_pnl_percent := round(((random_exit - random_entry) / random_entry * 100 * random_leverage)::numeric, 2);
      
      message_text := (ARRAY[
        'Just closed ' || random_coin || ' long at ' || random_leverage || 'x! +$' || random_pnl || ' profit',
        'Easy ' || random_leverage || 'x win on ' || random_coin || '! Entry: $' || random_entry || ' Exit: $' || random_exit,
        random_coin || ' to the moon! ' || random_leverage || 'x leverage made me $' || random_pnl,
        'Called it! ' || random_coin || ' long ' || random_leverage || 'x = $' || random_pnl || ' profit',
        'Another win with ' || random_coin || '! ' || random_leverage || 'x long closed at $' || random_exit
      ])[floor(random() * 5 + 1)];
      random_likes := floor(random() * 200 + 50);
      random_comments := floor(random() * 30 + 5);
      random_shares := floor(random() * 15 + 2);
      
    ELSIF random_post_type = 'loss' THEN
      random_pnl := round((random() * -800 - 100)::numeric, 2);
      random_leverage := (ARRAY[50, 75, 100, 125])[floor(random() * 4 + 1)];
      random_entry := round((random() * 50000 + 1000)::numeric, 2);
      random_exit := round((random_entry * (1 - (random() * 0.15 + 0.05)))::numeric, 2);
      random_trade_type := (ARRAY['long', 'short'])[floor(random() * 2 + 1)];
      random_is_bullish := false;
      random_pnl_percent := round(((random_exit - random_entry) / random_entry * 100 * random_leverage)::numeric, 2);
      
      message_text := (ARRAY[
        'Got liquidated on ' || random_coin || ' ' || random_leverage || 'x... -$' || abs(random_pnl),
        random_coin || ' short got stopped out. -$' || abs(random_pnl) || ' loss',
        'Overleveraged ' || random_coin || ' at ' || random_leverage || 'x. Lost $' || abs(random_pnl),
        'Wrong direction on ' || random_coin || '. -$' || abs(random_pnl) || ' lesson learned'
      ])[floor(random() * 4 + 1)];
      random_likes := floor(random() * 30 + 5);
      random_comments := floor(random() * 15 + 3);
      random_shares := floor(random() * 5 + 1);
      
    ELSIF random_post_type = 'analysis' THEN
      random_entry := round((random() * 50000 + 1000)::numeric, 2);
      random_exit := 0;
      random_pnl := 0;
      random_pnl_percent := 0;
      random_leverage := (ARRAY[10, 20, 25, 50])[floor(random() * 4 + 1)];  -- FIX: Use actual leverage values
      random_trade_type := (ARRAY['long', 'short'])[floor(random() * 2 + 1)];
      random_is_bullish := random() > 0.5;
      
      message_text := (ARRAY[
        random_coin || ' looking bullish on the 4h chart. Potential long setup',
        'Watch ' || random_coin || ' at $' || random_entry || ' support level',
        random_coin || ' breaking resistance! Time to enter?',
        'Technical analysis: ' || random_coin || ' forming a bullish pattern',
        random_coin || ' volume increasing. Big move incoming?',
        'RSI oversold on ' || random_coin || '. Potential bounce',
        random_coin || ' trend reversal? Check your positions'
      ])[floor(random() * 7 + 1)];
      random_likes := floor(random() * 80 + 20);
      random_comments := floor(random() * 20 + 5);
      random_shares := floor(random() * 10 + 2);
      
    ELSE -- question
      random_entry := 0;
      random_exit := 0;
      random_pnl := 0;
      random_pnl_percent := 0;
      random_leverage := (ARRAY[1, 5, 10, 20])[floor(random() * 4 + 1)];  -- FIX: Min leverage 1
      random_trade_type := 'long';
      random_is_bullish := true;
      
      message_text := (ARRAY[
        'Should I long or short ' || random_coin || ' right now?',
        'What is your ' || random_coin || ' price prediction?',
        'Is ' || random_coin || ' a good buy at current price?',
        'Anyone trading ' || random_coin || ' today?',
        'Best leverage for ' || random_coin || ' in this market?',
        'Thoughts on ' || random_coin || ' for tomorrow?'
      ])[floor(random() * 6 + 1)];
      random_likes := floor(random() * 40 + 5);
      random_comments := floor(random() * 25 + 5);
      random_shares := floor(random() * 8 + 1);
    END IF;
    
    -- Random timestamp within last 7 days
    random_timestamp := now() - (random() * interval '7 days');
    
    -- Insert the post with ALL required columns
    INSERT INTO social_posts (
      profile_id,
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
      random_profile_id,
      profile_username,
      profile_avatar,
      message_text,
      random_coin,
      random_trade_type,
      random_entry,
      random_exit,
      random_pnl,
      random_pnl_percent,
      random_leverage,
      NULL,
      random_likes,
      random_comments,
      random_shares,
      random_is_bullish,
      random_timestamp
    );
    
  END LOOP;
END;
$$;

-- Generate 5000 social posts
DELETE FROM social_posts;

DO $$
BEGIN
  FOR i IN 1..50 LOOP
    PERFORM generate_random_social_posts();
  END LOOP;
END $$;
