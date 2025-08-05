import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/registration_page.dart';
import 'screens/admin_setup_page.dart';
import 'admin/screens/admin_dashboard.dart';
import 'owners/screens/owner_dashboard.dart';
import 'widgets/route_guards.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables for development
  await dotenv.load(fileName: ".env.development");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Uncomment this line to create an admin user once
  await createInitialAdmin();

  runApp(const MyApp());
}

// Temporary function to create admin user
Future<void> createInitialAdmin() async {
  try {
    final response = await Supabase.instance.client.auth.signUp(
      email: 'admin@venuevista.com',
      password: 'admin123',
      data: {'name': 'System Admin', 'role': 'admin'},
    );
    print('Admin user created: ${response.user?.email}');
  } catch (error) {
    print('Admin user might already exist: $error');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VenueVista',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/admin-setup': (context) => const AdminSetupPage(),
        '/admin': (context) => const AdminRouteGuard(child: AdminDashboard()),
        '/owner': (context) => const OwnerRouteGuard(child: OwnerDashboard()),
      },
    );
  }
}
