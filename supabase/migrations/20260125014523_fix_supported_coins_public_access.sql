/*
  # Fix Public Access to Supported Coins

  This migration fixes the RLS policy for supported_coins table to allow
  BOTH anonymous (anon) and authenticated users to view coins.

  ## Changes
  - Drop existing SELECT policy that only allows authenticated users
  - Create new SELECT policy that allows BOTH anon and authenticated users
  - This ensures coin list is visible even before login

  ## Security
  - Only SELECT (read) permission is granted
  - Only active coins are visible (is_active = true)
  - Write operations still require admin privileges
*/

-- Drop the existing restrictive policy
DROP POLICY IF EXISTS "Anyone can view active coins" ON supported_coins;

-- Create new policy that allows both anon and authenticated users
CREATE POLICY "Public can view active coins"
  ON supported_coins
  FOR SELECT
  TO anon, authenticated
  USING (is_active = true);