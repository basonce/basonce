/*
  # Smart Analytics & User Tracking System

  ## Overview
  Lightweight analytics system with minimal database load:
  - Batch processing (30 second intervals)
  - Session-based tracking
  - IP geolocation
  - Anonymous visitor tracking
  - User journey mapping

  ## Tables
  1. analytics_sessions - Session tracking
  2. analytics_events - Event tracking
  3. analytics_page_stats - Page statistics
  4. analytics_online_users - Real-time online users
*/

-- 1. Analytics Sessions
CREATE TABLE IF NOT EXISTS analytics_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id text UNIQUE NOT NULL,
  auth_user_id uuid,
  ip_address text,
  country_code text,
  country_name text,
  city text,
  region text,
  timezone text,
  browser text,
  device_type text,
  os text,
  started_at timestamptz DEFAULT now(),
  last_activity_at timestamptz DEFAULT now(),
  total_events int DEFAULT 0,
  total_duration_seconds int DEFAULT 0,
  is_registered boolean DEFAULT false,
  converted_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- 2. Analytics Events
CREATE TABLE IF NOT EXISTS analytics_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id text NOT NULL,
  auth_user_id uuid,
  event_type text NOT NULL,
  page_path text NOT NULL,
  element_id text,
  element_text text,
  event_data jsonb DEFAULT '{}'::jsonb,
  duration_seconds int DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- 3. Page Statistics
CREATE TABLE IF NOT EXISTS analytics_page_stats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_path text UNIQUE NOT NULL,
  total_views bigint DEFAULT 0,
  unique_visitors bigint DEFAULT 0,
  total_duration_seconds bigint DEFAULT 0,
  avg_duration_seconds int DEFAULT 0,
  bounce_count bigint DEFAULT 0,
  conversion_count bigint DEFAULT 0,
  last_updated_at timestamptz DEFAULT now()
);

-- 4. Online Users
CREATE TABLE IF NOT EXISTS analytics_online_users (
  session_id text PRIMARY KEY,
  auth_user_id uuid,
  username text,
  avatar_url text,
  current_page text,
  country_code text,
  country_name text,
  device_type text,
  last_activity_at timestamptz,
  duration_on_current_page int DEFAULT 0
);

-- Enable RLS
ALTER TABLE analytics_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_page_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_online_users ENABLE ROW LEVEL SECURITY;

-- RLS: analytics_sessions
CREATE POLICY "Admins view all sessions"
  ON analytics_sessions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
    )
  );

CREATE POLICY "Users view own sessions"
  ON analytics_sessions FOR SELECT
  TO authenticated
  USING (auth_user_id = auth.uid());

CREATE POLICY "Anyone insert sessions"
  ON analytics_sessions FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "System update sessions"
  ON analytics_sessions FOR UPDATE
  TO anon, authenticated
  USING (true);

-- RLS: analytics_events
CREATE POLICY "Admins view all events"
  ON analytics_events FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
    )
  );

CREATE POLICY "Users view own events"
  ON analytics_events FOR SELECT
  TO authenticated
  USING (auth_user_id = auth.uid());

CREATE POLICY "Anyone insert events"
  ON analytics_events FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- RLS: analytics_page_stats
CREATE POLICY "Admins view page stats"
  ON analytics_page_stats FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
    )
  );

CREATE POLICY "System manage page stats"
  ON analytics_page_stats FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- RLS: analytics_online_users
CREATE POLICY "Admins view online users"
  ON analytics_online_users FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.is_admin = true
    )
  );

CREATE POLICY "System manage online users"
  ON analytics_online_users FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_sessions_session_id ON analytics_sessions(session_id);
