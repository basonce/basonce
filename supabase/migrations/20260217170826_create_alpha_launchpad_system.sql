/*
  # Basonce Alpha Token Launchpad System

  1. New Tables
    - `alpha_tokens` - Token launchpad listings with bonding curve, market data, social info
      - `id` (uuid, primary key)
      - `creator_id` (uuid) - Token creator
      - `name` (text) - Token name
      - `symbol` (text, unique) - Ticker symbol
      - `description` (text) - Token description
      - `logo_url` (text) - Logo image URL
      - `network` (text) - Blockchain network (BSC, Ethereum, Solana, Base)
      - `tag` (text) - Category (Meme, AI, Gaming, DeFi)
      - `website_url`, `twitter_url`, `telegram_url` - Social links
      - `raised_amount` (numeric) - Bonding curve current raised
      - `target_amount` (numeric) - Bonding curve target
      - `raised_token` (text) - Currency (BNB, ETH, SOL)
      - `current_price` (numeric) - Token price
      - `market_cap` (numeric) - Market capitalization
      - `holder_count` (integer) - Number of holders
      - `transaction_count` (integer) - Total transactions
      - `volume_24h` (numeric) - 24h trading volume
      - `community_score` (integer) - Net community votes
      - `is_graduated` (boolean) - Graduated from bonding curve
      - `is_featured` (boolean) - Featured token flag
      - `status` (text) - Token status

    - `alpha_transactions` - Buy/sell transaction records
      - Transaction details including wallet, amount, price
      - Denormalized token_symbol, token_name for live ticker display

    - `alpha_votes` - Community up/down voting
      - Unique per user per token

    - `alpha_comments` - Community discussion
      - Username, avatar, content, likes

    - `alpha_competitions` - Weekly trading competitions
      - Title, dates, prize pool, status

  2. Security
    - RLS enabled on all 5 tables
    - Public read access for active tokens (discovery)
    - Authenticated write access for participation
    - Vote management restricted to own votes

  3. Indexes
    - Optimized for network, tag, volume, score, created_at filtering

  4. Sample Data
    - 25 token listings across BSC, Ethereum, Solana, Base
    - 150+ transactions with wallet addresses
    - 60+ community comments
    - 1 active weekly competition
*/

CREATE TABLE IF NOT EXISTS alpha_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id uuid,
  name text NOT NULL,
  symbol text NOT NULL UNIQUE,
  description text,
  logo_url text,
  network text NOT NULL DEFAULT 'BSC',
  tag text NOT NULL DEFAULT 'Meme',
  website_url text,
  twitter_url text,
  telegram_url text,
  raised_amount numeric NOT NULL DEFAULT 0,
  target_amount numeric NOT NULL DEFAULT 18,
  raised_token text NOT NULL DEFAULT 'BNB',
  current_price numeric NOT NULL DEFAULT 0,
  market_cap numeric NOT NULL DEFAULT 0,
  holder_count integer NOT NULL DEFAULT 0,
  transaction_count integer NOT NULL DEFAULT 0,
  volume_24h numeric NOT NULL DEFAULT 0,
  community_score integer NOT NULL DEFAULT 0,
  is_graduated boolean NOT NULL DEFAULT false,
  is_featured boolean NOT NULL DEFAULT false,
  status text NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS alpha_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token_id uuid NOT NULL REFERENCES alpha_tokens(id) ON DELETE CASCADE,
  user_id uuid,
  tx_type text NOT NULL CHECK (tx_type IN ('buy', 'sell')),
  amount numeric NOT NULL DEFAULT 0,
  price numeric NOT NULL DEFAULT 0,
  total_value numeric NOT NULL DEFAULT 0,
  wallet_address text,
  username text,
  avatar_url text,
  token_symbol text NOT NULL DEFAULT '',
  token_name text NOT NULL DEFAULT '',
  raised_token text NOT NULL DEFAULT 'BNB',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS alpha_votes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token_id uuid NOT NULL REFERENCES alpha_tokens(id) ON DELETE CASCADE,
  user_id uuid NOT NULL,
  vote_type text NOT NULL CHECK (vote_type IN ('up', 'down')),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(token_id, user_id)
);

CREATE TABLE IF NOT EXISTS alpha_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token_id uuid NOT NULL REFERENCES alpha_tokens(id) ON DELETE CASCADE,
  user_id uuid,
  username text NOT NULL,
  avatar_url text,
  content text NOT NULL,
  likes integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS alpha_competitions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  start_date timestamptz NOT NULL,
  end_date timestamptz NOT NULL,
  prize_pool numeric NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_alpha_tokens_network ON alpha_tokens(network);
