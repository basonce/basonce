/*
  # Create 240 Social Posts - Batch 1: 80 Luxury/Wealth Proof Posts

  ## Overview
  Creates 80 luxury "wealth proof" posts showing:
  - Withdrawal screenshots + bank cards
  - Cash money stacks + trading screens
  - ATM photos + profit confirmations
  - Expensive purchases funded by crypto
  
  ## Distribution
  - Every 3rd post in the feed will be a wealth proof post
  - Natural, realistic content - not over the top
  - Mix of English casual style
  
  ## Image Pairs
  - image_url: Trading screen / withdrawal confirmation
  - image_url_2: Car, cash, card, luxury item photo
*/

DELETE FROM social_posts WHERE post_type IN ('luxury', 'winner');

DO $$
DECLARE
  rp anonymous_profiles%ROWTYPE;
  pr RECORD;
BEGIN
  FOR pr IN (
    SELECT * FROM (VALUES
      ('Just withdrew 50,000 USDT to my bank account 💰💳 Crypto gains hitting different when you see it in fiat! Time to enjoy life', 'USDT', 50000, '/ber1.jpg', '/ber2.jpg'),
      ('Cashed out 120k profits today 💵 From trading to my bank account. This is why I love crypto! Living the dream', 'BTC', 120000, '/ber3.jpg', '/ber4.jpg'),
      ('From trading to reality 💳 Withdrew 85k USDT this morning. Crypto changed my life fr. Keep grinding everyone', 'USDT', 85000, '/ber5.png', '/ber6.jpg'),
      ('150k USDT straight to my bank 💰 Started with 5k six months ago. Crypto is real guys! Time to celebrate', 'BTC', 150000, '/ber7.jpg', '/ber8.jpg'),
      ('Weekly withdrawal complete 💵 Took out 75k USDT profits. Crypto pays better than any job! Keep trading smart', 'USDT', 75000, '/ber9.jpg', '/ber10.jpg'),
      ('200k in cash feels amazing 💵 Just converted my crypto gains to fiat. Started from the bottom now we here', 'ETH', 200000, '/ber11.jpg', '/ber12.jpg'),
      ('Hit the ATM today 💰 Withdrew 95k USDT profits. Crypto to cash never felt so good! Keep hustling', 'BTC', 95000, '/ber13.jpg', '/ber14.jpg'),
      ('Secured the bag 💼 180k USDT withdrawal processed. Crypto changed my life in 8 months! Dreams do come true', 'USDT', 180000, '/ber15.jpg', '/ber16.jpg'),
      ('From screen to bank account 💰 Just withdrew 110k USDT. Trading crypto full-time now! This is the life', 'BTC', 110000, '/ber17.jpg', '/ber18.jpg'),
      ('Payday from crypto 💵 Cashed out 65k USDT to celebrate. Started with 2k, now living different! Keep grinding', 'ETH', 65000, '/ber19.jpg', '/ber20.jpg'),
      ('Just hit withdraw button on 250k USDT 💰 Account balance looking crazy right now. Hard work pays off', 'BTC', 250000, '/ber21.jpg', '/ber22.jpg'),
      ('Another 90k withdrawal 💳 My banker probably thinks I won the lottery at this point lol', 'USDT', 90000, '/ber23.jpg', '/ber24.jpg'),
      ('320k profits cashed out 💵 New Mercedes ordered, new apartment signed. Crypto life is real', 'BTC', 320000, '/ber25.jpg', '/ber26.jpg'),
      ('Just sent 45k USDT to my card 💳 Small withdrawal but consistent profits are the key. Stack and cash out', 'USDT', 45000, '/ber27.jpg', '/ber28.jpg'),
      ('500k total withdrawals this month 💰 I still can not believe this is my life now. Trading changed everything', 'BTC', 500000, '/ber29.jpg', '/ber30.jpg'),
      ('Took 130k profit off the table 💵 Ferrari deposit paid. Dreams becoming reality step by step', 'ETH', 130000, '/ber31.jpg', '/ber32.jpg'),
      ('Weekend withdrawal: 70k USDT 💳 Living proof that crypto trading works if you put in the effort', 'USDT', 70000, '/ber33.jpg', '/ber34.jpg'),
      ('Just withdrew 165k USDT 💰 My wife still does not believe me when I show her the balance. Crypto is wild', 'BTC', 165000, '/ber35.jpg', '/ber36.jpg'),
      ('Cashed out 55k today 💵 Not the biggest withdrawal but consistency is key. Small wins add up to big gains', 'USDT', 55000, '/ber37.jpg', '/ber38.jpg'),
      ('410k profits realized 💰 Lambo deposit done. Never thought I would say that. Crypto made it possible', 'BTC', 410000, '/ber39.jpg', '/ber40.jpg'),
      ('Monthly withdrawal: 88k USDT 💳 This is what financial freedom looks like. No boss, no alarm clock', 'USDT', 88000, '/ber41.jpg', '/ber42.jpg'),
      ('Just converted 280k to fiat 💵 Bank called to verify the transfer lol. Yes it is real money from crypto', 'ETH', 280000, '/ber43.jpg', '/ber44.jpg'),
      ('35k withdrawal processed 💳 Small but steady. Building wealth one trade at a time', 'USDT', 35000, '/ber45.jpg', '/ber46.jpg'),
      ('195k USDT to my account 💰 Penthouse deposit paid. Crypto really does change lives if you commit', 'BTC', 195000, '/ber47.jpg', '/ber48.jpg'),
      ('Withdrew 140k today 💵 New Porsche money right there. Hard to believe this started from a 3k account', 'BTC', 140000, '/ber49.jpg', '/ber50.jpg'),
      ('60k cashed out 💳 Took the wife shopping, she deserves it. Crypto profits hitting the real world', 'USDT', 60000, '/ber1.jpg', '/ber6.jpg'),
      ('Just moved 220k to my bank 💰 The withdrawal notification is my new favorite sound', 'ETH', 220000, '/ber2.jpg', '/ber8.jpg'),
      ('Another day another withdrawal. 105k USDT 💵 This is becoming routine and I love it', 'BTC', 105000, '/ber3.jpg', '/ber10.jpg'),
      ('Secured 480k in profits 💰 Private jet membership activated. This crypto game is unreal', 'BTC', 480000, '/ber4.jpg', '/ber12.jpg'),
      ('42k withdrawal 💳 Paying off my student loans with crypto gains. Financial freedom loading', 'USDT', 42000, '/ber5.png', '/ber14.jpg'),
      ('Just withdrew 175k USDT 💰 Range Rover ordered. From broke to this in under a year', 'BTC', 175000, '/ber7.jpg', '/ber16.jpg'),
      ('Cash out day! 98k USDT 💵 My family thinks I am doing something illegal lol. No just trading', 'USDT', 98000, '/ber9.jpg', '/ber18.jpg'),
      ('350k total realized gains 💰 Villa in Turkey under contract. Crypto made the impossible possible', 'ETH', 350000, '/ber11.jpg', '/ber20.jpg'),
      ('Withdrew 78k USDT today 💳 Watch collection growing. Rolex Submariner incoming', 'USDT', 78000, '/ber13.jpg', '/ber22.jpg'),
      ('600k withdrawal processed 💰 I literally could not sleep last night. Life changing money from crypto', 'BTC', 600000, '/ber15.jpg', '/ber24.jpg'),
      ('Another 115k to the bank 💵 My accountant asks me every time. Yes it is still from crypto', 'BTC', 115000, '/ber17.jpg', '/ber26.jpg'),
      ('Just cashed 185k USDT 💳 New G-Wagon ordered in black. Childhood dream fulfilled', 'USDT', 185000, '/ber19.jpg', '/ber28.jpg'),
      ('Quick 52k withdrawal 💰 Restaurant dinner tonight, celebrating another profitable month', 'USDT', 52000, '/ber21.jpg', '/ber30.jpg'),
      ('Realized 290k in profits 💵 Beach house deposit done. Trading from the ocean next month', 'ETH', 290000, '/ber23.jpg', '/ber32.jpg'),
      ('Just withdrew 160k 💳 My old coworkers still think I am crazy for quitting my job for crypto', 'BTC', 160000, '/ber25.jpg', '/ber34.jpg'),
      ('445k profits to my account 💰 Yacht club membership purchased. Living the life I always wanted', 'BTC', 445000, '/ber27.jpg', '/ber36.jpg'),
      ('83k cashed out today 💵 Reinvesting some, enjoying some. Balance is everything in this game', 'USDT', 83000, '/ber29.jpg', '/ber38.jpg'),
      ('Just moved 240k USDT 💳 New Tesla Model S Plaid delivered yesterday. Electric dreams', 'ETH', 240000, '/ber31.jpg', '/ber40.jpg'),
      ('Quick 38k withdrawal 💰 Nothing crazy but honest work. Every withdrawal adds up', 'USDT', 38000, '/ber33.jpg', '/ber42.jpg'),
      ('Withdrew 155k today 💵 Got myself a nice watch. Patek Philippe. Crypto money different', 'BTC', 155000, '/ber35.jpg', '/ber44.jpg'),
      ('520k total withdrawals 💰 Private pool villa in Bali booked for 3 months. Trading from paradise', 'BTC', 520000, '/ber37.jpg', '/ber46.jpg'),
      ('72k USDT cashed 💳 Paying for my mom house renovation. She does not know it is from crypto yet', 'USDT', 72000, '/ber39.jpg', '/ber48.jpg'),
      ('Just hit 300k withdrawal 💰 BMW M8 Competition ordered. From dreaming to driving', 'BTC', 300000, '/ber41.jpg', '/ber50.jpg'),
      ('Cashed out 125k profits 💵 Gold chain and a new wardrobe. Treating myself because I earned it', 'ETH', 125000, '/ber43.jpg', '/ber2.jpg'),
      ('48k quick withdrawal 💳 Small consistent gains over time beat any get rich quick scheme', 'USDT', 48000, '/ber45.jpg', '/ber4.jpg'),
      ('Just withdrew 210k 💰 Dubai apartment deposit paid. Moving to the city of gold next year', 'BTC', 210000, '/ber47.jpg', '/ber6.jpg'),
      ('190k USDT to my bank 💵 Audi RS7 sitting in my garage now. Never gets old', 'BTC', 190000, '/ber49.jpg', '/ber8.jpg'),
      ('Cash out: 67k USDT 💳 Treating the family to a vacation in Maldives. They deserve it', 'USDT', 67000, '/ber1.jpg', '/ber10.jpg'),
      ('380k realized profits 💰 Mansion tour tomorrow. Picking my new home, crypto funded', 'ETH', 380000, '/ber3.jpg', '/ber12.jpg'),
      ('Just withdrew 102k 💵 Business class flights from now on. Economy seats are history', 'BTC', 102000, '/ber5.png', '/ber14.jpg'),
      ('550k total gains cashed 💰 Starting my own investment fund. From trader to fund manager', 'BTC', 550000, '/ber7.jpg', '/ber16.jpg'),
      ('58k withdrawal done 💳 New MacBook Pro and home office setup. Trading station upgrade', 'USDT', 58000, '/ber9.jpg', '/ber18.jpg'),
      ('270k to my account 💰 Rolex Daytona purchased. The one I have been eyeing for 2 years', 'ETH', 270000, '/ber11.jpg', '/ber20.jpg'),
      ('Just cashed 145k USDT 💵 AMG GT63 on order. 4 door beast. Thanks crypto', 'BTC', 145000, '/ber13.jpg', '/ber22.jpg'),
      ('Quick 33k withdrawal 💳 Nothing flashy just building my savings consistently', 'USDT', 33000, '/ber15.jpg', '/ber24.jpg'),
      ('460k profits withdrawn 💰 Bought a commercial property. Passive income plus trading income', 'BTC', 460000, '/ber17.jpg', '/ber26.jpg'),
      ('88k USDT cashed out 💵 Renovating my apartment. Modern minimalist design. Crypto funded', 'USDT', 88000, '/ber19.jpg', '/ber28.jpg'),
      ('Just withdrew 230k 💳 First class to New York next week. Living like a boss', 'ETH', 230000, '/ber21.jpg', '/ber30.jpg'),
      ('340k realized 💰 Bought land in Montenegro. Building a villa, retirement plan from crypto', 'BTC', 340000, '/ber23.jpg', '/ber32.jpg'),
      ('76k withdrawal processed 💵 New gaming room setup. 4K triple monitor trading station', 'USDT', 76000, '/ber25.jpg', '/ber34.jpg'),
      ('Just moved 420k to bank 💰 Maserati MC20 on order. Dream car since I was a kid', 'BTC', 420000, '/ber27.jpg', '/ber36.jpg'),
      ('Cashed 93k USDT 💳 Gold Rolex for my dad birthday. He cried. This is why I trade', 'USDT', 93000, '/ber29.jpg', '/ber38.jpg'),
      ('200k profit withdrawal 💵 Hired a personal trainer and chef. Health is wealth too', 'ETH', 200000, '/ber31.jpg', '/ber40.jpg'),
      ('Just withdrew 135k 💰 Bentley Continental deposit. Elegance meets crypto money', 'BTC', 135000, '/ber33.jpg', '/ber42.jpg'),
      ('47k quick cash out 💳 Surprise trip for my girlfriend to Paris. She thinks I got a raise at work', 'USDT', 47000, '/ber35.jpg', '/ber44.jpg'),
      ('580k total realized 💰 Two apartments in Istanbul purchased. Building a real estate portfolio', 'BTC', 580000, '/ber37.jpg', '/ber46.jpg'),
      ('108k withdrawal today 💵 Cartier bracelet for the collection. Crypto accessories hitting different', 'ETH', 108000, '/ber39.jpg', '/ber48.jpg'),
      ('62k USDT cashed 💳 Home gym fully equipped now. Crypto funding the lifestyle', 'USDT', 62000, '/ber41.jpg', '/ber50.jpg'),
      ('365k profits to bank 💰 McLaren 720S. The car I said I would never afford. Crypto said otherwise', 'BTC', 365000, '/ber43.jpg', '/ber6.jpg'),
      ('Just withdrew 170k 💵 Penthouse view is insane. 42nd floor overlooking the city. All from trading', 'BTC', 170000, '/ber45.jpg', '/ber8.jpg'),
      ('82k cashed out today 💳 New Hermes bag for wife, new Omega for me. Couple goals funded by crypto', 'USDT', 82000, '/ber47.jpg', '/ber10.jpg'),
      ('255k USDT withdrawal 💰 Art collection growing. Banksy original. Crypto to art, love the journey', 'ETH', 255000, '/ber49.jpg', '/ber12.jpg'),
      ('39k quick withdrawal 💵 Family dinner at Nobu. 12 people, crypto pays. Best feeling ever', 'USDT', 39000, '/ber1.jpg', '/ber14.jpg'),
      ('430k realized gains 💰 Wine cellar installed in new house. 200 bottles. Celebrating properly', 'BTC', 430000, '/ber3.jpg', '/ber16.jpg'),
      ('Just cashed 148k 💳 Designer wardrobe refresh. Louis Vuitton, Gucci, Balenciaga. All from trades', 'BTC', 148000, '/ber5.png', '/ber18.jpg')
    ) AS t(content, coin, amount, img1, img2)
  ) LOOP
    SELECT * INTO rp FROM anonymous_profiles ORDER BY random() LIMIT 1;
    
    INSERT INTO social_posts (
      profile_id, username, avatar_url, content, coin_symbol, trade_type, leverage,
      entry_price, exit_price, profit_loss, profit_loss_percent, image_url, image_url_2,
      post_type, likes_count, comments_count, shares_count, is_bullish, created_at
    ) VALUES (
      rp.id, rp.username, rp.avatar_url, pr.content, pr.coin, 'long', 1,
      0, 0, pr.amount, 0, pr.img1, pr.img2,
      'luxury',
      floor(random() * 900 + 50)::int,
      floor(random() * 200 + 10)::int,
      floor(random() * 100 + 5)::int,
      true,
      NOW() - (random() * interval '14 days')
    );
  END LOOP;
END $$;