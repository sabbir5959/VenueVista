-- Simple fix for profile image column
-- Run this in your Supabase SQL Editor

-- First, let's make sure the column exists
DO $$
BEGIN
    -- Check if column exists, if not add it
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'user_profiles' 
        AND column_name = 'profile_image_url'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN profile_image_url TEXT;
        RAISE NOTICE 'Added profile_image_url column';
    ELSE
        RAISE NOTICE 'profile_image_url column already exists';
    END IF;
END $$;

-- Verify the column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'user_profiles' 
AND column_name = 'profile_image_url';
