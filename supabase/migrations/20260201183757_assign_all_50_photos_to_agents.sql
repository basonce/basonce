/*
  # Assign All 50 Photos to 400 Support Agents
  
  1. Purpose
    - Assign all 50 uploaded photos (ber1.jpg - ber50.jpg) to support agents
    - Random distribution across 400 agents
    - Each photo used by ~8 agents on average
  
  2. Photos
    - ber1.jpg to ber50.jpg (49 files)
    - ber5.png (1 PNG file)
    - Total: 50 unique photos
  
  3. Distribution Strategy
    - 400 agents / 50 photos = 8 agents per photo (average)
    - Random assignment for variety
*/

-- Update all agents with local photo URLs in random order
WITH agent_list AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (ORDER BY RANDOM()) as random_order
  FROM support_agents
),
photo_assignment AS (
  SELECT 
    id,
    '/ber' || (((random_order - 1) % 50) + 1) || 
    CASE 
      WHEN ((random_order - 1) % 50) + 1 = 5 THEN '.png'
      ELSE '.jpg'
    END as photo_url
  FROM agent_list
)
UPDATE support_agents sa
SET avatar_url = pa.photo_url
FROM photo_assignment pa
WHERE sa.id = pa.id;
