-- Comprehensive Profile Image Setup for VenueVista
-- Execute this script in your Supabase SQL Editor

-- Step 1: Create profile_image_url column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name='user_profiles' AND column_name='profile_image_url'
    ) THEN
        ALTER TABLE user_profiles ADD COLUMN profile_image_url TEXT;
        RAISE NOTICE 'Added profile_image_url column to user_profiles table';
    ELSE
        RAISE NOTICE 'profile_image_url column already exists in user_profiles table';
    END IF;
END $$;

-- Step 2: Create storage bucket for profile images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'profile-images', 
    'profile-images', 
    true, 
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
) ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Step 3: Create RLS policies for the bucket
CREATE POLICY "Profile images are viewable by everyone" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-images');

CREATE POLICY "Users can upload their own profile images" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'profile-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update their own profile images" ON storage.objects
FOR UPDATE USING (
    bucket_id = 'profile-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own profile images" ON storage.objects
FOR DELETE USING (
    bucket_id = 'profile-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Step 4: Update existing user_profiles records to have default values
UPDATE user_profiles 
SET profile_image_url = NULL 
WHERE profile_image_url IS NOT DISTINCT FROM '';

-- Step 5: Create an index for better performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_image_url 
ON user_profiles(profile_image_url) 
WHERE profile_image_url IS NOT NULL;

-- Step 6: Verify the setup
SELECT 
    'user_profiles table' as object_type,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'user_profiles' AND column_name = 'profile_image_url'

UNION ALL

SELECT 
    'storage bucket' as object_type,
    id as column_name,
    name as data_type,
    public::text as is_nullable
FROM storage.buckets 
WHERE id = 'profile-images';

-- Success message
SELECT 'Profile image setup completed successfully! ✅' as status;
