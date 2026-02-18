/*
  # Fix FREE CPU Miner Test Mode
  
  1. Changes
    - Update give_free_cpu_miner trigger to set test_mode: true
    - This makes FREE trial complete in 60 seconds (1 minute) instead of 3 hours
    
  2. Why
    - For testing purposes, 3 hours is too long
    - test_mode: true makes mining 180x faster (60 seconds total)
*/

-- Update the trigger function to include test_mode
CREATE OR REPLACE FUNCTION give_free_cpu_miner()
RETURNS TRIGGER AS $$
DECLARE
  v_free_equipment_id UUID;
BEGIN
  -- Get the FREE CPU Miner equipment
  SELECT id INTO v_free_equipment_id
  FROM mining_equipment_types
  WHERE is_free = true
  LIMIT 1;
  
  -- Give it to the new user with test_mode enabled
  IF v_free_equipment_id IS NOT NULL THEN
    INSERT INTO user_mining_equipment (
      user_id,
      equipment_type_id,
      icon,
      is_active,
      started_at,
      ends_at,
      test_mode,
      status,
      mining_duration_seconds
    )
    SELECT 
      NEW.id,
      v_free_equipment_id,
      icon,
      false,
      NULL,
      NULL,
      true,
      'stopped',
      0
    FROM mining_equipment_types
    WHERE id = v_free_equipment_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update existing FREE CPU Miners to have test_mode enabled
UPDATE user_mining_equipment
SET test_mode = true
WHERE equipment_type_id IN (
  SELECT id FROM mining_equipment_types WHERE is_free = true
);