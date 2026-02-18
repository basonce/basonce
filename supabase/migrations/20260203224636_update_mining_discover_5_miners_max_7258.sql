/*
  # Update Mining Discover - 5 Miners, Max $7,258 Earnings

  1. Changes
    - Reduce miners from 500 to 5 elite miners
    - Set maximum earnings to $7,258 (≈29,032 EQ at $0.25)
    - Professional Binance-style data
    - Realistic mining power and activity

  2. Security
    - Maintains existing RLS policies
*/

-- Clear existing data
TRUNCATE mining_discover_activities CASCADE;
TRUNCATE mining_discover_users CASCADE;

-- Create 5 elite miners with max $7,258 earnings
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
  usernames text[] := ARRAY['CryptoKing2847', 'MiningPro9124', 'HashMaster4589', 'BlockChainer7231', 'PowerMiner3456'];
  countries text[] := ARRAY['US', 'SG', 'JP', 'UK', 'CA'];
  avatar_nums int[] := ARRAY[15, 28, 42, 51, 67];
BEGIN
  FOR i IN 1..5 LOOP
    v_user_id := 'U#' || LPAD(i::text, 6, '0');
    v_username := usernames[i];
    v_avatar_num := avatar_nums[i];
    v_country := countries[i];

    -- Max earnings $7,258 = 29,032 EQ at $0.25
    -- Generate random between $2,000 and $7,258
    v_total_earned := (2000 + random() * 5258) / 0.25;
    v_total_withdrawn := (v_total_earned * (0.3 + random() * 0.4))::numeric(10, 2);
    v_mining_power := (15 + random() * 35)::numeric(10, 2);
    v_last_active := now() - (random() * interval '2 hours');

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

-- Generate realistic activities for each miner
DO $$
DECLARE
  v_user_record record;
  v_activity_type text;
  v_amount numeric;
  v_message text;
  v_created_at timestamptz;
BEGIN
  FOR v_user_record IN (SELECT * FROM mining_discover_users) LOOP
    -- Each miner gets 20-40 activities
    FOR i IN 1..(20 + floor(random() * 20))::int LOOP
      v_created_at := now() - (random() * interval '60 days');

      IF random() > 0.4 THEN
        v_activity_type := 'earning';
        v_amount := (random() * 300 + 50)::numeric(10, 2);
        v_message := 'Earned ' || v_amount || ' EQ from mining';
      ELSE
        v_activity_type := 'withdrawal';
        v_amount := (random() * 1500 + 200)::numeric(10, 2);
        v_message := 'Successfully withdrew ' || v_amount || ' EQ';
      END IF;

      INSERT INTO mining_discover_activities (
        discover_user_id, activity_type, amount, message, created_at
      ) VALUES (
        v_user_record.id, v_activity_type, v_amount, v_message, v_created_at
      );
    END LOOP;

    -- Add milestone activities
    IF v_user_record.total_earned >= 10000 THEN
      INSERT INTO mining_discover_activities (
        discover_user_id, activity_type, amount, message, created_at
      ) VALUES (
        v_user_record.id, 'milestone', 10000, 'Reached 10,000 EQ milestone!', now() - interval '10 days'
      );
    END IF;

    IF v_user_record.total_earned >= 20000 THEN
      INSERT INTO mining_discover_activities (
        discover_user_id, activity_type, amount, message, created_at
      ) VALUES (
        v_user_record.id, 'milestone', 20000, 'Reached 20,000 EQ milestone!', now() - interval '3 days'
      );
    END IF;
  END LOOP;
END $$;