import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AdminVenuesPage extends StatefulWidget {
  const AdminVenuesPage({super.key});

  @override
  State<AdminVenuesPage> createState() => _AdminVenuesPageState();
}

class _AdminVenuesPageState extends State<AdminVenuesPage> {
  int _currentPage = 1;
  final int _itemsPerPage = 8;
  String _selectedStatus = 'Active';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final filteredVenues = _getFilteredVenues();
    final totalPages = (filteredVenues.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(
      0,
      filteredVenues.length,
    );
    final currentPageVenues = filteredVenues.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMobile ? 'Venues' : 'Venues Management',
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
                            ? 'Manage all venues'
                            : 'Manage venue listings, owners and operational status',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 16 : 24),

            // Venue Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Venues',
                    '${_demoVenues.length}',
                    Icons.location_city,
                    Colors.blue[600]!,
                    'All registered',
                    isMobile,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Active Venues',
                    '${_demoVenues.where((v) => v['status'] == 'Active').length}',
                    Icons.check_circle,
                    Colors.green[600]!,
                    'Currently open',
                    isMobile,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Under Maintenance',
                    '${_demoVenues.where((v) => v['status'] == 'Maintenance').length}',
                    Icons.build,
                    Colors.orange[600]!,
                    'Temporarily closed',
                    isMobile,
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 16 : 20),

            // Filter Section
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by Status',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFilterChip('Active', 'Active', _selectedStatus, (
                        value,
                      ) {
                        setState(() {
                          _selectedStatus = value;
                          _currentPage = 1;
                        });
                      }),
                      SizedBox(width: 8),
                      _buildFilterChip(
                        'Maintenance',
                        'Maintenance',
                        _selectedStatus,
                        (value) {
                          setState(() {
                            _selectedStatus = value;
                            _currentPage = 1;
                          });
                        },
                      ),
                      SizedBox(width: 8),
                      _buildFilterChip(
                        'Inactive',
                        'Inactive',
                        _selectedStatus,
                        (value) {
                          setState(() {
                            _selectedStatus = value;
                            _currentPage = 1;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // Venues List
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
                  // List Header
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
                          isMobile ? 'Venue List' : 'All Registered Venues',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Showing ${startIndex + 1}-${endIndex} of ${filteredVenues.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Venues List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: currentPageVenues.length,
                    separatorBuilder:
                        (context, index) =>
                            Divider(color: AppColors.borderLight, height: 1),
                    itemBuilder: (context, index) {
                      return _buildVenueListItem(
                        currentPageVenues[index],
                        isMobile,
                      );
                    },
                  ),

                  // Pagination
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
                          // Previous Button
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

                          // Page Numbers
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

                          // Next Button
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

            SizedBox(height: 40), // Bottom spacing
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String count,
    IconData icon,
    Color color,
    String subtitle,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
              Icon(Icons.trending_up, color: color, size: 16),
            ],
          ),
          SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String currentValue,
    Function(String) onTap,
  ) {
    final isSelected = currentValue == value;

    return InkWell(
      onTap: () => onTap(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildVenueListItem(Map<String, dynamic> venue, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Row(
        children: [
          // Venue Image
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
              gradient: LinearGradient(
                colors: [
                  _getVenueColor(venue['id']),
                  _getVenueColor(venue['id']).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: isMobile ? 24 : 30,
            ),
          ),
          SizedBox(width: 16),

          // Venue Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        venue['name'],
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getVenueStatusColor(
                          venue['status'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        venue['status'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getVenueStatusColor(venue['status']),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      flex: 2,
                      child: Text(
                        venue['owner'],
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      flex: 1,
                      child: Text(
                        venue['contact'],
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 14,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venue['location'],
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '৳${venue['pricePerHour']}/hr',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildVenueFeature(
                      Icons.sports_soccer,
                      '${venue['courts']} Courts',
                    ),
                    if (!isMobile) ...[
                      SizedBox(width: 12),
                      _buildVenueFeature(Icons.star, '${venue['rating']}'),
                      SizedBox(width: 12),
                      _buildVenueFeature(
                        Icons.schedule,
                        '${venue['totalBookings']} Bookings',
                      ),
                    ],
                  ],
                ),
                if (isMobile) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      _buildVenueFeature(Icons.star, '${venue['rating']}'),
                      SizedBox(width: 12),
                      _buildVenueFeature(
                        Icons.schedule,
                        '${venue['totalBookings']} Bookings',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),

          // Action Buttons
          InkWell(
            onTap: () => _showVenueDetails(venue),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child:
                  isMobile
                      ? Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.primary,
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 12,
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

  Widget _buildVenueFeature(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredVenues() {
    List<Map<String, dynamic>> filtered = _demoVenues;

    // Filter by status
    filtered =
        filtered.where((venue) => venue['status'] == _selectedStatus).toList();

    return filtered;
  }

  Color _getVenueStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green[600]!;
      case 'Maintenance':
        return Colors.orange[600]!;
      case 'Inactive':
        return Colors.red[600]!;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getVenueColor(String venueId) {
    // Generate different colors for different venues
    final colors = [
      Colors.blue[600]!,
      Colors.green[600]!,
      Colors.purple[600]!,
      Colors.orange[600]!,
      Colors.teal[600]!,
      Colors.indigo[600]!,
      Colors.red[600]!,
      Colors.brown[600]!,
      Colors.pink[600]!,
      Colors.cyan[600]!,
    ];

    final index = venueId.hashCode % colors.length;
    return colors[index.abs()];
  }

  void _showVenueDetails(Map<String, dynamic> venue) {
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        _getVenueColor(venue['id']),
                        _getVenueColor(venue['id']).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.sports_soccer,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue['name'],
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        venue['location'],
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
                    color: _getVenueStatusColor(
                      venue['status'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    venue['status'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getVenueStatusColor(venue['status']),
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Container(
            padding: EdgeInsets.all(16),
            width: isMobile ? double.maxFinite : 500,
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVenueDetailSection('Owner Information', [
                    _buildVenueDetailItem(
                      'Owner Name',
                      venue['owner'],
                      Icons.person,
                    ),
                    _buildVenueDetailItem(
                      'Contact',
                      venue['contact'],
                      Icons.phone,
                    ),
                    _buildVenueDetailItem('Email', venue['email'], Icons.email),
                    _buildVenueDetailItem(
                      'Joined',
                      venue['joinedDate'],
                      Icons.calendar_today,
                    ),
                  ], isMobile),
                  SizedBox(height: 16),
                  _buildVenueDetailSection('Venue Details', [
                    _buildVenueDetailItem(
                      'Price per Hour',
                      '৳${venue['pricePerHour']}',
                      Icons.monetization_on,
                    ),
                    _buildVenueDetailItem(
                      'Total Courts',
                      '${venue['courts']}',
                      Icons.sports_soccer,
                    ),
                    _buildVenueDetailItem(
                      'Rating',
                      '${venue['rating']}/5.0',
                      Icons.star,
                    ),
                    _buildVenueDetailItem(
                      'Type',
                      venue['type'],
                      Icons.category,
                    ),
                  ], isMobile),
                  SizedBox(height: 16),
                  _buildVenueDetailSection('Statistics', [
                    _buildVenueDetailItem(
                      'Total Bookings',
                      '${venue['totalBookings']}',
                      Icons.book_online,
                    ),
                    _buildVenueDetailItem(
                      'This Month',
                      '${venue['monthlyBookings']}',
                      Icons.trending_up,
                    ),
                    _buildVenueDetailItem(
                      'Revenue',
                      '৳${venue['revenue']}',
                      Icons.account_balance_wallet,
                    ),
                    _buildVenueDetailItem(
                      'Commission',
                      '৳${venue['commission']}',
                      Icons.percent,
                    ),
                  ], isMobile),
                  if (venue['status'] == 'Maintenance') ...[
                    SizedBox(height: 16),
                    _buildVenueDetailSection('Maintenance Info', [
                      if (venue['maintenanceReason'] != null)
                        _buildVenueDetailItem(
                          'Reason',
                          venue['maintenanceReason'],
                          Icons.build,
                        ),
                      if (venue['maintenanceStart'] != null)
                        _buildVenueDetailItem(
                          'Started',
                          venue['maintenanceStart'],
                          Icons.schedule,
                        ),
                      if (venue['estimatedEnd'] != null)
                        _buildVenueDetailItem(
                          'Estimated End',
                          venue['estimatedEnd'],
                          Icons.event,
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

  Widget _buildVenueDetailSection(
    String title,
    List<Widget> items,
    bool isMobile,
  ) {
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
              fontSize: 14,
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

  Widget _buildVenueDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          SizedBox(width: 8),
          Expanded(
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
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static final List<Map<String, dynamic>> _demoVenues = [
    {
      'id': 'V001',
      'name': 'Green Valley Sports Complex',
      'owner': 'Md. Rahman',
      'contact': '+8801712345678',
      'email': 'rahman@greenvalley.com',
      'location': 'Dhanmondi, Dhaka',
      'status': 'Active',
      'pricePerHour': 1500,
      'courts': 3,
      'rating': 4.8,
      'type': 'Futsal',
      'totalBookings': 245,
      'monthlyBookings': 32,
      'revenue': 150000,
      'commission': 15000,
      'joinedDate': '2024-01-15',
    },
    {
      'id': 'V002',
      'name': 'Elite Futsal Academy',
      'owner': 'Salam Ahmed',
      'contact': '+8801534567890',
      'email': 'info@elitefutsal.com',
      'location': 'Gulshan, Dhaka',
      'status': 'Active',
      'pricePerHour': 2000,
      'courts': 2,
      'rating': 4.9,
      'type': 'Futsal',
      'totalBookings': 189,
      'monthlyBookings': 28,
      'revenue': 220000,
      'commission': 22000,
      'joinedDate': '2024-02-20',
    },
    {
      'id': 'V003',
      'name': 'BKSP Sports Authority',
      'owner': 'Karim Uddin',
      'contact': '+8801723456789',
      'email': 'contact@bksp.gov.bd',
      'location': 'Savar, Dhaka',
      'status': 'Maintenance',
      'pricePerHour': 1200,
      'courts': 4,
      'rating': 4.6,
      'type': 'Multi-Sport',
      'totalBookings': 167,
      'monthlyBookings': 15,
      'revenue': 98000,
      'commission': 9800,
      'joinedDate': '2024-03-10',
      'maintenanceReason': 'Turf replacement and facility upgrade',
      'maintenanceStart': '2024-07-25',
      'estimatedEnd': '2024-08-15',
    },
    {
      'id': 'V004',
      'name': 'Dhanmondi Futsal Ground',
      'owner': 'Nasir Hossain',
      'contact': '+8801656789012',
      'email': 'nasir@dhanmondifutsal.com',
      'location': 'Dhanmondi, Dhaka',
      'status': 'Active',
      'pricePerHour': 1800,
      'courts': 2,
      'rating': 4.7,
      'type': 'Futsal',
      'totalBookings': 203,
      'monthlyBookings': 25,
      'revenue': 175000,
      'commission': 17500,
      'joinedDate': '2024-01-28',
    },
    {
      'id': 'V005',
      'name': 'University Football Field',
      'owner': 'Dr. Salma Khatun',
      'contact': '+8801876543210',
      'email': 'sports@university.edu.bd',
      'location': 'Dhaka University',
      'status': 'Active',
      'pricePerHour': 800,
      'courts': 2,
      'rating': 4.5,
      'type': 'Football',
      'totalBookings': 134,
      'monthlyBookings': 18,
      'revenue': 85000,
      'commission': 8500,
      'joinedDate': '2024-03-22',
    },
    {
      'id': 'V006',
      'name': 'Premium Futsal Arena',
      'owner': 'Ruhul Amin',
      'contact': '+8801789012345',
      'email': 'contact@premiumfutsal.com',
      'location': 'Banani, Dhaka',
      'status': 'Maintenance',
      'pricePerHour': 2200,
      'courts': 2,
      'rating': 4.8,
      'type': 'Futsal',
      'totalBookings': 156,
      'monthlyBookings': 8,
      'revenue': 195000,
      'commission': 19500,
      'joinedDate': '2024-04-18',
      'maintenanceReason': 'AC system repair and court maintenance',
      'maintenanceStart': '2024-07-28',
      'estimatedEnd': '2024-08-05',
    },
    {
      'id': 'V007',
      'name': 'Community Sports Center',
      'owner': 'Fatima Begum',
      'contact': '+8801890123456',
      'email': 'info@communitysports.org',
      'location': 'Uttara, Dhaka',
      'status': 'Active',
      'pricePerHour': 1300,
      'courts': 2,
      'rating': 4.4,
      'type': 'Multi-Sport',
      'totalBookings': 112,
      'monthlyBookings': 16,
      'revenue': 95000,
      'commission': 9500,
      'joinedDate': '2024-05-30',
    },
    {
      'id': 'V008',
      'name': 'Mirpur Sports Complex',
      'owner': 'Abdul Karim',
      'contact': '+8801945678901',
      'email': 'karim@mirpursports.com',
      'location': 'Mirpur, Dhaka',
      'status': 'Inactive',
      'pricePerHour': 1100,
      'courts': 3,
      'rating': 4.3,
      'type': 'Multi-Sport',
      'totalBookings': 89,
      'monthlyBookings': 5,
      'revenue': 65000,
      'commission': 6500,
      'joinedDate': '2024-06-10',
    },
  ];
}
