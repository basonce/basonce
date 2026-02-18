/*
  # Create Reward Wheel System (Casino Style) - v2

  1. New Tables
    - `reward_wheel_prizes` - Prize configuration (8 sectors)
    - `user_spin_balance` - User spin count tracking
    - `reward_wheel_history` - Spin history and winners feed
    - `active_mining_boosts` - Active boost tracking
    - `daily_missions` - Available missions
    - `user_mission_progress` - User mission completion
    - `lucky_hour_schedule` - Lucky hour times

  2. Security
    - Enable RLS on all tables
    - Users can read own data
    - Public can view prizes, missions, winners

  3. Functions
    - spin_reward_wheel() - Main spin function
    - claim_daily_free_spin() - Daily free spin
    - check_lucky_hour() - Check if lucky hour active
    - award_spins() - Award spins for activities
*/

CREATE TABLE IF NOT EXISTS reward_wheel_prizes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prize_type text NOT NULL CHECK (prize_type IN ('futures_bonus', 'mining_boost', 'eq_tokens', 'mining_equipment', 'mega_jackpot')),
  prize_name text NOT NULL,
  prize_value numeric NOT NULL CHECK (prize_value > 0),
  probability numeric NOT NULL CHECK (probability >= 0 AND probability <= 100),
  color text NOT NULL,
  icon text NOT NULL,
  is_active boolean DEFAULT true,
  sort_order integer NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_spin_balance (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  available_spins integer DEFAULT 1 CHECK (available_spins >= 0),
  total_spins_earned integer DEFAULT 1,
  total_spins_used integer DEFAULT 0,
  last_daily_spin timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS reward_wheel_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  prize_id uuid NOT NULL REFERENCES reward_wheel_prizes(id),
  prize_name text NOT NULL,
  prize_value numeric NOT NULL,
  prize_type text NOT NULL,
  claimed_at timestamptz DEFAULT now(),
  is_visible_in_feed boolean DEFAULT true
);

CREATE TABLE IF NOT EXISTS active_mining_boosts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  boost_multiplier numeric NOT NULL CHECK (boost_multiplier >= 1),
  duration_hours integer NOT NULL CHECK (duration_hours > 0),
  started_at timestamptz DEFAULT now(),
  expires_at timestamptz NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS daily_missions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  mission_type text NOT NULL CHECK (mission_type IN ('mine_eq', 'futures_trade', 'referral', 'daily_login', 'equipment_purchase', 'deposit')),
  mission_name text NOT NULL,
  mission_description text NOT NULL,
  target_value numeric NOT NULL,
  spin_reward integer NOT NULL DEFAULT 1,
  icon text NOT NULL,
  is_active boolean DEFAULT true,
  sort_order integer NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_mission_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  mission_id uuid NOT NULL REFERENCES daily_missions(id) ON DELETE CASCADE,
  current_progress numeric DEFAULT 0,
  is_completed boolean DEFAULT false,
  completed_at timestamptz,
  reset_date date DEFAULT CURRENT_DATE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, mission_id, reset_date)
);

