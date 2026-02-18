/*
  # Fix Mining Discover - 3 Miners Only

  1. Changes
    - Reduce to exactly 3 elite miners
    - Max $7,258 earnings maintained
    - Professional realistic data
*/

-- Clear existing data
TRUNCATE mining_discover_activities CASCADE;
TRUNCATE mining_discover_users CASCADE;

-- Create exactly 3 elite miners
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
  usernames text[] := ARRAY['CryptoKing2847', 'MiningPro9124', 'HashMaster4589'];
  countries text[] := ARRAY['US', 'SG', 'JP'];
  avatar_nums int[] := ARRAY[15, 28, 42];
BEGIN
  FOR i IN 1..3 LOOP
    v_user_id := 'U#' || LPAD(i::text, 6, '0');
    v_username := usernames[i];
    v_avatar_num := avatar_nums[i];
    v_country := countries[i];
    v_total_earned := (3000 + random() * 4258) / 0.25;
    v_total_withdrawn := (v_total_earned * (0.35 + random() * 0.35))::numeric(10, 2);
    v_mining_power := (20 + random() * 30)::numeric(10, 2);
    v_last_active := now() - (random() * interval '1 hour');

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

-- Generate activities for each miner
DO $$
DECLARE
  v_user_record record;
  v_activity_type text;
  v_amount numeric;
  v_message text;
  v_created_at timestamptz;
BEGIN
  FOR v_user_record IN (SELECT * FROM mining_discover_users) LOOP
    FOR i IN 1..30 LOOP
      v_created_at := now() - (random() * interval '45 days');

      IF random() > 0.35 THEN
        v_activity_type := 'earning';
        v_amount := (random() * 400 + 100)::numeric(10, 2);
        v_message := 'Earned ' || v_amount || ' EQ from mining';
      ELSE
        v_activity_type := 'withdrawal';
        v_amount := (random() * 2000 + 300)::numeric(10, 2);
        v_message := 'Successfully withdrew ' || v_amount || ' EQ';
      END IF;

      INSERT INTO mining_discover_activities (
        discover_user_id, activity_type, amount, message, created_at
      ) VALUES (
        v_user_record.id, v_activity_type, v_amount, v_message, v_created_at
      );
    END LOOP;

    IF v_user_record.total_earned >= 15000 THEN
      INSERT INTO mining_discover_activities (
        discover_user_id, activity_type, amount, message, created_at
      ) VALUES (
        v_user_record.id, 'milestone', 15000, 'Reached 15,000 EQ milestone!', now() - interval '5 days'
      );
    END IF;
  END LOOP;
END $$;