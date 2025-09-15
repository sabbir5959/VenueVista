import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/common_drawer.dart';
import '../../services/profile_image_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  bool isUploadingImage = false;
  String? error;
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          error = 'User not authenticated';
          isLoading = false;
        });
        return;
      }

      // Try to load profile with explicit column selection to handle missing profile_image_url column
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select('id, full_name, email, phone, company_name, city, address, role, status, created_at, updated_at, profile_image_url')
          .eq('id', user.id)
          .single();

      setState(() {
        userProfile = response;
        _fullNameController.text = response['full_name'] ?? '';
        _emailController.text = response['email'] ?? '';
        _phoneController.text = response['phone'] ?? '';
        _companyNameController.text = response['company_name'] ?? '';
        _cityController.text = response['city'] ?? '';
        _addressController.text = response['address'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user profile: $e');
      
      // If the error is about missing column, try without profile_image_url
      if (e.toString().contains('column') && e.toString().contains('does not exist')) {
        try {
          print('Retrying profile load without profile_image_url column...');
          final user = Supabase.instance.client.auth.currentUser;
          if (user != null) {
            final response = await Supabase.instance.client
                .from('user_profiles')
                .select('id, full_name, email, phone, company_name, city, address, role, status, created_at, updated_at')
                .eq('id', user.id)
                .single();

            setState(() {
              userProfile = response;
              userProfile?['profile_image_url'] = null; // Set to null if column doesn't exist
              _fullNameController.text = response['full_name'] ?? '';
              _emailController.text = response['email'] ?? '';
              _phoneController.text = response['phone'] ?? '';
              _companyNameController.text = response['company_name'] ?? '';
              _cityController.text = response['city'] ?? '';
              _addressController.text = response['address'] ?? '';
              isLoading = false;
            });
            return;
          }
        } catch (fallbackError) {
          print('Fallback profile load also failed: $fallbackError');
        }
      }
      
      setState(() {
        error = 'Failed to load profile: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        isSaving = true;
        error = null;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final updateData = {
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        'company_name': _companyNameController.text.trim().isEmpty 
            ? null 
            : _companyNameController.text.trim(),
        'city': _cityController.text.trim().isEmpty 
            ? null 
            : _cityController.text.trim(),
        'address': _addressController.text.trim().isEmpty 
            ? null 
            : _addressController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client
          .from('user_profiles')
          .update(updateData)
          .eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      setState(() {
        isSaving = false;
      });
    } catch (e) {
      print('Error updating profile: $e');
      setState(() {
        error = e.toString();
        isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showImagePickerDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Profile Picture',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImagePickerOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickAndUploadImage(ImageSource.camera);
                      },
                    ),
                    _buildImagePickerOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickAndUploadImage(ImageSource.gallery);
                      },
                    ),
                    if (userProfile?['profile_image_url'] != null)
                      _buildImagePickerOption(
                        icon: Icons.delete,
                        label: 'Remove',
                        onTap: () {
                          Navigator.pop(context);
                          _removeProfileImage();
                        },
                        color: Colors.red,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    MaterialColor color = Colors.green,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 30,
              color: color.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      setState(() {
        isUploadingImage = true;
        error = null;
      });

      // Pick image
      final XFile? imageFile = await ProfileImageService.pickImage(source: source);
      if (imageFile == null) {
        setState(() {
          isUploadingImage = false;
        });
        return;
      }

      // Upload image and update profile
      final String? newImageUrl = await ProfileImageService.updateUserProfileImage(
        imageFile,
        oldImageUrl: userProfile?['profile_image_url'],
      );

      if (newImageUrl != null) {
        // Update local state
        setState(() {
          userProfile?['profile_image_url'] = newImageUrl;
          isUploadingImage = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green.shade600,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading profile image: $e');
      
      String errorMessage = 'Error uploading image';
      if (e.toString().contains('storage not configured')) {
        errorMessage = 'Profile image feature not available. Please contact administrator.';
      } else if (e.toString().contains('Permission denied')) {
        errorMessage = 'Permission denied. Please check your account settings.';
      } else if (e.toString().contains('too large')) {
        errorMessage = 'Image file is too large. Please choose a smaller image.';
      } else if (e.toString().contains('Failed to upload image')) {
        errorMessage = 'Upload failed. Please check your internet connection and try again.';
      }
      
      setState(() {
        error = errorMessage;
        isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      setState(() {
        isUploadingImage = true;
        error = null;
      });

      final bool success = await ProfileImageService.removeProfileImage(
        currentImageUrl: userProfile?['profile_image_url'],
      );

      if (success) {
        setState(() {
          userProfile?['profile_image_url'] = null;
          isUploadingImage = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile picture removed successfully!'),
              backgroundColor: Colors.green.shade600,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Failed to remove image');
      }
    } catch (e) {
      print('Error removing profile image: $e');
      setState(() {
        error = e.toString();
        isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing image: $e'),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: required
            ? validator ?? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              }
            : validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: '$label${required ? ' *' : ''}',
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade700, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  String _getMemberYear() {
    try {
      final createdAt = userProfile?['created_at'];
      if (createdAt != null) {
        return DateTime.parse(createdAt).year.toString();
      }
      return DateTime.now().year.toString();
    } catch (e) {
      return DateTime.now().year.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      drawer: const CommonDrawer(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade700,
                                    Colors.green.shade300
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _showImagePickerDialog,
                                    child: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 50,
                                          backgroundColor: Colors.white,
                                          backgroundImage: userProfile?['profile_image_url'] != null
                                              ? NetworkImage(userProfile!['profile_image_url'])
                                              : null,
                                          child: userProfile?['profile_image_url'] == null
                                              ? Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.green.shade700,
                                                )
                                              : null,
                                        ),
                                        if (isUploadingImage)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 30,
                                                  height: 30,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade700,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    userProfile?['full_name'] ?? 'User',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    userProfile?['role']?.toUpperCase() ?? 'USER',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Form Section
                          Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _fullNameController,
                            label: 'Full Name',
                            icon: Icons.person,
                          ),

                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            required: false,
                          ),

                          // Show company name field only for owners
                          if (userProfile?['role'] == 'owner') ...[
                            _buildTextField(
                              controller: _companyNameController,
                              label: 'Company Name',
                              icon: Icons.business,
                              required: false,
                            ),
                          ],

                          _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            icon: Icons.location_city,
                            required: false,
                          ),

                          _buildTextField(
                            controller: _addressController,
                            label: 'Address',
                            icon: Icons.home,
                            maxLines: 3,
                            required: false,
                          ),

                          const SizedBox(height: 24),

                          // Update Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isSaving ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Update Profile',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Account Info
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.badge, 
                                          color: Colors.grey.shade600, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Role: ${userProfile?['role']?.toUpperCase() ?? 'USER'}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.schedule, 
                                          color: Colors.grey.shade600, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Status: ${userProfile?['status']?.toUpperCase() ?? 'ACTIVE'}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (userProfile?['created_at'] != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, 
                                            color: Colors.grey.shade600, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Member since: ${_getMemberYear()}',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
