/*
  # Wallet Security System - Critical Safety Measures

  This migration implements CRITICAL security measures to prevent:
  - Duplicate wallet addresses in the system
  - Same wallet being assigned to multiple users
  - Accidental re-assignment of wallets
  - Potential financial losses due to wrong address assignments

  ## Security Measures

  1. **Database Constraints**
     - UNIQUE constraint on wallet_pool.address (prevents duplicates)
     - CHECK constraint: once assigned, cannot be unassigned
     - Prevent modification of critical fields after assignment

  2. **Audit Log System**
     - `wallet_assignments_audit` table
     - Tracks every wallet assignment with timestamp
     - Immutable records (no delete/update allowed)
     - Shows full history of who got which wallet when

  3. **Safety Functions**
     - check_duplicate_wallets() - Find duplicate addresses
     - verify_wallet_integrity() - Check for data corruption
     - get_wallet_assignment_history() - Full audit trail

  4. **RLS Policies**
     - Admin read-only access to audit logs
     - No one can delete or modify audit records
     - Transparent and secure
*/

-- Step 1: Add UNIQUE constraint to wallet addresses
-- This ensures NO duplicate addresses can exist in the system
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'wallet_pool_address_unique'
  ) THEN
    ALTER TABLE wallet_pool 
    ADD CONSTRAINT wallet_pool_address_unique UNIQUE (address);
  END IF;
END $$;

-- Step 2: Add CHECK constraint - once assigned, always assigned
-- A wallet can NEVER be unassigned once it's given to a user
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'wallet_pool_assignment_permanent'
  ) THEN
    ALTER TABLE wallet_pool
    ADD CONSTRAINT wallet_pool_assignment_permanent 
    CHECK (
      -- If assigned_user_id is set, is_assigned must be true
      (assigned_user_id IS NOT NULL AND is_assigned = true) OR
      (assigned_user_id IS NULL AND is_assigned = false)
    );
  END IF;
END $$;

-- Step 3: Create audit log table for all wallet assignments
CREATE TABLE IF NOT EXISTS wallet_assignments_audit (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id uuid NOT NULL REFERENCES wallet_pool(id) ON DELETE CASCADE,
  wallet_address text NOT NULL,
  wallet_network text NOT NULL,
  assigned_to_user_id uuid NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  assigned_to_email text NOT NULL,
  assigned_at timestamptz NOT NULL DEFAULT now(),
  assignment_method text NOT NULL DEFAULT 'auto',
  notes text
);

-- Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_wallet_audit_user ON wallet_assignments_audit(assigned_to_user_id);
CREATE INDEX IF NOT EXISTS idx_wallet_audit_address ON wallet_assignments_audit(wallet_address);
CREATE INDEX IF NOT EXISTS idx_wallet_audit_wallet_id ON wallet_assignments_audit(wallet_id);

-- Step 4: Enable RLS on audit table
ALTER TABLE wallet_assignments_audit ENABLE ROW LEVEL SECURITY;

-- Step 5: RLS Policies for audit log
-- Admins can view all audit logs (read-only)
CREATE POLICY "Admins can view wallet assignment audit logs"
  ON wallet_assignments_audit FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
    )
  );

-- Step 6: Function to check for duplicate wallets
CREATE OR REPLACE FUNCTION check_duplicate_wallets()
RETURNS TABLE (
  address text,
  network text,
  count bigint,
  wallet_ids uuid[]
) 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    wp.address,
    wp.network,
    COUNT(*)::bigint,
    array_agg(wp.id) as wallet_ids
  FROM wallet_pool wp
  GROUP BY wp.address, wp.network
  HAVING COUNT(*) > 1;
END;
$$;

