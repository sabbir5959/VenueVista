import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_config.dart';

/// Admin tournament service for managing all tournaments
class AdminTournamentService {
  static final SupabaseClient _client = SupabaseConfig.client;

  /// Get all tournaments with status calculation based on date and duration
  static Future<List<Map<String, dynamic>>> getAllTournaments() async {
    try {
      final response = await _client
          .from('tournaments')
          .select('''
            *,
            venues!venue_id (name, area, city),
            user_profiles!organizer_id (full_name, email, phone)
          ''')
          .order('tournament_date', ascending: false);

      // Calculate status for each tournament
      final now = DateTime.now();
      final tournamentsWithStatus =
          response.map<Map<String, dynamic>>((tournament) {
            // Handle null values safely
            final tournamentDateStr = tournament['tournament_date'] as String?;
            if (tournamentDateStr == null || tournamentDateStr.isEmpty) {
              return {
                ...tournament,
                'status': 'upcoming',
                'end_date': null,
                'tournament_date': null,
                'start_time': tournament['start_time'] ?? null,
                'duration_hours': tournament['duration_hours'] ?? 1,
              };
            }

            try {
              final tournamentDate = DateTime.parse(tournamentDateStr);
              final durationHours = (tournament['duration_hours'] as int?) ?? 1;
              final endDate = tournamentDate.add(
                Duration(hours: durationHours),
              );

              String status;
              if (endDate.isBefore(now)) {
                status = 'completed';
              } else if (tournamentDate.isAfter(now)) {
                status = 'upcoming';
              } else {
                status = 'active';
              }

              return {
                ...tournament,
                'status': status,
                'end_date': endDate.toIso8601String(),
              };
            } catch (e) {
              return {...tournament, 'status': 'upcoming', 'end_date': null};
            }
          }).toList();

      return tournamentsWithStatus;
    } catch (e) {
      print('❌ Error fetching tournaments: $e');
      return [];
    }
  }

  /// Get tournaments filtered by status
  static Future<List<Map<String, dynamic>>> getTournamentsByStatus(
    String status,
  ) async {
    try {
      final allTournaments = await getAllTournaments();

      if (status.toLowerCase() == 'all') {
        return allTournaments;
      }

      return allTournaments
          .where(
            (tournament) =>
                tournament['status'].toLowerCase() == status.toLowerCase(),
          )
          .toList();
    } catch (e) {
      print('❌ Error filtering tournaments by status: $e');
      return [];
    }
  }

  /// Get tournament statistics
  static Future<Map<String, dynamic>> getTournamentStats() async {
    try {
      final allTournaments = await getAllTournaments();

      final totalTournaments = allTournaments.length;
      final activeTournaments =
          allTournaments.where((t) => t['status'] == 'active').length;
      final upcomingTournaments =
          allTournaments.where((t) => t['status'] == 'upcoming').length;
      final completedTournaments =
          allTournaments.where((t) => t['status'] == 'completed').length;

      // Calculate total prize money
      double totalPrizePool = 0.0;
      for (final tournament in allTournaments) {
        final firstPrize = (tournament['first_prize'] ?? 0.0) as double;
        final secondPrize = (tournament['second_prize'] ?? 0.0) as double;
        final thirdPrize = (tournament['third_prize'] ?? 0.0) as double;
        totalPrizePool += firstPrize + secondPrize + thirdPrize;
      }

      // Calculate total registered teams
      int totalRegisteredTeams = 0;
      for (final tournament in allTournaments) {
        totalRegisteredTeams += (tournament['registered_teams'] ?? 0) as int;
      }

      return {
        'totalTournaments': totalTournaments,
        'activeTournaments': activeTournaments,
        'upcomingTournaments': upcomingTournaments,
        'completedTournaments': completedTournaments,
        'totalPrizePool': totalPrizePool,
        'totalRegisteredTeams': totalRegisteredTeams,
      };
    } catch (e) {
      print('❌ Error calculating tournament stats: $e');
      return {
        'totalTournaments': 0,
        'activeTournaments': 0,
        'upcomingTournaments': 0,
        'completedTournaments': 0,
        'totalPrizePool': 0.0,
        'totalRegisteredTeams': 0,
      };
    }
  }

  /// Update tournament status (if needed manually)
  static Future<bool> updateTournamentStatus(
    String tournamentId,
    String status,
  ) async {
    try {
      await _client
          .from('tournaments')
          .update({'status': status})
          .eq('tournament_id', tournamentId);

      return true;
    } catch (e) {
      print('❌ Error updating tournament status: $e');
      return false;
    }
  }

  /// Delete tournament (admin only)
  static Future<bool> deleteTournament(String tournamentId) async {
    try {
      await _client
          .from('tournaments')
          .delete()
          .eq('tournament_id', tournamentId);

      return true;
    } catch (e) {
      print('❌ Error deleting tournament: $e');
      return false;
    }
  }

