/*
  # Fix Avatar URLs - Use DiceBear API Instead of Pravatar

  1. Changes
    - Update all avatar URLs to use DiceBear API
    - DiceBear provides free, unlimited avatar generation
    - Each user gets unique avatar based on their ID

  2. DiceBear Styles Used
    - avataaars - Fun, colorful human avatars
    - personas - Professional, realistic avatars
    - lorelei - Female-focused avatars
    - micah - Male-focused avatars
    - bottts - Robot avatars for variety

  3. Format
    - https://api.dicebear.com/7.x/[style]/svg?seed=[unique-id]
*/

-- Update anonymous_profiles with DiceBear avatars
UPDATE anonymous_profiles
SET avatar_url = CASE 
  WHEN id % 5 = 0 THEN 'https://api.dicebear.com/7.x/avataaars/svg?seed=' || id
  WHEN id % 5 = 1 THEN 'https://api.dicebear.com/7.x/personas/svg?seed=' || id
  WHEN id % 5 = 2 THEN 'https://api.dicebear.com/7.x/lorelei/svg?seed=' || id
  WHEN id % 5 = 3 THEN 'https://api.dicebear.com/7.x/micah/svg?seed=' || id
  ELSE 'https://api.dicebear.com/7.x/bottts/svg?seed=' || id
END;

-- Update mining_chat_messages
UPDATE mining_chat_messages
SET avatar_url = (
  SELECT 'https://api.dicebear.com/7.x/avataaars/svg?seed=' || ap.id
  FROM anonymous_profiles ap
  WHERE ap.id = mining_chat_messages.profile_id
);

-- Update social_posts
UPDATE social_posts
SET avatar_url = (
  SELECT 'https://api.dicebear.com/7.x/personas/svg?seed=' || ap.id
  FROM anonymous_profiles ap
  WHERE ap.id = social_posts.profile_id
);

-- Update mining_success_feed
UPDATE mining_success_feed
SET avatar_url = (
  SELECT 'https://api.dicebear.com/7.x/lorelei/svg?seed=' || ap.id
  FROM anonymous_profiles ap
  WHERE ap.id = mining_success_feed.profile_id
);

-- Update mining_discover_users
UPDATE mining_discover_users
SET avatar_url = (
  SELECT 'https://api.dicebear.com/7.x/micah/svg?seed=' || ap.id
  FROM anonymous_profiles ap
  WHERE ap.id = mining_discover_users.profile_id
);

-- Update the add_mining_success_to_feed function to use DiceBear
CREATE OR REPLACE FUNCTION add_mining_success_to_feed(
  p_eq_amount numeric,
  p_usd_value numeric
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  random_profile_id bigint;
  profile_username text;
  profile_country text;
  profile_avatar text;
BEGIN
  -- Get random profile
  SELECT id, username, country, 'https://api.dicebear.com/7.x/avataaars/svg?seed=' || id
  INTO random_profile_id, profile_username, profile_country, profile_avatar
  FROM anonymous_profiles
  ORDER BY random()
  LIMIT 1;
  
  -- Insert into success feed
  INSERT INTO mining_success_feed (profile_id, username, avatar_url, country, eq_amount, usd_value, created_at)
  VALUES (
    random_profile_id,
    profile_username,
    profile_avatar,
    profile_country,
    p_eq_amount,
    p_usd_value,
    now()
  );
  
  -- Keep only last 100 records
  DELETE FROM mining_success_feed
  WHERE id NOT IN (
    SELECT id FROM mining_success_feed
    ORDER BY created_at DESC
    LIMIT 100
  );
END;
$$;

-- Update the generate_random_social_posts function to use DiceBear
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
  message_text text;
  random_likes integer;
  random_timestamp timestamptz;
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
    WHERE futures_enabled = true
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
      
      message_text := (ARRAY[
        'Just closed ' || random_coin || ' long at ' || random_leverage || 'x! +$' || random_pnl || ' profit',
        'Easy ' || random_leverage || 'x win on ' || random_coin || '! Entry: $' || random_entry || ' Exit: $' || random_exit,
        random_coin || ' to the moon! ' || random_leverage || 'x leverage made me $' || random_pnl,
        'Called it! ' || random_coin || ' long ' || random_leverage || 'x = $' || random_pnl || ' profit',
        'Another win with ' || random_coin || '! ' || random_leverage || 'x long closed at $' || random_exit
      ])[floor(random() * 5 + 1)];
      random_likes := floor(random() * 200 + 50);
      
    ELSIF random_post_type = 'loss' THEN
      random_pnl := round((random() * -800 - 100)::numeric, 2);
      random_leverage := (ARRAY[50, 75, 100, 125])[floor(random() * 4 + 1)];
      
      message_text := (ARRAY[
        'Got liquidated on ' || random_coin || ' ' || random_leverage || 'x... -$' || abs(random_pnl),
        random_coin || ' short got stopped out. -$' || abs(random_pnl) || ' loss',
        'Overleveraged ' || random_coin || ' at ' || random_leverage || 'x. Lost $' || abs(random_pnl),
        'Wrong direction on ' || random_coin || '. -$' || abs(random_pnl) || ' lesson learned'
      ])[floor(random() * 4 + 1)];
      random_likes := floor(random() * 30 + 5);
      
    ELSIF random_post_type = 'analysis' THEN
      message_text := (ARRAY[
        random_coin || ' looking bullish on the 4h chart. Potential long setup',
        'Watch ' || random_coin || ' at $' || round((random() * 50000 + 1000)::numeric, 2) || ' support level',
        random_coin || ' breaking resistance! Time to enter?',
        'Technical analysis: ' || random_coin || ' forming a bullish pattern',
        random_coin || ' volume increasing. Big move incoming?',
        'RSI oversold on ' || random_coin || '. Potential bounce',
        random_coin || ' trend reversal? Check your positions'
      ])[floor(random() * 7 + 1)];
      random_likes := floor(random() * 80 + 20);
      
    ELSE -- question
      message_text := (ARRAY[
        'Should I long or short ' || random_coin || ' right now?',
        'What is your ' || random_coin || ' price prediction?',
        'Is ' || random_coin || ' a good buy at current price?',
        'Anyone trading ' || random_coin || ' today?',
        'Best leverage for ' || random_coin || ' in this market?',
        'Thoughts on ' || random_coin || ' for tomorrow?'
      ])[floor(random() * 6 + 1)];
      random_likes := floor(random() * 40 + 5);
    END IF;
    
    -- Random timestamp within last 7 days
    random_timestamp := now() - (random() * interval '7 days');
    
    -- Insert the post
    INSERT INTO social_posts (profile_id, username, avatar_url, content, likes, created_at)
    VALUES (
      random_profile_id,
      profile_username,
      profile_avatar,
      message_text,
      random_likes,
      random_timestamp
    );
    
  END LOOP;
END;
$$;
