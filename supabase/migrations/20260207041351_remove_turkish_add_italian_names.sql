/*
  # Remove Turkish Names, Add Italian Names

  1. Changes
    - Delete all existing messages
    - Regenerate 10,000 messages with Italian names instead of Turkish
    - Replace Turkish names: Ahmet, Mehmet, Mustafa, Ali, Hasan, Burak, Emre, Can, Cem, Eren
    - With Italian names: Marco, Giuseppe, Antonio, Francesco, Alessandro, Lorenzo, Matteo, Andrea, Luca, Giovanni

  2. Security
    - Maintain existing RLS policies
*/

DELETE FROM mining_chat_messages;

DO $$
DECLARE
  v_countries text[] := ARRAY['US', 'UK', 'CN', 'JP', 'KR', 'IT', 'DE', 'FR', 'CA', 'AU', 'BR', 'IN', 'ES', 'MX', 'NL', 'SE', 'NO', 'DK', 'FI', 'RU'];
  v_names text[] := ARRAY[
    'Alex', 'Mike', 'John', 'David', 'Chris', 'Ryan', 'Matt', 'Tom', 'James', 'Robert',
    'Sarah', 'Emma', 'Lisa', 'Anna', 'Maria', 'Sophie', 'Julia', 'Kate', 'Amy', 'Lucy',
    'Wei', 'Yuki', 'Jin', 'Min', 'Kenji', 'Hiroshi', 'Taro', 'Hiro', 'Ryu', 'Ken',
    'Marco', 'Giuseppe', 'Antonio', 'Francesco', 'Alessandro', 'Lorenzo', 'Matteo', 'Andrea', 'Luca', 'Giovanni',
    'Pedro', 'Carlos', 'Jose', 'Luis', 'Diego', 'Juan', 'Miguel', 'Pablo', 'Mario', 'Rafael'
  ];
  v_suffixes text[] := ARRAY['_miner', '_trader', '_pro', '_crypto', '_master', '_king', '_boss', '_legend', '123', '777', '888', '999', '2024', '2025'];

  v_withdrawal_msgs text[] := ARRAY[
    'Just withdrew $%s to my wallet! Instant!',
    'Cashed out $%s! This platform is legit!',
    'Withdrew $%s, already in my account!',
    'Successfully withdrew $%s! No issues at all!',
    'Got my $%s withdrawal! Super fast!',
    'Withdrawal of $%s completed! Amazing!',
    'Just received $%s in my wallet! Love it!',
    'Withdrew $%s profit! Time to celebrate!',
    'Easy withdrawal of $%s! Impressed!',
    'My $%s withdrawal went through instantly!'
  ];

  v_profit_msgs text[] := ARRAY[
    'My Quantum Miner earned $%s in 24 hours!',
    'Daily profit: $%s! This is insane!',
    'Made $%s today from mining! Best investment!',
    'Earning $%s per day consistently now!',
    'Just hit $%s in profits! Keep going!',
    'My miners generated $%s today! Awesome!',
    'Passive income of $%s daily! Life changing!',
    'ROI achieved! Making $%s per day now!',
    'Earned $%s while I was sleeping!',
    'Total earnings: $%s! This really works!'
  ];

  v_upgrade_msgs text[] := ARRAY[
    'Just upgraded to ASIC Miner! Profit tripled!',
    'Bought Quantum Datacenter! Best decision ever!',
    'Upgraded to premium! Earnings doubled!',
    'New equipment purchased! ROI in 3 days!',
    'Just got the Fusion Reactor! Earning big now!',
    'Upgraded my mining rig! Best choice!',
    'Invested in new equipment! Already paying off!',
    'Bought 3 more miners! Scaling up!',
    'New mining setup complete! Profits soaring!',
    'Equipment upgrade done! Returns doubled!'
  ];

  v_milestone_msgs text[] := ARRAY[
    'Hit $%s total earnings! Thank you team!',
    'Made $%s in my first week! Unbelievable!',
    'Hit my $%s target today! Dreams do come true!',
    'First $%s earned! Many more to come!',
    'Broke $%s total profit! This is real!',
    'Reached $%s milestone! Incredible journey!',
    'Just hit $%s! Next goal double that!',
    'Total profit: $%s! Life changing money!',
    'Achieved $%s today! So grateful!',
    'Made $%s this month! Best decision ever!'
  ];

  v_tip_msgs text[] := ARRAY[
    'Pro tip: Compound your earnings! Best strategy!',
    'Quantum Datacenter has the best ROI! Just saying!',
    'Start small, scale up! Proven method!',
    'Reinvest at least 50% of profits! Trust me!',
    'Time is money in mining! Start now!',
    'Diversify your miners! Risk management!',
    'Always withdraw regularly! Secure your profits!',
    'Level up your miners ASAP! Higher returns!',
    'Join the VIP room for exclusive tips! Worth it!',
    'Set realistic goals! Consistency is key!'
  ];

  v_celebration_msgs text[] := ARRAY[
    'Today is a good day! $%s earned!',
    'This platform changed my life! $%s and counting!',
    'Who else is making $%s+ daily?',
    'Almost didn''t start! Now at $%s in profit!',
    'Best community ever! We all winning!',
    'To the moon! $%s withdrawn this week!',
    'Living the dream! $%s passive income daily!',
    'Started 2 weeks ago, already at $%s! Insane!',
    'This is not a game! Real $%s in my account!',
    'Financial freedom! $%s milestone achieved!'
  ];

  v_general_msgs text[] := ARRAY[
    'Anyone else mining with Quantum Datacenter?',
    'What is your daily profit goal?',
    'How long until I can upgrade to ASIC?',
    'Just joined! Any tips for beginners?',
    'The returns are insane! Loving this!',
    'Support team is super helpful! Shoutout!',
    'How many miners do you guys run?',
    'This is way better than traditional investing!',
    'Who has been here for 6+ months? Results?',
    'Cannot stop checking my balance!'
  ];

  v_username text;
  v_amount numeric;
  v_level int;
  v_country text;
  v_message text;
  v_type text;
  v_is_featured boolean;
  v_created_at timestamptz;
  v_base_time timestamptz;
  i int;

