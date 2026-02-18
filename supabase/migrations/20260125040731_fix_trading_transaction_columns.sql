/*
  # Fix Trading System Transaction Columns

  ## Changes
  - Make balance_before and balance_after nullable in transactions table
  - These fields are not always needed for trading transactions
  
  ## Why
  - Trading transactions track buy/sell operations
  - Balance changes are managed in user_balances table
  - These columns should be optional for trading records
*/

-- Make balance columns nullable
ALTER TABLE transactions 
ALTER COLUMN balance_before DROP NOT NULL,
ALTER COLUMN balance_after DROP NOT NULL;

-- Add index for better performance
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_symbol ON transactions(symbol);
