/*
  # Create Mining Games System

  1. New Tables
    - `game_types`
      - `id` (uuid, primary key)
      - `name` (text) - Game name (Coin Flip, Dice, Crash, Mines)
      - `icon` (text) - Icon identifier
      - `min_bet` (numeric) - Minimum bet amount in EQ
      - `max_bet` (numeric) - Maximum bet amount in EQ
      - `house_edge` (numeric) - House edge percentage (1-5%)
      - `is_active` (boolean) - Game availability
      - `description` (text) - Game description
      - `created_at` (timestamp)

    - `user_game_history`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to auth.users)
      - `game_type_id` (uuid, foreign key to game_types)
      - `bet_amount` (numeric) - Amount bet in EQ
      - `multiplier` (numeric) - Win multiplier
      - `payout` (numeric) - Payout amount (0 if lost)
      - `profit` (numeric) - Net profit/loss
      - `game_data` (jsonb) - Game-specific data (result, choice, etc)
      - `server_seed` (text) - For provably fair
      - `client_seed` (text) - For provably fair
      - `nonce` (integer) - For provably fair
      - `result_hash` (text) - Result verification hash
      - `created_at` (timestamp)

    - `user_game_stats`
      - `user_id` (uuid, primary key, foreign key to auth.users)
      - `total_bets` (integer) - Total number of bets
      - `total_wagered` (numeric) - Total amount wagered
      - `total_won` (numeric) - Total amount won
      - `total_profit` (numeric) - Net profit (can be negative)
      - `biggest_win` (numeric) - Biggest single win
      - `win_streak` (integer) - Current win streak
      - `best_win_streak` (integer) - Best win streak ever
      - `last_played_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Users can view their own game history and stats
    - Users can insert their own game records
    - Public can view game types

  3. Functions
    - Function to place bet and record game result
    - Function to update user game stats
    - Function to get leaderboard

  4. Indexes
    - Index on user_id for game history
    - Index on created_at for recent games
*/

-- Create game_types table
CREATE TABLE IF NOT EXISTS game_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  icon text NOT NULL,
  min_bet numeric DEFAULT 1,
  max_bet numeric DEFAULT 10000,
  house_edge numeric DEFAULT 2.0,
  is_active boolean DEFAULT true,
  description text,
  created_at timestamptz DEFAULT now()
);

-- Create user_game_history table
CREATE TABLE IF NOT EXISTS user_game_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  game_type_id uuid REFERENCES game_types(id) ON DELETE CASCADE NOT NULL,
  bet_amount numeric NOT NULL CHECK (bet_amount > 0),
  multiplier numeric DEFAULT 0,
  payout numeric DEFAULT 0,
  profit numeric NOT NULL,
  game_data jsonb DEFAULT '{}'::jsonb,
  server_seed text,
  client_seed text,
  nonce integer,
  result_hash text,
  created_at timestamptz DEFAULT now()
);

