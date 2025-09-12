# Profile Image Setup Guide for Supabase

## Step-by-Step Instructions

### Step 1: Add Column to Database
1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor**
3. Run this query:

```sql
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS profile_image_url TEXT;
```

### Step 2: Create Storage Bucket
1. Go to **Storage** in Supabase Dashboard
2. Click **Create Bucket**
3. Fill in:
   - **Name**: `profile-images`
   - **Public**: ✅ **Yes** (checked)
   - **File size limit**: 50MB
   - **Allowed MIME types**: `image/jpeg,image/png,image/webp`
4. Click **Create**

### Step 3: Set Up Storage Policies
Go back to **SQL Editor** and run these queries **ONE BY ONE**:

#### Query 1:
```sql
CREATE POLICY "Users can upload own profile image"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'profile-images' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);
```

#### Query 2:
```sql
CREATE POLICY "Users can update own profile image"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'profile-images' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);
```

#### Query 3:
```sql
CREATE POLICY "Users can delete own profile image"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'profile-images' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);
```

#### Query 4:
```sql
CREATE POLICY "Anyone can view profile images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profile-images');
```

### Step 4: Verify Setup
1. Go to **Storage** > **profile-images** bucket
2. Check that the bucket exists and is marked as **Public**
3. Go to **Authentication** > **Policies** 
4. Verify that you see 4 policies for `storage.objects` related to profile-images

### Alternative: If Policies Still Don't Work
If you continue to have permission issues, you can create a more permissive policy temporarily:

```sql
CREATE POLICY "Full access to profile images"
ON storage.objects
TO authenticated
USING (bucket_id = 'profile-images')
WITH CHECK (bucket_id = 'profile-images');
```

This gives full access to authenticated users for the profile-images bucket.

### Step 5: Test in App
Once the database and storage are set up:
1. Run your Flutter app
2. Go to Profile page
3. Click on the avatar
4. Try uploading an image
5. Check that it appears in both profile page and drawer

## Troubleshooting

### If you get "bucket not found" error:
- Make sure the bucket name is exactly `profile-images`
- Ensure the bucket is marked as Public

### If you get permission errors:
- Check that RLS is enabled on storage.objects
- Verify policies are created correctly
- Try the more permissive policy above

### If images don't display:
- Check that the bucket is Public
- Verify the image URLs are correct
- Check browser console for network errors