CREATE TABLE IF NOT EXISTS lucky_hour_schedule (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  hour_start time NOT NULL,
  hour_end time NOT NULL,
  multiplier numeric NOT NULL DEFAULT 5,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE reward_wheel_prizes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_spin_balance ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_wheel_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE active_mining_boosts ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_mission_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE lucky_hour_schedule ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active prizes"
  ON reward_wheel_prizes FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "Users can view own spin balance"
  ON user_spin_balance FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own spin balance"
  ON user_spin_balance FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can insert own spin balance"
  ON user_spin_balance FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own wheel history"
  ON reward_wheel_history FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can view recent winners feed"
  ON reward_wheel_history FOR SELECT
  TO authenticated
  USING (is_visible_in_feed = true);

CREATE POLICY "Users can view own mining boosts"
  ON active_mining_boosts FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Anyone can view active missions"
  ON daily_missions FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "Users can view own mission progress"
  ON user_mission_progress FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own mission progress"
  ON user_mission_progress FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can insert own mission progress"
  ON user_mission_progress FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Anyone can view lucky hour schedule"
  ON lucky_hour_schedule FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE INDEX IF NOT EXISTS idx_user_spin_balance_user_id ON user_spin_balance(user_id);
CREATE INDEX IF NOT EXISTS idx_reward_history_user_id ON reward_wheel_history(user_id);
CREATE INDEX IF NOT EXISTS idx_reward_history_feed ON reward_wheel_history(claimed_at DESC) WHERE is_visible_in_feed = true;
CREATE INDEX IF NOT EXISTS idx_mining_boosts_user_active ON active_mining_boosts(user_id, is_active, expires_at);
CREATE INDEX IF NOT EXISTS idx_mission_progress_user_date ON user_mission_progress(user_id, reset_date);

INSERT INTO reward_wheel_prizes (prize_type, prize_name, prize_value, probability, color, icon, sort_order) VALUES
  ('futures_bonus', '5 USDT Bonus', 5, 25, '#10b981', '💰', 1),
  ('mining_boost', '24h 3x Speed', 24, 20, '#fbbf24', '⚡', 2),
  ('eq_tokens', '1-3 EQ', 2, 18, '#3b82f6', '🪙', 3),
  ('futures_bonus', '15 USDT Bonus', 15, 12, '#8b5cf6', '💎', 4),
  ('mining_equipment', 'GPU Rig', 1, 10, '#f97316', '🖥️', 5),
  ('eq_tokens', '10-25 EQ', 17.5, 8, '#06b6d4', '💰', 6),
  ('futures_bonus', '50 USDT Bonus', 50, 5, '#ef4444', '🔥', 7),
  ('mega_jackpot', '200 USDT MEGA!', 200, 2, '#ec4899', '⭐', 8)
ON CONFLICT DO NOTHING;

INSERT INTO daily_missions (mission_type, mission_name, mission_description, target_value, spin_reward, icon, sort_order) VALUES
  ('mine_eq', 'Mine 5 EQ Today', 'Mine at least 5 EQ tokens', 5, 1, '⛏️', 1),
  ('futures_trade', 'Make 1 Trade', 'Execute 1 futures trade', 1, 1, '📈', 2),
  ('referral', 'Invite 1 Friend', 'Refer 1 new user', 1, 3, '🤝', 3),
  ('daily_login', '7-Day Login Streak', 'Login 7 days in a row', 7, 5, '🔥', 4),
  ('equipment_purchase', 'Buy Equipment', 'Purchase mining equipment', 1, 2, '🛒', 5),
  ('deposit', 'Deposit 50+ USDT', 'Deposit at least 50 USDT', 50, 5, '💵', 6)
ON CONFLICT DO NOTHING;

INSERT INTO lucky_hour_schedule (hour_start, hour_end, multiplier) VALUES
  ('12:00:00', '13:00:00', 5),
  ('20:00:00', '21:00:00', 5)
ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION check_lucky_hour()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_time time;
  v_is_lucky boolean;
BEGIN
  v_current_time := LOCALTIME;

  SELECT EXISTS (
    SELECT 1 FROM lucky_hour_schedule
    WHERE is_active = true
    AND v_current_time >= hour_start
    AND v_current_time <= hour_end
  ) INTO v_is_lucky;

  RETURN v_is_lucky;
END;
$$;

CREATE OR REPLACE FUNCTION claim_daily_free_spin()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_last_claim timestamptz;
  v_hours_since_last numeric;
BEGIN
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Not authenticated');
  END IF;

  INSERT INTO user_spin_balance (user_id, available_spins, last_daily_spin)
  VALUES (v_user_id, 1, now())
  ON CONFLICT (user_id) DO NOTHING;

  SELECT last_daily_spin INTO v_last_claim
  FROM user_spin_balance
  WHERE user_id = v_user_id;

  v_hours_since_last := EXTRACT(EPOCH FROM (now() - v_last_claim)) / 3600;

  IF v_hours_since_last < 24 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Daily spin already claimed',
      'hours_remaining', ROUND(24 - v_hours_since_last, 1)
    );
  END IF;

  UPDATE user_spin_balance
  SET available_spins = available_spins + 1,
      total_spins_earned = total_spins_earned + 1,
      last_daily_spin = now(),
      updated_at = now()
  WHERE user_id = v_user_id;

  RETURN json_build_object('success', true, 'spins_added', 1);
