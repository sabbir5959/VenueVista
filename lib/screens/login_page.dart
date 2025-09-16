import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'user'; // Default role
  StreamSubscription<AuthState>? _authSubscription;
  bool _isHandlingAuth = false; // Flag to prevent duplicate auth handling
  String? _lastHandledUserId; // Track last handled user to prevent duplicates
  bool _isGoogleAuthInProgress = false; // Track if Google OAuth is in progress
  bool _rememberMe = false; // Remember me checkbox state

  @override
  void initState() {
    super.initState();
    // Clear any existing snackbars when login page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).clearSnackBars();
    });

    // Just load remember me state, no auto-login
    _checkSavedLogin();

    // Listen for auth state changes (for Google OAuth)
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSubscription = AuthService.client.auth.onAuthStateChange.listen((
      data,
    ) async {
      // Only handle Google OAuth events
      if (data.event == AuthChangeEvent.signedIn &&
          data.session?.user != null &&
          !_isHandlingAuth &&
          _isGoogleAuthInProgress) {
        final user = data.session!.user;

        // Check if we already handled this user
        if (_lastHandledUserId == user.id) {
          print('⏭️ Skipping duplicate auth event for: ${user.email}');
          return;
        }

        _isHandlingAuth = true; // Set flag to prevent duplicate handling
        _lastHandledUserId = user.id; // Track this user
        print('🔄 Auth state changed - user signed in: ${user.email}');

        // Handle successful authentication
        await _handleSuccessfulAuth(user);

        _isHandlingAuth = false; // Reset flag after handling
        _isGoogleAuthInProgress = false; // Reset Google OAuth flag
      }
    });
  }

  // Check for saved login credentials
  Future<void> _checkSavedLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      final savedRole = prefs.getString('saved_role');

      // Load saved role if available
      if (savedRole != null) {
        setState(() {
          _selectedRole = savedRole;
        });
        print('🔄 Loaded saved role: $savedRole');
      }

      // Only set remember me checkbox state
      if (rememberMe) {
        setState(() {
          _rememberMe = true;
        });
      }
    } catch (e) {
      print('Error checking saved login: $e');
    }
  }

  // Save login credentials
  Future<void> _saveCredentials() async {
    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setString('saved_role', _selectedRole);
      await prefs.setBool('remember_me', true);
    }
  }

  // Clear saved credentials
  Future<void> _clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
    await prefs.remove('saved_role');
    await prefs.setBool('remember_me', false);
  }

  Future<void> _handleSuccessfulAuth(User user) async {
    try {
      // Clear logout flag on successful authentication
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_out', false);

      // Check if user profile exists in database
      final userProfile = await DatabaseService.getUserProfile(user.id);

      // User exists, check role match
      if (userProfile['role'] == _selectedRole) {
        // Save credentials if remember me is checked (for Google OAuth)
        if (_rememberMe) {
          await _saveCredentials();
        }

        String userName =
            userProfile['full_name'] ??
            user.userMetadata?['full_name'] ??
            'User';
        print('✅ Role matched - navigating as ${userProfile['role']}');
        await _navigateBasedOnRole(userName);
      } else {
        _showErrorMessage(
          'Invalid credentials. Please check your role selection and try again.',
        );
        await AuthService.signOut();
      }
    } catch (e) {
      // User profile doesn't exist, this is first time Google sign-in
      final userName =
          user.userMetadata?['full_name'] ??
          user.userMetadata?['name'] ??
          user.email?.split('@')[0] ??
          'User';

      // Only create profile if selected role is 'user' (default for new signups)
      if (_selectedRole == 'user') {
        try {
          print('🆕 Creating new user profile for: ${user.email}');
          await DatabaseService.createUserProfile(
            userId: user.id,
            fullName: userName,
            email: user.email!,
            role: 'user',
            phone: '', // Google sign-in doesn't provide phone
          );

          // Save credentials if remember me is checked (for Google OAuth new user)
          if (_rememberMe) {
            await _saveCredentials();
          }

          await _navigateBasedOnRole(userName);
        } catch (createError) {
          _showErrorMessage('Failed to create user profile. Please try again.');
          await AuthService.signOut();
        }
      } else {
        _showErrorMessage(
          'This Google account is not registered as ${_selectedRole}. Please use email login or sign up first.',
        );
        await AuthService.signOut();
      }
    }

    // Reset loading state after auth handling is complete
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authSubscription?.cancel();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();

        // Authenticate with Supabase using AuthService
        final response = await AuthService.signIn(
          email: email,
          password: password,
        );

        if (response.user != null) {
          // Get user profile from database using DatabaseService
          final userProfile = await DatabaseService.getUserProfile(
            response.user!.id,
          );

          // Check if role matches selected role
          if (userProfile['role'] == _selectedRole) {
            // Save credentials if remember me is checked
            if (_rememberMe) {
              await _saveCredentials();
            } else {
              await _clearSavedCredentials();
            }

            // Navigate based on role
            switch (_selectedRole) {
              case 'admin':
                Navigator.of(context).pushReplacementNamed('/admin');
                break;
              case 'owner':
                Navigator.of(context).pushReplacementNamed('/owner');
                break;
              case 'user':
              default:
                Navigator.of(context).pushReplacementNamed('/');
                break;
            }
          } else {
            _showErrorMessage(
              'Invalid credentials. Please check your role selection and try again.',
            );
            await AuthService.signOut();
          }
        }
      } on AuthException catch (error) {
        _showErrorMessage('Login failed: ${error.message}');
      } on PostgrestException catch (_) {
        _showErrorMessage('Account not found or inactive');
        await AuthService.signOut();
      } catch (error) {
        _showErrorMessage('Login failed. Please try again.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _showErrorMessage('Please fill all fields correctly.');
    }
  }

  Future<void> _loginWithGoogle() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _isGoogleAuthInProgress = true; // Set flag for Google OAuth
    });

    try {
      // Start Supabase Google OAuth flow with account selection
      final success = await AuthService.signInWithGoogle(
        forceAccountSelection: true,
      );

      if (!success) {
        _showErrorMessage('Failed to initiate Google sign-in.');
        // Reset loading state only on failure
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isGoogleAuthInProgress = false;
          });
        }
      }
      // On success, loading state will be reset by auth handler
    } catch (error) {
      print('Google sign-in error: $error');
      _showErrorMessage('Google sign-in failed. Please try again.');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isGoogleAuthInProgress = false;
        });
      }
    }
  }

  Future<void> _navigateBasedOnRole(String userName) async {
    // Clear any existing snackbars before navigation
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    // Dismiss any loading state
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    // Navigate based on selected role
    switch (_selectedRole) {
      case 'admin':
        Navigator.of(context).pushReplacementNamed('/admin');
        break;
      case 'owner':
        Navigator.of(context).pushReplacementNamed('/owner');
        break;
      case 'user':
      default:
        Navigator.of(context).pushReplacementNamed('/');
        break;
    }

    // No welcome message after navigation to avoid persistent alerts
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2), // Reduced from 4 to 2 seconds
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[300]!, Colors.green[500]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo and Title
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green[50],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icons/venue.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Sign in to continue to VenueVista',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 32),

                      // Login Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Role Selection Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: InputDecoration(
                                labelText: 'Select Role',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.green[700]!,
                                  ),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'user',
                                  child: Text('User'),
                                ),
                                DropdownMenuItem(
                                  value: 'admin',
                                  child: Text('Admin'),
                                ),
                                DropdownMenuItem(
                                  value: 'owner',
                                  child: Text('Owner'),
                                ),
                              ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedRole = newValue!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a role';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.green[700]!,
                                  ),
                                ),
                              ),
                              validator: _validateEmail,
                            ),

                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.green[700]!,
                                  ),
                                ),
                              ),
                              validator: _validatePassword,
                            ),

                            const SizedBox(height: 16),

                            // Remember Me Checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: Colors.green[700],
                                ),
                                const Expanded(
                                  child: Text(
                                    'Remember me',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                // Forgot Password Link
                                Flexible(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const ForgotPasswordPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _login,
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text('Login'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Divider with "OR"
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Google Login Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _loginWithGoogle,
                          icon: Icon(
                            Icons.g_mobiledata,
                            color: Colors.red,
                            size: 20,
                          ),
                          label: const Text(
                            'Continue with Google',
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
