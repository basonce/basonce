/*
  # Mining Persistence System
  
  1. Tables
    - `user_mining_sessions` - Stores active mining sessions for each user
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `miner_id` (text) - Equipment ID that is mining
      - `started_at` (timestamptz) - When mining started
      - `total_earned` (numeric) - Total EQ earned in this session
      - `is_active` (boolean) - Whether miner is currently active
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
    
    - `user_eq_balance` - Stores user's EQ coin balance
      - `user_id` (uuid, primary key, references auth.users)
      - `eq_amount` (numeric) - Total EQ balance
      - `last_session_start_balance` (numeric) - Balance when session started
      - `updated_at` (timestamptz)
  
  2. Security
    - Enable RLS on both tables
    - Users can only read/write their own data
    - Automatic timestamp updates
  
  3. Features
    - Persist mining state across page refreshes
    - Track earnings per miner
    - Store total EQ balance
*/

-- Create user_mining_sessions table
CREATE TABLE IF NOT EXISTS user_mining_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  miner_id text NOT NULL,
  started_at timestamptz DEFAULT now(),
  total_earned numeric DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, miner_id)
);

-- Create user_eq_balance table
CREATE TABLE IF NOT EXISTS user_eq_balance (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  eq_amount numeric DEFAULT 0,
  last_session_start_balance numeric DEFAULT 0,
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE user_mining_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_eq_balance ENABLE ROW LEVEL SECURITY;

-- Policies for user_mining_sessions
CREATE POLICY "Users can read own mining sessions"
  ON user_mining_sessions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own mining sessions"
  ON user_mining_sessions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own mining sessions"
  ON user_mining_sessions FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own mining sessions"
  ON user_mining_sessions FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Policies for user_eq_balance
CREATE POLICY "Users can read own eq balance"
  ON user_eq_balance FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own eq balance"
  ON user_eq_balance FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own eq balance"
  ON user_eq_balance FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_mining_sessions_user_active 
  ON user_mining_sessions(user_id, is_active);

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE user_mining_sessions;
ALTER PUBLICATION supabase_realtime ADD TABLE user_eq_balance;