/*
  # Remove Female Stock Photos & Add Breaking News Posts

  1. Data Cleanup
    - Remove /ber*.jpg image URLs from social posts (customer service stock photos)

  2. Schema Changes
    - Add 'news' to post_type constraint

  3. New Posts
    - 50 professional crypto breaking news posts
    - Categories: breaking, market, regulation, technology, institutional

  4. RPC Update
    - Updated get_random_social_posts to include news post type
    - Balanced distribution with news posts
*/

UPDATE social_posts SET image_url = NULL WHERE image_url LIKE '/ber%';

ALTER TABLE social_posts DROP CONSTRAINT IF EXISTS social_posts_post_type_check;
ALTER TABLE social_posts ADD CONSTRAINT social_posts_post_type_check
  CHECK (post_type IN ('text', 'winner', 'luxury', 'analysis', 'educational', 'personal', 'event', 'multi_position', 'live_embed', 'news'));

DO $$
DECLARE
  v_profile RECORD;
  v_coins TEXT[] := ARRAY['BTC', 'ETH', 'SOL', 'BNB', 'XRP', 'DOGE', 'ADA', 'AVAX', 'LINK', 'DOT', 'UNI', 'ATOM', 'ARB', 'OP', 'NEAR', 'AAVE', 'INJ', 'SUI', 'JUP', 'PEPE', 'APT', 'TAO', 'TIA', 'SEI', 'RENDER', 'FET', 'ONDO', 'WLD'];
  v_news TEXT[];
  v_coin TEXT;
  v_i INTEGER;
  v_tags JSONB;
