import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'create_tournament.dart';
import '../widgets/venue_owner_sidebar.dart';

// Models for tournament and booking data
class Tournament {
  final String id;
  final String name;
  final DateTime date;
  final double revenue;
  final int teams;

  Tournament({
    required this.id,
    required this.name,
    required this.date,
    required this.revenue,
    required this.teams,
  });
}

class DailyBooking {
  final String id;
  final String customerName;
  final DateTime date;
  final double amount;
  final String timeSlot;

  DailyBooking({
    required this.id,
    required this.customerName,
    required this.date,
    required this.amount,
    required this.timeSlot,
  });
}

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({Key? key}) : super(key: key);

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Tournament> _tournaments = [];
  List<DailyBooking> _dailyBookings = [];
  List<Tournament> _filteredTournaments = [];
  List<DailyBooking> _filteredBookings = [];
  double _totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
    _filterData();
  }

  void _loadSampleData() {
    _tournaments = [
      Tournament(
        id: '1',
        name: 'Inter-College Futsal Tournament',
        date: DateTime.now().subtract(const Duration(days: 5)),
        revenue: 15000.0,
        teams: 16,
      ),
      Tournament(
        id: '2',
        name: 'MIST Football Tournament',
        date: DateTime.now().subtract(const Duration(days: 12)),
        revenue: 18500.0,
        teams: 12,
      ),
      Tournament(
        id: '3',
        name: 'Youth Tournament',
        date: DateTime.now().subtract(const Duration(days: 20)),
        revenue: 5200.0,
        teams: 8,
      ),
    ];

    // Sample daily booking data
    _dailyBookings = [
      DailyBooking(
        id: '1',
        customerName: 'Maheen Khan',
        date: DateTime.now().subtract(const Duration(days: 1)),
        amount: 500.0,
        timeSlot: '10:00 AM - 12:00 PM',
      ),
      DailyBooking(
        id: '2',
        customerName: 'Shohan Rahman',
        date: DateTime.now().subtract(const Duration(days: 3)),
        amount: 750.0,
        timeSlot: '2:00 PM - 4:00 PM',
      ),
      DailyBooking(
        id: '3',
        customerName: 'Amira Khan',
        date: DateTime.now().subtract(const Duration(days: 7)),
        amount: 600.0,
        timeSlot: '6:00 PM - 8:00 PM',
      ),
    ];
  }

  void _filterData() {
    setState(() {
      if (_startDate != null && _endDate != null) {
        _filteredTournaments = _tournaments.where((tournament) {
          return tournament.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                 tournament.date.isBefore(_endDate!.add(const Duration(days: 1)));
        }).toList();

        _filteredBookings = _dailyBookings.where((booking) {
          return booking.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                 booking.date.isBefore(_endDate!.add(const Duration(days: 1)));
        }).toList();
      } else {
        _filteredTournaments = _tournaments;
        _filteredBookings = _dailyBookings;
      }

      // Calculate total revenue
      _totalRevenue = _filteredTournaments.fold(0.0, (sum, t) => sum + t.revenue) +
                    _filteredBookings.fold(0.0, (sum, b) => sum + b.amount);
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _filterData();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _filterData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venue Owner Dashboard'),
        backgroundColor: Colors.green,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.sports_soccer_rounded,
                color: Colors.green[700],
                size: 24,
              ),
            ),
          ),
        ],
      ),
      drawer: const VenueOwnerSidebar(currentPage: 'dashboard'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Owner Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage your venue, tournaments, and bookings from here.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Add Tournament Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateTournamentPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Tournament'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

                // Date Range Search Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.search, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Revenue Search by Date Range',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _selectDateRange,
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  _startDate != null && _endDate != null
                                      ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'
                                      : 'Select Date Range',
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  foregroundColor: Colors.green[700],
                                ),
                              ),
                            ),
                            if (_startDate != null && _endDate != null) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _clearDateFilter,
                                icon: const Icon(Icons.clear),
                                color: Colors.red,
                                tooltip: 'Clear Filter',
                              ),
                            ],
                          ],
                        ),
                        if (_startDate != null && _endDate != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Total Revenue for Selected Period',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '৳${_totalRevenue.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

            const SizedBox(height: 20),

            // Results Section
            Container(
              height: 600, // Fixed height for the tab view
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Colors.green[700],
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.green[700],
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.emoji_events),
                          text: 'Tournaments (${_filteredTournaments.length})',
                        ),
                        Tab(
                          icon: const Icon(Icons.calendar_month),
                          text: 'Daily Bookings (${_filteredBookings.length})',
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildTournamentsTab(),
                          _buildBookingsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentsTab() {
    if (_filteredTournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tournaments found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _startDate != null 
                  ? 'No tournaments in selected date range'
                  : 'No tournaments available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTournaments.length,
      itemBuilder: (context, index) {
        final tournament = _filteredTournaments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.orange[700],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tournament.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(tournament.date),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '৳${tournament.revenue.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tournament.teams} teams',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Revenue',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingsTab() {
    if (_filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _startDate != null 
                  ? 'No bookings in selected date range'
                  : 'No bookings available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = _filteredBookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_month,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.customerName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(booking.date),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '৳${booking.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking.timeSlot,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
