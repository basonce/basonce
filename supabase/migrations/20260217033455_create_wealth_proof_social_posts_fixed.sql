/*
  # Wealth Proof Social Posts System

  ## Overview
  Creates a realistic social feed where every 3rd post shows "wealth proof" 
  (money withdrawal, bank cards, cash, ATM screenshots) to create FOMO.
  
  ## Post Distribution
  - **Normal Trading Posts (66%)**: Regular coin analysis, trade updates, market sentiment
  - **Wealth Proof Posts (34%)**: Screenshots of withdrawals + bank cards/cash/ATM photos
  
  ## Changes
  1. Delete old luxury posts (all car/villa focused)
  2. Create 30 new posts:
     - 20 normal trading posts (coin mentions, TA, positions)
     - 10 wealth proof posts (withdrawal proof + cash/card images)
  3. Posts are ordered naturally to appear every ~3 posts
  
  ## Wealth Proof Post Examples
  - "Just withdrew 50k USDT 💰💳" + [trade screen, bank card]
  - "Cashed out profits. 120k in my account now 💵" + [withdrawal screen, cash stack]
  - "From crypto to reality. 85k secured ✅" + [phone screen, ATM money]
  
  ## Normal Trading Post Examples  
  - "Just bought 10M $LUNC coin 🪙 We saw $LUNC touching 96$ in 2022 🚀"
  - "$BTC looking bullish! Opening 50k long position 📈"
  - "$ETH breaking resistance. This is the moment! 💎"
  
  ## Security
  - Public read access for all posts
  - Users can only modify their own posts
*/

-- Delete old luxury posts
DELETE FROM social_posts WHERE post_type = 'luxury';

-- Insert new mixed posts (normal trading + wealth proof)
DO $$
DECLARE
  random_profile anonymous_profiles%ROWTYPE;
  post_record RECORD;
