/*
  # Create VIP Live Rooms System with 72 Premium Rooms
  
  1. Schema Changes
    - Add `is_vip` column to live_rooms (boolean)
    - Add `required_level` column (integer, default 0)
    - Add `access_type` column (text: 'public', 'premium', 'vip', 'exclusive')
    - Add `room_category` column (text: trading topics)
    - Add `background_gradient` column (text: custom gradient colors)
    
  2. Data Population
    - Clear existing rooms
    - Create 72 new rooms with diverse topics
    - 50% VIP rooms (36 rooms) - requires premium access
    - 50% Public rooms (36 rooms) - free access
    - Premium VIP design with gold/platinum themes
    
  3. Room Categories
    - Crypto Trading Analysis
    - Futures Market Insights
    - NFT & DeFi Discussions
    - Technical Analysis
    - Risk Management
    - Market News & Updates
*/

-- Add new columns to live_rooms table
ALTER TABLE live_rooms 
  ADD COLUMN IF NOT EXISTS is_vip BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS required_level INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS access_type TEXT DEFAULT 'public' CHECK (access_type IN ('public', 'premium', 'vip', 'exclusive')),
  ADD COLUMN IF NOT EXISTS room_category TEXT DEFAULT 'General Trading',
  ADD COLUMN IF NOT EXISTS background_gradient TEXT DEFAULT 'from-purple-600 to-purple-800';

-- Clear existing rooms
TRUNCATE TABLE live_rooms CASCADE;

