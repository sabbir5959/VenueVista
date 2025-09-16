import 'package:supabase_flutter/supabase_flutter.dart';

class AdminVenuePaymentsService {
  static final _supabase = Supabase.instance.client;

  static Future<int> getPendingCommissionCount() async {
    try {
      final commissions = await getVenueOwnerCommissions();

      int pendingCount = 0;
      for (var commission in commissions) {
        if (commission['status'] == 'pending') {
          pendingCount++;
        }
      }

      return pendingCount;
    } catch (e) {
      print('Error getting pending commission count: $e');
      return 0;
    }
  }

  static Future<List<Map<String, dynamic>>> getVenueOwnerCommissions({
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      // First, get all venues with owner details
      final venuesResponse = await _supabase.from('venues').select('''
            id, 
            name, 
            venue_type, 
            owner_id,
            user_profiles!venues_owner_id_fkey(
              id,
              full_name,
              email,
              phone
            )
          ''');

      final venuesData = venuesResponse as List<dynamic>;
      if (venuesData.isEmpty) return [];

      // Get commission records (using actual column names)
      var commissionQuery = _supabase.from('owner_record_cash').select('''
            id,
            owner_name,
            cash_amount,
            status,
            contact,
            description,
            created_at,
            events
          ''');

      if (status != null && status.isNotEmpty && status != 'all') {
        if (status == 'paid') {
          commissionQuery = commissionQuery.eq('status', 'successful');
        } else {
          commissionQuery = commissionQuery.eq('status', status);
        }
      }

      final commissionResponse = await commissionQuery;
      final commissionsData = commissionResponse as List<dynamic>;

      // Create a map of owner names to commission records
      final Map<String, List<Map<String, dynamic>>> commissionsByOwner = {};
      for (final commission in commissionsData) {
        final ownerName = commission['owner_name']?.toString() ?? '';
        if (ownerName.isNotEmpty) {
          if (!commissionsByOwner.containsKey(ownerName)) {
            commissionsByOwner[ownerName] = [];
          }
          commissionsByOwner[ownerName]!.add(
            Map<String, dynamic>.from(commission),
          );
        }
      }

      // Combine venue data with commission data and calculate real bookings/payments
      final List<Map<String, dynamic>> result = [];

      for (final venue in venuesData) {
        final venueId = venue['id'].toString();
        final userProfile = venue['user_profiles'];
        final ownerName =
            userProfile != null ? userProfile['full_name'] ?? '' : '';

        // Get real booking data for this venue
        final bookingStats = await _getVenueBookingStats(venueId);

        // Check if this owner has commission records
        final ownerCommissions = commissionsByOwner[ownerName] ?? [];

        if (ownerCommissions.isNotEmpty) {
          // Owner has commission records
          for (final commission in ownerCommissions) {
            final cashAmount =
                double.tryParse(commission['cash_amount']?.toString() ?? '0') ??
                0.0;
            result.add({
              'id': commission['id'],
              'venue_id': venue['id'],
              'venue_name': venue['name'] ?? 'Unknown Venue',
              'venue_type': _mapVenueType(venue['venue_type'] ?? ''),
              'owner_id': venue['owner_id'],
              'owner_name': ownerName,
              'owner_email':
                  userProfile != null ? userProfile['email'] ?? '' : '',
              'owner_phone':
                  userProfile != null ? userProfile['phone'] ?? '' : '',
              'amount': cashAmount,
              'status':
                  commission['status'] == 'successful'
                      ? 'paid'
                      : commission['status'] ?? 'pending',
              'payment_date': commission['created_at'],
              'created_at': commission['created_at'],
              'description': commission['description'],
              'contact': commission['contact'],
              'events': commission['events'],
              // Real booking data
              'totalBookings': bookingStats['totalBookings'],
              'normalBookings': bookingStats['normalBookings'],
              'tournamentBookings': bookingStats['tournamentBookings'],
              'totalBookingAmount': bookingStats['totalBookingAmount'],
              'normalBookingAmount': bookingStats['normalBookingAmount'],
              'tournamentBookingAmount':
                  bookingStats['tournamentBookingAmount'],
              'venueType': _mapVenueType(venue['venue_type'] ?? ''),
            });
          }
        } else {
          // Owner without commission records - show as pending with real booking data
          if (status == null ||
              status.isEmpty ||
              status == 'all' ||
              status == 'pending') {
            // Calculate commission based on total bookings (fixed amount per booking)
            final commissionAmount =
                bookingStats['totalBookings'] * 100.0; // 100 taka per booking

            result.add({
              'id': null,
              'venue_id': venue['id'],
              'venue_name': venue['name'] ?? 'Unknown Venue',
              'venue_type': _mapVenueType(venue['venue_type'] ?? ''),
              'owner_id': venue['owner_id'],
              'owner_name': ownerName,
              'owner_email':
                  userProfile != null ? userProfile['email'] ?? '' : '',
              'owner_phone':
                  userProfile != null ? userProfile['phone'] ?? '' : '',
              'amount': commissionAmount,
              'status': 'pending',
              'payment_date': null,
              'created_at': null,
              'description': 'No payment record for this month',
              'contact': userProfile != null ? userProfile['phone'] ?? '' : '',
              'events': '',
              // Real booking data
              'totalBookings': bookingStats['totalBookings'],
              'normalBookings': bookingStats['normalBookings'],
              'tournamentBookings': bookingStats['tournamentBookings'],
              'totalBookingAmount': bookingStats['totalBookingAmount'],
              'normalBookingAmount': bookingStats['normalBookingAmount'],
              'tournamentBookingAmount':
                  bookingStats['tournamentBookingAmount'],
              'venueType': _mapVenueType(venue['venue_type'] ?? ''),
            });
          }
        }
      }

      // Apply pagination if specified
      if (offset != null && offset > 0) {
        if (offset >= result.length) return [];
        final endIndex =
            limit != null
                ? (offset + limit).clamp(0, result.length)
                : result.length;
        return result.sublist(offset, endIndex);
      } else if (limit != null && limit > 0) {
        return result.take(limit).toList();
      }

      return result;
    } catch (e) {
      print('Error getting venue owner commissions: $e');
      return [];
    }
  }

