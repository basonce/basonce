/*
  # Fix Social Posts RPC Function

  ## Changes
  1. Drop and recreate `get_random_social_posts` function to include:
     - `post_type` column (text, winner, luxury)
     - `image_url_2` column (second image for luxury posts)
  2. This fixes the Discover feed not showing luxury post images

  ## Important
  - Function is dropped and recreated with new return type
  - All existing callers will automatically get the new columns
*/

DROP FUNCTION IF EXISTS get_random_social_posts(integer);

CREATE FUNCTION get_random_social_posts(post_limit integer DEFAULT 25)
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
LANGUAGE sql
STABLE
AS $$
SELECT 
  id, username, avatar_url, content, coin_symbol, trade_type,
  entry_price, exit_price, profit_loss, profit_loss_percent, leverage,
  image_url, image_url_2, post_type,
  likes_count, comments_count, shares_count, is_bullish, created_at
FROM social_posts
ORDER BY random()
LIMIT post_limit;
$$;