import 'supabase_config.dart';

class BookingService {
  /// Get bookings for a specific venue and date (for slot marking)
  static Future<List<Map<String, dynamic>>> getBookingsForVenueAndDate(
    String venueId,
    DateTime date,
  ) async {
    try {
      // Format date to match database format (YYYY-MM-DD)
      final bookingDate =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      print('🔍 BookingService: Querying bookings for:');
      print('   Venue ID: "$venueId"');
      print('   Target Date: "$bookingDate"');
      print('   Input Date: ${date.toString()}');
      print('   Formatted for DB: $bookingDate');

      // First, let's see ALL bookings for this venue to debug
      final allVenueBookings = await _client
          .from('bookings')
          .select('start_time, end_time, booking_date, venue_id')
          .eq('venue_id', venueId);

      print('📋 ALL bookings for venue "$venueId":');
      for (var booking in allVenueBookings) {
        print(
          '   - Venue: "${booking['venue_id']}", Date: "${booking['booking_date']}", Time: ${booking['start_time']}-${booking['end_time']}',
        );
      }

      // Now get bookings for specific date
      final response = await _client
          .from('bookings')
          .select('start_time, end_time, booking_date, venue_id')
          .eq('venue_id', venueId)
          .eq('booking_date', bookingDate);

      print('📊 BookingService: Filtered result for "$bookingDate":');
      print(
        '   Found ${response.length} bookings matching venue "$venueId" and date "$bookingDate"',
      );
      for (var booking in response) {
        print(
          '   ✅ MATCH - Venue: "${booking['venue_id']}", Date: "${booking['booking_date']}", Time: ${booking['start_time']}-${booking['end_time']}',
        );
      }

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

  /// Get user's bookings - FORCE RELOAD
  static Future<List<Map<String, dynamic>>> getUserBookings(
    String userId,
  ) async {
    try {
      print('🔍 TESTING - Fetching bookings for user: $userId');

      final response = await _client
          .from('bookings')
          .select('''
            *,
            venues!inner(
              id,
              name,
              address,
              price_per_hour,
              image_urls
            ),
            cancellations!left(
              id,
              refund_status,
              refund_amount,
              cancelled_at,
              cancellation_reason
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('✅ User bookings fetched: ${response.length}');

      // Debug: Print each booking
      for (int i = 0; i < response.length; i++) {
        print('📋 Booking $i: ${response[i]}');
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching user bookings: $e');
      print('❌ Error details: ${e.toString()}');
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
              address,
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

  /// Cancel booking with reason and store in cancellations table
  static Future<bool> cancelBookingWithReason(
    String bookingId,
    String? cancellationReason,
  ) async {
    try {
      print('🔄 Starting booking cancellation for ID: $bookingId');
      
      // Get current user
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        print('❌ User not authenticated');
        return false;
      }

      print('👤 User authenticated: ${currentUser.id}');

      // Get booking details with venue information to calculate original amount from venue price
      print('📋 Fetching booking details with venue information...');
      final bookingResponse =
          await _client
              .from('bookings')
              .select('''
            *,
            venues!inner(
              id,
              name,
              price_per_hour
            )
          ''')
              .eq('id', bookingId)
              .eq('user_id', currentUser.id) // Ensure user owns this booking
              .maybeSingle();

      if (bookingResponse == null) {
        print('❌ Booking not found or user does not own this booking');
        return false;
      }

      print('✅ Booking found: $bookingResponse');
      
      final booking = bookingResponse;
      final venue = booking['venues'];

      // Calculate original amount based on venue's price per hour and booking duration
      final pricePerHour = (venue['price_per_hour'] ?? 0).toDouble();
      final startTime = booking['start_time'] ?? '';
      final endTime = booking['end_time'] ?? '';
      
      // Calculate hours between start and end time
      double hours = 1.0; // Default to 1 hour if calculation fails
      try {
        final start = DateTime.parse('2000-01-01 $startTime');
        final end = DateTime.parse('2000-01-01 $endTime');
        hours = end.difference(start).inMinutes / 60.0;
      } catch (e) {
        print('⚠️  Could not calculate hours, using default: $e');
      }
      
      final originalAmount = pricePerHour * hours;
      
      print('💰 Price calculation:');
      print('   Venue: ${venue['name']}');
      print('   Price per hour: ৳$pricePerHour');
      print('   Start time: $startTime');
      print('   End time: $endTime');
      print('   Hours: $hours');
      print('   Original amount: ৳$originalAmount');

      // Prepare cancellation data according to your exact requirements
      final cancellationData = {
        'booking_id': bookingId,
        'user_id': currentUser.id,
        'venue_id': booking['venue_id'],
        'venue_name': venue['name'], // Store actual venue name
        'booking_date': booking['booking_date'],
        'start_time': booking['start_time'],
        'end_time': booking['end_time'],
        'original_amount': originalAmount, // From venue price_per_hour * hours
        'cancellation_fee': 0, // Set to 0 as requested
        'refund_amount': 0, // Set to 0 as requested  
        'cancellation_reason': cancellationReason?.isNotEmpty == true ? cancellationReason : null,
        'cancelled_at': null, // Set to NULL as requested
        'refund_status': 'pending', // Set to pending as requested
        'refund_processed_at': null,
        'processed_by': null,
        'admin_notes': null, // Set to NULL as requested
      };

      print('📝 Storing cancellation data per your requirements:');
      print('   📍 Venue Name: ${venue['name']}');
      print('   💰 Original Amount: ৳$originalAmount (from venue price)');
      print('   💸 Cancellation Fee: 0');
      print('   💳 Refund Amount: 0');
      print('   ⏰ Cancelled Time: NULL');
      print('   📊 Refund Status: pending');
      print('   📝 Admin Notes: NULL');
      print('   🏢 Venue Name Current (in view): NULL');
      print('   💬 Reason: ${cancellationReason ?? 'No reason provided'}');

      // Insert into cancellations table
      print('🔄 Inserting cancellation record into database...');
      final cancellationResponse = await _client
          .from('cancellations')
          .insert(cancellationData)
          .select()
          .single();

      print('✅ Cancellation record inserted with ID: ${cancellationResponse['id']}');

      // Update booking status to cancelled
      print('🔄 Updating booking status to cancelled...');
      await _client
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId);

      print('✅ Booking status updated to cancelled');
      print('🎉 Cancellation completed successfully!');
      
      // Verify the record was stored in cancellation_summary
      print('🔍 Verifying data in cancellation_summary...');
      final summaryCheck = await _client
          .from('cancellation_summary')
          .select('*')
          .eq('booking_id', bookingId)
          .maybeSingle();
          
      if (summaryCheck != null) {
        print('✅ Data confirmed in cancellation_summary:');
        print('   Original Amount: ${summaryCheck['original_amount']}');
        print('   Cancellation Fee: ${summaryCheck['cancellation_fee']}');
        print('   Refund Amount: ${summaryCheck['refund_amount']}');
        print('   Venue Name Current: ${summaryCheck['venue_name_current']}');
        print('   Refund Status: ${summaryCheck['refund_status']}');
        print('   Admin Notes: ${summaryCheck['admin_notes']}');
      }

      return true;

    } catch (e, stackTrace) {
      print('❌ Error cancelling booking with reason: $e');
      print('📍 Stack trace: $stackTrace');

      // More detailed error information
      if (e.toString().contains('violates')) {
        print(
          '💡 Possible cause: Foreign key constraint or data validation issue',
        );
      }
      if (e.toString().contains('permission')) {
        print('💡 Possible cause: RLS policy blocking the operation');
      }
      if (e.toString().contains('null')) {
        print('💡 Possible cause: Required field is NULL');
      }

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

  // Method to query cancellation summary for debugging
  static Future<List<Map<String, dynamic>>> getCancellationSummary() async {
    try {
      final result = await _client.from('cancellation_summary').select();
      print('📊 Cancellation Summary Data: $result');
      return result;
    } catch (e) {
      print('❌ Error querying cancellation summary: $e');
      return [];
    }
  }
}
