import 'package:flutter/material.dart';
import '../widgets/venue_owner_sidebar.dart';
import '../services/revenue_service.dart';
import '../models/revenue_data.dart';

class RevenueTrackingScreen extends StatefulWidget {
  const RevenueTrackingScreen({Key? key}) : super(key: key);

  @override
  State<RevenueTrackingScreen> createState() => _RevenueTrackingScreenState();
}

class _RevenueTrackingScreenState extends State<RevenueTrackingScreen> {
  final RevenueService _revenueService = RevenueService();
  RevenueData? _revenueData;
  bool _isLoading = true;

  // Filter variables
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // Month names
  final List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _loadRevenueData();
  }

  Future<void> _loadRevenueData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _revenueService.getOwnerRevenueDataByMonth(
        _selectedMonth,
        _selectedYear,
      );
      setState(() {
        _revenueData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading revenue data: $e')),
        );
      }
    }
  }

  void _onMonthChanged(int? month) {
    if (month != null && month != _selectedMonth) {
      setState(() {
        _selectedMonth = month;
      });
      _loadRevenueData();
    }
  }

  void _onYearChanged(int? year) {
    if (year != null && year != _selectedYear) {
      setState(() {
        _selectedYear = year;
      });
      _loadRevenueData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earning Overview'),
        backgroundColor: Colors.green[700],
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.green[700], size: 24),
            ),
          ),
        ],
      ),
      drawer: const VenueOwnerSidebar(currentPage: 'revenue'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Summary Card
            Card(
              color: Colors.cyan,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Owner Share (30%)',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              '\u09F3 ${(_revenueData?.ownerShare ?? 0).toStringAsFixed(0)}',
                              key: ValueKey(_revenueData?.ownerShare ?? 0),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Month and Year Filter Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter by Month & Year',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Month Dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Month',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<int>(
                                value: _selectedMonth,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: List.generate(12, (index) {
                                  return DropdownMenuItem<int>(
                                    value: index + 1,
                                    child: Text(_monthNames[index]),
                                  );
                                }),
                                onChanged: _onMonthChanged,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Year Dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Year',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<int>(
                                value: _selectedYear,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: List.generate(5, (index) {
                                  final year = DateTime.now().year - index;
                                  return DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(year.toString()),
                                  );
                                }),
                                onChanged: _onYearChanged,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Revenue Section Title
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                'Booking Income for ${_monthNames[_selectedMonth - 1]} $_selectedYear',
                key: ValueKey('$_selectedMonth-$_selectedYear'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Content with smooth loading
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Loading revenue data...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Check debug console for details',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: _loadRevenueData,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: _buildBookingIncomeView(),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the booking income view
  Widget _buildBookingIncomeView() {
    return ListView.builder(
      key: ValueKey('$_selectedMonth-$_selectedYear-list'),
      itemCount: _revenueData?.bookingIncomes.length ?? 0,
      itemBuilder: (context, index) {
        final income = _revenueData!.bookingIncomes[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    income.type == 'tournament'
                        ? Colors.cyan
                        : Colors.purpleAccent,
                child: Icon(
                  income.type == 'tournament' ? Icons.pie_chart : Icons.widgets,
                  color: Colors.white,
                ),
              ),
              title: Text(income.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(income.subtitle),
                  Text(
                    'Total: \u09F3 ${income.amount.toStringAsFixed(0)} (${income.count} ${income.type == 'tournament' ? 'tournaments' : 'bookings'})',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      '\u09F3 ${income.ownerAmount.toStringAsFixed(0)}',
                      key: ValueKey(income.ownerAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    'Your Share',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
