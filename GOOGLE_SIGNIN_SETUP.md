# Google Sign-In Setup Guide for VenueVista

## ✅ What's Already Done

1. ✅ Added `google_sign_in` dependency to pubspec.yaml
2. ✅ Updated AuthService with Google Sign-In functionality  
3. ✅ Updated Login page with Google Sign-In button and logic
4. ✅ Updated Registration page with Google Sign-Up button and logic
5. ✅ Added Android configuration for Google Services
6. ✅ Created template google-services.json file

## 🔧 What You Need to Do Next

### Step 1: Firebase Console Setup

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Create or Select Project**: 
   - Create a new project OR select existing project
   - Enable Google Analytics (optional)

3. **Add Android App**:
   - Click "Add app" → Android
   - Package name: `com.example.venuevista`
   - App nickname: `VenueVista`
   - SHA-1 certificate fingerprint: Get this by running command below

4. **Download google-services.json**:
   - Download the file from Firebase Console
   - Replace the template file at `android/app/google-services.json`

### Step 2: Get SHA-1 Certificate Fingerprint

Run this command in your project's `android` folder:

```bash
cd android
./gradlew signingReport
```

Look for the SHA1 fingerprint in the output and add it to Firebase Console.

### Step 3: Supabase Google Provider Configuration

1. **Go to Supabase Dashboard**: https://supabase.com/dashboard
2. **Navigate to**: Authentication → Providers → Google
3. **Enable Google Provider**
4. **Add OAuth Credentials**:
   - Get Client ID and Client Secret from Firebase Console
   - Go to Firebase Console → Authentication → Sign-in method → Google
   - Copy the Web Client ID and Web Client Secret to Supabase

### Step 4: Update Environment Configuration (Optional)

Add Google configuration to your `.env.development` file:

```bash
# Google Sign-In Configuration
GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

## 🎯 Testing the Implementation

### For User Registration:
1. Open Registration page
2. Click "Sign up with Google" button
3. Select Google account
4. User will be created with 'user' role by default
5. Redirected to login page

### For User Login:
1. Open Login page  
2. Select "User" role
3. Click "Google" button
4. If user exists with 'user' role → Login successful
5. If user doesn't exist → Creates new user profile automatically

### For Admin/Owner Login:
1. Admin/Owner accounts must be created manually first via email registration
2. Google Sign-In only works for existing accounts with matching roles
3. New Google sign-ins are always created as 'user' role

## 🔍 How It Works

### Registration Flow:
1. User clicks "Sign up with Google"
2. Google authentication happens
3. Check if user already exists in database
4. If exists → Show message and redirect to login
5. If not exists → Create new user profile with 'user' role
6. Success message and redirect to login

### Login Flow:
1. User selects role and clicks "Google" button
2. Google authentication happens
3. Check if user profile exists in database
4. If exists and role matches → Login successful
5. If exists but role doesn't match → Show error
6. If doesn't exist and selected role is 'user' → Create new profile
7. If doesn't exist and selected role is admin/owner → Show error

## 🚀 Ready to Test!

Once you complete Steps 1-3 above, your Google Sign-In will be fully functional. The code is already implemented and ready to work!

## 🔧 Troubleshooting

If you face issues:

1. **"Google sign-in failed"**: Check google-services.json file
2. **"Invalid client ID"**: Verify SHA-1 fingerprint in Firebase  
3. **"User not found"**: Make sure Supabase Google provider is enabled
4. **"Role mismatch"**: Google sign-ins default to 'user' role only

## 📁 Files Modified

- `pubspec.yaml` - Added google_sign_in dependency
- `lib/services/auth_service.dart` - Added Google Sign-In methods
- `lib/screens/login_page.dart` - Added Google login functionality
- `lib/screens/registration_page.dart` - Added Google signup functionality
- `android/build.gradle.kts` - Added Google Services plugin
- `android/app/build.gradle.kts` - Added Google Services plugin
- `android/app/google-services.json` - Template file (needs replacement)
