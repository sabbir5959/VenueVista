import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/venue_owner_sidebar.dart';
import '../widgets/owner_profile_widget.dart';
import '../services/tournament_service.dart';
import 'tournament_list.dart';

class TournamentsAndEventsPage extends StatefulWidget {
  const TournamentsAndEventsPage({Key? key}) : super(key: key);

  @override
  State<TournamentsAndEventsPage> createState() => _TournamentsAndEventsPageState();
}

class _TournamentsAndEventsPageState extends State<TournamentsAndEventsPage> {
  final DateTime now = DateTime.now();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _upcomingTournaments = [];
  List<Map<String, dynamic>> _ongoingTournaments = [];
  List<Map<String, dynamic>> _pastTournaments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Fetch tournaments for current owner
        final tournaments = await OwnerTournamentService.getOwnerTournaments(user.id);
        
        // Categorize tournaments based on date and time
        _categorizeTournaments(tournaments);
      }
    } catch (e) {
      print('Error loading tournaments: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _categorizeTournaments(List<Map<String, dynamic>> tournaments) {
    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);
    
    List<Map<String, dynamic>> upcoming = [];
    List<Map<String, dynamic>> ongoing = [];
    List<Map<String, dynamic>> past = [];

    for (var tournament in tournaments) {
      final tournamentDate = DateTime.parse(tournament['tournament_date']);
      final tournamentDay = DateTime(tournamentDate.year, tournamentDate.month, tournamentDate.day);
      
      if (tournamentDay.isAfter(currentDate)) {
        // Future tournament
        upcoming.add(tournament);
      } else if (tournamentDay.isAtSameMomentAs(currentDate)) {
        // Today's tournament - check if ongoing
        if (_isTournamentOngoing(tournament)) {
          ongoing.add(tournament);
        } else if (_isTournamentFinished(tournament)) {
          past.add(tournament);
        } else {
          upcoming.add(tournament); // Not started yet today
        }
      } else {
        // Past tournament
        past.add(tournament);
      }
    }

    setState(() {
      _upcomingTournaments = upcoming;
      _ongoingTournaments = ongoing;
      _pastTournaments = past;
    });
  }

  bool _isTournamentOngoing(Map<String, dynamic> tournament) {
    final now = DateTime.now();
    final tournamentDate = DateTime.parse(tournament['tournament_date']);
    final startTime = tournament['start_time'] as String;
    final durationHours = tournament['duration_hours'] as int;

    // Parse start time (format: "HH:mm:ss")
    final timeParts = startTime.split(':');
    final startHour = int.parse(timeParts[0]);
    final startMinute = int.parse(timeParts[1]);

    final tournamentStart = DateTime(
      tournamentDate.year,
      tournamentDate.month,
      tournamentDate.day,
      startHour,
      startMinute,
    );
    
    final tournamentEnd = tournamentStart.add(Duration(hours: durationHours));

    return now.isAfter(tournamentStart) && now.isBefore(tournamentEnd);
  }

  bool _isTournamentFinished(Map<String, dynamic> tournament) {
    final now = DateTime.now();
    final tournamentDate = DateTime.parse(tournament['tournament_date']);
    final startTime = tournament['start_time'] as String;
    final durationHours = tournament['duration_hours'] as int;

    // Parse start time
    final timeParts = startTime.split(':');
    final startHour = int.parse(timeParts[0]);
    final startMinute = int.parse(timeParts[1]);

    final tournamentStart = DateTime(
      tournamentDate.year,
      tournamentDate.month,
      tournamentDate.day,
      startHour,
      startMinute,
    );
    
    final tournamentEnd = tournamentStart.add(Duration(hours: durationHours));

    return now.isAfter(tournamentEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VenueVista'),
        backgroundColor: Colors.green[700],
        actions: [
          OwnerProfileWidget(),
        ],
      ),
      drawer: const VenueOwnerSidebar(currentPage: 'tournaments'),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tournament Categories',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            
            
            _buildCategoryCard(
              'Ongoing Tournaments',
              'Currently active tournaments',
              Colors.green,
              Icons.play_circle_filled,
              'Ongoing',
              _ongoingTournaments,
            ),
            
            const SizedBox(height: 16),
            
            
            _buildCategoryCard(
              'Upcoming Tournaments',
              'Tournaments scheduled for future',
              Colors.blue,
              Icons.schedule,
              'Upcoming',
              _upcomingTournaments,
            ),
            
            const SizedBox(height: 16),
            
           
            _buildCategoryCard(
              'Past Tournaments',
              'Completed tournaments',
              Colors.red,
              Icons.history,
              'Past',
              _pastTournaments,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    String subtitle,
    MaterialColor color,
    IconData icon,
    String filter,
    List<Map<String, dynamic>> tournaments,
  ) {
    final count = tournaments.length;
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color[400]!,
              color[600]!,
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TournamentListPage(
                    title: title,
                    filter: filter,
                    color: color,
                    tournaments: tournaments,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${count} tournament${count != 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
