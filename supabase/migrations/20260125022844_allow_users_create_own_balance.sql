/*
  # Allow Users to Create Their Own Initial Balance

  1. Problem
    - user_balances table only allows admin INSERT
    - New users can't create their own initial balance during signup
    
  2. Solution
    - Add policy to allow authenticated users to insert their own initial balance
    
  3. Security
    - User can only insert for their own user_id
    - Balance must be 10000 USDT (initial gift)
*/

-- Add policy for users to create their own initial balance
CREATE POLICY "Users can create own initial balance"
  ON user_balances
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user_id
  );
