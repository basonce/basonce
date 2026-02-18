/*
  # Professional Discover Feed - Schema & RPC Update

  1. Schema Changes
    - Extended post_type values: analysis, educational, personal, event, multi_position, live_embed
    - New columns:
      - coin_tags (jsonb) - Coin tickers with price changes shown under posts
      - asset_change_30d (numeric) - 30-day portfolio performance percentage
      - chart_coin (text) - Coin symbol for chart analysis posts
      - sub_positions (jsonb) - Array of position data for multi-position posts
      - live_room_data (jsonb) - Live room embed data
      - sentiment (text) - Post sentiment: bullish/bearish/neutral

  2. RPC Function Update
    - Updated get_random_social_posts to return all new columns
    - Balanced post type distribution for diverse feed

  3. Data Cleanup
    - Remove luxury posts (money/cash images)
    - Add coin_tags to existing text posts
*/

-- Drop old post_type constraint
ALTER TABLE social_posts DROP CONSTRAINT IF EXISTS social_posts_post_type_check;

-- Add new constraint with all types
ALTER TABLE social_posts ADD CONSTRAINT social_posts_post_type_check
  CHECK (post_type IN ('text', 'winner', 'luxury', 'analysis', 'educational', 'personal', 'event', 'multi_position', 'live_embed'));

-- Add new columns
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'social_posts' AND column_name = 'coin_tags') THEN
    ALTER TABLE social_posts ADD COLUMN coin_tags jsonb DEFAULT '[]'::jsonb;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'social_posts' AND column_name = 'asset_change_30d') THEN
    ALTER TABLE social_posts ADD COLUMN asset_change_30d numeric;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'social_posts' AND column_name = 'chart_coin') THEN
    ALTER TABLE social_posts ADD COLUMN chart_coin text;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'social_posts' AND column_name = 'sub_positions') THEN
    ALTER TABLE social_posts ADD COLUMN sub_positions jsonb DEFAULT '[]'::jsonb;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'social_posts' AND column_name = 'live_room_data') THEN
    ALTER TABLE social_posts ADD COLUMN live_room_data jsonb;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'social_posts' AND column_name = 'sentiment') THEN
    ALTER TABLE social_posts ADD COLUMN sentiment text DEFAULT 'neutral';
  END IF;
END $$;

-- Remove luxury posts
DELETE FROM social_posts WHERE post_type = 'luxury';

-- Add coin_tags to existing text/winner posts
UPDATE social_posts SET
  coin_tags = CASE
    WHEN coin_symbol = 'BTC' THEN '[{"symbol":"BTC","change":2.34},{"symbol":"ETH","change":-1.22},{"symbol":"SOL","change":4.56}]'::jsonb
    WHEN coin_symbol = 'ETH' THEN '[{"symbol":"ETH","change":1.87},{"symbol":"BTC","change":0.45},{"symbol":"LINK","change":-2.11}]'::jsonb
    WHEN coin_symbol = 'SOL' THEN '[{"symbol":"SOL","change":3.45},{"symbol":"JUP","change":5.67},{"symbol":"BONK","change":-1.89}]'::jsonb
    WHEN coin_symbol = 'BNB' THEN '[{"symbol":"BNB","change":0.78},{"symbol":"CAKE","change":-3.45},{"symbol":"XVS","change":2.11}]'::jsonb
    WHEN coin_symbol = 'DOGE' THEN '[{"symbol":"DOGE","change":-2.34},{"symbol":"SHIB","change":1.23},{"symbol":"PEPE","change":8.90}]'::jsonb
    WHEN coin_symbol = 'XRP' THEN '[{"symbol":"XRP","change":1.56},{"symbol":"XLM","change":-0.89},{"symbol":"HBAR","change":3.45}]'::jsonb
    WHEN coin_symbol = 'ADA' THEN '[{"symbol":"ADA","change":-1.23},{"symbol":"DOT","change":2.34},{"symbol":"ATOM","change":-0.67}]'::jsonb
    WHEN coin_symbol = 'AVAX' THEN '[{"symbol":"AVAX","change":3.12},{"symbol":"FTM","change":-2.56},{"symbol":"NEAR","change":1.45}]'::jsonb
    WHEN coin_symbol = 'LINK' THEN '[{"symbol":"LINK","change":2.89},{"symbol":"AAVE","change":1.34},{"symbol":"UNI","change":-0.78}]'::jsonb
    WHEN coin_symbol = 'DOT' THEN '[{"symbol":"DOT","change":-0.56},{"symbol":"ATOM","change":1.78},{"symbol":"NEAR","change":2.34}]'::jsonb
    WHEN coin_symbol = 'MATIC' THEN '[{"symbol":"MATIC","change":1.23},{"symbol":"ARB","change":-2.45},{"symbol":"OP","change":3.67}]'::jsonb
    ELSE ('[{"symbol":"' || coin_symbol || '","change":' || round((random() * 10 - 5)::numeric, 2)::text || '},{"symbol":"BTC","change":' || round((random() * 4 - 2)::numeric, 2)::text || '}]')::jsonb
  END,
  sentiment = CASE WHEN is_bullish THEN 'bullish' ELSE 'bearish' END
WHERE post_type IN ('text', 'winner') AND (coin_tags IS NULL OR coin_tags = '[]'::jsonb);

-- Drop and recreate the RPC function with all new columns
DROP FUNCTION IF EXISTS get_random_social_posts(integer);

CREATE FUNCTION get_random_social_posts(post_limit integer DEFAULT 50)
RETURNS TABLE(
  id uuid,
  username text,
  avatar_url text,
  content text,
  coin_symbol text,
  trade_type text,
  entry_price numeric,
  exit_price numeric,
  profit_loss numeric,
  profit_loss_percent numeric,
  leverage integer,
  image_url text,
  image_url_2 text,
  post_type text,
  likes_count integer,
  comments_count integer,
  shares_count integer,
  is_bullish boolean,
  created_at timestamptz,
  coin_tags jsonb,
  asset_change_30d numeric,
  chart_coin text,
  sub_positions jsonb,
  live_room_data jsonb,
  sentiment text
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  v_text_count integer;
  v_analysis_count integer;
  v_educational_count integer;
  v_personal_count integer;
  v_event_count integer;
  v_multi_count integer;
  v_live_count integer;
BEGIN
  v_text_count := GREATEST(1, post_limit * 30 / 100);
  v_analysis_count := GREATEST(1, post_limit * 14 / 100);
  v_educational_count := GREATEST(1, post_limit * 14 / 100);
  v_personal_count := GREATEST(1, post_limit * 14 / 100);
  v_event_count := GREATEST(1, post_limit * 6 / 100);
  v_multi_count := GREATEST(1, post_limit * 12 / 100);
  v_live_count := GREATEST(1, post_limit * 10 / 100);

  RETURN QUERY
  SELECT * FROM (
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type IN ('text', 'winner') ORDER BY random() LIMIT v_text_count)
    UNION ALL
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type = 'analysis' ORDER BY random() LIMIT v_analysis_count)
    UNION ALL
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type = 'educational' ORDER BY random() LIMIT v_educational_count)
    UNION ALL
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type = 'personal' ORDER BY random() LIMIT v_personal_count)
    UNION ALL
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type = 'event' ORDER BY random() LIMIT v_event_count)
    UNION ALL
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type = 'multi_position' ORDER BY random() LIMIT v_multi_count)
    UNION ALL
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type = 'live_embed' ORDER BY random() LIMIT v_live_count)
  ) combined
  ORDER BY random();
END;
$$;