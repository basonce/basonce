/*
  # Time Wallet Mining System

  ## Overview
  Implement a time-based mining system where each miner has a time wallet:
  - Free miners have limited time (e.g., 180 minutes)
  - Time is tracked accurately (no reset on pause/resume)
  - When time runs out, user sees upgrade options
  - Premium miners have unlimited time

  ## Changes
  1. Remove `is_locked` column (no longer needed)
  2. Add `has_time_limit` boolean to equipment types
  3. Rename `mining_duration_seconds` to `used_mining_seconds` for clarity
  4. Add calculated remaining time logic

  ## Time Wallet Logic
  - max_time = mining_duration_hours * 3600
  - used_time = used_mining_seconds
  - remaining_time = max_time - used_time
  - When remaining_time <= 0, mining stops and upgrade screen shows

  ## Security
  - RLS policies remain unchanged
  - Time tracking is server-authoritative
*/

-- 1. Remove is_locked column (no longer needed)
ALTER TABLE user_mining_equipment
DROP COLUMN IF EXISTS is_locked;

-- 2. Rename mining_duration_seconds to used_mining_seconds for clarity
ALTER TABLE user_mining_equipment
RENAME COLUMN mining_duration_seconds TO used_mining_seconds;

-- 3. Add has_time_limit to equipment types (default true for free, false for premium)
ALTER TABLE mining_equipment_types
ADD COLUMN IF NOT EXISTS has_time_limit boolean DEFAULT true;

-- 4. Set unlimited time for premium equipment (price > 0)
UPDATE mining_equipment_types
SET has_time_limit = false
WHERE price > 0;

-- 5. Set time limit for free equipment
UPDATE mining_equipment_types
SET has_time_limit = true
WHERE is_free = true OR price = 0;

-- 6. Create helper function to calculate remaining time
CREATE OR REPLACE FUNCTION get_remaining_mining_seconds(
  p_mining_duration_hours integer,
  p_used_mining_seconds integer,
  p_has_time_limit boolean
)
RETURNS integer
LANGUAGE plpgsql
AS $$
BEGIN
  -- Unlimited miners have no time limit
  IF NOT p_has_time_limit THEN
    RETURN 999999;
  END IF;
  
  -- Calculate remaining time
  RETURN (p_mining_duration_hours * 3600) - p_used_mining_seconds;
END;
$$;

-- 7. Create view for mining status with time wallet
CREATE OR REPLACE VIEW user_mining_status AS
SELECT 
  ume.*,
  met.has_time_limit,
  met.mining_duration_hours,
  (met.mining_duration_hours * 3600) as max_mining_seconds,
  CASE 
    WHEN met.has_time_limit THEN 
      (met.mining_duration_hours * 3600) - ume.used_mining_seconds
    ELSE 
      999999
  END as remaining_mining_seconds,
  CASE 
    WHEN met.has_time_limit THEN 
      ROUND((ume.used_mining_seconds::numeric / (met.mining_duration_hours * 3600)::numeric * 100), 2)
    ELSE 
      0
  END as usage_percentage
FROM user_mining_equipment ume
JOIN mining_equipment_types met ON ume.equipment_type_id = met.id
WHERE ume.is_active = true;

-- 8. Grant access to view
GRANT SELECT ON user_mining_status TO authenticated;

-- 9. Add comment for clarity
COMMENT ON VIEW user_mining_status IS 'Shows mining equipment with time wallet calculations';
