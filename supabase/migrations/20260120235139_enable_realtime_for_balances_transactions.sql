/*
  # Enable Realtime for user_balances and transactions
  
  1. Changes
    - Enable realtime publication for user_balances table
    - Enable realtime publication for transactions table
    
  2. Purpose
    - Allow real-time updates when admin adds balance
    - User wallet updates immediately without page refresh
*/

-- Enable realtime for user_balances table
ALTER PUBLICATION supabase_realtime ADD TABLE user_balances;

-- Enable realtime for transactions table
ALTER PUBLICATION supabase_realtime ADD TABLE transactions;
