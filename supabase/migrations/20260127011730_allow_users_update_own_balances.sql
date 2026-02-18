/*
  # Allow Users to Update Their Own Balances
  
  1. Security
    - Add RLS policy for authenticated users to update their own balance and futures_balance
    - Users can only update their own balances (user_id must match auth.uid())
    - This enables transfer functionality between spot and futures wallets
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'user_balances' 
    AND policyname = 'Users can update own balances'
  ) THEN
    CREATE POLICY "Users can update own balances"
      ON user_balances
      FOR UPDATE
      TO authenticated
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;