-- Insert 72 premium live rooms (36 VIP + 36 Public)
INSERT INTO live_rooms (title, description, topic, listener_count, is_active, is_vip, required_level, access_type, room_category, background_gradient) VALUES
  -- VIP EXCLUSIVE ROOMS (36)
  ('Elite Traders Circle', 'Million dollar portfolio strategies', 'VIP Trading Signals', 2847, true, true, 5, 'exclusive', 'VIP Trading', 'from-amber-500 via-yellow-500 to-amber-600'),
  ('Whale Watch Premium', 'Track the biggest market moves', 'Whale Movements', 3521, true, true, 5, 'exclusive', 'Market Analysis', 'from-yellow-600 via-amber-500 to-yellow-700'),
  ('Diamond Hands Lounge', 'Long-term wealth strategies', 'Investment Strategy', 2934, true, true, 4, 'vip', 'Investment', 'from-cyan-400 via-blue-500 to-cyan-600'),
  ('Platinum Futures Club', 'Advanced futures trading', 'Futures Mastery', 4123, true, true, 5, 'exclusive', 'Futures Trading', 'from-slate-300 via-gray-200 to-slate-400'),
  ('Golden Alpha Signals', 'Exclusive market insights', 'Alpha Signals', 5234, true, true, 5, 'exclusive', 'Trading Signals', 'from-yellow-500 via-amber-400 to-yellow-600'),
  ('VIP Market Makers', 'Institutional trading secrets', 'Market Making', 1876, true, true, 5, 'exclusive', 'Advanced Trading', 'from-amber-600 via-orange-500 to-amber-700'),
  ('Crown Trading Suite', 'Royal trading strategies', 'Premium Analysis', 3456, true, true, 4, 'vip', 'Market Analysis', 'from-yellow-400 via-amber-500 to-orange-500'),
  ('Elite DeFi Hub', 'Exclusive DeFi opportunities', 'DeFi Investments', 2567, true, true, 4, 'vip', 'DeFi', 'from-emerald-400 via-teal-500 to-cyan-500'),
  ('Sapphire Spot Trading', 'Premium spot strategies', 'Spot Trading VIP', 3890, true, true, 4, 'vip', 'Spot Trading', 'from-blue-500 via-indigo-500 to-blue-600'),
  ('Gold Rush Analytics', 'Real-time premium data', 'Market Analytics', 4567, true, true, 5, 'exclusive', 'Analytics', 'from-yellow-600 via-amber-600 to-yellow-700'),
  ('Prestige Leverage Zone', '100x leverage strategies', 'High Leverage', 2345, true, true, 5, 'exclusive', 'Leverage Trading', 'from-red-500 via-orange-500 to-red-600'),
  ('Imperial Trading Room', 'Empire building strategies', 'Wealth Building', 3123, true, true, 4, 'vip', 'Wealth Management', 'from-purple-500 via-violet-500 to-purple-600'),
  ('Emerald Options Club', 'Advanced options trading', 'Options Trading', 2789, true, true, 4, 'vip', 'Options', 'from-emerald-500 via-green-500 to-emerald-600'),
  ('Titanium Risk Room', 'Risk management mastery', 'Risk Control VIP', 1934, true, true, 4, 'vip', 'Risk Management', 'from-gray-400 via-slate-500 to-gray-600'),
  ('Luxury Arbitrage Hub', 'Cross-exchange profits', 'Arbitrage VIP', 2456, true, true, 5, 'exclusive', 'Arbitrage', 'from-pink-400 via-rose-500 to-pink-600'),
  ('Premium Scalping Den', 'Lightning fast trades', 'Scalping VIP', 3678, true, true, 4, 'vip', 'Scalping', 'from-green-500 via-emerald-500 to-green-600'),
  ('Royal NFT Vault', 'Blue chip NFT strategies', 'NFT VIP', 2890, true, true, 4, 'vip', 'NFT Trading', 'from-violet-400 via-purple-500 to-violet-600'),
  ('Supreme Swing Traders', 'Perfect entry timing', 'Swing Trading VIP', 3234, true, true, 4, 'vip', 'Swing Trading', 'from-blue-400 via-cyan-500 to-blue-600'),
  ('Diamond Altcoin Picks', 'Hidden gem discoveries', 'Altcoin VIP', 4456, true, true, 5, 'exclusive', 'Altcoins', 'from-teal-400 via-cyan-500 to-teal-600'),
  ('Executive Trading Floor', 'C-suite trading strategies', 'Executive Trading', 1567, true, true, 5, 'exclusive', 'Professional', 'from-slate-600 via-gray-700 to-slate-800'),
  ('Golden Cross Signals', 'Technical indicator mastery', 'Technical Analysis VIP', 3890, true, true, 4, 'vip', 'Technical Analysis', 'from-yellow-500 via-orange-500 to-yellow-600'),
  ('Platinum Portfolio Club', 'Diversification strategies', 'Portfolio VIP', 2678, true, true, 4, 'vip', 'Portfolio Management', 'from-gray-300 via-slate-400 to-gray-500'),
  ('VIP Market Psychology', 'Master trader mindset', 'Trading Psychology', 2123, true, true, 4, 'vip', 'Psychology', 'from-indigo-400 via-blue-500 to-indigo-600'),
  ('Crown Crypto Royalty', 'Elite crypto networking', 'Networking VIP', 1890, true, true, 5, 'exclusive', 'Networking', 'from-amber-500 via-yellow-600 to-amber-700'),
  ('Supreme Trend Riders', 'Ride the biggest trends', 'Trend Trading VIP', 3567, true, true, 4, 'vip', 'Trend Trading', 'from-orange-400 via-red-500 to-orange-600'),
  ('Gold Standard Trading', 'Highest quality setups', 'Premium Setups', 2934, true, true, 5, 'exclusive', 'Trade Setups', 'from-yellow-600 via-amber-600 to-yellow-700'),
  ('Elite Breakout Room', 'Early breakout detection', 'Breakout VIP', 3456, true, true, 4, 'vip', 'Breakout Trading', 'from-red-400 via-orange-500 to-red-600'),
  ('Prestige Token Launch', 'New token opportunities', 'Token Launch VIP', 4789, true, true, 5, 'exclusive', 'Token Launches', 'from-purple-400 via-fuchsia-500 to-purple-600'),
  ('Imperial Day Trading', 'Intraday profit strategies', 'Day Trading VIP', 3123, true, true, 4, 'vip', 'Day Trading', 'from-green-400 via-emerald-500 to-green-600'),
  ('Sapphire Sentiment Hub', 'Market sentiment analysis', 'Sentiment VIP', 2567, true, true, 4, 'vip', 'Market Sentiment', 'from-blue-400 via-indigo-500 to-blue-600'),
  ('Crown Derivatives Club', 'Advanced derivatives', 'Derivatives VIP', 1987, true, true, 5, 'exclusive', 'Derivatives', 'from-yellow-500 via-orange-500 to-yellow-600'),
  ('VIP Liquidity Pool', 'Liquidity farming secrets', 'Liquidity VIP', 2456, true, true, 4, 'vip', 'Liquidity', 'from-cyan-400 via-blue-500 to-cyan-600'),
  ('Golden Momentum Zone', 'Momentum trading mastery', 'Momentum VIP', 3678, true, true, 4, 'vip', 'Momentum Trading', 'from-amber-500 via-orange-600 to-amber-700'),
  ('Elite Multi-Chain Hub', 'Cross-chain opportunities', 'Multi-Chain VIP', 2890, true, true, 4, 'vip', 'Multi-Chain', 'from-violet-400 via-purple-500 to-violet-600'),
  ('Diamond Macro Room', 'Macro economic analysis', 'Macro VIP', 2234, true, true, 5, 'exclusive', 'Macro Analysis', 'from-cyan-500 via-blue-600 to-cyan-700'),
  ('Supreme Hodl Vault', 'Long-term holding strategies', 'Hodl VIP', 3890, true, true, 4, 'vip', 'Long-term Investment', 'from-emerald-400 via-green-500 to-emerald-600'),

  -- PUBLIC ROOMS (36)
  ('BTC Bulls Discussion', 'Bitcoin market analysis', 'Bitcoin Trading', 4567, true, false, 0, 'public', 'Bitcoin', 'from-orange-500 to-orange-700'),
  ('Ethereum Hub', 'ETH trading and news', 'Ethereum', 3890, true, false, 0, 'public', 'Ethereum', 'from-blue-500 to-blue-700'),
  ('Altcoin Hunters', 'Discover new altcoins', 'Altcoin Discovery', 5234, true, false, 0, 'public', 'Altcoins', 'from-green-500 to-green-700'),
  ('Futures Trading 101', 'Learn futures basics', 'Futures Education', 2876, true, false, 0, 'public', 'Education', 'from-purple-500 to-purple-700'),
  ('Spot Market Central', 'Spot trading discussions', 'Spot Trading', 3456, true, false, 0, 'public', 'Spot Trading', 'from-teal-500 to-teal-700'),
  ('DeFi Explorers', 'Decentralized finance', 'DeFi', 2567, true, false, 0, 'public', 'DeFi', 'from-cyan-500 to-cyan-700'),
  ('NFT Marketplace', 'NFT trading community', 'NFTs', 1987, true, false, 0, 'public', 'NFT', 'from-pink-500 to-pink-700'),
  ('Technical Analysis Room', 'Chart patterns and indicators', 'TA Discussion', 3234, true, false, 0, 'public', 'Technical Analysis', 'from-indigo-500 to-indigo-700'),
  ('Crypto News Live', 'Breaking crypto news', 'News & Updates', 6789, true, false, 0, 'public', 'News', 'from-red-500 to-red-700'),
  ('Beginner Traders Club', 'New to crypto trading', 'Beginners', 4123, true, false, 0, 'public', 'Education', 'from-blue-400 to-blue-600'),
  ('Daily Market Overview', 'Market summary and analysis', 'Market Analysis', 5567, true, false, 0, 'public', 'Market Analysis', 'from-violet-500 to-violet-700'),
  ('Swing Trading Community', 'Multi-day positions', 'Swing Trading', 2890, true, false, 0, 'public', 'Swing Trading', 'from-emerald-500 to-emerald-700'),
  ('Scalping Strategies', 'Quick profit techniques', 'Scalping', 3678, true, false, 0, 'public', 'Scalping', 'from-yellow-500 to-yellow-700'),
  ('Risk Management 101', 'Protect your capital', 'Risk Management', 2456, true, false, 0, 'public', 'Risk Management', 'from-orange-500 to-orange-700'),
  ('Layer 2 Solutions', 'Scaling networks discussion', 'Layer 2', 1876, true, false, 0, 'public', 'Technology', 'from-blue-500 to-blue-700'),
  ('Meme Coins Madness', 'Trending meme tokens', 'Meme Coins', 7890, true, false, 0, 'public', 'Meme Coins', 'from-pink-400 to-pink-600'),
  ('Staking & Rewards', 'Passive income strategies', 'Staking', 2234, true, false, 0, 'public', 'Staking', 'from-green-500 to-green-700'),
  ('Trading Psychology', 'Master your emotions', 'Psychology', 1567, true, false, 0, 'public', 'Psychology', 'from-purple-500 to-purple-700'),
  ('Leverage Trading Talk', 'Margin and leverage', 'Leverage', 3123, true, false, 0, 'public', 'Leverage Trading', 'from-red-500 to-red-700'),
  ('Portfolio Building', 'Diversification strategies', 'Portfolio', 2678, true, false, 0, 'public', 'Portfolio', 'from-teal-500 to-teal-700'),
  ('Market Sentiment Chat', 'Community market feels', 'Sentiment', 4456, true, false, 0, 'public', 'Sentiment', 'from-indigo-500 to-indigo-700'),
  ('Blockchain Technology', 'Tech behind crypto', 'Technology', 1890, true, false, 0, 'public', 'Technology', 'from-cyan-500 to-cyan-700'),
  ('Options Trading Hub', 'Crypto options discussion', 'Options', 2345, true, false, 0, 'public', 'Options', 'from-orange-500 to-orange-700'),
  ('Arbitrage Opportunities', 'Cross-exchange trading', 'Arbitrage', 1678, true, false, 0, 'public', 'Arbitrage', 'from-green-500 to-green-700'),
  ('Web3 & Metaverse', 'Future of internet', 'Web3', 2987, true, false, 0, 'public', 'Web3', 'from-violet-500 to-violet-700'),
  ('Fundamental Analysis', 'Project evaluation', 'Fundamentals', 1765, true, false, 0, 'public', 'Fundamental Analysis', 'from-blue-500 to-blue-700'),
  ('Gaming & NFTs', 'GameFi discussion', 'GameFi', 3456, true, false, 0, 'public', 'Gaming', 'from-purple-500 to-purple-700'),
  ('Liquidity Pools', 'DeFi liquidity farming', 'Liquidity', 2123, true, false, 0, 'public', 'DeFi', 'from-teal-500 to-teal-700'),
  ('Token Economics', 'Tokenomics analysis', 'Tokenomics', 1543, true, false, 0, 'public', 'Tokenomics', 'from-orange-500 to-orange-700'),
  ('Smart Contract Security', 'Audit and safety', 'Security', 1287, true, false, 0, 'public', 'Security', 'from-red-500 to-red-700'),
  ('Regulatory Updates', 'Crypto regulations news', 'Regulations', 2456, true, false, 0, 'public', 'Regulations', 'from-indigo-500 to-indigo-700'),
  ('Mining & Validators', 'Network participation', 'Mining', 1876, true, false, 0, 'public', 'Mining', 'from-yellow-500 to-yellow-700'),
  ('Cross-Chain Bridges', 'Multi-chain connectivity', 'Bridges', 1654, true, false, 0, 'public', 'Technology', 'from-cyan-500 to-cyan-700'),
  ('Crypto Tax Planning', 'Tax optimization', 'Tax & Legal', 1432, true, false, 0, 'public', 'Tax', 'from-green-500 to-green-700'),
  ('Community Governance', 'DAO participation', 'Governance', 1765, true, false, 0, 'public', 'Governance', 'from-purple-500 to-purple-700'),
  ('Market Cycles Study', 'Bull and bear markets', 'Market Cycles', 2890, true, false, 0, 'public', 'Market Analysis', 'from-orange-500 to-orange-700');

-- Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_live_rooms_vip ON live_rooms(is_vip, is_active);
CREATE INDEX IF NOT EXISTS idx_live_rooms_access ON live_rooms(access_type, is_active);
