/*
  # Update Mining Chat Messages with DiceBear Avatars

  1. Changes
    - Regenerate all mining chat messages with DiceBear avatars
    - Use anonymous_profiles for realistic data
    - Maintain message types and amounts

  2. DiceBear Benefits
    - Free and unlimited
    - Consistent avatars per user
    - Works reliably
*/

-- Delete old mining chat messages
DELETE FROM mining_chat_messages;

-- Insert 10,000 chat messages with DiceBear avatars from anonymous_profiles
DO $$
DECLARE
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
    'Cannot stop checking my balance!',
    'Best passive income stream ever!',
    'Mining while working my 9-5!',
    'Just bought my second miner!',
    'EQ price looking good today!',
    'Who else is here for the long term?'
  ];
  
  v_amount numeric;
  v_level int;
  v_message text;
  v_type text;
  v_is_featured boolean;
  v_created_at timestamptz;
  v_base_time timestamptz;
  i int;
  profile_rec record;
BEGIN
  v_base_time := now() - interval '30 days';

  FOR i IN 1..10000 LOOP
    -- Get random profile
    SELECT id, username, country INTO profile_rec
    FROM anonymous_profiles
    ORDER BY random()
    LIMIT 1;
    
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

    -- Insert with DiceBear avatar
    INSERT INTO mining_chat_messages (
      profile_id,
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
      profile_rec.id,
      profile_rec.username,
      'https://api.dicebear.com/7.x/avataaars/svg?seed=' || profile_rec.id,
      v_message,
      v_type,
      v_amount,
      v_level,
      profile_rec.country,
      v_is_featured,
      v_created_at
    );
  END LOOP;

  RAISE NOTICE 'Successfully generated 10,000 mining chat messages with DiceBear avatars';
END $$;
