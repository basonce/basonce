/*
  # Otomatik Cüzdan Atama Sistemi

  Yeni kullanıcı kaydolduğunda otomatik olarak wallet_pool'dan boş bir cüzdan atar.

  ## Özellikler:
  1. Yeni kullanıcı kaydında otomatik trigger
  2. Hem BEP20 hem TRC20 için bir adet cüzdan atar (varsa)
  3. Atanan cüzdanı is_assigned=true yapar
  4. assigned_user_id ve assigned_at güncellemeleri
  5. Kullanıcı ilk kayıtta deposit adreslerine sahip olur

  ## Güvenlik:
  - SECURITY DEFINER ile çalışır (RLS bypass gerekli)
  - Sadece yeni kullanıcı oluşturulduğunda tetiklenir
  - Aynı cüzdan birden fazla kullanıcıya ASLA atanamaz
*/

-- Function: Kullanıcıya otomatik cüzdan ata
CREATE OR REPLACE FUNCTION assign_wallet_to_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_bep20_wallet_id uuid;
  v_trc20_wallet_id uuid;
BEGIN
  -- BEP20 cüzdan ata (varsa)
  SELECT id INTO v_bep20_wallet_id
  FROM wallet_pool
  WHERE network = 'BEP20'
    AND is_assigned = false
  ORDER BY created_at ASC
  LIMIT 1
  FOR UPDATE SKIP LOCKED;

  IF v_bep20_wallet_id IS NOT NULL THEN
    UPDATE wallet_pool
    SET
      is_assigned = true,
      assigned_user_id = NEW.id,
      assigned_at = now()
    WHERE id = v_bep20_wallet_id;
  END IF;

  -- TRC20 cüzdan ata (varsa)
  SELECT id INTO v_trc20_wallet_id
  FROM wallet_pool
  WHERE network = 'TRC20'
    AND is_assigned = false
  ORDER BY created_at ASC
  LIMIT 1
  FOR UPDATE SKIP LOCKED;

  IF v_trc20_wallet_id IS NOT NULL THEN
    UPDATE wallet_pool
    SET
      is_assigned = true,
      assigned_user_id = NEW.id,
      assigned_at = now()
    WHERE id = v_trc20_wallet_id;
  END IF;

  RETURN NEW;
END;
$$;

-- Trigger: user_profiles tablosuna insert olduğunda cüzdan ata
DROP TRIGGER IF EXISTS auto_assign_wallet_on_signup ON user_profiles;

CREATE TRIGGER auto_assign_wallet_on_signup
  AFTER INSERT ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION assign_wallet_to_new_user();

-- Function: Kullanıcının atanmış cüzdanlarını getir
CREATE OR REPLACE FUNCTION get_user_deposit_addresses(user_id_param uuid)
RETURNS TABLE (
  network text,
  address text,
  assigned_at timestamptz
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    wp.network::text,
    wp.address::text,
    wp.assigned_at
  FROM wallet_pool wp
  WHERE wp.assigned_user_id = user_id_param
    AND wp.is_assigned = true
  ORDER BY wp.network;
END;
$$;

-- RLS: Kullanıcılar sadece kendi atanmış cüzdanlarını görebilir
DROP POLICY IF EXISTS "Users can view their assigned wallets" ON wallet_pool;
CREATE POLICY "Users can view their assigned wallets"
  ON wallet_pool
  FOR SELECT
  TO authenticated
  USING (assigned_user_id = auth.uid() AND is_assigned = true);
