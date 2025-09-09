import '../services/supabase_config.dart';

class TournamentService {
  static final _supabase = SupabaseConfig.client;

  // Get all tournaments
  static Future<List<Map<String, dynamic>>> getAllTournaments() async {
    try {
      final response = await _supabase
          .from('tournaments')
          .select('*')
          .order('created_at', ascending: false);

      print('✅ Tournaments fetched: ${response.length}');
      // Debug: Print actual data to see what's in the table
      for (int i = 0; i < response.length && i < 3; i++) {
        print('🔍 Tournament ${i + 1}: ${response[i]}');
      }
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching tournaments: $e');
      return [];
    }
  }

  // Get featured tournaments (upcoming ones)
  static Future<List<Map<String, dynamic>>> getFeaturedTournaments({
    int limit = 5,
  }) async {
    try {
      final response = await _supabase
          .from('tournaments')
          .select('''
            *,
            venues (
              name,
              address
            )
          ''')
          .gte(
            'tournament_date',
            DateTime.now().toIso8601String().split('T')[0],
          )
          .order('tournament_date', ascending: true)
          .limit(limit);

      print('✅ Featured tournaments fetched: ${response.length}');
      // Debug: Print tournament data
      for (var tournament in response) {
        print(
          '🏆 ${tournament['name']}: ${tournament['tournament_date']} at ${tournament['venues']?['name'] ?? 'Unknown Venue'}',
        );
      }
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching featured tournaments: $e');
      return [];
    }
  }

  // Get upcoming tournaments
  static Future<List<Map<String, dynamic>>> getUpcomingTournaments({
    int limit = 10,
  }) async {
    try {
      final response = await _supabase
          .from('tournaments')
          .select('''
            *,
            venues (
              name,
              address
            )
          ''')
          .gte(
            'tournament_date',
            DateTime.now().toIso8601String().split('T')[0],
          )
          .order('tournament_date', ascending: true)
          .limit(limit);

      print('✅ Upcoming tournaments fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching upcoming tournaments: $e');
      return [];
    }
  }

  // Get tournaments by sport type
  static Future<List<Map<String, dynamic>>> getTournamentsBySport(
    String sport,
  ) async {
    try {
      final response = await _supabase
          .from('tournaments')
          .select('*')
          .eq('status', 'active')
          .ilike('sport_type', '%$sport%')
          .gte('tournament_date', DateTime.now().toIso8601String().split('T')[0])
          .order('tournament_date', ascending: true);

      print('✅ Tournaments by sport fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching tournaments by sport: $e');
      return [];
    }
  }

  // Search tournaments
  static Future<List<Map<String, dynamic>>> searchTournaments(
    String query,
  ) async {
    try {
      final response = await _supabase
          .from('tournaments')
          .select('*')
          .eq('status', 'active')
          .or(
            'name.ilike.%$query%,description.ilike.%$query%,location.ilike.%$query%',
          )
          .order('start_date', ascending: true);

      print('✅ Tournament search results: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error searching tournaments: $e');
      return [];
    }
  }

  // Get tournament by ID
  static Future<Map<String, dynamic>?> getTournamentById(
    String tournamentId,
  ) async {
    try {
      final response =
          await _supabase
              .from('tournaments')
              .select('*')
              .eq('id', tournamentId)
              .single();

      print('✅ Tournament details fetched for ID: $tournamentId');
      return response;
    } catch (e) {
      print('❌ Error fetching tournament details: $e');
      return null;
    }
  }

  // Register user for tournament
  static Future<bool> registerForTournament(
    String tournamentId,
    String userId,
    String registrationFee,
    String paymentMethod,
  ) async {
    try {
      await _supabase.from('tournament_registrations').insert({
        'tournament_id': tournamentId,
        'user_id': userId,
        'registration_fee': registrationFee,
        'payment_method': paymentMethod,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ User registered for tournament: $tournamentId');
      return true;
    } catch (e) {
      print('❌ Error registering for tournament: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserTournaments(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('tournament_registrations')
          .select('tournaments(*)')
          .eq('user_id', userId)
          .eq('status', 'registered');

      print('✅ User tournaments fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching user tournaments: $e');
      return [];
    }
  }

  // Get user tournament registrations with full tournament details
  static Future<List<Map<String, dynamic>>> getUserTournamentRegistrations(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('tournament_registrations')
          .select('''
            *,
            tournaments (
              *,
              venues (
                name,
                address
              )
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('✅ User tournament registrations fetched: ${response.length}');

      // Debug: Print the structure of returned data
      if (response.isNotEmpty) {
        print('📋 First registration structure: ${response.first}');
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching user tournament registrations: $e');
      return [];
    }
  }

  // Check if user has registered for a tournament
  static Future<bool> hasUserRegistered(String tournamentId, String userId) async {
    try {
      final response = await _supabase
          .from('tournament_registrations')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('user_id', userId)
          .limit(1);
      
      print('✅ Registration check complete for tournament: $tournamentId');
      return response.isNotEmpty;
    } catch (e) {
      print('❌ Error checking tournament registration: $e');
      return false;
    }
  }
}