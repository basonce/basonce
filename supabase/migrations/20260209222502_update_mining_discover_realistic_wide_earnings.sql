/*
  # Update Mining Discover with Realistic Wide Earnings Range

  1. Updates
    - Small winners: $500 to $1,380 (1,000-2,760 EQ)
    - Medium winners: $1,380 to $7,451 (2,760-14,902 EQ)
    - Big winners: $7,451 to $51,849 (14,902-103,698 EQ)
    - Losers: -$20 to -$9,856 (-40 to -19,712 EQ)
    - More realistic and diverse earnings distribution
*/

-- Update with realistic wide earnings range
UPDATE mining_discover_users
SET 
  total_earned = CASE 
    -- Losers (positions 20-24) - Losing between $20 and $9,856
    WHEN user_id IN (
      SELECT user_id FROM mining_discover_users 
      ORDER BY total_earned DESC 
      LIMIT 5 OFFSET 19
    ) THEN (RANDOM() * 19672 + 40) * -1 -- -$20 to -$9,856 (-40 to -19,712 EQ)
    
    -- Small winners (positions 12-19) - $500 to $1,380
    WHEN user_id IN (
      SELECT user_id FROM mining_discover_users 
      ORDER BY total_earned DESC 
      LIMIT 8 OFFSET 11
    ) THEN RANDOM() * 1760 + 1000 -- $500 to $1,380 (1,000-2,760 EQ)
    
    -- Medium winners (positions 4-11) - $1,380 to $7,451
    WHEN user_id IN (
      SELECT user_id FROM mining_discover_users 
      ORDER BY total_earned DESC 
      LIMIT 8 OFFSET 3
    ) THEN RANDOM() * 12142 + 2760 -- $1,380 to $7,451 (2,760-14,902 EQ)
    
    -- Big winners (top 3) - $7,451 to $51,849
    ELSE RANDOM() * 88796 + 14902 -- $7,451 to $51,849 (14,902-103,698 EQ)
  END,
  mining_power = CASE 
    -- Low power for losers
    WHEN user_id IN (
      SELECT user_id FROM mining_discover_users 
      ORDER BY total_earned DESC 
      LIMIT 5 OFFSET 19
    ) THEN RANDOM() * 1.5 + 0.2
    
    -- Small power for small winners
    WHEN user_id IN (
      SELECT user_id FROM mining_discover_users 
      ORDER BY total_earned DESC 
      LIMIT 8 OFFSET 11
    ) THEN RANDOM() * 5 + 2
    
    -- Medium power for medium winners
    WHEN user_id IN (
      SELECT user_id FROM mining_discover_users 
      ORDER BY total_earned DESC 
      LIMIT 8 OFFSET 3
    ) THEN RANDOM() * 15 + 8
    
    -- High power for big winners
    ELSE RANDOM() * 35 + 20
  END
WHERE id IN (SELECT id FROM mining_discover_users LIMIT 30);
