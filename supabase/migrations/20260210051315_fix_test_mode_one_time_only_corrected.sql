/*
  # Fix Test Mode - Make It One-Time Only (CORRECTED)

  1. Problem
    - Users stay in test mode forever
    - They can mine infinitely with 180x speed
    - No incentive to buy premium equipment
    - We lose money!

  2. Solution
    - Test mode works ONLY ONCE per user
    - After first completion, test_mode switches to false
    - All future mining is normal speed (3 hours)
    - Users must buy equipment to continue profitable mining

  3. Changes
    - Add completed_test_mode column to user_profiles
    - Create function to disable test mode after first completion
    - Update trigger to check if user already completed test mode
    - Set withdrawal limit enforcement

  4. Strategy
    - User gets free $130 in test mode (60 seconds)
    - They collect, see the money
    - Try again, but now it takes 3 REAL HOURS
    - Realization: "I need better equipment!"
    - They buy from shop with the $130
    - We profit, they feel they're winning
*/

-- Add column to track test mode completion
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS completed_test_mode boolean DEFAULT false;

-- Function to disable test mode after completion
CREATE OR REPLACE FUNCTION disable_test_mode_after_completion()
RETURNS TRIGGER AS $$
BEGIN
  -- If mining duration reached max in test mode
  IF NEW.test_mode = true 
     AND NEW.mining_duration_seconds >= 60 
     AND NEW.status = 'stopped' THEN
    
    -- Switch equipment to normal mode
    NEW.test_mode := false;
    
    -- Mark user as completed test mode
    UPDATE user_profiles
    SET completed_test_mode = true
    WHERE id = NEW.user_id;
    
    RAISE NOTICE 'Test mode completed for user %. Switching to normal mode.', NEW.user_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for test mode completion
DROP TRIGGER IF EXISTS check_test_mode_completion ON user_mining_equipment;
CREATE TRIGGER check_test_mode_completion
  BEFORE UPDATE ON user_mining_equipment
  FOR EACH ROW
  EXECUTE FUNCTION disable_test_mode_after_completion();

-- Function to check if user should get test mode
CREATE OR REPLACE FUNCTION should_enable_test_mode(p_user_id uuid)
RETURNS boolean AS $$
DECLARE
  v_completed boolean;
BEGIN
  SELECT completed_test_mode INTO v_completed
  FROM user_profiles
  WHERE id = p_user_id;
  
  -- If never completed test mode, allow it
  RETURN COALESCE(v_completed, false) = false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update existing trigger to respect test mode completion
CREATE OR REPLACE FUNCTION give_free_cpu_miner()
RETURNS TRIGGER AS $$
DECLARE
  v_free_equipment record;
  v_should_test boolean;
BEGIN
  -- Check if user should get test mode
  v_should_test := should_enable_test_mode(NEW.id);
  
  -- Get FREE CPU Miner
  SELECT * INTO v_free_equipment
  FROM mining_equipment_types
  WHERE is_free = true
  LIMIT 1;

  IF v_free_equipment.id IS NOT NULL THEN
    -- Give it to the new user
    INSERT INTO user_mining_equipment (
      user_id,
      equipment_type_id,
      icon,
      is_active,
      status,
      mining_duration_seconds,
      test_mode,
      started_at,
      ends_at
    ) VALUES (
      NEW.id,
      v_free_equipment.id,
      v_free_equipment.icon,
      false,
      'stopped',
      0,
      v_should_test,  -- Only true if never completed
      NULL,
      NULL
    )
    ON CONFLICT (user_id, equipment_type_id) DO NOTHING;
    
    RAISE NOTICE 'Gave free CPU miner to user % (test_mode: %)', NEW.id, v_should_test;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Important: Existing users who haven't completed test mode keep it
-- Users who already used test mode lose it permanently
UPDATE user_mining_equipment
SET test_mode = false
WHERE test_mode = true
  AND mining_duration_seconds >= 60
  AND EXISTS (
    SELECT 1 
    FROM user_profiles 
    WHERE id = user_mining_equipment.user_id
    AND completed_test_mode = true
  );
