/*
  # Fix Transactions Type Constraint Safely

  ## Changes
  - Drop old constraint
  - Add comprehensive constraint that covers all existing and new types
  
  ## Allowed Types
  - deposit, withdrawal (existing)
  - trade, admin_credit, admin_debit (existing)
  - admin_add, admin_deduct (existing variants)
  - buy, sell (NEW - for spot trading)
*/

-- Drop old constraint
ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_type_check;

-- Add comprehensive constraint
ALTER TABLE transactions ADD CONSTRAINT transactions_type_check 
CHECK (type IN (
  'deposit', 
  'withdrawal', 
  'trade',
  'admin_credit', 
  'admin_debit',
  'admin_add',
  'admin_deduct',
  'buy', 
  'sell'
));
