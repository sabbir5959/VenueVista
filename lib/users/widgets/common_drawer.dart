import 'package:flutter/material.dart';
import '../search_grounds.dart';
import '../screens/schedule_page.dart';
import '../weather_update.dart';
import '../dashboard.dart';

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  'Kawsar Arafat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'kawsar.arafat@example.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.green.shade700),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeActivity()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.sports_soccer, color: Colors.green.shade700),
            title: Text('Playgrounds'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SearchGrounds()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.event, color: Colors.green.shade700),
            title: Text('Tournaments'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to tournaments page when available
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tournaments page coming soon!')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.schedule, color: Colors.green.shade700),
            title: Text('Schedule'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SchedulePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.cloud, color: Colors.green.shade700),
            title: Text('Weather'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WeatherPage()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person, color: Colors.green.shade700),
            title: Text('Account'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to account page when available
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Account page coming soon!')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.green.shade700),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings page when available
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings page coming soon!')),
              );
            },
          ),
          Divider(thickness: 1),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.green.shade700),
            title: Text('Logout', style: TextStyle(color: Colors.green.shade700)),
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
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(); // Close drawer
                          // Navigate to login page
                          Navigator.pushReplacementNamed(context, '/login');
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
