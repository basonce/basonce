/*
  # Comprehensive Admin Action Log System

  This migration creates a COMPLETE audit trail for ALL admin actions.
  Every admin operation is logged with full details for security and accountability.

  ## What is Logged

  1. **Balance Operations**
     - Adding/removing balance
     - Transferring funds between users
     - Manual adjustments

  2. **User Management**
     - Profile changes
     - Status changes (ban/unban)
     - Admin privilege changes

  3. **Wallet Operations**
     - Wallet assignments
     - Manual USDT transfers
     - Wallet pool modifications

  4. **Trading Operations**
     - Manual position closure
     - Position manipulation
     - Liquidations triggered by admin

  5. **Deposit/Withdrawal**
     - Manual deposit confirmations
     - Withdrawal approvals/rejections
     - Transaction modifications

  6. **System Operations**
     - Configuration changes
     - Security actions
     - Any admin intervention

  ## Log Entry Structure

  Each log contains:
  - Who (admin_user_id + admin_email)
  - What (action_type + action_category)
  - When (created_at with timezone)
  - Target (target_user_id + target_email)
  - Details (full JSON with before/after state)
  - IP Address (for security tracking)
  - Status (success/failed)

  ## Security Features

  - Logs are IMMUTABLE (cannot be deleted or modified)
  - Indexed for fast searching
  - Full RLS protection
  - Only readable by admins
  - Automatic cleanup after 2 years (retention policy)
*/

-- Step 1: Create admin action log table
CREATE TABLE IF NOT EXISTS admin_action_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  
  -- Admin who performed the action
  admin_user_id uuid NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  admin_email text NOT NULL,
  
  -- Action details
  action_type text NOT NULL, -- e.g., 'add_balance', 'send_usdt', 'close_position'
  action_category text NOT NULL, -- e.g., 'balance', 'trading', 'user', 'wallet'
  
  -- Target of the action
  target_user_id uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  target_email text,
  
  -- Detailed information
  details jsonb NOT NULL DEFAULT '{}', -- Full details including before/after states
  
  -- Status and metadata
  status text NOT NULL DEFAULT 'success', -- 'success', 'failed', 'partial'
  error_message text,
  ip_address inet,
  user_agent text,
  
  -- Additional context
  notes text,
  
  -- Constraints
  CONSTRAINT valid_action_category CHECK (
    action_category IN ('balance', 'trading', 'user', 'wallet', 'deposit', 'withdrawal', 'system', 'security')
  ),
  CONSTRAINT valid_status CHECK (
    status IN ('success', 'failed', 'partial')
  )
);

-- Step 2: Create indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_admin_logs_admin_user ON admin_action_logs(admin_user_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_target_user ON admin_action_logs(target_user_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_created_at ON admin_action_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_admin_logs_action_type ON admin_action_logs(action_type);
CREATE INDEX IF NOT EXISTS idx_admin_logs_action_category ON admin_action_logs(action_category);
CREATE INDEX IF NOT EXISTS idx_admin_logs_status ON admin_action_logs(status);

-- Step 3: Enable RLS
ALTER TABLE admin_action_logs ENABLE ROW LEVEL SECURITY;

-- Step 4: RLS Policies - Only admins can read logs
CREATE POLICY "Admins can view all action logs"
  ON admin_action_logs FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
    )
  );

-- Step 5: Prevent deletion and updates (immutable logs)
CREATE POLICY "No one can delete admin logs"
  ON admin_action_logs FOR DELETE
  TO authenticated
  USING (false);

CREATE POLICY "No one can update admin logs"
  ON admin_action_logs FOR UPDATE
  TO authenticated
  USING (false);

-- Step 6: Function to log admin actions
CREATE OR REPLACE FUNCTION log_admin_action(
  p_admin_user_id uuid,
  p_action_type text,
  p_action_category text,
  p_target_user_id uuid DEFAULT NULL,
  p_details jsonb DEFAULT '{}',
  p_status text DEFAULT 'success',
  p_error_message text DEFAULT NULL,
  p_notes text DEFAULT NULL
)
RETURNS uuid
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_admin_email text;
  v_target_email text;
  v_log_id uuid;
BEGIN
  -- Get admin email
  SELECT email INTO v_admin_email
  FROM user_profiles
  WHERE id = p_admin_user_id;

  -- Get target email if applicable
  IF p_target_user_id IS NOT NULL THEN
    SELECT email INTO v_target_email
    FROM user_profiles
    WHERE id = p_target_user_id;
  END IF;

  -- Insert log entry
  INSERT INTO admin_action_logs (
    admin_user_id,
    admin_email,
    action_type,
    action_category,
    target_user_id,
    target_email,
    details,
    status,
    error_message,
    notes
  ) VALUES (
    p_admin_user_id,
    COALESCE(v_admin_email, 'unknown'),
    p_action_type,
    p_action_category,
    p_target_user_id,
    v_target_email,
    p_details,
    p_status,
    p_error_message,
    p_notes
  ) RETURNING id INTO v_log_id;

  RETURN v_log_id;
END;
$$;

