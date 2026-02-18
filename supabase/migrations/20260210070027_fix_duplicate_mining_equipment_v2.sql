/*
  # Remove Duplicate Mining Equipment

  1. Problem
    - Users have multiple equipment of the same tier/level
    - Each user should only have ONE equipment per tier

  2. Solution
    - Keep the oldest equipment for each user-tier combination
    - Delete all duplicates

  3. Changes
    - Delete duplicate user_mining_equipment records
    - Keep only the first (oldest) equipment per user per tier
*/

-- Delete duplicate equipment, keeping only the oldest one for each user-tier combination
-- We're using the level column from mining_equipment_types
DELETE FROM user_mining_equipment
WHERE id NOT IN (
  SELECT DISTINCT ON (ume.user_id, met.tier) ume.id
  FROM user_mining_equipment ume
  INNER JOIN mining_equipment_types met ON ume.equipment_type_id = met.id
  ORDER BY ume.user_id, met.tier, ume.created_at ASC
);