BEGIN
  v_news := ARRAY[
    'Bitcoin ETF Daily Volume Surpasses $10 Billion for First Time' || chr(10) || 'Institutional demand continues to accelerate as Bitcoin spot ETFs reach a historic milestone. BlackRock iShares Bitcoin Trust led the charge with over $4.2 billion in single-day trading volume. Analysts suggest this marks a turning point for mainstream crypto adoption.',
    'Ethereum Completes Major Network Upgrade Successfully' || chr(10) || 'The latest Ethereum protocol upgrade has been deployed across all validators without issues. The upgrade introduces improved transaction throughput and reduced gas fees, with early data showing a 40% decrease in average transaction costs.',
    'SEC Approves New Spot Ethereum ETF Applications' || chr(10) || 'Three additional Ethereum ETF applications have received regulatory approval. The newly approved funds are expected to begin trading next week, potentially bringing billions in new capital to the Ethereum ecosystem.',
    'Federal Reserve Signals Rate Cut - Crypto Markets Rally' || chr(10) || 'Federal Reserve officials have indicated a higher probability of interest rate cuts in the coming months. Risk assets including cryptocurrencies saw immediate positive price action, with Bitcoin rising 4.2% within hours of the announcement.',
    'MicroStrategy Acquires Additional 15,000 BTC Worth $1.5 Billion' || chr(10) || 'Michael Saylor continues his aggressive Bitcoin accumulation strategy. The latest purchase brings MicroStrategy total BTC holdings to over 250,000 coins, making it the largest corporate Bitcoin holder in the world.',
    'Solana Network Processes Record 100 Million Transactions in 24 Hours' || chr(10) || 'The Solana blockchain has set a new transaction processing record, handling over 100 million transactions in a single day. Network fees remained below $0.001 per transaction throughout the high-traffic period.',
    'Major Bank Launches Crypto Custody Service for Institutional Clients' || chr(10) || 'One of the world largest banking institutions has officially launched its digital asset custody platform. The service supports Bitcoin, Ethereum, and 20 other cryptocurrencies, with insurance coverage up to $500 million.',
    'Bitcoin Mining Difficulty Reaches New All-Time High' || chr(10) || 'Bitcoin mining difficulty has adjusted upward by 3.2%, reaching a new record. The increase reflects growing competition among miners and continued investment in mining infrastructure globally.',
    'Binance Announces Strategic Partnership with Major Payment Processor' || chr(10) || 'Binance has entered a strategic partnership enabling seamless fiat-to-crypto conversions across 50 countries. The integration is expected to onboard millions of new users to the cryptocurrency ecosystem.',
    'DeFi Total Value Locked Surpasses $200 Billion Milestone' || chr(10) || 'Decentralized finance protocols have collectively surpassed $200 billion in total value locked. Ethereum-based protocols account for 58% of the total, followed by Solana and BNB Chain.',
    'G20 Nations Agree on Unified Crypto Regulatory Framework' || chr(10) || 'Finance ministers from G20 nations have reached a landmark agreement on international cryptocurrency regulation standards. The framework aims to provide clarity for businesses while maintaining consumer protection.',
    'Bitcoin Surpasses Silver in Global Asset Market Cap Ranking' || chr(10) || 'Bitcoin has officially overtaken silver to become the 7th largest asset by market capitalization globally. The milestone highlights the growing acceptance of Bitcoin as a mainstream store of value.',
    'Ethereum Layer 2 Networks TVL Reaches All-Time High of $45 Billion' || chr(10) || 'Layer 2 scaling solutions on Ethereum have reached unprecedented adoption levels. Arbitrum and Optimism lead the segment, collectively processing more transactions than the Ethereum mainnet.',
    'Central Bank Digital Currency Pilot Launches in 5 New Countries' || chr(10) || 'Five additional countries have begun CBDC pilot programs, bringing the total to 30 nations actively testing digital currencies. The pilots focus on cross-border payment efficiency and financial inclusion.',
    'Crypto Exchange Trading Volume Hits $150 Billion in Single Day' || chr(10) || 'Global cryptocurrency exchange trading volume has surged to $150 billion in 24 hours, marking the highest single-day volume in over a year. The spike was driven by increased institutional participation.',
    'BlackRock CEO: Digital Assets Are Legitimate Asset Class' || chr(10) || 'BlackRock CEO Larry Fink has made strong statements supporting cryptocurrencies as a legitimate investment category. The endorsement comes as BlackRock manages over $20 billion in crypto-related products.',
    'New Stablecoin Regulation Passes Congressional Committee' || chr(10) || 'The stablecoin oversight bill has passed through committee with bipartisan support. The legislation establishes clear guidelines for stablecoin issuers including reserve requirements and audit standards.',
    'Major Insurance Company Begins Accepting Bitcoin Premium Payments' || chr(10) || 'A Fortune 500 insurance company has announced it will accept Bitcoin for premium payments starting next quarter. The move signals growing corporate acceptance of cryptocurrency as a payment method.',
    'Crypto Venture Capital Investment Reaches $5.8 Billion in Q1' || chr(10) || 'Venture capital firms invested $5.8 billion in crypto and blockchain startups during Q1, a 120% increase from the previous quarter. DeFi and infrastructure projects attracted the most funding.',
    'Bitcoin Lightning Network Capacity Exceeds 10,000 BTC' || chr(10) || 'The Bitcoin Lightning Network has reached a new milestone with over 10,000 BTC in channel capacity. Transaction speeds on the network average under 1 second with fees below $0.01.',
    'Ethereum Staking Participation Rate Crosses 30% of Total Supply' || chr(10) || 'Over 30% of all ETH is now staked in validators, demonstrating strong network security and holder conviction. The staking yield currently averages 4.2% annually.',
    'South Korea Approves Institutional Crypto Trading Framework' || chr(10) || 'South Korean regulators have approved a comprehensive framework allowing institutional investors to trade cryptocurrencies directly. The decision opens a $2 trillion asset management market to crypto.',
    'Chainlink Launches Cross-Chain Protocol with 15 Blockchain Partners' || chr(10) || 'Chainlink has launched its cross-chain interoperability protocol connecting 15 major blockchains. The protocol enables seamless asset and data transfers across different networks.',
    'NFT Market Shows Signs of Recovery with $2.1 Billion Monthly Volume' || chr(10) || 'The NFT market recorded $2.1 billion in trading volume last month, marking a significant recovery from recent lows. Gaming and utility-focused NFTs are leading the resurgence.',
    'Grayscale Launches New Multi-Asset Crypto Index Fund' || chr(10) || 'Grayscale Investments has introduced a new diversified crypto index fund targeting institutional investors. The fund tracks the top 20 cryptocurrencies by market cap with quarterly rebalancing.',
    'Japan Lowers Crypto Tax Rate to 20% for Individual Investors' || chr(10) || 'Japan has officially reduced the cryptocurrency capital gains tax rate from the maximum 55% to a flat 20%, aligning it with traditional securities taxation. The move is expected to boost domestic trading activity.',
    'Visa Processes $1 Billion in Crypto-Linked Card Transactions Monthly' || chr(10) || 'Visa reports that crypto-linked debit and credit cards are now processing over $1 billion in monthly transactions globally. The figure represents a 300% increase from the previous year.',
    'Bitcoin Options Open Interest Hits Record $30 Billion' || chr(10) || 'Bitcoin options open interest across major exchanges has reached $30 billion, indicating significant institutional hedging and speculation activity. The put/call ratio suggests bullish sentiment.',
    'Polygon Partners with Global Sports League for Fan Engagement' || chr(10) || 'Polygon has announced a multi-year partnership with a major global sports league to power digital fan engagement experiences. The deal includes ticketing, collectibles, and loyalty programs on-chain.',
    'Crypto Market Cap Surpasses $3 Trillion for First Time Since 2021' || chr(10) || 'The total cryptocurrency market capitalization has reclaimed the $3 trillion level. Bitcoin and Ethereum account for approximately 65% of the total, with altcoins showing strong relative performance.',
    'Deutsche Bank Integrates Crypto Trading into Private Banking Platform' || chr(10) || 'Deutsche Bank has begun offering cryptocurrency trading services to its private banking clients. The integration supports Bitcoin, Ethereum, and select altcoins through a regulated custody framework.',
    'Uniswap V4 Launch Drives DEX Volume to New Monthly Record' || chr(10) || 'The launch of Uniswap V4 has propelled decentralized exchange volume to an all-time monthly high. New features including concentrated liquidity hooks and reduced gas costs attracted significant trading activity.',
    'Singapore Grants Full Crypto Licenses to 3 Major Exchanges' || chr(10) || 'Singapore Monetary Authority has approved full operating licenses for three additional cryptocurrency exchanges. The city-state continues to position itself as a leading crypto-friendly jurisdiction.',
    'Fidelity Report: 80% of Institutional Investors View Crypto Favorably' || chr(10) || 'A new Fidelity Digital Assets survey reveals that 80% of institutional investors now have a positive outlook on digital assets. The report also notes that 60% have current allocations to crypto.',
    'US Treasury Clarifies Tax Reporting Rules for Crypto Staking Rewards' || chr(10) || 'The US Treasury has issued updated guidance clarifying that staking rewards are taxable upon receipt. The clarification provides much-needed regulatory certainty for proof-of-stake participants.',
    'Ripple Wins Partial Victory in Ongoing SEC Lawsuit' || chr(10) || 'A federal judge has ruled in favor of Ripple on key aspects of the SEC enforcement action. The ruling establishes important precedents for how cryptocurrency tokens are classified under securities law.',
    'Avalanche Foundation Launches $100 Million Ecosystem Growth Fund' || chr(10) || 'The Avalanche Foundation has committed $100 million to support developers building on the Avalanche ecosystem. The fund will provide grants, liquidity incentives, and technical resources.',
    'Global Crypto ATM Count Surpasses 50,000 Machines' || chr(10) || 'The number of cryptocurrency ATMs worldwide has exceeded 50,000. The United States leads with 35,000 installations, followed by Canada and Europe. Average daily transaction volume per machine continues to grow.',
    'Coinbase International Exchange Launches Perpetual Futures for 20 New Pairs' || chr(10) || 'Coinbase has expanded its international derivatives platform with 20 new perpetual futures contracts. The expansion targets professional traders seeking regulated alternatives to offshore exchanges.',
    'World Economic Forum Publishes Blockchain Technology Standards Guide' || chr(10) || 'The WEF has released comprehensive guidelines for blockchain technology implementation across industries. The standards cover interoperability, security, and governance best practices.',
    'Cardano Completes Plutus V3 Smart Contract Upgrade' || chr(10) || 'Cardano has successfully deployed the Plutus V3 smart contract platform, enabling more efficient and cost-effective decentralized applications. Early benchmarks show 5x improvement in execution speed.',
    'US Pension Fund Allocates 2% of Portfolio to Bitcoin' || chr(10) || 'A major US state pension fund has approved a 2% allocation to Bitcoin, marking one of the largest public pension investments in cryptocurrency. The allocation represents approximately $800 million.',
    'Tether USDT Market Cap Reaches $120 Billion Milestone' || chr(10) || 'Tether has reached a new milestone with USDT market capitalization exceeding $120 billion. The stablecoin continues to dominate the market with over 70% share of total stablecoin supply.',
    'Hong Kong Crypto ETFs See Record Inflows in First Month' || chr(10) || 'Hong Kong-listed cryptocurrency ETFs have attracted over $2 billion in net inflows during their first month of trading. Asian institutional demand is exceeding analyst expectations.',
    'Cosmos IBC Processes 10 Million Cross-Chain Transactions' || chr(10) || 'The Cosmos Inter-Blockchain Communication protocol has processed its 10 millionth cross-chain transaction. The milestone demonstrates growing adoption of interoperable blockchain networks.',
    'JPMorgan Launches Blockchain-Based Settlement Platform' || chr(10) || 'JPMorgan has launched its institutional blockchain settlement platform, enabling real-time settlement of tokenized assets. The platform supports government bonds, corporate debt, and money market instruments.',
    'Brazil Mandates Crypto Exchange Registration with Central Bank' || chr(10) || 'Brazil Central Bank has issued new regulations requiring all cryptocurrency exchanges operating in the country to register and comply with anti-money laundering standards. The deadline is set for Q3.',
    'AI and Crypto Sector Tokens Rally on New Partnership Announcements' || chr(10) || 'Tokens at the intersection of artificial intelligence and blockchain have seen significant gains following several major partnership announcements. FET, RENDER, and TAO led the sector with double-digit gains.',
    'Circle Launches USDC on 5 Additional Blockchain Networks' || chr(10) || 'Circle has expanded USDC availability to five new blockchain networks, bringing the total supported chains to 15. The expansion aims to improve cross-chain liquidity and payment efficiency.',
    'Crypto Winter Officially Over According to Major Research Firm' || chr(10) || 'A leading digital asset research firm has declared the crypto winter officially over based on multiple on-chain and market indicators. The report cites sustained institutional inflows and improving fundamentals.'
  ];

  FOR v_i IN 1..50 LOOP
    SELECT * INTO v_profile FROM anonymous_profiles ORDER BY random() LIMIT 1;
    v_coin := v_coins[1 + floor(random() * array_length(v_coins, 1))::int];

    v_tags := json_build_array(
      json_build_object('symbol', v_coin, 'change', round((random() * 12 - 4)::numeric, 2)),
      json_build_object('symbol', v_coins[1 + floor(random() * array_length(v_coins, 1))::int], 'change', round((random() * 10 - 5)::numeric, 2))
    )::jsonb;

    INSERT INTO social_posts (
      username, avatar_url, content, coin_symbol, trade_type, entry_price, exit_price,
      profit_loss, profit_loss_percent, leverage, image_url, post_type,
      likes_count, comments_count, shares_count, is_bullish, created_at,
      coin_tags, sentiment
    ) VALUES (
      CASE WHEN random() > 0.6 THEN 'CryptoNews' WHEN random() > 0.3 THEN 'MarketWatch' ELSE 'BlockchainDaily' END,
      v_profile.avatar_url,
      v_news[1 + ((v_i - 1) % array_length(v_news, 1))],
      v_coin, 'long', 0, 0, 0, 0, 1, NULL, 'news',
      floor(random() * 800 + 50)::int, floor(random() * 150 + 10)::int,
      floor(random() * 300 + 20)::int, true,
      now() - (random() * interval '3 days'),
      v_tags, 'neutral'
    );
  END LOOP;
