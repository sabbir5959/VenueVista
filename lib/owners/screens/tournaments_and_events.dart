import 'package:flutter/material.dart';
import '../widgets/venue_owner_sidebar.dart';

class TournamentsAndEventsPage extends StatefulWidget {
  const TournamentsAndEventsPage({Key? key}) : super(key: key);

  @override
  State<TournamentsAndEventsPage> createState() => _TournamentsAndEventsPageState();
}

class _TournamentsAndEventsPageState extends State<TournamentsAndEventsPage> {
  final DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tournaments & Events'),
          backgroundColor: Colors.green[700],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ongoing'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        drawer: const VenueOwnerSidebar(currentPage: 'tournaments'),
        body: TabBarView(
          children: [
            _buildEventList('Ongoing'),
            _buildEventList('Upcoming'),
            _buildEventList('Past'),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(String filter) {
    final events = [
      {
        'name': 'Football Championship',
        'sport': 'Football',
        'date': DateTime(2025, 8, 15, 10, 0),
        'teamSize': '11',
        'fee': '\u09F3 5000',
      },
      {
        'name': 'Cricket League',
        'sport': 'Cricket',
        'date': DateTime(2025, 8, 20, 14, 0),
        'teamSize': '11',
        'fee': '\u09F3 7000',
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
      return const Center(
        child: Text('No events found', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(
                event['sport'] == 'Football' ? Icons.sports_soccer : Icons.sports_cricket,
                color: Colors.green[700],
              ),
            ),
            title: Text(
              event['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${event['date'].toString()}\nTeam Size: ${event['teamSize']}\nFee: ${event['fee']}',
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
                          // Close registration
                        },
                      ),
                    ],
                  )
                : filter == 'Past'
                    ? IconButton(
                        icon: const Icon(Icons.people, color: Colors.green),
                        onPressed: () {
                          // View participants
                        },
                      )
                    : null,
          ),
        );
      },
    );
  }
}
