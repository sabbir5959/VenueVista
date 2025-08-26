import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_config.dart';

/// Authentication service for handling all auth operations
class AuthService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Android OAuth Client ID for deep linking
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '696710869192-b3lh9icra4971vsr9k1ntib61fugd6b1.apps.googleusercontent.com',
  );

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Clear logout flag on successful login
      if (response.user != null) {
        await _clearLogoutFlag();
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Clear logout flag to enable auto-login
  static Future<void> _clearLogoutFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_out', false);
    } catch (e) {
      print('Error clearing logout flag: $e');
    }
  }

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'user',
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': role},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with Google using Supabase OAuth
  static Future<bool> signInWithGoogle({
    bool forceAccountSelection = false,
  }) async {
    try {
      print('🔄 Starting Supabase Google OAuth...');

      // Build query parameters for account selection
      Map<String, String>? queryParams;
      if (forceAccountSelection) {
        queryParams = {
          'prompt': 'select_account', // Forces Google to show account selection
        };
      }

      // Use Supabase OAuth with deep link redirect
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'venuevista://auth-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
        queryParams: queryParams,
      );

      print('✅ Supabase OAuth initiated: $response');

      // Auth state will be handled by the calling screen's listener
      return response;
    } catch (e) {
      print('❌ Supabase Google OAuth Error: $e');
      rethrow;
    }
  }

  /// Handle OAuth code manually (for fallback)
  static Future<bool> handleOAuthCode(String code) async {
    try {
      print('🔄 Processing OAuth code: $code');

      // Exchange code for session
      await _client.auth.exchangeCodeForSession(code);

      final user = currentUser;
      if (user != null) {
        print('✅ OAuth code exchange successful! User: ${user.email}');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ OAuth code exchange failed: $e');
      return false;
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      // Clear saved credentials when signing out
      await _clearSavedCredentials();

      // Sign out from Google first
      await _googleSignIn.signOut();
      // Then sign out from Supabase
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Clear saved login credentials
  static Future<void> _clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.remove('saved_role');
      await prefs.setBool('remember_me', false);
      await prefs.setBool('is_logged_out', true); // Set logout flag
    } catch (e) {
      print('Error clearing saved credentials: $e');
    }
  }

  /// Get current user
  static User? get currentUser => _client.auth.currentUser;

  /// Get Supabase client for advanced operations
  static SupabaseClient get client => _client;

  /// Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  /// Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  /// Update password
  static Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;
}
