/*
  # Expand Voice Messages Feed with 1000+ Messages
  
  1. Purpose
    - Add 1000+ diverse voice messages for live voice room
    - Create engaging, realistic mining community conversations
    - Support 114-1318 concurrent listener simulation
  
  2. Message Categories
    - earnings: Users sharing their mining profits
    - withdrawal: Users talking about successful withdrawals
    - equipment: Users discussing mining equipment upgrades
    - motivation: Encouraging messages for new miners
    - advice: Mining tips and strategies
  
  3. Content Distribution
    - 40% earnings messages (profitable miners)
    - 20% withdrawal messages (successful cashouts)
    - 15% equipment messages (upgrade discussions)
    - 15% motivation messages (community support)
    - 10% advice messages (tips and tricks)
*/

DO $$
DECLARE
  profile_ids INT[] := ARRAY(SELECT id FROM anonymous_profiles ORDER BY RANDOM() LIMIT 270);
  profile_id INT;
  msg_count INT := 0;
  
  earnings_msgs TEXT[] := ARRAY[
    'Just collected $1,247 from my GPU rig! This is incredible!',
    'My ASIC miner paid off in 3 months, now pure profit baby!',
    '$890 in 24 hours from my mining farm. Best investment ever!',
    'Made $2,100 this week alone. Mining is printing money!',
    'Holy cow! $3,450 profit this month from just 5 machines',
    'My electricity bill is $200, I made $1,800. Easy math!',
    'Started with one CPU miner, now earning $450/day across 12 units',
    '$567 overnight while I slept. This is passive income done right!',
    'Just hit $10K total earnings milestone! Started 4 months ago',
    'My mining operation is generating $125/hour consistently',
    'Upgraded to industrial miners, now pulling $4,200/week',
    'ROI achieved! Everything from now on is pure profit',
    'Making more from mining than my day job. About to quit!',
    '$1,890 today alone. My neighbors think I am crazy rich now',
    'Portfolio crossed $50K thanks to consistent mining rewards',
    'Daily average is $670 now. Life changing money here!',
    'My 3 ASIC units are making $2,340/week like clockwork',
    'Just reinvested $5K in new equipment. Scaling up fast!',
    'Hit $100K total mined. Started with just $2K investment',
    'Earning $890/day now. Compound interest is real!'
  ];
  
  withdrawal_msgs TEXT[] := ARRAY[
    'Withdrew $5,000 to my bank account. Arrived in 2 hours!',
    'Just cashed out $2,340 via USDT. Instant transfer!',
    'Withdrawal of $8,900 processed successfully. Amazing platform!',
    'Got my $3,200 withdrawal. Buying a new gaming PC!',
    'Successfully withdrew $12,000. Paid off my student loans!',
    'Cashed out $4,560 yesterday. Money hit my account today!',
    'Just withdrew $1,890 for the third time this month. Smooth!',
    '$6,700 withdrawal cleared. Taking my family on vacation!',
    'Withdrew $9,100 to buy a car. Dreams coming true!',
    'Got my $2,890 payout. Zero issues, instant processing!',
    'Just cashed out $15,000. Bought my mom a new house!',
    'Withdrawal of $7,200 successful. Reinvesting half back in!',
    'Got $4,300 in my bank. Third withdrawal this month!',
    'Cashed out $11,000. Starting my own business now!',
    'Withdrew $3,670 for Christmas shopping. Family will love it!',
    '$8,400 withdrawal processed in minutes. Impressive speed!',
    'Just got $5,900. Putting a down payment on a house!',
    'Cashed out $2,100. Small but consistent profits!',
    'Withdrew $13,500. Officially financially free now!',
    'Got my $6,200 payout. Best passive income ever!'
  ];
  
  equipment_msgs TEXT[] := ARRAY[
    'Just upgraded to Quantum Miner X9. Earnings doubled!',
    'Bought 3 ASIC Elite units. ROI in 2 months max!',
    'My new GPU farm is insane. 15 RTX 4090s running 24/7',
    'Upgraded cooling system. Efficiency up 40%!',
    'Just installed Solar AI Miner. Using 70% less power!',
    'Got the new Fusion Reactor 5000. Beast mode activated!',
    'Upgraded from CPU to ASIC. Night and day difference!',
    'Added 10 more GPUs to my rig. Scaling like crazy!',
    'New industrial setup cost $30K but earning $500/day now',
    'Upgraded power supply. Running 20 miners simultaneously!',
    'Just bought Cosmic Drill Pro. Mining speed insane!',
    'New liquid cooling system. Zero downtime now!',
    'Upgraded to 480V industrial power. Game changer!',
    'Got 5 ASIC miners on sale. Already profitable!',
    'New warehouse setup complete. 50 miners running!',
    'Upgraded firmware. 25% efficiency boost immediately!',
    'Just installed noise reduction. Neighbors happy now!',
    'New rack system holds 30 miners. Organization matters!',
    'Upgraded network infrastructure. Zero latency issues!',
    'Got industrial fans. Temperature under control finally!'
  ];
  
  motivation_msgs TEXT[] := ARRAY[
    'Started with $100, now earning $400/day. Never give up!',
    'To all beginners: Stay consistent. Results will come!',
    'Your first dollar mined is the hardest. Keep pushing!',
    'I failed 3 times before this. Persistence pays off!',
    'Small equipment? No problem! Start where you are!',
    'Everyone here started from zero. You can do it too!',
    'Patience is key. Took me 2 months to see big results',
    'Do not compare your day 1 to someone else day 100',
    'Consistency beats intensity. Mine every single day!',
    'Your future self will thank you for starting today',
    'Set it and forget it. Let the machines work for you!',
    'Invest in knowledge first, equipment second',
    'Community support helped me succeed. Ask questions!',
    'Track your progress daily. Small wins add up big!',
    'Started scared, now earning $600/day. You got this!',
    'Educate yourself. Watch tutorials. Learn constantly!',
    'My first week earned $12. Now earning $1200/week!',
    'Upgrade gradually. Do not rush. Build steadily!',
    'Join the L4 club! Earnings unlock at that level!',
    'Passive income is real. I am living proof of it!'
  ];
  
  advice_msgs TEXT[] := ARRAY[
    'Pro tip: Reinvest 50% of profits for exponential growth',
    'Run equipment at 80% capacity for longevity and efficiency',
    'Best ROI: Start with mid-tier ASIC, upgrade quarterly',
    'Track your kwh cost. Efficiency is profit multiplier!',
    'Diversify equipment. Different miners for different coins',
    'Join mining pools for consistent daily payouts',
    'Set alerts for equipment downtime. Every minute counts!',
    'Optimize during off-peak electricity hours for max profit',
    'Cloud mining is ok to start but physical rigs scale better',
    'Calculate ROI before every purchase. Emotions kill profits',
    'Hot tip: GPU mining flexibility beats ASIC single-purpose',
    'Monitor difficulty rates. Adjust strategy monthly!',
    'Network with other miners. Share knowledge, grow together',
    'Tax planning is crucial. Track every transaction!',
    'Security first! Use hardware wallets for large amounts',
    'Start small, prove the model, then scale aggressively',
    'Noise and heat management saves money long-term',
    'Automation tools 10x your operation efficiency',
    'Seasonal strategy: Mine hard in winter, save on cooling',
    'VIP rooms at L4 unlock insider strategies. Push for it!'
  ];
  
  celebration_msgs TEXT[] := ARRAY[
    'MILESTONE! Just hit $100K total earnings! Champagne time!',
    'OMG! $15,000 in ONE DAY! My biggest day ever!',
    'Finally reached L5 status! The VIP benefits are insane!',
    'Just bought a Tesla with mining profits! Dreams do come true!',
    'BROKE $1M total mined! Started with just $5K! Unbelievable!',
    'Quit my job today! Full-time miner now! Freedom achieved!',
    'My mining farm hit 100 machines! Industrial level unlocked!',
    'Just received $50K withdrawal! Bought a house cash!',
    'RECORD! $8,900 in 24 hours! New personal best!',
    'Reached $500K portfolio! Thank you mining community!',
    'Just upgraded to 50 ASIC miners! Empire mode activated!',
    'My monthly income hit $45K! This is life changing!',
    'Got verified millionaire status! Mining changed my life!',
    'JACKPOT! Equipment upgrade paid off 300% this month!',
    'Just earned more in mining than my entire year salary!',
    'Finally achieved financial independence! Thank you all!',
    'Bought my dream car with pure mining profits! Surreal!',
    'Hit top 10 earners list! Feeling incredibly blessed!',
    'My mining revenue exceeded $200K this quarter! Wow!',
    '$25K profit in one week! This is absolutely insane!'
  ];
  
