import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity_data.dart';

class ActivityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ActivityData> getActivityData() async {
    try {
      print('🎯 ActivityService: Starting to fetch activity data...');

      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      print('🔐 ActivityService: User authenticated: ${user.id}');

      // Get owner's venue ID
      final venueResponse = await _supabase
          .from('venues')
          .select('id')
          .eq('owner_id', user.id)
          .maybeSingle();

      if (venueResponse == null) {
        print('⚠️ ActivityService: No venue found for owner');
        return ActivityData(
          totalBookings: 0,
          tournamentBookings: 0,
          totalReviews: 0,
          averageRating: 0.0,
          recentReviews: [],
        );
      }

      final venueId = venueResponse['id'];
      print('🏟️ ActivityService: Found venue ID: $venueId');

      // Fetch total bookings count
      final bookingsResponse = await _supabase
          .from('bookings')
          .select('id')
          .eq('venue_id', venueId);

      final totalBookings = bookingsResponse.length;
      print('📅 ActivityService: Total bookings: $totalBookings');

      // Fetch tournament bookings count
      final tournamentBookingsResponse = await _supabase
          .from('tournament_registrations')
          .select('id, tournaments!inner(venue_id)')
          .eq('tournaments.venue_id', venueId);

      final tournamentBookings = tournamentBookingsResponse.length;
      print('🏆 ActivityService: Tournament bookings: $tournamentBookings');

      // Fetch reviews data
      final reviewsResponse = await _supabase
          .from('venue_reviews')
          .select('id, rating, review_text, created_at, user_profiles!inner(full_name)')
          .eq('venue_id', venueId)
          .order('created_at', ascending: false);

      print('⭐ ActivityService: Found ${reviewsResponse.length} reviews');

      // Process reviews
      final reviews = reviewsResponse.map((review) {
        return ReviewItem(
          id: review['id'].toString(),
          rating: review['rating'] ?? 0,
          reviewText: review['review_text'] ?? '',
          userName: review['user_profiles']['full_name'] ?? 'Anonymous',
          createdAt: DateTime.parse(review['created_at']),
        );
      }).toList();

      // Calculate average rating
      double averageRating = 0.0;
      if (reviews.isNotEmpty) {
        final totalRating = reviews.fold(0, (sum, review) => sum + review.rating);
        averageRating = totalRating / reviews.length;
      }

      print('📊 ActivityService: Average rating: ${averageRating.toStringAsFixed(2)}');

      final activityData = ActivityData(
        totalBookings: totalBookings,
        tournamentBookings: tournamentBookings,
        totalReviews: reviews.length,
        averageRating: averageRating,
        recentReviews: reviews.take(5).toList(), // Get latest 5 reviews
      );

      print('✅ ActivityService: Successfully created activity data');
      return activityData;

    } catch (e) {
      print('❌ ActivityService Error: $e');
      throw Exception('Failed to fetch activity data: $e');
    }
  }
}