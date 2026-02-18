/*
  # Create Random Social Posts Function

  1. New Function
    - `get_random_social_posts(post_limit)` - Returns random social posts from the database
    - Uses PostgreSQL's random() function to shuffle posts
    - Limits results to specified number
    - Ensures diverse content on each page load
    
  2. Purpose
    - Provide dynamic, ever-changing content feed
    - Prevent users from seeing the same posts repeatedly
    - Create engaging discover/forum experience
    - Simulate active community with rotating content
*/

CREATE OR REPLACE FUNCTION get_random_social_posts(post_limit INTEGER DEFAULT 25)
RETURNS TABLE (
  id UUID,
  username TEXT,
  avatar_url TEXT,
  content TEXT,
  coin_symbol TEXT,
  trade_type TEXT,
  entry_price NUMERIC,
  exit_price NUMERIC,
  profit_loss NUMERIC,
  profit_loss_percent NUMERIC,
  leverage INTEGER,
  image_url TEXT,
  likes_count INTEGER,
  comments_count INTEGER,
  shares_count INTEGER,
  is_bullish BOOLEAN,
  created_at TIMESTAMPTZ
)
LANGUAGE SQL
STABLE
AS $$
  SELECT 
    id,
    username,
    avatar_url,
    content,
    coin_symbol,
    trade_type,
    entry_price,
    exit_price,
    profit_loss,
    profit_loss_percent,
    leverage,
    image_url,
    likes_count,
    comments_count,
    shares_count,
    is_bullish,
    created_at
  FROM social_posts
  ORDER BY random()
  LIMIT post_limit;
$$;