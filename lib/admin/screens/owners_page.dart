import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AdminOwnersPage extends StatefulWidget {
  const AdminOwnersPage({super.key});

  @override
  State<AdminOwnersPage> createState() => _AdminOwnersPageState();
}

class _AdminOwnersPageState extends State<AdminOwnersPage> {
  int _currentPage = 1;
  final int _itemsPerPage = 6; // Mobile এর জন্য optimal
  
  List<Map<String, dynamic>> get _paginatedOwners {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _demoOwners.sublist(
      startIndex,
      endIndex > _demoOwners.length ? _demoOwners.length : endIndex,
    );
  }
  
  int get _totalPages => (_demoOwners.length / _itemsPerPage).ceil();

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

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildOwnerStatCard(
                    'Total Owners',
                    '127',
                    Icons.person_outline,
                    AppColors.primary,
                    isMobile,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildOwnerStatCard(
                    'Football Venues',
                    '145',
                    Icons.sports_soccer,
                    AppColors.success,
                    isMobile,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildOwnerStatCard(
                    'Monthly Revenue',
                    '৳2.5L',
                    Icons.monetization_on_outlined,
                    AppColors.secondary,
                    isMobile,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Owners List Header
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
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 12,
                      vertical: isMobile ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Add New',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Owners List Items
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
                children: _paginatedOwners.map((owner) {
                  return _buildOwnerCard(owner, isMobile);
                }).toList(),
              ),
            ),

            // Pagination Controls
            const SizedBox(height: 20),
            _buildPaginationControls(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 16,
      ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          _buildPaginationButton(
            icon: Icons.chevron_left,
            text: isMobile ? '' : 'Previous',
            onPressed: _currentPage > 1 ? _goToPreviousPage : null,
            isMobile: isMobile,
          ),
          
          // Page Numbers
          Row(
            children: [
              if (!isMobile) ...[
                Text(
                  'Page ',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$_currentPage',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                ' of $_totalPages',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!isMobile) ...[
                Text(
                  ' (${_demoOwners.length} total)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          
          // Next Button
          _buildPaginationButton(
            icon: Icons.chevron_right,
            text: isMobile ? '' : 'Next',
            onPressed: _currentPage < _totalPages ? _goToNextPage : null,
            isMobile: isMobile,
            isNext: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
    required bool isMobile,
    bool isNext = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: onPressed != null 
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onPressed != null 
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isNext && !isMobile) ...[
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: onPressed != null 
                    ? AppColors.primary
                    : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              icon,
              size: isMobile ? 20 : 16,
              color: onPressed != null 
                ? AppColors.primary
                : AppColors.textSecondary,
            ),
            if (isNext && !isMobile) ...[
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: onPressed != null 
                    ? AppColors.primary
                    : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
    }
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: isMobile ? 20 : 24),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
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
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerCard(Map<String, dynamic> owner, bool isMobile) {
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
                      // Owner Info
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.secondary.withOpacity(0.1),
                        child: Icon(
                          Icons.business,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              owner['name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              owner['email'],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            owner['status'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          owner['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(owner['status']),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Venue Info and Actions Row
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${owner['venues']} venues',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          owner['revenue'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Actions
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                          SizedBox(width: 4),
                          IconButton(
                            onPressed: () {},
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
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Owner Info
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.secondary.withOpacity(
                                0.1,
                              ),
                              child: Icon(
                                Icons.business,
                                color: AppColors.secondary,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    owner['name'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    owner['email'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
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
                          color: _getStatusColor(
                            owner['status'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          owner['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(owner['status']),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Venue Info
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${owner['venues']} venues',
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
                              Icons.monetization_on_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              owner['revenue'],
                              style: TextStyle(
                                fontSize: 14,
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
                            onPressed: () {},
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            onPressed: () {},
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
                ],
              ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return AppColors.success;
      case 'Suspended':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  static final List<Map<String, dynamic>> _demoOwners = [
    {
      'name': 'Green Valley Football Club',
      'email': 'info@greenvalley.com',
      'venues': 3,
      'revenue': '৳45,000',
      'status': 'Active',
      'joinDate': '2024-01-10',
    },
    {
      'name': 'Dhanmondi Football Complex',
      'email': 'admin@dhanmondifootball.com',
      'venues': 5,
      'revenue': '৳78,500',
      'status': 'Active',
      'joinDate': '2024-01-25',
    },
    {
      'name': 'Elite Football Arena',
      'email': 'info@elitefootball.com',
      'venues': 4,
      'revenue': '৳67,200',
      'status': 'Active',
      'joinDate': '2024-02-12',
    },
    {
      'name': 'Metro Football Ground',
      'email': 'admin@metrofootball.com',
      'venues': 1,
      'revenue': '৳15,800',
      'status': 'Suspended',
      'joinDate': '2024-03-20',
    },
    {
      'name': 'Gulshan Football Center',
      'email': 'contact@gulshanfootball.com',
      'venues': 2,
      'revenue': '৳38,400',
      'status': 'Active',
      'joinDate': '2024-04-05',
    },
    {
      'name': 'Premier Football Complex',
      'email': 'info@premierfootball.com',
      'venues': 6,
      'revenue': '৳95,600',
      'status': 'Active',
      'joinDate': '2024-01-30',
    },
    {
      'name': 'Uttara Football Academy',
      'email': 'admin@uttarafootball.com',
      'venues': 3,
      'revenue': '৳52,300',
      'status': 'Active',
      'joinDate': '2024-03-18',
    },
  ];
}
