/*
  # Diverse Social Posts - Personal Stories & Events

  1. New Posts
    - 80 natural personal story posts (earnings, life updates)
    - 25 event/announcement posts (competitions, promotions)
  
  2. Features
    - Personal posts: natural text about trading life, no images
    - Event posts: announcement style with promotional content
*/

DO $$
DECLARE
  v_profile RECORD;
  v_coins TEXT[] := ARRAY['BTC', 'ETH', 'SOL', 'BNB', 'XRP', 'DOGE', 'ADA', 'AVAX', 'LINK', 'DOT', 'UNI', 'ATOM', 'ARB', 'OP', 'NEAR', 'AAVE', 'INJ', 'SUI', 'JUP', 'PEPE'];
  v_personal TEXT[];
  v_events TEXT[];
  v_coin TEXT;
  v_i INTEGER;
  v_tags JSONB;
  v_tag_coins TEXT[];
  v_amount TEXT;
BEGIN
  v_personal := ARRAY[
    'This week I earned $AMOUNT from my $COIN and ETH positions. Finally going to pay off my credit card. Small wins add up!',
    'Just closed my $COIN position for $AMOUNT profit. Taking the family out for dinner tonight. Work-life balance matters.',
    'Started with $500 three months ago. Portfolio just hit $AMOUNT. Patience and proper risk management really do pay off.',
    'First time breaking five figures in a single week. $AMOUNT realized. Not selling everything though - keeping core positions.',
    'My DCA strategy on $COIN finally paying off. Up significantly since I started 6 months ago. Time in the market wins.',
    '$AMOUNT withdrawn to my bank account today. First real profit I''m taking out. Going to reinvest 60%% and save 40%%.',
    'Woke up to my $COIN stop-loss hitting in profit. $AMOUNT secured while I was sleeping. Set your orders and rest easy.',
    'After 8 months of consistent trading, I can finally say this is sustainable income. $AMOUNT this month alone.',
    'Paid my rent with trading profits for the first time. $AMOUNT from $COIN futures this week. Feels surreal.',
    'My portfolio allocation strategy is working. 50%% in BTC/ETH, rest in quality alts. Up $AMOUNT overall this month.',
    'Closed all my positions before the weekend. $AMOUNT profit locked in. Never hold leveraged positions over weekends.',
    'The $COIN trade I was hesitant about turned out to be my best this month. $AMOUNT profit. Trust your analysis.',
    'Took a 2-week break from trading. Came back refreshed and immediately made $AMOUNT. Mental health matters.',
    'My automated grid bot on $COIN has been printing money. $AMOUNT in passive income this week alone.',
    'Finally hit my yearly target of $AMOUNT in trading profits. And we still have months to go. Compounding is magical.',
    'Converted some profits to stablecoins and put them in earn. $AMOUNT generating passive yield while I focus on spot.',
    'Best trade of my career: $COIN long from the bottom. $AMOUNT unrealized. Not closing until target hits.',
    'Lost $800 on Monday, made $AMOUNT by Friday. The key is not letting one bad day define your week.',
    'Just completed 100 consecutive profitable trading days. Average $AMOUNT per day. Consistency over everything.',
    'Moved some profits into a hardware wallet. $AMOUNT safely stored offline. Not your keys, not your crypto.',
    'My $COIN position from last month is still running. $AMOUNT in profit. Sometimes the best trade is doing nothing.',
    'Withdrew $AMOUNT today to buy my first car. Started trading 14 months ago with $1,000. Life-changing.',
    'The market gave me $AMOUNT this week from $COIN scalping. 47 trades, 38 winners. Volume and patience.',
    'Set up a separate savings wallet for trading profits. Already accumulated $AMOUNT in 3 months. Discipline pays.',
    'Today I earned more from one trade than my monthly salary. $AMOUNT from $COIN. Still processing this.',
    'Portfolio rebalancing day. Took $AMOUNT in profits from alts and moved back to BTC/ETH. Risk management.',
    'My copy trading followers are up $AMOUNT combined this month. Helping others succeed feels amazing.',
    'Three losing trades in a row, then one winner that covered everything plus $AMOUNT extra. R/R ratio is everything.',
    'Thanksgiving dinner funded entirely by $COIN trading profits. $AMOUNT this week. Grateful for the markets.',
    'Hit a new personal record: $AMOUNT in a single day from futures. Leverage was only 5x. Big size, small leverage.',
    'Withdrawing $AMOUNT to invest in my education. Trading taught me that investing in yourself has the best ROI.',
    'My $COIN spot bag is up significantly since accumulation. Haven''t sold a single token. Diamond hands actually work for good projects.',
    'After 6 months of learning and paper trading, my first real month ended with $AMOUNT profit. The preparation was worth it.',
    'Just sent $AMOUNT to my parents. They don''t fully understand crypto but they''re happy. That''s all that matters.',
    'Spot trading profits this month: $AMOUNT. No leverage, no stress, just buying dips and selling rips on $COIN.',
    'The $COIN scalping strategy I''ve been testing made $AMOUNT in 3 days. Going to scale up next week.',
    'Realized I don''t need to trade every day. Made $AMOUNT this week from just 4 high-conviction setups.',
    'Portfolio crossed six figures today. Started from $2,500. Most of the gains came from $COIN and patience.',
    'My morning routine: check charts, set alerts, place orders, go to work. Made $AMOUNT today without staring at screens.',
    'This bull market has been good to me. $AMOUNT in realized gains so far. But staying humble and keeping risk tight.',
    'Funded my emergency savings entirely from trading profits. $AMOUNT set aside. Trading responsibly means planning ahead.',
    'Got stopped out on 2 trades but the $COIN winner more than covered losses. Net $AMOUNT positive. Risk management works.',
    'Weekend market review: $AMOUNT in profits this week. Best performers were $COIN and SOL. Setting up for next week now.',
    'Passed my day trading income goal for the month with $AMOUNT total. The key was fewer trades, bigger conviction.',
    'My first full year of profitable trading. Total net profit: $AMOUNT. Countless hours of learning made this possible.',
    'Took profits on my $COIN position today. $AMOUNT secured. Will re-enter on the next pullback to support.',
    'The bear market taught me everything I know. Now in the bull market, I''m finally reaping rewards. $AMOUNT this quarter.',
    'Swing trading $COIN has been incredibly consistent. $AMOUNT over the past 2 weeks. Higher timeframes, lower stress.',
    'I use 80%% of my profits for reinvestment and 20%% for living expenses. Made $AMOUNT this month. System is working.',
    'Finally in a position where trading covers all my bills. $AMOUNT net this month from $COIN and BTC.',
    'What a week. $AMOUNT from futures, $500 from spot, $200 from staking rewards. Multiple income streams in crypto.',
    'Lost my job 8 months ago. Trading is now my full-time income. $AMOUNT this month. Never giving up was the right choice.',
    'The $COIN airdrop plus my trading profits = $AMOUNT this month. Always participate in ecosystem events.',
    'My portfolio is finally diversified enough. $AMOUNT spread across 8 coins. No single position can sink me.',
    'End of month report: $AMOUNT profit. 156 trades. 64%% win rate. Average R/R of 2.3. Slowly improving each month.',
    'Made $AMOUNT from $COIN today and immediately transferred to stablecoin savings. Protect your profits.',
    'Trading from my phone while traveling. Made $AMOUNT from $COIN this week. Location freedom is the real luxury.',
    'Three months of zero withdrawals, all profits reinvested. Account grew from $5k to $AMOUNT. Compound growth is real.',
    'Today marks 1 year since my last blown account. Since then: $AMOUNT in total profits. The turnaround was possible.',
    'My secret to consistency: max 3 trades per day, 1%% risk per trade, and no trading when tired. $AMOUNT this month.'
  ];

  v_events := ARRAY[
    'Futures Trading Competition: Top 100 traders share $50,000 USDT prize pool! Trade any perpetual pair with 10x+ leverage to qualify. Competition runs for 7 days.',
    'New Listing Alert: Trading has opened for the latest addition to our platform. 0%% trading fee for the first 48 hours. Don''t miss the early volatility!',
    'Weekly Trading Tournament Results: Congratulations to all participants! Over 15,000 traders competed. Winners have been notified and prizes distributed.',
    'Flash Promotion: Deposit any amount in the next 24 hours and receive a mystery box reward. Up to $500 in trading vouchers available.',
    'Spot Trading Challenge: Achieve $10,000+ in spot trading volume this week to earn exclusive badges and fee discounts. 5,000 spots remaining.',
    'Copy Trading Event: Follow a Top Trader this month and both of you earn bonus rewards. Up to $200 in shared incentives per pair.',
    'Referral Program Update: Invite friends and earn up to 40%% commission on their trading fees. New tier system with increased rewards.',
    'Learn & Earn Campaign: Complete 5 educational quizzes about DeFi and earn $25 in token rewards. Limited to first 10,000 participants.',
    'Grid Trading Bot Competition: Activate a grid bot with $100+ and compete for $20,000 prize pool. Best performing bots win.',
    'Market Maker Program: Apply to become a market maker and enjoy 0%% maker fees plus VIP perks. Minimum volume requirements apply.',
    'Leverage Trading Workshop: Join our free webinar this Saturday to learn advanced futures strategies from professional traders.',
    'Annual Trading Recap: Check your personalized trading stats for 2025! Total volume, best trades, and comparative rankings available now.',
    'Token Burn Event: 500M tokens will be burned this Friday. Historical data shows significant price impact after previous burns.',
    'Fee Discount Week: All spot trading fees reduced by 25%% for the next 7 days. Stack with VIP discounts for maximum savings.',
    'Demo Trading Contest: Practice with virtual funds and win real prizes! $10,000 prize pool. No risk required.',
    'Staking Rewards Boost: Stake $100+ worth of any supported token and earn 2x rewards for 30 days. APY up to 45%%.',
    'Community Vote: Help decide which token gets listed next! Cast your vote and earn participation rewards.',
    'Trading Signal Channel: Premium signals now available for VIP members. 75%% historical accuracy. Join the exclusive group.',
    'Cross-chain Bridge Promotion: Bridge assets to earn bonus tokens. 0%% bridge fees for the first 1,000 transactions.',
    'Portfolio Challenge: Grow your portfolio by 50%% this month using any strategy. Top 50 performers share $30,000.',
    'New Feature Launch: Advanced order types now available! Trailing stop, OCO, and iceberg orders. Trade smarter.',
    'Airdrop Season: Complete tasks to qualify for upcoming airdrops. Multiple projects participating. Check eligibility now.',
    'API Trading Competition: Build a trading bot and compete against others. $15,000 prize pool for best-performing algorithms.',
    'VIP Tier Update: New benefits added to all VIP levels. Enhanced withdrawal limits, priority support, and exclusive events.',
    'End of Quarter Bonus: Trade $50,000+ volume this week to qualify for end-of-quarter bonuses. Up to $1,000 in rewards.'
  ];

  FOR v_i IN 1..80 LOOP
    SELECT * INTO v_profile FROM anonymous_profiles ORDER BY random() LIMIT 1;
    v_coin := v_coins[1 + floor(random() * array_length(v_coins, 1))::int];
    
    v_amount := CASE
      WHEN random() < 0.2 THEN (floor(random() * 900 + 100))::text
      WHEN random() < 0.5 THEN (floor(random() * 4000 + 1000))::text || '.' || lpad((floor(random() * 99))::text, 2, '0')
      WHEN random() < 0.8 THEN (floor(random() * 15000 + 5000))::text || '.' || lpad((floor(random() * 99))::text, 2, '0')
      ELSE (floor(random() * 40000 + 15000))::text || '.' || lpad((floor(random() * 99))::text, 2, '0')
    END;

    v_tag_coins := ARRAY[
      v_coins[1 + floor(random() * array_length(v_coins, 1))::int],
      v_coins[1 + floor(random() * array_length(v_coins, 1))::int]
    ];
    v_tags := json_build_array(
      json_build_object('symbol', v_tag_coins[1], 'change', round((random() * 12 - 6)::numeric, 2)),
      json_build_object('symbol', v_tag_coins[2], 'change', round((random() * 12 - 6)::numeric, 2))
    )::jsonb;

    INSERT INTO social_posts (
      username, avatar_url, content, coin_symbol, trade_type, entry_price, exit_price,
      profit_loss, profit_loss_percent, leverage, image_url, post_type,
      likes_count, comments_count, shares_count, is_bullish, created_at,
      coin_tags, sentiment
    ) VALUES (
      v_profile.username, v_profile.avatar_url,
      replace(replace(
        v_personal[1 + ((v_i - 1) % array_length(v_personal, 1))],
        '$AMOUNT', v_amount),
        '$COIN', v_coin),
      v_coin, 'long', 0, 0, 0, 0, 1, NULL, 'personal',
      floor(random() * 200 + 10)::int, floor(random() * 60 + 3)::int,
      floor(random() * 40 + 1)::int, true,
      now() - (random() * interval '10 days'),
      v_tags, 'bullish'
    );
  END LOOP;

  FOR v_i IN 1..25 LOOP
    SELECT * INTO v_profile FROM anonymous_profiles ORDER BY random() LIMIT 1;
    v_coin := v_coins[1 + floor(random() * array_length(v_coins, 1))::int];

    INSERT INTO social_posts (
      username, avatar_url, content, coin_symbol, trade_type, entry_price, exit_price,
      profit_loss, profit_loss_percent, leverage, image_url, post_type,
      likes_count, comments_count, shares_count, is_bullish, created_at,
      coin_tags, sentiment
    ) VALUES (
      CASE WHEN random() > 0.5 THEN 'Official' ELSE v_profile.username END,
      v_profile.avatar_url,
      v_events[1 + ((v_i - 1) % array_length(v_events, 1))],
      v_coin, 'long', 0, 0, 0, 0, 1, NULL, 'event',
      floor(random() * 500 + 50)::int, floor(random() * 100 + 10)::int,
      floor(random() * 200 + 20)::int, true,
      now() - (random() * interval '5 days'),
      '[]'::jsonb, 'neutral'
    );
  END LOOP;
END $$;