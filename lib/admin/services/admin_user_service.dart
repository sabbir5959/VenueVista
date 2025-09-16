import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_config.dart';

/// Admin-specific user management service
class AdminUserService {
  static final SupabaseClient _client = SupabaseConfig.client;

  /// Get all users with pagination and filtering for admin panel
  static Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 8,
    String? searchQuery,
    String? statusFilter,
  }) async {
    try {
      final allUsers = await _client
          .from('user_profiles')
          .select('*')
          .eq('role', 'user')
          .order('created_at', ascending: false);

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

      if (statusFilter != null && statusFilter != 'All') {
        filteredUsers =
            filteredUsers.where((user) {
              final userStatus =
                  (user['status'] ?? 'active').toString().toLowerCase();
              return userStatus == statusFilter.toLowerCase();
            }).toList();
      }

      final totalCount = filteredUsers.length;

      final offset = (page - 1) * limit;
      final endIndex = offset + limit;
      final paginatedUsers = filteredUsers.sublist(
        offset,
        endIndex > filteredUsers.length ? filteredUsers.length : endIndex,
      );

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

  /// Get user details by ID for admin panel
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

  /// Delete a user from admin panel
  static Future<void> deleteUser(String userId) async {
    try {
      print('🔄 Deleting user: $userId');

      final user =
          await _client
              .from('user_profiles')
              .select('full_name')
              .eq('id', userId)
              .single();

      print('✅ Found user: ${user['full_name']}');

      await _client.from('user_profiles').delete().eq('id', userId);

      print('✅ User deleted successfully');
    } catch (e) {
      print('❌ Error deleting user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Update user status (admin only)
  static Future<void> updateUserStatus(String userId, String status) async {
    try {
      print('🔄 Updating user status: $userId to $status');

      await _client
          .from('user_profiles')
          .update({'status': status})
          .eq('id', userId);

      print('✅ User status updated successfully');
    } catch (e) {
      print('❌ Error updating user status: $e');
      throw Exception('Failed to update user status: $e');
    }
  }

  /// Ban/Unban user (admin only)
  static Future<void> toggleUserBan(String userId, bool isBanned) async {
    try {
      print('🔄 ${isBanned ? 'Banning' : 'Unbanning'} user: $userId');

      final status = isBanned ? 'banned' : 'active';
      await _client
          .from('user_profiles')
          .update({'status': status})
          .eq('id', userId);

      print('✅ User ${isBanned ? 'banned' : 'unbanned'} successfully');
    } catch (e) {
      print('❌ Error ${isBanned ? 'banning' : 'unbanning'} user: $e');
      throw Exception('Failed to ${isBanned ? 'ban' : 'unban'} user: $e');
    }
  }

  /// Get user statistics for admin dashboard
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      print('🔄 Fetching user statistics...');

      final totalUsers = await _client
          .from('user_profiles')
          .select('id')
          .eq('role', 'user');

      final activeUsers = await _client
          .from('user_profiles')
          .select('id')
          .eq('role', 'user')
          .eq('status', 'active');

      final inactiveUsers = await _client
          .from('user_profiles')
          .select('id')
          .eq('role', 'user')
          .eq('status', 'inactive');

      final bannedUsers = await _client
          .from('user_profiles')
          .select('id')
          .eq('role', 'user')
          .eq('status', 'banned');

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
        'bannedUsers': bannedUsers.length,
        'newUsersThisMonth': newUsersThisMonth.length,
      };
    } catch (e) {
      print('❌ Error fetching user statistics: $e');
      return {
        'totalUsers': 0,
        'activeUsers': 0,
        'inactiveUsers': 0,
        'bannedUsers': 0,
        'newUsersThisMonth': 0,
      };
    }
  }

  /// Get recent user activity for admin dashboard
  static Future<List<Map<String, dynamic>>> getRecentUserActivity({
    int limit = 10,
  }) async {
    try {
      print('🔄 Fetching recent user activity...');

      final recentUsers = await _client
          .from('user_profiles')
          .select('id, full_name, email, created_at, status')
          .eq('role', 'user')
          .order('created_at', ascending: false)
          .limit(limit);

      final activities =
          recentUsers.map((user) {
            return {
              'id': user['id'],
              'title': 'New User Registration',
              'description':
                  '${user['full_name'] ?? 'Unknown'} joined VenueVista',
              'time': user['created_at'],
              'icon': 'person',
              'color': 'success',
              'user_email': user['email'],
              'user_status': user['status'],
            };
          }).toList();

      print('✅ Recent user activity fetched successfully');
      return activities;
    } catch (e) {
      print('❌ Error fetching recent user activity: $e');
      return [];
    }
  }

  /// Format user data for admin UI
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

  /// Format status for admin display
  static String _formatStatus(String? status) {
    if (status == null) return 'Active';
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'banned':
        return 'Banned';
      case 'suspended':
        return 'Suspended';
      default:
        return 'Active';
    }
  }

  /// Format date for admin display
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

  /// Search users by query (admin specific)
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      print('🔄 Searching users with query: $query');

      final users = await _client
          .from('user_profiles')
          .select('*')
          .eq('role', 'user')
          .or(
            'full_name.ilike.%$query%,email.ilike.%$query%,phone.ilike.%$query%',
          )
          .limit(20);

      print('✅ User search completed');
      return users.map((user) => _formatUserData(user)).toList();
    } catch (e) {
      print('❌ Error searching users: $e');
      return [];
    }
  }

  /// Get users by status (admin filtering)
  static Future<List<Map<String, dynamic>>> getUsersByStatus(
    String status,
  ) async {
    try {
      print('🔄 Fetching users by status: $status');

      final users = await _client
          .from('user_profiles')
          .select('*')
          .eq('role', 'user')
          .eq('status', status.toLowerCase())
          .order('created_at', ascending: false);

      print('✅ Users by status fetched successfully');
      return users.map((user) => _formatUserData(user)).toList();
    } catch (e) {
      print('❌ Error fetching users by status: $e');
      return [];
    }
  }
}
