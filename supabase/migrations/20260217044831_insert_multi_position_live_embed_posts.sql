/*
  # Diverse Social Posts - Multi-Position & Live Embed

  1. New Posts
    - 40 multi-position posts with 2-4 position cards each
    - 25 live embed posts with room preview data
  
  2. Features
    - Multi-position: sub_positions JSONB with position grid data
    - Live embed: live_room_data JSONB with room info and chat messages
    - asset_change_30d for some multi-position posts
*/

DO $$
DECLARE
  v_profile RECORD;
  v_coins TEXT[] := ARRAY['BTC', 'ETH', 'SOL', 'BNB', 'XRP', 'DOGE', 'ADA', 'AVAX', 'LINK', 'DOT', 'UNI', 'ATOM', 'ARB', 'OP', 'NEAR', 'AAVE', 'INJ', 'SUI', 'JUP', 'PEPE', 'APT', 'TAO', 'TIA', 'SEI', 'WLD', 'FET', 'RENDER', 'ONDO', 'SHIB', 'FTM'];
  v_multi_content TEXT[];
  v_live_content TEXT[];
  v_coin1 TEXT; v_coin2 TEXT; v_coin3 TEXT; v_coin4 TEXT;
  v_i INTEGER;
  v_tags JSONB;
  v_positions JSONB;
  v_live_data JSONB;
  v_num_positions INTEGER;
  v_pnl1 NUMERIC; v_pnl2 NUMERIC; v_pnl3 NUMERIC; v_pnl4 NUMERIC;
  v_roi1 NUMERIC; v_roi2 NUMERIC; v_roi3 NUMERIC; v_roi4 NUMERIC;
  v_lev1 INTEGER; v_lev2 INTEGER; v_lev3 INTEGER; v_lev4 INTEGER;
  v_type1 TEXT; v_type2 TEXT; v_type3 TEXT; v_type4 TEXT;
  v_entry NUMERIC; v_mark NUMERIC; v_liq NUMERIC; v_size NUMERIC; v_margin NUMERIC;
  v_asset_change NUMERIC;
  v_viewers INTEGER;
  v_host_msgs TEXT[];
  v_cohost_msgs TEXT[];
  v_live_titles TEXT[];
  v_avatar_id INTEGER;
