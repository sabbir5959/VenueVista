import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/common_drawer.dart';
import '../../services/booking_service.dart';
import '../../services/tournament_service.dart';
import '../../widgets/weather_popup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> futureBookings = [];
  List<Map<String, dynamic>> tournamentRegistrations = [];
  bool isLoading = true;
  String? error;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([_loadFutureBookings(), _loadTournamentRegistrations()]);
  }

  Future<void> _loadTournamentRegistrations() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('🏆 Loading tournament registrations for user: ${user.id}');

      // Get user tournament registrations
      final registrations =
          await TournamentService.getUserTournamentRegistrations(user.id);
      print('🎮 Tournament registrations found: ${registrations.length}');

      setState(() {
        tournamentRegistrations = registrations;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading tournament registrations: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadFutureBookings() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('🔍 Loading bookings for user: ${user.id}');

      // Get all user bookings
      final allBookings = await BookingService.getUserBookings(user.id);
      print('📅 Total bookings found: ${allBookings.length}');

      // Debug: Print all bookings data
      for (int i = 0; i < allBookings.length; i++) {
        final booking = allBookings[i];
        print('📋 Booking $i: $booking');
      }

      // Filter for future bookings only
      final now = DateTime.now();
      final filtered = <Map<String, dynamic>>[];

      for (final booking in allBookings) {
        try {
          // Parse booking date and start time
          final bookingDateStr = booking['booking_date'];
          final startTimeStr = booking['start_time'];

          if (bookingDateStr != null && startTimeStr != null) {
            // Create DateTime from booking date and start time
            final bookingDate = DateTime.parse(bookingDateStr);
            final startTimeParts = startTimeStr.split(':');
            final startHour = int.parse(startTimeParts[0]);
            final startMinute = int.parse(startTimeParts[1]);

            final bookingDateTime = DateTime(
              bookingDate.year,
              bookingDate.month,
              bookingDate.day,
              startHour,
              startMinute,
            );

            // Parse end time to check if booking is still valid
            final endTimeStr = booking['end_time'];
            final endTimeParts = endTimeStr?.split(':');
            final endHour =
                endTimeParts != null
                    ? int.parse(endTimeParts[0])
                    : startHour + 1;
            final endMinute =
                endTimeParts != null ? int.parse(endTimeParts[1]) : startMinute;

            final bookingEndDateTime = DateTime(
              bookingDate.year,
              bookingDate.month,
              bookingDate.day,
              endHour,
              endMinute,
            );

            print(
              '🕒 Checking booking: ${booking['venues']?['name']} from $bookingDateTime to $bookingEndDateTime vs now $now',
            );

            // Include bookings that:
            // 1. Are on future dates (after today)
            // 2. Are today but haven't ended yet
            final isToday =
                bookingDate.year == now.year &&
                bookingDate.month == now.month &&
                bookingDate.day == now.day;

            final isFutureDate = bookingDate.isAfter(
              DateTime(now.year, now.month, now.day),
            );
            final isTodayAndNotEnded =
                isToday && bookingEndDateTime.isAfter(now);

            if (isFutureDate || isTodayAndNotEnded) {
              filtered.add(booking);
              print(
                '✅ Added future booking: ${booking['venues']?['name']} (${isFutureDate ? 'future date' : 'today, not ended'})',
              );
            } else {
              print(
                '⏰ Skipped past booking: ${booking['venues']?['name']} (ended or in past)',
              );
            }
          }
        } catch (e) {
          print('❌ Error processing booking: $e');
        }
      }

      print('🎯 Future bookings filtered: ${filtered.length}');

      setState(() {
        futureBookings = filtered;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading future bookings: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // Function to open directions in Google Maps
  Future<void> _openDirections(
    BuildContext context,
    String destinationQuery,
  ) async {
    try {
      final Uri geoUri = Uri.parse(
        'geo:0,0?q=${Uri.encodeComponent(destinationQuery)}',
      );

      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Fallback to Google Maps web
      final Uri webMapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(destinationQuery)}',
      );

      if (await canLaunchUrl(webMapsUri)) {
        await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
        return;
      }

      // If all else fails, try the original directions URL
      final Uri directionsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(destinationQuery)}',
      );

      if (await canLaunchUrl(directionsUrl)) {
        await launchUrl(directionsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Google Maps directions.';
      }
    } catch (e) {
      // Show user-friendly error message instead of throwing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open directions. Please check if Google Maps is installed.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Function to show weather popup
  void _showWeatherPopup(
    BuildContext context,
    String location,
    DateTime bookingDate,
    String groundName,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => WeatherPopup(
            location: location,
            bookingDate: bookingDate,
            groundName: groundName,
          ),
    );
  }

  // Function to parse date string to DateTime
  DateTime _parseDate(String dateStr) {
    try {
      // Handle different date formats
      if (dateStr.contains('-')) {
        // Format: YYYY-MM-DD
        return DateTime.parse(dateStr);
      } else if (dateStr.contains('/')) {
        // Format: DD/MM/YYYY or MM/DD/YYYY
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }
      // Fallback to current date if parsing fails
      return DateTime.now();
    } catch (e) {
      print('❌ Date parsing error: $e');
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: AppBar(
        title: Text('My Schedules', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.sports_soccer), text: 'Venue Bookings'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Tournament Bookings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildVenueBookingsTab(), _buildTournamentBookingsTab()],
      ),
    );
  }

  Widget _buildVenueBookingsTab() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green.shade700),
            SizedBox(height: 16),
            Text('Loading your venue bookings...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            SizedBox(height: 16),
            Text('Error loading schedules'),
            SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFutureBookings,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (futureBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'No upcoming venue bookings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Book a venue to see your schedules here',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFutureBookings,
      color: Colors.green.shade700,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: futureBookings.length,
        itemBuilder: (context, index) {
          final booking = futureBookings[index];
          final venue = booking['venues'];

          return Card(
            elevation: 4,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: _buildBookingTitle(booking, venue),
              onTap: () => _showBookingDetails(context, booking, venue),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTournamentBookingsTab() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green.shade700),
            SizedBox(height: 16),
            Text('Loading your tournament registrations...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            SizedBox(height: 16),
            Text('Error loading tournament registrations'),
            SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTournamentRegistrations,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (tournamentRegistrations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'No tournament registrations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Register for tournaments to see them here',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTournamentRegistrations,
      color: Colors.green.shade700,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: tournamentRegistrations.length,
        itemBuilder: (context, index) {
          final registration = tournamentRegistrations[index];
          final tournament = registration['tournaments'];

          return Card(
            elevation: 4,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: _buildTournamentTitle(registration, tournament),
              onTap:
                  () =>
                      _showTournamentDetails(context, registration, tournament),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTournamentTitle(
    Map<String, dynamic> registration,
    Map<String, dynamic>? tournament,
  ) {
    final tournamentName = tournament?['name'] ?? 'Unknown Tournament';
    final tournamentDate = tournament?['tournament_date'] ?? '';
    final entryFee = '৳${tournament?['entry_fee']?.toString() ?? '0'}';
    final venue = tournament?['venues'];
    final location = venue?['name'] ?? 'Tournament Venue';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                tournamentName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Registered',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Text(
              _formatDate(tournamentDate),
              style: TextStyle(color: Colors.grey.shade700),
            ),
            SizedBox(width: 16),
            Icon(Icons.attach_money, size: 16, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Text(
              entryFee,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                location,
                style: TextStyle(color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingTitle(
    Map<String, dynamic> booking,
    Map<String, dynamic>? venue,
  ) {
    final groundName = venue?['name'] ?? 'Unknown Ground';
    final bookingDate = booking['booking_date'] ?? '';
    final startTime = booking['start_time'] ?? '';
    final endTime = booking['end_time'] ?? '';
    final location = venue?['address'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                groundName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Confirmed',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Text(
              _formatDate(bookingDate),
              style: TextStyle(color: Colors.grey.shade700),
            ),
            SizedBox(width: 16),
            Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Text(
              '$startTime - $endTime',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
        if (location.isNotEmpty) ...[
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              IconButton(
                icon: Icon(Icons.cloud, color: Colors.blue.shade600, size: 20),
                onPressed:
                    () => _showWeatherPopup(
                      context,
                      location,
                      _parseDate(bookingDate),
                      groundName,
                    ),
                tooltip: 'Weather Update',
              ),
              IconButton(
                icon: Icon(
                  Icons.directions,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                onPressed:
                    () => _openDirections(context, '$groundName, $location'),
                tooltip: 'Get Directions',
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Tomorrow';
      } else if (difference < 7) {
        return '${difference} days from now';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }

  void _showBookingDetails(
    BuildContext context,
    Map<String, dynamic> booking,
    Map<String, dynamic>? venue,
  ) {
    final groundName = venue?['name'] ?? 'Unknown Ground';
    final bookingDate = booking['booking_date'] ?? '';
    final startTime = booking['start_time'] ?? '';
    final endTime = booking['end_time'] ?? '';
    final bookingId = booking['booking_id'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            groundName,
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking Details:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('Date: ${_formatDate(bookingDate)}'),
              Text('Time: $startTime - $endTime'),
              Text('Booking ID: $bookingId'),
              Text('Status: Confirmed'),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.cloud_outlined,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  TextButton(
                    onPressed:
                        () => _showWeatherDialog(
                          context,
                          groundName,
                          bookingDate,
                        ),
                    child: Text('Check Weather'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Cancel Booking',
                style: TextStyle(color: Colors.red),
              ),
              onPressed:
                  () => _showCancelDialog(context, groundName, bookingId),
            ),
          ],
        );
      },
    );
  }

  void _showWeatherDialog(
    BuildContext context,
    String groundName,
    String date,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.cloud_outlined, color: Colors.blue.shade700, size: 28),
              SizedBox(width: 8),
              Text(
                'Weather Forecast',
                style: TextStyle(color: Colors.blue.shade700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                groundName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16),
                  SizedBox(width: 8),
                  Text(_formatDate(date)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.thermostat_outlined,
                        size: 32,
                        color: Colors.orange,
                      ),
                      Text(
                        '28°C',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Temperature'),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        size: 32,
                        color: Colors.blue,
                      ),
                      Text(
                        '65%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Humidity'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Weather Condition: Partly Cloudy',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog(
    BuildContext context,
    String groundName,
    String bookingId,
  ) {
    Navigator.of(context).pop(); // Close the details dialog first
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Cancel Booking', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please note:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Cancellation fee may apply'),
              Text('• Refund will take 3-5 business days'),
              Text('• This action cannot be undone'),
              SizedBox(height: 16),
              Text(
                'Are you sure you want to cancel your booking for $groundName?',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Keep Booking'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Cancel Booking',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cancellation request sent for $groundName'),
                    backgroundColor: Colors.red.shade700,
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Cancellation request withdrawn'),
                            backgroundColor: Colors.green.shade700,
                          ),
                        );
                      },
                    ),
                  ),
                );
                // Refresh the bookings list
                _loadFutureBookings();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTournamentDetails(
    BuildContext context,
    Map<String, dynamic> registration,
    Map<String, dynamic>? tournament,
  ) {
    final tournamentName = tournament?['name'] ?? 'Unknown Tournament';
    final tournamentDate = tournament?['tournament_date'] ?? '';
    final entryFee = tournament?['entry_fee']?.toString() ?? '0';
    final firstPrize = tournament?['first_prize']?.toString() ?? '0';
    final maxTeams = tournament?['max_teams']?.toString() ?? '0';
    final playerFormat = tournament?['player_format'] ?? '';
    final venue = tournament?['venues'];
    final location = venue?['name'] ?? 'Tournament Venue';
    final registrationDate = registration['created_at'] ?? '';
    final paymentMethod = registration['payment_method'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            tournamentName,
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tournament Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 12),
                _buildDetailRow(
                  Icons.calendar_today,
                  'Date',
                  _formatDate(tournamentDate),
                ),
                _buildDetailRow(Icons.location_on, 'Venue', location),
                _buildDetailRow(Icons.sports_soccer, 'Format', playerFormat),
                _buildDetailRow(Icons.groups, 'Max Teams', maxTeams),
                _buildDetailRow(
                  Icons.emoji_events,
                  'First Prize',
                  '৳$firstPrize',
                ),
                SizedBox(height: 16),
                Text(
                  'Registration Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 12),
                _buildDetailRow(Icons.attach_money, 'Entry Fee', '৳$entryFee'),
                _buildDetailRow(
                  Icons.payment,
                  'Payment Method',
                  paymentMethod.toUpperCase(),
                ),
                _buildDetailRow(
                  Icons.schedule,
                  'Registered On',
                  _formatDate(registrationDate),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You are successfully registered for this tournament!',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (tournament != null && venue != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
                child: Text('Get Directions'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _openDirections(
                    context,
                    '${venue['name']}, ${venue['address'] ?? ''}',
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}
