import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
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

  // Delete owner function
  void _deleteOwner(int index) {
    final owner = _demoOwners[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Owner'),
          content: Text('Are you sure you want to delete "${owner['name']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _demoOwners.removeAt(index);
                  // Adjust current page if needed
                  if (_paginatedOwners.isEmpty && _currentPage > 1) {
                    _currentPage--;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Owner "${owner['name']}" deleted successfully',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
                    'Total Income',
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
                children: [
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
                  onPressed: () => _deleteOwner(_demoOwners.indexOf(owner)),
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
                    onPressed: () => _deleteOwner(_demoOwners.indexOf(owner)),
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

  static final List<Map<String, dynamic>> _demoOwners = [
    {
      'id': 'GV001',
      'name': 'Green Valley Football Club',
      'phone': '+880-1234-567890',
      'email': 'info@greenvalley.com',
      'groundSize': '100x70 meters',
      'capacity': 22,
      'pricePerHour': 1500,
      'venues': 3,
      'revenue': '৳45,000',
      'status': 'Active',
      'joinDate': '2024-01-10',
    },
    {
      'id': 'DFC001',
      'name': 'Dhanmondi Football Complex',
      'phone': '+880-1987-654321',
      'email': 'admin@dhanmondifootball.com',
      'groundSize': '110x70 meters',
      'capacity': 24,
      'pricePerHour': 2000,
      'venues': 5,
      'revenue': '৳78,500',
      'status': 'Active',
      'joinDate': '2024-01-25',
    },
    {
      'id': 'EFA001',
      'name': 'Elite Football Arena',
      'phone': '+880-1555-123456',
      'email': 'info@elitefootball.com',
      'groundSize': '105x68 meters',
      'capacity': 20,
      'pricePerHour': 1800,
      'venues': 4,
      'revenue': '৳67,200',
      'status': 'Active',
      'joinDate': '2024-02-12',
    },
    {
      'id': 'MFG001',
      'name': 'Metro Football Ground',
      'phone': '+880-1333-789012',
      'email': 'admin@metrofootball.com',
      'groundSize': '95x65 meters',
      'capacity': 18,
      'pricePerHour': 1200,
      'venues': 1,
      'revenue': '৳15,800',
      'status': 'Suspended',
      'joinDate': '2024-03-20',
    },
    {
      'id': 'GFC001',
      'name': 'Gulshan Football Center',
      'phone': '+880-1444-567890',
      'email': 'contact@gulshanfootball.com',
      'groundSize': '100x68 meters',
      'capacity': 22,
      'pricePerHour': 1600,
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
