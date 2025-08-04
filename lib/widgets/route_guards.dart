import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AdminRouteGuard extends StatelessWidget {
  final Widget child;

  const AdminRouteGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated and is admin
    if (AuthService.currentUser == null) {
      // Not logged in, redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const SizedBox.shrink();
    }

    if (!AuthService.isAdmin()) {
      // Logged in but not admin, show unauthorized page
      return Scaffold(
        appBar: AppBar(
          title: const Text('Unauthorized Access'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 100, color: Colors.red[300]),
              const SizedBox(height: 24),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You do not have permission to access this area.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await AuthService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      );
    }

    // User is admin, show the protected content
    return child;
  }
}

class OwnerRouteGuard extends StatelessWidget {
  final Widget child;

  const OwnerRouteGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (AuthService.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const SizedBox.shrink();
    }

    if (!AuthService.isOwner()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Unauthorized Access'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 100, color: Colors.red[300]),
              const SizedBox(height: 24),
              Text(
                'Owner Access Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You need owner privileges to access this area.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await AuthService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}