CREATE INDEX IF NOT EXISTS idx_alpha_tokens_tag ON alpha_tokens(tag);
CREATE INDEX IF NOT EXISTS idx_alpha_tokens_status ON alpha_tokens(status);
CREATE INDEX IF NOT EXISTS idx_alpha_tokens_volume ON alpha_tokens(volume_24h DESC);
CREATE INDEX IF NOT EXISTS idx_alpha_tokens_score ON alpha_tokens(community_score DESC);
CREATE INDEX IF NOT EXISTS idx_alpha_tokens_created ON alpha_tokens(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_alpha_tokens_graduated ON alpha_tokens(is_graduated);
CREATE INDEX IF NOT EXISTS idx_alpha_tx_token ON alpha_transactions(token_id);
CREATE INDEX IF NOT EXISTS idx_alpha_tx_created ON alpha_transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_alpha_votes_token ON alpha_votes(token_id);
CREATE INDEX IF NOT EXISTS idx_alpha_comments_token ON alpha_comments(token_id);

ALTER TABLE alpha_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE alpha_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE alpha_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE alpha_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE alpha_competitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active tokens"
  ON alpha_tokens FOR SELECT
  TO authenticated, anon
  USING (status = 'active');

CREATE POLICY "Authenticated users can create tokens"
  ON alpha_tokens FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Creators can update own tokens"
  ON alpha_tokens FOR UPDATE
  TO authenticated
  USING (auth.uid() = creator_id)
  WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Anyone can view recent transactions"
  ON alpha_transactions FOR SELECT
  TO authenticated, anon
  USING (created_at > now() - interval '90 days');

CREATE POLICY "Authenticated users can create transactions"
  ON alpha_transactions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Anyone can view votes on active tokens"
  ON alpha_votes FOR SELECT
  TO authenticated, anon
  USING (EXISTS (
    SELECT 1 FROM alpha_tokens
    WHERE alpha_tokens.id = alpha_votes.token_id
    AND alpha_tokens.status = 'active'
  ));

CREATE POLICY "Authenticated users can vote"
  ON alpha_votes FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own votes"
  ON alpha_votes FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own votes"
  ON alpha_votes FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Anyone can view comments on active tokens"
  ON alpha_comments FOR SELECT
  TO authenticated, anon
  USING (EXISTS (
    SELECT 1 FROM alpha_tokens
    WHERE alpha_tokens.id = alpha_comments.token_id
    AND alpha_tokens.status = 'active'
  ));

CREATE POLICY "Authenticated users can comment"
  ON alpha_comments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Anyone can view active competitions"
  ON alpha_competitions FOR SELECT
  TO authenticated, anon
  USING (status IN ('active', 'completed'));

DO $$
DECLARE
  v_tid uuid;
  v_names text[] := ARRAY[
    'PepeCash','GigaChad','BullishAF','MoonBag','DiamondDoge',
    'WenLambo','AITraderPro','DeFiDegen','CryptoChef','SafeRekt',
    'BNBBaby','PancakeFlip','VitaliksCat','GasGuzzler','ETHPepe',
    'NeuralNet','MergeToken','SolPunk','FastMoney','JitoJuice',
    'PixelWar','BasedAF','CoinbaseKid','OnchainApe','BaseBuilder'
  ];
  v_sym text[] := ARRAY[
    'PEPC','GIGA','BULL','MBAG','DDOGE',
    'WLAMBO','AITP','DEGEN','CHEF','SREKT',
    'BNBB','FLIP','VCAT','GGAS','ETHP',
    'NEUR','MERGE','SPUNK','FAST','JITO2',
    'PIXL','BASED','CBK','OAPE','BUILD'
  ];
  v_desc text[] := ARRAY[
    'The official Pepe of BNB Chain. Rare, green, and ready to moon. Join the frog army!',
    'The chaddest token on BSC. Only gigachads hold this. Born to pump.',
    'Only up from here. Diamond hands only. Bears are not welcome.',
    'Pack your bags, we are going to the moon! Early entry, maximum gains.',
    'Diamond paws, diamond hands. The doge with unbreakable spirit.',
    'When lambo? RIGHT NOW. The fastest road to your dream car.',
    'AI-powered trading signals on the blockchain. Let AI trade for you.',
    'Born to degen. Built for degens. The official token of DeFi degeneracy.',
    'Cooking up gains daily in the crypto kitchen. Michelin star returns.',
    'Safe until you get rekt. The most honest token name in crypto.',
    'BNB Chain cutest baby token. Small but mighty.',
    'Flip pancakes, flip profits. The unofficial PancakeSwap mascot.',
    'Even Vitalik cat needs a token. The purrfect investment.',
    'Someone has to pay for Ethereum gas. Might as well profit from it.',
    'Pepe meets Ethereum. Double the meme, double the gains.',
    'Decentralized AI on the blockchain. The future is neural.',
    'Born from the merge. Proof of meme at its finest.',
    'Punk vibes on Solana. Fast, cheap, and full of attitude.',
    'Faster than your trading bot. Solana speed, meme power.',
    'The juiciest yields on Solana. Squeeze every last drop of alpha.',
    'Retro pixel battles with real crypto rewards. 8-bit fortune awaits.',
    'The most based token on Base. If you know, you know.',
    'Born on Base, raised on gains. The Coinbase community token.',
    'Apes together strong. On-chain ape movement on Base.',
    'Building the future of Base ecosystem. One block at a time.'
  ];
  v_net text[] := ARRAY[
    'BSC','BSC','BSC','BSC','BSC','BSC','BSC','BSC','BSC','BSC',
    'BSC','BSC','Ethereum','Ethereum','Ethereum','Ethereum','Ethereum',
    'Solana','Solana','Solana','Solana','Base','Base','Base','Base'
  ];
  v_tag text[] := ARRAY[
    'Meme','Meme','Meme','Meme','Meme','Meme','AI','DeFi','Meme','Meme',
    'Meme','DeFi','Meme','Meme','Meme','AI','Meme','Meme','Meme','DeFi',
    'Gaming','Meme','Meme','Meme','DeFi'
  ];
  v_raised numeric[] := ARRAY[
    12.06,18,8.1,16.02,6.12,14.04,10.08,16.56,4.14,2.7,
    18,7.38,10.95,4.2,12.75,9.3,7.5,182,76,200,
    88,7.68,4.16,7.1,3.0
  ];
  v_target numeric[] := ARRAY[
    18,18,18,18,18,18,18,18,18,18,
    18,18,15,15,15,15,15,200,200,200,
    200,8,8,10,10
  ];
  v_rtok text[] := ARRAY[
    'BNB','BNB','BNB','BNB','BNB','BNB','BNB','BNB','BNB','BNB',
    'BNB','BNB','ETH','ETH','ETH','ETH','ETH','SOL','SOL','SOL',
    'SOL','ETH','ETH','ETH','ETH'
  ];
  v_mcap numeric[] := ARRAY[
    28500,185000,18200,52000,12400,43000,24500,58000,8900,4200,
    210000,15800,38000,9500,47000,32000,21000,62000,14500,145000,
    17800,48500,16200,28000,7500
  ];
  v_hold integer[] := ARRAY[
    342,2341,189,876,156,654,298,1123,87,42,
    3210,176,534,112,789,456,234,987,167,1890,
    201,723,145,389,78
  ];
  v_txc integer[] := ARRAY[
    1847,12450,956,5432,678,3210,1567,7890,345,123,
    15670,834,2890,534,4560,2340,1230,6780,789,9870,
    934,4120,678,2010,289
  ];
  v_vol numeric[] := ARRAY[
    15200,89000,8900,34500,5600,28000,12300,45000,3400,1800,
    125000,7200,21000,4500,31000,18500,9800,42000,6700,78000,
    8400,32000,5900,15600,2800
  ];
  v_score integer[] := ARRAY[
    156,892,78,345,45,234,167,456,23,-12,
    678,56,289,34,378,198,89,512,67,567,
    78,345,45,156,23
  ];
  v_grad boolean[] := ARRAY[
    false,true,false,false,false,false,false,false,false,false,
    true,false,false,false,false,false,false,false,false,true,
    false,false,false,false,false
  ];
  v_feat boolean[] := ARRAY[
    true,true,false,true,false,true,false,true,false,false,
    true,false,true,false,true,false,false,true,false,true,
    false,true,false,false,false
  ];
  v_hrs integer[] := ARRAY[
    8,120,3,48,1,24,16,72,2,0,
    168,12,36,6,56,20,10,96,4,144,
    7,32,5,14,1
  ];
  v_users text[] := ARRAY[
    'CryptoKing42','MoonHunter','DegenTrader','DiamondHands88','ApeStrong',
    'WhaleAlert','GemFinder','BullRunner','TokenMaster','AlphaSeeker',
    'ChartWizard','PumpDetector','EarlyBird99','SolanaFan','DeFiPro',
    'MemeKing','CryptoNinja','BlockchainBro','YieldFarmer','GasOptimizer'
  ];
  v_cmt text[] := ARRAY[
    'LFG! This is going to moon for sure!',
    'Just aped in, let us go!',
    'Bonding curve filling fast, do not miss out!',
    'Dev is based, community is strong.',
    'This is the next 100x, mark my words.',
    'Chart looking beautiful, breakout incoming!',
    'Finally a legit project on the launchpad.',
    'Early bird gets the worm. So glad I found this early.',
    'Community vibes are insane here!',
    'Who else is loading up their bags?',
    'This token has real potential.',
    'Diamond hands only, paper hands exit now.',
    'The bonding curve is almost full!',
    'Best entry point right now.',
    'Solid fundamentals for a meme token.',
    'Graduation is coming soon!',
    'Just added more to my position.',
    'The marketing has not even started yet.',
    'Incredible community, incredible token.',
    'Smart money is accumulating quietly.',
    'Do not fade this one. Trust.',
    'Volume is picking up, something big is coming.',
    'Every dip gets bought up instantly.',
    'Holder count growing fast. Organic growth.',
    'This is what early opportunities feel like.'
  ];
  v_ui integer;
  v_ci integer;
  v_tv numeric;
BEGIN
  FOR i IN 1..25 LOOP
    INSERT INTO alpha_tokens (
      name, symbol, description, network, tag,
      raised_amount, target_amount, raised_token,
      current_price, market_cap, holder_count,
      transaction_count, volume_24h, community_score,
      is_graduated, is_featured, status, created_at
    ) VALUES (
      v_names[i], v_sym[i], v_desc[i], v_net[i], v_tag[i],
      v_raised[i], v_target[i], v_rtok[i],
      v_mcap[i] / 1000000000.0, v_mcap[i], v_hold[i],
      v_txc[i], v_vol[i], v_score[i],
      v_grad[i], v_feat[i], 'active',
      now() - (GREATEST(v_hrs[i], 1)::text || ' hours')::interval
    ) RETURNING id INTO v_tid;

    FOR j IN 1..(4 + floor(random() * 5)::int) LOOP
      v_ui := 1 + floor(random() * 20)::int;
      v_tv := CASE v_rtok[i]
        WHEN 'BNB' THEN round((random() * 2.5 + 0.05)::numeric, 3)
        WHEN 'ETH' THEN round((random() * 0.8 + 0.01)::numeric, 4)
        WHEN 'SOL' THEN round((random() * 15 + 0.5)::numeric, 2)
        ELSE round((random() * 2 + 0.1)::numeric, 3)
      END;
      INSERT INTO alpha_transactions (
        token_id, tx_type, amount, price, total_value,
        wallet_address, username, avatar_url,
        token_symbol, token_name, raised_token, created_at
      ) VALUES (
        v_tid,
        CASE WHEN random() > 0.35 THEN 'buy' ELSE 'sell' END,
        round((v_tv * 1000000 / GREATEST(v_mcap[i], 1))::numeric, 0),
        v_mcap[i] / 1000000000.0,
        v_tv,
        '0x' || substr(md5(random()::text || i::text || j::text), 1, 4) || '...' || substr(md5(random()::text), 1, 4),
        v_users[v_ui],
        'https://i.pravatar.cc/150?img=' || (10 + v_ui),
        v_sym[i], v_names[i], v_rtok[i],
        now() - ((random() * GREATEST(v_hrs[i], 1))::text || ' hours')::interval
      );
    END LOOP;

    FOR j IN 1..(2 + floor(random() * 3)::int) LOOP
      v_ui := 1 + floor(random() * 20)::int;
      v_ci := 1 + floor(random() * 25)::int;
      INSERT INTO alpha_comments (
        token_id, username, avatar_url, content, likes, created_at
      ) VALUES (
        v_tid,
        v_users[v_ui],
        'https://i.pravatar.cc/150?img=' || (10 + v_ui),
        v_cmt[v_ci],
        floor(random() * 50)::int,
        now() - ((random() * GREATEST(v_hrs[i], 1))::text || ' hours')::interval
      );
    END LOOP;
  END LOOP;

  INSERT INTO alpha_competitions (title, description, start_date, end_date, prize_pool, status)
  VALUES (
    'Weekly Token Wars',
    'The token with the highest trading volume wins! Top 3 creators share the prize pool.',
    date_trunc('week', now()),
    date_trunc('week', now()) + interval '7 days',
    5000,
    'active'
  );
END $$;
