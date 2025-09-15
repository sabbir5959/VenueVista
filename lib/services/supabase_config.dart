import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration and initialization service
class SupabaseConfig {
  static bool _initialized = false;

  /// Get the Supabase client instance
  static SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return Supabase.instance.client;
  }

  /// Initialize Supabase with environment variables
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Load environment variables
      await dotenv.load(fileName: ".env.development");

      // Initialize Supabase with network configuration
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
        authOptions: const FlutterAuthClientOptions(
          autoRefreshToken: true,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );

      _initialized = true;

      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Supabase: $e');
      // Don't rethrow, allow app to continue with limited functionality
      print('⚠️ App will continue with limited functionality');
    }
  }

  /// Check if Supabase is initialized
  static bool get isInitialized => _initialized;

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;
}
