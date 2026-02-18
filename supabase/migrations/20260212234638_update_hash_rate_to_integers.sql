/*
  # Update Hash Rate to Whole Numbers
  
  1. Changes
    - Round all hash_rate values to whole numbers (no decimals)
    - Remove decimal points from hash power display
    
  2. Examples
    - 19.58 → 20
    - 41.45 → 41
    - 43.33 → 43
    
  This makes the UI cleaner and more professional
*/

-- Round hash_rate values to whole numbers
UPDATE mining_equipment_types 
SET hash_rate = ROUND(hash_rate);
