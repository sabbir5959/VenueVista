import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileImageService {
  static final _supabase = Supabase.instance.client;
  static const String _bucketName = 'profile-images';
  
  /// Pick an image from gallery or camera
  static Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Upload profile image to Supabase storage
  static Future<String?> uploadProfileImage(XFile imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('🔄 Starting image upload for user: ${user.id}');

      // Create unique filename with user ID and timestamp
      final String fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Read file bytes
      final Uint8List fileBytes;
      if (kIsWeb) {
        fileBytes = await imageFile.readAsBytes();
      } else {
        fileBytes = await File(imageFile.path).readAsBytes();
      }

      // Upload to Supabase storage
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(fileName, fileBytes);

      // Get public URL
      final String publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(fileName);

      print('✅ Image uploaded successfully: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      print('❌ Storage error uploading profile image: ${e.message}');
      if (e.message.contains('Bucket not found') || e.statusCode == 404) {
        throw Exception('Profile image storage not configured. Please contact administrator.');
      } else if (e.message.contains('Policy violation') || e.statusCode == 403) {
        throw Exception('Permission denied uploading image.');
      } else if (e.statusCode == 413) {
        throw Exception('Image file too large. Please choose a smaller image.');
      } else {
        throw Exception('Upload failed: ${e.message}');
      }
    } catch (e) {
      print('❌ Error uploading profile image: $e');
      throw Exception('Failed to upload image');
    }
  }

  /// Update user profile with new image URL
  static Future<bool> updateProfileImageUrl(String imageUrl) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Try to update with profile_image_url column
      try {
        await _supabase
            .from('user_profiles')
            .update({
              'profile_image_url': imageUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', user.id);
        return true;
      } catch (columnError) {
        // If column doesn't exist, just update the timestamp for now
        if (columnError.toString().contains('column') && 
            columnError.toString().contains('does not exist')) {
          print('profile_image_url column does not exist yet');
          await _supabase
              .from('user_profiles')
              .update({
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', user.id);
          return false; // Return false to indicate column doesn't exist
        }
        rethrow;
      }
    } catch (e) {
      print('Error updating profile image URL: $e');
      return false;
    }
  }

  /// Delete old profile image from storage
  static Future<void> deleteOldProfileImage(String? oldImageUrl) async {
    try {
      if (oldImageUrl == null || oldImageUrl.isEmpty) return;

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Extract file path from URL
      final uri = Uri.parse(oldImageUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the path after the bucket name in the URL
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) return;
      
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      
      // Only delete if it belongs to the current user
      if (filePath.startsWith(user.id)) {
        await _supabase.storage
            .from(_bucketName)
            .remove([filePath]);
      }
    } catch (e) {
      print('Error deleting old profile image: $e');
    }
  }

  /// Complete profile image update process
  static Future<String?> updateUserProfileImage(XFile imageFile, {String? oldImageUrl}) async {
    try {
      // Upload new image
      final String? newImageUrl = await uploadProfileImage(imageFile);
      if (newImageUrl == null) {
        throw Exception('Failed to upload image');
      }

      // Update profile with new URL
      final bool success = await updateProfileImageUrl(newImageUrl);
      if (!success) {
        throw Exception('Failed to update profile');
      }

      // Delete old image if it exists
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        await deleteOldProfileImage(oldImageUrl);
      }

      return newImageUrl;
    } catch (e) {
      print('Error in complete profile image update: $e');
      return null;
    }
  }

  /// Get current user's profile image URL
  static Future<String?> getCurrentProfileImageUrl() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      try {
        final response = await _supabase
            .from('user_profiles')
            .select('profile_image_url')
            .eq('id', user.id)
            .single();

        return response['profile_image_url'];
      } catch (columnError) {
        // If column doesn't exist, return null
        if (columnError.toString().contains('column') && 
            columnError.toString().contains('does not exist')) {
          print('profile_image_url column does not exist yet');
          return null;
        }
        rethrow;
      }
    } catch (e) {
      print('Error getting profile image URL: $e');
      return null;
    }
  }

  /// Remove profile image from user profile
  static Future<bool> removeProfileImage({String? currentImageUrl}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Delete image from storage if it exists
      if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
        await deleteOldProfileImage(currentImageUrl);
      }

      // Update profile to remove image URL
      await _supabase
          .from('user_profiles')
          .update({
            'profile_image_url': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      return true;
    } catch (e) {
      print('Error removing profile image: $e');
      return false;
    }
  }
}
