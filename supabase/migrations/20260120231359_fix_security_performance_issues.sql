/*
  # Fix Security and Performance Issues
  
  1. Add Missing Indexes
    - Add indexes for all unindexed foreign keys:
      - admin_actions.target_user_id
      - trades.buy_order_id
      - trades.sell_order_id
      - transactions.admin_id
      - wallets.currency_id
  
  2. Optimize RLS Policies
    - Replace auth.uid() with (select auth.uid()) in all policies for better performance
    - This prevents re-evaluation of auth function for each row
  
  3. Remove Unused Indexes
    - Drop indexes that are not being used:
      - idx_transactions_created_at
      - idx_admin_actions_created_at
      - idx_orders_status
      - idx_orders_currency_id
      - idx_trades_currency_id
      - idx_trades_created_at
  
  4. Consolidate Multiple Permissive Policies
    - Merge duplicate SELECT policies into single policies with OR conditions
    - Affects: trades, transactions, user_balances, user_profiles
  
  5. Fix Function Search Paths
    - Set immutable search_path for all functions
*/

-- =====================================================
-- 1. ADD MISSING INDEXES FOR FOREIGN KEYS
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_admin_actions_target_user_id 
  ON admin_actions(target_user_id);

CREATE INDEX IF NOT EXISTS idx_trades_buy_order_id 
  ON trades(buy_order_id);

CREATE INDEX IF NOT EXISTS idx_trades_sell_order_id 
  ON trades(sell_order_id);

CREATE INDEX IF NOT EXISTS idx_transactions_admin_id 
  ON transactions(admin_id);

CREATE INDEX IF NOT EXISTS idx_wallets_currency_id 
  ON wallets(currency_id);

-- =====================================================
-- 2. DROP UNUSED INDEXES
-- =====================================================

DROP INDEX IF EXISTS idx_transactions_created_at;
DROP INDEX IF EXISTS idx_admin_actions_created_at;
DROP INDEX IF EXISTS idx_orders_status;
DROP INDEX IF EXISTS idx_orders_currency_id;
DROP INDEX IF EXISTS idx_trades_currency_id;
DROP INDEX IF EXISTS idx_trades_created_at;

-- =====================================================
-- 3. FIX RLS POLICIES - Replace auth.uid() with (select auth.uid())
-- =====================================================

-- profiles table policies
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (id = (select auth.uid()));

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (id = (select auth.uid()))
  WITH CHECK (id = (select auth.uid()));

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (id = (select auth.uid()));

-- wallets table policies
DROP POLICY IF EXISTS "Users can view own wallets" ON wallets;
DROP POLICY IF EXISTS "Users can update own wallets" ON wallets;
DROP POLICY IF EXISTS "Users can insert own wallets" ON wallets;

CREATE POLICY "Users can view own wallets"
  ON wallets FOR SELECT
  TO authenticated
  USING (user_id = (select auth.uid()));

CREATE POLICY "Users can update own wallets"
  ON wallets FOR UPDATE
  TO authenticated
  USING (user_id = (select auth.uid()))
  WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Users can insert own wallets"
  ON wallets FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (select auth.uid()));

-- orders table policies
DROP POLICY IF EXISTS "Users can view own orders" ON orders;
DROP POLICY IF EXISTS "Users can insert own orders" ON orders;
DROP POLICY IF EXISTS "Users can update own orders" ON orders;

CREATE POLICY "Users can view own orders"
  ON orders FOR SELECT
  TO authenticated
  USING (user_id = (select auth.uid()));

CREATE POLICY "Users can insert own orders"
  ON orders FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Users can update own orders"
  ON orders FOR UPDATE
  TO authenticated
  USING (user_id = (select auth.uid()))
  WITH CHECK (user_id = (select auth.uid()));

-- =====================================================
-- 4. CONSOLIDATE MULTIPLE PERMISSIVE POLICIES
-- =====================================================

-- trades table - merge duplicate SELECT policies
DROP POLICY IF EXISTS "Users can view own trades" ON trades;
DROP POLICY IF EXISTS "Authenticated users can view all trades" ON trades;

