/*
  # Fix Public Access to Supported Networks

  This migration ensures networks are also accessible to anonymous users.

  ## Changes
  - Drop existing restrictive SELECT policy
  - Create new policy allowing both anon and authenticated users
  
  ## Security
  - Only SELECT permission granted
  - Only active networks visible
*/

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Anyone can view active networks" ON supported_networks;

-- Create new public access policy
CREATE POLICY "Public can view active networks"
  ON supported_networks
  FOR SELECT
  TO anon, authenticated
  USING (is_active = true);