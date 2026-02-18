/*
  # Profil Avatar Sistemi

  1. Değişiklikler
    - user_profiles tablosuna avatar_url kolonu eklendi
    - Profil fotoğrafları için Storage bucket oluşturuldu
    - Storage RLS politikaları eklendi
    
  2. Storage Politikaları
    - Herkes kendi avatarını upload edebilir
    - Herkes tüm avatarları görüntüleyebilir (public read)
    - Sadece kendi avatarını güncelleyebilir
    - Sadece kendi avatarını silebilir
    
  3. Notlar
    - Avatar dosyaları "avatars" bucket'ında saklanır
    - Dosya formatı: {user_id}.{extension}
    - Max dosya boyutu: 5MB
*/

-- Avatar URL kolonu ekle
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS avatar_url text;

-- Storage bucket oluştur
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Storage RLS politikaları
CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update own avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);
