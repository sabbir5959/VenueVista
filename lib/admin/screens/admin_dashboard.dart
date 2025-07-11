import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<AdminMenuItem> _menuItems = [
    AdminMenuItem(icon: Icons.dashboard_outlined, title: 'Overview', index: 0),
    AdminMenuItem(icon: Icons.people_outline, title: 'Users', index: 1),
    AdminMenuItem(
      icon: Icons.business_outlined,
      title: 'Venue Owners',
      index: 2,
    ),
    AdminMenuItem(icon: Icons.location_on_outlined, title: 'Venues', index: 3),
    AdminMenuItem(
      icon: Icons.calendar_today_outlined,
      title: 'Bookings',
      index: 4,
    ),
    AdminMenuItem(icon: Icons.analytics_outlined, title: 'Analytics', index: 5),
    AdminMenuItem(icon: Icons.payment_outlined, title: 'Payments', index: 6),
    AdminMenuItem(icon: Icons.settings_outlined, title: 'Settings', index: 7),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_city,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'VenueVista Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        elevation: 0,
        child: Container(
          color: AppColors.surface,
          child: SafeArea(
            child: Column(
              children: [
                // Top spacing
                const SizedBox(height: 20),

                // Drawer Header
                Container(
                  height: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_city,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'VenueVista',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Menu Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      final isSelected = _selectedIndex == item.index;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _selectedIndex = item.index;
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.primary.withOpacity(
                                          0.3,
                                        ),
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary.withOpacity(
                                              0.1,
                                            ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Logout Button
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.logout_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _getSelectedPage(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return const AdminOverviewPage();
      case 1:
        return const AdminUsersPage();
      case 2:
        return const AdminOwnersPage();
      case 3:
        return const AdminVenuesPage();
      case 4:
        return const AdminBookingsPage();
      case 5:
        return const AdminAnalyticsPage();
      case 6:
        return const AdminPaymentsPage();
      case 7:
        return const AdminSettingsPage();
      default:
        return const AdminOverviewPage();
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_outlined,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Logout',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from admin panel?',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
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
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AdminMenuItem {
  final IconData icon;
  final String title;
  final int index;

  AdminMenuItem({required this.icon, required this.title, required this.index});
}

// Modern Admin Pages
class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: AppColors.background,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard_outlined,
                  size: isMobile ? 24 : 32,
                  color: AppColors.primary,
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Welcome to VenueVista Admin Panel',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 24 : 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: isMobile ? 48 : 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: isMobile ? 16 : 24),
                    Text(
                      'Overview content will be added here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Dashboard metrics and analytics coming soon',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: AppColors.textTertiary,
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
}

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_outline, size: 32, color: Color(0xFF2E7D32)),
                SizedBox(width: 16),
                Text(
                  'Users Management',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Manage all registered users',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 64,
                      color: Color(0xFF757575),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Users management content will be added here',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF757575),
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
    );
  }
}

class AdminOwnersPage extends StatelessWidget {
  const AdminOwnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: AppColors.background,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: isMobile ? 24 : 32,
                  color: AppColors.primary,
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Text(
                    'Venue Owners Management',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Manage venue owners and their properties',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 24 : 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: isMobile ? 48 : 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: isMobile ? 16 : 24),
                    Text(
                      'Venue owners management content will be added here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: AppColors.textSecondary,
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
    );
  }
}

class AdminVenuesPage extends StatelessWidget {
  const AdminVenuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: AppColors.background,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: isMobile ? 24 : 32,
                  color: AppColors.primary,
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Text(
                    'Venues Management',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Manage all venue listings and details',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 24 : 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.domain_outlined,
                      size: isMobile ? 48 : 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: isMobile ? 16 : 24),
                    Text(
                      'Venues management content will be added here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: AppColors.textSecondary,
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
    );
  }
}

class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: AppColors.background,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: isMobile ? 24 : 32,
                  color: AppColors.primary,
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Text(
                    'Bookings Management',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Track and manage all venue bookings',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 24 : 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: isMobile ? 48 : 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: isMobile ? 16 : 24),
                    Text(
                      'Bookings management content will be added here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: AppColors.textSecondary,
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
    );
  }
}

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 32,
                  color: Color(0xFF2E7D32),
                ),
                SizedBox(width: 16),
                Text(
                  'Analytics & Reports',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'View detailed analytics and generate reports',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insert_chart_outlined,
                      size: 64,
                      color: Color(0xFF757575),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Analytics and reports content will be added here',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF757575),
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
    );
  }
}

class AdminPaymentsPage extends StatelessWidget {
  const AdminPaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: AppColors.background,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment_outlined,
                  size: isMobile ? 24 : 32,
                  color: AppColors.primary,
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Text(
                    'Payments Management',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Monitor transactions and payment history',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 24 : 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: isMobile ? 48 : 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: isMobile ? 16 : 24),
                    Text(
                      'Payments management content will be added here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: AppColors.textSecondary,
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
    );
  }
}


class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  size: 32,
                  color: Color(0xFF2E7D32),
                ),
                SizedBox(width: 16),
                Text(
                  'System Settings',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Configure system preferences and settings',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.tune_outlined,
                      size: 64,
                      color: Color(0xFF757575),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'System settings content will be added here',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF757575),
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
    );
  }
}
