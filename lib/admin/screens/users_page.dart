import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  int _currentPage = 1;
  final int _itemsPerPage = 8; // Users এর জন্য একটু বেশি রাখলাম
  
  List<Map<String, dynamic>> get _paginatedUsers {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _demoUsers.sublist(
      startIndex,
      endIndex > _demoUsers.length ? _demoUsers.length : endIndex,
    );
  }
  
  int get _totalPages => (_demoUsers.length / _itemsPerPage).ceil();

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
              isMobile ? 'Users' : 'Users Management',
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
              isMobile ? 'Manage users' : 'Manage all registered users',
              style: TextStyle(
                fontSize: isMobile ? 12 : 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 32),

            // Search and Filter Bar
            Row(
              children: [
                Expanded(
                  child: Container(
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
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: isMobile ? 'Search...' : 'Search users...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                          size: isMobile ? 20 : 24,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
                        hintStyle: TextStyle(fontSize: isMobile ? 14 : 16),
                      ),
                      style: TextStyle(fontSize: isMobile ? 14 : 16),
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 16),
                Container(
                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: AppColors.white,
                    size: isMobile ? 18 : 24,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Users List
            Container(
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
                      padding: const EdgeInsets.all(20),
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
                            'Users (${_demoUsers.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.person_add_outlined,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    // User List
                    Column(
                      children: _paginatedUsers.map((user) {
                        return _buildUserCard(user, isMobile);
                      }).toList(),
                    ),
                  ],
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
                  ' (${_demoUsers.length} total)',
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

  Widget _buildUserCard(Map<String, dynamic> user, bool isMobile) {
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
                      // Profile Picture
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          user['name'][0].toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              user['email'],
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
                          color:
                              user['status'] == 'Active'
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                user['status'] == 'Active'
                                    ? AppColors.success
                                    : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Phone and Actions Row
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user['phone'],
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
              : Row(
                children: [
                  // Desktop Layout - Original Row layout
                  // Profile Picture
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      user['name'][0].toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          user['email'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              user['phone'],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status and Actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              user['status'] == 'Active'
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                user['status'] == 'Active'
                                    ? AppColors.success
                                    : AppColors.warning,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
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

  static final List<Map<String, dynamic>> _demoUsers = [
    {
      'name': 'Ahmed Rahman',
      'email': 'ahmed.rahman@email.com',
      'phone': '+8801712345678',
      'status': 'Active',
      'joinDate': '2024-01-15',
    },
    {
      'name': 'Fatima Khan',
      'email': 'fatima.khan@email.com',
      'phone': '+8801987654321',
      'status': 'Active',
      'joinDate': '2024-02-20',
    },
    {
      'name': 'Mohammad Ali',
      'email': 'mohammad.ali@email.com',
      'phone': '+8801555123456',
      'status': 'Inactive',
      'joinDate': '2024-03-10',
    },
    {
      'name': 'Rashida Begum',
      'email': 'rashida.begum@email.com',
      'phone': '+8801666789012',
      'status': 'Active',
      'joinDate': '2024-03-25',
    },
    {
      'name': 'Karim Hassan',
      'email': 'karim.hassan@email.com',
      'phone': '+8801777890123',
      'status': 'Active',
      'joinDate': '2024-04-05',
    },
    {
      'name': 'Salma Khatun',
      'email': 'salma.khatun@email.com',
      'phone': '+8801888901234',
      'status': 'Inactive',
      'joinDate': '2024-04-18',
    },
  ];
}
