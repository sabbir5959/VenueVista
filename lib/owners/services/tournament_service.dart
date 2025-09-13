import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerTournamentService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Check if the tournament date conflicts with maintenance
  static Future<bool> checkMaintenanceConflict(String venueId, DateTime tournamentDate) async {
    try {
      final response = await _client
          .from('venues')
          .select('maintenance_start, maintenance_end, maintenance_reason')
          .eq('id', venueId)
          .not('maintenance_start', 'is', null)
          .not('maintenance_end', 'is', null);

      if (response.isEmpty) return false;

      final venue = response.first;
      final maintenanceStart = DateTime.parse(venue['maintenance_start']);
      final maintenanceEnd = DateTime.parse(venue['maintenance_end']);

      return tournamentDate.isAfter(maintenanceStart.subtract(const Duration(days: 1))) &&
             tournamentDate.isBefore(maintenanceEnd.add(const Duration(days: 1)));
    } catch (e) {
      print('Error checking maintenance conflict: $e');
      return false;
    }
  }

  /// Create a new tournament (Owner specific)
  static Future<Map<String, dynamic>> createTournament({
    required String name,
    required String description,
    required String venueId,
    required String organizerId,
    required DateTime tournamentDate,
    required String startTime,
    required int durationHours,
    required int teamSize,
    required int maxTeams,
    required double entryFee,
    double? firstPrize,
    double? secondPrize,
    double? thirdPrize,
    required String playerFormat,
    String? imageUrl,
  }) async {
    try {
      // First check for maintenance conflicts
      final hasMaintenanceConflict = await checkMaintenanceConflict(venueId, tournamentDate);
      if (hasMaintenanceConflict) {
        // Get maintenance details for error message
        final maintenanceResponse = await _client
            .from('venues')
            .select('maintenance_start, maintenance_end, maintenance_reason')
            .eq('id', venueId)
            .single();
        
        final reason = maintenanceResponse['maintenance_reason'] ?? 'Maintenance scheduled';
        final startDate = DateTime.parse(maintenanceResponse['maintenance_start']).toLocal();
        final endDate = DateTime.parse(maintenanceResponse['maintenance_end']).toLocal();
        
        throw Exception(
          'Cannot create tournament on this date. Venue maintenance is scheduled: '
          '$reason (${startDate.day}/${startDate.month}/${startDate.year} - '
          '${endDate.day}/${endDate.month}/${endDate.year})'
        );
      }

      // Generate unique tournament ID
      final tournamentId = 'TOURN${DateTime.now().millisecondsSinceEpoch}';

      final tournamentData = {
        'tournament_id': tournamentId,
        'name': name,
        'description': description,
        'venue_id': venueId,
        'organizer_id': organizerId,
        'tournament_date': tournamentDate.toIso8601String().split('T')[0],
        'start_time': startTime,
        'duration_hours': durationHours,
        'team_size': teamSize,
        'max_teams': maxTeams,
        'registered_teams': 0,
        'entry_fee': entryFee,
        'first_prize': firstPrize,
        'second_prize': secondPrize,
        'third_prize': thirdPrize,
        'player_format': playerFormat,
        'image_url': imageUrl ?? 'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?auto=format&fit=crop&w=800&q=80',
      };

      print('DEBUG [OWNER]: Creating tournament with data: $tournamentData');

      final response = await _client
          .from('tournaments')
          .insert(tournamentData)
          .select()
          .single();

      print('DEBUG [OWNER]: Tournament created successfully: $response');
      return response;
    } catch (e) {
      print('DEBUG [OWNER]: Tournament creation error: $e');
      if (e is PostgrestException) {
        print('DEBUG [OWNER]: PostgrestException details: ${e.message}');
        print('DEBUG [OWNER]: PostgrestException code: ${e.code}');
        print('DEBUG [OWNER]: PostgrestException details: ${e.details}');
      }
      rethrow;
    }
  }

  /// Get tournaments by organizer (Owner specific)
  static Future<List<Map<String, dynamic>>> getOwnerTournaments(String organizerId) async {
    try {
      print('DEBUG [OWNER]: Fetching tournaments for organizer: $organizerId');
      
      final response = await _client
          .from('tournaments')
          .select('*')
          .eq('organizer_id', organizerId)
          .order('tournament_date', ascending: true);
      
      print('DEBUG [OWNER]: Retrieved ${response.length} tournaments for organizer');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('DEBUG [OWNER]: Error fetching tournaments by organizer: $e');
      if (e is PostgrestException) {
        print('DEBUG [OWNER]: PostgrestException details: ${e.message}');
      }
      rethrow;
    }
  }

  /// Get owner's venues (to populate dropdown in create tournament)
  static Future<List<Map<String, dynamic>>> getOwnerVenues(String ownerId) async {
    try {
      print('DEBUG [OWNER]: Fetching venues for owner: $ownerId');
      // First attempt: fetch active venues
      final activeResponse = await _client
          .from('venues')
          .select('id, name, city, area, capacity, status, maintenance_start, maintenance_end')
          .eq('owner_id', ownerId)
          .eq('status', 'active')
          .order('name', ascending: true);

      print('DEBUG [OWNER]: Active venues count: ${activeResponse.length}');

      if (activeResponse.isNotEmpty) {
        return List<Map<String, dynamic>>.from(activeResponse);
      }

      // If no active venues, fallback to any venues (maybe under maintenance)
      final anyResponse = await _client
          .from('venues')
          .select('id, name, city, area, capacity, status, maintenance_start, maintenance_end')
          .eq('owner_id', ownerId)
          .order('name', ascending: true);

      print('DEBUG [OWNER]: Fallback any-status venues count: ${anyResponse.length}');
      if (anyResponse.isEmpty) {
        print('DEBUG [OWNER]: No venues found at all for owner $ownerId');
      } else {
        final statuses = anyResponse.map((v) => v['status']).toSet();
        print('DEBUG [OWNER]: Found venues with statuses: $statuses');
      }

      return List<Map<String, dynamic>>.from(anyResponse);
    } catch (e) {
      print('DEBUG [OWNER]: Error fetching venues by owner: $e');
      if (e is PostgrestException) {
        print('DEBUG [OWNER]: PostgrestException details: ${e.message}');
      }
      rethrow;
    }
  }

  /// Update tournament (Owner specific)
  static Future<Map<String, dynamic>> updateTournament(
    String tournamentId,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('DEBUG [OWNER]: Updating tournament $tournamentId with: $updates');
      
      final response = await _client
          .from('tournaments')
          .update(updates)
          .eq('id', tournamentId)  // Use 'id' (UUID) instead of 'tournament_id'
          .select()
          .single();
      
      print('DEBUG [OWNER]: Tournament updated successfully: $response');
      return response;
    } catch (e) {
      print('DEBUG [OWNER]: Error updating tournament: $e');
      if (e is PostgrestException) {
        print('DEBUG [OWNER]: PostgrestException details: ${e.message}');
      }
      rethrow;
    }
  }

  /// Delete tournament (Owner specific)
  static Future<void> deleteTournament(String tournamentId) async {
    try {
      print('DEBUG [OWNER]: Deleting tournament with ID: $tournamentId');
      
      await _client
          .from('tournaments')
          .delete()
          .eq('id', tournamentId);  // Use 'id' (UUID) instead of 'tournament_id'
      
      print('DEBUG [OWNER]: Tournament deleted successfully');
    } catch (e) {
      print('DEBUG [OWNER]: Error deleting tournament: $e');
      if (e is PostgrestException) {
        print('DEBUG [OWNER]: PostgrestException details: ${e.message}');
      }
      rethrow;
    }
  }

  /// Get tournament statistics for owner dashboard
  static Future<Map<String, dynamic>> getTournamentStats(String organizerId) async {
    try {
      print('DEBUG [OWNER]: Fetching tournament statistics for organizer: $organizerId');
      
      final tournaments = await getOwnerTournaments(organizerId);
      
      final totalTournaments = tournaments.length;
      final activeTournaments = tournaments.where((t) => 
        DateTime.parse(t['tournament_date']).isAfter(DateTime.now())).length;
      final totalRegistrations = tournaments.fold<int>(0, 
        (sum, t) => sum + (t['registered_teams'] as int? ?? 0));
      final totalRevenue = tournaments.fold<double>(0.0, 
        (sum, t) => sum + ((t['registered_teams'] as int? ?? 0) * (t['entry_fee'] as double? ?? 0.0)));
      
      final stats = {
        'total_tournaments': totalTournaments,
        'active_tournaments': activeTournaments,
        'total_registrations': totalRegistrations,
        'total_revenue': totalRevenue,
      };
      
      print('DEBUG [OWNER]: Tournament stats: $stats');
      return stats;
    } catch (e) {
      print('DEBUG [OWNER]: Error fetching tournament stats: $e');
      rethrow;
    }
  }

  // ========================================
  // USER-RELATED FUNCTIONS (For User Pages)
  // ========================================

  /// Get all tournaments for users to view (created by owners)
  static Future<List<Map<String, dynamic>>> getAllTournamentsForUsers() async {
    try {
      print('DEBUG [USER]: Fetching all tournaments for users from database');
      
      final response = await _client
          .from('tournaments')
          .select('''
            *,
            venues:venue_id (
              name,
              city,
              area,
              address
            ),
            organizers:organizer_id (
              full_name,
              company_name
            )
          ''')
          .order('tournament_date', ascending: true);
      
      print('DEBUG [USER]: Retrieved ${response.length} tournaments for users');
      if (response.isNotEmpty) {
        print('DEBUG [USER]: Sample tournament: ${response.first}');
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('DEBUG [USER]: Error fetching tournaments: $e');
      if (e is PostgrestException) {
        print('DEBUG [USER]: PostgrestException details: ${e.message}');
      }
      rethrow;
    }
  }

  /// Get upcoming tournaments for users
  static Future<List<Map<String, dynamic>>> getUpcomingTournamentsForUsers() async {
    try {
      print('DEBUG [USER]: Fetching upcoming tournaments for users');
      
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final response = await _client
          .from('tournaments')
          .select('''
            *,
            venues:venue_id (
              name,
              city,
              area
            ),
            organizers:organizer_id (
              full_name,
              company_name
            )
          ''')
          .gte('tournament_date', today)
          .order('tournament_date', ascending: true);
      
      print('DEBUG [USER]: Retrieved ${response.length} upcoming tournaments');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('DEBUG [USER]: Error fetching upcoming tournaments: $e');
      rethrow;
    }
  }
}
