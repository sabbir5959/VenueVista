import 'package:supabase_flutter/supabase_flutter.dart';

class VenueReviewService {
  static final _supabase = Supabase.instance.client;

  // Submit a venue review
  static Future<bool> submitReview({
    required String venueId,
    required String userId,
    required int rating,
    String? reviewText,
    String? bookingId,
  }) async {
    try {
      print('📝 Submitting venue review...');
      print('   Venue ID: $venueId');
      print('   User ID: $userId');
      print('   Rating: $rating');
      print('   Review Text: $reviewText');
      print('   Booking ID: $bookingId');

      await _supabase.from('venue_reviews').insert({
        'venue_id': venueId,
        'user_id': userId,
        'rating': rating,
        'review_text': reviewText,
        'booking_id': bookingId,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Venue review submitted successfully');
      return true;
    } catch (e) {
      print('❌ Error submitting venue review: $e');
      return false;
    }
  }

  // Get reviews for a specific venue
  static Future<List<Map<String, dynamic>>> getVenueReviews(
    String venueId,
  ) async {
    try {
      final response = await _supabase
          .from('venue_reviews')
          .select('''
            *,
            user_profiles (
              username,
              full_name
            )
          ''')
          .eq('venue_id', venueId)
          .order('created_at', ascending: false);

      print('✅ Venue reviews fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching venue reviews: $e');
      return [];
    }
  }

  // Get reviews by a specific user
  static Future<List<Map<String, dynamic>>> getUserReviews(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('venue_reviews')
          .select('''
            *,
            venues (
              name,
              address
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('✅ User reviews fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching user reviews: $e');
      return [];
    }
  }

  // Check if user has already reviewed a venue
  static Future<bool> hasUserReviewedVenue({
    required String venueId,
    required String userId,
    String? bookingId,
  }) async {
    try {
      var query = _supabase
          .from('venue_reviews')
          .select('id')
          .eq('venue_id', venueId)
          .eq('user_id', userId);

      if (bookingId != null) {
        query = query.eq('booking_id', bookingId);
      }

      final response = await query.limit(1);
      return response.isNotEmpty;
    } catch (e) {
      print('❌ Error checking existing review: $e');
      return false;
    }
  }

  // Get average rating for a venue
  static Future<double> getVenueAverageRating(String venueId) async {
    try {
      final response = await _supabase
          .from('venue_reviews')
          .select('rating')
          .eq('venue_id', venueId);

      if (response.isEmpty) return 0.0;

      final ratings =
          response.map<int>((review) => review['rating'] as int).toList();
      final average = ratings.reduce((a, b) => a + b) / ratings.length;

      print('✅ Average rating for venue $venueId: $average');
      return average;
    } catch (e) {
      print('❌ Error calculating average rating: $e');
      return 0.0;
    }
  }

  // Update an existing review
  static Future<bool> updateReview({
    required String reviewId,
    required int rating,
    String? reviewText,
  }) async {
    try {
      await _supabase
          .from('venue_reviews')
          .update({'rating': rating, 'review_text': reviewText})
          .eq('id', reviewId);

      print('✅ Review updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating review: $e');
      return false;
    }
  }

  // Delete a review
  static Future<bool> deleteReview(String reviewId) async {
    try {
      await _supabase.from('venue_reviews').delete().eq('id', reviewId);
      print('✅ Review deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting review: $e');
      return false;
    }
  }
}
