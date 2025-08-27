import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic>? ownerData;
  final Map<String, dynamic>? venueData;
  
  const EditProfilePage({
    Key? key,
    this.ownerData,
    this.venueData,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _venueTypeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  // Venue details controllers
  final TextEditingController _pricePerHourController = TextEditingController();
  final TextEditingController _totalCourtsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _turfSizeController = TextEditingController();
  final TextEditingController _parkingSpotsController = TextEditingController();
  
  // Facility availability
  bool _hasTrainingEquipment = true;
  bool _hasCafe = true;
  bool _hasChangingRooms = true;
  bool _hasFloodlights = true;
  bool _hasParking = true;
  
  // Password controllers
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _populateFieldsWithData();
  }

  void _populateFieldsWithData() {
    // Populate with real data passed from owner profile
    if (widget.ownerData != null) {
      _nameController.text = widget.ownerData!['full_name'] ?? '';
      _phoneController.text = widget.ownerData!['phone'] ?? '';
      _emailController.text = widget.ownerData!['email'] ?? '';
      _bioController.text = widget.ownerData!['bio'] ?? '';
      _addressController.text = widget.ownerData!['address'] ?? '';
    }
    
    if (widget.venueData != null) {
      _venueTypeController.text = widget.venueData!['venue_type'] ?? '';
      _pricePerHourController.text = widget.venueData!['price_per_hour']?.toString() ?? '';
      _totalCourtsController.text = widget.venueData!['total_courts']?.toString() ?? '';
      _locationController.text = widget.venueData!['location'] ?? '';
      _turfSizeController.text = widget.venueData!['turf_size'] ?? '';
      _parkingSpotsController.text = widget.venueData!['parking_spots']?.toString() ?? '';
      
      // Set facility booleans
      _hasTrainingEquipment = widget.venueData!['has_training_equipment'] ?? false;
      _hasCafe = widget.venueData!['has_cafe'] ?? false;
      _hasChangingRooms = widget.venueData!['has_changing_rooms'] ?? false;
      _hasFloodlights = widget.venueData!['has_floodlights'] ?? false;
      _hasParking = widget.venueData!['has_parking'] ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _venueTypeController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _pricePerHourController.dispose();
    _totalCourtsController.dispose();
    _locationController.dispose();
    _turfSizeController.dispose();
    _parkingSpotsController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Update Profile Picture'),
            content: const Text('Choose how you want to update your profile picture:'),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (source != null) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 90,
        );

        if (image != null) {
          setState(() {
            _profileImage = File(image.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Prepare user profile data
      Map<String, dynamic> userProfileData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'bio': _bioController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Update user profile
      await client
          .from('user_profiles')
          .update(userProfileData)
          .eq('user_id', user.id);

      // Prepare venue data if venue exists
      if (widget.venueData != null) {
        Map<String, dynamic> venueUpdateData = {
          'name': _venueTypeController.text.trim(),
          'address': _addressController.text.trim(),
          'price_per_hour': double.tryParse(_pricePerHourController.text.trim()) ?? 0.0,
          'total_courts': int.tryParse(_totalCourtsController.text.trim()) ?? 1,
          'location': _locationController.text.trim(),
          'turf_size': _turfSizeController.text.trim(),
          'parking_spots': int.tryParse(_parkingSpotsController.text.trim()) ?? 0,
          'has_training_equipment': _hasTrainingEquipment,
          'has_cafe': _hasCafe,
          'has_changing_rooms': _hasChangingRooms,
          'has_floodlights': _hasFloodlights,
          'has_parking': _hasParking,
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Update venue data
        await client
            .from('venues')
            .update(venueUpdateData)
            .eq('owner_id', user.id);
      }

      // Handle password change if requested
      bool isChangingPassword = _oldPasswordController.text.isNotEmpty || 
                               _newPasswordController.text.isNotEmpty || 
                               _confirmPasswordController.text.isNotEmpty;
      
      if (isChangingPassword) {
        if (_oldPasswordController.text.isEmpty || 
            _newPasswordController.text.isEmpty || 
            _confirmPasswordController.text.isEmpty) {
          throw Exception('All password fields are required for password change');
        }
        
        // Update password
        await client.auth.updateUser(
          UserAttributes(password: _newPasswordController.text.trim())
        );
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Return to previous screen and refresh data
      Navigator.pop(context, true); // Return true to indicate successful update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.green[700],
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Updating profile...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.green[100],
                                backgroundImage: _profileImage != null 
                                    ? FileImage(_profileImage!) 
                                    : null,
                                child: _profileImage == null
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.green[700],
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green[700],
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: _pickProfileImage,
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap camera icon to change photo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Personal Information Section
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Full Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Business Information Section
                    const Text(
                      'Business Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Venue Type Field
                    TextFormField(
                      controller: _venueTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Venue Type',
                        prefixIcon: Icon(Icons.business_outlined),
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Sports Complex, Football Ground',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your venue type';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Address Field
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                        hintText: 'Enter your venue address',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Bio Field
                    TextFormField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Bio (Optional)',
                        prefixIcon: Icon(Icons.info_outline),
                        border: OutlineInputBorder(),
                        hintText: 'Tell us about yourself and your venue experience',
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Venue Details Section
                    const Text(
                      'Venue Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price per Hour Field
                    TextFormField(
                      controller: _pricePerHourController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price per Hour (৳)',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 1500',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter price per hour';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Total Courts Field
                    TextFormField(
                      controller: _totalCourtsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total Courts',
                        prefixIcon: Icon(Icons.sports_tennis),
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 4',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter number of courts';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Location Field
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Dhanmondi, Dhaka',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Turf Size Field
                    TextFormField(
                      controller: _turfSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Size of Turf',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 100m x 70m',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter turf size';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Parking Spots Field
                    TextFormField(
                      controller: _parkingSpotsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Parking Spots',
                        prefixIcon: Icon(Icons.local_parking),
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 50',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter number of parking spots';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Facilities Section
                    const Text(
                      'Facilities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Training Equipment Switch
                    Row(
                      children: [
                        const Icon(Icons.fitness_center, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Training Equipment',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Switch(
                          value: _hasTrainingEquipment,
                          onChanged: (value) {
                            setState(() {
                              _hasTrainingEquipment = value;
                            });
                          },
                          activeColor: Colors.green[700],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Cafe Switch
                    Row(
                      children: [
                        const Icon(Icons.local_cafe, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Cafe',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Switch(
                          value: _hasCafe,
                          onChanged: (value) {
                            setState(() {
                              _hasCafe = value;
                            });
                          },
                          activeColor: Colors.green[700],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Changing Rooms Switch
                    Row(
                      children: [
                        const Icon(Icons.wc, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Changing Rooms',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Switch(
                          value: _hasChangingRooms,
                          onChanged: (value) {
                            setState(() {
                              _hasChangingRooms = value;
                            });
                          },
                          activeColor: Colors.green[700],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Floodlights Switch
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Floodlights',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Switch(
                          value: _hasFloodlights,
                          onChanged: (value) {
                            setState(() {
                              _hasFloodlights = value;
                            });
                          },
                          activeColor: Colors.green[700],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Parking Switch
                    Row(
                      children: [
                        const Icon(Icons.local_parking, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Parking Available',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Switch(
                          value: _hasParking,
                          onChanged: (value) {
                            setState(() {
                              _hasParking = value;
                            });
                          },
                          activeColor: Colors.green[700],
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Password Section
                    const Text(
                      'Change Password (Optional)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Leave blank if you don\'t want to change your password',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Old Password Field
                    TextFormField(
                      controller: _oldPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                        hintText: 'Enter your current password',
                      ),
                      validator: (value) {
                        // Only validate if user is trying to change password
                        if (_newPasswordController.text.isNotEmpty || _confirmPasswordController.text.isNotEmpty) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your current password';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // New Password Field
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: Icon(Icons.lock_reset),
                        border: OutlineInputBorder(),
                        hintText: 'Enter your new password',
                      ),
                      validator: (value) {
                        // Only validate if user entered old password or confirm password
                        if (_oldPasswordController.text.isNotEmpty || _confirmPasswordController.text.isNotEmpty) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your new password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                        prefixIcon: Icon(Icons.lock_clock),
                        border: OutlineInputBorder(),
                        hintText: 'Re-enter your new password',
                      ),
                      validator: (value) {
                        // Only validate if user entered old password or new password
                        if (_oldPasswordController.text.isNotEmpty || _newPasswordController.text.isNotEmpty) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[400]!),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
