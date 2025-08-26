import 'package:flutter/material.dart';
import 'dart:convert';
import '../widgets/common_drawer.dart';
import 'payment_page.dart';
import '../../owners/services/tournament_service.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  List<Map<String, dynamic>> tournaments = [];
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

      final fetchedTournaments =
          await OwnerTournamentService.getAllTournamentsForUsers();

      setState(() {
        tournaments = fetchedTournaments.isNotEmpty
            ? _convertTournamentFormat(fetchedTournaments)
            : _getFallbackTournaments();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        tournaments = _getFallbackTournaments();
      });
    }
  }

  List<Map<String, dynamic>> _convertTournamentFormat(List<Map<String, dynamic>> dbTournaments) {
    return dbTournaments.map((tournament) {
      // Convert 24-hour time to 12-hour format
      String formattedTime = '10:00 AM';
      if (tournament['start_time'] != null) {
        try {
          final timeString = tournament['start_time'].toString();
          final timeParts = timeString.split(':');
          if (timeParts.length >= 2) {
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            
            final period = hour >= 12 ? 'PM' : 'AM';
            final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
            formattedTime = '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
          }
        } catch (e) {
          print('Error formatting time: $e');
        }
      }

      return {
        'name': tournament['name'] ?? 'Unnamed Tournament',
        'image': tournament['image_url'],
        'date': tournament['tournament_date'] ?? '2025-08-15',
        'time': formattedTime,
        'prize': '৳${tournament['first_prize'] ?? 0}',
        'participants': '${tournament['registered_teams'] ?? 0}/${tournament['max_teams'] ?? 0} teams',
        'playerFormat': tournament['player_format'] ?? '11v11',
        'status': tournament['status'] ?? 'Registration Open',
        'description': tournament['description'] ?? 'Tournament description not available.',
        'entryFee': '৳${tournament['entry_fee'] ?? 0}',
      };
    }).toList();
  }

  List<Map<String, dynamic>> _getFallbackTournaments() {
    return [
      {
        'name': 'Dhaka Premier League',
        'image':
            'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?auto=format&fit=crop&w=800&q=80',
        'date': '2025-08-15',
        'time': '10:00 AM',
        'prize': '৳50,000',
        'participants': '8/16 teams',
        'playerFormat': '11v11',
        'status': 'Registration Open',
        'description':
            'Annual premier football tournament featuring the best teams from Dhaka city.',
        'entryFee': '৳5,000',
      },
      {
        'name': 'Inter-University Championship',
        'image':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRP1pncn_KE2LWv7ekCregNYFhXid6ZFaVWeA&s',
        'date': '2025-09-01',
        'time': '2:00 PM',
        'prize': '৳30,000',
        'participants': '6/12 teams',
        'playerFormat': '7v7',
        'status': 'Registration Open',
        'description':
            'Prestigious university-level football competition bringing together the brightest talents.',
        'entryFee': '৳3,000',
      },
      {
        'name': 'Corporate Football League',
        'image':
            'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=800&q=80',
        'date': '2025-08-25',
        'time': '6:00 PM',
        'prize': '৳75,000',
        'participants': '20/20 teams',
        'playerFormat': '8v8',
        'status': 'Registration Closed',
        'description':
            'Professional corporate teams compete in this high-stakes tournament.',
        'entryFee': '৳8,000',
      },
      {
        'name': 'Youth Development Cup',
        'image':
            'https://images.unsplash.com/photo-1606925797300-0b35e9d1794e?auto=format&fit=crop&w=800&q=80',
        'date': '2025-09-10',
        'time': '4:00 PM',
        'prize': '৳25,000',
        'participants': '12/24 teams',
        'playerFormat': '6v6',
        'status': 'Registration Open',
        'description':
            'Nurturing young talent through competitive football at the grassroots level.',
        'entryFee': '৳2,000',
      },
      {
        'name': 'Weekend Warriors League',
        'image':
            'https://images.unsplash.com/photo-1522778119026-d647f0596c20?auto=format&fit=crop&w=800&q=80',
        'date': '2025-08-30',
        'time': '8:00 AM',
        'prize': '৳20,000',
        'participants': '4/8 teams',
        'playerFormat': '5v5',
        'status': 'Registration Open',
        'description':
            'Perfect tournament for weekend football enthusiasts and amateur players.',
        'entryFee': '৳1,500',
      },
      {
        'name': 'Champions Trophy 2025',
        'image':
            'https://images.unsplash.com/photo-1522778119026-d647f0596c20?auto=format&fit=crop&w=800&q=80',
        'date': '2025-10-05',
        'time': '3:00 PM',
        'prize': '৳100,000',
        'participants': '0/32 teams',
        'playerFormat': '11v11',
        'status': 'Coming Soon',
        'description':
            'The ultimate football championship with the highest prize pool in the region.',
        'entryFee': '৳10,000',
      },
    ];
  }

  Widget _buildTournamentImage(String? imageUrl) {
    if (imageUrl == null) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Icon(Icons.sports_soccer, size: 80, color: Colors.grey),
      );
    }

    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
        );
      } catch (_) {
        return Image.network(
          'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?auto=format&fit=crop&w=800&q=80',
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
        );
      }
    } else {
      return Image.network(
        imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.sports_soccer, size: 80, color: Colors.grey),
          );
        },
      );
    }
  }

  Color _getStatusColor(String? status) {
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
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
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
                Text('🏆 Prize: ${tournament['prize']}'),
                Text('👥 Teams: ${tournament['participants']}'),
                Text('⚽ Format: ${tournament['playerFormat']}'),
                Text('💰 Entry Fee: ${tournament['entryFee']}'),
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTournaments,
          ),
        ],
      ),
      drawer: const CommonDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
            )
          : tournaments.isEmpty
              ? const Center(child: Text('No tournaments available'))
              : RefreshIndicator(
                  onRefresh: _loadTournaments,
                  child: SingleChildScrollView(
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
                                      child: _buildTournamentImage(tournament['image']),
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
                ),
    );
  }
}
