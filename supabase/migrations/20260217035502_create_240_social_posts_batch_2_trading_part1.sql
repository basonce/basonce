/*
  # Create 240 Social Posts - Batch 2: Normal Trading Posts (Part 1/2)

  ## Overview
  Creates 80 normal trading posts with realistic coin analysis,
  position updates, and market sentiment.
  
  ## Post Types
  - Coin analysis and predictions
  - Position opening/closing updates  
  - Market sentiment and reactions
  - Winner posts with single image
*/

DO $$
DECLARE
  rp anonymous_profiles%ROWTYPE;
  pr RECORD;
BEGIN
  FOR pr IN (
    SELECT * FROM (VALUES
      ('$BTC looking extremely bullish! Just opened 50k position at 67,800$. Target: 75k! 🚀', 'BTC', 'long', 5, 48000, 67.3, NULL, 'text'),
      ('$ETH breakout incoming! Chart looking perfect for 4,500$ run. Opened 100k position with 10x leverage 📈', 'ETH', 'long', 10, 85000, 124.5, NULL, 'text'),
      ('$SOL to 200$ is inevitable. Just loaded my bags heavy. If you are not in $SOL you are missing out big time 🔥', 'SOL', 'long', 15, 65000, 89.7, '/ber7.jpg', 'winner'),
      ('$PEPE holders, we are going to make it! Just added 500M more tokens. Meme season is back 📈', 'PEPE', 'long', 20, 42000, 156.8, NULL, 'text'),
      ('$DOGE pump incoming! Elon just tweeted again. Opened massive long position. This is going to 1$ 🚀', 'DOGE', 'long', 12, 38000, 78.4, '/ber12.jpg', 'winner'),
      ('$BNB about to explode! BSC ecosystem growing fast. Just bought 200 BNB at 610$. Target: 850$ 📊', 'BNB', 'long', 8, 55000, 92.1, NULL, 'text'),
      ('$AVAX winter is over! Just opened 75k long position. This coin is undervalued af. Easy 3x from here 🚀', 'AVAX', 'long', 15, 68000, 145.7, '/ber17.jpg', 'winner'),
      ('$MATIC polygon season starting! Just loaded 50k tokens. This is going to pump hard 📈', 'MATIC', 'long', 10, 32000, 67.9, NULL, 'text'),
      ('$LINK marines assemble! Just opened 40k position on $LINK. Chainlink to 50$ is programmed 💎', 'LINK', 'long', 7, 45000, 88.3, '/ber22.jpg', 'winner'),
      ('$ADA finally waking up! Cardano breaking out of accumulation zone. Opened 60k long. Target: 1.50$ 🚀', 'ADA', 'long', 12, 52000, 98.6, NULL, 'text'),
      ('$DOT parachain auctions creating hype! Just bought heavy at 28$. Polkadot to 50$ easy 💎', 'DOT', 'long', 9, 48000, 82.4, '/ber27.jpg', 'winner'),
      ('$XRP lawsuit victory rally! Opened 100k position at 0.52$. This is going to 2$ minimum 📈', 'XRP', 'long', 15, 72000, 134.8, NULL, 'text'),
      ('$SHIB army strong! Just added 10 billion tokens. Shiba Inu to 0.001$ is not a meme anymore 🔥', 'SHIB', 'long', 25, 38000, 245.7, '/ber32.jpg', 'winner'),
      ('$UNI DeFi king! Uniswap about to pump hard. Just opened 55k long position. Target: 25$ 📊', 'UNI', 'long', 8, 58000, 96.2, NULL, 'text'),
      ('$FTM fantom opera! Just bought 100k tokens at 2.10$. Criminally undervalued. Easy 5x 🚀', 'FTM', 'long', 12, 44000, 118.5, '/ber37.jpg', 'winner'),
      ('$NEAR protocol heating up! Just opened 65k position at 18$. Near to 40$ is inevitable 📈', 'NEAR', 'long', 10, 62000, 128.4, NULL, 'text'),
      ('$ATOM cosmos ecosystem booming! Opened 50k long. IBC growing fast. Going to 100$ 💎', 'ATOM', 'long', 7, 54000, 87.9, '/ber42.jpg', 'winner'),
      ('$ALGO algorand pumping! Just loaded 80k tokens. Pure tech foundation underrated. Target: 5$ 🚀', 'ALGO', 'long', 9, 48000, 94.3, NULL, 'text'),
      ('$LTC halving coming! Litecoin always delivers. Just opened 70k position at 180$. Target: 350$ 📈', 'LTC', 'long', 6, 51000, 76.8, '/ber47.jpg', 'winner'),
      ('$BTC just broke resistance at 68k! This is the beginning of the next leg up. Loaded my position heavy 💎', 'BTC', 'long', 10, 95000, 187.3, NULL, 'text'),
      ('$ETH staking rewards are insane right now. 8.2% APY plus price appreciation. No brainer investment 📊', 'ETH', 'long', 5, 42000, 56.8, NULL, 'text'),
      ('$SOL ecosystem on fire! New DEX launching next week. This is going to pump the price hard 🔥', 'SOL', 'long', 20, 78000, 234.5, '/ber1.jpg', 'winner'),
      ('Just closed my $BTC short at perfect timing. 85k profit secured. Reading the charts pays off 💰', 'BTC', 'short', 15, 85000, -156.2, NULL, 'text'),
      ('$DOGE back above 0.15$! Opened 30k position with 10x leverage. Memecoin king never dies 🐕', 'DOGE', 'long', 10, 28000, 89.4, NULL, 'text'),
      ('$ARB Arbitrum season incoming! Layer 2 narrative is the next big thing. Loaded 50k long 📈', 'ARB', 'long', 12, 45000, 112.7, '/ber6.jpg', 'winner'),
      ('If $PIPPIN just touch 20$, I will have 100k$ in my wallet. 1$ possible I granted this but you guys tell me $PIPPIN 20$ possible. If it is possible than I buy my mercedes car', 'PIPPIN', 'long', 10, 614, 7.17, '/ber1.jpg', 'winner'),
      ('$OP Optimism governance token undervalued! Just opened 55k position. Target: 8$ by Q2 🚀', 'OP', 'long', 8, 38000, 78.9, NULL, 'text'),
      ('$INJ Injective protocol breaking all time highs! This is just the beginning. Loaded my bags 💎', 'INJ', 'long', 15, 62000, 167.8, '/ber11.jpg', 'winner'),
      ('$SUI new chain new opportunity! Just bought 100k tokens at 1.80$. This is going to 10$ easy 📈', 'SUI', 'long', 10, 35000, 98.4, NULL, 'text'),
      ('$APT Aptos moving fast! Developer activity through the roof. Opened 45k long position 🔥', 'APT', 'long', 7, 42000, 84.3, NULL, 'text'),
      ('Short squeeze on $BTC incoming! Open interest at record levels. Going to be explosive 🚀', 'BTC', 'long', 20, 120000, 278.9, '/ber16.jpg', 'winner'),
      ('$ONDO real world assets tokenization is the future! Just opened 60k position. Easy 5x from here 📊', 'ONDO', 'long', 12, 55000, 134.5, NULL, 'text'),
      ('$TIA Celestia modular blockchain thesis playing out! Loaded 40k at 12$. Target: 30$ 💎', 'TIA', 'long', 8, 36000, 89.7, NULL, 'text'),
      ('$RENDER AI narrative plus crypto. Best combo ever. Just bought 10k RNDR tokens 🔥', 'RENDER', 'long', 5, 28000, 67.2, '/ber21.jpg', 'winner'),
      ('$WIF bonk bonk! Solana meme coins going crazy. Threw 5k at it, already up 300% 📈', 'WIF', 'long', 25, 15000, 312.4, NULL, 'text'),
      ('$BONK Solana meme king! Just added more. This is going parabolic this cycle 🚀', 'BONK', 'long', 20, 22000, 267.8, NULL, 'text'),
      ('$FET AI token pumping! Fetch.ai partnership with big tech companies. Opening 50k long 💎', 'FET', 'long', 10, 48000, 112.3, '/ber26.jpg', 'winner'),
      ('$JUP Jupiter DEX on Solana is killing it! Volume through the roof. Loaded my bags heavy 📊', 'JUP', 'long', 8, 32000, 78.9, NULL, 'text'),
      ('$STRK StarkNet airdrop was just the beginning. Layer 2 season is upon us. Opened 35k position 🔥', 'STRK', 'long', 12, 38000, 94.5, NULL, 'text'),
      ('$SEI fastest chain in the game! TVL growing exponentially. Just bought 80k tokens at 0.75$ 📈', 'SEI', 'long', 15, 45000, 156.7, '/ber31.jpg', 'winner'),
      ('Closed my $ETH long at 3,800$. 120k profit. Patience is the key in this market 💰', 'ETH', 'long', 8, 120000, 189.4, NULL, 'text'),
      ('$BTC dominance dropping! Altseason about to start. Loading up on quality altcoins 🚀', 'BTC', 'long', 5, 85000, 67.3, NULL, 'text'),
      ('$LUNC 10M coins secured! This touched 96$ in 2022. History will repeat. Keep buying $LUNC 📈', 'LUNC', 'long', 10, 12500, 45.2, '/ber36.jpg', 'winner'),
      ('$RUNE THORChain cross-chain DEX future! Just opened 55k position. Undervalued gem 💎', 'RUNE', 'long', 10, 48000, 98.7, NULL, 'text'),
      ('$TRX Tron network growing silently! Justin Sun playing 4D chess. Loaded 70k USDT worth 📊', 'TRX', 'long', 6, 42000, 72.3, NULL, 'text'),
      ('$XLM Stellar finally moving! Cross-border payments narrative is hot. Opened 40k long 🔥', 'XLM', 'long', 8, 35000, 84.5, '/ber41.jpg', 'winner'),
      ('$HBAR enterprise adoption growing! Google Cloud partnership. This is going to 1$ minimum 🚀', 'HBAR', 'long', 12, 52000, 112.8, NULL, 'text'),
      ('$SAND metaverse comeback! Gaming tokens about to pump hard this quarter. Loaded my bags 📈', 'SAND', 'long', 15, 38000, 134.6, NULL, 'text'),
      ('$MANA Decentraland partnership with major brands! Virtual real estate about to boom 💎', 'MANA', 'long', 10, 32000, 89.4, '/ber46.jpg', 'winner'),
      ('$CRV Curve Finance liquidity wars heating up! DeFi summer 2.0 incoming. Big position opened 📊', 'CRV', 'long', 8, 45000, 78.9, NULL, 'text'),
      ('$AAVE lending protocol king! TVL back to ATH levels. Opened 60k long position 🔥', 'AAVE', 'long', 7, 55000, 92.3, NULL, 'text'),
      ('$MKR MakerDAO governance token pumping! Real yield narrative is strong. Loaded up 🚀', 'MKR', 'long', 5, 48000, 67.8, '/ber50.jpg', 'winner'),
      ('$SNX Synthetix v3 launch is game changer! Derivatives DEX future. Opened 45k position 📈', 'SNX', 'long', 12, 42000, 105.4, NULL, 'text'),
      ('$COMP Compound Finance growing steadily! Institutional DeFi adoption incoming 💎', 'COMP', 'long', 8, 38000, 84.7, NULL, 'text'),
      ('$GRT The Graph indexing the decentralized web! Web3 infrastructure bet. 40k long opened 📊', 'GRT', 'long', 10, 35000, 94.3, '/ber4.jpg', 'winner'),
      ('$1INCH DEX aggregator dominating! Gas optimization on point. Loaded 30k USDT worth 🔥', 'ONE', 'long', 15, 28000, 134.2, NULL, 'text'),
      ('$CAKE PancakeSwap BSC king! Highest volume DEX on BNB Chain. Just bought 50k tokens 🚀', 'CAKE', 'long', 8, 42000, 78.6, NULL, 'text'),
      ('$AXS Axie Infinity V3 changing the game! Play to earn making a comeback. Opened 35k long 📈', 'AXS', 'long', 10, 32000, 89.7, '/ber9.jpg', 'winner'),
      ('$GALA gaming revolution! New game launches every week. Ecosystem growing fast. Loaded up 💎', 'GALA', 'long', 12, 25000, 112.3, NULL, 'text'),
      ('$ENJ Enjin NFT infrastructure! Gaming tokens about to explode this cycle. Bought 60k tokens 📊', 'ENJ', 'long', 8, 28000, 84.5, NULL, 'text'),
      ('$CHZ Chiliz sports fan tokens! World Cup effect incoming. Opened 40k position at 0.12$ 🔥', 'CHZ', 'long', 15, 35000, 145.8, '/ber14.jpg', 'winner'),
      ('Just scooped 750,000,000 $BTTC. Yep you read that right. This is going to make millionaires', 'BTTC', 'long', 5, 8000, 34.2, '/ber19.jpg', 'winner'),
      ('$VET VeChain supply chain revolution! Real world usage growing. Loaded 100k VET tokens 📈', 'VET', 'long', 10, 32000, 78.9, NULL, 'text'),
      ('$IOTA IoT blockchain leader! Smart city partnerships. Just opened 35k position at 0.35$ 💎', 'IOTA', 'long', 8, 28000, 67.4, NULL, 'text'),
      ('$ZIL Zilliqa sharding technology ahead of its time! Loaded up before the pump. 45k position 📊', 'ZIL', 'long', 12, 38000, 98.5, '/ber24.jpg', 'winner'),
      ('$ICX ICON network Korea blockchain leader! Korean exchanges about to list more pairs 🔥', 'ICX', 'long', 10, 25000, 84.3, NULL, 'text'),
      ('$THETA video streaming on blockchain! Netflix competitor in the making. Opened 50k long 🚀', 'THETA', 'long', 8, 42000, 92.7, NULL, 'text'),
      ('$EGLD MultiversX Layer 1 gem! Fastest growing ecosystem in Europe. Just bought 500 EGLD 📈', 'EGLD', 'long', 7, 55000, 76.8, '/ber29.jpg', 'winner'),
      ('$KSM Kusama canary network! Experimental by design, explosive by nature. Loaded position 💎', 'KSM', 'long', 10, 42000, 89.4, NULL, 'text'),
      ('$FLOW Flow blockchain for gaming and NFTs! Dapper Labs empire growing. 40k long opened 📊', 'FLOW', 'long', 8, 35000, 78.6, NULL, 'text'),
      ('$ONE Harmony bridge recovered! Team building back stronger. Opened 30k position at 0.02$ 🔥', 'ONE', 'long', 15, 28000, 134.5, '/ber34.jpg', 'winner'),
      ('$CKB Nervos Network connecting BTC to everything! The Bitcoin L2 nobody talks about 🚀', 'CKB', 'long', 12, 22000, 112.3, NULL, 'text'),
      ('$ROSE Oasis privacy computing! Web3 privacy narrative is the next big trade. Loaded bags 📈', 'ROSE', 'long', 10, 35000, 94.7, NULL, 'text'),
      ('$KAVA cross-chain DeFi hub! Cosmos ecosystem expanding fast. Opened 45k position 💎', 'KAVA', 'long', 8, 38000, 84.2, '/ber39.jpg', 'winner'),
      ('$CELO mobile-first blockchain! Bringing crypto to billions. Just bought 80k tokens at 0.65$ 📊', 'CELO', 'long', 10, 32000, 78.9, NULL, 'text'),
      ('$ZRX 0x protocol powering DEX trades! Infrastructure play. Opened 35k long position 🔥', 'ZRX', 'long', 8, 28000, 67.4, NULL, 'text'),
      ('$BAT Basic Attention Token! Brave browser growing 50% YoY. Loaded up heavy at 0.30$ 🚀', 'BAT', 'long', 12, 35000, 98.5, '/ber44.jpg', 'winner'),
      ('$LRC Loopring L2 for Ethereum! ZK rollup technology. Just opened 40k position. Target: 5$ 📈', 'LRC', 'long', 10, 38000, 89.3, NULL, 'text'),
      ('$STORJ decentralized cloud storage! AWS killer in the making. Bought 50k STORJ tokens 💎', 'STORJ', 'long', 8, 32000, 78.6, NULL, 'text'),
      ('$SKL SKALE Network feeless blockchain! Gaming adoption growing. Opened 30k position 📊', 'SKL', 'long', 15, 25000, 112.7, '/ber49.jpg', 'winner')
    ) AS t(content, coin, trade, lev, pnl, pnl_pct, img, ptype)
  ) LOOP
    SELECT * INTO rp FROM anonymous_profiles ORDER BY random() LIMIT 1;
    
    INSERT INTO social_posts (
      profile_id, username, avatar_url, content, coin_symbol, trade_type, leverage,
      entry_price, exit_price, profit_loss, profit_loss_percent, image_url, image_url_2,
      post_type, likes_count, comments_count, shares_count, is_bullish, created_at
    ) VALUES (
      rp.id, rp.username, rp.avatar_url, pr.content, pr.coin, pr.trade, pr.lev,
      0, 0, pr.pnl, pr.pnl_pct, pr.img, NULL,
      pr.ptype,
      floor(random() * 700 + 30)::int,
      floor(random() * 120 + 5)::int,
      floor(random() * 70 + 3)::int,
      pr.pnl >= 0,
      NOW() - (random() * interval '14 days')
    );
  END LOOP;
END $$;