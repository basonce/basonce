/*
  # Live Room Chat Mesajları - Toplu Ekleme
  
  1. Her odaya 30+ gerçekçi mesaj ekle
  2. Host, co-host, listener mesajları
  3. Trading sorular, emoji, reaksiyonlar
  4. Zamanlama farklı
*/

DO $$
DECLARE
  v_room_record RECORD;
  v_host_id uuid;
  v_cohost_ids uuid[];
  v_listener_ids uuid[];
  room_idx integer := 0;
BEGIN
  FOR v_room_record IN 
    SELECT id FROM live_rooms WHERE is_active = true ORDER BY listener_count DESC LIMIT 22
  LOOP
    room_idx := room_idx + 1;
    
    SELECT dummy_user_id INTO v_host_id
    FROM live_room_participants
    WHERE room_id = v_room_record.id AND role = 'host'
    LIMIT 1;
    
    SELECT array_agg(dummy_user_id) INTO v_cohost_ids
    FROM (
      SELECT dummy_user_id 
      FROM live_room_participants 
      WHERE room_id = v_room_record.id AND role = 'co-host'
      ORDER BY joined_at
      LIMIT 3
    ) sub;
    
    SELECT array_agg(dummy_user_id) INTO v_listener_ids
    FROM (
      SELECT dummy_user_id 
      FROM live_room_participants 
      WHERE room_id = v_room_record.id AND role = 'listener'
      ORDER BY joined_at
      LIMIT 10
    ) sub;
    
    IF array_length(v_listener_ids, 1) >= 10 AND array_length(v_cohost_ids, 1) >= 2 THEN
      INSERT INTO live_room_messages (room_id, dummy_user_id, message, created_at)
      VALUES
        (v_room_record.id, v_host_id, '444', NOW() - (room_idx * 3 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[1], 'co host me please', NOW() - (room_idx * 3 + 1 || ' minutes')::interval),
        (v_room_record.id, v_cohost_ids[1], '888✨', NOW() - (room_idx * 3 + 2 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[2], 'BTC to 100K? 🚀', NOW() - (room_idx * 3 + 3 || ' minutes')::interval),
        (v_room_record.id, v_host_id, 'Yes! Target is 100K', NOW() - (room_idx * 3 + 4 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[3], 'What about ETH?', NOW() - (room_idx * 3 + 5 || ' minutes')::interval),
        (v_room_record.id, v_cohost_ids[2], 'ETH looking good at $3500', NOW() - (room_idx * 3 + 6 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[4], 'Should I buy now?', NOW() - (room_idx * 3 + 7 || ' minutes')::interval),
        (v_room_record.id, v_host_id, 'Wait for dip', NOW() - (room_idx * 3 + 8 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[5], '🔥🔥🔥', NOW() - (room_idx * 3 + 9 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[6], 'Thanks for signals!', NOW() - (room_idx * 3 + 10 || ' minutes')::interval),
        (v_room_record.id, v_cohost_ids[1], 'Follow for more updates', NOW() - (room_idx * 3 + 11 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[7], 'Best room ever!', NOW() - (room_idx * 3 + 12 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[8], 'I made 500 USDT today 💰', NOW() - (room_idx * 3 + 13 || ' minutes')::interval),
        (v_room_record.id, v_host_id, 'Congrats! Keep it up', NOW() - (room_idx * 3 + 14 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[9], 'What leverage?', NOW() - (room_idx * 3 + 15 || ' minutes')::interval),
        (v_room_record.id, v_cohost_ids[2], '10x-20x is safe', NOW() - (room_idx * 3 + 16 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[1], 'Long or short?', NOW() - (room_idx * 3 + 17 || ' minutes')::interval),
        (v_room_record.id, v_host_id, 'LONG! 📈', NOW() - (room_idx * 3 + 18 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[2], 'Entry price?', NOW() - (room_idx * 3 + 19 || ' minutes')::interval),
        (v_room_record.id, v_cohost_ids[1], 'Current price is good', NOW() - (room_idx * 3 + 20 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[3], 'Stop loss at?', NOW() - (room_idx * 3 + 21 || ' minutes')::interval),
        (v_room_record.id, v_host_id, '5% below entry', NOW() - (room_idx * 3 + 22 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[4], 'Take profit level?', NOW() - (room_idx * 3 + 23 || ' minutes')::interval),
        (v_room_record.id, v_cohost_ids[2], '10% profit minimum', NOW() - (room_idx * 3 + 24 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[5], 'I''m in! 💪', NOW() - (room_idx * 3 + 25 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[6], 'Same here!', NOW() - (room_idx * 3 + 26 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[7], 'To the moon! 🌙', NOW() - (room_idx * 3 + 27 || ' minutes')::interval),
        (v_room_record.id, v_host_id, 'Good luck everyone!', NOW() - (room_idx * 3 + 28 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[8], 'LFG! 🚀', NOW() - (room_idx * 3 + 29 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[9], 'When next signal?', NOW() - (room_idx * 3 + 30 || ' minutes')::interval),
        (v_room_record.id, v_cohost_ids[1], 'Soon! Stay tuned', NOW() - (room_idx * 3 + 31 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[1], 'Chart analysis pls', NOW() - (room_idx * 3 + 32 || ' minutes')::interval),
        (v_room_record.id, v_host_id, 'RSI oversold, bullish', NOW() - (room_idx * 3 + 33 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[2], 'Support level?', NOW() - (room_idx * 3 + 34 || ' minutes')::interval),
        (v_room_record.id, v_cohost_ids[2], '$95,000 strong support', NOW() - (room_idx * 3 + 35 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[3], 'Resistance at?', NOW() - (room_idx * 3 + 36 || ' minutes')::interval),
        (v_room_record.id, v_host_id, '$102,000 resistance', NOW() - (room_idx * 3 + 37 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[4], 'Volume increasing 📊', NOW() - (room_idx * 3 + 38 || ' minutes')::interval),
        (v_room_record.id, v_listener_ids[5], 'Bullish flag pattern', NOW() - (room_idx * 3 + 39 || ' minutes')::interval),
        (v_room_record.id, v_cohost_ids[1], 'Exactly! Good eye 👁️', NOW() - (room_idx * 3 + 40 || ' minutes')::interval);
    END IF;
    
  END LOOP;
END $$;