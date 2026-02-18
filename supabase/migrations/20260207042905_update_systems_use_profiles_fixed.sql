/*
  # Update Existing Systems to Use Anonymous Profiles

  1. Changes
    - Update mining_chat_messages to reference anonymous_profiles
    - Update social_posts to reference anonymous_profiles
    - Update mining_success_feed to reference anonymous_profiles

  2. Migration Strategy
    - Add foreign key columns to existing tables
    - Randomly assign profiles to existing records
    - Update functions to use anonymous_profiles

  3. Security
    - Maintain existing RLS policies
    - Add foreign key constraints
*/

-- Add profile_id to mining_chat_messages
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'mining_chat_messages' AND column_name = 'profile_id'
  ) THEN
    ALTER TABLE mining_chat_messages 
    ADD COLUMN profile_id bigint REFERENCES anonymous_profiles(id);
  END IF;
END $$;

-- Add profile_id to social_posts
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'social_posts' AND column_name = 'profile_id'
  ) THEN
    ALTER TABLE social_posts 
    ADD COLUMN profile_id bigint REFERENCES anonymous_profiles(id);
  END IF;
END $$;

-- Add profile_id to mining_success_feed
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'mining_success_feed' AND column_name = 'profile_id'
  ) THEN
    ALTER TABLE mining_success_feed 
    ADD COLUMN profile_id bigint REFERENCES anonymous_profiles(id);
  END IF;
END $$;

-- Update existing mining_chat_messages with random profiles
UPDATE mining_chat_messages
SET profile_id = (
  SELECT id FROM anonymous_profiles
  ORDER BY random()
  LIMIT 1
)
WHERE profile_id IS NULL;

-- Update existing social_posts with random profiles
UPDATE social_posts
SET profile_id = (
  SELECT id FROM anonymous_profiles
  ORDER BY random()
  LIMIT 1
)
WHERE profile_id IS NULL;

-- Update existing mining_success_feed with random profiles
UPDATE mining_success_feed
SET profile_id = (
  SELECT id FROM anonymous_profiles
  ORDER BY random()
  LIMIT 1
)
WHERE profile_id IS NULL;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_mining_chat_messages_profile_id ON mining_chat_messages(profile_id);
CREATE INDEX IF NOT EXISTS idx_social_posts_profile_id ON social_posts(profile_id);
CREATE INDEX IF NOT EXISTS idx_mining_success_feed_profile_id ON mining_success_feed(profile_id);

-- Drop the old generate_random_social_posts function and recreate with profile support
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
    -- Get random profile
    SELECT id, username, avatar_url INTO random_profile_id, profile_username, profile_avatar
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

-- Update the mining success feed to use anonymous profiles
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
  profile_avatar text;
  profile_country text;
BEGIN
  -- Get random profile
  SELECT id, username, avatar_url, country 
  INTO random_profile_id, profile_username, profile_avatar, profile_country
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

-- Regenerate mining chat messages with profiles (delete old messages and create new)
DELETE FROM mining_chat_messages;

