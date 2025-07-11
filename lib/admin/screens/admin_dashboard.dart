import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isCollapsed = false;

  final List<AdminMenuItem> _menuItems = [
    AdminMenuItem(icon: Icons.dashboard, title: 'Overview', index: 0),
    AdminMenuItem(icon: Icons.people, title: 'Users', index: 1),
    AdminMenuItem(icon: Icons.business, title: 'Venue Owners', index: 2),
    AdminMenuItem(icon: Icons.location_on, title: 'Venues', index: 3),
    AdminMenuItem(icon: Icons.calendar_today, title: 'Bookings', index: 4),
    AdminMenuItem(icon: Icons.analytics, title: 'Analytics', index: 5),
    AdminMenuItem(icon: Icons.payment, title: 'Payments', index: 6),
    AdminMenuItem(icon: Icons.settings, title: 'Settings', index: 7),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
          child: Row(
            children: [
              // Collapsible Sidebar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isCollapsed ? 80 : (isMobile ? 250 : 280),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Hamburger Menu Button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isCollapsed = !_isCollapsed;
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _isCollapsed ? Icons.menu : Icons.menu_open,
                                    color: Colors.green.shade600,
                                    size: 24,
                                  ),
                                ),
                              ),
                              if (!_isCollapsed) ...[
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'VenueVista Admin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (!_isCollapsed) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Admin User',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Super Administrator',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Menu Items
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: _menuItems.length,
                        itemBuilder: (context, index) {
                          final item = _menuItems[index];
                          final isSelected = _selectedIndex == item.index;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            child: Tooltip(
                              message: _isCollapsed ? item.title : '',
                              child: ListTile(
                                leading: Icon(
                                  item.icon,
                                  color: isSelected
                                      ? Colors.green.shade600
                                      : Colors.grey.shade600,
                                  size: 22,
                                ),
                                title: _isCollapsed
                                    ? null
                                    : Text(
                                        item.title,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.green.shade600
                                              : Colors.grey.shade700,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      ),
                                selected: isSelected,
                                selectedTileColor: Colors.green.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: _isCollapsed
                                    ? const EdgeInsets.symmetric(horizontal: 16)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = item.index;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Logout Button
                    Container(
                      margin: const EdgeInsets.all(12),
                      child: Tooltip(
                        message: _isCollapsed ? 'Logout' : '',
                        child: ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.red,
                            size: 22,
                          ),
                          title: _isCollapsed
                              ? null
                              : const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: _isCollapsed
                              ? const EdgeInsets.symmetric(horizontal: 16)
                              : null,
                          onTap: () {
                            _showLogoutDialog();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: isMobile ? 4.0 : 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _getSelectedPage(),
                  ),
                ),
              ),
            ],
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
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
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

// Simple Empty Admin Pages
class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(
                'Overview content will be added here',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Users Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(
                'Users management content will be added here',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminOwnersPage extends StatelessWidget {
  const AdminOwnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Venue Owners Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(
                'Venue owners management content will be added here',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminVenuesPage extends StatelessWidget {
  const AdminVenuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Venues Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(
                'Venues management content will be added here',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bookings Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(
                'Bookings management content will be added here',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics & Reports',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(
                'Analytics and reports content will be added here',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminPaymentsPage extends StatelessWidget {
  const AdminPaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payments Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(
                'Payments management content will be added here',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(
                'System settings content will be added here',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