  // Helper method to get real booking stats for a venue
  static Future<Map<String, dynamic>> _getVenueBookingStats(
    String venueId,
  ) async {
    try {
      // Get normal bookings from bookings table with payment amounts
      final normalBookingsResponse = await _supabase
          .from('bookings')
          .select('id, booking_id')
          .eq('venue_id', venueId);

      final normalBookings = normalBookingsResponse as List<dynamic>;
      final normalBookingCount = normalBookings.length;

      // Calculate normal booking amount from payments table
      double normalBookingAmount = 0.0;
      for (var booking in normalBookings) {
        final paymentsResponse = await _supabase
            .from('payments')
            .select('amount')
            .eq('booking_id', booking['id'])
            .eq('payment_status', 'completed');

        final payments = paymentsResponse as List<dynamic>;
        for (var payment in payments) {
          normalBookingAmount += (payment['amount'] as num).toDouble();
        }
      }

      // Get tournament bookings through tournament_registrations with amounts
      final tournamentResponse = await _supabase
          .from('tournament_registrations')
          .select('''
            id,
            registration_fee,
            tournaments!inner(
              venue_id
            )
          ''')
          .eq('tournaments.venue_id', venueId);

      final tournamentRegistrations = tournamentResponse as List<dynamic>;
      int tournamentBookingCount = tournamentRegistrations.length;

      // Calculate tournament booking amount
      double tournamentBookingAmount = 0.0;
      for (var registration in tournamentRegistrations) {
        tournamentBookingAmount +=
            (registration['registration_fee'] as num? ?? 0).toDouble();
      }

      double totalBookingAmount = normalBookingAmount + tournamentBookingAmount;

      return {
        'totalBookings': normalBookingCount + tournamentBookingCount,
        'normalBookings': normalBookingCount,
        'tournamentBookings': tournamentBookingCount,
        'totalBookingAmount': totalBookingAmount,
        'normalBookingAmount': normalBookingAmount,
        'tournamentBookingAmount': tournamentBookingAmount,
      };
    } catch (e) {
      print('Error getting venue booking stats: $e');
      return {
        'totalBookings': 0,
        'normalBookings': 0,
        'tournamentBookings': 0,
        'totalBookingAmount': 0.0,
        'normalBookingAmount': 0.0,
        'tournamentBookingAmount': 0.0,
      };
    }
  }

