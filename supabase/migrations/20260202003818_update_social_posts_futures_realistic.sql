/*
  # Update Social Posts to Realistic Futures Trading Data

  1. Changes
    - Delete all existing social posts with random images
    - Create new realistic futures trading posts
    - Use actual coin prices from Basonce
    - Remove image_url (set to NULL) - only show position cards like in futures page
    - Generate diverse realistic trading scenarios
    - Mix of profitable and loss positions
    - Various leverage levels (5x-125x)
    - Different time frames and trading styles
  
  2. Realistic Trading Data
    - BTC, ETH, BNB, SOL, DOGE, XRP, ADA, MATIC, LINK, DOT positions
    - Entry and exit prices based on recent market data
    - Realistic margin amounts and PnL
    - Professional trading content/comments
    - Mix of long and short positions
    
  3. Purpose
    - Match futures page design consistency
    - Show real trading activity
    - Remove fake social media images
    - Create professional trading community feel
*/

-- Delete all existing posts
DELETE FROM social_posts;

-- Insert realistic futures trading posts with actual market prices
INSERT INTO social_posts (username, avatar_url, content, coin_symbol, trade_type, entry_price, exit_price, profit_loss, profit_loss_percent, leverage, image_url, likes_count, comments_count, shares_count, is_bullish, created_at) VALUES

-- BTC Positions
('CryptoKing', 'https://i.pravatar.cc/150?img=12', 'BTC breaking 100k resistance! Opened long position with tight stop loss.', 'BTC', 'long', 98450.00, 101250.00, 2840.50, 5.67, 20, NULL, 124, 23, 8, true, NOW() - INTERVAL '2 hours'),
('TraderMike', 'https://i.pravatar.cc/150?img=33', 'Short BTC here, expecting pullback to 97k support zone', 'BTC', 'short', 100800.00, 98200.00, 1300.00, 2.58, 10, NULL, 89, 15, 4, true, NOW() - INTERVAL '4 hours'),
('BTCMaxi', 'https://i.pravatar.cc/150?img=56', 'HODL is not a strategy in futures! Closed my long at perfect timing', 'BTC', 'long', 96800.00, 101100.00, 4430.00, 8.87, 20, NULL, 256, 47, 19, true, NOW() - INTERVAL '6 hours'),

-- ETH Positions  
('EthWhale', 'https://i.pravatar.cc/150?img=22', 'ETH looking strong above 3800! Long position opened', 'ETH', 'long', 3780.00, 3920.00, 1850.00, 7.40, 25, NULL, 178, 31, 12, true, NOW() - INTERVAL '1 hour'),
('DeFiTrader', 'https://i.pravatar.cc/150?img=44', 'Took profit on my ETH long. Markets too volatile right now', 'ETH', 'long', 3650.00, 3890.00, 3280.00, 13.15, 20, NULL, 203, 28, 15, true, NOW() - INTERVAL '3 hours'),
('AltcoinPro', 'https://i.pravatar.cc/150?img=67', 'ETH rejected at 4k. Opened short with 50x leverage 🎯', 'ETH', 'short', 3980.00, 3820.00, 4000.00, 8.04, 50, NULL, 312, 52, 22, true, NOW() - INTERVAL '5 hours'),

-- SOL Positions
('SolanaMaxi', 'https://i.pravatar.cc/150?img=15', 'SOL pumping hard! Entered long at 195, target 210', 'SOL', 'long', 195.50, 207.80, 1564.00, 12.56, 25, NULL, 167, 29, 11, true, NOW() - INTERVAL '2 hours'),
('CryptoNinja', 'https://i.pravatar.cc/150?img=38', 'Solana network congestion FUD. Perfect time to long!', 'SOL', 'long', 198.00, 206.00, 1010.00, 8.08, 25, NULL, 145, 24, 9, true, NOW() - INTERVAL '4 hours'),

-- BNB Positions
('BinanceTrader', 'https://i.pravatar.cc/150?img=28', 'BNB breaking out! Long with 30x leverage', 'BNB', 'long', 695.00, 718.00, 1985.00, 6.61, 30, NULL, 198, 33, 14, true, NOW() - INTERVAL '3 hours'),
('DayTrader99', 'https://i.pravatar.cc/150?img=51', 'Closed BNB short too early... still profitable though', 'BNB', 'short', 710.00, 698.00, 675.00, 3.38, 20, NULL, 92, 16, 5, true, NOW() - INTERVAL '7 hours'),

-- DOGE Positions
('DogeArmy', 'https://i.pravatar.cc/150?img=19', 'DOGE to the moon! 🚀 100x leverage lets go!', 'DOGE', 'long', 0.3850, 0.4120, 7020.00, 14.03, 100, NULL, 423, 89, 45, true, NOW() - INTERVAL '1 hour'),
('MemeTrader', 'https://i.pravatar.cc/150?img=42', 'DOGE pump was expected. Easy money with high leverage', 'DOGE', 'long', 0.3780, 0.4050, 3567.00, 14.29, 50, NULL, 267, 41, 18, true, NOW() - INTERVAL '5 hours'),

-- XRP Positions
('RippleTrader', 'https://i.pravatar.cc/150?img=24', 'XRP breaking key resistance. Longing here with stop at 2.85', 'XRP', 'long', 2.92, 3.08, 1372.00, 10.96, 25, NULL, 156, 27, 10, true, NOW() - INTERVAL '2 hours'),
('CryptoWhale', 'https://i.pravatar.cc/150?img=47', 'XRP lawsuit victory priced in. Time to short', 'XRP', 'short', 3.05, 2.94, 902.00, 7.21, 25, NULL, 134, 22, 8, true, NOW() - INTERVAL '6 hours'),

