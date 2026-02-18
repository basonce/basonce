/*
  # Update Chat Messages with Realistic Earnings - Final

  1. Changes
    - Regenerate all mining chat messages with realistic earnings based on current equipment prices
    - Messages reflect actual equipment capabilities:
      - CPU Miner (Free): $25-130 range
      - GPU Miner Pro (150 EQ): $100-250 range
      - ASIC Miner Pro (400 EQ): $200-712 range
      - Mining Farm (1000 EQ): $500-1880 range
      - Industrial (2500 EQ): $1000-4975 range
      - Quantum (5000 EQ): $2000-11500 range
    - Update discover users with realistic mining stats
    - Update success feed with realistic amounts
    - Keep natural conversation style

  2. Security
    - No RLS changes needed
*/

-- Delete old chat messages
TRUNCATE mining_chat_messages;

-- Insert new realistic chat messages
INSERT INTO mining_chat_messages (username, message, message_type, amount, level, avatar_url, country, created_at)
SELECT 
  ap.username,
  CASE msg_type
    -- profit messages (40%)
    WHEN 1 THEN 
      CASE (random() * 6)::int
        WHEN 0 THEN 'Started with free CPU Miner, already earned $' || amount::text || '!'
        WHEN 1 THEN 'My ' || equipment || ' made $' || amount::text || ' today'
        WHEN 2 THEN 'Just hit $' || amount::text || ' in profits'
        WHEN 3 THEN 'Daily profit: $' || amount::text
        WHEN 4 THEN 'Made $' || amount::text || ' in passive income'
        ELSE 'Total earnings reached $' || amount::text
      END
    -- withdrawal messages (15%)
    WHEN 2 THEN 
      CASE (random() * 3)::int
        WHEN 0 THEN 'Just withdrew $' || amount::text || ' to my wallet'
        WHEN 1 THEN 'Cashed out $' || amount::text || ' profit'
        ELSE 'Withdrawal successful: $' || amount::text
      END
    -- milestone messages (15%)
    WHEN 3 THEN 
      CASE (random() * 3)::int
        WHEN 0 THEN 'Reached $' || amount::text || ' total earnings'
        WHEN 1 THEN 'Hit my goal! $' || amount::text || ' and counting'
        ELSE 'Milestone: $' || amount::text || ' earned'
      END
    -- upgrade messages (15%)
    WHEN 4 THEN 
      CASE (random() * 3)::int
        WHEN 0 THEN 'Upgraded to ' || equipment || '! Earning $' || amount::text || ' daily'
        WHEN 1 THEN 'New ' || equipment || ' is a beast. $' || amount::text || ' already'
        ELSE 'Invested in ' || equipment || ', made $' || amount::text || ' back'
      END
    -- celebration messages (10%)
    WHEN 5 THEN 
      CASE (random() * 3)::int
        WHEN 0 THEN 'Best decision ever! $' || amount::text || ' and loving it'
        WHEN 1 THEN 'This is amazing! $' || amount::text || ' in just few days'
        ELSE 'Life changing! $' || amount::text || ' passive income'
      END
    -- general/tip messages (5%)
    ELSE 
      CASE (random() * 3)::int
        WHEN 0 THEN 'Start small, grow big. I''m at $' || amount::text || ' now'
        WHEN 1 THEN 'Patience pays off. $' || amount::text || ' so far'
        ELSE 'Free miner is perfect to start!'
      END
  END as message,
  CASE msg_type
    WHEN 1 THEN 'profit'
    WHEN 2 THEN 'withdrawal'
    WHEN 3 THEN 'milestone'
    WHEN 4 THEN 'upgrade'
    WHEN 5 THEN 'celebration'
    ELSE 'general'
  END as message_type,
  amount,
  CASE 
    WHEN amount < 150 THEN (random() * 3 + 1)::int
    WHEN amount < 500 THEN (random() * 3 + 2)::int
    WHEN amount < 2000 THEN (random() * 2 + 3)::int
    ELSE (random() * 2 + 4)::int
  END as level,
  ap.avatar_url,
  ap.country,
  NOW() - (random() * interval '7 days') as created_at
FROM anonymous_profiles ap
CROSS JOIN LATERAL (
  SELECT 
    ((random() * 5)::int + 1) as msg_type,
    CASE 
      WHEN random() < 0.30 THEN (25 + random() * 105)::numeric(10,2)  -- CPU Miner range
      WHEN random() < 0.50 THEN (100 + random() * 150)::numeric(10,2)  -- GPU range
      WHEN random() < 0.70 THEN (200 + random() * 512)::numeric(10,2)  -- ASIC range
      WHEN random() < 0.85 THEN (500 + random() * 1380)::numeric(10,2)  -- Farm range
      WHEN random() < 0.95 THEN (1000 + random() * 3975)::numeric(10,2)  -- Industrial range
      ELSE (2000 + random() * 9500)::numeric(10,2)  -- Quantum range
    END as amount,
    CASE (random() * 5)::int
      WHEN 0 THEN 'CPU Miner'
      WHEN 1 THEN 'GPU Miner Pro'
      WHEN 2 THEN 'ASIC Miner Pro'
      WHEN 3 THEN 'Mining Farm'
      WHEN 4 THEN 'Industrial Station'
      ELSE 'Quantum Datacenter'
    END as equipment
) sub
WHERE ap.id <= 5000
ORDER BY random()
LIMIT 10000;

-- Update mining discover users with realistic earnings and mining power
UPDATE mining_discover_users
SET 
  total_earned = CASE 
    WHEN random() < 0.30 THEN (100 + random() * 500)::numeric(10,2)
    WHEN random() < 0.50 THEN (500 + random() * 1500)::numeric(10,2)
    WHEN random() < 0.70 THEN (1500 + random() * 3500)::numeric(10,2)
    WHEN random() < 0.85 THEN (3500 + random() * 8500)::numeric(10,2)
    WHEN random() < 0.95 THEN (8500 + random() * 25000)::numeric(10,2)
    ELSE (25000 + random() * 100000)::numeric(10,2)
  END,
  mining_power = CASE 
    WHEN random() < 0.30 THEN (25 + random() * 75)::numeric(10,2)
    WHEN random() < 0.50 THEN (100 + random() * 150)::numeric(10,2)
    WHEN random() < 0.70 THEN (200 + random() * 300)::numeric(10,2)
    WHEN random() < 0.85 THEN (500 + random() * 500)::numeric(10,2)
    WHEN random() < 0.95 THEN (1000 + random() * 2000)::numeric(10,2)
    ELSE (5000 + random() * 5000)::numeric(10,2)
  END;

-- Update success feed with realistic amounts
UPDATE mining_success_feed
SET 
  amount = CASE 
    WHEN random() < 0.40 THEN (25 + random() * 225)::numeric(10,2)
    WHEN random() < 0.70 THEN (200 + random() * 1500)::numeric(10,2)
    ELSE (1000 + random() * 10500)::numeric(10,2)
  END
WHERE type IN ('withdrawal', 'mining', 'upgrade', 'milestone');
