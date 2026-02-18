/*
  # Create 240 Social Posts - Batch 3: Normal Trading Posts (Part 2/2)

  ## Overview
  Creates another 80 normal trading posts to reach 160 total trading posts.
  Combined with 80 luxury posts = 240 total.
  
  ## Content
  - More diverse coin coverage
  - Mix of bullish/bearish sentiment
  - Realistic leverage and PnL numbers
  - Natural social media language
*/

DO $$
DECLARE
  rp anonymous_profiles%ROWTYPE;
  pr RECORD;
BEGIN
  FOR pr IN (
    SELECT * FROM (VALUES
      ('$BTC 100k is not a meme! Just doubled down on my position. 200k total exposure now 🚀', 'BTC', 'long', 10, 135000, 198.4, NULL, 'text'),
      ('$ETH merge was just the beginning. Deflationary tokenomics kicking in. Ultra sound money 📈', 'ETH', 'long', 8, 72000, 112.3, NULL, 'text'),
      ('$SOL TPS records being broken daily! Fastest L1 in the game. Added more to my position 🔥', 'SOL', 'long', 15, 88000, 167.5, '/ber2.jpg', 'winner'),
      ('$BNB Binance listing new coins every week! Exchange token alpha. Opened 45k position 💎', 'BNB', 'long', 7, 42000, 78.9, NULL, 'text'),
      ('$XRP 3$ target is conservative! Utility token for banks. Cross-border payments future 📊', 'XRP', 'long', 12, 65000, 134.2, NULL, 'text'),
      ('$ADA Hydra scaling solution live! 1 million TPS incoming. Cardano believers will be rewarded 🚀', 'ADA', 'long', 10, 48000, 98.7, '/ber8.jpg', 'winner'),
      ('$DOGE to the moon! Twitter integration rumors getting stronger. 50k position opened 📈', 'DOGE', 'long', 15, 55000, 178.4, NULL, 'text'),
      ('$SHIB ecosystem growing! ShibaSwap V2, Shibarium, Bone. Whole DeFi stack. Loaded up heavy 🔥', 'SHIB', 'long', 20, 35000, 234.5, NULL, 'text'),
      ('$AVAX subnets are the future! Custom blockchain for every use case. Just opened 60k long 💎', 'AVAX', 'long', 10, 52000, 112.8, '/ber13.jpg', 'winner'),
      ('$LINK oracle problem solved! Every DeFi protocol needs Chainlink. Accumulating more 📊', 'LINK', 'long', 8, 45000, 89.3, NULL, 'text'),
      ('$DOT parachains delivering results! Real interoperability happening. Position: 55k long 🚀', 'DOT', 'long', 10, 50000, 98.6, NULL, 'text'),
      ('$MATIC zkEVM live and scaling! Polygon tech is years ahead. Just added 40k to my position 📈', 'MATIC', 'long', 12, 42000, 112.4, '/ber18.jpg', 'winner'),
      ('$UNI V4 hooks game changer! Customizable liquidity pools. DeFi innovation leader 🔥', 'UNI', 'long', 8, 38000, 84.5, NULL, 'text'),
      ('$AAVE flash loans 2.0! DeFi lending on steroids. Opened 50k long. Target: 200$ 💎', 'AAVE', 'long', 7, 48000, 76.8, NULL, 'text'),
      ('$FTM Sonic upgrade coming! 10x speed improvement. Fantom about to fly. 45k position 📊', 'FTM', 'long', 15, 42000, 145.6, '/ber23.jpg', 'winner'),
      ('$NEAR AI integration narrative! Protocol building AI tools on chain. Loaded 55k long 🚀', 'NEAR', 'long', 10, 48000, 105.3, NULL, 'text'),
      ('$ATOM IBC expanding to new chains! Cosmos hub value accrual. Opened 40k position 📈', 'ATOM', 'long', 8, 35000, 84.7, NULL, 'text'),
      ('$INJ perpetuals DEX king! Highest volume on-chain derivatives. Added 60k to position 🔥', 'INJ', 'long', 12, 58000, 134.2, '/ber28.jpg', 'winner'),
      ('$TIA data availability is the new narrative! Celestia modular thesis winning. 35k long 💎', 'TIA', 'long', 10, 32000, 89.5, NULL, 'text'),
      ('$SUI Move language blockchain! Developer friendly means adoption. Opened 45k position 📊', 'SUI', 'long', 8, 40000, 78.6, NULL, 'text'),
      ('$APT Aptos DeFi TVL exploding! New projects launching daily. Just loaded 50k worth 🚀', 'APT', 'long', 10, 45000, 98.4, '/ber33.jpg', 'winner'),
      ('$OP Superchain vision massive! Every L2 will be built on OP Stack. Opened 55k long 📈', 'OP', 'long', 12, 52000, 112.7, NULL, 'text'),
      ('$ARB Nitro upgrade complete! Arbitrum fastest growing L2. Position: 60k USDT long 🔥', 'ARB', 'long', 10, 55000, 105.8, NULL, 'text'),
      ('$RENDER GPU computing on blockchain! AI needs compute. Perfect intersection. 40k long 💎', 'RENDER', 'long', 8, 38000, 84.3, '/ber38.jpg', 'winner'),
      ('$FET artificial intelligence meets blockchain! Fetch.ai partnerships growing. Loaded bags 📊', 'FET', 'long', 10, 42000, 92.5, NULL, 'text'),
      ('$ONDO BlackRock tokenization partner! Real world assets on chain. Opened 50k position 🚀', 'ONDO', 'long', 7, 45000, 78.9, NULL, 'text'),
      ('$JUP Solana DEX aggregator dominating! Best UI in DeFi. Just bought 80k tokens 📈', 'JUP', 'long', 10, 35000, 98.7, '/ber43.jpg', 'winner'),
      ('This $BTC dip is a gift. Buying the blood. Opened 100k long with 15x leverage. See you at 80k 🔥', 'BTC', 'long', 15, 95000, 215.4, NULL, 'text'),
      ('$ETH gas fees lowest in 2 years! L2 scaling working. Bullish for adoption. Added more 💎', 'ETH', 'long', 5, 52000, 56.7, NULL, 'text'),
      ('$BTC ETF inflows record high! Institutional money flooding in. This is just the start 📊', 'BTC', 'long', 8, 78000, 112.3, '/ber48.jpg', 'winner'),
      ('Closed my $DOGE short perfectly. Market makers can not touch this trader. 45k profit 💰', 'DOGE', 'short', 20, 45000, -189.4, NULL, 'text'),
      ('$SOL NFT volume back to ATH! Magic Eden partnership announced. Opened 70k long 🚀', 'SOL', 'long', 12, 65000, 134.8, NULL, 'text'),
      ('$PEPE frog season! Meme coins rotating. $PEPE next leg up incoming. 25k position opened 📈', 'PEPE', 'long', 25, 22000, 267.3, '/ber3.jpg', 'winner'),
      ('$BNB quarterly burn happening! 600M worth of BNB getting burned. Supply shock incoming 🔥', 'BNB', 'long', 10, 58000, 105.6, NULL, 'text'),
      ('$XRP SEC appeal dismissed! Clear skies ahead. Opened massive long. Target: 5$ 💎', 'XRP', 'long', 15, 85000, 178.4, NULL, 'text'),
      ('$ADA smart contracts usage growing! Real DeFi on Cardano. Opened 55k position 📊', 'ADA', 'long', 10, 48000, 94.5, '/ber10.jpg', 'winner'),
      ('$LINK CCIP live on 15 chains! Cross-chain interoperability solved. Chainlink is king 🚀', 'LINK', 'long', 8, 62000, 89.7, NULL, 'text'),
      ('$DOT 2.0 upgrade complete! Faster finality, better UX. Polkadot renaissance. 45k long 📈', 'DOT', 'long', 10, 42000, 98.3, NULL, 'text'),
      ('$AVAX institutional adoption! Deloitte partnership expanding. Opened 55k position 🔥', 'AVAX', 'long', 8, 50000, 84.6, '/ber15.jpg', 'winner'),
      ('$MATIC Disney partnership delivering! Polygon in the metaverse. Just added 40k more 💎', 'MATIC', 'long', 12, 38000, 112.8, NULL, 'text'),
      ('$SHIB Shibarium daily transactions exploding! L2 adoption real. Loaded more $SHIB 📊', 'SHIB', 'long', 15, 32000, 145.7, NULL, 'text'),
      ('$DOGE Dogecoin Core update! Faster transactions, lower fees. Still the people coin 🐕', 'DOGE', 'long', 10, 42000, 98.4, '/ber20.jpg', 'winner'),
      ('$FTM Andre Cronje building again! DeFi OG returns. Fantom ecosystem about to boom 🚀', 'FTM', 'long', 12, 45000, 112.5, NULL, 'text'),
      ('$NEAR Protocol AI marketplace live! First mover advantage in AI x Crypto. 50k long 📈', 'NEAR', 'long', 10, 48000, 105.2, NULL, 'text'),
      ('$ATOM Neutron and Stride growing! Cosmos DeFi expanding. Opened 45k position 🔥', 'ATOM', 'long', 8, 40000, 84.7, '/ber25.jpg', 'winner'),
      ('$INJ burn auction record! 5M INJ burned this quarter. Deflation on steroids 💎', 'INJ', 'long', 10, 55000, 98.6, NULL, 'text'),
      ('$SUI DEX volume surging! Move language developer tools improving. Added 40k position 📊', 'SUI', 'long', 12, 38000, 112.4, NULL, 'text'),
      ('$APT Microsoft partnership confirmed! Enterprise blockchain adoption. Opened 60k long 🚀', 'APT', 'long', 8, 52000, 89.5, '/ber30.jpg', 'winner'),
      ('$TIA blob space demand growing! Rollups need Celestia. Data availability narrative strong 📈', 'TIA', 'long', 10, 35000, 94.8, NULL, 'text'),
      ('$OP bedrock upgrade improved performance! Transaction costs down 40%. Loaded more 🔥', 'OP', 'long', 8, 42000, 78.9, NULL, 'text'),
      ('$ARB Orbit chains launching! Custom L3s on Arbitrum. Innovation at scale. 50k long 💎', 'ARB', 'long', 12, 48000, 112.3, '/ber35.jpg', 'winner'),
      ('$RENDER Apple Vision Pro needs GPU compute! Decentralized rendering is the answer 📊', 'RENDER', 'long', 10, 42000, 98.7, NULL, 'text'),
      ('$FET autonomous AI agents trading on chain! The future is here. Opening 45k position 🚀', 'FET', 'long', 8, 40000, 84.5, NULL, 'text'),
      ('$ONDO treasury bill tokens on chain! 5% yield in DeFi. Traditional finance migrating 📈', 'ONDO', 'long', 7, 48000, 76.4, '/ber40.jpg', 'winner'),
      ('$RUNE cross chain swaps without bridges! THORChain solving the interop problem 🔥', 'RUNE', 'long', 12, 52000, 112.8, NULL, 'text'),
      ('$TRX stablecoin network king! Most USDT on Tron. Transaction volume incredible 💎', 'TRX', 'long', 8, 38000, 78.6, NULL, 'text'),
      ('$HBAR CBDC pilot programs worldwide! Hedera enterprise adoption. Opened 50k long 📊', 'HBAR', 'long', 10, 45000, 94.3, '/ber45.jpg', 'winner'),
      ('$ALGO state proofs live! Bridging to Ethereum trustlessly. Algorand tech is elite 🚀', 'ALGO', 'long', 8, 35000, 84.7, NULL, 'text'),
      ('$LTC MimbleWimble privacy option! Litecoin innovating quietly. Opened 40k position 📈', 'LTC', 'long', 6, 38000, 72.4, NULL, 'text'),
      ('$SAND The Sandbox Alpha Season 4! Gaming metaverse adoption growing. Loaded bags 🔥', 'SAND', 'long', 12, 32000, 112.5, '/ber50.jpg', 'winner'),
      ('$MANA fashion brands in Decentraland! Virtual commerce growing. Opened 35k long 💎', 'MANA', 'long', 10, 30000, 89.4, NULL, 'text'),
      ('$CRV real yield narrative back! Curve wars 2.0 heating up. DeFi blue chip. 45k position 📊', 'CRV', 'long', 8, 42000, 78.8, NULL, 'text'),
      ('$MKR DAI savings rate at 8%! Risk free yield in DeFi. MakerDAO dominance. Loaded up 🚀', 'MKR', 'long', 5, 55000, 56.7, '/ber5.png', 'winner'),
      ('$GRT subgraph queries at record levels! Web3 needs indexing. The Graph is essential 📈', 'GRT', 'long', 12, 28000, 98.5, NULL, 'text'),
      ('$VET VeChain x BMW partnership expansion! Real supply chain tracking. 45k long opened 🔥', 'VET', 'long', 10, 38000, 89.7, NULL, 'text'),
      ('$THETA EdgeCloud live! Decentralized computing for AI. Video streaming plus AI. Loaded 💎', 'THETA', 'long', 8, 42000, 78.4, '/ber11.jpg', 'winner'),
      ('$EGLD MultiversX gaming hub! xPortal super app growing. 1M daily users. Opened 50k long 📊', 'EGLD', 'long', 7, 48000, 76.8, NULL, 'text'),
      ('$FLOW NBA Top Shot resurgence! Collectibles market coming back. Position: 35k long 🚀', 'FLOW', 'long', 10, 32000, 89.3, NULL, 'text'),
      ('$CHZ Chiliz 2.0 launch! Fan tokens for every major sports team. Opened 40k position 📈', 'CHZ', 'long', 12, 38000, 105.4, '/ber16.jpg', 'winner'),
      ('$KSM parachain slots filling up! Kusama experiments leading to Polkadot innovation 🔥', 'KSM', 'long', 10, 42000, 94.5, NULL, 'text'),
      ('$ROSE privacy preserving AI! Oasis Network x Meta partnership. Opened 35k long 💎', 'ROSE', 'long', 8, 32000, 84.6, NULL, 'text'),
      ('$KAVA Cosmos DeFi hub! Lending and staking platform growing. Just added 40k position 📊', 'KAVA', 'long', 10, 38000, 89.7, '/ber21.jpg', 'winner'),
      ('$LRC Loopring exchange volume up 300%! ZK rollup adoption real. Opened 35k long 🚀', 'LRC', 'long', 12, 32000, 112.3, NULL, 'text'),
      ('$BAT Brave search market share growing! Privacy browser revolution. Loaded more tokens 📈', 'BAT', 'long', 8, 28000, 78.4, NULL, 'text'),
      ('$IOTA Shimmer network TVL growing! IoT blockchain leader. Added 30k to position 🔥', 'IOTA', 'long', 10, 25000, 89.5, '/ber26.jpg', 'winner'),
      ('$ZIL EVM compatibility achieved! Zilliqa 2.0 is a game changer. Opened 35k position ��', 'ZIL', 'long', 12, 32000, 98.7, NULL, 'text'),
      ('$ICX BTP cross-chain protocol! ICON bridge connecting all blockchains. 30k long opened 📊', 'ICX', 'long', 8, 28000, 78.9, NULL, 'text'),
      ('$DGB DigiByte speed test record! 560 TPS achieved. OG coin making moves. Loaded up 🚀', 'DGB', 'long', 10, 22000, 89.4, '/ber31.jpg', 'winner'),
      ('Just scooped 100M $LUNC at these prices. When this hits 1$ I am retiring. Diamond hands only', 'LUNC', 'long', 5, 15000, 45.6, '/ber36.jpg', 'winner')
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