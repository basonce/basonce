/*
  # Realistic Live Room Chat & Dynamic User System

  1. New Tables
    - `live_room_active_users`
      - Tracks users currently in room with join/leave times
      - Used for dynamic user count updates
    - `live_room_realistic_messages`
      - Pre-populated with 1000+ realistic crypto trading discussions
      - Messages about BTC, ETH, ADA, SOL, etc.
      - Technical analysis, price predictions, trading advice
  
  2. Security
    - Enable RLS on all tables
    - Policies for authenticated users to read
*/

-- Create active users tracking table
CREATE TABLE IF NOT EXISTS live_room_active_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid REFERENCES live_rooms(id) ON DELETE CASCADE NOT NULL,
  dummy_user_id bigint REFERENCES anonymous_profiles(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  joined_at timestamptz DEFAULT now() NOT NULL,
  left_at timestamptz,
  is_speaking boolean DEFAULT false,
  role text DEFAULT 'listener' CHECK (role IN ('host', 'co-host', 'listener')),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE live_room_active_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active users"
  ON live_room_active_users FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can insert active users"
  ON live_room_active_users FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update their active status"
  ON live_room_active_users FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid() OR dummy_user_id IS NOT NULL);

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_active_users_room ON live_room_active_users(room_id, left_at);

-- Create realistic crypto chat messages table
CREATE TABLE IF NOT EXISTS live_room_realistic_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid REFERENCES live_rooms(id) ON DELETE CASCADE NOT NULL,
  dummy_user_id bigint REFERENCES anonymous_profiles(id) ON DELETE CASCADE,
  message text NOT NULL,
  message_type text DEFAULT 'general' CHECK (message_type IN ('general', 'technical_analysis', 'question', 'prediction', 'alert')),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE live_room_realistic_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view realistic messages"
  ON live_room_realistic_messages FOR SELECT
  TO public
  USING (true);