END;
$$;

CREATE OR REPLACE FUNCTION spin_reward_wheel()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_available_spins integer;
  v_random numeric;
  v_cumulative numeric := 0;
  v_prize record;
  v_is_lucky_hour boolean;
  v_adjusted_probability numeric;
BEGIN
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Not authenticated');
  END IF;

  SELECT available_spins INTO v_available_spins
  FROM user_spin_balance
  WHERE user_id = v_user_id;

  IF v_available_spins IS NULL OR v_available_spins < 1 THEN
    RETURN json_build_object('success', false, 'error', 'No spins available');
  END IF;

  v_is_lucky_hour := check_lucky_hour();
  v_random := random() * 100;

  FOR v_prize IN
    SELECT * FROM reward_wheel_prizes
    WHERE is_active = true
    ORDER BY sort_order
  LOOP
    IF v_is_lucky_hour AND v_prize.prize_value >= 50 THEN
      v_adjusted_probability := LEAST(v_prize.probability * 5, 100);
    ELSE
      v_adjusted_probability := v_prize.probability;
    END IF;

    v_cumulative := v_cumulative + v_adjusted_probability;

    IF v_random <= v_cumulative THEN
      UPDATE user_spin_balance
      SET available_spins = available_spins - 1,
          total_spins_used = total_spins_used + 1,
          updated_at = now()
      WHERE user_id = v_user_id;

      INSERT INTO reward_wheel_history (user_id, prize_id, prize_name, prize_value, prize_type)
      VALUES (v_user_id, v_prize.id, v_prize.prize_name, v_prize.prize_value, v_prize.prize_type);

      CASE v_prize.prize_type
        WHEN 'futures_bonus' THEN
          UPDATE user_balances
          SET futures_balance = futures_balance + v_prize.prize_value,
              updated_at = now()
          WHERE user_id = v_user_id;

        WHEN 'eq_tokens' THEN
          UPDATE user_mining_data
          SET total_mined = total_mined + v_prize.prize_value,
              updated_at = now()
          WHERE user_id = v_user_id;

        WHEN 'mining_boost' THEN
          INSERT INTO active_mining_boosts (user_id, boost_multiplier, duration_hours, expires_at)
          VALUES (v_user_id, 3, v_prize.prize_value::integer, now() + (v_prize.prize_value || ' hours')::interval);

        WHEN 'mining_equipment' THEN
          UPDATE user_mining_data
          SET equipment_count = equipment_count + 1,
              updated_at = now()
          WHERE user_id = v_user_id;

        WHEN 'mega_jackpot' THEN
          UPDATE user_balances
          SET futures_balance = futures_balance + v_prize.prize_value,
              updated_at = now()
          WHERE user_id = v_user_id;
      END CASE;

      RETURN json_build_object(
        'success', true,
        'prize', json_build_object(
          'name', v_prize.prize_name,
          'value', v_prize.prize_value,
          'type', v_prize.prize_type,
          'color', v_prize.color,
          'icon', v_prize.icon
        ),
        'is_lucky_hour', v_is_lucky_hour
      );
    END IF;
  END LOOP;

  RETURN json_build_object('success', false, 'error', 'Prize calculation error');
END;
$$;

CREATE OR REPLACE FUNCTION award_spins(
  p_user_id uuid,
  p_spin_count integer,
  p_reason text DEFAULT 'Activity reward'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO user_spin_balance (user_id, available_spins, total_spins_earned)
  VALUES (p_user_id, p_spin_count, p_spin_count)
  ON CONFLICT (user_id) DO UPDATE
  SET available_spins = user_spin_balance.available_spins + p_spin_count,
      total_spins_earned = user_spin_balance.total_spins_earned + p_spin_count,
      updated_at = now();
END;
$$;

CREATE OR REPLACE FUNCTION initialize_user_spin_balance()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO user_spin_balance (user_id, available_spins, total_spins_earned)
  VALUES (NEW.id, 1, 1)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created_init_spins ON auth.users;
CREATE TRIGGER on_auth_user_created_init_spins
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION initialize_user_spin_balance();