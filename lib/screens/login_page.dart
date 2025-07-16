import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../users/dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isOwnerLogin = false; // Track if user is logging in as owner

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 11) {
      return 'Phone number must be 11 digits';
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

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Check for admin and user credentials
        String phone = _phoneController.text.trim();
        String password = _passwordController.text.trim();

        // Admin login check
        if (phone == "01798155814" && password == "sabbir55") {
          _showSuccessMessage('Admin login successful! Welcome Admin.');
          Navigator.of(context).pushReplacementNamed('/admin');
        }
        // User login check
        else if (phone == "01533985291" && password == "kawsar47") {
          _showSuccessMessage('User login successful! Welcome to VenueVista.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeActivity()),
          );
        } else {
          _showErrorMessage('Invalid credentials. Please try again.');
        }
      }

      setState(() {
        _isLoading = false;
      });
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
                          _isOwnerLogin ? Icons.sports : Icons.person,
                          size: 60,
                          color: Colors.green[700],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login Type Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text('User'),
                            selected: !_isOwnerLogin,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _isOwnerLogin = false;
                                });
                              }
                            },
                            selectedColor: Colors.green[100],
                          ),
                          const SizedBox(width: 16),
                          ChoiceChip(
                            label: const Text('Venue Owner'),
                            selected: _isOwnerLogin,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _isOwnerLogin = true;
                                });
                              }
                            },
                            selectedColor: Colors.green[100],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Text(
                        _isOwnerLogin ? 'Venue Owner Login' : 'Welcome Back!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Sign in to continue to VenueVista',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 32),

                      // Social Login Buttons (only for users)
                      if (!_isOwnerLogin) ...[
                        Row(
                          children: [
                            // Google Login Button
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : _loginWithGoogle,
                                icon: Image.asset(
                                  'assets/icons/google.png',
                                  height: 20,
                                  width: 20,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.g_mobiledata,
                                      color: Colors.red,
                                      size: 20,
                                    );
                                  },
                                ),
                                label: const Text('Google'),
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
                                icon: Image.asset(
                                  'assets/icons/facebook.png',
                                  height: 20,
                                  width: 20,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.facebook,
                                      color: Colors.blue[700],
                                      size: 20,
                                    );
                                  },
                                ),
                                label: const Text('Facebook'),
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
                      ],

                      // Login Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Phone Number Field
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                hintText: 'phone number',
                                prefixIcon: const Icon(Icons.phone),
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
                              validator: _validatePhone,
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
                                  // Handle forgot password
                                  _showSuccessMessage(
                                    'Forgot password feature coming soon!',
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
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.grey[700]),
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
