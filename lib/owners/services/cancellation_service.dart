import 'package:supabase_flutter/supabase_flutter.dart';

class CancellationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all pending cancellation requests for venues owned by the current user
  static Future<List<Map<String, dynamic>>> getOwnerCancellationRequests(String ownerId) async {
    try {
      // First get all venue IDs owned by this owner
      final ownerVenueIds = await _getOwnerVenueIds(ownerId);
      if (ownerVenueIds.isEmpty) {
        print('No venues found for owner: $ownerId');
        return [];
      }

      print('Found ${ownerVenueIds.length} venues for owner: $ownerId');

      // Fetch pending cancellations for owner's venues
      final response = await _supabase
          .from('cancellations')
          .select('''
            id,
            booking_id,
            user_id,
            venue_id,
            venue_name,
            booking_date,
            start_time,
            end_time,
            original_amount,
            cancellation_reason,
            refund_amount,
            refund_status,
            cancelled_at,
            created_at
          ''')
          .eq('refund_status', 'pending')
          .inFilter('venue_id', ownerVenueIds)
          .order('cancelled_at', ascending: false);

      print('Found ${response.length} pending cancellations');

      if (response.isEmpty) {
        return [];
      }

      // Fetch user full names for each cancellation
      List<Map<String, dynamic>> enrichedCancellations = [];
      
      for (var cancellation in response) {
        try {
          final userResponse = await _supabase
              .from('user_profiles')
              .select('full_name')
              .eq('id', cancellation['user_id'])
              .single();
          
          cancellation['user_full_name'] = userResponse['full_name'];
          enrichedCancellations.add(cancellation);
        } catch (userError) {
          print('Error fetching user details for ${cancellation['user_id']}: $userError');
          // Add cancellation with fallback user name
          cancellation['user_full_name'] = 'Unknown User';
          enrichedCancellations.add(cancellation);
        }
      }

      return enrichedCancellations;
    } catch (e) {
      print('Error fetching cancellation requests: $e');
      return [];
    }
  }

  // Get all venue IDs owned by the current user
  static Future<List<String>> _getOwnerVenueIds(String ownerId) async {
    try {
      final response = await _supabase
          .from('venues')
          .select('id')
          .eq('owner_id', ownerId);

      if (response.isEmpty) {
        return [];
      }

      return response.map<String>((venue) => venue['id'] as String).toList();
    } catch (e) {
      print('Error fetching owner venue IDs: $e');
      return [];
    }
  }

  // Accept a cancellation request with refund amount
  static Future<bool> acceptCancellationRequest({
    required String cancellationId,
    required double refundAmount,
    required String ownerId,
  }) async {
    try {
      final response = await _supabase
          .from('cancellations')
          .update({
            'refund_amount': refundAmount,
            'refund_status': 'accepted',
            'refund_processed_at': DateTime.now().toIso8601String(),
            'processed_by': ownerId,
          })
          .eq('id', cancellationId)
          .eq('refund_status', 'pending'); // Ensure we only update pending requests

      print('Accept cancellation response: $response');
      return true;
    } catch (e) {
      print('Error accepting cancellation request: $e');
      return false;
    }
  }

  // Reject a cancellation request
  static Future<bool> rejectCancellationRequest({
    required String cancellationId,
    required String ownerId,
    String? rejectionReason,
  }) async {
    try {
      final response = await _supabase
          .from('cancellations')
          .update({
            'refund_amount': 0.00,
            'refund_status': 'rejected',
            'refund_processed_at': DateTime.now().toIso8601String(),
            'processed_by': ownerId,
            'admin_notes': rejectionReason ?? 'Rejected by venue owner',
          })
          .eq('id', cancellationId)
          .eq('refund_status', 'pending'); // Ensure we only update pending requests

      print('Reject cancellation response: $response');
      return true;
    } catch (e) {
      print('Error rejecting cancellation request: $e');
      return false;
    }
  }

  // Get cancellation request details by ID
  static Future<Map<String, dynamic>?> getCancellationDetails(String cancellationId) async {
    try {
      final response = await _supabase
          .from('cancellations')
          .select('*')
          .eq('id', cancellationId)
          .single();

      // Fetch user details separately
      try {
        final userResponse = await _supabase
            .from('user_profiles')
            .select('full_name, email, phone')
            .eq('id', response['user_id'])
            .single();
        
        response['user_profiles'] = userResponse;
      } catch (userError) {
        print('Error fetching user details: $userError');
        response['user_profiles'] = {
          'full_name': 'Unknown User',
          'email': 'N/A',
          'phone': 'N/A'
        };
      }

      // Fetch venue details separately
      try {
        final venueResponse = await _supabase
            .from('venues')
            .select('name, owner_id')
            .eq('id', response['venue_id'])
            .single();
        
        response['venues'] = venueResponse;
      } catch (venueError) {
        print('Error fetching venue details: $venueError');
        response['venues'] = {
          'name': 'Unknown Venue',
          'owner_id': null
        };
      }

      return response;
    } catch (e) {
      print('Error fetching cancellation details: $e');
      return null;
    }
  }

  // Helper method to format relative time
  static String getRelativeTime(DateTime cancelledAt) {
    final now = DateTime.now();
    final difference = now.difference(cancelledAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks weeks ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months months ago';
    }
  }

  // Helper method to format date and time together
  static String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final date = formatDate(dateTimeString);
      final timeString = dateTime.toString().split(' ')[1].split('.')[0]; // Extract time part
      final time = formatTime(timeString);
      return '$date, $time';
    } catch (e) {
      return dateTimeString;
    }
  }

  // Helper method to format currency
  static String formatCurrency(double amount) {
    return '৳${amount.toStringAsFixed(2)}';
  }

  // Helper method to format date
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Helper method to format time
  static String formatTime(String timeString) {
    try {
      final time = DateTime.parse('2025-01-01 $timeString');
      final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return timeString;
    }
  }
}