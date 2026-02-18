/*
  # Update Support Agent Avatars with Local Photos
  
  1. Purpose
    - Replace external Pexels URLs with local uploaded photos
    - Use uploaded photos from /ber1.jpg to /ber50.jpg
    - Randomly distribute 50 photos across 400 agents
    - Each photo will be used by multiple agents
  
  2. Distribution
    - 400 agents total
    - 50 unique photos
    - Each photo used by ~8 agents on average
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
