import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Admin booking service for managing all bookings and cancellation requests
class AdminBookingService {
  static final SupabaseClient _client = SupabaseConfig.client;

  /// Get all bookings with status calculation based on booking_date
  static Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            id,
            booking_id,
            user_id,
            venue_id,
            booking_date,
            start_time,
            end_time,
            duration_hours,
            created_at,
            user_profiles!inner (
              id,
              full_name,
              email,
              phone
            ),
            venues!inner (
              id,
              name,
              address,
              city,
              price_per_hour
            )
          ''')
          .order('booking_date', ascending: false);

      // Calculate status for each booking
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      final bookingsWithStatus =
          response.map<Map<String, dynamic>>((booking) {
            // Handle null values safely
            final bookingDateStr = booking['booking_date'] as String?;
            if (bookingDateStr == null || bookingDateStr.isEmpty) {
              return {
                ...booking,
                'status': 'unknown',
                'calculated_status': 'unknown',
              };
            }

            try {
              final bookingDate = DateTime.parse(bookingDateStr);
              final bookingDateOnly = DateTime(
                bookingDate.year,
                bookingDate.month,
                bookingDate.day,
              );

              String status;
              if (bookingDateOnly.isBefore(todayDate)) {
                status = 'completed';
              } else {
                status = 'confirmed'; // Today's and future dates
              }

              return {
                ...booking,
                'status': status,
                'calculated_status': status,
              };
            } catch (e) {
              print('⚠️ Error parsing booking date ${bookingDateStr}: $e');
              return {
                ...booking,
                'status': 'unknown',
                'calculated_status': 'unknown',
              };
            }
          }).toList();

      return bookingsWithStatus;
    } catch (e) {
      print('❌ Error fetching bookings: $e');
      return [];
    }
  }

  /// Get all cancellation requests from cancellations table
  static Future<List<Map<String, dynamic>>> getAllCancellationRequests() async {
    try {
      // Get cancellations with user and booking information
      final response = await _client
          .from('cancellations')
          .select('''
            *,
            bookings!inner(
              booking_id,
              booking_date,
              start_time,
              end_time,
              duration_hours,
              user_profiles!inner(
                id,
                full_name,
                email,
                phone
              ),
              venues!inner(
                id,
                name,
                address,
                city,
                price_per_hour
              )
            )
          ''')
          .order('created_at', ascending: false);

      // Format each cancellation for display
      final formattedCancellations =
          response.map<Map<String, dynamic>>((cancellation) {
            return formatCancellationForDisplay(cancellation);
          }).toList();

      return formattedCancellations;
    } catch (e) {
      print('❌ Error fetching cancellation requests: $e');

      // Fallback to simple query if joins fail
      try {
        final simpleResponse = await _client
            .from('cancellations')
            .select('*')
            .order('created_at', ascending: false);

        return simpleResponse;
      } catch (fallbackError) {
        print('❌ Fallback cancellation query also failed: $fallbackError');
        return [];
      }
    }
  }

  /// Get booking statistics for admin dashboard
  static Future<Map<String, dynamic>> getBookingStats() async {
    try {
      final allBookings = await getAllBookings();
      final allCancellations = await getAllCancellationRequests();

      int totalBookings = allBookings.length;
      int confirmedBookings = 0;
      int completedBookings = 0;
      int cancelledBookings = allCancellations.length;
      double totalRevenue = 0.0;

      for (final booking in allBookings) {
        final status = booking['calculated_status'] ?? 'unknown';
        if (status == 'confirmed') {
          confirmedBookings++;
        } else if (status == 'completed') {
          completedBookings++;
        }

        // Calculate revenue from venue price and duration
        final venue = booking['venues'] as Map<String, dynamic>?;
        final pricePerHour = (venue?['price_per_hour'] ?? 0.0) as num;
        final durationHours = (booking['duration_hours'] ?? 0.0) as num;
        totalRevenue += pricePerHour.toDouble() * durationHours.toDouble();
      }

      return {
        'totalBookings': totalBookings,
        'confirmedBookings': confirmedBookings,
        'completedBookings': completedBookings,
        'cancelledBookings': cancelledBookings,
        'totalRevenue': totalRevenue,
        'pendingCancellations':
            allCancellations
                .where((c) => (c['refund_status'] ?? 'pending') == 'pending')
                .length,
      };
    } catch (e) {
      print('❌ Error calculating booking stats: $e');
      return {
        'totalBookings': 0,
        'confirmedBookings': 0,
        'completedBookings': 0,
        'cancelledBookings': 0,
        'totalRevenue': 0.0,
        'pendingCancellations': 0,
      };
    }
  }

  /// Get bookings filtered by status
  static Future<List<Map<String, dynamic>>> getBookingsByStatus(
    String status,
  ) async {
    try {
      final allBookings = await getAllBookings();

      if (status.toLowerCase() == 'all') {
        return allBookings;
      }

      return allBookings
          .where(
            (booking) =>
                (booking['calculated_status'] ?? 'unknown').toLowerCase() ==
                status.toLowerCase(),
          )
          .toList();
    } catch (e) {
      print('❌ Error filtering bookings by status: $e');
      return [];
    }
  }

  /// Process cancellation request (approve/reject)
  static Future<bool> processCancellationRequest(
    String cancellationId,
    String action, // 'accepted' or 'rejected'
    String? adminNotes,
  ) async {
    try {
      final adminUser = _client.auth.currentUser;
      if (adminUser == null) {
        print('❌ Admin not authenticated');
        return false;
      }

      String refundStatus;
      if (action.toLowerCase() == 'accepted') {
        refundStatus = 'accepted';
      } else if (action.toLowerCase() == 'rejected') {
        refundStatus = 'rejected';
      } else {
        print('❌ Invalid action: $action');
        return false;
      }

      await _client
          .from('cancellations')
          .update({
            'refund_status': refundStatus,
            'admin_notes': adminNotes,
            'processed_by': adminUser.id,
            'refund_processed_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', cancellationId);

      print(
        '✅ Cancellation request processed: $cancellationId -> $refundStatus',
      );
      return true;
    } catch (e) {
      print('❌ Error processing cancellation request: $e');
      return false;
    }
  }

  /// Format booking data for display
  static Map<String, dynamic> formatBookingForDisplay(
    Map<String, dynamic> booking,
  ) {
    try {
      final user = booking['user_profiles'] as Map<String, dynamic>?;
      final venue = booking['venues'] as Map<String, dynamic>?;

      final durationHours = booking['duration_hours'] ?? 0.0;
      final pricePerHour = venue?['price_per_hour'] ?? 0.0;
      final totalAmount = (pricePerHour * durationHours);

      final formatted = {
        'id': booking['id']?.toString() ?? '',
        'booking_id': booking['booking_id']?.toString() ?? 'N/A',
        'user_name': user?['full_name']?.toString() ?? 'Unknown User',
        'user_email': user?['email']?.toString() ?? 'N/A',
        'user_phone': user?['phone']?.toString() ?? 'N/A',
        'venue_name': venue?['name']?.toString() ?? 'Unknown Venue',
        'venue_address': venue?['address']?.toString() ?? 'N/A',
        'venue_city': venue?['city']?.toString() ?? 'N/A',
        'booking_date': booking['booking_date']?.toString() ?? 'TBD',
        'start_time': booking['start_time']?.toString() ?? 'TBD',
        'end_time': booking['end_time']?.toString() ?? 'TBD',
        'duration_hours': (booking['duration_hours'] ?? 0.0).toString(),
        'price_per_hour': (venue?['price_per_hour'] ?? 0.0).toString(),
        'total_amount': totalAmount.toString(),
        'status': booking['calculated_status']?.toString() ?? 'unknown',
        'created_at': booking['created_at']?.toString() ?? '',
      };

      return formatted;
    } catch (e) {
      print('❌ Error formatting booking data: $e');

      // Return safe fallback data
      return {
        'id': '',
        'booking_id': 'N/A',
        'user_name': 'Unknown User',
        'user_email': 'N/A',
        'user_phone': 'N/A',
        'venue_name': 'Unknown Venue',
        'venue_address': 'N/A',
        'venue_city': 'N/A',
        'booking_date': 'TBD',
        'start_time': 'TBD',
        'end_time': 'TBD',
        'duration_hours': '0',
        'price_per_hour': '0',
        'total_amount': '0',
        'status': 'unknown',
        'created_at': '',
      };
    }
  }

  /// Format cancellation data for display
  static Map<String, dynamic> formatCancellationForDisplay(
    Map<String, dynamic> cancellation,
  ) {
    try {
      // Extract nested booking data
      final booking = cancellation['bookings'] as Map<String, dynamic>?;
      final user = booking?['user_profiles'] as Map<String, dynamic>?;
      final venue = booking?['venues'] as Map<String, dynamic>?;

      // Safe calculation of amounts with type conversion
      double originalAmount = 0.0;
      double cancellationFee = 0.0;

      try {
        final durationHours = booking?['duration_hours'];
        final pricePerHour = venue?['price_per_hour'];
        final cancellationFeeVal = cancellation['cancellation_fee'];

        if (durationHours != null && pricePerHour != null) {
          final duration =
              durationHours is String
                  ? double.parse(durationHours)
                  : (durationHours as num).toDouble();
          final price =
              pricePerHour is String
                  ? double.parse(pricePerHour)
                  : (pricePerHour as num).toDouble();
          originalAmount = duration * price;
        }

        if (cancellationFeeVal != null) {
          cancellationFee =
              cancellationFeeVal is String
                  ? double.parse(cancellationFeeVal)
                  : (cancellationFeeVal as num).toDouble();
        }
      } catch (e) {
        // Keep default values if parsing fails
      }

      final refundAmount = originalAmount - cancellationFee;

      final formatted = {
        'id': cancellation['id']?.toString() ?? '',
        'booking_id': booking?['booking_id']?.toString() ?? 'N/A',
        'user_name': user?['full_name']?.toString() ?? 'Unknown User',
        'user_email': user?['email']?.toString() ?? 'N/A',
        'user_phone': user?['phone']?.toString() ?? 'N/A',
        'venue_name': venue?['name']?.toString() ?? 'Unknown Venue',
        'venue_address': venue?['address']?.toString() ?? 'N/A',
        'venue_city': venue?['city']?.toString() ?? 'N/A',
        'booking_date': booking?['booking_date']?.toString() ?? 'TBD',
        'start_time': booking?['start_time']?.toString() ?? 'TBD',
        'end_time': booking?['end_time']?.toString() ?? 'TBD',
        'original_amount': originalAmount.toString(),
        'cancellation_fee': cancellationFee.toString(),
        'refund_amount': refundAmount.toString(),
        'reason':
            cancellation['cancellation_reason']?.toString() ??
            'No reason provided',
        'refund_status': cancellation['refund_status']?.toString() ?? 'pending',
        'admin_notes': cancellation['admin_notes']?.toString() ?? '',
        'cancelled_at': cancellation['created_at']?.toString() ?? '',
        'status': 'cancelled', // Always cancelled for cancellation requests
        'created_at': cancellation['created_at']?.toString() ?? '',
      };

      return formatted;
    } catch (e) {
      print('❌ Error formatting cancellation data: $e');

      return {
        'id': cancellation['id']?.toString() ?? '',
        'booking_id': 'N/A',
        'user_name': 'Unknown User',
        'user_email': 'N/A',
        'user_phone': 'N/A',
        'venue_name': 'Unknown Venue',
        'venue_address': 'N/A',
        'venue_city': 'N/A',
        'booking_date': 'TBD',
        'start_time': 'TBD',
        'end_time': 'TBD',
        'original_amount': '0',
        'cancellation_fee': '0',
        'refund_amount': '0',
        'reason': 'No reason provided',
        'refund_status': 'pending',
        'admin_notes': '',
        'cancelled_at': '',
        'status': 'cancelled',
        'created_at': '',
      };
    }
  }
}
