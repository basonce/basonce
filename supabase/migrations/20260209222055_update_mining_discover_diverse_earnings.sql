/*
  # Update Mining Discover Users with Diverse Earnings

  1. Updates
    - Mix of losers, small winners, medium winners, and big winners
    - Losers: -$20 to -$300
    - Small winners: $5 to $50
    - Medium winners: $50 to $300
    - Big winners: $300 to $2,000
    - Makes the discover feed more realistic and engaging
*/

-- Update with diverse earnings (losers and winners)
UPDATE mining_discover_users
SET 
  total_earned = CASE 
    -- Losers (positions 20-22)
    WHEN user_id IN (
      SELECT user_id FROM mining_discover_users 
      ORDER BY total_earned DESC 
      LIMIT 3 OFFSET 19
    ) THEN (RANDOM() * 280 + 20) * -2 -- -$20 to -$300 (in EQ, multiply by -2)
    
    -- Small winners (positions 15-19)
    WHEN user_id IN (
      SELECT user_id FROM mining_discover_users 
      ORDER BY total_earned DESC 
      LIMIT 5 OFFSET 14
    ) THEN RANDOM() * 90 + 10 -- $5 to $50 (10-100 EQ)
    
    -- Medium winners (positions 6-14)
    WHEN user_id IN (
      SELECT user_id FROM mining_discover_users 
      ORDER BY total_earned DESC 
      LIMIT 9 OFFSET 5
    ) THEN RANDOM() * 500 + 100 -- $50 to $300 (100-600 EQ)
    
    -- Big winners (top 5)
    ELSE RANDOM() * 3400 + 600 -- $300 to $2,000 (600-4000 EQ)
  END,
  mining_power = CASE 
    WHEN user_id IN (
      SELECT user_id FROM mining_discover_users 
      ORDER BY total_earned DESC 
      LIMIT 3 OFFSET 19
    ) THEN RANDOM() * 0.5 + 0.1 -- Low power for losers
    
    WHEN user_id IN (
      SELECT user_id FROM mining_discover_users 
      ORDER BY total_earned DESC 
      LIMIT 5 OFFSET 14
    ) THEN RANDOM() * 2 + 0.5 -- Small power
    
    WHEN user_id IN (
      SELECT user_id FROM mining_discover_users 
      ORDER BY total_earned DESC 
      LIMIT 9 OFFSET 5
    ) THEN RANDOM() * 8 + 2 -- Medium power
    
    ELSE RANDOM() * 20 + 10 -- High power for big winners
  END
WHERE id IN (SELECT id FROM mining_discover_users LIMIT 25);
