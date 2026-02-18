/*
  # Live Room Hayali Kullanıcılar ve Mesajlar - Final
  
  1. Yeni Tablo
    - dummy_users - Hayali kullanıcılar (auth'a bağlı değil)
  
  2. Değişiklikler
    - live_room_participants ve messages için user_id nullable yap
    - dummy_user_id kolonları ekle
    - Her oda için host, co-host, listener'lar oluştur
    - Chat mesajları ekle
*/

CREATE TABLE IF NOT EXISTS dummy_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text NOT NULL,
  avatar_url text NOT NULL,
  verification_status text DEFAULT 'regular' CHECK (verification_status IN ('regular', 'verified', 'vip', 'premium')),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE dummy_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view dummy users"
  ON dummy_users FOR SELECT
  TO public
  USING (true);

ALTER TABLE live_room_participants 
  ALTER COLUMN user_id DROP NOT NULL;

ALTER TABLE live_room_messages 
  ALTER COLUMN user_id DROP NOT NULL;

ALTER TABLE live_room_participants 
  ADD COLUMN IF NOT EXISTS dummy_user_id uuid REFERENCES dummy_users(id);

ALTER TABLE live_room_messages 
  ADD COLUMN IF NOT EXISTS dummy_user_id uuid REFERENCES dummy_users(id);

DO $$
DECLARE
  v_room_id uuid;
  v_host_id uuid;
  v_cohost1_id uuid;
  v_cohost2_id uuid;
  v_cohost3_id uuid;
  v_listener_ids uuid[] := ARRAY[]::uuid[];
  v_room_record RECORD;
  room_count integer := 0;
  i integer;
