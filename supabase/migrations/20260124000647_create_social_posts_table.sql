/*
  # Create Social Posts Table for Discover Feed

  1. New Tables
    - `social_posts`
      - `id` (uuid, primary key) - Unique post identifier
      - `username` (text) - Display name of the user
      - `avatar_url` (text) - User avatar image URL
      - `content` (text) - Post content/message
      - `coin_symbol` (text) - Trading pair symbol (BTC, ETH, etc.)
      - `trade_type` (text) - Type of trade (long/short)
      - `entry_price` (numeric) - Entry price of the trade
      - `exit_price` (numeric) - Exit price of the trade
      - `profit_loss` (numeric) - Profit/Loss amount in USD
      - `profit_loss_percent` (numeric) - Profit/Loss percentage
      - `leverage` (integer) - Leverage used (1-125x)
      - `image_url` (text, nullable) - Optional image attachment
      - `likes_count` (integer) - Number of likes
      - `comments_count` (integer) - Number of comments
      - `shares_count` (integer) - Number of shares
      - `is_bullish` (boolean) - True if profitable, false if loss
      - `created_at` (timestamptz) - Post creation timestamp

  2. Security
    - Enable RLS on `social_posts` table
    - Add policy for anyone to read posts (public feed)
    - Add policy for authenticated users to create posts

  3. Indexes
    - Index on `created_at` for sorting by newest first
    - Index on `coin_symbol` for filtering by coin
*/

CREATE TABLE IF NOT EXISTS social_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text NOT NULL,
  avatar_url text NOT NULL,
  content text NOT NULL,
  coin_symbol text NOT NULL,
  trade_type text NOT NULL CHECK (trade_type IN ('long', 'short')),
  entry_price numeric NOT NULL,
  exit_price numeric NOT NULL,
  profit_loss numeric NOT NULL,
  profit_loss_percent numeric NOT NULL,
  leverage integer NOT NULL DEFAULT 1 CHECK (leverage >= 1 AND leverage <= 125),
  image_url text,
  likes_count integer NOT NULL DEFAULT 0,
  comments_count integer NOT NULL DEFAULT 0,
  shares_count integer NOT NULL DEFAULT 0,
  is_bullish boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE social_posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read social posts"
  ON social_posts
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can create posts"
  ON social_posts
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_social_posts_created_at ON social_posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_social_posts_coin_symbol ON social_posts(coin_symbol);