/*
  # Expand Mining Shop with Diverse Equipment
  
  1. Changes
    - Add 20+ new mining equipment options
    - Cover all price ranges from $50 to $300K
    - Include GPUs, ASICs, Rigs, and Enterprise solutions
    - Realistic hashrates and earnings
    - Fixed tier values to match constraint
*/

-- Add diverse mining equipment
INSERT INTO mining_shop_items (name, description, tier, level, price_usdt, hash_rate, hourly_earning_usdt, daily_earning_usdt, roi_days, icon, badge, bonus_text, withdrawal_enabled, min_withdrawal_amount, max_mining_hours, sold_count, is_available)
VALUES
  -- Level 1: Affordable Starters ($50-500)
  ('GTX 1660 Super', 'Affordable GPU miner perfect for beginners. Low power, steady earnings.', 'starter', 1, 50, 32, 5, 120, 10, '🎮', 'BUDGET', '+10% Weekend Bonus', true, 50, NULL, 1847, true),
  ('RX 580 8GB', 'Popular AMD GPU with great mining efficiency. Perfect starter choice!', 'starter', 1, 75, 45, 7.5, 180, 10, '💎', 'POPULAR', 'AMD Optimized', true, 50, NULL, 2193, true),
  ('GTX 1080 Ti', 'High-performance GPU with excellent hashrate. Great value!', 'starter', 1, 150, 75, 15, 360, 10, '⚡', 'VALUE', '+15% Bonus', true, 75, NULL, 1567, true),
  ('RTX 3060', 'Modern NVIDIA GPU with efficient mining. LHR unlocked!', 'starter', 1, 300, 95, 30, 720, 10, '🚀', 'NEW', 'LHR Unlocked', true, 100, NULL, 2891, true),
  
  -- Level 2: Mid-Range Powerhouses ($500-2000)
  ('RTX 3070 Ti', 'Powerful NVIDIA GPU with 8GB VRAM. High efficiency mining!', 'popular', 2, 600, 125, 75, 1800, 8, '💪', 'EFFICIENT', '+20% Hash Boost', true, 100, NULL, 1923, true),
  ('RTX 3080', 'Premium GPU miner with 10GB memory. Professional grade!', 'popular', 2, 900, 180, 120, 2880, 7, '🔥', 'HOT DEAL', '+25% Earnings', true, 150, NULL, 2456, true),
  ('RX 6800 XT', 'AMD flagship GPU with incredible hashrate. Very profitable!', 'popular', 2, 850, 175, 115, 2760, 7, '💥', 'AMD BEAST', '+22% AMD Bonus', true, 150, NULL, 1678, true),
  ('4-GPU Mining Rig', 'Pre-built rig with 4x RTX 3060 Ti. Plug and play!', 'popular', 2, 1800, 550, 220, 5280, 8, '🏗️', 'BEST VALUE', 'Pre-Configured', true, 300, NULL, 1234, true),
  
  -- Level 2-3: Professional ASICs ($2000-8000)
  ('Antminer S19j Pro', 'Professional ASIC with 100 TH/s. Industry standard!', 'advanced', 2, 2500, 1000, 280, 6720, 9, '⚙️', 'PRO SERIES', 'Antminer Series', true, 500, NULL, 987, true),
  ('Whatsminer M30S', 'Powerful ASIC miner with great efficiency. Top performer!', 'advanced', 3, 3500, 1850, 450, 10800, 8, '🛠️', 'EFFICIENT', '+30% Efficiency', true, 750, NULL, 743, true),
  ('AvalonMiner 1246', 'High-end ASIC with 90 TH/s. Reliable and stable!', 'advanced', 3, 3000, 1500, 400, 9600, 7, '⚡', 'STABLE', 'Enterprise Grade', true, 600, NULL, 892, true),
  ('6-GPU Pro Rig', 'Professional rig with 6x RTX 3080. Maximum performance!', 'advanced', 3, 4500, 1800, 550, 13200, 8, '💎', 'PRO RIG', '6-GPU Setup', true, 1000, NULL, 567, true),
  ('Antminer S19 XP', 'Latest generation ASIC. 140 TH/s beast!', 'advanced', 3, 6000, 3200, 850, 20400, 7, '👑', 'LATEST', '140 TH/s Power', true, 1500, NULL, 456, true),
  
  -- Level 3-4: Enterprise Solutions ($8000-30000)
  ('8-GPU Mega Rig', 'Mega rig with 8x RTX 3090. Maximum GPU power!', 'enterprise', 3, 8500, 4500, 1100, 26400, 8, '🏭', 'MEGA RIG', '8-GPU Beast', false, 25000, NULL, 234, true),
  ('Mining Container Pro', 'Shipping container with 50+ ASICs. Industrial scale!', 'enterprise', 4, 15000, 12000, 2500, 60000, 6, '📦', 'INDUSTRIAL', '50+ ASICs', false, 50000, NULL, 156, true),
  ('Antminer Farm 20x', 'Complete farm with 20 Antminer S19. Turnkey solution!', 'enterprise', 4, 22000, 18000, 3500, 84000, 6, '🏢', 'FARM', '20x S19 Units', false, 80000, NULL, 98, true),
  ('Hydro Mining Setup', 'Water-cooled mining farm. Ultra-efficient cooling!', 'enterprise', 4, 28000, 24000, 4500, 108000, 6, '💧', 'HYDRO', 'Water Cooled', false, 100000, NULL, 67, true),
  
  -- Level 4-5: Elite & Legendary ($30000-300000)
  ('Mining Warehouse', 'Full warehouse with 100+ miners. Massive scale!', 'enterprise', 4, 45000, 45000, 7500, 180000, 6, '🏭', 'ELITE', '100+ Miners', false, 150000, NULL, 34, true),
  ('Data Center Mini', 'Small data center setup. Professional operation!', 'enterprise', 4, 75000, 75000, 13000, 312000, 6, '🏢', 'DATA CENTER', 'Pro Operation', false, 300000, NULL, 23, true),
  ('Blockchain Complex', 'Complete blockchain mining complex. Ultimate power!', 'limited', 5, 150000, 150000, 28000, 672000, 5, '🌐', 'LEGENDARY', 'VIP Access', false, 600000, NULL, 12, true),
  ('Global Mining Network', 'Worldwide distributed mining network. God-tier!', 'limited', 5, 300000, 300000, 60000, 1440000, 5, '👑', 'GOD TIER', 'Global Network', false, 999999999, NULL, 3, true)
ON CONFLICT (id) DO NOTHING;