BEGIN
  FOR post_record IN (
    SELECT * FROM (VALUES
      -- NORMAL TRADING POST 1
      ('Just bought 10M $LUNC coin 🪙 We saw $LUNC touching 96$ in 2022 🚀 Don''t forget this, $LUNC will reach 100$ again 📈 Keep buying $LUNC', 'LUNC', 'long', 10, 12500, 45.2, '/ber1.jpg', '/ber2.jpg', 'luxury'),
      
      -- NORMAL TRADING POST 2  
      ('$BTC looking extremely bullish! 📊 Just opened 50k position at 67,800$. Target: 75k! This is not financial advice but... 🚀💎', 'BTC', 'long', 5, 48000, 67.3, NULL, NULL, 'text'),
      
      -- WEALTH PROOF POST 1
      ('Just withdrew 50,000 USDT to my bank account 💰💳 Crypto gains hitting different when you see it in fiat 🤑 Time to enjoy life!', 'USDT', 'long', 1, 50000, 0, '/ber3.jpg', '/ber4.jpg', 'luxury'),
      
      -- NORMAL TRADING POST 3
      ('$ETH breakout incoming! 💎 Chart looking perfect for 4,500$ run. Opened 100k position with 10x leverage. Let''s go! 📈⚡', 'ETH', 'long', 10, 85000, 124.5, NULL, NULL, 'text'),
      
      -- NORMAL TRADING POST 4
      ('$SOL to 200$ is inevitable 🔥 Just loaded my bags heavy. If you''re not in $SOL, you''re missing out big time! 🚀💰', 'SOL', 'long', 15, 65000, 89.7, '/ber7.jpg', NULL, 'winner'),
      
      -- WEALTH PROOF POST 2
      ('Cashed out 120k profits today 💵🏦 From trading to my bank account. This is why I love crypto! Living the dream 😎💰', 'BTC', 'long', 1, 120000, 0, '/ber8.jpg', '/ber9.jpg', 'luxury'),
      
      -- NORMAL TRADING POST 5
      ('$PEPE holders, we''re going to make it! 🐸 Just added 500M more tokens. Meme season is back and $PEPE leading the charge! 📈💎', 'PEPE', 'long', 20, 42000, 156.8, NULL, NULL, 'text'),
      
      -- NORMAL TRADING POST 6
      ('$DOGE pump incoming! 🐕 Elon just tweeted again. Opened massive long position. This is going to 1$ eventually! 🚀🌙', 'DOGE', 'long', 12, 38000, 78.4, '/ber12.jpg', NULL, 'winner'),
      
      -- WEALTH PROOF POST 3
      ('From trading to reality 💳✨ Withdrew 85k USDT this morning. Crypto changed my life fr 🤑 Keep grinding everyone!', 'USDT', 'long', 1, 85000, 0, '/ber13.jpg', '/ber14.jpg', 'luxury'),
      
      -- NORMAL TRADING POST 7
      ('$BNB about to explode! 🔥 BSC ecosystem growing fast. Just bought 200 BNB at 610$. Target: 850$ this month! 📊💰', 'BNB', 'long', 8, 55000, 92.1, NULL, NULL, 'text'),
      
      -- NORMAL TRADING POST 8
      ('$AVAX winter is over! ❄️ Just opened 75k long position. This coin is undervalued af. Easy 3x from here! 🚀💎', 'AVAX', 'long', 15, 68000, 145.7, '/ber17.jpg', NULL, 'winner'),
      
      -- WEALTH PROOF POST 4
      ('150k USDT straight to my bank 💰🏦 Started with 5k six months ago. Crypto is real guys! Time to celebrate 🍾💎', 'BTC', 'long', 1, 150000, 0, '/ber18.jpg', '/ber19.jpg', 'luxury'),
      
      -- NORMAL TRADING POST 9
      ('$MATIC polygon season starting! 🟣 Just loaded 50k MATIC tokens. This is going to pump hard! Don''t say I didn''t warn you 📈🚀', 'MATIC', 'long', 10, 32000, 67.9, NULL, NULL, 'text'),
      
      -- NORMAL TRADING POST 10
      ('$LINK marines assemble! ⛓️ Just opened 40k position on $LINK. Chainlink to 50$ is programmed! 💎📈', 'LINK', 'long', 7, 45000, 88.3, '/ber22.jpg', NULL, 'winner'),
      
      -- WEALTH PROOF POST 5
      ('Weekly withdrawal complete 💵💳 Took out 75k USDT profits. Crypto pays better than any job! Keep trading smart 🤑✨', 'USDT', 'long', 1, 75000, 0, '/ber23.jpg', '/ber24.jpg', 'luxury'),
      
      -- NORMAL TRADING POST 11
      ('$ADA finally waking up! 💙 Cardano breaking out of accumulation zone. Opened 60k long. Target: 1.50$! 🚀📊', 'ADA', 'long', 12, 52000, 98.6, NULL, NULL, 'text'),
      
      -- NORMAL TRADING POST 12
      ('$DOT parachain auctions creating hype! 🔴 Just bought heavy at 28$. Polkadot to 50$ easy! This is the way! 💎🚀', 'DOT', 'long', 9, 48000, 82.4, '/ber27.jpg', NULL, 'winner'),
      
      -- WEALTH PROOF POST 6
      ('200k in cash feels amazing 💵💎 Just converted my crypto gains to fiat. Started from the bottom now we here! 🤑🏦', 'ETH', 'long', 1, 200000, 0, '/ber28.jpg', '/ber29.jpg', 'luxury'),
      
      -- NORMAL TRADING POST 13
      ('$XRP lawsuit victory rally! ⚖️ Opened 100k position at 0.52$. This is going to 2$ minimum! History in the making! 📈💰', 'XRP', 'long', 15, 72000, 134.8, NULL, NULL, 'text'),
      
      -- NORMAL TRADING POST 14
      ('$SHIB army strong! 🐕 Just added 10 billion tokens. Shiba Inu to 0.001$ is not a meme anymore! Burn rate accelerating! 🔥🚀', 'SHIB', 'long', 25, 38000, 245.7, '/ber32.jpg', NULL, 'winner'),
      
      -- WEALTH PROOF POST 7
      ('Hit the ATM today 💰🤑 Withdrew 95k USDT profits. Crypto to cash never felt so good! Keep hustling traders! 💳✨', 'BTC', 'long', 1, 95000, 0, '/ber33.jpg', '/ber34.jpg', 'luxury'),
      
      -- NORMAL TRADING POST 15
      ('$UNI DeFi king! 🦄 Uniswap about to pump hard. Just opened 55k long position. Target: 25$! DEX season incoming! 📊💎', 'UNI', 'long', 8, 58000, 96.2, NULL, NULL, 'text'),
      
      -- NORMAL TRADING POST 16
      ('$FTM fantom opera! 👻 Just bought 100k FTM tokens at 2.10$. This is criminally undervalued! Easy 5x from here! 🚀💰', 'FTM', 'long', 12, 44000, 118.5, '/ber37.jpg', NULL, 'winner'),
      
      -- WEALTH PROOF POST 8
      ('Secured the bag 💼💳 180k USDT withdrawal processed. Crypto changed my life in 8 months! Dreams do come true 🤑💎', 'USDT', 'long', 1, 180000, 0, '/ber38.jpg', '/ber39.jpg', 'luxury'),
      
      -- NORMAL TRADING POST 17
      ('$NEAR protocol heating up! 🔥 Just opened 65k position at 18$. Near to 40$ is inevitable! AI narrative strong! 📈🚀', 'NEAR', 'long', 10, 62000, 128.4, NULL, NULL, 'text'),
      
      -- NORMAL TRADING POST 18
      ('$ATOM cosmos ecosystem booming! ⚛️ Opened 50k long on $ATOM. IBC growing fast. This is going to 100$! 💎📊', 'ATOM', 'long', 7, 54000, 87.9, '/ber42.jpg', NULL, 'winner'),
      
      -- WEALTH PROOF POST 9
      ('From screen to bank account 💰🏦 Just withdrew 110k USDT. Trading crypto full-time now! This is the life 🤑💳', 'BTC', 'long', 1, 110000, 0, '/ber43.jpg', '/ber44.jpg', 'luxury'),
      
      -- NORMAL TRADING POST 19
      ('$ALGO algorand pumping! 🟢 Just loaded 80k ALGO tokens. Pure tech foundation is underrated. Target: 5$! 🚀💰', 'ALGO', 'long', 9, 48000, 94.3, NULL, NULL, 'text'),
      
      -- NORMAL TRADING POST 20
      ('$LTC halving coming! 🪙 Litecoin always delivers. Just opened 70k position at 180$. Target: 350$! OG coin! 📈💎', 'LTC', 'long', 6, 51000, 76.8, '/ber47.jpg', NULL, 'winner'),
      
      -- WEALTH PROOF POST 10
      ('Payday from crypto 💵💎 Cashed out 65k USDT to celebrate. Started with 2k, now living different! Keep grinding 🤑✨', 'ETH', 'long', 1, 65000, 0, '/ber48.jpg', '/ber49.jpg', 'luxury')
      
    ) AS t(content, coin_symbol, trade_type, leverage, profit_loss, profit_loss_percent, image_url, image_url_2, post_type)
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
      post_record.post_type,
      floor(random() * 800 + 50)::int,
      floor(random() * 150 + 10)::int,
      floor(random() * 80 + 5)::int,
      true,
      NOW() - (random() * interval '7 days')
    );
  END LOOP;
END $$;