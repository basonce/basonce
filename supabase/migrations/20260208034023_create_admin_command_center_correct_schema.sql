/*
  # Admin Command Center - Complete Mobile Control System
  
  Bu sistem admin'in telefondan platformu tamamen yönetmesini sağlar.
  
  ## Özellikler:
  - Real-time platform statistics
  - Financial overview (liability, risk ratio)
  - VIP users & whale traders
  - Large withdrawal alerts
  - Large position alerts
  - Risk metrics
  - System health monitoring
  - Quick action functions
*/

-- ============================================================================
-- PLATFORM STATISTICS VIEW
-- ============================================================================

CREATE OR REPLACE VIEW admin_platform_stats AS
SELECT
  -- User stats
  (SELECT COUNT(*) FROM user_profiles) as total_users,
  (SELECT COUNT(*) FROM user_profiles WHERE created_at > now() - interval '24 hours') as users_today,
  (SELECT COUNT(DISTINCT user_id) FROM deposit_transactions WHERE created_at > now() - interval '24 hours') as active_users_24h,
  
  -- Balance stats
  (SELECT COALESCE(SUM(balance), 0) FROM user_balances WHERE symbol = 'USDT') as total_usdt_balances,
  (SELECT COALESCE(SUM(futures_balance), 0) FROM user_balances WHERE symbol = 'USDT') as total_futures_balances,
  
  -- Transaction stats
  (SELECT COALESCE(SUM(amount), 0) FROM deposit_transactions WHERE status = 'confirmed') as total_deposits,
  (SELECT COALESCE(SUM(amount), 0) FROM withdrawal_transactions WHERE status = 'completed') as total_withdrawals,
  (SELECT COALESCE(SUM(amount), 0) FROM deposit_transactions WHERE status = 'confirmed' AND created_at > now() - interval '24 hours') as deposits_24h,
  (SELECT COALESCE(SUM(amount), 0) FROM withdrawal_transactions WHERE status = 'completed' AND created_at > now() - interval '24 hours') as withdrawals_24h,
  
  -- Position stats
  (SELECT COUNT(*) FROM futures_positions WHERE status = 'open') as open_positions,
  (SELECT COALESCE(SUM(position_size * entry_price), 0) FROM futures_positions WHERE status = 'open') as total_position_value,
  
  -- Pending actions
  (SELECT COUNT(*) FROM withdrawal_transactions WHERE status = 'pending') as pending_withdrawals,
  (SELECT COALESCE(SUM(amount), 0) FROM withdrawal_transactions WHERE status = 'pending') as pending_withdrawal_amount;

GRANT SELECT ON admin_platform_stats TO authenticated;