-- Loss Positions (Realistic Mix)
('Rekt_Trader', 'https://i.pravatar.cc/150?img=31', 'Stop loss hit on BTC long. Market too choppy today', 'BTC', 'long', 99800.00, 98200.00, -1600.00, -3.21, 20, NULL, 67, 12, 3, false, NOW() - INTERVAL '3 hours'),
('NoobTrader', 'https://i.pravatar.cc/150?img=54', 'Liquidated on ETH short... 125x was too much', 'ETH', 'short', 3850.00, 3980.00, -3250.00, -6.75, 125, NULL, 89, 34, 7, false, NOW() - INTERVAL '4 hours'),
('LeverageKing', 'https://i.pravatar.cc/150?img=63', 'Got stopped out. Will revenge trade later 😤', 'SOL', 'short', 202.00, 208.00, -1485.00, -5.94, 25, NULL, 45, 18, 2, false, NOW() - INTERVAL '5 hours'),

-- More Profitable Positions
('SmartMoney', 'https://i.pravatar.cc/150?img=17', 'ADA finally moving! Took profit at +8%', 'ADA', 'long', 0.8950, 0.9680, 1630.00, 16.31, 20, NULL, 187, 29, 11, true, NOW() - INTERVAL '3 hours'),
('PatientTrader', 'https://i.pravatar.cc/150?img=39', 'MATIC breakout confirmed. Easy 10% gain', 'MATIC', 'long', 0.7850, 0.8640, 2015.00, 20.13, 25, NULL, 223, 37, 15, true, NOW() - INTERVAL '4 hours'),
('TechAnalyst', 'https://i.pravatar.cc/150?img=26', 'LINK bounced perfectly off support. Long position working well', 'LINK', 'long', 22.40, 24.80, 2150.00, 21.43, 20, NULL, 198, 32, 13, true, NOW() - INTERVAL '2 hours'),
('SwingTrader', 'https://i.pravatar.cc/150?img=48', 'DOT weekly chart looking bullish. Entered long', 'DOT', 'long', 8.25, 9.15, 1635.00, 21.82, 15, NULL, 167, 28, 12, true, NOW() - INTERVAL '6 hours'),

-- More Realistic Scenarios
('ScalpMaster', 'https://i.pravatar.cc/150?img=13', 'Quick scalp on BTC. In and out in 15 minutes', 'BTC', 'long', 99200.00, 99850.00, 655.00, 1.31, 50, NULL, 134, 19, 7, true, NOW() - INTERVAL '1 hour'),
('TrendFollower', 'https://i.pravatar.cc/150?img=35', 'Following the trend on ETH. Never fight the tape!', 'ETH', 'long', 3720.00, 3880.00, 2150.00, 8.60, 20, NULL, 176, 26, 10, true, NOW() - INTERVAL '4 hours'),
('GridTrader', 'https://i.pravatar.cc/150?img=57', 'Grid trading SOL working perfectly today', 'SOL', 'long', 199.00, 205.00, 754.00, 6.03, 25, NULL, 142, 21, 8, true, NOW() - INTERVAL '3 hours'),
('NewsTrader', 'https://i.pravatar.cc/150?img=21', 'Bought BNB on the news. Sold on confirmation', 'BNB', 'long', 702.00, 716.00, 1195.00, 3.99, 30, NULL, 156, 24, 9, true, NOW() - INTERVAL '5 hours'),
('RiskManager', 'https://i.pravatar.cc/150?img=43', 'Small loss on DOGE but risk was controlled. Good trade management', 'DOGE', 'short', 0.3950, 0.4020, -885.00, -3.54, 50, NULL, 78, 13, 4, false, NOW() - INTERVAL '2 hours'),

-- Professional Traders
('ProTrader100', 'https://i.pravatar.cc/150?img=16', 'BTC consolidation break. Long with target 105k', 'BTC', 'long', 98900.00, 102400.00, 3535.00, 7.08, 20, NULL, 289, 43, 17, true, NOW() - INTERVAL '2 hours'),
('InstitutionalFlow', 'https://i.pravatar.cc/150?img=37', 'ETH/BTC ratio bullish. Longed ETH, shorted BTC', 'ETH', 'long', 3800.00, 3950.00, 1975.00, 7.89, 25, NULL, 234, 38, 14, true, NOW() - INTERVAL '3 hours'),
('AlgoTrader', 'https://i.pravatar.cc/150?img=58', 'Algorithm signaled SOL long. Following the system', 'SOL', 'long', 197.00, 206.00, 2285.00, 9.14, 25, NULL, 198, 31, 12, true, NOW() - INTERVAL '4 hours'),
('OptionsTrader', 'https://i.pravatar.cc/150?img=29', 'Hedged my spot with BNB short. Working perfectly', 'BNB', 'short', 712.00, 703.00, 1270.00, 2.53, 30, NULL, 167, 27, 10, true, NOW() - INTERVAL '6 hours'),
('MacroInvestor', 'https://i.pravatar.cc/150?img=50', 'DOGE showing strength. Entered small long position', 'DOGE', 'long', 0.3880, 0.4100, 2835.00, 11.34, 50, NULL, 223, 36, 15, true, NOW() - INTERVAL '1 hour');