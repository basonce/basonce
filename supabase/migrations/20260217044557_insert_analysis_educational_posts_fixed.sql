/*
  # Diverse Social Posts - Analysis & Educational (Fixed)

  1. New Posts
    - 60 chart analysis posts with technical analysis content
    - 60 educational posts with trading tips and strategies
  
  2. Features
    - Each post has coin_tags for related coins
    - Analysis posts have chart_coin for chart display
    - Sentiment tags (bullish/bearish/neutral)
    - leverage set to 1 (minimum) for non-trading posts
*/

DO $$
DECLARE
  v_profile RECORD;
  v_coins TEXT[] := ARRAY['BTC', 'ETH', 'SOL', 'BNB', 'XRP', 'DOGE', 'ADA', 'AVAX', 'LINK', 'DOT', 'UNI', 'ATOM', 'LTC', 'ARB', 'OP', 'NEAR', 'FTM', 'AAVE', 'INJ', 'TIA', 'SUI', 'SEI', 'JUP', 'WLD', 'PEPE', 'APT', 'TAO', 'RENDER', 'FET', 'ONDO'];
  v_analysis TEXT[];
  v_educational TEXT[];
  v_coin TEXT;
  v_i INTEGER;
  v_tags JSONB;
  v_tag_coins TEXT[];
  v_sentiment TEXT;
