import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class BookingService {
  /// Get bookings for a specific venue and date (for slot marking)
  static Future<List<Map<String, dynamic>>> getBookingsForVenueAndDate(
    String venueId,
    DateTime date,
  ) async {
    try {
      final bookingDate =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _client
          .from('bookings')
          .select('start_time, end_time')
          .eq('venue_id', venueId)
          .eq('booking_date', bookingDate);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching bookings for venue and date: $e');
      return [];
    }
  }

  static final _client = SupabaseConfig.client;

  /// Create a new booking
  static Future<String?> createBooking({
    required String userId,
    required String venueId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    required double totalAmount,
  }) async {
    try {
      // Generate unique booking ID
      final bookingId = 'BK_${DateTime.now().millisecondsSinceEpoch}';

      print('🏃 Creating booking record...');
      print('   Booking ID: $bookingId');
      print('   User ID: $userId');
      print('   Venue ID: $venueId');
      print('   Date: $bookingDate');
      print('   Start Time: $startTime');
      print('   End Time: $endTime');

      // Calculate duration in hours
      final start = DateTime.parse('2023-01-01 $startTime:00');
      final end = DateTime.parse('2023-01-01 $endTime:00');
      final duration = end.difference(start).inMinutes / 60.0;
      print('   Duration: $duration hours');

      final response =
          await _client
              .from('bookings')
              .insert({
                'booking_id': bookingId,
                'user_id': userId,
                'venue_id': venueId,
                'booking_date': bookingDate,
                'start_time': startTime,
                'end_time': endTime,
                'duration_hours': duration,
                // Note: total_amount and status will be added by the SQL migration
              })
              .select()
              .single();

      final id = response['id'] as String;
      print('✅ Booking created successfully: $id');
      return id;
    } catch (e) {
      print('❌ Error creating booking: $e');
      print('❌ Error details: ${e.toString()}');
      return null;
    }
  }

  /// Get user's bookings
  static Future<List<Map<String, dynamic>>> getUserBookings(
    String userId,
  ) async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            *,
            venues:venue_id (
              id,
              name,
              location,
              price_per_hour,
              image_urls
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('✅ User bookings fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching user bookings: $e');
      return [];
    }
  }

  /// Get booking by ID
  static Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    try {
      final response =
          await _client
              .from('bookings')
              .select('''
            *,
            venues:venue_id (
              id,
              name,
              location,
              price_per_hour,
              image_urls,
              owner_id
            ),
            user_profiles:user_id (
              id,
              name,
              email,
              phone
            )
          ''')
              .eq('id', bookingId)
              .single();

      print('✅ Booking details fetched for ID: $bookingId');
      return response;
    } catch (e) {
      print('❌ Error fetching booking details: $e');
      return null;
    }
  }

  /// Update booking status
  static Future<bool> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      await _client
          .from('bookings')
          .update({'status': status})
          .eq('id', bookingId);

      print('✅ Booking status updated: $bookingId -> $status');
      return true;
    } catch (e) {
      print('❌ Error updating booking status: $e');
      return false;
    }
  }

  /// Cancel booking
  static Future<bool> cancelBooking(String bookingId) async {
    try {
      await _client
          .from('bookings')
          .update({
            'status': 'cancelled',
            'cancelled_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      print('✅ Booking cancelled: $bookingId');
      return true;
    } catch (e) {
      print('❌ Error cancelling booking: $e');
      return false;
    }
  }

  /// Get venue's bookings (for venue owners)
  static Future<List<Map<String, dynamic>>> getVenueBookings(
    String venueId,
  ) async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            *,
            user_profiles:user_id (
              id,
              name,
              email,
              phone
            )
          ''')
          .eq('venue_id', venueId)
          .order('booking_date', ascending: true);

      print('✅ Venue bookings fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching venue bookings: $e');
      return [];
    }
  }

  /// Check for booking conflicts
  static Future<bool> hasBookingConflict({
    required String venueId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    String? excludeBookingId,
  }) async {
    try {
      var query = _client
          .from('bookings')
          .select('id')
          .eq('venue_id', venueId)
          .eq('booking_date', bookingDate)
          .neq('status', 'cancelled');

      // Exclude current booking if updating
      if (excludeBookingId != null) {
        query = query.neq('id', excludeBookingId);
      }

      final response = await query;

      // Check for time conflicts
      // This is a simplified conflict check
      // In a real app, you'd need more sophisticated time overlap detection
      // For now, we'll assume no conflicts for demo purposes
      final hasConflicts = response.isNotEmpty;

      print(
        '✅ Booking conflict check completed - Found ${response.length} potential conflicts',
      );
      return hasConflicts; // Return true if there are any bookings in the same date
    } catch (e) {
      print('❌ Error checking booking conflicts: $e');
      return true; // Assume conflict on error for safety
    }
  }

  /// Get bookings for a specific date range
  static Future<List<Map<String, dynamic>>> getBookingsInDateRange({
    required String venueId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            *,
            user_profiles:user_id (
              id,
              name,
              email,
              phone
            )
          ''')
          .eq('venue_id', venueId)
          .gte('booking_date', startDate)
          .lte('booking_date', endDate)
          .neq('status', 'cancelled')
          .order('booking_date', ascending: true)
          .order('start_time', ascending: true);

      print('✅ Bookings in date range fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching bookings in date range: $e');
      return [];
    }
  }
}