-- ============================================================================
-- FINANCIAL STATUS FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION get_platform_financial_status()
RETURNS TABLE (
  total_liability numeric,
  total_deposits numeric,
  total_withdrawals numeric,
  net_deposits numeric,
  platform_profit_loss numeric,
  risk_ratio numeric
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    (SELECT COALESCE(SUM(balance + futures_balance), 0) FROM user_balances WHERE symbol = 'USDT') as total_liability,
    (SELECT COALESCE(SUM(amount), 0) FROM deposit_transactions WHERE status = 'confirmed') as total_deposits,
    (SELECT COALESCE(SUM(amount), 0) FROM withdrawal_transactions WHERE status = 'completed') as total_withdrawals,
    (SELECT COALESCE(SUM(amount), 0) FROM deposit_transactions WHERE status = 'confirmed') -
    (SELECT COALESCE(SUM(amount), 0) FROM withdrawal_transactions WHERE status = 'completed') as net_deposits,
    (SELECT COALESCE(SUM(realized_pnl), 0) FROM futures_positions WHERE status = 'closed') as platform_profit_loss,
    CASE 
      WHEN (SELECT COALESCE(SUM(amount), 0) FROM deposit_transactions WHERE status = 'confirmed') -
           (SELECT COALESCE(SUM(amount), 0) FROM withdrawal_transactions WHERE status = 'completed') > 0
      THEN (SELECT COALESCE(SUM(balance + futures_balance), 0) FROM user_balances WHERE symbol = 'USDT') /
           NULLIF((SELECT COALESCE(SUM(amount), 0) FROM deposit_transactions WHERE status = 'confirmed') -
                  (SELECT COALESCE(SUM(amount), 0) FROM withdrawal_transactions WHERE status = 'completed'), 0)
      ELSE 0
    END as risk_ratio;
END;
$$;

-- ============================================================================
-- VIP USERS FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION get_vip_users(p_limit int DEFAULT 20)
RETURNS TABLE (
  user_id uuid,
  email text,
  full_name text,
  total_deposited numeric,
  total_withdrawn numeric,
  current_balance numeric,
  open_positions bigint,
  joined_date timestamptz
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    up.id,
    up.email,
    up.full_name,
    COALESCE((SELECT SUM(amount) FROM deposit_transactions WHERE user_id = up.id AND status = 'confirmed'), 0) as total_deposited,
    COALESCE((SELECT SUM(amount) FROM withdrawal_transactions WHERE user_id = up.id AND status = 'completed'), 0) as total_withdrawn,
    COALESCE((SELECT balance + futures_balance FROM user_balances WHERE user_id = up.id AND symbol = 'USDT'), 0) as current_balance,
    (SELECT COUNT(*) FROM futures_positions WHERE user_id = up.id AND status = 'open') as open_positions,
    up.created_at
  FROM user_profiles up
  ORDER BY total_deposited DESC
  LIMIT p_limit;
END;
$$;

-- ============================================================================
-- WHALE TRADERS FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION get_whale_traders(p_limit int DEFAULT 20)
RETURNS TABLE (
  user_id uuid,
  email text,
  symbol text,
  position_size numeric,
  position_value numeric,
  leverage numeric,
  unrealized_pnl numeric,
  liquidation_price numeric
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    up.id,
    up.email,
    fp.symbol,
    fp.position_size,
    fp.position_size * fp.entry_price as position_value,
    fp.leverage,
    fp.unrealized_pnl,
    fp.liquidation_price
  FROM futures_positions fp
  JOIN user_profiles up ON up.id = fp.user_id
  WHERE fp.status = 'open'
  ORDER BY (fp.position_size * fp.entry_price) DESC
  LIMIT p_limit;
END;
$$;

-- ============================================================================
-- ALERT VIEWS
-- ============================================================================

-- Large pending withdrawals
CREATE OR REPLACE VIEW admin_large_withdrawals AS
SELECT
  wt.id,
  wt.user_id,
  up.email,
  up.full_name,
  wt.amount,
  wt.coin_symbol,
  wt.status,
  wt.created_at,
  EXTRACT(EPOCH FROM (now() - wt.created_at))/3600 as hours_pending,
  wt.destination_address
FROM withdrawal_transactions wt
JOIN user_profiles up ON up.id = wt.user_id
WHERE wt.status = 'pending'
  AND wt.amount > 500
ORDER BY wt.amount DESC, wt.created_at ASC;

GRANT SELECT ON admin_large_withdrawals TO authenticated;

-- Large open positions
CREATE OR REPLACE VIEW admin_large_positions AS
SELECT
  fp.id,
  fp.user_id,
  up.email,
  fp.symbol,
  fp.side,
  fp.position_size,
  fp.entry_price,
  fp.position_size * fp.entry_price as position_value,
  fp.leverage,
  fp.margin,
  fp.unrealized_pnl,
  fp.liquidation_price
FROM futures_positions fp
JOIN user_profiles up ON up.id = fp.user_id
WHERE fp.status = 'open'
  AND fp.position_size * fp.entry_price > 3000
ORDER BY (fp.position_size * fp.entry_price) DESC;

GRANT SELECT ON admin_large_positions TO authenticated;

-- ============================================================================
-- QUICK ACTION FUNCTIONS
-- ============================================================================

-- Bulk approve small withdrawals
CREATE OR REPLACE FUNCTION admin_bulk_approve_withdrawals(
  p_admin_user_id uuid,
  p_max_amount numeric DEFAULT 500
)
RETURNS int
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_count int;
BEGIN
  UPDATE withdrawal_transactions
  SET 
    status = 'completed',
    completed_at = now()
  WHERE status = 'pending'
    AND amount <= p_max_amount;
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  
  PERFORM log_admin_action(
    p_admin_user_id,
    'bulk_approve_withdrawals',
    'withdrawal',
    NULL,
    jsonb_build_object('max_amount', p_max_amount, 'approved_count', v_count),
    'success',
    NULL,
    format('Toplu onay: %s withdrawal', v_count)
  );
  
  RETURN v_count;
END;
$$;

-- ============================================================================
-- RISK METRICS FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION get_platform_risk_metrics()
RETURNS TABLE (
  total_open_positions bigint,
  total_position_value numeric,
  largest_position_value numeric,
  total_margin_used numeric,
  total_unrealized_pnl numeric,
  positions_near_liquidation bigint,
  avg_leverage numeric
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*) as total_open_positions,
    COALESCE(SUM(position_size * entry_price), 0) as total_position_value,
    COALESCE(MAX(position_size * entry_price), 0) as largest_position_value,
    COALESCE(SUM(margin), 0) as total_margin_used,
    COALESCE(SUM(unrealized_pnl), 0) as total_unrealized_pnl,
    COUNT(*) FILTER (WHERE 
      CASE
        WHEN side = 'long' THEN ABS((liquidation_price - entry_price) / entry_price * 100) < 10
        ELSE ABS((entry_price - liquidation_price) / entry_price * 100) < 10
      END
    ) as positions_near_liquidation,
    COALESCE(AVG(leverage), 0) as avg_leverage
  FROM futures_positions
  WHERE status = 'open';
END;
$$;

-- ============================================================================
-- SYSTEM HEALTH VIEW
-- ============================================================================

CREATE OR REPLACE VIEW admin_system_health AS
SELECT
  (SELECT COUNT(*) FROM deposit_transactions WHERE status = 'failed' AND created_at > now() - interval '1 hour') as failed_deposits_last_hour,
  (SELECT COUNT(*) FROM withdrawal_transactions WHERE status = 'pending' AND created_at < now() - interval '24 hours') as stuck_withdrawals,
  (SELECT COUNT(DISTINCT user_id) FROM deposit_transactions WHERE created_at > now() - interval '1 hour') as active_users_last_hour,
  (SELECT COUNT(*) FROM futures_positions WHERE status = 'open' AND created_at > now() - interval '1 hour') as new_positions_last_hour,
  now() as checked_at;

GRANT SELECT ON admin_system_health TO authenticated;

-- Add comments
COMMENT ON VIEW admin_platform_stats IS 'Real-time platform statistics for admin dashboard';
COMMENT ON FUNCTION get_platform_financial_status IS 'Complete financial overview including liability and risk ratio';
COMMENT ON FUNCTION get_vip_users IS 'Top depositors (VIP users)';
COMMENT ON FUNCTION get_whale_traders IS 'Users with largest open positions';
COMMENT ON VIEW admin_large_withdrawals IS 'Pending withdrawals over $500 requiring attention';
COMMENT ON VIEW admin_large_positions IS 'Large open positions over $3000 for risk monitoring';
COMMENT ON FUNCTION admin_bulk_approve_withdrawals IS 'Bulk approve withdrawals under specified amount';
COMMENT ON FUNCTION get_platform_risk_metrics IS 'Platform risk metrics including liquidation risks';
COMMENT ON VIEW admin_system_health IS 'System health indicators for monitoring';
