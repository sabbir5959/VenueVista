import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Admin statistics service for overview dashboard
class AdminStatsService {
  static final SupabaseClient _client = SupabaseConfig.client;

  /// Get overview statistics for admin dashboard
  static Future<Map<String, dynamic>> getOverviewStats() async {
    try {
      // Get all stats in parallel for better performance
      final futures = await Future.wait([
        _getTotalUsers(),
        _getTotalVenues(),
        _getTotalBookings(),
        _getTotalRevenue(),
        _getTodayBookings(),
        _getActiveVenues(),
        _getPendingBookings(),
        _getRecentActivity(),
      ]);

      return {
        'totalUsers': futures[0],
        'totalVenues': futures[1],
        'totalBookings': futures[2],
        'totalRevenue': futures[3],
        'todayBookings': futures[4],
        'activeVenues': futures[5],
        'pendingBookings': futures[6],
        'recentActivity': futures[7],
      };
    } catch (e) {
      throw Exception('Failed to fetch overview stats: $e');
    }
  }

  /// Get total number of users
  static Future<int> _getTotalUsers() async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('*')
          .eq('role', 'user'); // Only count normal users

      print('Normal users (role=user) count: ${response.length}');
      print('Sample normal users: ${response.take(3).toList()}');

      return response.length;
    } catch (e) {
      print('Error fetching normal users: $e');
      return 0;
    }
  }

  /// Get total number of venues
  static Future<int> _getTotalVenues() async {
    try {
      final response = await _client.from('venues').select('*');

      print('Total venues query response: ${response.length}');

      return response.length;
    } catch (e) {
      print('Error fetching venues: $e');
      return 0;
    }
  }

  /// Get total number of bookings
  static Future<int> _getTotalBookings() async {
    try {
      final response = await _client.from('bookings').select('*');

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get total revenue from payments (net after refunds)
  static Future<double> _getTotalRevenue() async {
    try {
      // Get all completed payments - using payment_id to identify refunds
      final response = await _client
          .from('payments')
          .select('amount, payment_id')
          .eq('payment_status', 'completed');

      if (response.isEmpty) return 0.0;

      double totalReceived = 0.0;
      double totalRefunded = 0.0;

      for (final payment in response) {
        final amount = (payment['amount'] as num).toDouble();
        final paymentId = payment['payment_id'] as String?;

        // Check if this is a refund payment (payment_id starts with "REF")
        if (paymentId != null && paymentId.startsWith('REF')) {
          totalRefunded += amount;
        } else {
          // Regular payment from users
          totalReceived += amount;
        }
      }

      // Return net revenue (received - refunded)
      return totalReceived - totalRefunded;
    } catch (e) {
      print('Error calculating total revenue: $e');
      return 0.0;
    }
  }

  /// Get today's bookings count
  static Future<int> _getTodayBookings() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _client
          .from('bookings')
          .select('*')
          .eq('booking_date', today);

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get number of active venues
  static Future<int> _getActiveVenues() async {
    try {
      final response = await _client
          .from('venues')
          .select('*')
          .eq('status', 'active');

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get number of pending bookings (if you add booking status)
  static Future<int> _getPendingBookings() async {
    try {
      // For now, return 0 since booking status is not in the schema
      // You can modify this when you add booking status
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get recent activity for dashboard
  static Future<List<Map<String, dynamic>>> _getRecentActivity() async {
    try {
      List<Map<String, dynamic>> activity = [];

      // Get recent bookings with user and venue info
      try {
        final bookings = await _client
            .from('bookings')
            .select('''
              *,
              user_profiles!user_id(full_name, email),
              venues!venue_id(name, area)
            ''')
            .order('created_at', ascending: false)
            .limit(5);

        print('Bookings fetched: ${bookings.length}');

        // Add booking activities
        for (final booking in bookings) {
          if (booking['user_profiles'] != null && booking['venues'] != null) {
            activity.add({
              'type': 'booking',
              'title': 'New Booking',
              'description':
                  '${booking['user_profiles']['full_name']} booked ${booking['venues']['name']}',
              'time': booking['created_at'],
              'icon': 'calendar',
              'color': 'success',
            });
          }
        }
      } catch (e) {
        print('Error fetching bookings: $e');
      }

      // Get recent venue registrations
      try {
        final newVenues = await _client
            .from('venues')
            .select('''
              *,
              user_profiles!owner_id(full_name, email)
            ''')
            .order('created_at', ascending: false)
            .limit(3);

        print('New venues fetched: ${newVenues.length}');

        // Add venue activities
        for (final venue in newVenues) {
          if (venue['user_profiles'] != null) {
            activity.add({
              'type': 'venue',
              'title': 'New Venue Added',
              'description':
                  '${venue['user_profiles']['full_name']} added ${venue['name']}',
              'time': venue['created_at'],
              'icon': 'stadium',
              'color': 'primary',
            });
          }
        }
      } catch (e) {
        print('Error fetching venues: $e');
      }

      // Get recent user registrations
      try {
        final newUsers = await _client
            .from('user_profiles')
            .select('*')
            .neq('role', 'admin')
            .order('created_at', ascending: false)
            .limit(3);

        print('New users fetched: ${newUsers.length}');

        // Add user activities
        for (final user in newUsers) {
          activity.add({
            'type': 'user',
            'title': 'New User Registration',
            'description': '${user['full_name']} joined as ${user['role']}',
            'time': user['created_at'],
            'icon': 'person',
            'color': 'info',
          });
        }
      } catch (e) {
        print('Error fetching users: $e');
      }

      // Sort by time and return top 10
      activity.sort(
        (a, b) =>
            DateTime.parse(b['time']).compareTo(DateTime.parse(a['time'])),
      );

      print('Total activity items: ${activity.length}');
      return activity.take(10).toList();
    } catch (e) {
      print('Error in _getRecentActivity: $e');
      return [];
    }
  }

  /// Get monthly stats for charts
  static Future<Map<String, dynamic>> getMonthlyStats() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      // Get monthly bookings
      final monthlyBookings = await _client
          .from('bookings')
          .select('booking_date')
          .gte('booking_date', startOfMonth.toIso8601String().split('T')[0])
          .lte('booking_date', endOfMonth.toIso8601String().split('T')[0]);

      // Get monthly revenue (net after refunds)
      final monthlyPayments = await _client
          .from('payments')
          .select('amount, created_at, payment_id')
          .eq('payment_status', 'completed')
          .gte('created_at', startOfMonth.toIso8601String())
          .lte('created_at', endOfMonth.toIso8601String());

      double monthlyReceived = 0.0;
      double monthlyRefunded = 0.0;

      for (final payment in monthlyPayments) {
        final amount = (payment['amount'] as num).toDouble();
        final paymentId = payment['payment_id'] as String?;

        // Check if this is a refund payment (payment_id starts with "REF")
        if (paymentId != null && paymentId.startsWith('REF')) {
          monthlyRefunded += amount;
        } else {
          // Regular payment from users
          monthlyReceived += amount;
        }
      }

      double monthlyRevenue = monthlyReceived - monthlyRefunded;

      return {
        'monthlyBookings': monthlyBookings.length,
        'monthlyRevenue': monthlyRevenue,
        'bookingGrowth': await _calculateGrowthRate('bookings'),
        'revenueGrowth': await _calculateGrowthRate('revenue'),
      };
    } catch (e) {
      return {
        'monthlyBookings': 0,
        'monthlyRevenue': 0.0,
        'bookingGrowth': 0.0,
        'revenueGrowth': 0.0,
      };
    }
  }

  /// Calculate growth rate compared to previous period
  static Future<double> _calculateGrowthRate(String type) async {
    try {
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 1);
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      final endLastMonth = DateTime(now.year, now.month, 0);

      if (type == 'bookings') {
        final thisMonthBookings = await _client
            .from('bookings')
            .select('*')
            .gte('booking_date', thisMonth.toIso8601String().split('T')[0]);

        final lastMonthBookings = await _client
            .from('bookings')
            .select('*')
            .gte('booking_date', lastMonth.toIso8601String().split('T')[0])
            .lte('booking_date', endLastMonth.toIso8601String().split('T')[0]);

        final thisCount = thisMonthBookings.length;
        final lastCount = lastMonthBookings.length;

        if (lastCount == 0) return thisCount > 0 ? 100.0 : 0.0;
        return ((thisCount - lastCount) / lastCount) * 100;
      }

      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get venue distribution by area
  static Future<Map<String, int>> getVenueDistribution() async {
    try {
      final response = await _client
          .from('venues')
          .select('area')
          .eq('status', 'active');

      Map<String, int> distribution = {};
      for (final venue in response) {
        final area = venue['area'] ?? 'Unknown';
        distribution[area] = (distribution[area] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      return {};
    }
  }

  /// Get user role distribution
  static Future<Map<String, int>> getUserRoleDistribution() async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('role')
          .neq('role', 'admin');

      Map<String, int> distribution = {};
      for (final user in response) {
        final role = user['role'] ?? 'user';
        distribution[role] = (distribution[role] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      return {};
    }
  }
}
