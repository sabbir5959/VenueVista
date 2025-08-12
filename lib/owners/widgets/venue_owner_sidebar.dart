import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/owner_dashboard.dart';
import '../screens/tournaments_and_events.dart';
import '../screens/revenue_tracking.dart';
import '../screens/maintenance.dart';
import '../screens/cancellation_request.dart';
import '../screens/dynamic_pricing.dart';

class VenueOwnerSidebar extends StatelessWidget {
  final int selectedIndex;
  final String currentPage;

  const VenueOwnerSidebar({
    Key? key,
    this.selectedIndex = -1,
    required this.currentPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green[700]),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.sports_soccer_rounded,
                    size: 35,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Venue Owner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: const Text('Dashboard'),
            selected: currentPage == 'dashboard',
            onTap: () {
              Navigator.pop(context);
              if (currentPage != 'dashboard') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OwnerDashboard(),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events_rounded),
            title: const Text(
              'Tournaments & Events',
              overflow: TextOverflow.ellipsis,
            ),
            selected: currentPage == 'tournaments',
            onTap: () {
              Navigator.pop(context);
              if (currentPage != 'tournaments') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TournamentsAndEventsPage(),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.price_change_rounded),
            title: const Text(
              'Dynamic Pricing',
              overflow: TextOverflow.ellipsis,
            ),
            selected: currentPage == 'pricing',
            onTap: () {
              Navigator.pop(context);
              if (currentPage != 'pricing') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DynamicPricingPage(),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money_rounded),
            title: const Text('Total Earnings'),
            selected: currentPage == 'revenue',
            onTap: () {
              Navigator.pop(context);
              if (currentPage != 'revenue') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RevenueTrackingScreen(),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.build_rounded),
            title: const Text('Maintenance Schedule'),
            selected: currentPage == 'maintenance',
            onTap: () {
              Navigator.pop(context);
              if (currentPage != 'maintenance') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MaintenancePage(),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel_rounded),
            title: const Text(
              'Cancellations Request',
              overflow: TextOverflow.ellipsis,
            ),
            selected: currentPage == 'cancellations',
            onTap: () {
              Navigator.pop(context);
              if (currentPage != 'cancellations') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CancellationRequestsPage(),
                  ),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Logout'),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () async {
                          // Clear any existing snackbars
                          ScaffoldMessenger.of(context).clearSnackBars();

                          // Sign out from Supabase
                          await Supabase.instance.client.auth.signOut();

                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(); // Close drawer

                          // Navigate to login page and clear all previous routes
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
