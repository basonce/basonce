/*
  # Mining Discover System - Professional Binance-Style

  1. New Tables
    - `mining_discover_users`
      - `id` (uuid, primary key)
      - `user_id` (text, unique) - Display ID like "U#123456"
      - `username` (text) - Display name
      - `avatar_url` (text) - Pravatar API URL
      - `country` (text) - Country code
      - `total_earned` (numeric) - Total EQ earned
      - `total_withdrawn` (numeric) - Total EQ withdrawn
      - `mining_power` (numeric) - Current mining power (EQ/hour)
      - `last_active` (timestamptz) - Last activity time
      - `created_at` (timestamptz)

    - `mining_discover_activities`
      - `id` (uuid, primary key)
      - `discover_user_id` (uuid, FK to mining_discover_users)
      - `activity_type` (text) - 'earning', 'withdrawal', 'milestone'
      - `amount` (numeric) - Amount in EQ
      - `message` (text) - Activity message
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on both tables
    - Public read access for discovery features
    - No write access from clients (server-only)

  3. Data
    - Create 500 realistic mining users with Pravatar avatars
    - Generate thousands of realistic activities
*/

-- Create mining_discover_users table
CREATE TABLE IF NOT EXISTS mining_discover_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id text UNIQUE NOT NULL,
  username text NOT NULL,
  avatar_url text NOT NULL,
  country text NOT NULL,
  total_earned numeric DEFAULT 0 NOT NULL,
  total_withdrawn numeric DEFAULT 0 NOT NULL,
  mining_power numeric DEFAULT 0 NOT NULL,
  last_active timestamptz DEFAULT now() NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- Create mining_discover_activities table
CREATE TABLE IF NOT EXISTS mining_discover_activities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  discover_user_id uuid REFERENCES mining_discover_users(id) ON DELETE CASCADE NOT NULL,
  activity_type text NOT NULL CHECK (activity_type IN ('earning', 'withdrawal', 'milestone')),
  amount numeric NOT NULL,
  message text NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_mining_discover_users_total_earned ON mining_discover_users(total_earned DESC);
