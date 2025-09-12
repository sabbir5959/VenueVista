import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../search_grounds.dart';
import '../screens/schedule_page.dart';
import '../screens/tournaments_page.dart';
import '../dashboard.dart';
import '../weather_update.dart';

class CommonDrawer extends StatefulWidget {
  const CommonDrawer({super.key});

  @override
  State<CommonDrawer> createState() => _CommonDrawerState();
}

class _CommonDrawerState extends State<CommonDrawer> {
  String userName = '';
  String userEmail = '';
  String? profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      if (user != null) {
        // Fetch user profile from user_profiles table
        try {
          final response = await Supabase.instance.client
              .from('user_profiles')
              .select('full_name, email, profile_image_url')
              .eq('id', user.id)
              .single();

          setState(() {
            userName = response['full_name'] ?? 'User';
            userEmail = response['email'] ?? user.email ?? 'No email';
            profileImageUrl = response['profile_image_url'];
            isLoading = false;
          });
        } catch (columnError) {
          // If profile_image_url column doesn't exist, try without it
          if (columnError.toString().contains('column') && 
              columnError.toString().contains('does not exist')) {
            try {
              final response = await Supabase.instance.client
                  .from('user_profiles')
                  .select('full_name, email')
                  .eq('id', user.id)
                  .single();

              setState(() {
                userName = response['full_name'] ?? 'User';
                userEmail = response['email'] ?? user.email ?? 'No email';
                profileImageUrl = null;
                isLoading = false;
              });
            } catch (fallbackError) {
              throw fallbackError;
            }
          } else {
            throw columnError;
          }
        }
      } else {
        setState(() {
          userName = 'Guest User';
          userEmail = 'Not logged in';
          profileImageUrl = null;
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching user profile: $error');
      setState(() {
        userName = 'Error loading';
        userEmail = 'Error loading';
        profileImageUrl = null;
        isLoading = false;
      });
    }
  }

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
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.green.shade700,
                            strokeWidth: 2,
                          ),
                        )
                      : profileImageUrl == null
                          ? Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.green.shade700,
                            )
                          : null,
                ),
                const SizedBox(height: 8),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail,
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
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeActivity()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.sports_soccer, color: Colors.green.shade700),
            title: const Text('Playgrounds'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SearchGrounds()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.event, color: Colors.green.shade700),
            title: const Text('Tournaments'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TournamentsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.schedule, color: Colors.green.shade700),
            title: const Text('Schedule'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SchedulePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.green.shade700),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.cloud, color: Colors.green.shade700),
            title: const Text('Weather'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WeatherUpdate()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.green.shade700),
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.green.shade700),
            ),
            onTap: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(
                          'Logout',
                          style: TextStyle(color: Colors.green.shade700),
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