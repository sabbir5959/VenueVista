import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'dart:typed_data';
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

  // Edit owner function
  void _editOwner(int index) {
    final owner = _demoOwners[index];
    final isMobile = MediaQuery.of(context).size.width < 768;
    _showAddVenueOwnerDialog(
      context,
      isMobile,
      editingOwner: owner,
      editingIndex: index,
    );
  }

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
                  GestureDetector(
                    onTap: () => _showAddVenueOwnerDialog(context, isMobile),
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
                            Icons.add,
                            color: AppColors.white,
                            size: isMobile ? 14 : 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Add New',
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
                children:
                    _paginatedOwners.map((owner) {
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
          color:
              onPressed != null
                  ? AppColors.primary.withOpacity(0.05)
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                onPressed != null
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
                  color:
                      onPressed != null
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
              color:
                  onPressed != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
            ),
            if (isNext && !isMobile) ...[
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      onPressed != null
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
                            onPressed:
                                () => _editOwner(_demoOwners.indexOf(owner)),
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
                            onPressed:
                                () => _deleteOwner(_demoOwners.indexOf(owner)),
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
                  // Additional info for new venue owners
                  if (owner.containsKey('phone') ||
                      owner.containsKey('groundSize') ||
                      owner.containsKey('capacity') ||
                      owner.containsKey('pricePerHour')) ...[
                    SizedBox(height: 8),
                    Divider(color: AppColors.borderLight, height: 1),
                    SizedBox(height: 8),
                    Wrap(
                      runSpacing: 4,
                      spacing: 12,
                      children: [
                        if (owner.containsKey('phone'))
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                owner['phone'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        if (owner.containsKey('groundSize'))
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.aspect_ratio_outlined,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                owner['groundSize'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        if (owner.containsKey('capacity'))
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${owner['capacity']} players',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        if (owner.containsKey('pricePerHour'))
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '৳${owner['pricePerHour']}/hr',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
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
                            onPressed:
                                () => _editOwner(_demoOwners.indexOf(owner)),
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
                            onPressed:
                                () => _deleteOwner(_demoOwners.indexOf(owner)),
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
                  // Additional info for new venue owners
                  if (owner.containsKey('phone') ||
                      owner.containsKey('groundSize') ||
                      owner.containsKey('capacity') ||
                      owner.containsKey('pricePerHour')) ...[
                    SizedBox(height: 12),
                    Divider(color: AppColors.borderLight, height: 1),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        if (owner.containsKey('phone'))
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  owner['phone'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (owner.containsKey('groundSize'))
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.aspect_ratio_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  owner['groundSize'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (owner.containsKey('capacity'))
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${owner['capacity']} players',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (owner.containsKey('pricePerHour'))
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '৳${owner['pricePerHour']}/hr',
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
                  ],
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

  void _showAddVenueOwnerDialog(
    BuildContext context,
    bool isMobile, {
    Map<String, dynamic>? editingOwner,
    int? editingIndex,
  }) {
    final TextEditingController idController = TextEditingController(
      text: editingOwner?['id'] ?? '',
    );
    final TextEditingController nameController = TextEditingController(
      text: editingOwner?['name'] ?? '',
    );
    final TextEditingController phoneController = TextEditingController(
      text: editingOwner?['phone'] ?? '',
    );
    final TextEditingController emailController = TextEditingController(
      text: editingOwner?['email'] ?? '',
    );
    final TextEditingController groundSizeController = TextEditingController(
      text: editingOwner?['groundSize'] ?? '',
    );
    final TextEditingController capacityController = TextEditingController(
      text: editingOwner?['capacity']?.toString() ?? '',
    );
    final TextEditingController priceController = TextEditingController(
      text: editingOwner?['pricePerHour']?.toString() ?? '',
    );
    String? selectedGroundPicture = editingOwner?['groundPicture'];
    dynamic selectedImageFile; // Can be File or Uint8List
    Uint8List? webImageBytes;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_business,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      editingOwner != null
                          ? 'Edit Venue Owner'
                          : 'Add New Venue Owner',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: isMobile ? MediaQuery.of(context).size.width * 0.9 : 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Owner ID
                      Text(
                        'Owner ID',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: idController,
                        decoration: InputDecoration(
                          hintText: 'Enter unique owner ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Owner Name
                      Text(
                        'Owner Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Enter owner/business name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone Number
                      Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter email address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ground Picture
                      Text(
                        'Ground Picture',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();

                          // Show option to pick from gallery or camera
                          final ImageSource? source =
                              await showDialog<ImageSource>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Select Image Source'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(
                                            Icons.photo_library,
                                          ),
                                          title: const Text('Gallery'),
                                          onTap:
                                              () => Navigator.pop(
                                                context,
                                                ImageSource.gallery,
                                              ),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt),
                                          title: const Text('Camera'),
                                          onTap:
                                              () => Navigator.pop(
                                                context,
                                                ImageSource.camera,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );

                          if (source != null) {
                            try {
                              final XFile? image = await picker.pickImage(
                                source: source,
                              );
                              if (image != null) {
                                if (kIsWeb) {
                                  // For web platform, read as bytes
                                  final bytes = await image.readAsBytes();
                                  setDialogState(() {
                                    webImageBytes = bytes;
                                    selectedImageFile = bytes;
                                    selectedGroundPicture = image.name;
                                  });
                                } else {
                                  // For mobile/desktop platforms
                                  setDialogState(() {
                                    selectedImageFile = image.path;
                                    selectedGroundPicture = image.name;
                                  });
                                }
                              }
                            } catch (e) {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error picking image: $e'),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          height: selectedImageFile != null ? 120 : 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              selectedImageFile != null
                                  ? Stack(
                                    children: [
                                      // Image preview
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            kIsWeb
                                                ? Image.memory(
                                                  webImageBytes!,
                                                  width: double.infinity,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                )
                                                : Image.network(
                                                  selectedImageFile!,
                                                  width: double.infinity,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Container(
                                                      width: double.infinity,
                                                      height: 120,
                                                      color:
                                                          Colors.grey.shade200,
                                                      child: const Icon(
                                                        Icons.error,
                                                      ),
                                                    );
                                                  },
                                                ),
                                      ),
                                      // Remove button
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setDialogState(() {
                                              selectedImageFile = null;
                                              webImageBytes = null;
                                              selectedGroundPicture = null;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(
                                                0.8,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        child: Icon(
                                          Icons.add_photo_alternate_outlined,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Select ground picture',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ground Size
                      Text(
                        'Ground Size',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: groundSizeController,
                        decoration: InputDecoration(
                          hintText: 'e.g., 100x60 meters',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Player Capacity
                      Text(
                        'Player Capacity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: capacityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'How many players can play',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price/Rate
                      Text(
                        'Price per Hour (৳)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter price per hour',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validate fields
                    if (idController.text.isEmpty ||
                        nameController.text.isEmpty ||
                        phoneController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        groundSizeController.text.isEmpty ||
                        capacityController.text.isEmpty ||
                        priceController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill all required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Add or update venue owner
                    setState(() {
                      final ownerData = {
                        'id': idController.text,
                        'name': nameController.text,
                        'phone': phoneController.text,
                        'email': emailController.text,
                        'groundPicture': selectedGroundPicture ?? 'default.jpg',
                        'groundSize': groundSizeController.text,
                        'capacity': int.tryParse(capacityController.text) ?? 0,
                        'pricePerHour': int.tryParse(priceController.text) ?? 0,
                        'venues':
                            editingOwner?['venues'] ??
                            1, // Keep existing or default
                        'revenue':
                            editingOwner?['revenue'] ??
                            '৳0', // Keep existing or default
                        'status': editingOwner?['status'] ?? 'Active',
                        'joinDate':
                            editingOwner?['joinDate'] ??
                            DateTime.now().toString().substring(0, 10),
                      };

                      if (editingIndex != null) {
                        // Update existing owner
                        _demoOwners[editingIndex] = ownerData;
                      } else {
                        // Add new owner
                        _demoOwners.add(ownerData);
                      }
                    });

                    Navigator.of(context).pop();

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          editingIndex != null
                              ? 'Venue owner updated successfully!'
                              : 'Venue owner added successfully!',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
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
                  child: Text(
                    editingIndex != null ? 'Update Owner' : 'Add Owner',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
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