BEGIN
  v_analysis := ARRAY[
    'Zoom out and you''ll see the full range. Support at key levels holding strong. The 4H chart shows a clear ascending channel since last week.',
    'Breaking out of the ascending triangle on the daily. If we hold above current support, target is 15-20%% higher. Volume confirming.',
    'Textbook cup and handle on the 4H. Breakout above neckline confirms. Risk/reward here is excellent for longs.',
    'Weekly RSI showing bullish divergence while price makes lower lows. Historically precedes major reversals. Accumulation zone.',
    'Liquidity sweep below previous low completed. Smart money grabbed stops, now aggressive buying. Classic manipulation.',
    'Order flow: massive bid walls forming between here and key support. Whales are accumulating quietly.',
    'The 200 EMA on the 4H acting as dynamic support. Every touch has been a buy opportunity for 3 weeks. Trend clearly bullish.',
    'Fib retracement to 0.618 complete. The golden pocket - historically strongest bounce zone. Watching closely.',
    'Volume profile shows massive gap above. Once we break through thin volume area, expect rapid move to fill.',
    'Double bottom confirmed on daily. Neckline breakout with volume expansion. Classic bullish reversal.',
    'Descending wedge nearly complete. Bullish continuation pattern. Expecting breakout to upside within 24-48 hours.',
    'MACD crossing bullish on weekly for first time in 3 months. Last time, price rallied 45%% in following weeks.',
    'Head and shoulders forming on 1D. If neckline breaks, significant correction ahead. Setting stop-losses.',
    'Ichimoku: price crossed above cloud on 4H. Kumo breakout is strong bullish signal. TK cross confirmed.',
    'On-chain: exchange reserves at all-time lows. Supply shock incoming. When whales stop selling, only one direction.',
    'Funding rate negative for 5 consecutive days while price holds. This divergence typically resolves with sharp upward move.',
    'Elliott Wave count: Wave 3 of impulse. Typically strongest and longest wave. Targets significantly higher.',
    'Wyckoff accumulation complete. Spring test successful, now in markup phase. Follow the composite operator.',
    'Bollinger Bands squeezing on daily - tightest in 60 days. Explosive move incoming. Watch breakout direction.',
    'Market structure shift on 1H. Higher highs and higher lows forming. Bears losing control.',
    'POC on volume profile at this level suggests strong support. Price gravitates toward highest volume node.',
    'ADX crossed above 25 on daily, confirming new trend. Combined with bullish DI crossover, strong long signal.',
    'Decoupling from BTC. Independent price action often precedes significant moves. Worth watching.',
    'Open interest surging while price consolidates. Big move loading. Liquidation cascades waiting on both sides.',
    'Real crashes visible on-chain and in liquidity behavior before they happen. Forget retail indicators.',
    'Golden cross (50/200 MA) on daily. One of most reliable bullish signals across all markets.',
    'Relative strength vs BTC improving for weeks. Outperforming market leader = strong accumulation sign.',
    'CME gap above still unfilled. Gaps filled 90%% of the time. Expect eventual move to that level.',
    'Heatmap: massive liquidation cluster above current price. Market makers love hunting these levels.',
    'VPVR shows clear low-volume node above. Minimal resistance once price enters this zone.',
    'Stochastic RSI oversold on weekly. Last 4 times: 30-80%% rallies over next month.',
    'Bearish RSI divergence while price makes new highs. Warning sign. Taking partial profits.',
    'Massive bullish engulfing at support on daily. One of strongest single-candle reversal signals.',
    'Funding extremely positive across exchanges. Too many longs. Contrarian correction signal.',
    'Symmetrical triangle consolidation for 12 days. Apex approaching. Breakout sets trend for weeks.',
    'VWAP reclaim on 4H. Institutional traders use VWAP as primary reference. This reclaim is significant.',
    'Ask wall at resistance being slowly absorbed. Once fully eaten, expect rapid move higher.',
    'Five consecutive Doji candles at resistance on 1H. Market undecided. Wait for clear break.',
    'Volume-weighted analysis: distribution phase starting. Smart money selling into retail buying.',
    'Three drives pattern completing on daily. Reversal pattern that catches everyone off guard.',
    'Supertrend flipped bullish on 4H after 2 weeks bearish. Reliable trend-following signal.',
    'Inverse H&S on weekly. If plays out, targets 40%% above current levels.',
    'Heikin Ashi: sustained bullish momentum on daily. No bottom wicks = pure buying pressure.',
    'Monthly chart: this level acted as S/R 7 times since 2023. Major decision point.',
    'Parabolic SAR flipped below price on daily. With ADX above 30, confirms strong uptrend.',
    'Thin sell-side liquidity. Even moderate buying could cause significant squeeze.',
    'Weekly close above key resistance = extremely bullish. Rejected here 4 times previously.',
    'Perp premium: trading at discount to spot. Historically leads to convergence rally.',
    'Multi-timeframe: 1H bullish, 4H neutral, daily bullish. 2/3 alignment supports longs.',
    'Chaikin Money Flow positive for 20 consecutive days. Sustained institutional buying.',
    'Failed breakdown below support with immediate recovery. Bear trap. Shorts getting squeezed.',
    'Testing 0.786 Fib. If holds, ABC correction complete. New impulse wave begins.',
    'Ratio chart vs ETH at multi-month lows. Mean reversion plays like this have high win rates.',
    'Momentum indicators aligning bullish across all timeframes for first time since rally started.',
    'Clear liquidity void between current price and previous high. Fast move expected once triggered.',
    'Tape reading: large market buys consistently at this level. Deep-pocket accumulation.',
    'Hash rate at ATH while price consolidates. Fundamental-technical divergence resolves to upside.',
    'Fear and Greed at extreme fear while price holds support. Historically best time to buy.',
    'Retail shorts at record highs, whales net long. Smart money positioned opposite to crowd.',
    'OBV making new highs while price hasn''t broken out. Volume leads price. Breakout imminent.'
  ];

  v_educational := ARRAY[
    'Risk Management 101: Never risk more than 2%% of your portfolio on a single trade. This rule saves more traders than any indicator.',
    'Isolated vs Cross Margin: Isolated limits loss to position margin. Cross uses entire balance. Choose based on your risk tolerance.',
    'Stop-loss placement: Don''t set at obvious levels. Place slightly below real support where smart money accumulates.',
    'Why most traders lose: Overtrading, ignoring risk management, emotional decisions. Fix these three and you''re ahead of 90%%.',
    'Funding rates explained: Positive = longs pay shorts. Negative = shorts pay longs. Key sentiment gauge.',
    'Position sizing: Risk Amount / (Entry - Stop Loss) = Position Size. Never skip this calculation before entering.',
    'Top 3 futures mistakes: 1) Over-leveraging 2) No stop-loss 3) Moving SL against the trade. Avoid all three.',
    'Order book reading: Large walls = potential S/R. But remember walls can be spoofed. Always confirm with price action.',
    'DCA strategy: Fixed amount at regular intervals instead of timing the market. Best during accumulation phases.',
    'Trade journaling: Patterns in your behavior become visible. Losing streaks usually share common mistakes.',
    'Liquidation math: 100x leverage = 1%% move liquidates. 10x = 10%% buffer. Always calculate before entering.',
    'Take-profit importance: Most focus on entries but ignore exits. Set realistic TP based on S/R zones.',
    'Fake breakout detection: Volume confirmation is key. No volume increase = likely fakeout. Wait for retest.',
    'After a loss, take a break. Revenge trading is the fastest way to blow an account.',
    'BTC correlation: When BTC dumps, alts dump harder. When BTC pumps, select alts pump more. Use this.',
    'Paper trading: Practice strategy with virtual funds first. Track results for minimum 30 trades before going live.',
    'Market cycles: Accumulation - Markup - Distribution - Markdown. Identify the phase before trading.',
    'The 1%% Rule: Professionals never risk more than 1%% of capital per trade. This ensures account longevity.',
    'Fib extension targets: Use 1.272, 1.618, 2.618 levels from impulse wave for realistic take-profit targets.',
    'Divergence trading: Price new highs + RSI lower highs = weakness. One of most reliable reversal signals.',
    'Avoid trading during news: Slippage increases, spreads widen, stops can fail. Wait for dust to settle.',
    'Compounding power: 1%% per day consistently = 10x in one year. Small consistent gains beat big risky trades.',
    'VWAP for intraday: Above VWAP = bullish bias. Below VWAP = bearish bias. Simple but effective.',
    'Grid trading: Buy and sell orders at regular intervals. Works best in ranging markets. Automate for passive income.',
    'Slippage: In volatile markets, fill price differs from order price. Use limit orders to avoid negative slippage.',
    'Time in market vs timing market: Long-term holders consistently outperform active traders in all studies.',
    'Trailing stop-loss: Move SL to breakeven once 1R in profit. Lock in gains progressively.',
    'Martingale trap: Doubling down on losers seems logical but destroys accounts mathematically.',
    'Candlestick context: Hammer at support = bullish. Shooting star at resistance = bearish. Context matters.',
    'Why most alts go to zero: No utility, team dumps, community dies. Only invest in real use cases.',
    'Whale manipulation: Accumulate quietly, pump to attract retail, distribute. Don''t be exit liquidity.',
    'Scale into positions: Split entry into 3-4 parts instead of all at once. Reduces bad timing impact.',
    'Trading plan: Before market opens, define entries, exits, position sizes, and max daily loss.',
    'Bollinger Bands: Lower band touch in uptrend = buy. Upper band in downtrend = sell opportunity.',
    'Leverage reality: 10x = 10x profits AND 10x losses. Start with 2-3x until consistently profitable.',
    'Market maker tactics: Spoofing, stop hunts, liquidity grabs. Learn to spot them, trade with them.',
    'The 90/90/90 rule: 90%% of traders lose 90%% of money in first 90 days. Be in the 10%%.',
    'Drawdown management: Set max drawdown limit (20%%). If reached, stop trading for a week.',
    'Timeframe alignment: Only trade when trend agrees on 2 of 3 timeframes (1H, 4H, Daily).',
    'Win rate vs R/R: 40%% win rate with 3:1 R/R is more profitable than 70%% with 1:1.',
    'Bid-ask spread: Tighter = more liquid. Avoid wide-spread coins as costs eat profits.',
    'Portfolio allocation: 50%% BTC/ETH, 30%% large-cap alts, 15%% mid-caps, 5%% small-caps.',
    'Confirmation bias: Don''t seek info that confirms your view. Actively look for why your trade could fail.',
    'Backtesting: Test against historical data before risking real money. Minimum 100 trades for significance.',
    'Perpetual futures: No expiry date. Funding rates keep price tethered to spot market.',
    'Expected value: 60%% win rate with 2:1 R/R = positive EV per trade. Trade this consistently.',
    'S/R reality: More times tested = weaker level. Fresh untested levels are strongest.',
    'Hard stops always: Mental stops rely on discipline. Discipline fails during emotional moments.',
    'Crypto market hours: 24/7 trading. Most volatility during US and Asian market overlaps.',
    'Define your edge: If you can''t clearly state it, you''re gambling. Develop a testable strategy.',
    'Unrealized vs realized PnL: Paper gains aren''t real until position closed. Don''t let winners become losers.',
    'Patience in trading: Best traders wait for high-probability setups. Sitting on hands IS a strategy.',
    'Funding heatmaps: Persistent high positive funding = overleveraged long. Correction increasingly likely.',
    'Scale out: DCA works for exits too. Take profits at predetermined levels progressively.',
    'Token unlocks: Large unlocks create sell pressure. Monitor vesting schedules before entering positions.',
    'Bear market survival: Reduce sizes, increase cash, focus on learning. Bear markets create future winners.',
    'Community sentiment: When euphoric = take profits. When everyone gives up = accumulate.',
    'Health matters: Tired traders make bad decisions. Set alerts, place orders, get proper rest.',
    'Gas fees impact: High fees eat small-position profits. Factor this into your strategy.',
    'Pump and dump avoidance: If someone aggressively promotes a low-cap token, they want to dump on you. DYOR.'
  ];

  FOR v_i IN 1..60 LOOP
    SELECT * INTO v_profile FROM anonymous_profiles ORDER BY random() LIMIT 1;
    v_coin := v_coins[1 + floor(random() * array_length(v_coins, 1))::int];
    v_tag_coins := ARRAY[
      v_coins[1 + floor(random() * array_length(v_coins, 1))::int],
      v_coins[1 + floor(random() * array_length(v_coins, 1))::int],
      v_coins[1 + floor(random() * array_length(v_coins, 1))::int]
    ];
    v_sentiment := CASE WHEN random() > 0.4 THEN 'bullish' ELSE 'bearish' END;
    v_tags := json_build_array(
      json_build_object('symbol', v_tag_coins[1], 'change', round((random() * 16 - 8)::numeric, 2)),
      json_build_object('symbol', v_tag_coins[2], 'change', round((random() * 16 - 8)::numeric, 2)),
      json_build_object('symbol', v_tag_coins[3], 'change', round((random() * 16 - 8)::numeric, 2))
    )::jsonb;

    INSERT INTO social_posts (
      username, avatar_url, content, coin_symbol, trade_type, entry_price, exit_price,
      profit_loss, profit_loss_percent, leverage, image_url, post_type,
      likes_count, comments_count, shares_count, is_bullish, created_at,
      coin_tags, chart_coin, sentiment
    ) VALUES (
      v_profile.username, v_profile.avatar_url,
      v_coin || '/USDT: ' || v_analysis[1 + ((v_i - 1) % array_length(v_analysis, 1))],
      v_coin,
      CASE WHEN v_sentiment = 'bullish' THEN 'long' ELSE 'short' END,
      0, 0, 0, 0, 1, NULL, 'analysis',
      floor(random() * 180 + 5)::int, floor(random() * 50 + 2)::int,
      floor(random() * 80 + 1)::int, v_sentiment = 'bullish',
      now() - (random() * interval '7 days'),
      v_tags, v_coin, v_sentiment
    );
  END LOOP;

  FOR v_i IN 1..60 LOOP
    SELECT * INTO v_profile FROM anonymous_profiles ORDER BY random() LIMIT 1;
    v_coin := v_coins[1 + floor(random() * array_length(v_coins, 1))::int];
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
      v_educational[1 + ((v_i - 1) % array_length(v_educational, 1))],
      v_coin, 'long', 0, 0, 0, 0, 1, NULL, 'educational',
      floor(random() * 300 + 20)::int, floor(random() * 80 + 5)::int,
      floor(random() * 120 + 5)::int, true,
      now() - (random() * interval '14 days'),
      v_tags, 'neutral'
    );
  END LOOP;
END $$;