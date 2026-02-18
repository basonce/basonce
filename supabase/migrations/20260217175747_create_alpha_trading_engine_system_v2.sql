/*
  # Alpha Token Trading Engine - Complete System

  1. New Tables
    - `alpha_token_holders` - Tracks token holdings per user
    - `alpha_price_history` - OHLCV price data for charts

  2. New Columns on alpha_tokens
    - `total_supply`, `circulating_supply`, `initial_price`
    - `creator_initial_buy`, `price_change_24h`, `ath_price`, `liquidity`

  3. Security
    - RLS enabled on all new tables
    - Proper read/write policies

  4. Sample Data
    - Price history for all existing tokens
    - Holder entries with distribution
*/

CREATE TABLE IF NOT EXISTS alpha_token_holders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token_id uuid NOT NULL REFERENCES alpha_tokens(id) ON DELETE CASCADE,
  user_id uuid,
  username text NOT NULL DEFAULT 'Anonymous',
  avatar_url text,
  amount numeric NOT NULL DEFAULT 0,
  avg_buy_price numeric NOT NULL DEFAULT 0,
  total_invested numeric NOT NULL DEFAULT 0,
  percentage numeric NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS alpha_price_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token_id uuid NOT NULL REFERENCES alpha_tokens(id) ON DELETE CASCADE,
  price numeric NOT NULL DEFAULT 0,
  market_cap numeric NOT NULL DEFAULT 0,
  volume numeric NOT NULL DEFAULT 0,
  open_price numeric NOT NULL DEFAULT 0,
  high_price numeric NOT NULL DEFAULT 0,
  low_price numeric NOT NULL DEFAULT 0,
  close_price numeric NOT NULL DEFAULT 0,
  timestamp timestamptz NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'alpha_tokens' AND column_name = 'total_supply'
  ) THEN
    ALTER TABLE alpha_tokens ADD COLUMN total_supply numeric NOT NULL DEFAULT 1000000000;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'alpha_tokens' AND column_name = 'circulating_supply'
  ) THEN
    ALTER TABLE alpha_tokens ADD COLUMN circulating_supply numeric NOT NULL DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'alpha_tokens' AND column_name = 'initial_price'
  ) THEN
    ALTER TABLE alpha_tokens ADD COLUMN initial_price numeric NOT NULL DEFAULT 0.000001;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'alpha_tokens' AND column_name = 'creator_initial_buy'
  ) THEN
    ALTER TABLE alpha_tokens ADD COLUMN creator_initial_buy numeric NOT NULL DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'alpha_tokens' AND column_name = 'price_change_24h'
  ) THEN
    ALTER TABLE alpha_tokens ADD COLUMN price_change_24h numeric NOT NULL DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'alpha_tokens' AND column_name = 'ath_price'
  ) THEN
    ALTER TABLE alpha_tokens ADD COLUMN ath_price numeric NOT NULL DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'alpha_tokens' AND column_name = 'liquidity'
  ) THEN
    ALTER TABLE alpha_tokens ADD COLUMN liquidity numeric NOT NULL DEFAULT 0;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_alpha_holders_token ON alpha_token_holders(token_id);