BEGIN
  FOR v_room_record IN 
    SELECT id FROM live_rooms WHERE is_active = true ORDER BY listener_count DESC LIMIT 22
  LOOP
    v_room_id := v_room_record.id;
    room_count := room_count + 1;
    
    INSERT INTO dummy_users (username, avatar_url, verification_status)
    VALUES 
      (CASE room_count % 10
         WHEN 0 THEN 'Emma-加密貨幣'
         WHEN 1 THEN 'CryptoQueen'
         WHEN 2 THEN 'BTCTrader88'
         WHEN 3 THEN 'DeFiMaster'
         WHEN 4 THEN 'WhaleWatcher'
         WHEN 5 THEN 'MoonShot'
         WHEN 6 THEN 'DiamondHands'
         WHEN 7 THEN 'CryptoGuru'
         WHEN 8 THEN 'TradingPro'
         ELSE 'MarketMaker'
       END,
       '/ber' || ((room_count % 50) + 1)::text || '.jpg',
       'vip')
    RETURNING id INTO v_host_id;
    
    INSERT INTO live_room_participants (room_id, dummy_user_id, role, is_speaking)
    VALUES (v_room_id, v_host_id, 'host', true);
    
    INSERT INTO dummy_users (username, avatar_url, verification_status)
    VALUES 
      (CASE (room_count * 2) % 10
         WHEN 0 THEN 'BF神话小哥'
         WHEN 1 THEN 'Nexus_Crypto'
         WHEN 2 THEN 'AlexZizi'
         WHEN 3 THEN 'TechTrader'
         WHEN 4 THEN 'BlockchainBob'
         WHEN 5 THEN 'CryptoSage'
         WHEN 6 THEN 'MarketWizard'
         WHEN 7 THEN 'TokenKing'
         WHEN 8 THEN 'ChartMaster'
         ELSE 'TradeGenius'
       END,
       '/ber' || (((room_count * 2) % 50) + 1)::text || '.jpg',
       'verified')
    RETURNING id INTO v_cohost1_id;
    
    INSERT INTO dummy_users (username, avatar_url, verification_status)
    VALUES 
      (CASE (room_count * 3) % 10
         WHEN 0 THEN 'Elena神'
         WHEN 1 THEN 'SufyanQuan'
         WHEN 2 THEN 'Rabiahh'
         WHEN 3 THEN 'CryptoNinja'
         WHEN 4 THEN 'TradingQueen'
         WHEN 5 THEN 'BitcoinBoss'
         WHEN 6 THEN 'AltcoinAce'
         WHEN 7 THEN 'DeFiDiva'
         WHEN 8 THEN 'NFTHunter'
         ELSE 'MetaTrader'
       END,
       '/ber' || (((room_count * 3) % 50) + 1)::text || '.jpg',
       'verified')
    RETURNING id INTO v_cohost2_id;
    
    INSERT INTO live_room_participants (room_id, dummy_user_id, role, is_speaking)
    VALUES 
      (v_room_id, v_cohost1_id, 'co-host', (room_count % 3 = 0)),
      (v_room_id, v_cohost2_id, 'co-host', false);
    
    IF room_count % 3 = 0 THEN
      INSERT INTO dummy_users (username, avatar_url)
      VALUES (CASE (room_count * 4) % 10
                WHEN 0 THEN 'Coin_Lover'
                WHEN 1 THEN 'Hyung-mi'
                WHEN 2 THEN 'Saif Ali-95'
                ELSE 'CryptoFan' || room_count::text
              END,
              '/ber' || (((room_count * 4) % 50) + 1)::text || '.jpg')
      RETURNING id INTO v_cohost3_id;
      
      INSERT INTO live_room_participants (room_id, dummy_user_id, role, is_speaking)
      VALUES (v_room_id, v_cohost3_id, 'co-host', false);
    END IF;
    
    FOR i IN 1..15 LOOP
      DECLARE
        v_listener_id uuid;
      BEGIN
        INSERT INTO dummy_users (username, avatar_url)
        VALUES (CASE (room_count + i) % 20
                  WHEN 0 THEN 'BullMarket'
                  WHEN 1 THEN 'BearKiller'
                  WHEN 2 THEN 'MoonBoy'
                  WHEN 3 THEN 'DiamondGirl'
                  WHEN 4 THEN 'HODLer'
                  WHEN 5 THEN 'Rekt_Trader'
                  WHEN 6 THEN 'PumpChaser'
                  WHEN 7 THEN 'DipBuyer'
                  WHEN 8 THEN 'YieldFarmer'
                  WHEN 9 THEN 'StakeHolder'
                  WHEN 10 THEN 'GasOptimizer'
                  WHEN 11 THEN 'SmartMoney'
                  WHEN 12 THEN 'WhaleAlert'
                  WHEN 13 THEN 'RugPull'
                  WHEN 14 THEN 'DeFiDegen'
                  WHEN 15 THEN 'NFTFlipper'
                  WHEN 16 THEN 'MemeLord'
                  WHEN 17 THEN 'ApeStrong'
                  WHEN 18 THEN 'ToTheMoon'
                  ELSE 'CryptoFan' || (room_count + i)::text
                END,
                '/ber' || (((room_count * 5 + i) % 50) + 1)::text || '.jpg')
        RETURNING id INTO v_listener_id;
        
        INSERT INTO live_room_participants (room_id, dummy_user_id, role, is_speaking)
        VALUES (v_room_id, v_listener_id, 'listener', false);
        
        v_listener_ids := array_append(v_listener_ids, v_listener_id);
      END;
    END LOOP;
    
    INSERT INTO live_room_messages (room_id, dummy_user_id, message, created_at)
    VALUES
      (v_room_id, v_host_id, 
       CASE room_count % 10
         WHEN 0 THEN '444'
         WHEN 1 THEN 'Welcome everyone! 🚀'
         WHEN 2 THEN 'BTC looking bullish!'
         WHEN 3 THEN 'Who''s ready for profits? 💰'
         WHEN 4 THEN 'ETH to $5000!'
         WHEN 5 THEN 'Market analysis incoming'
         WHEN 6 THEN 'Trading signals ready'
         WHEN 7 THEN 'Let''s make money today'
         WHEN 8 THEN 'Big moves coming'
         ELSE 'Ready to trade!'
       END, NOW() - (room_count || ' minutes')::interval),
      (v_room_id, v_cohost1_id,
       CASE (room_count * 2) % 10
         WHEN 0 THEN '888✨'
         WHEN 1 THEN 'Good analysis host!'
         WHEN 2 THEN 'I agree 100%'
         WHEN 3 THEN 'Just took profits at 2x'
         WHEN 4 THEN 'Should we long here?'
         WHEN 5 THEN 'Chart looks perfect'
         WHEN 6 THEN 'Support is strong'
         WHEN 7 THEN 'Resistance broken!'
         WHEN 8 THEN 'Volume increasing'
         ELSE 'Great setup!'
       END, NOW() - (room_count + 1 || ' minutes')::interval),
      (v_room_id, v_cohost2_id,
       CASE (room_count * 3) % 10
         WHEN 0 THEN 'co host me please'
         WHEN 1 THEN 'What''s the entry price?'
         WHEN 2 THEN 'Stop loss at?'
         WHEN 3 THEN 'Target profit?'
         WHEN 4 THEN 'Which leverage?'
         WHEN 5 THEN 'Spot or futures?'
         WHEN 6 THEN 'Market or limit?'
         WHEN 7 THEN 'Long or short?'
         WHEN 8 THEN 'When to sell?'
         ELSE 'Show me the trade'
       END, NOW() - (room_count + 2 || ' minutes')::interval);
    
    IF room_count % 2 = 0 THEN
      FOR i IN 1..5 LOOP
        IF array_length(v_listener_ids, 1) >= i THEN
          INSERT INTO live_room_messages (room_id, dummy_user_id, message, created_at)
          VALUES (v_room_id, v_listener_ids[i],
            CASE i % 15
              WHEN 0 THEN '🔥🔥🔥'
              WHEN 1 THEN 'To the moon!'
              WHEN 2 THEN 'I''m in!'
              WHEN 3 THEN 'Nice call!'
              WHEN 4 THEN 'Following host'
              WHEN 5 THEN 'Already up 20%'
              WHEN 6 THEN 'Thanks for signal'
              WHEN 7 THEN 'Keep it up'
              WHEN 8 THEN 'Best room ever'
              WHEN 9 THEN 'Making money here'
              WHEN 10 THEN 'Love this room'
              WHEN 11 THEN 'Daily wins'
              WHEN 12 THEN 'Good vibes'
              WHEN 13 THEN 'Let''s go!'
              ELSE 'Amazing'
            END, NOW() - (room_count + i + 2 || ' minutes')::interval);
        END IF;
      END LOOP;
    END IF;
    
    v_listener_ids := ARRAY[]::uuid[];
    
  END LOOP;
END $$;