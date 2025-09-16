import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../services/admin_venue_payments_service.dart';

class AdminVenuePaymentsPage extends StatefulWidget {
  final VoidCallback? onNotificationUpdate;

  const AdminVenuePaymentsPage({super.key, this.onNotificationUpdate});

  @override
  State<AdminVenuePaymentsPage> createState() => _AdminVenuePaymentsPageState();
}

class _AdminVenuePaymentsPageState extends State<AdminVenuePaymentsPage> {
  String _selectedPaymentStatus = 'All';
  String _selectedVenueType = 'All Venues';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  List<Map<String, dynamic>> _venueOwnerCommissions = [];
  Map<String, dynamic> _totalStats = {};
  bool _isLoading = true;

  final List<String> _paymentStatusOptions = ['All', 'Pending', 'Paid'];

  final List<String> _venueTypeOptions = [
    'All Venues',
    'Cricket Ground',
    'Football Field',
    'Basketball Court',
    'Multi-purpose',
    'Badminton Court',
  ];

  final List<String> _monthOptions = [
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

  final List<int> _yearOptions = List.generate(
    5,
    (index) => DateTime.now().year - index,
  );

  @override
  void initState() {
    super.initState();
    _loadCommissionData();
  }

  Future<void> _loadCommissionData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final commissions =
          await AdminVenuePaymentsService.getVenueOwnerCommissions(
            status:
                _selectedPaymentStatus != 'All' ? _selectedPaymentStatus : null,
          );

      final stats = await AdminVenuePaymentsService.getTotalStats(
        status: _selectedPaymentStatus != 'All' ? _selectedPaymentStatus : null,
      );

      setState(() {
        _venueOwnerCommissions = commissions;
        _totalStats = stats;
        _isLoading = false;
      });

      // Update notification count when data loads
      if (widget.onNotificationUpdate != null) {
        widget.onNotificationUpdate!();
      }
    } catch (e) {
      print('Error loading commission data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Filtering logic for loaded data
  List<Map<String, dynamic>> get _filteredCommissions {
    return _venueOwnerCommissions
        .where((commission) => commission.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 768;
          double padding = isMobile ? 12 : 24;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child:
                _isLoading
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(50),
                        child: CircularProgressIndicator(),
                      ),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildSummaryCards(),
                        const SizedBox(height: 24),
                        _buildFilters(),
                        const SizedBox(height: 24),
                        _buildPaymentsList(),
                      ],
                    ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child:
              isMobile
                  ? Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Column(
                        children: [
                          Text(
                            'Venue Owner Commission Calculator',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Calculate 30% commission for each venue owner based on monthly bookings',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Venue Owner Commission Calculator',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Calculate 30% commission for each venue owner based on monthly bookings',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if screen is mobile
        bool isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          // Mobile layout - 1x2 grid (removed Booking Amount and Pending Payments)
          return Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Bookings',
                  '${_totalStats['totalBookings']?.toInt() ?? 0}',
                  Icons.event_available,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Commission',
                  '৳${((_totalStats['total_amount'] ?? 0) / 1000).toStringAsFixed(0)}K',
                  Icons.person_pin_circle,
                  Colors.orange,
                ),
              ),
            ],
          );
        } else {
          // Desktop layout - single row (removed Booking Amount and Pending Payments)
          return Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Bookings',
                  '${_totalStats['totalBookings']?.toInt() ?? 0}',
                  Icons.event_available,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Commission',
                  '৳${(_totalStats['total_amount'] ?? 0).toStringAsFixed(0)}',
                  Icons.person_pin_circle,
                  Colors.orange,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 200;

        return Container(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: isMobile ? 20 : 24),
                  Container(
                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: isMobile ? 12 : 16),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            // Mobile layout - stacked vertically
            return Column(
              children: [
                _buildFilterDropdown(
                  'Payment Status',
                  _selectedPaymentStatus,
                  _paymentStatusOptions,
                  (value) {
                    setState(() {
                      _selectedPaymentStatus = value!;
                    });
                    _loadCommissionData();
                  },
                ),
                const SizedBox(height: 16),
                _buildFilterDropdown(
                  'Venue Type',
                  _selectedVenueType,
                  _venueTypeOptions,
                  (value) {
                    setState(() {
                      _selectedVenueType = value!;
                    });
                    _loadCommissionData();
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        'Month',
                        _monthOptions[_selectedMonth - 1],
                        _monthOptions,
                        (value) {
                          setState(() {
                            _selectedMonth = _monthOptions.indexOf(value!) + 1;
                          });
                          _loadCommissionData();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFilterDropdown(
                        'Year',
                        _selectedYear.toString(),
                        _yearOptions.map((y) => y.toString()).toList(),
                        (value) {
                          setState(() {
                            _selectedYear = int.parse(value!);
                          });
                          _loadCommissionData();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Apply filters
                    },
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Apply Filters'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Desktop layout - horizontal
            return Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    'Payment Status',
                    _selectedPaymentStatus,
                    _paymentStatusOptions,
                    (value) {
                      setState(() {
                        _selectedPaymentStatus = value!;
                      });
                      _loadCommissionData();
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildFilterDropdown(
                    'Venue Type',
                    _selectedVenueType,
                    _venueTypeOptions,
                    (value) {
                      setState(() {
                        _selectedVenueType = value!;
                      });
                      _loadCommissionData();
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildFilterDropdown(
                    'Month',
                    _monthOptions[_selectedMonth - 1],
                    _monthOptions,
                    (value) {
                      setState(() {
                        _selectedMonth = _monthOptions.indexOf(value!) + 1;
                      });
                      _loadCommissionData();
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildFilterDropdown(
                    'Year',
                    _selectedYear.toString(),
                    _yearOptions.map((y) => y.toString()).toList(),
                    (value) {
                      setState(() {
                        _selectedYear = int.parse(value!);
                      });
                      _loadCommissionData();
                    },
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Apply filters
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Apply Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Venue Owner Commission Calculations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 30,
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
              columns: const [
                DataColumn(
                  label: Text(
                    'Venue Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Owner Info',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Bookings',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Booking Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Commission (30%)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Payment Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows:
                  _filteredCommissions.isEmpty
                      ? [
                        DataRow(
                          cells: [
                            DataCell(Text('No data available')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                          ],
                        ),
                      ]
                      : _filteredCommissions.map((commission) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    commission['venue_name'] ?? 'Unknown Venue',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${commission['venue_type'] ?? commission['venueType'] ?? 'Football Field'}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    commission['owner_name'] ?? 'Unknown Owner',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    commission['owner_email'] ??
                                        'No email provided',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Total: ${commission['totalBookings'] ?? 0}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Normal: ${commission['normalBookings'] ?? 0} | Tournament: ${commission['tournamentBookings'] ?? 0}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                '৳${(commission['totalBookingAmount'] ?? 0).toString()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '৳${(commission['amount'] ?? 0).toString()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(
                                    '30% of total booking',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (commission['paymentStatus'] ??
                                                  commission['status'] ??
                                                  'pending') ==
                                              'paid'
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  (commission['paymentStatus'] ??
                                              commission['status'] ??
                                              'pending') ==
                                          'paid'
                                      ? 'Paid'
                                      : 'Pending',
                                  style: TextStyle(
                                    color:
                                        (commission['paymentStatus'] ??
                                                    commission['status'] ??
                                                    'pending') ==
                                                'paid'
                                            ? Colors.green
                                            : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed:
                                        () =>
                                            _showCommissionDetails(commission),
                                    icon: const Icon(
                                      Icons.visibility,
                                      size: 18,
                                    ),
                                    tooltip: 'View Details',
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.blue.withOpacity(
                                        0.1,
                                      ),
                                      foregroundColor: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if ((commission['paymentStatus'] ??
                                          commission['status'] ??
                                          'pending') ==
                                      'pending')
                                    IconButton(
                                      onPressed: () => _markAsPaid(commission),
                                      icon: const Icon(Icons.payment, size: 18),
                                      tooltip: 'Mark as Paid',
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.green
                                            .withOpacity(0.1),
                                        foregroundColor: Colors.green,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showCommissionDetails(Map<String, dynamic> commission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 600,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fixed header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              commission['venue_name'] ?? 'Unknown Venue',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Commission Details',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          'Owner Name',
                          commission['owner_name'] ?? 'Unknown',
                        ),
                        _buildDetailRow(
                          'Owner Email',
                          commission['owner_email'] ?? 'Not provided',
                        ),
                        _buildDetailRow(
                          'Owner Phone',
                          commission['owner_phone'] ?? 'Not provided',
                        ),
                        _buildDetailRow(
                          'Venue Type',
                          commission['venue_type'] ?? 'Unknown',
                        ),
                        _buildDetailRow(
                          'Total Amount',
                          '৳${commission['amount'] ?? 0}',
                        ),
                        _buildDetailRow(
                          'Payment Status',
                          commission['status'] ?? 'pending',
                        ),
                        _buildDetailRow(
                          'Tournament Bookings',
                          '${commission['tournamentBookings'] ?? 0}',
                        ),
                        const Divider(),
                        _buildDetailRow(
                          'Total Booking Amount',
                          '৳${(commission['totalBookingAmount'] ?? 0).toStringAsFixed(0)}',
                        ),
                        _buildDetailRow(
                          'Normal Booking Amount',
                          '৳${(commission['normalBookingAmount'] ?? 0).toStringAsFixed(0)}',
                        ),
                        _buildDetailRow(
                          'Tournament Booking Amount',
                          '৳${(commission['tournamentBookingAmount'] ?? 0).toStringAsFixed(0)}',
                        ),
                        const Divider(),
                        _buildDetailRow(
                          'Owner Commission',
                          '৳${(commission['amount'] ?? 0).toStringAsFixed(0)}',
                          isHighlight: true,
                        ),
                        _buildDetailRow(
                          'Payment Status',
                          (commission['paymentStatus'] ?? 'pending')
                              .toString()
                              .toUpperCase(),
                        ),
                        if (commission['lastPaymentDate'] != null)
                          _buildDetailRow(
                            'Last Paid Date',
                            commission['lastPaymentDate'] ?? 'Not available',
                          ),
                        _buildDetailRow(
                          'Owner Join Date',
                          commission['ownerJoinDate'] ?? 'Not available',
                        ),
                      ],
                    ),
                  ),
                ),
                // Fixed footer
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 12),
                      if (commission['paymentStatus'] == 'pending')
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _markAsPaid(commission);
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text('Mark as Paid'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                color: isHighlight ? Colors.blue : Colors.black87,
                fontSize: isHighlight ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _markAsPaid(Map<String, dynamic> commission) async {
    final result = await _showRecordPaymentDialog(commission);

    if (result != null) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final success = await AdminVenuePaymentsService.recordCashPayment(
          venueId: commission['venue_id'].toString(),
          amount: result['amount']?.toDouble() ?? 0.0,
          month: DateTime.now().month,
          year: DateTime.now().year,
          notes: result['description'] ?? 'Commission payment',
        );

        // Hide loading
        Navigator.of(context).pop();

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Payment recorded successfully for ${commission['owner_name']}',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Reload data
          _loadCommissionData();

          // Update notification count
          if (widget.onNotificationUpdate != null) {
            widget.onNotificationUpdate!();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to record payment. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Hide loading
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _showRecordPaymentDialog(
    Map<String, dynamic> commission,
  ) async {
    final TextEditingController amountController = TextEditingController(
      text: commission['amount'].toString(),
    );
    final TextEditingController noteController = TextEditingController();
    String selectedPaymentMethod = 'Cash';

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.payment,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Record Commission Payment',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Payment to ${commission['owner_name']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Venue Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Venue: ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  commission['venue_name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Total Commission: ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '৳${commission['amount']?.toString() ?? '0'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Amount
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Payment Amount (৳)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monetization_on),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Payment Method
                    DropdownButtonFormField<String>(
                      value: selectedPaymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payment),
                      ),
                      items:
                          ['Cash', 'Bank Transfer', 'bKash', 'Nagad', 'Rocket']
                              .map(
                                (method) => DropdownMenuItem(
                                  value: method,
                                  child: Text(method),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            final amount =
                                double.tryParse(amountController.text) ?? 0;
                            if (amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid amount'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            Navigator.pop(context, {
                              'amount': amount,
                              'description':
                                  'Commission payment via $selectedPaymentMethod - ${noteController.text}',
                              'events':
                                  'Venue: ${commission['venue_name']} | Amount: ৳${amount.toStringAsFixed(0)} | Method: $selectedPaymentMethod',
                            });
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Record Payment'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
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
      },
    );
  }
}
