/*
  # Alpha Token Logo Storage

  1. Storage
    - Create `alpha-logos` public bucket for token logo images
    - Max file size 5MB, allowed types: PNG, JPEG, WEBP, GIF

  2. Security
    - Authenticated users can upload logo images
    - Anyone can view logos (public bucket)
    - Users can only update/delete their own uploads
*/

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'alpha-logos',
  'alpha-logos',
  true,
  5242880,
  ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Anyone can view alpha logos"
  ON storage.objects FOR SELECT
  TO authenticated, anon
  USING (bucket_id = 'alpha-logos');

CREATE POLICY "Authenticated users can upload alpha logos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'alpha-logos');

CREATE POLICY "Users can update own alpha logos"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'alpha-logos' AND auth.uid()::text = (storage.foldername(name))[1])
  WITH CHECK (bucket_id = 'alpha-logos');

CREATE POLICY "Users can delete own alpha logos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'alpha-logos' AND auth.uid()::text = (storage.foldername(name))[1]);
