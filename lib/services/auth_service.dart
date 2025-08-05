import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get current user
  static User? get currentUser => _client.auth.currentUser;

  // Get user role from metadata or hardcoded admin emails
  static String getUserRole() {
    final user = currentUser;
    if (user == null) return 'guest';

    // Check if this is a hardcoded admin email
    final adminEmails = [
      'admin@venuevista.com',
      'sabbir5959@gmail.com', // Your admin email - change this to your actual admin email
      // Add more admin emails here if needed
    ];

    if (adminEmails.contains(user.email?.toLowerCase())) {
      return 'admin';
    }

    // Check metadata for role
    final role = user.userMetadata?['role'] as String?;
    return role ?? 'user'; // default to 'user' if no role is set
  }

  // Check if current user is admin
  static bool isAdmin() {
    return getUserRole() == 'admin';
  }

  // Check if current user is owner
  static bool isOwner() {
    return getUserRole() == 'owner';
  }

  // Check if current user is regular user
  static bool isUser() {
    final role = getUserRole();
    return role == 'user' || role == 'guest';
  }

  // Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Register new user
  static Future<AuthResponse> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone': phone,
        'role': 'user', // Default role
      },
    );
  }

  // Get user email
  static String? getUserEmail() {
    return currentUser?.email;
  }

  // Get user ID
  static String? getUserId() {
    return currentUser?.id;
  }

  // Get user name from metadata
  static String? getUserName() {
    return currentUser?.userMetadata?['name'] as String?;
  }

  // Get user phone from metadata
  static String? getUserPhone() {
    return currentUser?.userMetadata?['phone'] as String?;
  }

  // Update user role (for admin setup)
  static Future<void> updateUserRole(String role) async {
    final user = currentUser;
    if (user != null) {
      await _client.auth.updateUser(
        UserAttributes(data: {...user.userMetadata ?? {}, 'role': role}),
      );
    }
  }

  // Create admin user (for initial setup)
  static Future<void> createAdminUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': 'admin'},
      );

      if (response.user != null) {
        print('Admin user created successfully: ${response.user!.email}');
      }
    } catch (error) {
      print('Error creating admin user: $error');
    }
  }
}
