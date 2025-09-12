-- Migration to add profile image column to user_profiles table
-- Add profile_image_url column to store image URLs from Supabase storage

ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS profile_image_url TEXT;

-- Add comment for documentation
COMMENT ON COLUMN public.user_profiles.profile_image_url IS 'URL to user profile image stored in Supabase storage';

-- Create storage bucket for profile images if it doesn't exist
INSERT INTO storage.buckets (id, name, public) 
VALUES ('profile-images', 'profile-images', true)
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies for profile images
-- Policy to allow users to upload their own profile images
CREATE POLICY "Users can upload own profile image" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'profile-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy to allow users to update their own profile images
CREATE POLICY "Users can update own profile image" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'profile-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy to allow users to delete their own profile images
CREATE POLICY "Users can delete own profile image" ON storage.objects
FOR DELETE USING (
  bucket_id = 'profile-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy to allow public read access to profile images
CREATE POLICY "Public can view profile images" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-images');

-- Enable RLS on storage.objects if not already enabled
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
