import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// User management service for admin operations
class UserService {
  static final SupabaseClient _client = SupabaseConfig.client;

  /// Get all users with pagination and filtering
  static Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 8,
    String? searchQuery,
    String? statusFilter,
  }) async {
    try {
      print('🔄 Fetching users - Page: $page, Limit: $limit');

      // Simple approach - get all data and filter in code
      final allUsers = await _client
          .from('user_profiles')
          .select('*')
          .eq('role', 'user')
          .order('created_at', ascending: false);

      print('✅ Fetched ${allUsers.length} total users from database');

      // Apply search filter
      List<Map<String, dynamic>> filteredUsers = allUsers;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        filteredUsers =
            allUsers.where((user) {
              final name = (user['full_name'] ?? '').toString().toLowerCase();
              final email = (user['email'] ?? '').toString().toLowerCase();
              final phone = (user['phone'] ?? '').toString().toLowerCase();
              return name.contains(searchQuery.toLowerCase()) ||
                  email.contains(searchQuery.toLowerCase()) ||
                  phone.contains(searchQuery.toLowerCase());
            }).toList();
      }

      // Apply status filter
      if (statusFilter != null && statusFilter != 'All') {
        filteredUsers =
            filteredUsers.where((user) {
              final userStatus =
                  (user['status'] ?? 'active').toString().toLowerCase();
              return userStatus == statusFilter.toLowerCase();
            }).toList();
      }

      final totalCount = filteredUsers.length;

      // Apply pagination
      final offset = (page - 1) * limit;
      final endIndex = offset + limit;
      final paginatedUsers = filteredUsers.sublist(
        offset,
        endIndex > filteredUsers.length ? filteredUsers.length : endIndex,
      );

      print('✅ Fetched ${paginatedUsers.length} users, Total: $totalCount');

      return {
        'users': paginatedUsers.map((user) => _formatUserData(user)).toList(),
        'totalCount': totalCount,
        'currentPage': page,
        'totalPages': (totalCount / limit).ceil(),
        'hasNext': page * limit < totalCount,
        'hasPrevious': page > 1,
      };
    } catch (e) {
      print('❌ Error fetching users: $e');
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Get user details by ID
  static Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      print('🔄 Fetching user details for ID: $userId');

      final user =
          await _client
              .from('user_profiles')
              .select('*')
              .eq('id', userId)
              .single();

      print('✅ User details fetched successfully');
      return _formatUserData(user);
    } catch (e) {
      print('❌ Error fetching user details: $e');
      throw Exception('Failed to fetch user details: $e');
    }
  }

  /// Delete a user
  static Future<void> deleteUser(String userId) async {
    try {
      print('🔄 Deleting user: $userId');

      // Check if user exists
      final user =
          await _client
              .from('user_profiles')
              .select('full_name')
              .eq('id', userId)
              .single();

      // Delete user profile
      await _client.from('user_profiles').delete().eq('id', userId);

      print('✅ User ${user['full_name']} deleted successfully');
    } catch (e) {
      print('❌ Error deleting user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Update user status
  static Future<void> updateUserStatus(String userId, String status) async {
    try {
      print('🔄 Updating user status: $userId -> $status');

      await _client
          .from('user_profiles')
          .update({'status': status.toLowerCase()})
          .eq('id', userId);

      print('✅ User status updated successfully');
    } catch (e) {
      print('❌ Error updating user status: $e');
      throw Exception('Failed to update user status: $e');
    }
  }

  /// Format user data for UI
  static Map<String, dynamic> _formatUserData(Map<String, dynamic> user) {
    return {
      'id': user['id'],
      'name': user['full_name'] ?? 'N/A',
      'email': user['email'] ?? 'N/A',
      'phone': user['phone'] ?? 'N/A',
      'status': _formatStatus(user['status']),
      'joinDate': _formatDate(user['created_at']),
      'role': user['role'] ?? 'user',
      'city': user['city'] ?? 'N/A',
      'address': user['address'] ?? 'N/A',
      'companyName': user['company_name'] ?? 'N/A',
      'avatarUrl': user['avatar_url'],
    };
  }

  /// Format status for display
  static String _formatStatus(String? status) {
    if (status == null) return 'Active';
    return status.toLowerCase() == 'active' ? 'Active' : 'Inactive';
  }

  /// Format date for display
  static String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  /// Get user statistics
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      print('🔄 Fetching user statistics...');

      // Get total users count
      final totalUsers = await _client
          .from('user_profiles')
          .select('id')
          .eq('role', 'user');

      // Get active users count
      final activeUsers = await _client
          .from('user_profiles')
          .select('id')
          .eq('role', 'user')
          .eq('status', 'active');

      // Get inactive users count
      final inactiveUsers = await _client
          .from('user_profiles')
          .select('id')
          .eq('role', 'user')
          .eq('status', 'inactive');

      // Get new users this month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final newUsersThisMonth = await _client
          .from('user_profiles')
          .select('id')
          .eq('role', 'user')
          .gte('created_at', startOfMonth.toIso8601String());

      print('✅ User statistics fetched successfully');

      return {
        'totalUsers': totalUsers.length,
        'activeUsers': activeUsers.length,
        'inactiveUsers': inactiveUsers.length,
        'newUsersThisMonth': newUsersThisMonth.length,
      };
    } catch (e) {
      print('❌ Error fetching user statistics: $e');
      return {
        'totalUsers': 0,
        'activeUsers': 0,
        'inactiveUsers': 0,
        'newUsersThisMonth': 0,
      };
    }
  }
}