BEGIN
  -- Loop through profiles and create diverse messages
  FOREACH profile_id IN ARRAY profile_ids LOOP
    -- Earnings messages (40%)
    FOR i IN 1..4 LOOP
      INSERT INTO voice_messages (
        user_id, text_content, emotion, voice_gender, voice_name,
        category, play_order, is_active
      ) VALUES (
        profile_id,
        earnings_msgs[1 + floor(random() * array_length(earnings_msgs, 1))],
        CASE floor(random() * 4)
          WHEN 0 THEN 'excited'
          WHEN 1 THEN 'happy'
          WHEN 2 THEN 'enthusiastic'
          ELSE 'confident'
        END,
        CASE WHEN random() > 0.5 THEN 'female' ELSE 'male' END,
        CASE WHEN random() > 0.5 THEN 'Samantha' ELSE 'Daniel' END,
        'earnings',
        floor(random() * 10000),
        true
      );
      msg_count := msg_count + 1;
    END LOOP;
    
    -- Withdrawal messages (20%)
    FOR i IN 1..2 LOOP
      INSERT INTO voice_messages (
        user_id, text_content, emotion, voice_gender, voice_name,
        category, play_order, is_active
      ) VALUES (
        profile_id,
        withdrawal_msgs[1 + floor(random() * array_length(withdrawal_msgs, 1))],
        CASE floor(random() * 3)
          WHEN 0 THEN 'happy'
          WHEN 1 THEN 'excited'
          ELSE 'emotional'
        END,
        CASE WHEN random() > 0.5 THEN 'female' ELSE 'male' END,
        CASE WHEN random() > 0.5 THEN 'Victoria' ELSE 'Alex' END,
        'withdrawal',
        floor(random() * 10000),
        true
      );
      msg_count := msg_count + 1;
    END LOOP;
    
    -- Equipment messages (15%)
    IF random() > 0.3 THEN
      INSERT INTO voice_messages (
        user_id, text_content, emotion, voice_gender, voice_name,
        category, play_order, is_active
      ) VALUES (
        profile_id,
        equipment_msgs[1 + floor(random() * array_length(equipment_msgs, 1))],
        CASE floor(random() * 3)
          WHEN 0 THEN 'enthusiastic'
          WHEN 1 THEN 'excited'
          ELSE 'confident'
        END,
        CASE WHEN random() > 0.5 THEN 'female' ELSE 'male' END,
        CASE WHEN random() > 0.5 THEN 'Karen' ELSE 'Tom' END,
        'equipment',
        floor(random() * 10000),
        true
      );
      msg_count := msg_count + 1;
    END IF;
    
    -- Motivation messages (15%)
    IF random() > 0.3 THEN
      INSERT INTO voice_messages (
        user_id, text_content, emotion, voice_gender, voice_name,
        category, play_order, is_active
      ) VALUES (
        profile_id,
        motivation_msgs[1 + floor(random() * array_length(motivation_msgs, 1))],
        CASE floor(random() * 3)
          WHEN 0 THEN 'calm'
          WHEN 1 THEN 'confident'
          ELSE 'happy'
        END,
        CASE WHEN random() > 0.5 THEN 'female' ELSE 'male' END,
        CASE WHEN random() > 0.5 THEN 'Emma' ELSE 'James' END,
        'motivation',
        floor(random() * 10000),
        true
      );
      msg_count := msg_count + 1;
    END IF;
    
    -- Advice messages (10%)
    IF random() > 0.5 THEN
      INSERT INTO voice_messages (
        user_id, text_content, emotion, voice_gender, voice_name,
        category, play_order, is_active
      ) VALUES (
        profile_id,
        advice_msgs[1 + floor(random() * array_length(advice_msgs, 1))],
        CASE floor(random() * 3)
          WHEN 0 THEN 'thoughtful'
          WHEN 1 THEN 'confident'
          ELSE 'calm'
        END,
        CASE WHEN random() > 0.5 THEN 'female' ELSE 'male' END,
        CASE WHEN random() > 0.5 THEN 'Sophia' ELSE 'Michael' END,
        'advice',
        floor(random() * 10000),
        true
      );
      msg_count := msg_count + 1;
    END IF;
    
    -- Celebration messages (bonus, rare)
    IF random() > 0.85 THEN
      INSERT INTO voice_messages (
        user_id, text_content, emotion, voice_gender, voice_name,
        category, play_order, is_active
      ) VALUES (
        profile_id,
        celebration_msgs[1 + floor(random() * array_length(celebration_msgs, 1))],
        'excited',
        CASE WHEN random() > 0.5 THEN 'female' ELSE 'male' END,
        CASE WHEN random() > 0.5 THEN 'Isabella' ELSE 'Chris' END,
        'earnings',
        floor(random() * 10000),
        true
      );
      msg_count := msg_count + 1;
    END IF;
  END LOOP;
  
  RAISE NOTICE 'Successfully created % voice messages', msg_count;
END $$;