END $$;

DROP FUNCTION IF EXISTS get_random_social_posts(integer);

CREATE FUNCTION get_random_social_posts(post_limit integer DEFAULT 50)
RETURNS TABLE(
  id uuid,
  username text,
  avatar_url text,
  content text,
  coin_symbol text,
  trade_type text,
  entry_price numeric,
  exit_price numeric,
  profit_loss numeric,
  profit_loss_percent numeric,
  leverage integer,
  image_url text,
  image_url_2 text,
  post_type text,
  likes_count integer,
  comments_count integer,
  shares_count integer,
  is_bullish boolean,
  created_at timestamptz,
  coin_tags jsonb,
  asset_change_30d numeric,
  chart_coin text,
  sub_positions jsonb,
  live_room_data jsonb,
  sentiment text
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  v_text_count integer;
  v_analysis_count integer;
  v_educational_count integer;
  v_personal_count integer;
  v_event_count integer;
  v_multi_count integer;
  v_live_count integer;
  v_news_count integer;
BEGIN
  v_text_count := GREATEST(1, post_limit * 24 / 100);
  v_analysis_count := GREATEST(1, post_limit * 12 / 100);
  v_educational_count := GREATEST(1, post_limit * 12 / 100);
  v_personal_count := GREATEST(1, post_limit * 12 / 100);
  v_event_count := GREATEST(1, post_limit * 5 / 100);
  v_multi_count := GREATEST(1, post_limit * 10 / 100);
  v_live_count := GREATEST(1, post_limit * 10 / 100);
  v_news_count := GREATEST(1, post_limit * 15 / 100);

  RETURN QUERY
  SELECT * FROM (
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type IN ('text', 'winner') ORDER BY random() LIMIT v_text_count)
    UNION ALL
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type = 'analysis' ORDER BY random() LIMIT v_analysis_count)
    UNION ALL
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type = 'educational' ORDER BY random() LIMIT v_educational_count)
    UNION ALL
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type = 'personal' ORDER BY random() LIMIT v_personal_count)
    UNION ALL
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type = 'event' ORDER BY random() LIMIT v_event_count)
    UNION ALL
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type = 'multi_position' ORDER BY random() LIMIT v_multi_count)
    UNION ALL
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type = 'live_embed' ORDER BY random() LIMIT v_live_count)
    UNION ALL
    (SELECT sp.id, sp.username, sp.avatar_url, sp.content, sp.coin_symbol, sp.trade_type,
      sp.entry_price, sp.exit_price, sp.profit_loss, sp.profit_loss_percent, sp.leverage,
      sp.image_url, sp.image_url_2, sp.post_type, sp.likes_count, sp.comments_count,
      sp.shares_count, sp.is_bullish, sp.created_at, sp.coin_tags, sp.asset_change_30d,
      sp.chart_coin, sp.sub_positions, sp.live_room_data, sp.sentiment
    FROM social_posts sp WHERE sp.post_type = 'news' ORDER BY random() LIMIT v_news_count)
  ) combined
  ORDER BY random();
END;
$$;