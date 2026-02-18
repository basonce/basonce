/*
  # Fix equipment_type_id to be nullable
  
  1. Changes
    - Make equipment_type_id column nullable in user_mining_equipment table
    - This allows inserting equipment without equipment_type_id reference
  
  2. Reason
    - Shop purchases don't use equipment_type_id
    - They directly insert equipment details (name, icon, hash_rate, etc.)
*/

ALTER TABLE user_mining_equipment 
ALTER COLUMN equipment_type_id DROP NOT NULL;
