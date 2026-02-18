/*
  # Fix Withdrawal Limits - Each Equipment Can Earn Up To Its Limit
  
  1. Strategy
    - Each equipment has withdrawal_limit = maximum it can earn
    - This prevents withdrawal from individual equipment earnings
    - Global system minimum: $10,000 total balance required
    
  2. Cumulative Earnings Path
    - Level 0: Earn $130 (total: $130, limit: $130) ❌
    - Level 1: Earn $180 (total: $310, limit: $180) ❌
    - Level 2: Earn $500 (total: $810, limit: $500) ❌
    - Level 3: Earn $1,300 (total: $2,110, limit: $1,300) ❌
    - Level 4: Earn $2,800 (total: $4,910, limit: $2,800) ❌
    - Level 5: Earn $8,000 (total: $12,910, limit: $10,000) ✅ Can withdraw!
*/

-- Set each equipment's withdrawal limit to exactly what it can earn
UPDATE mining_equipment_types 
SET withdrawal_limit = (daily_earning * mining_duration_hours / 24)
WHERE level IN (0, 1, 2, 3, 4);

-- Level 5 withdrawal limit stays at $10,000 (global minimum for withdrawal unlock)
UPDATE mining_equipment_types 
SET withdrawal_limit = 10000.00
WHERE level = 5;