  // Helper method to map venue types
  static String _mapVenueType(String venueType) {
    switch (venueType.toLowerCase()) {
      case 'football':
      case 'football_field':
      case 'football field':
        return 'Football Field';
      case 'cricket':
      case 'cricket_ground':
      case 'cricket ground':
        return 'Cricket Ground';
      case 'basketball':
      case 'basketball_court':
      case 'basketball court':
        return 'Basketball Court';
      case 'badminton':
      case 'badminton_court':
      case 'badminton court':
        return 'Badminton Court';
      case 'multi-purpose':
      case 'multipurpose':
      case 'multi_purpose':
        return 'Multi-purpose';
      default:
        return 'Football Field'; // Default to Football Field
    }
  }

  static Future<Map<String, dynamic>> getTotalStats({String? status}) async {
    try {
      final commissions = await getVenueOwnerCommissions(status: status);

      double totalAmount = 0.0;
      int totalBookings = 0;
      int paidCount = 0;
      int pendingCount = 0;

      for (final commission in commissions) {
        final commissionStatus = commission['status']?.toString() ?? 'pending';
        final amount = commission['amount']?.toDouble() ?? 0.0;
        final bookings = (commission['totalBookings'] ?? 0) as int;

        totalAmount += amount;
        totalBookings += bookings;

        if (commissionStatus == 'paid' || commissionStatus == 'successful') {
          paidCount++;
        } else {
          pendingCount++;
        }
      }

      return {
        'total_amount': totalAmount,
        'total_count': commissions.length,
        'paid_count': paidCount,
        'pending_count': pendingCount,
        'average_amount':
            commissions.isNotEmpty ? totalAmount / commissions.length : 0.0,
        'totalBookings': totalBookings,
      };
    } catch (e) {
      print('Error getting total stats: $e');
      return {
        'total_amount': 0.0,
        'total_count': 0,
        'paid_count': 0,
        'pending_count': 0,
        'average_amount': 0.0,
        'totalBookings': 0,
      };
    }
  }

  static Future<bool> recordCashPayment({
    required String venueId,
    required double amount,
    required int month,
    required int year,
    String? notes,
  }) async {
    try {
      // We need to get the owner name and contact from the venue
      final venueResponse =
          await _supabase
              .from('venues')
              .select('''
            owner_id,
            name,
            user_profiles!venues_owner_id_fkey(
              full_name,
              phone
            )
          ''')
              .eq('id', venueId)
              .single();

      final userProfile = venueResponse['user_profiles'];
      final ownerName =
          userProfile != null ? userProfile['full_name'] : 'Unknown Owner';
      final ownerPhone = userProfile != null ? userProfile['phone'] : '';
      final venueName = venueResponse['name'] ?? 'Unknown Venue';

      await _supabase.from('owner_record_cash').insert({
        'owner_name': ownerName,
        'cash_amount': amount.toString(),
        'status': 'paid',
        'description':
            notes ??
            'Commission payment for $venueName - Month: $month, Year: $year',
        'contact': ownerPhone ?? '',
        'events':
            'Venue: $venueName | Amount: ৳${amount.toStringAsFixed(0)} | Month: $month/$year',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error recording cash payment: $e');
      return false;
    }
  }
}
