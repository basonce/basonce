/*
  # Fix Only Exclamation Marks - Natural Messages

  1. Changes
    - Remove excessive exclamation marks
    - Mix of . ? and occasional !
    - Everyone can earn any amount (no level restrictions)
    - More natural conversation style
*/

TRUNCATE TABLE mining_chat_messages;

DO $$
DECLARE
  v_countries text[] := ARRAY['US', 'UK', 'CN', 'JP', 'KR', 'TR', 'DE', 'FR', 'CA', 'AU', 'BR', 'IN', 'IT', 'ES', 'MX'];

  v_withdrawal text[] := ARRAY[
    'Just withdrew $%s to my wallet.',
    'Cashed out $%s today.',
    'Withdrew $%s, already in my account',
    'Successfully withdrew $%s.',
    'Got my $%s withdrawal',
    'Just received $%s in my wallet',
    'Withdrew $%s profit',
    'Easy withdrawal of $%s',
    'My $%s withdrawal went through',
    'Withdrawal of $%s completed'
  ];

  v_profit text[] := ARRAY[
    'Made $%s today from mining',
    'Daily profit: $%s',
    'Earning $%s per day now',
    'Just hit $%s in profits',
    'My miners generated $%s today',
    'Passive income of $%s daily',
    'Making $%s per day',
    'Earned $%s while sleeping',
    'Total earnings: $%s',
    'Got $%s from my miner today'
  ];

  v_upgrade text[] := ARRAY[
    'Just upgraded to ASIC Miner. Profit tripled',
    'Bought Quantum Datacenter. Best decision',
    'Upgraded to premium. Earnings doubled',
    'New equipment purchased. ROI in 3 days',
    'Just got the Fusion Reactor',
    'Upgraded my mining rig today',
    'Invested in new equipment',
    'Bought 3 more miners. Scaling up',
    'New mining setup complete',
    'Equipment upgrade done. Returns doubled'
  ];

  v_milestone text[] := ARRAY[
    'Hit $%s total earnings. Thank you team',
    'Made $%s in my first week',
    'Hit my $%s target today',
    'First $%s earned',
    'Broke $%s total profit',
    'Reached $%s milestone',
    'Just hit $%s',
    'Total profit: $%s so far',
    'Achieved $%s today',
    'Made $%s this month'
  ];

  v_tip text[] := ARRAY[
    'Pro tip: Compound your earnings',
    'Quantum Datacenter has the best ROI',
    'Start small, scale up',
    'Reinvest at least 50% of profits',
    'Time is money in mining. Start now',
    'Diversify your miners for better returns',
    'Always withdraw regularly',
    'Level up your miners ASAP',
    'Join the VIP room for exclusive tips',
    'Set realistic goals. Consistency is key'
  ];

  v_celebration text[] := ARRAY[
    'Today is a good day. $%s earned',
    'This platform changed my life. $%s and counting',
    'Making $%s daily now',
    'Started recently, now at $%s',
    'Best community ever',
    'Made $%s this week',
    'Living the dream. $%s daily',
    'Started 2 weeks ago, already at $%s',
    'Real $%s in my account',
    '$%s milestone achieved'
  ];

  v_general text[] := ARRAY[
    'Anyone else mining with Quantum Datacenter?',
    'What is your daily profit goal',
    'How long until I can upgrade to ASIC?',
    'Just joined. Any tips for beginners?',
    'The returns are great',
    'Support team is super helpful',
    'How many miners do you guys run',
    'This is better than traditional investing',
    'Who has been here for 6+ months',
    'Cannot stop checking my balance'
  ];

  v_profile record;
  v_amount numeric;
  v_level int;
  v_message text;
  v_type text;
  v_is_featured boolean;
  v_created_at timestamptz;
  i int;

BEGIN
  FOR i IN 1..10000 LOOP
    SELECT * INTO v_profile FROM anonymous_profiles ORDER BY random() LIMIT 1;

    v_level := 1 + floor(random() * 5)::INTEGER;
    v_created_at := now() - (random() * interval '30 days');
    v_type := (ARRAY['withdrawal', 'profit', 'upgrade', 'milestone', 'tip', 'celebration', 'general', 'profit', 'profit', 'profit'])[1 + floor(random() * 10)];

    CASE v_type
      WHEN 'withdrawal' THEN
        v_amount := CASE 
          WHEN random() < 0.4 THEN (20 + random() * 280)::numeric(10,2)
          WHEN random() < 0.7 THEN (300 + random() * 1700)::numeric(10,2)
          ELSE (2000 + random() * 8000)::numeric(10,2)
        END;
        v_message := replace(v_withdrawal[1 + floor(random() * array_length(v_withdrawal, 1))], '%s', v_amount::text);
        v_is_featured := v_amount > 5000;

      WHEN 'profit' THEN
        v_amount := CASE 
          WHEN random() < 0.4 THEN (5 + random() * 95)::numeric(10,2)
          WHEN random() < 0.7 THEN (100 + random() * 900)::numeric(10,2)
          ELSE (1000 + random() * 4000)::numeric(10,2)
        END;
        v_message := replace(v_profit[1 + floor(random() * array_length(v_profit, 1))], '%s', v_amount::text);
        v_is_featured := v_amount > 2000;

      WHEN 'upgrade' THEN
        v_amount := 0;
        v_message := v_upgrade[1 + floor(random() * array_length(v_upgrade, 1))];
        v_is_featured := false;

      WHEN 'milestone' THEN
        v_amount := CASE 
          WHEN random() < 0.4 THEN (50 + random() * 450)::numeric(10,2)
          WHEN random() < 0.7 THEN (500 + random() * 4500)::numeric(10,2)
          ELSE (5000 + random() * 45000)::numeric(10,2)
        END;
        v_message := replace(v_milestone[1 + floor(random() * array_length(v_milestone, 1))], '%s', v_amount::text);
        v_is_featured := v_amount > 10000;

      WHEN 'tip' THEN
        v_amount := 0;
        v_message := v_tip[1 + floor(random() * array_length(v_tip, 1))];
        v_is_featured := false;

      WHEN 'celebration' THEN
        v_amount := CASE 
          WHEN random() < 0.5 THEN (20 + random() * 480)::numeric(10,2)
          ELSE (500 + random() * 9500)::numeric(10,2)
        END;
        v_message := replace(v_celebration[1 + floor(random() * array_length(v_celebration, 1))], '%s', v_amount::text);
        v_is_featured := v_amount > 5000;

      ELSE
        v_amount := 0;
        v_message := v_general[1 + floor(random() * array_length(v_general, 1))];
        v_is_featured := false;
    END CASE;

    INSERT INTO mining_chat_messages (
      username, avatar_url, message, message_type,
      amount, level, country, is_featured, created_at
    ) VALUES (
      v_profile.username, v_profile.avatar_url, v_message, v_type,
      v_amount, v_level, v_profile.country, v_is_featured, v_created_at
    );
  END LOOP;
END $$;
