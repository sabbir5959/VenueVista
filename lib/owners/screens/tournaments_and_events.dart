import 'package:flutter/material.dart';
import '../widgets/venue_owner_sidebar.dart';
import '../widgets/owner_profile_widget.dart';
import 'tournament_list.dart';

class TournamentsAndEventsPage extends StatefulWidget {
  const TournamentsAndEventsPage({Key? key}) : super(key: key);

  @override
  State<TournamentsAndEventsPage> createState() => _TournamentsAndEventsPageState();
}

class _TournamentsAndEventsPageState extends State<TournamentsAndEventsPage> {
  final DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments & Events'),
        backgroundColor: Colors.green[700],
        actions: [
          OwnerProfileWidget(),
        ],
      ),
      drawer: const VenueOwnerSidebar(currentPage: 'tournaments'),
      body: SingleChildScrollView(
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
            
            // Ongoing Tournaments Card (Green)
            _buildCategoryCard(
              'Ongoing Tournaments',
              'Currently active tournaments',
              Colors.green,
              Icons.play_circle_filled,
              'Ongoing',
            ),
            
            const SizedBox(height: 16),
            
            // Upcoming Tournaments Card (Blue)
            _buildCategoryCard(
              'Upcoming Tournaments',
              'Tournaments scheduled for future',
              Colors.blue,
              Icons.schedule,
              'Upcoming',
            ),
            
            const SizedBox(height: 16),
            
            // Past Tournaments Card (Red)
            _buildCategoryCard(
              'Past Tournaments',
              'Completed tournaments',
              Colors.red,
              Icons.history,
              'Past',
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
  ) {
    final events = _getFilteredEvents(filter);
    
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
                          '${events.length} tournament${events.length != 1 ? 's' : ''}',
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

  List<Map<String, dynamic>> _getFilteredEvents(String filter) {
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

    return events.where((event) {
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
  }
}