CREATE INDEX IF NOT EXISTS idx_alpha_holders_user ON alpha_token_holders(user_id);
CREATE INDEX IF NOT EXISTS idx_alpha_price_hist_token ON alpha_price_history(token_id);
CREATE INDEX IF NOT EXISTS idx_alpha_price_hist_time ON alpha_price_history(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_alpha_price_hist_token_time ON alpha_price_history(token_id, timestamp DESC);

ALTER TABLE alpha_token_holders ENABLE ROW LEVEL SECURITY;
ALTER TABLE alpha_price_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view token holders"
  ON alpha_token_holders FOR SELECT
  TO authenticated, anon
  USING (EXISTS (
    SELECT 1 FROM alpha_tokens
    WHERE alpha_tokens.id = alpha_token_holders.token_id
    AND alpha_tokens.status = 'active'
  ));

CREATE POLICY "Authenticated users can create holder entries"
  ON alpha_token_holders FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own holdings"
  ON alpha_token_holders FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Anyone can view price history"
  ON alpha_price_history FOR SELECT
  TO authenticated, anon
  USING (EXISTS (
    SELECT 1 FROM alpha_tokens
    WHERE alpha_tokens.id = alpha_price_history.token_id
    AND alpha_tokens.status = 'active'
  ));

CREATE POLICY "System can insert price history"
  ON alpha_price_history FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

UPDATE alpha_tokens SET
  circulating_supply = CASE
    WHEN market_cap > 0 AND current_price > 0 THEN (market_cap / current_price)::numeric
    ELSE 100000000
  END,
  initial_price = current_price * 0.1,
  price_change_24h = ((random() * 80 - 20))::numeric,
  ath_price = current_price * (1 + random() * 3),
  liquidity = raised_amount * CASE
    WHEN raised_token = 'BNB' THEN 600
    WHEN raised_token = 'ETH' THEN 3500
    ELSE 150
  END * 0.5;

DO $$
DECLARE
  v_tok RECORD;
  v_time timestamptz;
  v_base_price numeric;
  v_p numeric;
  v_open numeric;
  v_high numeric;
  v_low numeric;
  v_close numeric;
  v_vol numeric;
  v_hrs integer;
  v_users text[] := ARRAY[
    'CryptoKing42','MoonHunter','DegenTrader','DiamondHands88','ApeStrong',
    'WhaleAlert','GemFinder','BullRunner','TokenMaster','AlphaSeeker',
    'ChartWizard','PumpDetector','EarlyBird99','SolanaFan','DeFiPro',
    'MemeKing','CryptoNinja','BlockchainBro','YieldFarmer','GasOptimizer',
    'BagHolder99','RektCapital','BuyTheDip','FOMOKing','HodlGang',
    'LamboSoon','PaperHands','SatoshiFan','AltSeason','DipBuyer'
  ];
  v_ui integer;
  v_pct numeric;
  v_amt numeric;
  v_circ numeric;
BEGIN
  FOR v_tok IN SELECT * FROM alpha_tokens WHERE status = 'active' LOOP
    v_hrs := GREATEST(EXTRACT(EPOCH FROM (now() - v_tok.created_at))::integer / 3600, 1);
    v_base_price := v_tok.current_price * 0.3;
    v_circ := COALESCE(NULLIF(v_tok.circulating_supply, 0), 100000000);

    FOR i IN 0..LEAST(v_hrs, 72) LOOP
      v_time := v_tok.created_at + make_interval(hours => i);
      v_p := v_base_price + (v_tok.current_price - v_base_price) * (i::numeric / LEAST(v_hrs, 72)::numeric) * (1 + (random() * 0.3 - 0.15));
      v_vol := v_tok.volume_24h * (0.3 + random() * 1.4) / LEAST(v_hrs, 72)::numeric;
      v_open := v_p * (1 + (random() * 0.04 - 0.02));
      v_close := v_p * (1 + (random() * 0.06 - 0.03));
      v_high := GREATEST(v_open, v_close) * (1 + random() * 0.05);
      v_low := LEAST(v_open, v_close) * (1 - random() * 0.05);

      INSERT INTO alpha_price_history (
        token_id, price, market_cap, volume,
        open_price, high_price, low_price, close_price, timestamp
      ) VALUES (
        v_tok.id, v_p,
        v_p * v_circ,
        v_vol, v_open, v_high, v_low, v_close, v_time
      );
    END LOOP;

    FOR j IN 1..LEAST(GREATEST(v_tok.holder_count, 5), 15) LOOP
      v_ui := 1 + (random() * 29)::integer;
      v_pct := CASE
        WHEN j = 1 THEN (15 + random() * 25)::numeric
        WHEN j <= 3 THEN (5 + random() * 12)::numeric
        WHEN j <= 6 THEN (2 + random() * 5)::numeric
        ELSE (0.1 + random() * 3)::numeric
      END;
      v_amt := v_circ * v_pct / 100;

      INSERT INTO alpha_token_holders (
        token_id, username, avatar_url, amount,
        avg_buy_price, total_invested, percentage, created_at
      ) VALUES (
        v_tok.id,
        v_users[v_ui],
        'https://i.pravatar.cc/150?img=' || (v_ui + 5),
        v_amt,
        v_tok.current_price * (0.5 + random() * 0.8),
        v_amt * v_tok.current_price * (0.5 + random() * 0.8),
        v_pct,
        v_tok.created_at + make_interval(hours => (random() * GREATEST(v_hrs, 1))::integer)
      );
    END LOOP;
  END LOOP;
END $$;
