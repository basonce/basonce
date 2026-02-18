/*
  # Fix Chat Messages Random Amounts

  1. Changes
    - Fix the random amount generation bug
    - Each message should have a different random amount
    - Use UPDATE to set unique random values after insert

  2. Security
    - No RLS changes needed
*/

-- Update all messages with truly random amounts
UPDATE mining_chat_messages
SET amount = CASE 
  WHEN random() < 0.30 THEN (25 + random() * 105)::numeric(10,2)
  WHEN random() < 0.50 THEN (100 + random() * 150)::numeric(10,2)
  WHEN random() < 0.70 THEN (200 + random() * 512)::numeric(10,2)
  WHEN random() < 0.85 THEN (500 + random() * 1380)::numeric(10,2)
  WHEN random() < 0.95 THEN (1000 + random() * 3975)::numeric(10,2)
  ELSE (2000 + random() * 9500)::numeric(10,2)
END;

-- Update messages to include the amount in the text
UPDATE mining_chat_messages
SET message = CASE 
  WHEN message_type = 'profit' THEN 
    CASE (random() * 6)::int
      WHEN 0 THEN 'Started with free CPU Miner, already earned $' || amount::text || '!'
      WHEN 1 THEN 'My mining rig made $' || amount::text || ' today'
      WHEN 2 THEN 'Just hit $' || amount::text || ' in profits'
      WHEN 3 THEN 'Daily profit: $' || amount::text
      WHEN 4 THEN 'Made $' || amount::text || ' in passive income'
      ELSE 'Total earnings reached $' || amount::text
    END
  WHEN message_type = 'withdrawal' THEN 
    CASE (random() * 3)::int
      WHEN 0 THEN 'Just withdrew $' || amount::text || ' to my wallet'
      WHEN 1 THEN 'Cashed out $' || amount::text || ' profit'
      ELSE 'Withdrawal successful: $' || amount::text
    END
  WHEN message_type = 'milestone' THEN 
    CASE (random() * 3)::int
      WHEN 0 THEN 'Reached $' || amount::text || ' total earnings'
      WHEN 1 THEN 'Hit my goal! $' || amount::text || ' and counting'
      ELSE 'Milestone: $' || amount::text || ' earned'
    END
  WHEN message_type = 'upgrade' THEN 
    CASE (random() * 5)::int
      WHEN 0 THEN 'Upgraded to GPU Miner Pro! Earning $' || amount::text || ' daily'
      WHEN 1 THEN 'New ASIC Miner is a beast. $' || amount::text || ' already'
      WHEN 2 THEN 'Invested in Mining Farm, made $' || amount::text || ' back'
      WHEN 3 THEN 'Industrial Station earning $' || amount::text || ' daily'
      ELSE 'Quantum Datacenter profit: $' || amount::text
    END
  WHEN message_type = 'celebration' THEN 
    CASE (random() * 3)::int
      WHEN 0 THEN 'Best decision ever! $' || amount::text || ' and loving it'
      WHEN 1 THEN 'This is amazing! $' || amount::text || ' in just few days'
      ELSE 'Life changing! $' || amount::text || ' passive income'
    END
  ELSE 
    CASE (random() * 3)::int
      WHEN 0 THEN 'Start small, grow big. I''m at $' || amount::text || ' now'
      WHEN 1 THEN 'Patience pays off. $' || amount::text || ' so far'
      ELSE 'Free miner is perfect to start!'
    END
END;

-- Update level based on amount
UPDATE mining_chat_messages
SET level = CASE 
  WHEN amount < 150 THEN (random() * 3 + 1)::int
  WHEN amount < 500 THEN (random() * 3 + 2)::int
  WHEN amount < 2000 THEN (random() * 2 + 3)::int
  ELSE (random() * 2 + 4)::int
END;
