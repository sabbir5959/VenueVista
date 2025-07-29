import 'package:flutter/material.dart';
import '../widgets/common_drawer.dart';
import 'payment_page.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  final List<Map<String, dynamic>> tournaments = [
    {
      'name': 'Dhaka Premier League',
      'image':
          'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?auto=format&fit=crop&w=800&q=80',
      'date': '2025-08-15',
      'time': '10:00 AM',
      'location': 'National Stadium, Dhaka',
      'prize': '৳50,000',
      'participants': '16 teams',
      'playerFormat': '11v11',
      'status': 'Registration Open',
      'description':
          'Annual premier football tournament featuring the best teams from Dhaka city.',
      'entryFee': '৳5,000',
      'organizer': 'Dhaka Football Association',
    },
    {
      'name': 'Inter-University Championship',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRP1pncn_KE2LWv7ekCregNYFhXid6ZFaVWeA&s',
      'date': '2025-09-01',
      'time': '2:00 PM',
      'location': 'University of Dhaka Ground',
      'prize': '৳30,000',
      'participants': '12 teams',
      'playerFormat': '7v7',
      'status': 'Registration Open',
      'description':
          'Prestigious university-level football competition bringing together the brightest talents.',
      'entryFee': '৳3,000',
      'organizer': 'Inter-University Sports Council',
    },
    {
      'name': 'Corporate Football League',
      'image':
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=800&q=80',
      'date': '2025-08-25',
      'time': '6:00 PM',
      'location': 'Gulshan Youth Club',
      'prize': '৳75,000',
      'participants': '20 teams',
      'playerFormat': '8v8',
      'status': 'Registration Closed',
      'description':
          'Professional corporate teams compete in this high-stakes tournament.',
      'entryFee': '৳8,000',
      'organizer': 'Corporate Sports Foundation',
    },
    {
      'name': 'Youth Development Cup',
      'image':
          'https://images.unsplash.com/photo-1606925797300-0b35e9d1794e?auto=format&fit=crop&w=800&q=80',
      'date': '2025-09-10',
      'time': '4:00 PM',
      'location': 'Mirpur Sports Complex',
      'prize': '৳25,000',
      'participants': '24 teams',
      'playerFormat': '6v6',
      'status': 'Registration Open',
      'description':
          'Nurturing young talent through competitive football at the grassroots level.',
      'entryFee': '৳2,000',
      'organizer': 'Youth Sports Development',
    },
    {
      'name': 'Weekend Warriors League',
      'image':
          'https://images.unsplash.com/photo-1579952363873-27d3bfad9c0d?auto=format&fit=crop&w=800&q=80',
      'date': '2025-08-30',
      'time': '8:00 AM',
      'location': 'Dhanmondi Lake Ground',
      'prize': '৳20,000',
      'participants': '8 teams',
      'playerFormat': '5v5',
      'status': 'Registration Open',
      'description':
          'Perfect tournament for weekend football enthusiasts and amateur players.',
      'entryFee': '৳1,500',
      'organizer': 'Weekend Sports Club',
    },
    {
      'name': 'Champions Trophy 2025',
      'image':
          'https://images.unsplash.com/photo-1522778119026-d647f0596c20?auto=format&fit=crop&w=800&q=80',
      'date': '2025-10-05',
      'time': '3:00 PM',
      'location': 'Bangabandhu National Stadium',
      'prize': '৳100,000',
      'participants': '32 teams',
      'playerFormat': '11v11',
      'status': 'Coming Soon',
      'description':
          'The ultimate football championship with the highest prize pool in the region.',
      'entryFee': '৳10,000',
      'organizer': 'Bangladesh Football Federation',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text(
          'Tournaments & Events',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Add search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search functionality coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const CommonDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upcoming Tournaments',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join exciting football tournaments and compete with the best teams',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tournaments list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tournaments.length,
              itemBuilder: (context, index) {
                final tournament = tournaments[index];
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tournament image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.network(
                            tournament['image'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey.shade300,
                                child: Icon(
                                  Icons.sports_soccer,
                                  size: 80,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          ),
                        ),

                        // Tournament details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tournament name and status
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      tournament['name'],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        tournament['status'],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      tournament['status'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Description
                              Text(
                                tournament['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Tournament info grid
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.calendar_today,
                                      'Date',
                                      tournament['date'],
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.access_time,
                                      'Time',
                                      tournament['time'],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.location_on,
                                      'Location',
                                      tournament['location'],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.emoji_events,
                                      'Prize',
                                      tournament['prize'],
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.groups,
                                      'Teams',
                                      tournament['participants'],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.sports_soccer,
                                      'Format',
                                      tournament['playerFormat'],
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.attach_money,
                                      'Entry Fee',
                                      tournament['entryFee'],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.payment,
                                      'Entry Fee',
                                      tournament['entryFee'],
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.business,
                                      'Organizer',
                                      tournament['organizer'],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Action buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                          tournament['status'] ==
                                                  'Registration Open'
                                              ? () {
                                                _showRegistrationDialog(
                                                  context,
                                                  tournament,
                                                );
                                              }
                                              : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        tournament['status'] ==
                                                'Registration Open'
                                            ? 'Register Now'
                                            : tournament['status'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton(
                                    onPressed: () {
                                      _showTournamentDetails(
                                        context,
                                        tournament,
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.green.shade700,
                                      side: BorderSide(
                                        color: Colors.green.shade700,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Details',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.green.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Registration Open':
        return Colors.green;
      case 'Registration Closed':
        return Colors.red;
      case 'Coming Soon':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showRegistrationDialog(
    BuildContext context,
    Map<String, dynamic> tournament,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Register for ${tournament['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Entry Fee: ${tournament['entryFee']}'),
              const SizedBox(height: 8),
              Text('Date: ${tournament['date']}'),
              const SizedBox(height: 8),
              Text('Location: ${tournament['location']}'),
              const SizedBox(height: 16),
              const Text(
                'You will be redirected to the payment page to complete your registration.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Proceed to Payment'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(tournament: tournament),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showTournamentDetails(
    BuildContext context,
    Map<String, dynamic> tournament,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tournament['name']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tournament['description'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text('📅 Date: ${tournament['date']}'),
                Text('🕐 Time: ${tournament['time']}'),
                Text('📍 Location: ${tournament['location']}'),
                Text('🏆 Prize: ${tournament['prize']}'),
                Text('👥 Teams: ${tournament['participants']}'),
                Text('⚽ Format: ${tournament['playerFormat']}'),
                Text('💰 Entry Fee: ${tournament['entryFee']}'),
                Text('🏢 Organizer: ${tournament['organizer']}'),
                Text('📊 Status: ${tournament['status']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
