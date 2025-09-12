-- Fixed Migration for Profile Images
-- This version handles Supabase storage permissions correctly

-- 1. Add profile_image_url column to user_profiles table
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS profile_image_url TEXT;

-- Add comment for documentation
COMMENT ON COLUMN public.user_profiles.profile_image_url IS 'URL to user profile image stored in Supabase storage';

-- 2. Create storage bucket for profile images (this needs to be done in Supabase Dashboard)
-- Go to Storage > Create Bucket:
-- - Name: profile-images
-- - Public: Yes
-- - File size limit: 50MB (recommended)
-- - Allowed MIME types: image/jpeg, image/png, image/webp

-- 3. After creating the bucket manually, run these policies:
-- Note: Run these one by one in the SQL Editor, not all at once

-- Policy 1: Allow users to upload their own profile images
CREATE POLICY "Users can upload own profile image"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'profile-images' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 2: Allow users to update their own profile images  
CREATE POLICY "Users can update own profile image"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'profile-images' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 3: Allow users to delete their own profile images
CREATE POLICY "Users can delete own profile image"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'profile-images' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 4: Allow public read access to all profile images
CREATE POLICY "Anyone can view profile images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profile-images');
