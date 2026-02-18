/*
  # Luxury Lifestyle Posts System

  1. Changes
    - Add `post_type` column to social_posts (text, winner, luxury)
    - Add `image_url_2` column for second image (luxury items, cars, etc.)
    - Create 25 luxury lifestyle posts with:
      - Big earnings + luxury cars (Mercedes, Lamborghini, Ferrari)
      - Massive trades + cash/villa photos
      - "From 20k to 100k" success stories
    - Authentic feel: people showing off wealth to attract users

  2. Post Types
    - `text`: Regular text post
    - `winner`: Trading winner with 1 image
    - `luxury`: 2 images (earnings screenshot + luxury item)

  3. Security
    - Public read access for all posts
    - User can only insert/update own posts
*/

-- Add new columns to social_posts
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'social_posts' AND column_name = 'post_type'
  ) THEN
    ALTER TABLE social_posts ADD COLUMN post_type text DEFAULT 'text' CHECK (post_type IN ('text', 'winner', 'luxury'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'social_posts' AND column_name = 'image_url_2'
  ) THEN
    ALTER TABLE social_posts ADD COLUMN image_url_2 text;
  END IF;
END $$;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_social_posts_type ON social_posts(post_type);

-- Insert luxury lifestyle posts  
DO $$
DECLARE
  random_profile anonymous_profiles%ROWTYPE;
  post_record RECORD;
BEGIN
  FOR post_record IN (
    SELECT * FROM (VALUES
      ('If $PIPPIN just touch 20$, I will have 100k$ in my wallet 😍🤑 1$ possible I granted this but you guys tell me $PIPPIN 20$ possible 👀🔥 If it''s possible than I buy my mercedes car...', 'PIPPIN', 'long', 10, 614.10, 7.17, '/ber1.jpg', '/ber5.png'),
      ('Just made 250k$ from $BTC futures! 💎 Time to upgrade my ride. New Lamborghini incoming! 🏎️✨', 'BTC', 'long', 20, 250000, 185.5, '/ber2.jpg', '/ber6.jpg'),
      ('$ETH to the moon! 🚀 Turned 30k into 180k in 2 weeks. Ferrari dealership tomorrow 🏎️💰', 'ETH', 'long', 15, 150000, 215.8, '/ber3.jpg', '/ber7.jpg'),
      ('Sold my $SOL position at perfect timing. 420k$ profit! New penthouse paid in full 🏙️💎', 'SOL', 'long', 25, 420000, 328.4, '/ber4.jpg', '/ber8.jpg'),
      ('$BNB made me rich! From 15k to 200k in one month. Porsche 911 Turbo ordered 🚗💨', 'BNB', 'long', 12, 185000, 412.7, '/ber9.jpg', '/ber10.jpg'),
      ('I told you about $DOGE! 850k$ profit now. Villa with ocean view incoming 🏖️💰', 'DOGE', 'long', 30, 850000, 627.3, '/ber11.jpg', '/ber12.jpg'),
      ('$ADA long position = 95k$ gain. Mercedes AMG GT ordered today! 🚗✨', 'ADA', 'long', 18, 95000, 156.2, '/ber13.jpg', '/ber14.jpg'),
      ('Just closed $AVAX trade. 340k$ profit! Rolex collection time ⌚💎', 'AVAX', 'long', 22, 340000, 278.9, '/ber15.jpg', '/ber16.jpg'),
      ('$MATIC made me millionaire! 1.2M$ total gains. New yacht arriving next month ⛵💰', 'MATIC', 'long', 50, 1200000, 845.6, '/ber17.jpg', '/ber18.jpg'),
      ('From 25k to 380k with $LINK. Range Rover Sport on the way! 🚙✨', 'LINK', 'long', 28, 355000, 492.1, '/ber19.jpg', '/ber20.jpg'),
      ('$UNI pump gave me 520k$. Private jet charter membership activated ✈️💎', 'UNI', 'long', 35, 520000, 318.7, '/ber21.jpg', '/ber22.jpg'),
      ('$DOT to 100$! Already made 280k$. Lamborghini Urus coming! 🚗🔥', 'DOT', 'long', 19, 280000, 234.5, '/ber23.jpg', '/ber24.jpg'),
      ('Holding $ATOM paid off. 195k$ profit = New Tesla Model X Plaid 🚗⚡', 'ATOM', 'long', 16, 195000, 287.3, '/ber25.jpg', '/ber26.jpg'),
      ('$XRP lawsuit win = 670k$ gains for me. Penthouse + Ferrari combo! 🏢🏎️', 'XRP', 'long', 42, 670000, 512.8, '/ber27.jpg', '/ber28.jpg'),
      ('$LTC halving trade: 145k$ profit. Porsche Cayenne Turbo incoming! 🚙💨', 'LTC', 'long', 14, 145000, 198.6, '/ber29.jpg', '/ber30.jpg'),
      ('$TRX staking + futures = 890k$ total. Mansion with pool paid! 🏰💎', 'TRX', 'long', 48, 890000, 673.2, '/ber31.jpg', '/ber32.jpg'),
      ('Started with 10k, now sitting at 450k thanks to $BCH. Audi R8 here I come! 🚗✨', 'BCH', 'long', 31, 440000, 589.4, '/ber33.jpg', '/ber34.jpg'),
      ('$EOS bounce gave me 180k$. Rolex Daytona collection growing ⌚💰', 'EOS', 'long', 17, 180000, 267.1, '/ber35.jpg', '/ber36.jpg'),
      ('$XLM to the stars! 240k$ profit. Beach house in Miami closing soon 🏖️🏠', 'XLM', 'long', 21, 240000, 312.5, '/ber37.jpg', '/ber38.jpg'),
      ('$FTM season started! Already up 310k$. McLaren 720S ordered! 🏎️🔥', 'FTM', 'long', 26, 310000, 428.9, '/ber39.jpg', '/ber40.jpg'),
      ('$NEAR protocol making me rich. 425k$ gains. New Bentley Continental GT 🚗💎', 'NEAR', 'long', 33, 425000, 518.7, '/ber41.jpg', '/ber42.jpg'),
      ('$ALGO DeFi plays = 165k$ profit. Mercedes G-Wagon ordered today! 🚙✨', 'ALGO', 'long', 15, 165000, 223.4, '/ber43.jpg', '/ber44.jpg'),
      ('$VET supply chain boom. 580k$ total gains. Villa in Italy purchased 🏛️💰', 'VET', 'long', 39, 580000, 634.8, '/ber45.jpg', '/ber46.jpg'),
      ('Took profit on $ICP at 720k$. Private island investment next! 🏝️💎', 'ICP', 'long', 51, 720000, 782.3, '/ber47.jpg', '/ber48.jpg'),
      ('$HBAR enterprise adoption = 290k$ for me. Lamborghini Huracán incoming 🏎️✨', 'HBAR', 'long', 24, 290000, 376.2, '/ber49.jpg', '/ber50.jpg')
    ) AS t(content, coin_symbol, trade_type, leverage, profit_loss, profit_loss_percent, image_url, image_url_2)
  ) LOOP
    SELECT * INTO random_profile FROM anonymous_profiles ORDER BY random() LIMIT 1;
    
    INSERT INTO social_posts (
      profile_id, username, avatar_url, content, coin_symbol, trade_type, leverage, 
      entry_price, exit_price, profit_loss, profit_loss_percent, image_url, image_url_2, 
      post_type, likes_count, comments_count, shares_count, is_bullish, created_at
    ) VALUES (
      random_profile.id,
      random_profile.username,
      random_profile.avatar_url,
      post_record.content,
      post_record.coin_symbol,
      post_record.trade_type,
      post_record.leverage,
      0,
      0,
      post_record.profit_loss,
      post_record.profit_loss_percent,
      post_record.image_url,
      post_record.image_url_2,
      'luxury',
      floor(random() * 500 + 50)::int,
      floor(random() * 100 + 10)::int,
      floor(random() * 50 + 5)::int,
      true,
      NOW() - (random() * interval '30 days')
    );
  END LOOP;
END $$;