-- Create user_game_stats table
CREATE TABLE IF NOT EXISTS user_game_stats (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  total_bets integer DEFAULT 0,
  total_wagered numeric DEFAULT 0,
  total_won numeric DEFAULT 0,
  total_profit numeric DEFAULT 0,
  biggest_win numeric DEFAULT 0,
  win_streak integer DEFAULT 0,
  best_win_streak integer DEFAULT 0,
  last_played_at timestamptz,
  updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_game_history_user_id ON user_game_history(user_id);
CREATE INDEX IF NOT EXISTS idx_game_history_created_at ON user_game_history(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_game_history_profit ON user_game_history(profit DESC);

-- Enable RLS
ALTER TABLE game_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_game_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_game_stats ENABLE ROW LEVEL SECURITY;

-- RLS Policies for game_types
CREATE POLICY "Anyone can view game types"
  ON game_types FOR SELECT
  TO authenticated
  USING (true);

-- RLS Policies for user_game_history
CREATE POLICY "Users can view own game history"
  ON user_game_history FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own game history"
  ON user_game_history FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for user_game_stats
CREATE POLICY "Users can view own game stats"
  ON user_game_stats FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own game stats"
  ON user_game_stats FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own game stats"
  ON user_game_stats FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Insert game types
INSERT INTO game_types (name, icon, min_bet, max_bet, house_edge, description) VALUES
('Coin Flip', '🪙', 1, 5000, 2.0, 'Classic heads or tails! Double your bet or lose it all. 50/50 chance with 2% house edge.'),
('Dice Roll', '🎲', 1, 5000, 2.5, 'Roll the dice and predict high or low! Adjust your risk for bigger multipliers.'),
('Crash', '🚀', 1, 5000, 3.0, 'Watch the multiplier rise and cash out before it crashes! The higher you go, the bigger the risk.'),
('Mines', '💣', 1, 5000, 2.0, 'Navigate through the minefield! More mines = higher rewards but greater risk.')
ON CONFLICT (name) DO NOTHING;

-- Function to update game stats after each game
CREATE OR REPLACE FUNCTION update_user_game_stats()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Insert or update user game stats
  INSERT INTO user_game_stats (
    user_id,
    total_bets,
    total_wagered,
    total_won,
    total_profit,
    biggest_win,
    win_streak,
    best_win_streak,
    last_played_at,
    updated_at
  ) VALUES (
    NEW.user_id,
    1,
    NEW.bet_amount,
    NEW.payout,
    NEW.profit,
    GREATEST(0, NEW.profit),
    CASE WHEN NEW.profit > 0 THEN 1 ELSE 0 END,
    CASE WHEN NEW.profit > 0 THEN 1 ELSE 0 END,
    NEW.created_at,
    now()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    total_bets = user_game_stats.total_bets + 1,
    total_wagered = user_game_stats.total_wagered + NEW.bet_amount,
    total_won = user_game_stats.total_won + NEW.payout,
    total_profit = user_game_stats.total_profit + NEW.profit,
    biggest_win = GREATEST(user_game_stats.biggest_win, NEW.profit),
    win_streak = CASE
      WHEN NEW.profit > 0 THEN user_game_stats.win_streak + 1
      ELSE 0
    END,
    best_win_streak = GREATEST(
      user_game_stats.best_win_streak,
      CASE WHEN NEW.profit > 0 THEN user_game_stats.win_streak + 1 ELSE 0 END
    ),
    last_played_at = NEW.created_at,
    updated_at = now();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update game stats
DROP TRIGGER IF EXISTS trigger_update_game_stats ON user_game_history;
CREATE TRIGGER trigger_update_game_stats
  AFTER INSERT ON user_game_history
  FOR EACH ROW
  EXECUTE FUNCTION update_user_game_stats();

-- Function to get game leaderboard (top winners)
CREATE OR REPLACE FUNCTION get_game_leaderboard(game_limit integer DEFAULT 20)
RETURNS TABLE (
  username text,
  avatar_url text,
  total_profit numeric,
  total_bets integer,
  biggest_win numeric,
  best_win_streak integer
)
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE(up.username, 'Player' || SUBSTRING(ugs.user_id::text, 1, 8)) as username,
    up.avatar_url,
    ugs.total_profit,
    ugs.total_bets,
    ugs.biggest_win,
    ugs.best_win_streak
  FROM user_game_stats ugs
  LEFT JOIN user_profiles up ON up.id = ugs.user_id
  WHERE ugs.total_profit > 0
  ORDER BY ugs.total_profit DESC
  LIMIT game_limit;
END;
$$ LANGUAGE plpgsql;

-- Function to get recent big wins (for live feed)
CREATE OR REPLACE FUNCTION get_recent_big_wins(win_limit integer DEFAULT 20)
RETURNS TABLE (
  username text,
  avatar_url text,
  game_name text,
  game_icon text,
  bet_amount numeric,
  multiplier numeric,
  payout numeric,
  profit numeric,
  created_at timestamptz
)
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE(up.username, 'Player' || SUBSTRING(ugh.user_id::text, 1, 8)) as username,
    up.avatar_url,
    gt.name as game_name,
    gt.icon as game_icon,
    ugh.bet_amount,
    ugh.multiplier,
    ugh.payout,
    ugh.profit,
    ugh.created_at
  FROM user_game_history ugh
  LEFT JOIN user_profiles up ON up.id = ugh.user_id
  JOIN game_types gt ON gt.id = ugh.game_type_id
  WHERE ugh.profit > 0
  ORDER BY ugh.created_at DESC
  LIMIT win_limit;
END;
$$ LANGUAGE plpgsql;
