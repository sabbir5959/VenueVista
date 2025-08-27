import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_colors.dart';

class AdminOwnersPage extends StatefulWidget {
  const AdminOwnersPage({super.key});

  @override
  State<AdminOwnersPage> createState() => _AdminOwnersPageState();
}

class _AdminOwnersPageState extends State<AdminOwnersPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  int _currentPage = 1;
  final int _itemsPerPage = 6; // Mobile এর জন্য optimal

  List<Map<String, dynamic>> _owners = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _totalOwners = 0;
  int _totalVenues = 0;
  double _totalRevenue = 0;

  List<Map<String, dynamic>> get _paginatedOwners {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _owners.sublist(
      startIndex,
      endIndex > _owners.length ? _owners.length : endIndex,
    );
  }

  int get _totalPages => (_owners.length / _itemsPerPage).ceil();

  @override
  void initState() {
    super.initState();
    _loadOwnersData();
  }

  Future<void> _loadOwnersData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🔄 Loading owners data from Supabase...');

      // Load owners from auth.users where role = 'owner'
      final ownersResponse = await _supabase
          .from('auth_users')
          .select('*')
          .eq('role', 'owner')
          .order('created_at', ascending: false);

      print('✅ Owners loaded: ${ownersResponse.length}');

      // Load venues count and revenue for each owner
      List<Map<String, dynamic>> ownersWithStats = [];

      for (var owner in ownersResponse) {
        // Get venues count for this owner
        final venuesResponse = await _supabase
            .from('venues')
            .select('id, price_per_hour')
            .eq('owner_id', owner['id']);

        // Calculate total revenue from bookings
        double totalRevenue = 0;
        if (venuesResponse.isNotEmpty) {
          final venueIds = venuesResponse.map((v) => v['id']).toList();
          final bookingsResponse = await _supabase
              .from('bookings')
              .select('total_amount')
              .inFilter('venue_id', venueIds)
              .eq('status', 'confirmed');

          for (var booking in bookingsResponse) {
            totalRevenue += (booking['total_amount'] ?? 0).toDouble();
          }
        }

        ownersWithStats.add({
          'id': owner['id'],
          'name': owner['full_name'] ?? 'N/A',
          'email': owner['email'] ?? 'N/A',
          'phone': owner['phone'] ?? 'N/A',
          'venues': venuesResponse.length,
          'revenue': '৳${totalRevenue.toStringAsFixed(0)}',
          'status': owner['email_confirmed_at'] != null ? 'Active' : 'Pending',
          'joinDate': owner['created_at'] ?? '',
        });
      }

      // Calculate total stats
      _totalOwners = ownersWithStats.length;
      _totalVenues = ownersWithStats.fold(
        0,
        (sum, owner) => sum + (owner['venues'] as int),
      );
      _totalRevenue = ownersWithStats.fold(0.0, (sum, owner) {
        String revenueStr = owner['revenue']
            .toString()
            .replaceAll('৳', '')
            .replaceAll(',', '');
        return sum + double.tryParse(revenueStr)!;
      });

      setState(() {
        _owners = ownersWithStats;
        _isLoading = false;
      });

      print('✅ Owners data loaded successfully: ${_owners.length} owners');
    } catch (e) {
      print('❌ Error loading owners data: $e');
      setState(() {
        _errorMessage = 'Failed to load owners data. Please try again.';
        _isLoading = false;
      });
    }
  }

  // Delete owner function
  Future<void> _deleteOwner(int index) async {
    final owner = _owners[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Owner'),
          content: Text(
            'Are you sure you want to delete "${owner['name']}"?\n\nThis will also delete all their venues and bookings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        print('🗑️ Deleting owner: ${owner['id']}');

        // Delete from auth_users table
        await _supabase.from('auth_users').delete().eq('id', owner['id']);

        // Reload data
        await _loadOwnersData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Owner "${owner['name']}" deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }

        print('✅ Owner deleted successfully');
      } catch (e) {
        print('❌ Error deleting owner: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete owner: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              isMobile
                  ? 'Football Venue Owners'
                  : 'Football Venue Owners Management',
              style: TextStyle(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Text(
              isMobile
                  ? 'Manage owners'
                  : 'Manage football venue owners and their properties',
              style: TextStyle(
                fontSize: isMobile ? 12 : 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 32),

            // Quick Stats or Loading/Error
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadOwnersData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildOwnerStatCard(
                      'Total Owners',
                      '$_totalOwners',
                      Icons.person_outline,
                      AppColors.primary,
                      isMobile,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildOwnerStatCard(
                      'Football Venues',
                      '$_totalVenues',
                      Icons.sports_soccer,
                      AppColors.success,
                      isMobile,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildOwnerStatCard(
                      'Total Income',
                      '৳${(_totalRevenue / 1000).toStringAsFixed(1)}K',
                      Icons.monetization_on_outlined,
                      AppColors.secondary,
                      isMobile,
                    ),
                  ),
                ],
              ),

            SizedBox(height: 24),

            // Owners List Header
            if (!_isLoading && _errorMessage.isEmpty)
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      'Venue Owners',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

            // Owners List Items
            if (!_isLoading && _errorMessage.isEmpty)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
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
                    if (_owners.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No owners found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else ...[
                      if (isMobile)
                        ..._buildMobileOwnersList()
                      else
                        ..._buildDesktopOwnersList(),

                      // Pagination
                      if (_totalPages > 1) ...[
                        Padding(
                          padding: EdgeInsets.all(isMobile ? 16 : 20),
                          child: _buildPaginationControls(isMobile),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isMobile ? 16 : 20),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            value,
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
              fontSize: isMobile ? 10 : 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMobileOwnersList() {
    return _paginatedOwners.map((owner) {
      return Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Owner Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    owner['name'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    owner['email'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            owner['status'] ?? 'Active',
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          owner['status'] ?? 'Active',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(owner['status'] ?? 'Active'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${owner['venues'] ?? 0} venues',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _deleteOwner(_owners.indexOf(owner)),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: AppColors.error,
                  ),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildDesktopOwnersList() {
    return [
      // Header Row
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Owner Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Venues',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Revenue',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Status',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 80), // Actions space
          ],
        ),
      ),

      // Owner Rows
      ..._paginatedOwners.map((owner) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.textSecondary.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Owner Details
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      owner['name'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      owner['email'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Venues
              Expanded(
                flex: 2,
                child: Text(
                  '${owner['venues'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // Revenue
              Expanded(
                flex: 2,
                child: Text(
                  owner['revenue'] ?? '৳0',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // Status
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      owner['status'] ?? 'Active',
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    owner['status'] ?? 'Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(owner['status'] ?? 'Active'),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _deleteOwner(_owners.indexOf(owner)),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.error,
                    ),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    ];
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'suspended':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildPaginationControls(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed:
              _currentPage > 1
                  ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                  : null,
          icon: Icon(Icons.chevron_left),
        ),
        Text(
          '$_currentPage of $_totalPages',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        IconButton(
          onPressed:
              _currentPage < _totalPages
                  ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                  : null,
          icon: Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
