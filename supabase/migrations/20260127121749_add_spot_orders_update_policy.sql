/*
  # Add Update Policy for Spot Orders

  ## Changes
  - Add RLS policy allowing users to update their own spot orders
  - This enables order cancellation functionality
*/

-- Add update policy for spot_orders
CREATE POLICY "Users can update own orders"
  ON spot_orders FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
