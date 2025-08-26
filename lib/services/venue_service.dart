import '../services/supabase_config.dart';

class VenueService {
  static final _supabase = SupabaseConfig.client;

  // Get all venues/grounds
  static Future<List<Map<String, dynamic>>> getAllVenues() async {
    try {
      print('🚀 Fetching all venues from Supabase...');
      final response = await _supabase
          .from('venues')
          .select('*')
          .eq('status', 'active')
          .order('created_at', ascending: false);

      print('✅ Venues fetched: ${response.length}');
      print('📊 Raw response: $response');

      // Debug: Print actual data to see what's in the table
      for (int i = 0; i < response.length && i < 3; i++) {
        print('🔍 Venue ${i + 1}: ${response[i]}');
        print('🖼️ Image URL: ${response[i]['image_url']}');
      }
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching venues: $e');
      print('📋 Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Get featured venues (top rated or most popular)
  static Future<List<Map<String, dynamic>>> getFeaturedVenues({
    int limit = 10,
  }) async {
    try {
      final response = await _supabase
          .from('venues')
          .select('*')
          .eq('status', 'active')
          .gte('rating', 4.0) // Get venues with rating 4.0 or higher
          .order('rating', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit);

      print('✅ Featured venues fetched: ${response.length}');
      // Debug: Print detailed image URLs to see what's stored
      for (var venue in response) {
        print('🖼️ VENUE: ${venue['name']}');
        print('   - image_url field exists: ${venue.containsKey('image_url')}');
        print('   - image_url value: "${venue['image_url']}"');
        print('   - image_url type: ${venue['image_url'].runtimeType}');
        print(
          '   - image_url isEmpty: ${venue['image_url']?.toString().isEmpty}',
        );
        print('   - All fields: ${venue.keys.toList()}');
        print('---');
      }
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching featured venues: $e');
      return [];
    }
  }

  // Get venues by location
  static Future<List<Map<String, dynamic>>> getVenuesByLocation(
    String location,
  ) async {
    try {
      final response = await _supabase
          .from('venues')
          .select('*')
          .eq('status', 'active')
          .ilike('location', '%$location%')
          .order('rating', ascending: false);

      print('✅ Venues by location fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching venues by location: $e');
      return [];
    }
  }

  // Get venues by sport type
  static Future<List<Map<String, dynamic>>> getVenuesBySport(
    String sport,
  ) async {
    try {
      final response = await _supabase
          .from('venues')
          .select('*')
          .eq('status', 'active')
          .ilike('sport_type', '%$sport%')
          .order('rating', ascending: false);

      print('✅ Venues by sport fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching venues by sport: $e');
      return [];
    }
  }

  // Search venues by name or description
  static Future<List<Map<String, dynamic>>> searchVenues(String query) async {
    try {
      final response = await _supabase
          .from('venues')
          .select('*')
          .eq('status', 'active')
          .or(
            'name.ilike.%$query%,description.ilike.%$query%,location.ilike.%$query%',
          )
          .order('rating', ascending: false);

      print('✅ Search results: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error searching venues: $e');
      return [];
    }
  }

  // Get venue by ID
  static Future<Map<String, dynamic>?> getVenueById(String venueId) async {
    try {
      final response =
          await _supabase.from('venues').select('*').eq('id', venueId).single();

      print('✅ Venue details fetched for ID: $venueId');
      return response;
    } catch (e) {
      print('❌ Error fetching venue details: $e');
      return null;
    }
  }

  // Get venues with price filter
  static Future<List<Map<String, dynamic>>> getVenuesByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      final response = await _supabase
          .from('venues')
          .select('*')
          .eq('status', 'active')
          .gte('price_per_hour', minPrice)
          .lte('price_per_hour', maxPrice)
          .order('price_per_hour', ascending: true);

      print('✅ Venues by price range fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching venues by price range: $e');
      return [];
    }
  }
}
