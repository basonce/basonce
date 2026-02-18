/*
  # Update Futures Leverage Limits
  
  1. Changes
    - Increase max leverage from 50x to 125x for isolated mode
    - Update constraint on futures_positions table
    
  2. Notes
    - Cross mode: Max 20x (enforced in application)
    - Isolated mode: Max 125x
*/

-- Drop existing constraint
ALTER TABLE futures_positions 
DROP CONSTRAINT IF EXISTS futures_positions_leverage_check;

-- Add new constraint with higher limit
ALTER TABLE futures_positions 
ADD CONSTRAINT futures_positions_leverage_check 
CHECK (leverage >= 1 AND leverage <= 125);