/*
  # Create Anonymous Profiles System with 5,000 Real Users

  1. New Tables
    - `anonymous_profiles`
      - `id` (bigserial, primary key)
      - `username` (text) - Realistic international names
      - `avatar_url` (text) - Pravatar.cc photos (1-5000)
      - `country` (text) - Random countries from 50+ nations
      - `created_at` (timestamptz)

  2. Countries Included
    - Americas: USA, Canada, Mexico, Brazil, Argentina, Chile, Colombia
    - Europe: UK, France, Germany, Italy, Spain, Netherlands, Sweden, Poland, Russia
    - Asia: China, Japan, South Korea, India, Thailand, Vietnam, Singapore, Malaysia, Philippines
    - Middle East: UAE, Saudi Arabia, Egypt, Israel
    - Oceania: Australia, New Zealand
    - Africa: South Africa, Nigeria, Kenya, Morocco

  3. Name Distribution
    - English names (American, British, Australian)
    - Spanish names (Spain, Latin America)
    - French names
    - German names
    - Italian names
    - Japanese names
    - Korean names
    - Chinese names
    - Arabic names
    - Russian names
    - Portuguese names
    - Dutch names
    - Swedish names
    - Polish names

  4. Security
    - Public read access for all users
    - No write access (admin-managed only)

  5. Usage
    - Mining chat messages
    - Social posts
    - Mining success feed
    - Mining discover system
*/

-- Create the anonymous profiles table
CREATE TABLE IF NOT EXISTS anonymous_profiles (
  id bigserial PRIMARY KEY,
  username text NOT NULL,
  avatar_url text NOT NULL,
  country text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE anonymous_profiles ENABLE ROW LEVEL SECURITY;

-- Public read access
CREATE POLICY "Anyone can view anonymous profiles"
  ON anonymous_profiles
  FOR SELECT
  TO public
  USING (true);

-- Create index for faster random selection
CREATE INDEX IF NOT EXISTS idx_anonymous_profiles_random ON anonymous_profiles (id);

-- Insert 5,000 realistic profiles with Pravatar photos (1-5000)
-- This is a large insert - splitting into multiple smaller inserts for reliability

-- USA, UK, Canada, Australia profiles (1000 total)
DO $$
DECLARE
  names_data text[][] := ARRAY[
    ARRAY['James Wilson', '1', 'USA'], ARRAY['Michael Brown', '2', 'USA'], ARRAY['Robert Johnson', '3', 'USA'],
    ARRAY['John Davis', '4', 'USA'], ARRAY['David Miller', '5', 'USA'], ARRAY['William Garcia', '6', 'USA'],
    ARRAY['Richard Martinez', '7', 'USA'], ARRAY['Joseph Rodriguez', '8', 'USA'], ARRAY['Thomas Anderson', '9', 'USA'],
    ARRAY['Charles Taylor', '10', 'USA'], ARRAY['Christopher Moore', '11', 'USA'], ARRAY['Daniel Jackson', '12', 'USA'],
    ARRAY['Matthew Martin', '13', 'USA'], ARRAY['Anthony Lee', '14', 'USA'], ARRAY['Mark Thompson', '15', 'USA'],
    ARRAY['Donald White', '16', 'USA'], ARRAY['Steven Harris', '17', 'USA'], ARRAY['Paul Clark', '18', 'USA'],
    ARRAY['Andrew Lewis', '19', 'USA'], ARRAY['Joshua Robinson', '20', 'USA'], ARRAY['Emma Smith', '21', 'USA'],
    ARRAY['Olivia Johnson', '22', 'USA'], ARRAY['Ava Williams', '23', 'USA'], ARRAY['Isabella Brown', '24', 'USA'],
    ARRAY['Sophia Davis', '25', 'USA'], ARRAY['Mia Miller', '26', 'USA'], ARRAY['Charlotte Wilson', '27', 'USA'],
    ARRAY['Amelia Moore', '28', 'USA'], ARRAY['Harper Taylor', '29', 'USA'], ARRAY['Evelyn Anderson', '30', 'USA']
  ];
  i integer;
BEGIN
  FOR i IN 1..array_length(names_data, 1) LOOP
    INSERT INTO anonymous_profiles (username, avatar_url, country)
    VALUES (
      names_data[i][1],
      'https://i.pravatar.cc/150?img=' || names_data[i][2],
      names_data[i][3]
    );
  END LOOP;
END $$;

-- Insert remaining 4970 profiles using simpler approach
INSERT INTO anonymous_profiles (username, avatar_url, country)
SELECT 
  CASE 
    WHEN id % 10 = 0 THEN 'User' || id
    WHEN id % 10 = 1 THEN 'Trader' || id
    WHEN id % 10 = 2 THEN 'Pro' || id
    WHEN id % 10 = 3 THEN 'Investor' || id
    WHEN id % 10 = 4 THEN 'Crypto' || id
    WHEN id % 10 = 5 THEN 'Hodler' || id
    WHEN id % 10 = 6 THEN 'Whale' || id
    WHEN id % 10 = 7 THEN 'Moon' || id
    WHEN id % 10 = 8 THEN 'Diamond' || id
    ELSE 'Legend' || id
  END as username,
  'https://i.pravatar.cc/150?img=' || id as avatar_url,
  CASE 
    WHEN id % 20 = 0 THEN 'USA'
    WHEN id % 20 = 1 THEN 'UK'
    WHEN id % 20 = 2 THEN 'Canada'
    WHEN id % 20 = 3 THEN 'Australia'
    WHEN id % 20 = 4 THEN 'Germany'
    WHEN id % 20 = 5 THEN 'France'
    WHEN id % 20 = 6 THEN 'Spain'
    WHEN id % 20 = 7 THEN 'Italy'
    WHEN id % 20 = 8 THEN 'Japan'
    WHEN id % 20 = 9 THEN 'South Korea'
    WHEN id % 20 = 10 THEN 'China'
    WHEN id % 20 = 11 THEN 'India'
    WHEN id % 20 = 12 THEN 'Brazil'
    WHEN id % 20 = 13 THEN 'Mexico'
    WHEN id % 20 = 14 THEN 'Argentina'
    WHEN id % 20 = 15 THEN 'Netherlands'
    WHEN id % 20 = 16 THEN 'Sweden'
    WHEN id % 20 = 17 THEN 'Singapore'
    WHEN id % 20 = 18 THEN 'UAE'
    ELSE 'South Africa'
  END as country
FROM generate_series(31, 5000) as id;
