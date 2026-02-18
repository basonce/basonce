/*
  # Update Anonymous Profiles with 270 Unique Real Human Photos

  1. Changes
    - Delete all existing anonymous profiles
    - Recreate 5,000 profiles with 270 unique real photos
    
  2. Photo Sources (270 unique photos)
    - Pravatar.cc: 70 photos (img 1-70)
    - RandomUser.me Men: 100 photos (0-99)
    - RandomUser.me Women: 100 photos (0-99)
    - Total: 270 unique photos cycling across 5,000 profiles
    
  3. Distribution
    - Each of 270 photos appears ~18-19 times across 5,000 profiles
    - Photos distributed evenly to maximize diversity
*/

-- Clear existing profiles
TRUNCATE TABLE anonymous_profiles RESTART IDENTITY CASCADE;

-- Insert 5,000 profiles with 270 unique real human photos
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

  -- Avatar URL: 270 unique photos cycling (photo_id from 0-269)
  CASE
    -- 0-69: Pravatar (70 photos)
    WHEN ((id - 1) % 270) BETWEEN 0 AND 69 THEN
      'https://i.pravatar.cc/150?img=' || (((id - 1) % 270) + 1)::text

    -- 70-169: RandomUser Men (100 photos: 0-99)
    WHEN ((id - 1) % 270) BETWEEN 70 AND 169 THEN
      'https://randomuser.me/api/portraits/men/' || (((id - 1) % 270) - 70)::text || '.jpg'

    -- 170-269: RandomUser Women (100 photos: 0-99)
    ELSE
      'https://randomuser.me/api/portraits/women/' || (((id - 1) % 270) - 170)::text || '.jpg'
  END as avatar_url,

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
FROM generate_series(1, 5000) as id;