-- Insert 1000 realistic crypto trading messages
DO $$
DECLARE
  room_record RECORD;
  random_user bigint;
  counter INT := 0;
  messages text[] := ARRAY[
    'BTC broke resistance at $68k, next target $72k',
    'ETH showing strong support at $3200, good entry point',
    'ADA forming a bullish flag on 4h chart',
    'SOL volume increasing, possible breakout soon',
    'BTC RSI oversold on 1h, expecting bounce',
    'DOGE testing resistance at $0.085, watch closely',
    'XRP breaking out of triangle pattern',
    'BTC MACD showing bullish crossover',
    'ETH/BTC ratio looking weak, be careful',
    'Strong support at $67500 for BTC',
    'Volume is increasing, possible pump incoming',
    'BTC rejected at $69k, might retest $68k',
    'ETH 2.0 staking rewards looking good',
    'Whale alert: 500 BTC moved to exchange',
    'BTC dominance dropping, alt season?',
    'SOL network congestion cleared, price recovering',
    'MATIC showing strength, ecosystem growing',
    'BTC hash rate at ATH, bullish signal',
    'ETH gas fees low, good time to transact',
    'Market looking bullish overall, steady accumulation',
    'Should I buy ETH now or wait?',
    'Is ADA a good long term hold?',
    'When is the next BTC halving?',
    'Best time to enter SOL?',
    'Is it too late to buy BTC?',
    'What do you think about DOGE?',
    'Should I DCA or wait for dip?',
    'Is this a bull trap?',
    'What are your price targets for ETH?',
    'How to set stop loss correctly?',
    'What is RSI indicator?',
    'Should I take profits now?',
    'Is futures trading safe?',
    'What leverage do you recommend?',
    'Any good entry points today?',
    'BTC to $75k by end of month',
    'ETH will hit $4k this week',
    'ADA pump to $0.60 incoming',
    'SOL will flip BNB this cycle',
    'Alt season starting next week',
    'BTC 100k by Q2',
    'ETH outperforming BTC soon',
    'Major correction coming, be careful',
    'This is just the beginning of bull run',
    'Expecting 20% pump on BTC',
    'Market will consolidate here for a while',
    'Next resistance at $70k for BTC',
    'We might see $65k retest',
    'DOGE to $0.10 this month',
    'Bullish on alts this week',
    'Just bought more BTC at $68500',
    'Set my stop loss at $67000',
    'Taking 50% profits here',
    'Opened long position on ETH',
    'DCA-ing into SOL every week',
    'Moved stop loss to breakeven',
    'Added to my ADA position',
    'Taking profits, market too hot',
    'Bought the dip at $67800',
    'Closing my shorts, reversing trend',
    'Scaling into position slowly',
    'Set take profit at $72k',
    'Just entered with 5x leverage',
    'Holding until $75k minimum',
    'Accumulating during this consolidation',
    'Breaking: ETF approval rumors circulating',
    'Major bank announces crypto custody service',
    'Fed meeting results coming in 1 hour',
    'Whale just moved 1000 BTC',
    'New partnership announcement for SOL',
    'Exchange wallet shows massive outflows',
    'Institutional buying pressure increasing',
    'Network upgrade scheduled for next week',
    'Trading volume doubled in last hour',
    'Major support level tested multiple times',
    'Bitcoin mining difficulty increased',
    'Market cap crossing important milestone',
    'Good morning everyone!',
    'What a volatile day',
    'HODL strong team',
    'To the moon!',
    'This is gentlemen',
    'Patience is key in crypto',
    'Never invest more than you can lose',
    'DYOR before investing',
    'Market looks healthy',
    'Consolidation is good for next leg up',
    'Thanks for the insights host',
    'Great analysis as always',
    'Following for daily updates',
    'Best trading community',
    'Learning so much here',
    'Risk management is crucial',
    'Don''t FOMO into trades',
    'Wait for confirmation',
    'Diversify your portfolio',
    'Not financial advice',
    'Always use stop losses',
    'Market manipulation happening',
    'Whales playing games',
    'Zoom out to weekly chart',
    'Long term bullish',
    'Short term bearish',
    'Stay calm and trade smart',
    'Emotions will destroy your portfolio',
    'Stick to your strategy',
    'Market cycles repeat',
    'co host me please',
    'hello how to trade were pls',
    'make co host me please',
    'Can someone explain leverage?',
    'New to crypto, where to start?',
    'Best exchange for trading?',
    'How to read candlestick charts?',
    'What is market cap?',
    'Difference between spot and futures?',
    'Should I use hardware wallet?',
    'Gas fees are crazy high',
    'Just made 10% today',
    'Lost money on that trade',
    'Setting alerts at key levels',
    'Following the trend',
    'Counter trend trading risky',
    'Swing trading vs day trading?',
    'Love this community',
    'Thanks for sharing',
    'Great call on that trade',
    'Who else is bullish?',
    'Bears getting rekt',
    'Bulls in control now',
    'Sideways action boring',
    'Accumulation phase',
    'Distribution starting?',
    'Breakout imminent',
    'Failed breakout, watch out',
    'Double bottom forming',
    'Head and shoulders pattern',
    'Cup and handle setup',
    'Ascending triangle bullish',
    'Descending triangle bearish',
    'Death cross warning',
    'Golden cross bullish',
    'Fibonacci retracement at 0.618',
    'Support turned resistance',
    'Resistance turned support',
    'Higher highs and higher lows',
    'Lower highs and lower lows',
    'Trend is your friend',
    'Don''t fight the trend',
    'Market in euphoria phase',
    'Fear and greed index high',
    'On-chain metrics bullish',
    'Exchange reserves dropping',
    'Stablecoin dominance rising',
    'Funding rates negative',
    'Open interest increasing',
    'Liquidation cascade possible',
    'Short squeeze incoming?',
    'Long liquidations happening',
    'Volume profile shows strong support',
    'Order book depth good',
    'Bid-ask spread tight',
    'Slippage minimal',
    'High frequency trading active',
    'Market makers providing liquidity',
    'Smart money accumulating',
    'Retail FOMO starting',
    'Institutional money flowing in',
    'Derivatives market heating up',
    'Options expiry coming',
    'Max pain at $68k',
    'Gamma squeeze possible',
    'Delta hedging by MMs',
    'Implied volatility dropping',
    'Historical volatility rising',
    'Bollinger bands squeezing',
    'Ichimoku cloud bullish',
    'Parabolic SAR flipped',
    'ADX showing strong trend',
    'Stochastic oversold',
    'Williams %R bottoming',
    'CCI in overbought territory',
    'ATR expanding, volatility up',
    'Pivot points holding',
    'VWAP acting as support',
    'EMA crossover bullish',
    'SMA death cross avoided',
    'Keltner channels expanding',
    'Donchian breakout confirmed'
  ];
BEGIN
  -- Get a public room
  SELECT id INTO room_record FROM live_rooms WHERE is_vip = false LIMIT 1;
  
  IF room_record.id IS NULL THEN
    RAISE NOTICE 'No public room found, skipping message insertion';
    RETURN;
  END IF;

  -- Insert 1000 messages with random users
  FOR counter IN 1..1000 LOOP
    SELECT id INTO random_user FROM anonymous_profiles ORDER BY random() LIMIT 1;
    INSERT INTO live_room_realistic_messages (room_id, dummy_user_id, message, message_type) VALUES
    (room_record.id, random_user, messages[(counter % array_length(messages, 1)) + 1], 
      CASE 
        WHEN counter % 5 = 0 THEN 'technical_analysis'
        WHEN counter % 7 = 0 THEN 'question'
        WHEN counter % 11 = 0 THEN 'prediction'
        WHEN counter % 13 = 0 THEN 'alert'
        ELSE 'general'
      END
    );
  END LOOP;

  RAISE NOTICE 'Inserted 1000 realistic crypto messages successfully';
END $$;

-- Create function to get random crypto message
CREATE OR REPLACE FUNCTION get_random_crypto_message()
RETURNS TABLE (
  user_id bigint,
  username text,
  avatar_url text,
  message text,
  message_type text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    ap.id as user_id,
    ap.username,
    ap.avatar_url,
    lrm.message,
    lrm.message_type
  FROM live_room_realistic_messages lrm
  JOIN anonymous_profiles ap ON lrm.dummy_user_id = ap.id
  WHERE lrm.room_id = (SELECT id FROM live_rooms WHERE is_vip = false LIMIT 1)
  ORDER BY random()
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
