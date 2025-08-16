import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  @override
  void initState() {
    super.initState();
    // Clear any existing snackbars when login page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).clearSnackBars();
    });
  }

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

        // Authenticate with Supabase
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );


        if (response.user != null) {
          // Get user profile from database
          final userProfile =
              await Supabase.instance.client
                  .from('user_profiles')
                  .select('*')
                  .eq('id', response.user!.id)
                  .single();

          // Check if role matches selected role
          if (userProfile['role'] == _selectedRole) {
            String userName = userProfile['full_name'] ?? 'User';

            // Navigate first without showing message
            switch (_selectedRole) {
              case 'admin':
                Navigator.of(context).pushReplacementNamed('/admin');
                // Show message after navigation with delay
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    _showSuccessMessage('Welcome Admin: $userName');
                  }
                });
                break;
              case 'owner':
                Navigator.of(context).pushReplacementNamed('/owner');
                // Show message after navigation with delay
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    _showSuccessMessage('Welcome Owner: $userName');
                  }
                });
                break;
              case 'user':
              default:
                Navigator.of(context).pushReplacementNamed('/');
                // Show message after navigation with delay
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    _showSuccessMessage('Welcome: $userName');
                  }
                });
                break;
            }
          } else {
            _showErrorMessage(
              'Invalid role! Your account role is: ${userProfile['role']}',
            );
            await Supabase.instance.client.auth.signOut();
          }
        }
      } on AuthException catch (error) {
        _showErrorMessage('Login failed: ${error.message}');
      } on PostgrestException catch (_) {
        _showErrorMessage('Account not found or inactive');
        await Supabase.instance.client.auth.signOut();
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
    _showErrorMessage('Social login not available. Please use email login.');
  }

  Future<void> _loginWithFacebook() async {
    _showErrorMessage('Social login not available. Please use email login.');
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
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
                              label: const Text(
                                'Google',
                                overflow: TextOverflow.ellipsis,
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
                              label: const Text(
                                'Facebook',
                                overflow: TextOverflow.ellipsis,
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
