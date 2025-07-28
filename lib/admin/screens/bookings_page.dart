import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({super.key});

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: AppColors.background,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 24), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              isMobile ? 'Bookings' : 'Bookings Management',
              style: TextStyle(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6), // Reduced height
            Text(
              isMobile
                  ? 'Manage bookings'
                  : 'Track and manage all football venue bookings',
              style: TextStyle(
                fontSize: isMobile ? 12 : 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 20), // Further reduced
            // Quick Stats - Made more compact
            Container(
              height: isMobile ? 90 : 110, // Even more reduced height
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 2 : 4,
                childAspectRatio:
                    isMobile
                        ? 2.2
                        : 2.8, // Increased even more for flatter cards
                crossAxisSpacing: 10, // Further reduced spacing
                mainAxisSpacing: 10, // Further reduced spacing
                children: [
                  _buildBookingStatCard(
                    'Match Bookings',
                    '8,934',
                    Icons.sports_soccer,
                    AppColors.primary,
                    isMobile,
                  ),
                  _buildBookingStatCard(
                    'Confirmed',
                    '7,245',
                    Icons.check_circle_outline,
                    AppColors.success,
                    isMobile,
                  ),
                  _buildBookingStatCard(
                    'Pending',
                    '124',
                    Icons.pending_outlined,
                    AppColors.warning,
                    isMobile,
                  ),
                  _buildBookingStatCard(
                    'Completed',
                    '6,892',
                    Icons.done_all_outlined,
                    AppColors.info,
                    isMobile,
                  ),
                ],
              ),
            ), // Close the Container

            SizedBox(height: 12), // Further reduced spacing
            // Bookings List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(isMobile ? 16 : 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Recent Football Bookings',
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () => _showExportDialog(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 8 : 12,
                                vertical: isMobile ? 4 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.download_outlined,
                                    color: AppColors.white,
                                    size: isMobile ? 16 : 18,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Export',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: isMobile ? 12 : 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bookings List
                    Expanded(
                      child: ListView.builder(
                        itemCount: _demoBookings.length,
                        itemBuilder: (context, index) {
                          return _buildBookingCard(
                            _demoBookings[index],
                            isMobile,
                          );
                        },
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

  Widget _buildBookingStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12), // Reduced padding
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8), // Smaller radius
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6, // Reduced shadow
            offset: const Offset(0, 1), // Smaller offset
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center content
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 4 : 6), // Reduced icon padding
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6), // Smaller radius
            ),
            child: Icon(
              icon,
              color: color,
              size: isMobile ? 16 : 20,
            ), // Smaller icons
          ),
          SizedBox(height: isMobile ? 4 : 6), // Fixed spacing instead of Spacer
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16, // Smaller font
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2), // Reduced spacing
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 9 : 10, // Even smaller font
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1, // Ensure single line
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 8),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child:
          isMobile
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mobile Layout - Stack vertically
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['venue'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'by ${booking['user']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _getBookingStatusColor(
                            booking['status'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getBookingStatusColor(booking['status']),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Booking Details Row
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        booking['date'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.access_time_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          booking['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        booking['amount'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  // No actions - admin can only view
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Booking Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['venue'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Booked by ${booking['user']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getBookingStatusColor(
                            booking['status'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          booking['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getBookingStatusColor(booking['status']),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Booking Details
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              booking['date'],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              booking['time'],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        booking['amount'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      // Admin can only view bookings - no actions available
                    ],
                  ),
                ],
              ),
    );
  }

  Color _getBookingStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return AppColors.success;
      case 'Pending':
        return AppColors.warning;
      case 'Cancelled':
        return AppColors.error;
      case 'Completed':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  static final List<Map<String, dynamic>> _demoBookings = [
    {
      'id': 'BK001',
      'venue': 'Green Valley Football Ground',
      'user': 'Ahmed Rahman',
      'date': '2024-07-20',
      'time': '10:00 - 11:00',
      'amount': '৳1,500',
      'status': 'Confirmed',
    },
    {
      'id': 'BK002',
      'venue': 'Dhanmondi Football Complex',
      'user': 'Fatima Khan',
      'date': '2024-07-21',
      'time': '14:00 - 15:00',
      'amount': '৳1,200',
      'status': 'Pending',
    },
    {
      'id': 'BK003',
      'venue': 'National Football Stadium',
      'user': 'Mohammad Ali',
      'date': '2024-07-22',
      'time': '09:00 - 12:00',
      'amount': '৳3,500',
      'status': 'Confirmed',
    },
    {
      'id': 'BK004',
      'venue': 'Uttara Football Arena',
      'user': 'Rashida Begum',
      'date': '2024-07-19',
      'time': '16:00 - 17:00',
      'amount': '৳800',
      'status': 'Completed',
    },
    {
      'id': 'BK005',
      'venue': 'Gulshan Football Ground',
      'user': 'Karim Hassan',
      'date': '2024-07-23',
      'time': '18:00 - 19:00',
      'amount': '৳1,000',
      'status': 'Pending',
    },
    {
      'id': 'BK006',
      'venue': 'University Football Field',
      'user': 'Salma Khatun',
      'date': '2024-07-18',
      'time': '08:00 - 09:00',
      'amount': '৳900',
      'status': 'Cancelled',
    },
    {
      'id': 'BK007',
      'venue': 'Elite Football Academy',
      'user': 'Abdul Mannan',
      'date': '2024-07-25',
      'time': '16:00 - 18:00',
      'amount': '৳4,000',
      'status': 'Confirmed',
    },
    {
      'id': 'BK008',
      'venue': 'Banani Football Club',
      'user': 'Nazia Ahmed',
      'date': '2024-07-26',
      'time': '17:30 - 18:30',
      'amount': '৳1,200',
      'status': 'Confirmed',
    },
    {
      'id': 'BK009',
      'venue': 'Chittagong Football Stadium',
      'user': 'Ruhul Amin',
      'date': '2024-07-24',
      'time': '14:00 - 16:00',
      'amount': '৳5,500',
      'status': 'Pending',
    },
    {
      'id': 'BK010',
      'venue': 'Mirpur Football Arena',
      'user': 'Fahmida Khan',
      'date': '2024-07-22',
      'time': '19:00 - 20:00',
      'amount': '৳750',
      'status': 'Completed',
    },
    {
      'id': 'BK011',
      'venue': 'Wari Football Field',
      'user': 'Shariful Islam',
      'date': '2024-07-27',
      'time': '15:00 - 16:30',
      'amount': '৳2,800',
      'status': 'Confirmed',
    },
    {
      'id': 'BK012',
      'venue': 'Motijheel Football Ground',
      'user': 'Nasreen Sultana',
      'date': '2024-07-28',
      'time': '07:00 - 08:00',
      'amount': '৳950',
      'status': 'Confirmed',
    },
    {
      'id': 'BK013',
      'venue': 'Rajshahi Football Complex',
      'user': 'Mizanur Rahman',
      'date': '2024-07-29',
      'time': '10:00 - 12:00',
      'amount': '৳3,200',
      'status': 'Pending',
    },
    {
      'id': 'BK014',
      'venue': 'Lalmatia Football Ground',
      'user': 'Sultana Begum',
      'date': '2024-07-21',
      'time': '17:00 - 18:00',
      'amount': '৳1,800',
      'status': 'Completed',
    },
    {
      'id': 'BK015',
      'venue': 'Mohammadpur Football Complex',
      'user': 'Jahangir Alam',
      'date': '2024-07-30',
      'time': '20:00 - 21:00',
      'amount': '৳1,500',
      'status': 'Confirmed',
    },
  ];

  void _showExportDialog(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.download_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Export Bookings',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              content: Container(
                width: isMobile ? double.maxFinite : 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select date range to export:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Date Range Selection
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateSelector(
                            'From Date',
                            _startDate,
                            (date) => setDialogState(() => _startDate = date),
                            isMobile,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildDateSelector(
                            'To Date',
                            _endDate,
                            (date) => setDialogState(() => _endDate = date),
                            isMobile,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Export Format Options
                    Text(
                      'Export Format:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // Excel Export Option
                    _buildExportOption(
                      'Excel',
                      Icons.table_chart_outlined,
                      Colors.green,
                      () => _exportToExcel(),
                      isMobile,
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Quick Date Filters
                    Text(
                      'Quick Filters:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildQuickFilter('Today', () {
                          setDialogState(() {
                            _startDate = DateTime.now();
                            _endDate = DateTime.now();
                          });
                        }),
                        _buildQuickFilter('This Week', () {
                          final now = DateTime.now();
                          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                          setDialogState(() {
                            _startDate = startOfWeek;
                            _endDate = now;
                          });
                        }),
                        _buildQuickFilter('This Month', () {
                          final now = DateTime.now();
                          setDialogState(() {
                            _startDate = DateTime(now.year, now.month, 1);
                            _endDate = now;
                          });
                        }),
                        _buildQuickFilter('All Time', () {
                          setDialogState(() {
                            _startDate = null;
                            _endDate = null;
                          });
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
    bool isMobile,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: isMobile ? 10 : 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              selectedDate != null
                  ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                  : 'Select Date',
              style: TextStyle(
                fontSize: 14,
                color: selectedDate != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isMobile,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: isMobile ? 24 : 28,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilter(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _exportToExcel() async {
    Navigator.of(context).pop();
    _showExportProgress('Excel');

    try {
      // Filter bookings by date range
      List<Map<String, dynamic>> filteredBookings = _getFilteredBookings();
      
      // Show online Excel viewer instead of downloading
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Close progress dialog
        _showOnlineExcelViewer(filteredBookings);
      });
      
    } catch (e) {
      Navigator.of(context).pop(); // Close progress dialog
      _showErrorDialog('Failed to generate Excel: $e');
    }
  }

  void _showOnlineExcelViewer(List<Map<String, dynamic>> bookings) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    void _closeDialog() {
      // Try multiple ways to close dialog safely
      try {
        Navigator.of(context).pop();
      } catch (e) {
        print('Dialog close error: $e');
        // Force close by going back to previous route
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.all(isMobile ? 16 : 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _closeDialog,
                        icon: Icon(Icons.arrow_back, color: Colors.green[700]),
                        tooltip: 'Back',
                      ),
                      Icon(
                        Icons.table_chart,
                        color: Colors.green,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VenueVista Bookings - Online Excel',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${bookings.length} records • ${_getDateRangeText()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _copyToClipboard(bookings),
                            icon: Icon(Icons.copy, color: Colors.blue),
                            tooltip: 'Copy Data',
                          ),
                          IconButton(
                            onPressed: _closeDialog,
                            icon: Icon(Icons.arrow_back, color: Colors.green[700]),
                            tooltip: 'Back to Bookings',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Excel-like Table
                Expanded(
                  child: Container(
                    color: Colors.grey[50],
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.green[100]),
                          headingTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                            fontSize: isMobile ? 12 : 14,
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: isMobile ? 11 : 13,
                            color: AppColors.textPrimary,
                          ),
                          columnSpacing: isMobile ? 16 : 24,
                          horizontalMargin: 16,
                          showCheckboxColumn: false,
                          columns: [
                            DataColumn(
                              label: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('A\nID'),
                              ),
                            ),
                            DataColumn(
                              label: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('B\nVenue'),
                              ),
                            ),
                            DataColumn(
                              label: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('C\nUser'),
                              ),
                            ),
                            DataColumn(
                              label: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('D\nDate'),
                              ),
                            ),
                            DataColumn(
                              label: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('E\nTime'),
                              ),
                            ),
                            DataColumn(
                              label: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('F\nAmount'),
                              ),
                            ),
                            DataColumn(
                              label: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('G\nStatus'),
                              ),
                            ),
                          ],
                          rows: bookings.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> booking = entry.value;
                            bool isEven = index % 2 == 0;
                            
                            return DataRow(
                              color: MaterialStateProperty.all(
                                isEven ? Colors.white : Colors.grey[50],
                              ),
                              cells: [
                                DataCell(
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text(booking['id']),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    constraints: BoxConstraints(maxWidth: 150),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      booking['venue'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    constraints: BoxConstraints(maxWidth: 120),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      booking['user'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text(booking['date']),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text(booking['time']),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      booking['amount'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(booking['status']).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        booking['status'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusColor(booking['status']),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Footer with summary
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total Records: ${bookings.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        'Completed: ${bookings.where((b) => b['status'] == 'Completed').length} • ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Pending: ${bookings.where((b) => b['status'] == 'Pending').length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
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

  String _getDateRangeText() {
    if (_startDate != null && _endDate != null) {
      return '${_startDate!.toString().substring(0, 10)} to ${_endDate!.toString().substring(0, 10)}';
    } else if (_startDate != null) {
      return 'From ${_startDate!.toString().substring(0, 10)}';
    } else if (_endDate != null) {
      return 'Until ${_endDate!.toString().substring(0, 10)}';
    }
    return 'All Time';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _copyToClipboard(List<Map<String, dynamic>> bookings) {
    String clipboardData = 'ID\tVenue\tUser\tDate\tTime\tAmount\tStatus\n';
    
    for (var booking in bookings) {
      clipboardData += '${booking['id']}\t${booking['venueName']}\t${booking['userName']}\t${booking['date']}\t${booking['time']}\t৳${booking['totalAmount']}\t${booking['status']}\n';
    }

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: clipboardData));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data copied to clipboard! Paste in any spreadsheet app.'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredBookings() {
    if (_startDate == null && _endDate == null) {
      return _demoBookings;
    }
    
    return _demoBookings.where((booking) {
      DateTime bookingDate = DateTime.parse(booking['date']);
      
      if (_startDate != null && bookingDate.isBefore(_startDate!)) {
        return false;
      }
      
      if (_endDate != null && bookingDate.isAfter(_endDate!.add(Duration(days: 1)))) {
        return false;
      }
      
      return true;
    }).toList();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Export Failed'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showExportProgress(String format) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                SizedBox(height: 16),
                Text(
                  'Generating $format...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please wait while we prepare your export',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    // Simulate export process
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }
}
