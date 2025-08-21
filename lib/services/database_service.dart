import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Database service for handling all database operations
class DatabaseService {
  static final SupabaseClient _client = SupabaseConfig.client;

  /// Get user profile by ID
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response =
          await _client
              .from('user_profiles')
              .select('*')
              .eq('id', userId)
              .single();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _client
          .from('user_profiles')
          .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Create user profile (usually called from database trigger)
  static Future<void> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phone,
    String role = 'user',
  }) async {
    try {
      await _client.from('user_profiles').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'role': role,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user has specific role
  static Future<bool> hasRole(String userId, String role) async {
    try {
      final profile = await getUserProfile(userId);
      return profile['role'] == role;
    } catch (e) {
      return false;
    }
  }

  /// Get all users (admin only)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('*')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user profile
  static Future<void> deleteUserProfile(String userId) async {
    try {
      await _client.from('user_profiles').delete().eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }
}
