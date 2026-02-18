/*
  # Remove Test Mode - Switch to Production

  1. Changes
    - Set all test_mode to false (production mode)
    - Remove test mode from new user flow
    - All mining now uses real durations
    - CPU Miner: 3 hours normal speed
    
  2. Why
    - System is ready for production
    - Test mode was only for development
    - Real earnings, real timers
    - Clean user experience
*/

-- Disable test mode for ALL existing equipment
UPDATE user_mining_equipment
SET test_mode = false
WHERE test_mode = true;

-- Update trigger to NEVER give test mode
CREATE OR REPLACE FUNCTION give_free_cpu_miner()
RETURNS TRIGGER AS $$
DECLARE
  v_free_equipment record;
BEGIN
  -- Get FREE CPU Miner
  SELECT * INTO v_free_equipment
  FROM mining_equipment_types
  WHERE is_free = true
  LIMIT 1;

  IF v_free_equipment.id IS NOT NULL THEN
    -- Give it to the new user (NO TEST MODE)
    INSERT INTO user_mining_equipment (
      user_id,
      equipment_type_id,
      icon,
      is_active,
      status,
      mining_duration_seconds,
      test_mode,  -- ALWAYS FALSE NOW
      started_at,
      ends_at
    ) VALUES (
      NEW.id,
      v_free_equipment.id,
      v_free_equipment.icon,
      false,
      'stopped',
      0,
      false,  -- ✅ PRODUCTION MODE
      NULL,
      NULL
    )
    ON CONFLICT (user_id, equipment_type_id) DO NOTHING;
    
    RAISE NOTICE 'Gave free CPU miner to user % (PRODUCTION MODE)', NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Optional: Remove completed_test_mode tracking (no longer needed)
-- We keep the column for historical data, but don't use it anymore
