# Google Sign-In Setup Guide for VenueVista

## 🚀 Quick Setup Summary

Google Sign-In has been implemented in your VenueVista app! Here's what was added:

### ✅ Code Changes Completed:
- ✅ Added `google_sign_in: ^6.2.1` dependency
- ✅ Updated `AuthService` with Google authentication
- ✅ Added Google Sign-In button to Login page
- ✅ Added Google Sign-Up button to Registration page
- ✅ Configured Android build files

### 📋 Required Manual Steps:

## 1. Firebase Console Setup

### Step 1: Create/Access Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project or use existing one
3. Enter project name: `VenueVista` or similar

### Step 2: Add Android App
1. Click "Add app" → Select Android
2. **Package name**: `com.example.venuevista`
3. **App nickname**: `VenueVista`
4. **Debug signing SHA-1**: `67:BB:ED:44:A5:EA:EF:C5:1C:BB:A9:A6:A4:B9:61:8F:D1:53:25:D5`

### Step 3: Download Configuration
1. Download `google-services.json`
2. Place it in `android/app/` folder
3. **Important**: The file should be at `android/app/google-services.json`

### Step 4: Enable Authentication
1. Go to Authentication → Sign-in method
2. Enable **Google** provider
3. Set support email
4. Add your test email addresses

### Step 5: Configure OAuth Consent Screen
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. APIs & Services → OAuth consent screen
3. Configure app information
4. Add test users if in testing mode

## 2. Supabase Configuration

### Update Supabase Auth Settings:
1. Go to your Supabase Dashboard
2. Authentication → Settings → Auth Providers
3. **Enable Google OAuth**:
   - Toggle ON "Enable sign in with Google"
   - **Client ID**: Get from Firebase Console → Authentication → Sign-in method → Google → Web SDK configuration
   - **Client Secret**: Get from Google Cloud Console → APIs & Services → Credentials

### Add Redirect URLs:
Add these URLs to your Supabase Auth settings:
```
http://localhost:3000/auth/callback
https://your-project.supabase.co/auth/v1/callback
```

## 3. Test Your Implementation

### After completing setup:

1. **Test Registration**:
   ```
   1. Open Registration page
   2. Click "Sign up with Google"
   3. Complete Google sign-in
   4. Verify user created in Supabase
   ```

2. **Test Login**:
   ```
   1. Open Login page
   2. Select "User" role
   3. Click "Google" button
   4. Verify login success
   ```

## 4. Current Implementation Features

### 🎯 What's Working:
- ✅ Google Sign-In/Sign-Up flow
- ✅ User profile creation in Supabase
- ✅ Role-based navigation
- ✅ Automatic user role assignment (defaults to 'user')
- ✅ Existing user detection and handling
- ✅ Error handling and user feedback

### 🔄 User Flow:
1. **First Time (Registration)**:
   - User clicks "Sign up with Google"
   - Google authentication completes
   - New user profile created in Supabase with role 'user'
   - Redirected to login page

2. **Subsequent Logins**:
   - User clicks "Google" on login page
   - Role must match selected role dropdown
   - Successful login navigates to appropriate dashboard

### 🛡️ Security Features:
- ✅ Role validation before navigation
- ✅ Automatic sign-out on role mismatch
- ✅ Proper error handling
- ✅ User feedback messages

## 5. File Structure

```
lib/services/auth_service.dart     # Updated with Google auth
lib/screens/login_page.dart        # Added Google login button
lib/screens/registration_page.dart # Added Google signup button
android/app/build.gradle.kts       # Configured Google services
android/build.gradle.kts           # Added Google services classpath
```

## 6. Environment Variables

Your `.env.development` file should contain:
```env
SUPABASE_URL=https://mdeurwhhfnbtmcuuceee.supabase.co
SUPABASE_ANON_KEY=your_anon_key
```

## 7. Next Steps After Setup

1. **Download and place google-services.json**
2. **Configure Supabase Google OAuth**
3. **Test the authentication flow**
4. **Run**: `flutter clean && flutter pub get && flutter run`

## 8. Troubleshooting

### Common Issues:

1. **"PlatformException(sign_in_failed)"**:
   - Check google-services.json placement
   - Verify SHA-1 fingerprint in Firebase
   - Ensure package name matches

2. **"Google sign-in was cancelled"**:
   - Normal behavior when user cancels
   - No action needed

3. **"Failed to create user profile"**:
   - Check Supabase connection
   - Verify user_profiles table exists
   - Check RLS policies

### Debug Commands:
```bash
# Check current SHA-1
cd android && ./gradlew signingReport

# Clean and rebuild
flutter clean && flutter pub get

# Run with verbose output
flutter run -v
```

## 🎉 Ready to Test!

Once you complete the Firebase and Supabase configuration, your Google Sign-In will be fully functional!

**Your SHA-1 Fingerprint**: `67:BB:ED:44:A5:EA:EF:C5:1C:BB:A9:A6:A4:B9:61:8F:D1:53:25:D5`
**Package Name**: `com.example.venuevista`
