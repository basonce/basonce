/*
  # Update Mining Discover to Use Anonymous Profiles

  1. Changes
    - Add profile_id column to mining_discover_users
    - Update existing records to use random profiles
    - Recreate discovery users with anonymous profiles

  2. Security
    - Maintain existing RLS policies
    - Add foreign key constraints
*/

-- Add profile_id to mining_discover_users
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'mining_discover_users' AND column_name = 'profile_id'
  ) THEN
    ALTER TABLE mining_discover_users 
    ADD COLUMN profile_id bigint REFERENCES anonymous_profiles(id);
  END IF;
END $$;

-- Update existing mining_discover_users with random profiles
UPDATE mining_discover_users
SET profile_id = (
  SELECT id FROM anonymous_profiles
  ORDER BY random()
  LIMIT 1
)
WHERE profile_id IS NULL;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_mining_discover_users_profile_id ON mining_discover_users(profile_id);

-- Delete old mining_discover_users and recreate with profiles
DELETE FROM mining_discover_users;

-- Insert 500 realistic mining users with anonymous profiles
INSERT INTO mining_discover_users (
  profile_id,
  user_id,
  username,
  avatar_url,
  country,
  total_earned,
  total_withdrawn,
  mining_power,
  last_active,
  created_at
)
SELECT 
  ap.id,
  'U#' || LPAD((row_number() OVER ())::text, 6, '0'),
  ap.username,
  ap.avatar_url,
  ap.country,
  (random() * 50000 + 1000)::numeric(10,2),
  (random() * 30000 + 500)::numeric(10,2),
  (random() * 500 + 10)::numeric(10,2),
  now() - (random() * interval '7 days'),
  now() - (random() * interval '60 days')
FROM 
  anonymous_profiles ap
WHERE 
  ap.id <= 500
ORDER BY 
  random();