CREATE INDEX IF NOT EXISTS idx_mining_discover_activities_created_at ON mining_discover_activities(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_mining_discover_activities_user ON mining_discover_activities(discover_user_id);

-- Enable RLS
ALTER TABLE mining_discover_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE mining_discover_activities ENABLE ROW LEVEL SECURITY;

-- Public read access for discovery features
CREATE POLICY "Anyone can view mining discover users"
  ON mining_discover_users FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can view mining discover activities"
  ON mining_discover_activities FOR SELECT
  TO public
  USING (true);

-- Generate 500 realistic mining users with Pravatar avatars
DO $$
DECLARE
  v_user_id text;
  v_username text;
  v_avatar_num int;
  v_country text;
  v_total_earned numeric;
  v_total_withdrawn numeric;
  v_mining_power numeric;
  v_last_active timestamptz;
  countries text[] := ARRAY['US', 'CN', 'JP', 'KR', 'SG', 'UK', 'DE', 'FR', 'CA', 'AU', 'BR', 'IN', 'RU', 'TR', 'ES', 'IT', 'NL', 'CH', 'SE', 'NO'];
  usernames text[] := ARRAY['CryptoKing', 'MiningPro', 'HashMaster', 'BlockChainer', 'DigitalMiner', 'CoinHunter', 'EQMaster', 'PowerMiner', 'CryptoNinja', 'MiningBoss', 'BitDigger', 'EarnQuester', 'HashHero', 'CryptoGuru', 'MiningLord', 'BlockMiner', 'EQKing', 'HashPro', 'CoinMaster', 'DigitalKing'];
BEGIN
  FOR i IN 1..500 LOOP
    v_user_id := 'U#' || LPAD(i::text, 6, '0');
    v_username := usernames[1 + floor(random() * array_length(usernames, 1))::int] || floor(random() * 9999)::int;
    v_avatar_num := floor(random() * 70)::int;
    v_country := countries[1 + floor(random() * array_length(countries, 1))::int];
    v_total_earned := (random() * 50000 + 100)::numeric(10, 2);
    v_total_withdrawn := (v_total_earned * (random() * 0.5))::numeric(10, 2);
    v_mining_power := (random() * 50 + 5)::numeric(10, 2);
    v_last_active := now() - (random() * interval '7 days');

    INSERT INTO mining_discover_users (
      user_id, username, avatar_url, country,
      total_earned, total_withdrawn, mining_power, last_active
    ) VALUES (
      v_user_id,
      v_username,
      'https://i.pravatar.cc/150?img=' || v_avatar_num,
      v_country,
      v_total_earned,
      v_total_withdrawn,
      v_mining_power,
      v_last_active
    );
  END LOOP;
END $$;

-- Generate realistic mining activities
DO $$
DECLARE
  v_user_record record;
  v_activity_type text;
  v_amount numeric;
  v_message text;
  v_created_at timestamptz;
  activity_types text[] := ARRAY['earning', 'withdrawal', 'milestone'];
BEGIN
  FOR v_user_record IN (SELECT * FROM mining_discover_users ORDER BY random() LIMIT 300) LOOP
    FOR i IN 1..(floor(random() * 10) + 5)::int LOOP
      v_activity_type := activity_types[1 + floor(random() * array_length(activity_types, 1))::int];
      v_created_at := now() - (random() * interval '30 days');

      CASE v_activity_type
        WHEN 'earning' THEN
          v_amount := (random() * 500 + 10)::numeric(10, 2);
          v_message := 'Earned ' || v_amount || ' EQ from mining';
        WHEN 'withdrawal' THEN
          v_amount := (random() * 1000 + 50)::numeric(10, 2);
          v_message := 'Withdrew ' || v_amount || ' EQ';
        WHEN 'milestone' THEN
          v_amount := (floor(random() * 10) + 1) * 1000;
          v_message := 'Reached ' || v_amount || ' EQ milestone!';
      END CASE;

      INSERT INTO mining_discover_activities (
        discover_user_id, activity_type, amount, message, created_at
      ) VALUES (
        v_user_record.id, v_activity_type, v_amount, v_message, v_created_at
      );
    END LOOP;
  END LOOP;
END $$;

-- Create function to get live stats
CREATE OR REPLACE FUNCTION get_mining_discover_stats()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result json;
BEGIN
  SELECT json_build_object(
    'total_miners', COUNT(*),
    'active_miners_24h', COUNT(*) FILTER (WHERE last_active > now() - interval '24 hours'),
    'total_earned', COALESCE(SUM(total_earned), 0),
    'total_withdrawn', COALESCE(SUM(total_withdrawn), 0),
    'avg_mining_power', COALESCE(AVG(mining_power), 0)
  )
  INTO v_result
  FROM mining_discover_users;

  RETURN v_result;
END;
$$;

-- Create function to add simulated live activity
CREATE OR REPLACE FUNCTION simulate_mining_activity()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_record record;
  v_amount numeric;
  v_activity_type text;
BEGIN
  SELECT * INTO v_user_record
  FROM mining_discover_users
  ORDER BY random()
  LIMIT 1;

  IF random() > 0.5 THEN
    v_activity_type := 'earning';
    v_amount := (random() * 100 + 5)::numeric(10, 2);

    INSERT INTO mining_discover_activities (discover_user_id, activity_type, amount, message)
    VALUES (v_user_record.id, v_activity_type, v_amount, 'Earned ' || v_amount || ' EQ from mining');

    UPDATE mining_discover_users
    SET total_earned = total_earned + v_amount, last_active = now()
    WHERE id = v_user_record.id;
  ELSE
    v_activity_type := 'withdrawal';
    v_amount := (random() * 500 + 50)::numeric(10, 2);

    INSERT INTO mining_discover_activities (discover_user_id, activity_type, amount, message)
    VALUES (v_user_record.id, v_activity_type, v_amount, 'Withdrew ' || v_amount || ' EQ');

    UPDATE mining_discover_users
    SET total_withdrawn = total_withdrawn + v_amount, last_active = now()
    WHERE id = v_user_record.id;
  END IF;
END;
$$;