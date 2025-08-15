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
  int _currentPage = 1;
  final int _itemsPerPage = 8;
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final filteredBookings = _getFilteredBookings();
    final totalPages = (filteredBookings.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(
      0,
      filteredBookings.length,
    );
    final currentPageBookings = filteredBookings.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMobile ? 'Bookings' : 'Bookings Management',
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isMobile
                            ? 'Manage all venue reservations'
                            : 'Monitor and track all football venue reservations and customer bookings',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
               
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _showExportDialog(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.download_outlined,
                          color: Colors.white,
                          size: isMobile ? 18 : 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Export',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 20 : 32),

            
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 2 : 4,
              childAspectRatio: isMobile ? 1.3 : 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Total Bookings',
                  '${_demoBookings.length}',
                  Icons.sports_soccer,
                  Colors.blue[600]!,
                  isMobile,
                  'All',
                ),
                _buildStatCard(
                  'Confirmed',
                  '${_demoBookings.where((b) => b['status'] == 'Confirmed').length}',
                  Icons.check_circle_outline,
                  Colors.green[600]!,
                  isMobile,
                  'Confirmed',
                ),
                _buildStatCard(
                  'Completed',
                  '${_demoBookings.where((b) => b['status'] == 'Completed').length}',
                  Icons.done_all_outlined,
                  Colors.purple[600]!,
                  isMobile,
                  'Completed',
                ),
                _buildStatCard(
                  'Cancel Requests',
                  '${_demoBookings.where((b) => b['status'] == 'Cancelled').length}',
                  Icons.cancel_outlined,
                  Colors.red[600]!,
                  isMobile,
                  'Cancelled',
                ),
              ],
            ),

            SizedBox(height: isMobile ? 20 : 24),

       
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  
                  Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isMobile
                              ? 'Recent Bookings'
                              : 'Football Venue Bookings History',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Showing ${startIndex + 1}-${endIndex} of ${filteredBookings.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: currentPageBookings.length,
                    separatorBuilder:
                        (context, index) =>
                            Divider(color: AppColors.borderLight, height: 1),
                    itemBuilder: (context, index) {
                      return _buildBookingListItem(
                        currentPageBookings[index],
                        isMobile,
                      );
                    },
                  ),

                 
                  if (totalPages > 1)
                    Container(
                      padding: EdgeInsets.all(isMobile ? 16 : 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         
                          IconButton(
                            onPressed:
                                _currentPage > 1
                                    ? () => setState(() => _currentPage--)
                                    : null,
                            icon: Icon(Icons.chevron_left),
                            color:
                                _currentPage > 1
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                          ),

                          
                          ...List.generate(totalPages, (index) {
                            final page = index + 1;
                            final isCurrentPage = page == _currentPage;
                            return InkWell(
                              onTap: () => setState(() => _currentPage = page),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isCurrentPage
                                          ? AppColors.primary
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        isCurrentPage
                                            ? AppColors.primary
                                            : AppColors.borderLight,
                                  ),
                                ),
                                child: Text(
                                  '$page',
                                  style: TextStyle(
                                    color:
                                        isCurrentPage
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                    fontWeight:
                                        isCurrentPage
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }),

                          
                          IconButton(
                            onPressed:
                                _currentPage < totalPages
                                    ? () => setState(() => _currentPage++)
                                    : null,
                            icon: Icon(Icons.chevron_right),
                            color:
                                _currentPage < totalPages
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
    String filterStatus,
  ) {
    final isSelected = _selectedStatus == filterStatus;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = filterStatus;
          _currentPage = 1; 
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              isSelected
                  ? Border.all(color: color, width: 3)
                  : Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected ? color.withOpacity(0.2) : AppColors.shadowLight,
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: isMobile ? 20 : 24),
            ),
            SizedBox(height: isMobile ? 8 : 10),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 2),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingListItem(Map<String, dynamic> booking, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Row(
        children: [
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking['venue'],
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getBookingStatusColor(
                          booking['status'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        booking['status'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getBookingStatusColor(booking['status']),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Booked by ${booking['user']}',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
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
                    SizedBox(width: 16),
                    Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      booking['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Spacer(),
                    Text(
                      booking['amount'],
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          
          InkWell(
            onTap: () => _showBookingDetails(booking),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12,
                vertical: isMobile ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: isMobile ? 16 : 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    isMobile ? 'Details' : 'Show Details',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredBookings() {
    List<Map<String, dynamic>> filtered = _demoBookings;

    // Filter by status
    if (_selectedStatus != 'All') {
      filtered =
          filtered
              .where((booking) => booking['status'] == _selectedStatus)
              .toList();
    }

    
    if (_startDate != null || _endDate != null) {
      filtered =
          filtered.where((booking) {
            DateTime bookingDate = DateTime.parse(booking['date']);

            if (_startDate != null && bookingDate.isBefore(_startDate!)) {
              return false;
            }

            if (_endDate != null &&
                bookingDate.isAfter(_endDate!.add(Duration(days: 1)))) {
              return false;
            }

            return true;
          }).toList();
    }

    return filtered;
  }

  Color _getBookingStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green[600]!;
      case 'Cancelled':
        return Colors.red[600]!;
      case 'Completed':
        return Colors.purple[600]!;
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
      'status': 'Confirmed',
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
      'status': 'Confirmed',
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
      'status': 'Cancelled',
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
      'status': 'Cancelled',
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
                width: isMobile ? double.maxFinite : 450,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Text(
                        'Export Format',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Choose your preferred export format',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 16),

                     
                      Row(
                        children: [
                          Expanded(
                            child: _buildStandardExportOption(
                              'Excel',
                              Icons.table_chart,
                              Colors.green[600]!,
                              'Spreadsheet format',
                              () => _exportToExcel(),
                              isMobile,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildStandardExportOption(
                              'PDF',
                              Icons.picture_as_pdf,
                              Colors.red[600]!,
                              'Document format',
                              () => _exportToPDF(),
                              isMobile,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      
                      Text(
                        'Filter Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16),

                     
                      Text(
                        'Booking Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.surface,
                        ),
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          isExpanded: true,
                          underline: SizedBox(),
                          icon: Icon(
                            Icons.expand_more,
                            color: AppColors.textSecondary,
                          ),
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'All',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.list_alt,
                                    size: 18,
                                    color: Colors.blue[600],
                                  ),
                                  SizedBox(width: 8),
                                  Text('All Bookings'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Confirmed',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: Colors.green[600],
                                  ),
                                  SizedBox(width: 8),
                                  Text('Confirmed Only'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Completed',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.done_all,
                                    size: 18,
                                    color: Colors.purple[600],
                                  ),
                                  SizedBox(width: 8),
                                  Text('Completed Only'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Cancelled',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.cancel,
                                    size: 18,
                                    color: Colors.red[600],
                                  ),
                                  SizedBox(width: 8),
                                  Text('Cancelled Only'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setDialogState(() {
                                _selectedStatus = newValue;
                              });
                            }
                          },
                        ),
                      ),

                      SizedBox(height: 16),

                      
                      Text(
                        'Time Period',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStandardTimePeriodChip('Today', () {
                            setDialogState(() {
                              _startDate = DateTime.now();
                              _endDate = DateTime.now();
                            });
                          }),
                          _buildStandardTimePeriodChip('This Week', () {
                            final now = DateTime.now();
                            final startOfWeek = now.subtract(
                              Duration(days: now.weekday - 1),
                            );
                            setDialogState(() {
                              _startDate = startOfWeek;
                              _endDate = now;
                            });
                          }),
                          _buildStandardTimePeriodChip('This Month', () {
                            final now = DateTime.now();
                            setDialogState(() {
                              _startDate = DateTime(now.year, now.month, 1);
                              _endDate = now;
                            });
                          }),
                          _buildStandardTimePeriodChip('All Time', () {
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

  Widget _buildStandardExportOption(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
    bool isMobile,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isMobile ? 28 : 32),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardTimePeriodChip(String label, VoidCallback onTap) {
    final isSelected = _getTimePeriodSelection(label);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1.5,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool _getTimePeriodSelection(String label) {
    final now = DateTime.now();

    switch (label) {
      case 'Today':
        return _startDate != null &&
            _endDate != null &&
            _startDate!.year == now.year &&
            _startDate!.month == now.month &&
            _startDate!.day == now.day &&
            _endDate!.year == now.year &&
            _endDate!.month == now.month &&
            _endDate!.day == now.day;

      case 'This Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return _startDate != null &&
            _endDate != null &&
            _startDate!.year == startOfWeek.year &&
            _startDate!.month == startOfWeek.month &&
            _startDate!.day == startOfWeek.day;

      case 'This Month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        return _startDate != null &&
            _endDate != null &&
            _startDate!.year == startOfMonth.year &&
            _startDate!.month == startOfMonth.month &&
            _startDate!.day == startOfMonth.day;

      case 'All Time':
        return _startDate == null && _endDate == null;

      default:
        return false;
    }
  }

  void _exportToExcel() async {
   
    Navigator.of(context).pop(); 

   
    _showExportProgress('Excel');

    try {
      
      List<Map<String, dynamic>> filteredBookings = _getFilteredBookings();

      
      await Future.delayed(Duration(seconds: 2));
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); 
      }

      
      _showOnlineExcelViewer(filteredBookings);
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); 
      }
      _showErrorDialog('Failed to generate Excel: $e');
    }
  }

  void _exportToPDF() async {
    
    Navigator.of(context).pop();

    
    _showExportProgress('PDF');

    try {
     
      List<Map<String, dynamic>> filteredBookings = _getFilteredBookings();

      
      await Future.delayed(Duration(seconds: 2));
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); 
      }

      
      _showOnlinePDFViewer(filteredBookings);
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); 
      }
      _showErrorDialog('Failed to generate PDF: $e');
    }
  }

  void _showOnlineExcelViewer(List<Map<String, dynamic>> bookings) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54, 
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.table_chart, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Excel Export Preview',
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
            ],
          ),
          content: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(bookings),
                        icon: Icon(Icons.copy, size: 16),
                        label: Text('Copy Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.green[100],
                          ),
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
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Venue')),
                            DataColumn(label: Text('User')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Time')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows:
                              bookings.map((booking) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(booking['id'])),
                                    DataCell(Text(booking['venue'])),
                                    DataCell(Text(booking['user'])),
                                    DataCell(Text(booking['date'])),
                                    DataCell(Text(booking['time'])),
                                    DataCell(Text(booking['amount'])),
                                    DataCell(
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            booking['status'],
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          booking['status'],
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: _getStatusColor(
                                              booking['status'],
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

                SizedBox(height: 16),

                
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total: ${bookings.length} records',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        'Completed: ${bookings.where((b) => b['status'] == 'Completed').length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOnlinePDFViewer(List<Map<String, dynamic>> bookings) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54, 
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PDF Export Preview',
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
            ],
          ),
          content: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(bookings),
                        icon: Icon(Icons.copy, size: 16),
                        label: Text('Copy Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'VenueVista',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Bookings Report',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _getDateRangeText(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Divider(thickness: 2, color: AppColors.primary),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),

                         
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children:
                                    bookings.map((booking) {
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 12),
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Booking #${booking['id']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(
                                                      booking['status'],
                                                    ).withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    booking['status'],
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: _getStatusColor(
                                                        booking['status'],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Venue: ${booking['venue']}',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              'User: ${booking['user']}',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              'Date: ${booking['date']}',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              'Time: ${booking['time']}',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              'Amount: ${booking['amount']}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total: ${bookings.length} records',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        'Completed: ${bookings.where((b) => b['status'] == 'Completed').length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
        return Colors.purple[600]!;
      case 'confirmed':
        return Colors.green[600]!;
      case 'cancelled':
        return Colors.red[600]!;
      default:
        return Colors.grey;
    }
  }

  void _copyToClipboard(List<Map<String, dynamic>> bookings) {
    String clipboardData = 'ID\tVenue\tUser\tDate\tTime\tAmount\tStatus\n';

    for (var booking in bookings) {
      clipboardData +=
          '${booking['id']}\t${booking['venue']}\t${booking['user']}\t${booking['date']}\t${booking['time']}\t${booking['amount']}\t${booking['status']}\n';
    }

    
    Clipboard.setData(ClipboardData(text: clipboardData));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Data copied to clipboard! Paste in any spreadsheet app.',
        ),
        backgroundColor: Colors.blue,
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Padding(
            padding: EdgeInsets.all(16), 
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getBookingStatusColor(
                      booking['status'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.sports_soccer,
                    color: _getBookingStatusColor(booking['status']),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Details',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'ID: ${booking['id']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getBookingStatusColor(
                      booking['status'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking['status'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getBookingStatusColor(booking['status']),
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Container(
            padding: EdgeInsets.all(16), 
            width: isMobile ? double.maxFinite : 400,
            height: MediaQuery.of(context).size.height * 0.6, 
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  _buildDetailSection('Venue Information', [
                    _buildDetailItem(
                      'Venue Name',
                      booking['venue'],
                      Icons.location_on_outlined,
                    ),
                    _buildDetailItem(
                      'Booking ID',
                      booking['id'],
                      Icons.confirmation_number_outlined,
                    ),
                  ], isMobile),

                  SizedBox(height: 12),

                  
                  _buildDetailSection('Customer Information', [
                    _buildDetailItem(
                      'Customer Name',
                      booking['user'],
                      Icons.person_outline,
                    ),
                    _buildDetailItem(
                      'Contact',
                      '+880 1712-345678',
                      Icons.phone_outlined,
                    ),
                    _buildDetailItem(
                      'Email',
                      '${booking['user'].toLowerCase().replaceAll(' ', '.')}@email.com',
                      Icons.email_outlined,
                    ),
                  ], isMobile),

                  SizedBox(height: 12),

                  
                  _buildDetailSection('Booking Information', [
                    _buildDetailItem(
                      'Date',
                      booking['date'],
                      Icons.calendar_today_outlined,
                    ),
                    _buildDetailItem(
                      'Time Slot',
                      booking['time'],
                      Icons.access_time_outlined,
                    ),
                    _buildDetailItem(
                      'Duration',
                      '1 Hour',
                      Icons.timer_outlined,
                    ),
                    _buildDetailItem(
                      'Total Amount',
                      booking['amount'],
                      Icons.payments_outlined,
                    ),
                  ], isMobile),

                  SizedBox(height: 12),

                  
                  _buildDetailSection('Status Information', [
                    _buildDetailItem(
                      'Current Status',
                      booking['status'],
                      Icons.flag_outlined,
                    ),
                    _buildDetailItem(
                      'Booked On',
                      '2024-07-15 14:30',
                      Icons.schedule_outlined,
                    ),
                    _buildDetailItem(
                      'Payment Status',
                      booking['status'] == 'Cancelled' ? 'Refunded' : 'Paid',
                      Icons.payment_outlined,
                    ),
                  ], isMobile),

                  
                  if (booking['status'] == 'Cancelled') ...[
                    SizedBox(height: 12),
                    _buildDetailSection('Cancellation Details', [
                      _buildDetailItem(
                        'Cancelled On',
                        '2024-07-16 09:15',
                        Icons.cancel_outlined,
                      ),
                      _buildDetailItem(
                        'Reason',
                        'Customer requested due to emergency',
                        Icons.info_outline,
                      ),
                      _buildDetailItem(
                        'Refund Status',
                        'Completed',
                        Icons.account_balance_wallet_outlined,
                      ),
                    ], isMobile),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

    
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }
}
