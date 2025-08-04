import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

        // Supabase Authentication
        final AuthResponse response = await Supabase.instance.client.auth
            .signInWithPassword(email: email, password: password);

        if (mounted && response.user != null) {
          // Check user role using AuthService
          final userRole = AuthService.getUserRole();

          switch (userRole) {
            case 'admin':
              _showSuccessMessage('Admin login successful! Welcome Admin.');
              Navigator.of(context).pushReplacementNamed('/admin');
              break;
            case 'owner':
              _showSuccessMessage('Owner login successful! Welcome Owner.');
              Navigator.of(context).pushReplacementNamed('/owner');
              break;
            case 'user':
            default:
              _showSuccessMessage('Login successful! Welcome to VenueVista.');
              Navigator.of(context).pushReplacementNamed('/');
              break;
          }
        }
      } on AuthException catch (error) {
        if (mounted) {
          _showErrorMessage(error.message);
        }
      } catch (error) {
        if (mounted) {
          _showErrorMessage('An unexpected error occurred. Please try again.');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      _showErrorMessage('Please fill all fields correctly.');
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate Google login
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      _showSuccessMessage('Google login successful!');
      Navigator.of(context).pushReplacementNamed('/admin');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loginWithFacebook() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate Facebook login
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      _showSuccessMessage('Facebook login successful!');
      Navigator.of(context).pushReplacementNamed('/admin');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
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
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.green[700],
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

                      // Social Login Buttons
                      Row(
                        children: [
                          // Google Login Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _loginWithGoogle,
                              icon: Icon(
                                Icons.g_mobiledata,
                                color: Colors.red,
                                size: 20,
                              ),
                              label: const Flexible(
                                child: Text(
                                  'Google',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Facebook Login Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _loginWithFacebook,
                              icon: Icon(
                                Icons.facebook,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                              label: const Flexible(
                                child: Text(
                                  'Facebook',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                          ),
                        ],
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

                      // Login Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
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

                            const SizedBox(height: 8),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
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
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

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
