import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/admin_venue_service.dart';

class AdminVenuesPage extends StatefulWidget {
  const AdminVenuesPage({super.key});

  @override
  State<AdminVenuesPage> createState() => _AdminVenuesPageState();
}

class _AdminVenuesPageState extends State<AdminVenuesPage> {
  int _currentPage = 1;
  final int _itemsPerPage = 4;
  String _selectedStatus = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Backend data
  List<Map<String, dynamic>> _venues = [];
  Map<String, int> _stats = {};
  bool _isLoading = false;
  int _totalCount = 0;
  int _totalPages = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadVenues();
    _loadStats();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce search to avoid too many API calls
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == _searchQuery) return;
      setState(() {
        _searchQuery = _searchController.text;
        _currentPage = 1; // Reset to first page when searching
      });
      _loadVenues();
    });
  }

  /// Load venues from backend
  Future<void> _loadVenues() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AdminVenueService.getVenues(
        page: _currentPage,
        limit: _itemsPerPage,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        statusFilter: _selectedStatus,
      );

      setState(() {
        _venues = result['venues'];
        _totalCount = result['totalCount'];
        _totalPages = result['totalPages'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Load venue statistics
  Future<void> _loadStats() async {
    try {
      final stats = await AdminVenueService.getVenueStats();
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      // Silently handle stats loading error
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

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
                IconButton(
                  onPressed: () {
                    _loadVenues();
                    _loadStats();
                  },
                  icon: Icon(Icons.refresh, color: AppColors.primary),
                  tooltip: 'Refresh',
                ),
              ],
            ),

            SizedBox(height: isMobile ? 16 : 24),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Venue Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Venues',
                    '${_stats['totalVenues'] ?? 0}',
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
                    '${_stats['activeVenues'] ?? 0}',
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
                    '${_stats['maintenanceVenues'] ?? 0}',
                    Icons.build,
                    Colors.orange[600]!,
                    'Temporarily closed',
                    isMobile,
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 16 : 20),

            // Search and Filter Section
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
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search venues by name, location, or description...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Status Filter
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
                      _buildFilterChip('All', 'All', _selectedStatus, (value) {
                        setState(() {
                          _selectedStatus = value;
                          _currentPage = 1;
                        });
                        _loadVenues();
                      }),
                      SizedBox(width: 8),
                      _buildFilterChip('Active', 'Active', _selectedStatus, (
                        value,
                      ) {
                        setState(() {
                          _selectedStatus = value;
                          _currentPage = 1;
                        });
                        _loadVenues();
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
                          _loadVenues();
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
                          _loadVenues();
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
                          'Venues (${_totalCount} total)',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Venues List
                  if (_isLoading)
                    Container(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  else if (_venues.isEmpty)
                    Container(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No venues found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters or search terms',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _venues.length,
                      separatorBuilder:
                          (context, index) =>
                              Divider(color: AppColors.borderLight, height: 1),
                      itemBuilder: (context, index) {
                        return _buildVenueListItem(_venues[index], isMobile);
                      },
                    ),

                  // Pagination
                  if (_totalPages > 1)
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
                                    ? () {
                                      setState(() => _currentPage--);
                                      _loadVenues();
                                    }
                                    : null,
                            icon: Icon(Icons.chevron_left),
                            color:
                                _currentPage > 1
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                          ),

                          // Page Numbers
                          ...List.generate(_totalPages, (index) {
                            final page = index + 1;
                            final isCurrentPage = page == _currentPage;
                            return InkWell(
                              onTap: () {
                                setState(() => _currentPage = page);
                                _loadVenues();
                              },
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
                                _currentPage < _totalPages
                                    ? () {
                                      setState(() => _currentPage++);
                                      _loadVenues();
                                    }
                                    : null,
                            icon: Icon(Icons.chevron_right),
                            color:
                                _currentPage < _totalPages
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
                        venue['owner'] is Map
                            ? (venue['owner']['full_name'] ?? 'Unknown Owner')
                            : (venue['owner']?.toString() ?? 'Unknown Owner'),
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
                        venue['owner'] is Map && venue['owner']['phone'] != null
                            ? venue['owner']['phone']
                            : 'No contact',
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
                        venue['address'] ?? venue['city'] ?? 'Unknown location',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '৳${venue['price_per_hour'] ?? 0}/hr',
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
                      '${venue['capacity'] ?? 0} Capacity',
                    ),
                    if (!isMobile) ...[
                      SizedBox(width: 12),
                      _buildVenueFeature(
                        Icons.star,
                        '${venue['rating'] ?? 0.0}',
                      ),
                      SizedBox(width: 12),
                      _buildVenueFeature(
                        Icons.info,
                        venue['ground_size'] ?? 'Standard',
                      ),
                    ],
                  ],
                ),
                if (isMobile) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      _buildVenueFeature(
                        Icons.star,
                        '${venue['rating'] ?? 0.0}',
                      ),
                      SizedBox(width: 12),
                      _buildVenueFeature(
                        Icons.info,
                        venue['ground_size'] ?? 'Standard',
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

  Color _getVenueStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green[600]!;
      case 'maintenance':
        return Colors.orange[600]!;
      case 'inactive':
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
                        venue['address'] ?? venue['city'] ?? 'Unknown location',
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
                      venue['owner'] is Map
                          ? (venue['owner']['full_name'] ?? 'Unknown Owner')
                          : (venue['owner']?.toString() ?? 'Unknown Owner'),
                      Icons.person,
                    ),
                    _buildVenueDetailItem(
                      'Contact',
                      venue['owner'] is Map && venue['owner']['phone'] != null
                          ? venue['owner']['phone']
                          : 'No contact',
                      Icons.phone,
                    ),
                    _buildVenueDetailItem(
                      'Email',
                      venue['owner'] is Map && venue['owner']['email'] != null
                          ? venue['owner']['email']
                          : 'No email',
                      Icons.email,
                    ),
                    _buildVenueDetailItem(
                      'Joined',
                      venue['owner'] is Map &&
                              venue['owner']['created_at'] != null
                          ? venue['owner']['created_at'].toString().split(
                            'T',
                          )[0]
                          : venue['created_at'] != null
                          ? venue['created_at'].toString().split('T')[0]
                          : 'Unknown',
                      Icons.calendar_today,
                    ),
                  ], isMobile),
                  SizedBox(height: 16),
                  _buildVenueDetailSection('Venue Details', [
                    _buildVenueDetailItem(
                      'Price per Hour',
                      '৳${venue['price_per_hour'] ?? 0}',
                      Icons.monetization_on,
                    ),
                    _buildVenueDetailItem(
                      'Total Capacity',
                      '${venue['capacity'] ?? 0}',
                      Icons.sports_soccer,
                    ),
                    _buildVenueDetailItem(
                      'Location',
                      venue['address'] ?? venue['city'] ?? 'Unknown location',
                      Icons.location_on,
                    ),
                    _buildVenueDetailItem(
                      'Type',
                      venue['type'] ?? 'Sports Venue',
                      Icons.category,
                    ),
                  ], isMobile),
                  SizedBox(height: 16),
                  _buildVenueDetailSection('Statistics', [
                    _buildVenueDetailItem(
                      'Venue Status',
                      venue['status'] ?? 'Unknown',
                      Icons.info,
                    ),
                    _buildVenueDetailItem(
                      'Created Date',
                      venue['created_at'] != null
                          ? venue['created_at'].toString().split('T')[0]
                          : 'Unknown',
                      Icons.calendar_today,
                    ),
                    _buildVenueDetailItem(
                      'Updated Date',
                      venue['updated_at'] != null
                          ? venue['updated_at'].toString().split('T')[0]
                          : 'Unknown',
                      Icons.update,
                    ),
                  ], isMobile),
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
}