BEGIN
  v_multi_content := ARRAY[
    'Big profits and big success again! Multiple positions running green.',
    'Portfolio is absolutely crushing it this week. All positions in profit.',
    'This is what proper diversification looks like. Multiple winners simultaneously.',
    'Patience pays off. All my setups from last week are hitting targets.',
    'The strategy is simple: find strong trends, ride them with proper risk management.',
    'Green across the board today. Love it when the analysis aligns with execution.',
    'Multiple positions, multiple wins. This is what consistent trading looks like.',
    'Every position carefully calculated. Risk managed. Results speak for themselves.',
    'When you trust your analysis and manage risk, this is what happens.',
    'Strong week. Positions running beautifully. Time to take some profits.',
    'Diversified entries across different coins. All performing as expected.',
    'My best trading week this month. Multiple setups playing out perfectly.',
    'The market is being generous to those who do their homework.',
    'All positions opened based on volume profile analysis. Results are clear.',
    'When multiple uncorrelated assets move in your favor simultaneously.',
    'Started these positions 3 days ago. Letting winners run with trailing stops.',
    'Cross-pair analysis led me to these entries. The correlation play is working.',
    'Sector rotation strategy: move capital to where momentum is building.',
    'My systematic approach: identify, enter, manage, profit. Repeat.',
    'This is why I hold multiple positions. Risk is spread, gains are amplified.'
  ];

  v_live_titles := ARRAY[
    'Earn Time', 'Market Analysis Live', 'Trading Room', 'Signal Session',
    'Morning Briefing', 'Whale Watching', 'Chart Review', 'Strategy Talk',
    'Open Discussion', 'Trade Together', 'Market Update', 'Analysis Hour',
    'Crypto Talk', 'Position Review', 'Entry Points', 'Market Moves',
    'Daily Recap', 'Setup Scanner', 'Trade Ideas', 'Market Pulse'
  ];

  v_host_msgs := ARRAY[
    'yes keep long, support is holding strong',
    'watching the 4H close carefully here',
    'this level is critical, don''t overtrade',
    'taking partial profits at resistance',
    'BTC looking strong, alts should follow',
    'funding rate turning negative, bullish signal',
    'volume picking up, breakout likely',
    'patience here, let the setup come to you',
    'stop-loss below the last swing low',
    'target is the next resistance zone',
    'accumulation phase confirmed on the daily',
    'scale in, don''t go all in at once',
    'the weekly close will be important',
    'RSI divergence forming, watch for reversal',
    'market structure is bullish on higher TF'
  ];

  v_cohost_msgs := ARRAY[
    'pumping now, volume is insane',
    'I''m in long from the bottom, looking great',
    'what''s the target for this move?',
    'bulls are in control here clearly',
    'anyone else seeing this breakout forming?',
    'entered at support, SL tight below',
    'this looks like accumulation to me',
    'the order book is heavily bid-sided',
    'funding going negative, short squeeze incoming',
    'great setup, R/R is at least 3:1',
    'holding since yesterday, up nice already',
    'resistance getting weaker with each test',
    'whale just market bought, check the tape',
    'consolidation almost over, breakout soon',
    'DCA''ing into this dip, great prices'
  ];

  FOR v_i IN 1..40 LOOP
    SELECT * INTO v_profile FROM anonymous_profiles ORDER BY random() LIMIT 1;
    
    v_coin1 := v_coins[1 + floor(random() * array_length(v_coins, 1))::int];
    v_coin2 := v_coins[1 + floor(random() * array_length(v_coins, 1))::int];
    v_coin3 := v_coins[1 + floor(random() * array_length(v_coins, 1))::int];
    v_coin4 := v_coins[1 + floor(random() * array_length(v_coins, 1))::int];
    
    v_num_positions := 2 + floor(random() * 3)::int;
    
    v_lev1 := (ARRAY[5,10,15,20,25,50])[1 + floor(random() * 6)::int];
    v_lev2 := (ARRAY[5,10,15,20,25,50])[1 + floor(random() * 6)::int];
    v_lev3 := (ARRAY[5,10,15,20,25,50])[1 + floor(random() * 6)::int];
    v_lev4 := (ARRAY[5,10,15,20,25,50])[1 + floor(random() * 6)::int];
    
    v_type1 := CASE WHEN random() > 0.3 THEN 'long' ELSE 'short' END;
    v_type2 := CASE WHEN random() > 0.3 THEN 'long' ELSE 'short' END;
    v_type3 := CASE WHEN random() > 0.3 THEN 'long' ELSE 'short' END;
    v_type4 := CASE WHEN random() > 0.3 THEN 'long' ELSE 'short' END;
    
    v_pnl1 := round((random() * 30000 + 500)::numeric, 2);
    v_roi1 := round((random() * 500 + 10)::numeric, 2);
    v_pnl2 := round((random() * 25000 + 300)::numeric, 2);
    v_roi2 := round((random() * 400 + 15)::numeric, 2);
    v_pnl3 := round((random() * 20000 + 200)::numeric, 2);
    v_roi3 := round((random() * 350 + 5)::numeric, 2);
    v_pnl4 := round((random() * 15000 + 100)::numeric, 2);
    v_roi4 := round((random() * 300 + 8)::numeric, 2);

    v_positions := '[]'::jsonb;
    
    v_entry := round((random() * 50000 + 0.01)::numeric, CASE WHEN random() > 0.5 THEN 2 ELSE 6 END);
    v_size := round((v_pnl1 / (v_roi1 / 100)) * v_lev1, 2);
    v_margin := round(v_size / v_lev1, 2);
    v_mark := round(v_entry * (1 + (v_roi1 / 100 / v_lev1) * CASE WHEN v_type1 = 'long' THEN 1 ELSE -1 END), CASE WHEN v_entry > 100 THEN 2 ELSE 6 END);
    v_liq := round(v_entry * (1 - (1.0 / v_lev1) * CASE WHEN v_type1 = 'long' THEN 1 ELSE -1 END), CASE WHEN v_entry > 100 THEN 2 ELSE 6 END);
    v_positions := v_positions || json_build_object(
      'coin', v_coin1, 'type', v_type1, 'leverage', v_lev1,
      'pnl', v_pnl1, 'roi', v_roi1, 'size', v_size, 'margin', v_margin,
      'entry', v_entry, 'mark', v_mark, 'liq', v_liq, 'margin_ratio', round((random() * 15 + 3)::numeric, 2)
    )::jsonb;

    v_entry := round((random() * 50000 + 0.01)::numeric, CASE WHEN random() > 0.5 THEN 2 ELSE 6 END);
    v_size := round((v_pnl2 / (v_roi2 / 100)) * v_lev2, 2);
    v_margin := round(v_size / v_lev2, 2);
    v_mark := round(v_entry * (1 + (v_roi2 / 100 / v_lev2) * CASE WHEN v_type2 = 'long' THEN 1 ELSE -1 END), CASE WHEN v_entry > 100 THEN 2 ELSE 6 END);
    v_liq := round(v_entry * (1 - (1.0 / v_lev2) * CASE WHEN v_type2 = 'long' THEN 1 ELSE -1 END), CASE WHEN v_entry > 100 THEN 2 ELSE 6 END);
    v_positions := v_positions || json_build_object(
      'coin', v_coin2, 'type', v_type2, 'leverage', v_lev2,
      'pnl', v_pnl2, 'roi', v_roi2, 'size', v_size, 'margin', v_margin,
      'entry', v_entry, 'mark', v_mark, 'liq', v_liq, 'margin_ratio', round((random() * 15 + 3)::numeric, 2)
    )::jsonb;

    IF v_num_positions >= 3 THEN
      v_entry := round((random() * 50000 + 0.01)::numeric, CASE WHEN random() > 0.5 THEN 2 ELSE 6 END);
      v_size := round((v_pnl3 / (v_roi3 / 100)) * v_lev3, 2);
      v_margin := round(v_size / v_lev3, 2);
      v_mark := round(v_entry * (1 + (v_roi3 / 100 / v_lev3) * CASE WHEN v_type3 = 'long' THEN 1 ELSE -1 END), CASE WHEN v_entry > 100 THEN 2 ELSE 6 END);
      v_liq := round(v_entry * (1 - (1.0 / v_lev3) * CASE WHEN v_type3 = 'long' THEN 1 ELSE -1 END), CASE WHEN v_entry > 100 THEN 2 ELSE 6 END);
      v_positions := v_positions || json_build_object(
        'coin', v_coin3, 'type', v_type3, 'leverage', v_lev3,
        'pnl', v_pnl3, 'roi', v_roi3, 'size', v_size, 'margin', v_margin,
        'entry', v_entry, 'mark', v_mark, 'liq', v_liq, 'margin_ratio', round((random() * 15 + 3)::numeric, 2)
      )::jsonb;
    END IF;

    IF v_num_positions >= 4 THEN
      v_entry := round((random() * 50000 + 0.01)::numeric, CASE WHEN random() > 0.5 THEN 2 ELSE 6 END);
      v_size := round((v_pnl4 / (v_roi4 / 100)) * v_lev4, 2);
      v_margin := round(v_size / v_lev4, 2);
      v_mark := round(v_entry * (1 + (v_roi4 / 100 / v_lev4) * CASE WHEN v_type4 = 'long' THEN 1 ELSE -1 END), CASE WHEN v_entry > 100 THEN 2 ELSE 6 END);
      v_liq := round(v_entry * (1 - (1.0 / v_lev4) * CASE WHEN v_type4 = 'long' THEN 1 ELSE -1 END), CASE WHEN v_entry > 100 THEN 2 ELSE 6 END);
      v_positions := v_positions || json_build_object(
        'coin', v_coin4, 'type', v_type4, 'leverage', v_lev4,
        'pnl', v_pnl4, 'roi', v_roi4, 'size', v_size, 'margin', v_margin,
        'entry', v_entry, 'mark', v_mark, 'liq', v_liq, 'margin_ratio', round((random() * 15 + 3)::numeric, 2)
      )::jsonb;
    END IF;

    v_asset_change := CASE WHEN random() > 0.6 THEN round((random() * 500000 + 1000)::numeric, 2) ELSE NULL END;

    v_tags := json_build_array(
      json_build_object('symbol', v_coin1, 'change', round((random() * 20 - 5)::numeric, 2)),
      json_build_object('symbol', v_coin2, 'change', round((random() * 20 - 5)::numeric, 2))
    )::jsonb;
    IF v_num_positions >= 3 THEN
      v_tags := v_tags || json_build_array(json_build_object('symbol', v_coin3, 'change', round((random() * 20 - 5)::numeric, 2)))::jsonb;
    END IF;

    INSERT INTO social_posts (
      username, avatar_url, content, coin_symbol, trade_type, entry_price, exit_price,
      profit_loss, profit_loss_percent, leverage, image_url, post_type,
      likes_count, comments_count, shares_count, is_bullish, created_at,
      coin_tags, sub_positions, asset_change_30d, sentiment
    ) VALUES (
      v_profile.username, v_profile.avatar_url,
      v_multi_content[1 + ((v_i - 1) % array_length(v_multi_content, 1))],
      v_coin1, 'long', 0, 0, 0, 0, 1, NULL, 'multi_position',
      floor(random() * 400 + 20)::int, floor(random() * 80 + 5)::int,
      floor(random() * 150 + 10)::int, true,
      now() - (random() * interval '7 days'),
      v_tags, v_positions, v_asset_change, 'bullish'
    );
  END LOOP;

  FOR v_i IN 1..25 LOOP
    SELECT * INTO v_profile FROM anonymous_profiles ORDER BY random() LIMIT 1;
    v_coin1 := v_coins[1 + floor(random() * array_length(v_coins, 1))::int];
    v_viewers := floor(random() * 200 + 10)::int;
    v_avatar_id := floor(random() * 70 + 1)::int;

    v_live_data := json_build_object(
      'title', v_live_titles[1 + floor(random() * array_length(v_live_titles, 1))::int],
      'viewers', v_viewers,
      'host_name', v_profile.username,
      'host_avatar', 'https://i.pravatar.cc/150?img=' || v_avatar_id,
      'coin', v_coin1,
      'messages', json_build_array(
        json_build_object(
          'role', 'host',
          'name', v_profile.username,
          'text', v_host_msgs[1 + floor(random() * array_length(v_host_msgs, 1))::int],
          'avatar', 'https://i.pravatar.cc/150?img=' || v_avatar_id
        ),
        json_build_object(
          'role', 'co-host',
          'name', v_coin1 || '_trader',
          'text', v_cohost_msgs[1 + floor(random() * array_length(v_cohost_msgs, 1))::int],
          'avatar', 'https://i.pravatar.cc/150?img=' || (v_avatar_id + 10)
        ),
        json_build_object(
          'role', 'host',
          'name', v_profile.username,
          'text', v_host_msgs[1 + floor(random() * array_length(v_host_msgs, 1))::int],
          'avatar', 'https://i.pravatar.cc/150?img=' || v_avatar_id
        )
      )
    )::jsonb;

    v_tags := json_build_array(
      json_build_object('symbol', v_coin1, 'change', round((random() * 16 - 8)::numeric, 2))
    )::jsonb;

    INSERT INTO social_posts (
      username, avatar_url, content, coin_symbol, trade_type, entry_price, exit_price,
      profit_loss, profit_loss_percent, leverage, image_url, post_type,
      likes_count, comments_count, shares_count, is_bullish, created_at,
      coin_tags, live_room_data, sentiment
    ) VALUES (
      v_profile.username, v_profile.avatar_url,
      v_live_titles[1 + floor(random() * array_length(v_live_titles, 1))::int],
      v_coin1, 'long', 0, 0, 0, 0, 1, NULL, 'live_embed',
      floor(random() * 100 + 5)::int, floor(random() * 30 + 2)::int,
      floor(random() * 20 + 1)::int, true,
      now() - (random() * interval '3 days'),
      v_tags, v_live_data, 'neutral'
    );
  END LOOP;
END $$;