CREATE INDEX IF NOT EXISTS idx_sessions_auth_user_id ON analytics_sessions(auth_user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_last_activity ON analytics_sessions(last_activity_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_country ON analytics_sessions(country_code);

CREATE INDEX IF NOT EXISTS idx_events_session_id ON analytics_events(session_id);
CREATE INDEX IF NOT EXISTS idx_events_auth_user_id ON analytics_events(auth_user_id);
CREATE INDEX IF NOT EXISTS idx_events_type ON analytics_events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_page ON analytics_events(page_path);
CREATE INDEX IF NOT EXISTS idx_events_created_at ON analytics_events(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_page_stats_path ON analytics_page_stats(page_path);
CREATE INDEX IF NOT EXISTS idx_online_users_auth_user_id ON analytics_online_users(auth_user_id);

-- Function: Update page statistics
CREATE OR REPLACE FUNCTION update_page_statistics()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO analytics_page_stats (page_path, total_views, unique_visitors, total_duration_seconds, avg_duration_seconds)
  SELECT
    page_path,
    COUNT(*) as total_views,
    COUNT(DISTINCT session_id) as unique_visitors,
    SUM(duration_seconds) as total_duration_seconds,
    AVG(duration_seconds)::int as avg_duration_seconds
  FROM analytics_events
  WHERE event_type = 'page_view'
  GROUP BY page_path
  ON CONFLICT (page_path)
  DO UPDATE SET
    total_views = EXCLUDED.total_views,
    unique_visitors = EXCLUDED.unique_visitors,
    total_duration_seconds = EXCLUDED.total_duration_seconds,
    avg_duration_seconds = EXCLUDED.avg_duration_seconds,
    last_updated_at = now();
END;
$$;

-- Function: Refresh online users
CREATE OR REPLACE FUNCTION refresh_online_users()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  DELETE FROM analytics_online_users
  WHERE last_activity_at < now() - interval '5 minutes';

  INSERT INTO analytics_online_users (
    session_id,
    auth_user_id,
    username,
    avatar_url,
    current_page,
    country_code,
    country_name,
    device_type,
    last_activity_at,
    duration_on_current_page
  )
  SELECT DISTINCT ON (s.session_id)
    s.session_id,
    s.auth_user_id,
    COALESCE(up.username, 'Anonymous'),
    up.avatar_url,
    e.page_path as current_page,
    s.country_code,
    s.country_name,
    s.device_type,
    s.last_activity_at,
    EXTRACT(EPOCH FROM (now() - e.created_at))::int as duration_on_current_page
  FROM analytics_sessions s
  LEFT JOIN user_profiles up ON up.id = s.auth_user_id
  LEFT JOIN LATERAL (
    SELECT page_path, created_at
    FROM analytics_events
    WHERE session_id = s.session_id
    ORDER BY created_at DESC
    LIMIT 1
  ) e ON true
  WHERE s.last_activity_at > now() - interval '5 minutes'
  ORDER BY s.session_id, s.last_activity_at DESC
  ON CONFLICT (session_id)
  DO UPDATE SET
    auth_user_id = EXCLUDED.auth_user_id,
    username = EXCLUDED.username,
    avatar_url = EXCLUDED.avatar_url,
    current_page = EXCLUDED.current_page,
    last_activity_at = EXCLUDED.last_activity_at,
    duration_on_current_page = EXCLUDED.duration_on_current_page;
END;
$$;

-- Function: Get analytics summary
CREATE OR REPLACE FUNCTION get_analytics_summary()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result jsonb;
BEGIN
  PERFORM refresh_online_users();

  SELECT jsonb_build_object(
    'online_now', (SELECT COUNT(*) FROM analytics_online_users),
    'total_sessions_today', (
      SELECT COUNT(*) FROM analytics_sessions
      WHERE started_at > CURRENT_DATE
    ),
    'total_events_today', (
      SELECT COUNT(*) FROM analytics_events
      WHERE created_at > CURRENT_DATE
    ),
    'anonymous_visitors_today', (
      SELECT COUNT(*) FROM analytics_sessions
      WHERE started_at > CURRENT_DATE AND auth_user_id IS NULL
    ),
    'registered_users_today', (
      SELECT COUNT(*) FROM analytics_sessions
      WHERE started_at > CURRENT_DATE AND auth_user_id IS NOT NULL
    ),
    'top_countries', (
      SELECT jsonb_agg(row_to_json(t))
      FROM (
        SELECT country_name, country_code, COUNT(*) as count
        FROM analytics_sessions
        WHERE started_at > CURRENT_DATE AND country_name IS NOT NULL
        GROUP BY country_name, country_code
        ORDER BY count DESC
        LIMIT 10
      ) t
    ),
    'top_pages', (
      SELECT jsonb_agg(row_to_json(t))
      FROM (
        SELECT page_path, total_views, unique_visitors, avg_duration_seconds
        FROM analytics_page_stats
        ORDER BY total_views DESC
        LIMIT 10
      ) t
    ),
    'conversion_funnel', (
      SELECT jsonb_build_object(
        'home_views', (SELECT COUNT(*) FROM analytics_events WHERE page_path = '/' AND created_at > CURRENT_DATE),
        'markets_views', (SELECT COUNT(*) FROM analytics_events WHERE page_path = '/markets' AND created_at > CURRENT_DATE),
        'trade_views', (SELECT COUNT(*) FROM analytics_events WHERE page_path = '/trade' AND created_at > CURRENT_DATE),
        'registrations', (SELECT COUNT(*) FROM user_profiles WHERE created_at > CURRENT_DATE)
      )
    )
  ) INTO result;

  RETURN result;
END;
$$;

-- Function: Get user journey
CREATE OR REPLACE FUNCTION get_user_journey(p_session_id text DEFAULT NULL, p_auth_user_id uuid DEFAULT NULL)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result jsonb;
BEGIN
  SELECT jsonb_agg(
    jsonb_build_object(
      'event_type', event_type,
      'page_path', page_path,
      'element_id', element_id,
      'element_text', element_text,
      'duration_seconds', duration_seconds,
      'created_at', created_at
    ) ORDER BY created_at
  ) INTO result
  FROM analytics_events
  WHERE (p_session_id IS NOT NULL AND session_id = p_session_id)
     OR (p_auth_user_id IS NOT NULL AND auth_user_id = p_auth_user_id)
  ORDER BY created_at;

  RETURN COALESCE(result, '[]'::jsonb);
END;
$$;

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE analytics_online_users;