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
          .select('*')
          .gte(
            'tournament_date',
            DateTime.now().toIso8601String().split('T')[0],
          )
          .order('tournament_date', ascending: true)
          .limit(limit);

      print('✅ Featured tournaments fetched: ${response.length}');
      // Debug: Print tournament data
      for (var tournament in response) {
        print('🏆 ${tournament['name']}: ${tournament['tournament_date']}');
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
          .select('*')
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
          .gte('start_date', DateTime.now().toIso8601String())
          .order('start_date', ascending: true);

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
  ) async {
    try {
      await _supabase.from('tournament_registrations').insert({
        'tournament_id': tournamentId,
        'user_id': userId,
        'registration_date': DateTime.now().toIso8601String(),
        'status': 'registered',
      });

      print('✅ User registered for tournament: $tournamentId');
      return true;
    } catch (e) {
      print('❌ Error registering for tournament: $e');
      return false;
    }
  }

  // Get user's registered tournaments
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
}
