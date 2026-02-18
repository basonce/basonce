/*
  # Add coin symbols to live rooms and assign different coins to each room

  1. Changes
    - Add `coin_symbol` column to `live_rooms` table
    - Add `coin_logo` column to `live_rooms` table
    - Update all existing rooms with different coins (BTC, ETH, SOL, EQ, BNB, XRP, ADA, DOGE, DOT, MATIC)
    - Ensure EQ coin is included with proper logo

  2. Notes
    - Each room will have a unique coin
    - Uses real coin logos from supported_coins table
    - EQ (EarnQuest) coin is included
*/

-- Add coin columns to live_rooms
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'live_rooms' AND column_name = 'coin_symbol'
  ) THEN
    ALTER TABLE live_rooms ADD COLUMN coin_symbol text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'live_rooms' AND column_name = 'coin_logo'
  ) THEN
    ALTER TABLE live_rooms ADD COLUMN coin_logo text;
  END IF;
END $$;

-- Update rooms with different coins
WITH room_coins AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (ORDER BY id) as rn
  FROM live_rooms
),
coin_list AS (
  SELECT symbol, logo_url, ROW_NUMBER() OVER (ORDER BY 
    CASE 
      WHEN symbol = 'BTC' THEN 1
      WHEN symbol = 'ETH' THEN 2
      WHEN symbol = 'SOL' THEN 3
      WHEN symbol = 'EQ' THEN 4
      WHEN symbol = 'BNB' THEN 5
      WHEN symbol = 'XRP' THEN 6
      WHEN symbol = 'ADA' THEN 7
      WHEN symbol = 'DOGE' THEN 8
      WHEN symbol = 'DOT' THEN 9
      WHEN symbol = 'MATIC' THEN 10
      ELSE 99
    END
  ) as cn
  FROM supported_coins
  WHERE symbol IN ('BTC', 'ETH', 'SOL', 'EQ', 'BNB', 'XRP', 'ADA', 'DOGE', 'DOT', 'MATIC')
  LIMIT 10
)
UPDATE live_rooms
SET 
  coin_symbol = coin_list.symbol,
  coin_logo = coin_list.logo_url
FROM room_coins
CROSS JOIN LATERAL (
  SELECT symbol, logo_url 
  FROM coin_list 
  WHERE cn = ((room_coins.rn - 1) % 10) + 1
  LIMIT 1
) coin_list
WHERE live_rooms.id = room_coins.id;