BEGIN
  v_base_time := now() - interval '30 days';

  FOR i IN 1..10000 LOOP
    v_username := v_names[1 + floor(random() * array_length(v_names, 1))] || v_suffixes[1 + floor(random() * array_length(v_suffixes, 1))];
    v_country := v_countries[1 + floor(random() * array_length(v_countries, 1))];
    v_level := 1 + floor(random() * 5);
    v_created_at := v_base_time + (random() * interval '30 days');
    v_type := (ARRAY['withdrawal', 'profit', 'upgrade', 'milestone', 'tip', 'celebration', 'general', 'withdrawal', 'profit', 'profit'])[1 + floor(random() * 10)];

    CASE v_type
      WHEN 'withdrawal' THEN
        v_amount := (50 + random() * 9950)::numeric(10,2);
        v_message := replace(v_withdrawal_msgs[1 + floor(random() * array_length(v_withdrawal_msgs, 1))], '%s', v_amount::text);
        v_is_featured := v_amount > 5000;

      WHEN 'profit' THEN
        v_amount := (20 + random() * 4980)::numeric(10,2);
        v_message := replace(v_profit_msgs[1 + floor(random() * array_length(v_profit_msgs, 1))], '%s', v_amount::text);
        v_is_featured := v_amount > 2000;

      WHEN 'upgrade' THEN
        v_amount := (100 + random() * 4900)::numeric(10,2);
        v_message := v_upgrade_msgs[1 + floor(random() * array_length(v_upgrade_msgs, 1))];
        v_is_featured := false;

      WHEN 'milestone' THEN
        v_amount := (500 + random() * 49500)::numeric(10,2);
        v_message := replace(v_milestone_msgs[1 + floor(random() * array_length(v_milestone_msgs, 1))], '%s', v_amount::text);
        v_is_featured := v_amount > 10000;

      WHEN 'tip' THEN
        v_amount := 0;
        v_message := v_tip_msgs[1 + floor(random() * array_length(v_tip_msgs, 1))];
        v_is_featured := false;

      WHEN 'celebration' THEN
        v_amount := (100 + random() * 9900)::numeric(10,2);
        v_message := replace(v_celebration_msgs[1 + floor(random() * array_length(v_celebration_msgs, 1))], '%s', v_amount::text);
        v_is_featured := v_amount > 5000;

      ELSE
        v_amount := 0;
        v_message := v_general_msgs[1 + floor(random() * array_length(v_general_msgs, 1))];
        v_is_featured := false;
    END CASE;

    INSERT INTO mining_chat_messages (
      username,
      avatar_url,
      message,
      message_type,
      amount,
      level,
      country,
      is_featured,
      created_at
    ) VALUES (
      v_username,
      'https://i.pravatar.cc/150?u=' || v_username || i::text,
      v_message,
      v_type,
      v_amount,
      v_level,
      v_country,
      v_is_featured,
      v_created_at
    );

    IF i % 1000 = 0 THEN
      RAISE NOTICE 'Generated % messages', i;
    END IF;
  END LOOP;

  RAISE NOTICE 'Successfully regenerated 10,000 mining chat messages with Italian names';
END $$;