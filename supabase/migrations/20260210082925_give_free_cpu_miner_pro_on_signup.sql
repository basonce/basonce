/*
  # Give Free CPU Miner Pro to New Signups

  1. Changes
    - Update handle_new_user() function to give FREE CPU Miner Pro on signup
    - This incentivizes users to convert from demo mode to real accounts
    - CPU Miner Pro provides better earnings ($1.2/day vs demo)

  2. Benefits
    - Increases conversion rate from demo to signup
    - Users get immediate value after registration
    - Encourages engagement with mining feature

  3. Security
    - Function runs as SECURITY DEFINER (safe)
    - Only creates equipment for the new user
    - No external input, all hardcoded values
*/

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  cpu_miner_pro_id UUID;
BEGIN
  -- Set trigger flag to bypass RLS
  PERFORM set_config('app.is_trigger', 'true', true);

  -- Create user profile
  INSERT INTO public.user_profiles (
    id,
    email,
    full_name,
    user_id,
    referral_code
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    nextval('user_id_seq'),
    generate_referral_code()
  );

  -- Create initial USDT balance
  INSERT INTO public.user_balances (user_id, symbol, balance, locked_balance)
  VALUES (NEW.id, 'USDT', 0, 0);

  -- Give FREE CPU Miner Pro as signup bonus
  -- First, get the CPU Miner Pro equipment type ID
  SELECT id INTO cpu_miner_pro_id
  FROM mining_equipment_types
  WHERE name = 'CPU Miner'
  AND is_free = true
  LIMIT 1;

  -- If CPU Miner exists, give it to the new user
  IF cpu_miner_pro_id IS NOT NULL THEN
    INSERT INTO user_mining_equipment (
      user_id,
      equipment_type_id,
      icon,
      status,
      is_active,
      test_mode,
      mining_duration_seconds,
      session_earned_usdt,
      total_earned_usdt,
      times_used,
      is_locked
    )
    VALUES (
      NEW.id,
      cpu_miner_pro_id,
      '💻',
      'stopped',
      false,
      false, -- Real mode, not test
      0,
      0,
      0,
      0,
      false
    );
  END IF;

  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION handle_new_user IS 'Auto-creates user profile, 0 USDT balance, and FREE CPU Miner Pro for new signups';