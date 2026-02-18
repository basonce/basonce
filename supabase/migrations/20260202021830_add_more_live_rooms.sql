/*
  # Add More Live Rooms

  Add 15+ more active live rooms with varying listener counts for a dynamic experience.
*/

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Altcoin Season Talk',
  'Which altcoins are ready to explode? Join the discussion!',
  (SELECT id FROM user_profiles LIMIT 1),
  'Altcoins',
  892,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Futures Trading Strategy',
  'Learn advanced futures trading techniques from professionals.',
  (SELECT id FROM user_profiles LIMIT 1),
  'Futures',
  1567,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Whale Watching',
  'Track big money movements and whale wallet activities.',
  (SELECT id FROM user_profiles LIMIT 1),
  'Market Analysis',
  2134,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Crypto News Live',
  'Breaking crypto news and market updates as they happen.',
  (SELECT id FROM user_profiles LIMIT 1),
  'News',
  3456,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Technical Analysis 101',
  'Learn chart patterns, indicators, and TA fundamentals.',
  (SELECT id FROM user_profiles LIMIT 1),
  'Education',
  756,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Meme Coins Madness',
  'High risk, high reward! Discussing the hottest meme coins.',
  (SELECT id FROM user_profiles LIMIT 1),
  'Meme Coins',
  4231,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'ETH 2.0 Discussion',
  'Everything about Ethereum upgrades, staking, and future.',
  (SELECT id FROM user_profiles LIMIT 1),
  'Ethereum',
  1823,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Layer 2 Solutions',
  'Exploring Arbitrum, Optimism, and other L2 networks.',
  (SELECT id FROM user_profiles LIMIT 1),
  'Layer 2',
  567,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Spot Trading Room',
  'Real-time spot trading signals and market opportunities.',
  (SELECT id FROM user_profiles LIMIT 1),
  'Spot Trading',
  2891,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Web3 Gaming',
  'Play-to-earn games, NFT gaming, and blockchain gaming.',
  (SELECT id FROM user_profiles LIMIT 1),
  'Gaming',
  1234,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Metaverse Talk',
  'Virtual worlds, metaverse tokens, and digital real estate.',
  (SELECT id FROM user_profiles LIMIT 1),
  'Metaverse',
  987,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Staking & Yield',
  'Maximize your passive income with staking and yield farming.',
  (SELECT id FROM user_profiles LIMIT 1),
  'Staking',
  1456,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Solana Ecosystem',
  'SOL price action, new projects, and ecosystem growth.',
  (SELECT id FROM user_profiles LIMIT 1),
  'Solana',
  2678,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'AI x Crypto',
  'Artificial Intelligence meets blockchain technology.',
  (SELECT id FROM user_profiles LIMIT 1),
  'AI & Crypto',
  3123,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Binance Smart Chain',
  'BSC projects, pancakeswap, and BNB ecosystem.',
  (SELECT id FROM user_profiles LIMIT 1),
  'BSC',
  1789,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Crypto Tax Planning',
  'Save money with smart crypto tax strategies.',
  (SELECT id FROM user_profiles LIMIT 1),
  'Tax & Legal',
  445,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'ICO & IDO Hunting',
  'Find the next 100x gem before everyone else.',
  (SELECT id FROM user_profiles LIMIT 1),
  'ICO/IDO',
  5234,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);

INSERT INTO live_rooms (title, description, host_id, topic, listener_count, is_active)
SELECT
  'Turkish Crypto Community',
  'Türkçe kripto sohbeti - Piyasa analizi ve tavsiyeler.',
  (SELECT id FROM user_profiles LIMIT 1),
  'Turkish',
  2456,
  true
WHERE EXISTS (SELECT 1 FROM user_profiles LIMIT 1);
