/*
  # Mining Success Feed System - Kazanç ve Çekim Bildirim Sistemi

  1. Yeni Tablo
    - `mining_success_feed`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to user_profiles)
      - `username` (text) - kullanıcı adı (anonim: User#1234)
      - `avatar_url` (text) - profil fotoğrafı
      - `type` (text) - 'withdrawal' veya 'earning'
      - `amount` (numeric) - kazanç/çekim tutarı
      - `coin` (text) - EQ, USDT, BTC, ETH, vs
      - `network` (text) - TRX, BNB, ETH, vs (sadece çekimler için)
      - `wallet_address` (text) - cüzdan adresi (sadece çekimler için)
      - `tx_id` (text) - transaction ID (sadece çekimler için)
      - `message` (text) - başarı mesajı
      - `status` (text) - 'completed', 'processing'
      - `created_at` (timestamptz)
      
  2. Güvenlik
    - RLS enabled
    - Public read access (herkes görebilir - motivasyon için)
    - Only authenticated users can insert their own records
    
  3. Notlar
    - Mining kazançları ve çekimleri gerçek zamanlı gösterilecek
    - Basonce markası vurgulanacak
    - Heyecan verici, motivasyonel içerik
*/

CREATE TABLE IF NOT EXISTS mining_success_feed (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES user_profiles(id) ON DELETE CASCADE,
  username text NOT NULL,
  avatar_url text,
  type text NOT NULL CHECK (type IN ('withdrawal', 'earning', 'mining_claim')),
  amount numeric NOT NULL CHECK (amount > 0),
  coin text NOT NULL DEFAULT 'EQ',
  network text,
  wallet_address text,
  tx_id text,
  message text NOT NULL,
  status text NOT NULL DEFAULT 'completed' CHECK (status IN ('completed', 'processing')),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE mining_success_feed ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Mining success feed is publicly readable"
  ON mining_success_feed FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Users can insert own success records"
  ON mining_success_feed FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS mining_success_feed_created_at_idx ON mining_success_feed(created_at DESC);
CREATE INDEX IF NOT EXISTS mining_success_feed_type_idx ON mining_success_feed(type);

-- Gerçek zamanlı güncellemeler için
ALTER PUBLICATION supabase_realtime ADD TABLE mining_success_feed;

-- Dummy success feed verileri - heyecan verici kazançlar ve çekimler!
INSERT INTO mining_success_feed (username, avatar_url, type, amount, coin, network, wallet_address, tx_id, message, status, created_at) VALUES
  ('Crypto_King_TR', 'https://i.pravatar.cc/150?img=12', 'withdrawal', 5420.50, 'USDT', 'TRX', 'TAvep3x8cAoUZ3goLojdTBLpXkmzqjbffk', '17d9bc9411af86bced8126614f7c72e694e4c9009768b03dd2ba2d94425cdb81', 'Basonce''den USDT çekimi tamamlandı! 🎉 Harika kar!', 'completed', now() - interval '5 minutes'),
  
  ('Miner_Sarah_US', 'https://i.pravatar.cc/150?img=5', 'mining_claim', 15234.80, 'EQ', NULL, NULL, NULL, '15,234 EQ madencilik kazancı toplandı! 💰 Mining devam ediyor!', 'completed', now() - interval '12 minutes'),
  
  ('Bitcoin_Ahmet', 'https://i.pravatar.cc/150?img=33', 'withdrawal', 2450.00, 'USDT', 'BNB', 'bnb1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh', '8f3e2a1c9b7d6e5f4a3b2c1d0e9f8a7b6c5d4e3f2a1b0c9d8e7f6a5b4c3d2e1f0', 'Basonce''den BNB ağından çekim yapıldı! ✅ Güvenli ve hızlı!', 'completed', now() - interval '18 minutes'),
  
  ('Mining_Pro_DE', 'https://i.pravatar.cc/150?img=68', 'earning', 8900.25, 'EQ', NULL, NULL, NULL, '8,900 EQ kazandı! 🚀 Mining makinen çalışıyor!', 'completed', now() - interval '25 minutes'),
  
  ('Trader_Mike_JP', 'https://i.pravatar.cc/150?img=14', 'withdrawal', 12750.00, 'USDT', 'ETH', '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb', '0xa3c2e4f8d9b7c1a5e6d3f2b8c4a7e9f1d5b3c8a2e6f4d1b7c9a5e3f8d2b6c4a1', 'ETH ağından Basonce''den çekim başarılı! 🎊 Büyük kazanç!', 'completed', now() - interval '32 minutes'),
  
  ('Diamond_Hands_BR', 'https://i.pravatar.cc/150?img=22', 'mining_claim', 23100.00, 'EQ', NULL, NULL, NULL, '23,100 EQ toplandı! 💎 Mining gücün artıyor!', 'completed', now() - interval '45 minutes'),
  
  ('Crypto_Queen_FR', 'https://i.pravatar.cc/150?img=44', 'withdrawal', 8320.75, 'USDT', 'TRX', 'TY2eqBEyKQRPQkzVCqKqZqJmqJqKqZqJmq', '5b8c7d9e2f1a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c', 'Basonce''den TRX ile ultra hızlı çekim! ⚡ Anında hesapta!', 'completed', now() - interval '1 hour'),
  
  ('Moon_Boy_IT', 'https://i.pravatar.cc/150?img=51', 'earning', 6540.50, 'EQ', NULL, NULL, NULL, '6,540 EQ madencilik karı! 🌙 To the moon!', 'completed', now() - interval '1 hour 15 minutes'),
  
  ('HODL_Master_ES', 'https://i.pravatar.cc/150?img=59', 'withdrawal', 18900.00, 'USDT', 'BNB', 'bnb1zxy3kgdygjrsqtzq2n0yrf2493p83kkfjhx0abc', '7f2d1c9e8b6a5f4e3d2c1b0a9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2a1f0', 'Dev çekim! Basonce''den BNB ağı ile 18,900 USDT! 🔥', 'completed', now() - interval '1 hour 30 minutes'),
  
  ('EQ_Miner_KR', 'https://i.pravatar.cc/150?img=8', 'mining_claim', 34500.00, 'EQ', NULL, NULL, NULL, '34,500 EQ kazanıldı! 💪 Mining lideri!', 'completed', now() - interval '2 hours'),
  
  ('Rich_Trader_UK', 'https://i.pravatar.cc/150?img=15', 'withdrawal', 25600.00, 'USDT', 'ETH', '0x8E23Ee67d1332aD560396262C48ffbB273f626Ed', '0x9e7f3b2d8c1a5f4e6d3b9c2a7f8e1d4c5b6a9f3e2d7c1b8a4f6e9d3c5b2a8f1', 'Büyük gün! Basonce''den 25,600 USDT çekildi! 🎉💰', 'completed', now() - interval '2 hours 20 minutes'),
  
  ('Whale_Alert_CN', 'https://i.pravatar.cc/150?img=70', 'withdrawal', 45000.00, 'USDT', 'TRX', 'TWhaleAddressExample123456789012345678', '1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b', 'WHALE ALERT! 🐋 45,000 USDT Basonce''den çekildi!', 'completed', now() - interval '3 hours'),
  
  ('Fast_Miner_RU', 'https://i.pravatar.cc/150?img=32', 'mining_claim', 11200.00, 'EQ', NULL, NULL, NULL, '11,200 EQ madencilik geliri! ⚡ Hızlı ve karlı!', 'completed', now() - interval '3 hours 30 minutes'),
  
  ('Lucky_Day_AU', 'https://i.pravatar.cc/150?img=41', 'withdrawal', 7890.00, 'USDT', 'BNB', 'bnb1luckyaddressexample123456789012', '3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4', 'Şanslı gün! Basonce ile 7,890 USDT cebimde! 🍀', 'completed', now() - interval '4 hours'),
  
  ('Pro_Miner_PL', 'https://i.pravatar.cc/150?img=56', 'earning', 19800.00, 'EQ', NULL, NULL, NULL, '19,800 EQ geliri! 📈 Mining profesyoneli!', 'completed', now() - interval '4 hours 45 minutes'),
  
  ('Crypto_Boss_MX', 'https://i.pravatar.cc/150?img=28', 'withdrawal', 16500.00, 'USDT', 'ETH', '0xBossCryptoWalletAddress123456789ABC', '0x4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5', 'Patron çıkışı! Basonce''den 16,500 USDT! 👑', 'completed', now() - interval '5 hours'),
  
  ('Moon_Miner_CA', 'https://i.pravatar.cc/150?img=17', 'mining_claim', 28300.00, 'EQ', NULL, NULL, NULL, '28,300 EQ madencilik başarısı! 🚀 Ay''a gidiyoruz!', 'completed', now() - interval '6 hours'),
  
  ('Profit_King_SE', 'https://i.pravatar.cc/150?img=63', 'withdrawal', 9870.00, 'USDT', 'TRX', 'TProfitKingAddress123456789012345678', '6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7', 'Kar kralı! 9,870 USDT Basonce''den çıktı! 👑💰', 'completed', now() - interval '7 hours'),
  
  ('EQ_Champion_NO', 'https://i.pravatar.cc/150?img=9', 'earning', 41000.00, 'EQ', NULL, NULL, NULL, '41,000 EQ kazancı! 🏆 Şampiyon madenci!', 'completed', now() - interval '8 hours'),
  
  ('Happy_Trader_NL', 'https://i.pravatar.cc/150?img=45', 'withdrawal', 13200.00, 'USDT', 'BNB', 'bnb1happytraderaddress123456789012', '8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9', 'Mutluluk dolu çekim! Basonce''den 13,200 USDT! 😊', 'completed', now() - interval '9 hours'),
  
  ('Diamond_Miner_BE', 'https://i.pravatar.cc/150?img=24', 'mining_claim', 17650.00, 'EQ', NULL, NULL, NULL, '17,650 EQ elmas gibi kazanç! 💎 Parlıyorsun!', 'completed', now() - interval '10 hours'),
  
  ('Winner_Alert_AT', 'https://i.pravatar.cc/150?img=38', 'withdrawal', 31500.00, 'USDT', 'ETH', '0xWinnerAlertAddress123456789ABCDEF', '0x1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2', 'KAZANAN ALERT! 31,500 USDT Basonce''den! 🏆🎉', 'completed', now() - interval '11 hours'),
  
  ('Success_Pro_CH', 'https://i.pravatar.cc/150?img=52', 'earning', 9400.00, 'EQ', NULL, NULL, NULL, '9,400 EQ başarı geliri! ✨ Profesyonel madenci!', 'completed', now() - interval '12 hours');
