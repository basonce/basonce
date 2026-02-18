/*
  # Profesyonel Profil Sistemi - Basonce Tarzı

  1. User Profiles Geliştirmeleri
    - user_id: Benzersiz kullanıcı numarası (örn: 57550677)
    - verification_status: Doğrulama durumu ('regular', 'verified', 'vip')
    - user_level: Kullanıcı seviyesi (0-10)
    - referral_code: Benzersiz referans kodu
    - total_trades: Toplam işlem sayısı
    - total_volume_usdt: Toplam işlem hacmi (USDT)
    - last_login_at: Son giriş zamanı
    
  2. Referral System Tablosu
    - referrals: Davetler ve kazançlar
    
  3. User Statistics Tablosu
    - user_statistics: Detaylı kullanıcı istatistikleri
    
  4. Security
    - Tüm yeni tablolar için RLS politikaları
    - Her kullanıcı kendi verilerini görüntüleyebilir
*/

-- User profiles tablosuna yeni kolonlar ekle
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS user_id bigint,
ADD COLUMN IF NOT EXISTS verification_status text DEFAULT 'regular',
ADD COLUMN IF NOT EXISTS user_level integer DEFAULT 1,
ADD COLUMN IF NOT EXISTS referral_code text,
ADD COLUMN IF NOT EXISTS total_trades integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_volume_usdt numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_login_at timestamptz;

-- User ID için sequence oluştur (100000'den başlasın)
CREATE SEQUENCE IF NOT EXISTS user_id_seq START WITH 100000;

-- Mevcut kullanıcılara user_id ata
UPDATE user_profiles 
SET user_id = nextval('user_id_seq')
WHERE user_id IS NULL;

-- User ID unique constraint ekle
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'user_profiles_user_id_unique'
  ) THEN
    ALTER TABLE user_profiles ADD CONSTRAINT user_profiles_user_id_unique UNIQUE (user_id);
  END IF;
END $$;

-- Referral code için function
CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS TEXT AS $$
DECLARE
  code TEXT;
  exists BOOLEAN;
BEGIN
  LOOP
    code := upper(substring(md5(random()::text) from 1 for 8));
    
    SELECT EXISTS(SELECT 1 FROM user_profiles WHERE referral_code = code) INTO exists;
    
    IF NOT exists THEN
      RETURN code;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Mevcut kullanıcılara referral code ata
UPDATE user_profiles 
SET referral_code = generate_referral_code()
WHERE referral_code IS NULL;

-- Referrals tablosu oluştur
CREATE TABLE IF NOT EXISTS referrals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  referred_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  referral_code text NOT NULL,
  reward_earned numeric DEFAULT 0,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'referrals_unique_referred'
  ) THEN
    ALTER TABLE referrals ADD CONSTRAINT referrals_unique_referred UNIQUE(referred_id);
  END IF;
END $$;

ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own referrals"
ON referrals FOR SELECT
TO authenticated
USING (auth.uid() = referrer_id);

CREATE POLICY "Users can insert referrals"
ON referrals FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = referrer_id);

-- User statistics tablosu
CREATE TABLE IF NOT EXISTS user_statistics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  spot_trades integer DEFAULT 0,
  futures_trades integer DEFAULT 0,
  total_deposits numeric DEFAULT 0,
  total_withdrawals numeric DEFAULT 0,
  highest_pnl numeric DEFAULT 0,
  lowest_pnl numeric DEFAULT 0,
  win_rate numeric DEFAULT 0,
  updated_at timestamptz DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'user_statistics_user_id_unique'
  ) THEN
    ALTER TABLE user_statistics ADD CONSTRAINT user_statistics_user_id_unique UNIQUE(user_id);
  END IF;
END $$;

ALTER TABLE user_statistics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own statistics"
ON user_statistics FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can update own statistics"
ON user_statistics FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "System can insert statistics"
ON user_statistics FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- User profil oluşturulduğunda otomatik statistics oluştur
CREATE OR REPLACE FUNCTION create_user_statistics()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_statistics (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_user_profile_created_statistics ON user_profiles;
CREATE TRIGGER on_user_profile_created_statistics
  AFTER INSERT ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION create_user_statistics();

-- Verification status constraint
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'verification_status_check'
  ) THEN
    ALTER TABLE user_profiles
    ADD CONSTRAINT verification_status_check 
    CHECK (verification_status IN ('regular', 'verified', 'vip', 'premium'));
  END IF;
END $$;
