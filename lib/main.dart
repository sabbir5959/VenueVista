import 'package:flutter/material.dart';
import 'services/supabase_config.dart';
import 'services/auth_service.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/registration_page.dart';
import 'admin/screens/admin_dashboard.dart';
import 'owners/screens/owner_dashboard.dart';
import 'users/dashboard.dart';
import 'users/screens/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase through our config service
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handleIncomingLinks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _checkAuthState();
    }
  }

  void _checkAuthState() async {
    final user = AuthService.currentUser;
    if (user != null) {
      // You can trigger UI updates or navigation here
    }
  }

  void _handleIncomingLinks() {
    // Deep link handling delegated to Supabase
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VenueVista',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      initialRoute: '/landing',
      routes: {
        '/': (context) => const HomeActivity(),
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/admin': (context) => const AdminDashboard(),
        '/owner': (context) => const OwnerDashboard(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
