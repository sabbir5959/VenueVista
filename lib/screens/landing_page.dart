import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();

    // Simple loading animation
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    // Start loading animation
    _loadingController.repeat();

    // Check for auto-login
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      final isLoggedOut = prefs.getBool('is_logged_out') ?? false;

      print('🔍 Remember me: $rememberMe, Is logged out: $isLoggedOut');
      print('🔍 Current user: ${AuthService.currentUser?.email}');
      print('🔍 Is signed in: ${AuthService.isSignedIn}');

      // If user has remember me enabled and hasn't explicitly logged out
      if (rememberMe && !isLoggedOut && AuthService.isSignedIn) {
        print('✅ Auto-login successful - navigating to dashboard');

        // Wait for animation to complete
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          // Get saved role from SharedPreferences (not from user metadata)
          final savedRole = prefs.getString('saved_role') ?? 'user';
          final savedEmail = prefs.getString('saved_email') ?? 'unknown';
          print('👤 Saved role from login: $savedRole');
          print('👤 Saved email from login: $savedEmail');
          print('👤 Current user email: ${AuthService.currentUser?.email}');

          switch (savedRole) {
            case 'admin':
              Navigator.pushReplacementNamed(context, '/admin');
              break;
            case 'owner':
              Navigator.pushReplacementNamed(context, '/owner');
              break;
            default:
              Navigator.pushReplacementNamed(context, '/');
              break;
          }
        }
      } else {
        print('🏠 No auto-login - going to login page');
        // Navigate to login page after animation
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      print('❌ Auto-login check failed: $e');
      // Navigate to login on error
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[300]!, Colors.green[500]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icons/venue.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // App Name
              const Text(
                'VenueVista',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'Football Ground Booking',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Loading Animation
              AnimatedBuilder(
                animation: _loadingAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      // Loading Progress Bar
                      Container(
                        width: 200,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 200 * _loadingAnimation.value,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Loading Text
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
