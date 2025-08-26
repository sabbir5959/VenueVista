import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'tournament_details.dart';

class TournamentListPage extends StatelessWidget {
  final String title;
  final String filter;
  final MaterialColor color;
  final List<Map<String, dynamic>> tournaments;

  const TournamentListPage({
    Key? key,
    required this.title,
    required this.filter,
    required this.color,
    required this.tournaments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color[700],
      ),
      body: tournaments.isEmpty
          ? _buildEmptyState()
          : _buildTournamentList(context),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tournaments found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new tournaments',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return _buildTournamentCard(tournament, context);
      },
    );
  }

  Widget _buildTournamentCard(Map<String, dynamic> tournament, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TournamentDetailsPage(
                tournament: tournament,
                filter: filter,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tournament Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tournament['name'] ?? 'Unnamed Tournament',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tournament['player_format'] ?? '11v11',
                      style: TextStyle(
                        color: color[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Tournament Details
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(tournament['tournament_date']),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(tournament['start_time']),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${tournament['registered_teams'] ?? 0}/${tournament['max_teams'] ?? 0} teams',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.monetization_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '৳${tournament['entry_fee'] ?? 0}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.emoji_events, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Prize: ৳${tournament['first_prize'] ?? 0}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              if (tournament['description'] != null && tournament['description'].isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  tournament['description'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'TBD';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'TBD';
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null) return 'TBD';
    try {
      final timeParts = timeString.split(':');
      if (timeParts.length >= 2) {
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
      }
      return timeString;
    } catch (e) {
      return 'TBD';
    }
  }
}