-- Insert 10,000 chat messages with random profiles
DO $$
DECLARE
  v_withdrawal_msgs text[] := ARRAY[
    'Just withdrew $%s to my wallet! Instant!',
    'Cashed out $%s! This platform is legit!',
    'Withdrew $%s, already in my account!',
    'Successfully withdrew $%s! No issues at all!',
    'Got my $%s withdrawal! Super fast!'
  ];
  v_profit_msgs text[] := ARRAY[
    'My Quantum Miner earned $%s in 24 hours!',
    'Daily profit: $%s! This is insane!',
    'Made $%s today from mining! Best investment!',
    'Earning $%s per day consistently now!',
    'Just hit $%s in profits! Keep going!'
  ];
  v_upgrade_msgs text[] := ARRAY[
    'Just upgraded to ASIC Miner! Profit tripled!',
    'Bought Quantum Datacenter! Best decision ever!',
    'Upgraded to premium! Earnings doubled!',
    'New equipment purchased! ROI in 3 days!',
    'Just got the Fusion Reactor! Earning big now!'
  ];
  v_milestone_msgs text[] := ARRAY[
    'Hit $%s total earnings! Thank you team!',
    'Made $%s in my first week! Unbelievable!',
    'Hit my $%s target today! Dreams do come true!',
    'First $%s earned! Many more to come!',
    'Broke $%s total profit! This is real!'
  ];
  v_tip_msgs text[] := ARRAY[
    'Pro tip: Compound your earnings! Best strategy!',
    'Quantum Datacenter has the best ROI! Just saying!',
    'Start small, scale up! Proven method!',
    'Reinvest at least 50% of profits! Trust me!',
    'Time is money in mining! Start now!'
  ];
  v_celebration_msgs text[] := ARRAY[
    'Today is a good day! $%s earned!',
    'This platform changed my life! $%s and counting!',
    'Who else is making $%s+ daily?',
    'Almost didn''t start! Now at $%s in profit!',
    'Best community ever! We all winning!'
  ];
  v_general_msgs text[] := ARRAY[
    'Anyone else mining with Quantum Datacenter?',
    'What is your daily profit goal?',
    'How long until I can upgrade to ASIC?',
    'Just joined! Any tips for beginners?',
    'The returns are insane! Loving this!'
  ];
  
  v_amount numeric;
  v_level int;
  v_message text;
  v_type text;
  v_is_featured boolean;
  v_created_at timestamptz;
  v_base_time timestamptz;
  i int;
  profile_rec record;
BEGIN
  v_base_time := now() - interval '30 days';

  FOR i IN 1..10000 LOOP
    -- Get random profile
    SELECT id, username, avatar_url, country INTO profile_rec
    FROM anonymous_profiles
    ORDER BY random()
    LIMIT 1;
    
    v_level := 1 + floor(random() * 5);
    v_created_at := v_base_time + (random() * interval '30 days');
    v_type := (ARRAY['withdrawal', 'profit', 'upgrade', 'milestone', 'tip', 'celebration', 'general', 'withdrawal', 'profit', 'profit'])[1 + floor(random() * 10)];

    CASE v_type
      WHEN 'withdrawal' THEN
        v_amount := (50 + random() * 9950)::numeric(10,2);
        v_message := replace(v_withdrawal_msgs[1 + floor(random() * array_length(v_withdrawal_msgs, 1))], '%s', v_amount::text);
        v_is_featured := v_amount > 5000;

      WHEN 'profit' THEN
        v_amount := (20 + random() * 4980)::numeric(10,2);
        v_message := replace(v_profit_msgs[1 + floor(random() * array_length(v_profit_msgs, 1))], '%s', v_amount::text);
        v_is_featured := v_amount > 2000;

      WHEN 'upgrade' THEN
        v_amount := (100 + random() * 4900)::numeric(10,2);
        v_message := v_upgrade_msgs[1 + floor(random() * array_length(v_upgrade_msgs, 1))];
        v_is_featured := false;

      WHEN 'milestone' THEN
        v_amount := (500 + random() * 49500)::numeric(10,2);
        v_message := replace(v_milestone_msgs[1 + floor(random() * array_length(v_milestone_msgs, 1))], '%s', v_amount::text);
        v_is_featured := v_amount > 10000;

      WHEN 'tip' THEN
        v_amount := 0;
        v_message := v_tip_msgs[1 + floor(random() * array_length(v_tip_msgs, 1))];
        v_is_featured := false;

      WHEN 'celebration' THEN
        v_amount := (100 + random() * 9900)::numeric(10,2);
        v_message := replace(v_celebration_msgs[1 + floor(random() * array_length(v_celebration_msgs, 1))], '%s', v_amount::text);
        v_is_featured := v_amount > 5000;

      ELSE
        v_amount := 0;
        v_message := v_general_msgs[1 + floor(random() * array_length(v_general_msgs, 1))];
        v_is_featured := false;
    END CASE;

    INSERT INTO mining_chat_messages (
      profile_id,
      username,
      avatar_url,
      message,
      message_type,
      amount,
      level,
      country,
      is_featured,
      created_at
    ) VALUES (
      profile_rec.id,
      profile_rec.username,
      profile_rec.avatar_url,
      v_message,
      v_type,
      v_amount,
      v_level,
      profile_rec.country,
      v_is_featured,
      v_created_at
    );
  END LOOP;

  RAISE NOTICE 'Successfully generated 10,000 mining chat messages with anonymous profiles';
END $$;
