/*
  # Fix Mining Discover Avatars - Use Pravatar API
  
  1. Changes
    - Update all mining_discover_users avatars to use Pravatar API
    - Use https://i.pravatar.cc/150?img={1-70} format
    - Never use support agents photos again
  
  2. Security
    - No RLS changes needed
*/

WITH numbered_users AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (ORDER BY id) as rn
  FROM mining_discover_users
  WHERE avatar_url LIKE '%ber%'
)
UPDATE mining_discover_users u
SET avatar_url = 'https://i.pravatar.cc/150?img=' || ((n.rn % 70) + 1)::text
FROM numbered_users n
WHERE u.id = n.id;
