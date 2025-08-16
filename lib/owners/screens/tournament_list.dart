import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'tournament_details.dart';

class TournamentListPage extends StatelessWidget {
  final String title;
  final String filter;
  final MaterialColor color;

  const TournamentListPage({
    Key? key,
    required this.title,
    required this.filter,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color[700],
      ),
      body: _buildEventList(filter, context),
    );
  }

  Widget _buildEventList(String filter, BuildContext context) {
    final DateTime now = DateTime.now();
    final events = [
      {
        'name': 'Football Championship',
        'sport': 'Football',
        'date': DateTime(2025, 8, 15, 10, 0),
        'teamSize': '11',
        'fee': '\u09F3 5000',
        'venue': 'Main Football Ground',
        'maxTeams': '16',
        'registeredTeams': '12',
        'duration': '1 Day',
        'firstPrize': '\u09F3 15,000',
        'secondPrize': '\u09F3 10,000',
        'thirdPrize': '\u09F3 5,000',
        'organizer': 'VenueVista Sports',
        'phone': '+880 1700-594133',
        'email': 'football@venuevista.com',
      },
      {
        'name': 'Premier League Tournament',
        'sport': 'Football',
        'date': DateTime(2025, 8, 20, 14, 0),
        'teamSize': '11',
        'fee': '\u09F3 7000',
        'venue': 'Football Stadium',
        'maxTeams': '12',
        'registeredTeams': '8',
        'duration': '2 Days',
        'firstPrize': '\u09F3 20,000',
        'secondPrize': '\u09F3 15,000',
        'thirdPrize': '\u09F3 8,000',
        'organizer': 'VenueVista Sports',
        'phone': '+880 1700-594133',
        'email': 'football@venuevista.com',
      },
      {
        'name': 'Youth Football Cup',
        'sport': 'Football',
        'date': DateTime(2025, 7, 25, 16, 0),
        'teamSize': '11',
        'fee': '\u09F3 3000',
        'venue': 'Youth Football Ground',
        'maxTeams': '8',
        'registeredTeams': '8',
        'duration': '1 Day',
        'firstPrize': '\u09F3 12,000',
        'secondPrize': '\u09F3 8,000',
        'thirdPrize': '\u09F3 4,000',
        'organizer': 'VenueVista Sports',
        'phone': '+880 1700-594133',
        'email': 'football@venuevista.com',
      },
      {
        'name': 'District Football League',
        'sport': 'Football',
        'date': DateTime(2025, 9, 5, 9, 0),
        'teamSize': '11',
        'fee': '\u09F3 4000',
        'venue': 'District Football Ground',
        'maxTeams': '20',
        'registeredTeams': '16',
        'duration': '3 Days',
        'firstPrize': '\u09F3 25,000',
        'secondPrize': '\u09F3 15,000',
        'thirdPrize': '\u09F3 8,000',
        'organizer': 'VenueVista Sports',
        'phone': '+880 1700-594133',
        'email': 'football@venuevista.com',
      },
    ];

    final filteredEvents = events.where((event) {
      final eventDate = event['date'] as DateTime;
      if (filter == 'Ongoing') {
        return eventDate.isBefore(now) && eventDate.add(const Duration(hours: 2)).isAfter(now);
      } else if (filter == 'Upcoming') {
        return eventDate.isAfter(now);
      } else if (filter == 'Past') {
        return eventDate.isBefore(now);
      }
      return false;
    }).toList();

    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
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

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TournamentDetailsPage(
                    tournament: event,
                    filter: filter,
                  ),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundColor: color[100],
              child: Icon(
                Icons.sports_soccer,
                color: color[700],
              ),
            ),
            title: Text(
              event['name'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${event['sport']} • ${_formatDate(event['date'] as DateTime)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Teams: ${event['teamSize']} players • Fee: ${event['fee']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            trailing: filter == 'Ongoing'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navigate to edit page
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.lock, color: Colors.red),
                        onPressed: () {
                      
                        },
                      ),
                    ],
                  )
                : filter == 'Past'
                    ? IconButton(
                        icon: const Icon(Icons.people, color: Colors.green),
                        onPressed: () {
                          
                        },
                      )
                    : const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }
}
