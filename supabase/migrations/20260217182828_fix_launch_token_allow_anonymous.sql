/*
  # Fix launch_alpha_token for anonymous users

  1. Changes
    - Update launch_alpha_token to allow anonymous users (auth.uid() can be NULL)
    - Grant execute permission to both authenticated and anon roles

  2. Security
    - Anonymous users can create tokens but creator_id will be NULL
    - Authenticated users get their auth.uid() set as creator_id
*/

CREATE OR REPLACE FUNCTION public.launch_alpha_token(
  p_name text,
  p_symbol text,
  p_description text DEFAULT NULL,
  p_logo_url text DEFAULT NULL,
  p_network text DEFAULT 'BSC',
  p_tag text DEFAULT 'Meme',
  p_website_url text DEFAULT NULL,
  p_twitter_url text DEFAULT NULL,
  p_telegram_url text DEFAULT NULL,
  p_initial_buy numeric DEFAULT 0,
  p_raised_token text DEFAULT 'BNB',
  p_target_amount numeric DEFAULT 18
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_token_id uuid;
  v_user_id uuid;
  v_initial_price numeric := 0.000001;
  v_price_multiplier numeric;
  v_mcap numeric;
  v_base_price numeric;
  v_current_price numeric;
  v_hour_offset integer;
  v_open numeric;
  v_high numeric;
  v_low numeric;
  v_close numeric;
  v_vol numeric;
  v_i integer;
  v_holder_count integer;
  v_holder_names text[] := ARRAY[
    'CryptoKing42','MoonHunter','DegenTrader','DiamondHands88','ApeStrong',
    'WhaleAlert','GemFinder','BullRunner','TokenMaster','AlphaSeeker',
    'ChartWizard','PumpDetector','EarlyBird99','SolanaFan','DeFiPro'
  ];
  v_holder_name text;
  v_holder_pct numeric;
  v_total_pct numeric := 0;
  v_holder_amount numeric;
BEGIN
  v_user_id := auth.uid();

  IF p_raised_token = 'BNB' THEN
    v_price_multiplier := 600;
  ELSIF p_raised_token = 'ETH' THEN
    v_price_multiplier := 3500;
  ELSE
    v_price_multiplier := 150;
  END IF;

  v_mcap := GREATEST(p_initial_buy * v_price_multiplier, 1000);

  INSERT INTO alpha_tokens (
    creator_id, name, symbol, description, logo_url,
    network, tag, website_url, twitter_url, telegram_url,
    raised_amount, target_amount, raised_token,
    current_price, market_cap, holder_count, transaction_count,
    volume_24h, community_score, is_graduated, is_featured, status,
    total_supply, circulating_supply, initial_price,
    creator_initial_buy, price_change_24h, ath_price, liquidity
  ) VALUES (
    v_user_id, p_name, p_symbol, p_description, p_logo_url,
    p_network, p_tag, p_website_url, p_twitter_url, p_telegram_url,
    p_initial_buy, p_target_amount, p_raised_token,
    v_initial_price, v_mcap,
    CASE WHEN p_initial_buy > 0 THEN 1 ELSE 0 END,
    CASE WHEN p_initial_buy > 0 THEN 1 ELSE 0 END,
    v_mcap * 0.3, 0, false, false, 'active',
    1000000000,
    CASE WHEN p_initial_buy > 0 THEN p_initial_buy / v_initial_price ELSE 0 END,
    v_initial_price, p_initial_buy, 0, v_initial_price, v_mcap * 0.5
  )
  RETURNING id INTO v_token_id;

  v_base_price := v_initial_price * (0.5 + random() * 0.5);
  v_current_price := v_base_price;

  FOR v_hour_offset IN 1..72 LOOP
    v_open := v_current_price;
    v_current_price := v_current_price * (0.92 + random() * 0.18);
    IF v_current_price < v_initial_price * 0.1 THEN
      v_current_price := v_initial_price * (0.1 + random() * 0.3);
    END IF;
    v_close := v_current_price;
    v_high := GREATEST(v_open, v_close) * (1 + random() * 0.08);
    v_low := LEAST(v_open, v_close) * (1 - random() * 0.08);
    v_vol := (100 + random() * 5000);

    INSERT INTO alpha_price_history (
      token_id, open_price, high_price, low_price, close_price,
      volume, price, market_cap, timestamp
    ) VALUES (
      v_token_id, v_open, v_high, v_low, v_close,
      v_vol, v_close, v_close * 1000000000,
      now() - ((72 - v_hour_offset) || ' hours')::interval
    );
  END LOOP;

  v_holder_count := 3 + floor(random() * 10)::integer;
  v_total_pct := 0;

  FOR v_i IN 1..v_holder_count LOOP
    v_holder_name := v_holder_names[1 + floor(random() * array_length(v_holder_names, 1))::integer];

    IF v_i = v_holder_count THEN
      v_holder_pct := GREATEST(100 - v_total_pct, 1);
    ELSE
      v_holder_pct := GREATEST(round((random() * 25 + 2)::numeric, 1), 0.5);
      IF v_total_pct + v_holder_pct > 95 THEN
        v_holder_pct := GREATEST(95 - v_total_pct, 0.5);
      END IF;
    END IF;

    v_total_pct := v_total_pct + v_holder_pct;
    v_holder_amount := round((v_holder_pct / 100.0) * 1000000000);

    INSERT INTO alpha_token_holders (
      token_id, user_id, username, avatar_url,
      amount, avg_buy_price, total_invested, percentage
    ) VALUES (
      v_token_id, NULL,
      v_holder_name || '#' || floor(random() * 9999)::integer,
      'https://i.pravatar.cc/150?img=' || (10 + v_i),
      v_holder_amount,
      v_initial_price * (0.8 + random() * 0.4),
      v_holder_amount * v_initial_price,
      v_holder_pct
    );

    EXIT WHEN v_total_pct >= 100;
  END LOOP;

  UPDATE alpha_tokens
  SET
    current_price = v_current_price,
    holder_count = v_holder_count,
    ath_price = GREATEST(v_current_price, v_initial_price * 1.5)
  WHERE id = v_token_id;

  RETURN v_token_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.launch_alpha_token TO authenticated;
GRANT EXECUTE ON FUNCTION public.launch_alpha_token TO anon;
