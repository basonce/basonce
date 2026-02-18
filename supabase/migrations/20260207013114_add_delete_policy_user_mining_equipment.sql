/*
  # Add DELETE Policy for User Mining Equipment
  
  1. Changes
    - Add DELETE policy for user_mining_equipment
    - Users can delete their own mining equipment
*/

-- Add delete policy for user_mining_equipment
CREATE POLICY "Users can delete own mining equipment"
  ON user_mining_equipment
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);
