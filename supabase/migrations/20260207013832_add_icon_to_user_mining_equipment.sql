/*
  # Add Icon to User Mining Equipment
  
  1. Changes
    - Add icon column to user_mining_equipment table
    - This allows storing the equipment icon from shop
*/

-- Add icon column
ALTER TABLE user_mining_equipment 
ADD COLUMN IF NOT EXISTS icon text DEFAULT '💻';

-- Update existing CPU Miners to have proper icon
UPDATE user_mining_equipment 
SET icon = '💻' 
WHERE name = 'CPU Miner' AND icon IS NULL;
