import 'package:flutter/material.dart';
import '../widgets/common_drawer.dart';
import 'payment_page.dart';
import '../../services/tournament_service.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  List<Map<String, dynamic>> tournaments = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUpcomingTournaments();
  }

  Future<void> _loadUpcomingTournaments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🏆 TournamentsPage: Loading upcoming tournaments...');
      final upcomingTournaments =
          await TournamentService.getUpcomingTournaments(
            limit: 50, // Get up to 50 upcoming tournaments
          );

      setState(() {
        tournaments = upcomingTournaments;
        _isLoading = false;
      });

      print(
        '✅ TournamentsPage: Loaded ${tournaments.length} upcoming tournaments',
      );
    } catch (e) {
      print('❌ TournamentsPage: Error loading tournaments: $e');
      setState(() {
        _errorMessage = 'Failed to load tournaments. Please try again.';
        _isLoading = false;
      });
    }
  }

  // Helper function to convert tournament data to display format
  Map<String, String> _convertTournamentToDisplayMap(
    Map<String, dynamic> data,
  ) {
    String imageUrl = '';
    if (data['image_url'] != null && data['image_url'].toString().isNotEmpty) {
      imageUrl = data['image_url'].toString();
    } else {
      // Multiple fallback images for variety
      final fallbackImages = [
        'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1459865264687-595d652de67e?auto=format&fit=crop&w=800&q=80',
      ];
      // Use hash of tournament name to consistently pick same image
      final hash = data['name']?.toString().hashCode ?? 0;
      imageUrl = fallbackImages[hash.abs() % fallbackImages.length];
    }

    String formattedTime = '';
    if (data['start_time'] != null) {
      formattedTime = data['start_time'].toString();
    }

    return {
      'id': data['id']?.toString() ?? '', // Preserve the tournament ID
      'name': data['name']?.toString() ?? 'Tournament',
      'image': imageUrl,
      'date': data['tournament_date']?.toString() ?? '',
      'time': formattedTime,
      'location': 'Tournament Venue', // Can be enhanced with venue join
      'prize': '৳${data['first_prize']?.toString() ?? '0'}',
      'participants': '${data['max_teams']?.toString() ?? '0'} teams',
      'playerFormat': data['player_format']?.toString() ?? '',
      'status':
          (data['registered_teams'] ?? 0) < (data['max_teams'] ?? 0)
              ? 'Registration Open'
              : 'Full',
      'description':
          data['description']?.toString() ?? 'Tournament details coming soon.',
      'entryFee': '৳${data['entry_fee']?.toString() ?? '0'}',
      'organizer': 'Tournament Organizer',
    };
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

            // Loading, Error, or Tournaments list
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUpcomingTournaments,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (tournaments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No tournaments available at the moment.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              // Tournaments list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tournaments.length,
                itemBuilder: (context, index) {
                  final tournamentData = tournaments[index];
                  final tournament = _convertTournamentToDisplayMap(
                    tournamentData,
                  );
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
                              tournament['image'] ?? '',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.green,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ Image load error: $error');
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.green.shade300,
                                        Colors.green.shade600,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.emoji_events,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Tournament',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
                                        tournament['name'] ?? 'Tournament',
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
                                          tournament['status'] ?? 'Unknown',
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        tournament['status'] ?? 'Unknown',
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
                                  tournament['description'] ??
                                      'No description available',
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
                                        tournament['date'] ?? '',
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildInfoItem(
                                        Icons.access_time,
                                        'Time',
                                        tournament['time'] ?? '',
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
                                        tournament['location'] ?? '',
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
                                        tournament['prize'] ?? '',
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildInfoItem(
                                        Icons.groups,
                                        'Teams',
                                        tournament['participants'] ?? '',
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
                                        tournament['playerFormat'] ?? '',
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildInfoItem(
                                        Icons.attach_money,
                                        'Entry Fee',
                                        tournament['entryFee'] ?? '',
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
                                        tournament['entryFee'] ?? '',
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildInfoItem(
                                        Icons.business,
                                        'Organizer',
                                        tournament['organizer'] ?? '',
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
                                            (tournament['status'] ?? '') ==
                                                    'Registration Open'
                                                ? () {
                                                  _showRegistrationDialog(
                                                    context,
                                                    tournament,
                                                  );
                                                }
                                                : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.green.shade700,
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
                                          (tournament['status'] ?? '') ==
                                                  'Registration Open'
                                              ? 'Register Now'
                                              : tournament['status'] ??
                                                  'Unknown',
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
