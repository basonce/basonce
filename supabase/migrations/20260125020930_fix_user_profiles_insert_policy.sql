/*
  # Fix User Profiles Registration

  1. Changes
    - Add INSERT policy to user_profiles for new user registration
    - Create trigger to auto-create user_profiles on auth.users insert
    - This allows users to register successfully

  2. Security
    - Users can only insert their own profile (auth.uid() = id)
    - Profile is auto-created on signup via trigger
*/

-- Drop existing policy if exists
DROP POLICY IF EXISTS "Users can create own profile" ON user_profiles;

-- Allow users to insert their own profile during registration
CREATE POLICY "Users can create own profile"
  ON user_profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Create function to auto-create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', '')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to call function on new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();