  /// Get tournament details with registrations
  static Future<Map<String, dynamic>?> getTournamentDetails(
    String tournamentId,
  ) async {
    try {
      final tournamentResponse =
          await _client
              .from('tournaments')
              .select('''
            *,
            venues!venue_id (name, area, city, address),
            user_profiles!organizer_id (full_name, email, phone, company_name)
          ''')
              .eq('tournament_id', tournamentId)
              .single();

      // Get tournament registrations
      final registrationsResponse = await _client
          .from('tournament_registrations')
          .select('''
            *,
            user_profiles!user_id (full_name, email, phone)
          ''')
          .eq('tournament_id', tournamentResponse['id']);

      // Calculate status
      final now = DateTime.now();
      final tournamentDate = DateTime.parse(
        tournamentResponse['tournament_date'],
      );
      final durationHours = tournamentResponse['duration_hours'] as int;
      final endDate = tournamentDate.add(Duration(hours: durationHours));

      String status;
      if (endDate.isBefore(now)) {
        status = 'completed';
      } else if (tournamentDate.isAfter(now)) {
        status = 'upcoming';
      } else {
        status = 'active';
      }

      return {
        ...tournamentResponse,
        'status': status,
        'end_date': endDate.toIso8601String(),
        'registrations': registrationsResponse,
      };
    } catch (e) {
      print('❌ Error fetching tournament details: $e');
      return null;
    }
  }

  /// Format tournament data for display
  static Map<String, dynamic> formatTournamentForDisplay(
    Map<String, dynamic> tournament,
  ) {
    try {
      final venue = tournament['venues'] as Map<String, dynamic>?;
      final organizer = tournament['user_profiles'] as Map<String, dynamic>?;

      final formattedData = {
        'id': tournament['tournament_id']?.toString() ?? '',
        'name': tournament['name']?.toString() ?? 'Unknown Tournament',
        'description':
            tournament['description']?.toString() ?? 'No description available',
        'venue': venue?['name']?.toString() ?? 'Unknown Venue',
        'location':
            '${venue?['area']?.toString() ?? ''}, ${venue?['city']?.toString() ?? ''}',
        'owner': organizer?['full_name']?.toString() ?? 'Unknown Organizer',
        'organizerEmail': organizer?['email']?.toString() ?? 'N/A',
        'organizerPhone': organizer?['phone']?.toString() ?? 'N/A',
        'date': tournament['tournament_date']?.toString() ?? 'TBD',
        'startTime': tournament['start_time']?.toString() ?? 'TBD',
        'duration': tournament['duration_hours']?.toString() ?? '0',
        'participants': tournament['max_teams']?.toString() ?? '0',
        'playersPerTeam': tournament['team_size']?.toString() ?? '5',
        'entryFee': (tournament['entry_fee'] ?? 0.0).toString(),
        'firstPrize': (tournament['first_prize'] ?? 0.0).toString(),
        'secondPrize': (tournament['second_prize'] ?? 0.0).toString(),
        'thirdPrize': (tournament['third_prize'] ?? 0.0).toString(),
        'type': tournament['player_format']?.toString() ?? 'Tournament',
        'status': tournament['status']?.toString() ?? 'unknown',
        'imageUrl': tournament['image_url']?.toString(),
        'createdAt': tournament['created_at']?.toString(),
      };

      return formattedData;
    } catch (e) {
      print('❌ Error formatting tournament data: $e');

      // Return safe fallback data
      return {
        'id': '',
        'name': 'Unknown Tournament',
        'description': 'No description available',
        'venue': 'Unknown Venue',
        'location': 'Unknown Location',
        'owner': 'Unknown Organizer',
        'organizerEmail': 'N/A',
        'organizerPhone': 'N/A',
        'date': 'TBD',
        'startTime': 'TBD',
        'duration': '0',
        'participants': '0',
        'playersPerTeam': '5',
        'entryFee': '0.0',
        'firstPrize': '0.0',
        'secondPrize': '0.0',
        'thirdPrize': '0.0',
        'type': 'Tournament',
        'status': 'unknown',
        'imageUrl': null,
        'createdAt': null,
      };
    }
  }

  /// Get tournaments for a specific date range
  static Future<List<Map<String, dynamic>>> getTournamentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _client
          .from('tournaments')
          .select('''
            *,
            venues!venue_id (name, area, city),
            user_profiles!organizer_id (full_name, email, phone)
          ''')
          .gte('tournament_date', startDate.toIso8601String().split('T')[0])
          .lte('tournament_date', endDate.toIso8601String().split('T')[0])
          .order('tournament_date', ascending: true);

      // Calculate status for each tournament
      final now = DateTime.now();
      final tournamentsWithStatus =
          response.map<Map<String, dynamic>>((tournament) {
            // Check if tournament_date is null
            if (tournament['tournament_date'] == null) {
              return {...tournament, 'status': 'unknown', 'end_date': null};
            }

            try {
              final tournamentDate = DateTime.parse(
                tournament['tournament_date'],
              );
              final durationHours =
                  (tournament['duration_hours'] as int?) ??
                  2; // Default 2 hours
              final endDate = tournamentDate.add(
                Duration(hours: durationHours),
              );

              String status;
              if (endDate.isBefore(now)) {
                status = 'completed';
              } else if (tournamentDate.isAfter(now)) {
                status = 'upcoming';
              } else {
                status = 'active';
              }

              return {
                ...tournament,
                'status': status,
                'end_date': endDate.toIso8601String(),
              };
            } catch (e) {
              return {...tournament, 'status': 'unknown', 'end_date': null};
            }
          }).toList();

      return tournamentsWithStatus;
    } catch (e) {
      print('❌ Error fetching tournaments by date range: $e');
      return [];
    }
  }
}