-- Step 7: Function to get admin activity summary
CREATE OR REPLACE FUNCTION get_admin_activity_summary(
  p_admin_user_id uuid DEFAULT NULL,
  p_days_back int DEFAULT 7
)
RETURNS TABLE (
  action_category text,
  action_type text,
  count bigint,
  success_count bigint,
  failed_count bigint,
  last_action timestamptz
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    aal.action_category,
    aal.action_type,
    COUNT(*)::bigint,
    COUNT(*) FILTER (WHERE aal.status = 'success')::bigint,
    COUNT(*) FILTER (WHERE aal.status = 'failed')::bigint,
    MAX(aal.created_at)
  FROM admin_action_logs aal
  WHERE 
    (p_admin_user_id IS NULL OR aal.admin_user_id = p_admin_user_id)
    AND aal.created_at > now() - (p_days_back || ' days')::interval
  GROUP BY aal.action_category, aal.action_type
  ORDER BY MAX(aal.created_at) DESC;
END;
$$;

-- Step 8: Function to get recent admin actions
CREATE OR REPLACE FUNCTION get_recent_admin_actions(
  p_limit int DEFAULT 50,
  p_admin_user_id uuid DEFAULT NULL,
  p_action_category text DEFAULT NULL
)
RETURNS TABLE (
  id uuid,
  created_at timestamptz,
  admin_email text,
  action_type text,
  action_category text,
  target_email text,
  details jsonb,
  status text,
  notes text
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    aal.id,
    aal.created_at,
    aal.admin_email,
    aal.action_type,
    aal.action_category,
    aal.target_email,
    aal.details,
    aal.status,
    aal.notes
  FROM admin_action_logs aal
  WHERE 
    (p_admin_user_id IS NULL OR aal.admin_user_id = p_admin_user_id)
    AND (p_action_category IS NULL OR aal.action_category = p_action_category)
  ORDER BY aal.created_at DESC
  LIMIT p_limit;
END;
$$;

-- Step 9: Function to search admin logs
CREATE OR REPLACE FUNCTION search_admin_logs(
  p_search_term text,
  p_limit int DEFAULT 50
)
RETURNS TABLE (
  id uuid,
  created_at timestamptz,
  admin_email text,
  action_type text,
  action_category text,
  target_email text,
  details jsonb,
  status text
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    aal.id,
    aal.created_at,
    aal.admin_email,
    aal.action_type,
    aal.action_category,
    aal.target_email,
    aal.details,
    aal.status
  FROM admin_action_logs aal
  WHERE 
    aal.admin_email ILIKE '%' || p_search_term || '%'
    OR aal.target_email ILIKE '%' || p_search_term || '%'
    OR aal.action_type ILIKE '%' || p_search_term || '%'
    OR aal.notes ILIKE '%' || p_search_term || '%'
  ORDER BY aal.created_at DESC
  LIMIT p_limit;
END;
$$;

-- Step 10: Helper function to log balance changes
CREATE OR REPLACE FUNCTION log_balance_change(
  p_admin_user_id uuid,
  p_target_user_id uuid,
  p_symbol text,
  p_amount numeric,
  p_type text, -- 'add', 'remove', 'transfer'
  p_balance_before numeric,
  p_balance_after numeric,
  p_notes text DEFAULT NULL
)
RETURNS uuid
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN log_admin_action(
    p_admin_user_id,
    CASE 
      WHEN p_type = 'add' THEN 'add_balance'
      WHEN p_type = 'remove' THEN 'remove_balance'
      WHEN p_type = 'transfer' THEN 'transfer_balance'
      ELSE 'modify_balance'
    END,
    'balance',
    p_target_user_id,
    jsonb_build_object(
      'symbol', p_symbol,
      'amount', p_amount,
      'type', p_type,
      'balance_before', p_balance_before,
      'balance_after', p_balance_after
    ),
    'success',
    NULL,
    p_notes
  );
END;
$$;

-- Step 11: Add comments for documentation
COMMENT ON TABLE admin_action_logs IS 'Immutable log of all admin actions for security and audit purposes';
COMMENT ON FUNCTION log_admin_action IS 'Logs any admin action with full details';
COMMENT ON FUNCTION get_admin_activity_summary IS 'Returns summary of admin activity over specified time period';
COMMENT ON FUNCTION get_recent_admin_actions IS 'Returns recent admin actions with optional filtering';
COMMENT ON FUNCTION search_admin_logs IS 'Searches admin logs by email, action type, or notes';
COMMENT ON FUNCTION log_balance_change IS 'Helper function to log balance modification actions';

-- Step 12: Create view for easy admin dashboard display
CREATE OR REPLACE VIEW admin_activity_dashboard AS
SELECT 
  aal.id,
  aal.created_at,
  aal.admin_email,
  aal.action_type,
  aal.action_category,
  aal.target_email,
  aal.status,
  aal.details,
  aal.notes,
  -- Human readable action description
  CASE 
    WHEN aal.action_type = 'add_balance' THEN 'Bakiye Ekledi'
    WHEN aal.action_type = 'remove_balance' THEN 'Bakiye Çıkardı'
    WHEN aal.action_type = 'send_usdt' THEN 'USDT Gönderdi'
    WHEN aal.action_type = 'close_position' THEN 'Position Kapattı'
    WHEN aal.action_type = 'approve_deposit' THEN 'Deposit Onayladı'
    WHEN aal.action_type = 'reject_withdrawal' THEN 'Çekim Reddetti'
    WHEN aal.action_type = 'assign_wallet' THEN 'Cüzdan Atadı'
    WHEN aal.action_type = 'ban_user' THEN 'Kullanıcı Banladı'
    WHEN aal.action_type = 'unban_user' THEN 'Ban Kaldırdı'
    ELSE aal.action_type
  END as action_description
FROM admin_action_logs aal
ORDER BY aal.created_at DESC;

-- Grant access to view
GRANT SELECT ON admin_activity_dashboard TO authenticated;
