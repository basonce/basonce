/*
  # Fix Social Posts RPC - Ensure 1/3 Luxury Ratio

  ## Changes
  1. Drop and recreate `get_random_social_posts` function
  2. New function ensures every 3rd post is a luxury/wealth proof post
  3. Fetches luxury and non-luxury posts separately, then interleaves them
  4. Result: natural-looking feed with consistent wealth proof visibility

  ## Ratio
  - 2 normal trading posts
  - 1 luxury wealth proof post
  - Repeats throughout the feed
*/

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
  created_at timestamptz
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  luxury_count integer;
  normal_count integer;
BEGIN
  luxury_count := GREATEST(1, post_limit / 3);
  normal_count := post_limit - luxury_count;
  
  RETURN QUERY
  WITH luxury_posts AS (
    SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type,
      sp.likes_count, sp.comments_count, sp.shares_count, sp.is_bullish, sp.created_at,
      row_number() OVER (ORDER BY random()) as rn
    FROM social_posts sp
    WHERE sp.post_type = 'luxury'
    LIMIT luxury_count
  ),
  normal_posts AS (
    SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type,
      sp.likes_count, sp.comments_count, sp.shares_count, sp.is_bullish, sp.created_at,
      row_number() OVER (ORDER BY random()) as rn
    FROM social_posts sp
    WHERE sp.post_type != 'luxury'
    LIMIT normal_count
  ),
  interleaved AS (
    SELECT n.*, 
      (n.rn - 1) * 3 + 
      CASE 
        WHEN (n.rn - 1) % 2 = 0 THEN 1
        ELSE 2
      END as sort_order
    FROM normal_posts n
    UNION ALL
    SELECT l.*,
      (l.rn) * 3 as sort_order
    FROM luxury_posts l
  )
  SELECT i.id, i.username, i.avatar_url, i.content, i.coin_symbol, i.trade_type,
    i.entry_price, i.exit_price, i.profit_loss, i.profit_loss_percent, i.leverage,
    i.image_url, i.image_url_2, i.post_type,
    i.likes_count, i.comments_count, i.shares_count, i.is_bullish, i.created_at
  FROM interleaved i
  ORDER BY i.sort_order;
END;
$$;