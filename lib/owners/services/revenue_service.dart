import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/revenue_data.dart';

class RevenueService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get revenue data for the current owner by specific month and year
  Future<RevenueData> getOwnerRevenueDataByMonth(int month, int year) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('Getting revenue data for month: $month, year: $year');
      print('User ID: ${user.id}');

      // Get the owner's venue
      final venueResponse =
          await _supabase
              .from('venues')
              .select('id, name')
              .eq('owner_id', user.id)
              .single();

      final venueId = venueResponse['id'];
      final venueName = venueResponse['name'];
      print('Found venue: $venueName (ID: $venueId)');

      // Calculate date range for the specific month and year
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1);
      print(
        'Date range: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
      );

      // Get tournament revenue data for the specific month
      final tournamentData = await _getTournamentRevenue(
        venueId,
        startDate,
        endDate,
      );

      // Get booking revenue data for the specific month
      final bookingData = await _getBookingRevenue(venueId, startDate, endDate);

      // Calculate totals
      final totalTournamentRevenue = tournamentData['total_amount'] ?? 0.0;
      final totalBookingRevenue = bookingData['total_amount'] ?? 0.0;
      final totalRevenue = totalTournamentRevenue + totalBookingRevenue;
      final ownerShare = totalRevenue * 0.3; // 30% for owner

      print('=== REVENUE SUMMARY ===');
      print(
        'Tournament Revenue: ₹$totalTournamentRevenue (${tournamentData['count']} tournaments)',
      );
      print(
        'Booking Revenue: ₹$totalBookingRevenue (${bookingData['count']} bookings)',
      );
      print('Total Revenue: ₹$totalRevenue');
      print('Owner Share (30%): ₹$ownerShare');
      print('=======================');

      // Create booking income items
      final bookingIncomes = <BookingIncomeItem>[
        BookingIncomeItem(
          type: 'tournament',
          title: 'Tournament',
          subtitle: 'For this month',
          amount: totalTournamentRevenue,
          ownerAmount: totalTournamentRevenue * 0.3,
          count: tournamentData['count'] ?? 0,
        ),
        BookingIncomeItem(
          type: 'daily_booking',
          title: 'Daily Booking',
          subtitle: 'For this month',
          amount: totalBookingRevenue,
          ownerAmount: totalBookingRevenue * 0.3,
          count: bookingData['count'] ?? 0,
        ),
      ];

      return RevenueData(
        totalRevenue: totalRevenue,
        ownerShare: ownerShare,
        monthlyProfit:
            0.0, // Not calculating monthly profit for specific month view
        profitPercentage: 0.0,
        bookingIncomes: bookingIncomes,
      );
    } catch (e) {
      print('Error fetching revenue data for month $month year $year: $e');
      // Return empty data in case of error
      return RevenueData(
        totalRevenue: 0.0,
        ownerShare: 0.0,
        monthlyProfit: 0.0,
        profitPercentage: 0.0,
        bookingIncomes: [],
      );
    }
  }

  // Get revenue data for the current owner
  Future<RevenueData> getOwnerRevenueData({String? timeRange = '1M'}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get the owner's venue
      final venueResponse =
          await _supabase
              .from('venues')
              .select('id')
              .eq('owner_id', user.id)
              .single();

      final venueId = venueResponse['id'];

      // Calculate date range based on timeRange parameter
      final now = DateTime.now();
      DateTime startDate;
      switch (timeRange) {
        case '3M':
          startDate = DateTime(now.year, now.month - 3, now.day);
          if (startDate.isAfter(now)) {
            startDate = DateTime(now.year - 1, now.month + 9, now.day);
          }
          break;
        case '6M':
          startDate = DateTime(now.year, now.month - 6, now.day);
          if (startDate.isAfter(now)) {
            startDate = DateTime(now.year - 1, now.month + 6, now.day);
          }
          break;
        case '9M':
          startDate = DateTime(now.year, now.month - 9, now.day);
          if (startDate.isAfter(now)) {
            startDate = DateTime(now.year - 1, now.month + 3, now.day);
          }
          break;
        case '1Y':
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        default: // 1M
          startDate = DateTime(now.year, now.month - 1, now.day);
          if (startDate.isAfter(now)) {
            startDate = DateTime(now.year - 1, 12, now.day);
          }
      }

      // Get tournament revenue data
      final tournamentData = await _getTournamentRevenue(venueId, startDate);

      // Get booking revenue data
      final bookingData = await _getBookingRevenue(venueId, startDate);

      // Calculate totals
      final totalTournamentRevenue = tournamentData['total_amount'] ?? 0.0;
      final totalBookingRevenue = bookingData['total_amount'] ?? 0.0;
      final totalRevenue = totalTournamentRevenue + totalBookingRevenue;
      final ownerShare = totalRevenue * 0.3; // 30% for owner

      // Get previous month data for profit calculation
      final prevMonthStart = DateTime(
        startDate.year,
        startDate.month - 1,
        startDate.day,
      );
      final adjustedPrevStart =
          prevMonthStart.isAfter(startDate)
              ? DateTime(
                startDate.year - 1,
                startDate.month + 11,
                startDate.day,
              )
              : prevMonthStart;
      final prevTournamentData = await _getTournamentRevenue(
        venueId,
        adjustedPrevStart,
        startDate,
      );
      final prevBookingData = await _getBookingRevenue(
        venueId,
        adjustedPrevStart,
        startDate,
      );
      final prevTotalRevenue =
          (prevTournamentData['total_amount'] ?? 0.0) +
          (prevBookingData['total_amount'] ?? 0.0);
      final prevOwnerShare = prevTotalRevenue * 0.3;

      final monthlyProfit = ownerShare - prevOwnerShare;
      final profitPercentage =
          prevOwnerShare > 0 ? (monthlyProfit / prevOwnerShare) * 100 : 0.0;

      // Create booking income items
      final bookingIncomes = <BookingIncomeItem>[
        BookingIncomeItem(
          type: 'tournament',
          title: 'Tournament',
          subtitle: 'Since Last Month',
          amount: totalTournamentRevenue,
          ownerAmount: totalTournamentRevenue * 0.3,
          count: tournamentData['count'] ?? 0,
        ),
        BookingIncomeItem(
          type: 'daily_booking',
          title: 'Daily Booking',
          subtitle: 'Since Last Month',
          amount: totalBookingRevenue,
          ownerAmount: totalBookingRevenue * 0.3,
          count: bookingData['count'] ?? 0,
        ),
      ];

      return RevenueData(
        totalRevenue: totalRevenue,
        ownerShare: ownerShare,
        monthlyProfit: monthlyProfit,
        profitPercentage: profitPercentage,
        bookingIncomes: bookingIncomes,
      );
    } catch (e) {
      print('Error fetching revenue data: $e');
      // Return empty data in case of error
      return RevenueData(
        totalRevenue: 0.0,
        ownerShare: 0.0,
        monthlyProfit: 0.0,
        profitPercentage: 0.0,
        bookingIncomes: [],
      );
    }
  }

  // Get tournament revenue for a venue
  Future<Map<String, dynamic>> _getTournamentRevenue(
    String venueId,
    DateTime startDate, [
    DateTime? endDate,
  ]) async {
    try {
      print('Fetching tournament revenue for venue: $venueId');
      print(
        'Date range: ${startDate.toIso8601String()} to ${endDate?.toIso8601String() ?? 'now'}',
      );

      // First get all tournament IDs for this venue
      final tournamentsQuery = _supabase
          .from('tournaments')
          .select('id')
          .eq('venue_id', venueId);

      final tournamentsResponse = await tournamentsQuery;
      print('Found ${tournamentsResponse.length} tournaments for this venue');

      if (tournamentsResponse.isEmpty) {
        print('No tournaments found for venue');
        return {'total_amount': 0.0, 'count': 0};
      }

      // Extract tournament IDs
      final tournamentIds =
          tournamentsResponse.map((tournament) => tournament['id']).toList();
      print('Tournament IDs: $tournamentIds');

      // Now get tournament registrations for these tournaments
      final registrationsQuery = _supabase
          .from('tournament_registrations')
          .select('registration_fee, tournament_id, created_at')
          .inFilter('tournament_id', tournamentIds)
          .gte('created_at', startDate.toIso8601String());

      if (endDate != null) {
        registrationsQuery.lt('created_at', endDate.toIso8601String());
      }

      final registrationsResponse = await registrationsQuery;
      print('Found ${registrationsResponse.length} tournament registrations');

      double totalAmount = 0.0;
      int count = 0;

      for (final registration in registrationsResponse) {
        final fee = (registration['registration_fee'] ?? 0.0).toDouble();
        totalAmount += fee;
        count++;
        print(
          'Registration: Tournament ${registration['tournament_id']}, Fee: ₹$fee, Date: ${registration['created_at']}',
        );
      }

      print(
        'Tournament revenue summary: Total = ₹$totalAmount, Count = $count',
      );
      return {'total_amount': totalAmount, 'count': count};
    } catch (e) {
      print('Error fetching tournament revenue: $e');
      return {'total_amount': 0.0, 'count': 0};
    }
  }

  // Get booking revenue for a venue
  Future<Map<String, dynamic>> _getBookingRevenue(
    String venueId,
    DateTime startDate, [
    DateTime? endDate,
  ]) async {
    try {
      print('Fetching booking revenue for venue: $venueId');
      print(
        'Date range: ${startDate.toIso8601String()} to ${endDate?.toIso8601String() ?? 'now'}',
      );

      // First get all booking IDs for this venue
      final bookingsQuery = _supabase
          .from('bookings')
          .select('id, booking_date, created_at')
          .eq('venue_id', venueId);

      final bookingsResponse = await bookingsQuery;
      print('Found ${bookingsResponse.length} bookings for this venue');

      if (bookingsResponse.isEmpty) {
        print('No bookings found for venue');
        return {'total_amount': 0.0, 'count': 0};
      }

      // Extract booking IDs
      final bookingIds =
          bookingsResponse.map((booking) => booking['id']).toList();
      print('Booking IDs: $bookingIds');

      // Now get payments for these bookings
      final paymentsQuery = _supabase
          .from('payments')
          .select('amount, booking_id, created_at, payment_status')
          .inFilter('booking_id', bookingIds)
          .eq('payment_status', 'completed')
          .gte('created_at', startDate.toIso8601String());

      if (endDate != null) {
        paymentsQuery.lt('created_at', endDate.toIso8601String());
      }

      final paymentsResponse = await paymentsQuery;
      print('Found ${paymentsResponse.length} completed payments');

      double totalAmount = 0.0;
      int count = 0;

      for (final payment in paymentsResponse) {
        final amount = (payment['amount'] ?? 0.0).toDouble();
        totalAmount += amount;
        count++;
        print(
          'Payment: Booking ${payment['booking_id']}, Amount: ₹$amount, Status: ${payment['payment_status']}, Date: ${payment['created_at']}',
        );
      }

      print('Booking revenue summary: Total = ₹$totalAmount, Count = $count');
      return {'total_amount': totalAmount, 'count': count};
    } catch (e) {
      print('Error fetching booking revenue: $e');
      return {'total_amount': 0.0, 'count': 0};
    }
  }

  // Get monthly revenue breakdown
  Future<List<MonthlyRevenueData>> getMonthlyRevenueBreakdown() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get the owner's venue
      final venueResponse =
          await _supabase
              .from('venues')
              .select('id')
              .eq('owner_id', user.id)
              .single();

      final venueId = venueResponse['id'];

      final List<MonthlyRevenueData> monthlyData = [];
      final now = DateTime.now();

      // Get data for last 6 months
      for (int i = 0; i < 6; i++) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        final monthEnd = DateTime(now.year, now.month - i + 1, 1);

        final tournamentData = await _getTournamentRevenue(
          venueId,
          monthStart,
          monthEnd,
        );
        final bookingData = await _getBookingRevenue(
          venueId,
          monthStart,
          monthEnd,
        );

        final totalRevenue =
            (tournamentData['total_amount'] ?? 0.0) +
            (bookingData['total_amount'] ?? 0.0);

        monthlyData.add(
          MonthlyRevenueData(
            month: _getMonthName(monthStart.month),
            totalRevenue: totalRevenue,
            ownerShare: totalRevenue * 0.3,
            tournamentCount: tournamentData['count'] ?? 0,
            bookingCount: bookingData['count'] ?? 0,
          ),
        );
      }

      return monthlyData.reversed.toList();
    } catch (e) {
      print('Error fetching monthly revenue breakdown: $e');
      return [];
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