CREATE POLICY "Users can view trades"
  ON trades FOR SELECT
  TO authenticated
  USING (
    buyer_id = (select auth.uid()) OR 
    seller_id = (select auth.uid()) OR
    true
  );

-- user_profiles table - merge duplicate SELECT policies
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON user_profiles;

CREATE POLICY "Users can view profiles"
  ON user_profiles FOR SELECT
  TO authenticated
  USING (
    id = (select auth.uid()) OR
    EXISTS (
      SELECT 1 FROM user_profiles up
      WHERE up.id = (select auth.uid()) AND up.is_admin = true
    )
  );

-- Admins can update profiles
DROP POLICY IF EXISTS "Admins can update profiles" ON user_profiles;

CREATE POLICY "Admins can update profiles"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles up
      WHERE up.id = (select auth.uid()) AND up.is_admin = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles up
      WHERE up.id = (select auth.uid()) AND up.is_admin = true
    )
  );

-- user_balances table - merge duplicate SELECT policies
DROP POLICY IF EXISTS "Users can view own balances" ON user_balances;
DROP POLICY IF EXISTS "Admins can view all balances" ON user_balances;

CREATE POLICY "Users can view balances"
  ON user_balances FOR SELECT
  TO authenticated
  USING (
    user_id = (select auth.uid()) OR
    EXISTS (
      SELECT 1 FROM user_profiles up
      WHERE up.id = (select auth.uid()) AND up.is_admin = true
    )
  );

-- Admins can insert balances
DROP POLICY IF EXISTS "Admins can insert balances" ON user_balances;

CREATE POLICY "Admins can insert balances"
  ON user_balances FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles up
      WHERE up.id = (select auth.uid()) AND up.is_admin = true
    )
  );

-- Admins can update balances
DROP POLICY IF EXISTS "Admins can update balances" ON user_balances;

CREATE POLICY "Admins can update balances"
  ON user_balances FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles up
      WHERE up.id = (select auth.uid()) AND up.is_admin = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles up
      WHERE up.id = (select auth.uid()) AND up.is_admin = true
    )
  );

-- transactions table - merge duplicate SELECT policies
DROP POLICY IF EXISTS "Users can view own transactions" ON transactions;
DROP POLICY IF EXISTS "Admins can view all transactions" ON transactions;

CREATE POLICY "Users can view transactions"
  ON transactions FOR SELECT
  TO authenticated
  USING (
    user_id = (select auth.uid()) OR
    EXISTS (
      SELECT 1 FROM user_profiles up
      WHERE up.id = (select auth.uid()) AND up.is_admin = true
    )
  );

-- Admins can insert transactions
DROP POLICY IF EXISTS "Admins can insert transactions" ON transactions;

CREATE POLICY "Admins can insert transactions"
  ON transactions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles up
      WHERE up.id = (select auth.uid()) AND up.is_admin = true
    )
  );

-- admin_actions table policies
DROP POLICY IF EXISTS "Admins can view all actions" ON admin_actions;
DROP POLICY IF EXISTS "Admins can insert actions" ON admin_actions;

CREATE POLICY "Admins can view all actions"
  ON admin_actions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles up
      WHERE up.id = (select auth.uid()) AND up.is_admin = true
    )
  );

CREATE POLICY "Admins can insert actions"
  ON admin_actions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles up
      WHERE up.id = (select auth.uid()) AND up.is_admin = true
    )
  );

-- =====================================================
-- 5. FIX FUNCTION SEARCH PATHS
-- =====================================================

-- Fix create_initial_usdt_balance function
CREATE OR REPLACE FUNCTION create_initial_usdt_balance()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  INSERT INTO user_balances (user_id, symbol, balance, locked_balance)
  VALUES (NEW.id, 'USDT', 0.00, 0.00)
  ON CONFLICT (user_id, symbol) DO NOTHING;
  
  RETURN NEW;
END;
$$;

-- Fix handle_new_user function
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  INSERT INTO user_profiles (id, email)
  VALUES (NEW.id, NEW.email)
  ON CONFLICT (id) DO NOTHING;
  
  RETURN NEW;
END;
$$;

-- Fix handle_updated_at function
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER 
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;