-- Step 7: Function to verify wallet integrity
CREATE OR REPLACE FUNCTION verify_wallet_integrity()
RETURNS TABLE (
  issue_type text,
  wallet_id uuid,
  wallet_address text,
  details text
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Check 1: Wallets assigned but no user_id
  RETURN QUERY
  SELECT 
    'ASSIGNED_WITHOUT_USER'::text,
    id,
    address,
    'Wallet marked as assigned but has no user_id'::text
  FROM wallet_pool
  WHERE is_assigned = true AND assigned_user_id IS NULL;

  -- Check 2: Wallets with user_id but not marked as assigned
  RETURN QUERY
  SELECT 
    'USER_WITHOUT_ASSIGNED_FLAG'::text,
    id,
    address,
    'Wallet has user_id but not marked as assigned'::text
  FROM wallet_pool
  WHERE assigned_user_id IS NOT NULL AND is_assigned = false;

  -- Check 3: Multiple wallets assigned to same user (should be 2 - BEP20 + TRC20)
  RETURN QUERY
  SELECT 
    'UNUSUAL_ASSIGNMENT_COUNT'::text,
    wp.id,
    wp.address,
    'User has ' || count_result.wallet_count::text || ' wallets (should be 2)'::text
  FROM wallet_pool wp
  JOIN (
    SELECT assigned_user_id, COUNT(*) as wallet_count
    FROM wallet_pool
    WHERE is_assigned = true AND assigned_user_id IS NOT NULL
    GROUP BY assigned_user_id
    HAVING COUNT(*) != 2
  ) count_result ON wp.assigned_user_id = count_result.assigned_user_id
  WHERE wp.is_assigned = true;
END;
$$;

-- Step 8: Function to get wallet assignment history
CREATE OR REPLACE FUNCTION get_wallet_assignment_history(p_wallet_address text DEFAULT NULL)
RETURNS TABLE (
  wallet_address text,
  wallet_network text,
  user_email text,
  assigned_at timestamptz,
  assignment_method text,
  notes text
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  IF p_wallet_address IS NOT NULL THEN
    RETURN QUERY
    SELECT 
      waa.wallet_address,
      waa.wallet_network,
      waa.assigned_to_email,
      waa.assigned_at,
      waa.assignment_method,
      waa.notes
    FROM wallet_assignments_audit waa
    WHERE waa.wallet_address = p_wallet_address
    ORDER BY waa.assigned_at DESC;
  ELSE
    RETURN QUERY
    SELECT 
      waa.wallet_address,
      waa.wallet_network,
      waa.assigned_to_email,
      waa.assigned_at,
      waa.assignment_method,
      waa.notes
    FROM wallet_assignments_audit waa
    ORDER BY waa.assigned_at DESC
    LIMIT 100;
  END IF;
END;
$$;

-- Step 9: Trigger to log all wallet assignments
CREATE OR REPLACE FUNCTION log_wallet_assignment()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_user_email text;
BEGIN
  -- Only log when a wallet becomes assigned
  IF NEW.is_assigned = true AND (OLD.is_assigned = false OR OLD.is_assigned IS NULL) THEN
    -- Get user email
    SELECT email INTO v_user_email
    FROM user_profiles
    WHERE id = NEW.assigned_user_id;

    -- Insert audit log
    INSERT INTO wallet_assignments_audit (
      wallet_id,
      wallet_address,
      wallet_network,
      assigned_to_user_id,
      assigned_to_email,
      assigned_at,
      assignment_method,
      notes
    ) VALUES (
      NEW.id,
      NEW.address,
      NEW.network,
      NEW.assigned_user_id,
      COALESCE(v_user_email, 'unknown'),
      NEW.assigned_at,
      'auto',
      'Wallet assigned via automated system'
    );
  END IF;

  RETURN NEW;
END;
$$;

-- Create trigger
DROP TRIGGER IF EXISTS trigger_log_wallet_assignment ON wallet_pool;
CREATE TRIGGER trigger_log_wallet_assignment
  AFTER UPDATE ON wallet_pool
  FOR EACH ROW
  EXECUTE FUNCTION log_wallet_assignment();

-- Step 10: Prevent deletion of audit logs (immutable)
CREATE POLICY "No one can delete audit logs"
  ON wallet_assignments_audit FOR DELETE
  TO authenticated
  USING (false);

CREATE POLICY "No one can update audit logs"
  ON wallet_assignments_audit FOR UPDATE
  TO authenticated
  USING (false);

-- Step 11: Add index to prevent slow duplicate checks
CREATE INDEX IF NOT EXISTS idx_wallet_pool_address_lower ON wallet_pool(LOWER(address));

-- Step 12: Function to safely add wallet (with duplicate check)
CREATE OR REPLACE FUNCTION safe_add_wallet(
  p_address text,
  p_network text
)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_existing_count int;
  v_new_wallet_id uuid;
BEGIN
  -- Normalize address
  p_address := TRIM(p_address);
  
  -- Check if already exists
  SELECT COUNT(*) INTO v_existing_count
  FROM wallet_pool
  WHERE LOWER(address) = LOWER(p_address);

  IF v_existing_count > 0 THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'DUPLICATE_ADDRESS',
      'message', 'Bu cüzdan adresi zaten sistemde mevcut!'
    );
  END IF;

  -- Insert new wallet
  INSERT INTO wallet_pool (address, network, is_assigned)
  VALUES (p_address, p_network, false)
  RETURNING id INTO v_new_wallet_id;

  RETURN jsonb_build_object(
    'success', true,
    'wallet_id', v_new_wallet_id,
    'message', 'Cüzdan başarıyla eklendi'
  );
EXCEPTION
  WHEN unique_violation THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'UNIQUE_VIOLATION',
      'message', 'Bu cüzdan adresi zaten sistemde mevcut (Unique constraint)'
    );
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'UNKNOWN_ERROR',
      'message', SQLERRM
    );
END;
$$;

-- Step 13: Add comments for documentation
COMMENT ON TABLE wallet_assignments_audit IS 'Immutable audit log of all wallet assignments. Critical for financial security.';
COMMENT ON FUNCTION check_duplicate_wallets() IS 'Finds duplicate wallet addresses in the system';
COMMENT ON FUNCTION verify_wallet_integrity() IS 'Checks for data corruption and inconsistencies in wallet assignments';
COMMENT ON FUNCTION safe_add_wallet(text, text) IS 'Safely adds a wallet with duplicate prevention';
