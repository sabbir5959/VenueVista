import 'package:flutter/material.dart';
import '../widgets/common_drawer.dart';
import 'payment_page.dart';
import '../../services/tournament_service.dart';
import '../../services/supabase_config.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  List<Map<String, dynamic>> tournaments = [];
  List<Map<String, dynamic>> filteredTournaments = [];
  Map<String, bool> userRegistrations = {}; // Track user's registrations
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUpcomingTournaments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh tournaments when returning to this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUpcomingTournaments();
    });
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
        filteredTournaments = upcomingTournaments; // Initialize filtered list
      });

      // Load user registration status for each tournament
      await _loadUserRegistrationStatus();

      setState(() {
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

  Future<void> _loadUserRegistrationStatus() async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId != null) {
        Map<String, bool> registrations = {};

        for (var tournament in tournaments) {
          final tournamentId = tournament['id']?.toString();
          if (tournamentId != null) {
            print('🔍 Checking registration for tournament ID: $tournamentId');
            print('🔍 Tournament name: ${tournament['name']}');

            final hasRegistered = await TournamentService.hasUserRegistered(
              tournamentId,
              userId,
            );

            print(
              '✅ Registration status for ${tournament['name']}: $hasRegistered',
            );
            registrations[tournamentId] = hasRegistered;
          }
        }

        setState(() {
          userRegistrations = registrations;
        });

        print(
          '✅ User registration status loaded for ${registrations.length} tournaments',
        );
        print('🔍 Registration map: $registrations');
      }
    } catch (e) {
      print('❌ Error loading user registration status: $e');
    }
  }

  void _filterTournaments(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();

      if (_searchQuery.isEmpty) {
        filteredTournaments = tournaments;
      } else {
        filteredTournaments =
            tournaments.where((tournament) {
              final name = tournament['name']?.toString().toLowerCase() ?? '';
              final date = tournament['tournament_date']?.toString() ?? '';

              // Search by name or date
              return name.contains(_searchQuery) ||
                  date.contains(_searchQuery) ||
                  _formatDateForSearch(date).contains(_searchQuery);
            }).toList();
      }
    });
  }

  String _formatDateForSearch(String date) {
    try {
      if (date.isEmpty) return '';

      // Parse the date and format it in different ways for better searchability
      final DateTime parsedDate = DateTime.parse(date);
      final List<String> formats = [
        '${parsedDate.day}',
        '${parsedDate.month}',
        '${parsedDate.year}',
        '${parsedDate.day}-${parsedDate.month}',
        '${parsedDate.day}/${parsedDate.month}',
        '${parsedDate.month}-${parsedDate.year}',
        '${parsedDate.month}/${parsedDate.year}',
      ];

      return formats.join(' ').toLowerCase();
    } catch (e) {
      return date.toLowerCase();
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

    // Get venue data from the joined venue data
    String venueName = 'Tournament Venue'; // Default fallback
    String venueLocation = 'Tournament Location'; // Default fallback
    if (data['venues'] != null && data['venues'] is Map) {
      final venueData = data['venues'] as Map<String, dynamic>;
      venueName = venueData['name']?.toString() ?? 'Tournament Venue';

      // Get the actual venue address for location
      final address = venueData['address']?.toString() ?? '';
      final city = venueData['city']?.toString() ?? '';

      if (address.isNotEmpty && city.isNotEmpty) {
        venueLocation = '$address, $city';
      } else if (address.isNotEmpty) {
        venueLocation = address;
      } else if (city.isNotEmpty) {
        venueLocation = city;
      } else {
        venueLocation = venueName; // Fallback to venue name if no address
      }
    }

    return {
      'id': data['id']?.toString() ?? '', // Preserve the tournament ID
      'name': data['name']?.toString() ?? 'Tournament',
      'image': imageUrl,
      'date': data['tournament_date']?.toString() ?? '',
      'time': formattedTime,
      'location': venueLocation, // Use venue address as location
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
      'organizer': venueName, // Use venue name as organizer
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

            // Search Bar
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterTournaments,
                decoration: InputDecoration(
                  hintText:
                      'Search tournaments by name or date (e.g., "Football", "2025-09-15", "15")...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _filterTournaments('');
                            },
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),

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
            else if (filteredTournaments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No tournaments found for "${_searchController.text}"',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try searching with different keywords',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Results Header
                  if (_searchController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Found ${filteredTournaments.length} tournament${filteredTournaments.length == 1 ? '' : 's'} for "${_searchController.text}"',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Tournaments list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTournaments.length,
                    itemBuilder: (context, index) {
                      final tournamentData = filteredTournaments[index];
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
                                              loadingProgress
                                                          .expectedTotalBytes !=
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                                            onPressed: _getButtonAction(
                                              tournament,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _getButtonColor(
                                                tournament,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              _getButtonText(tournament),
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
                                            foregroundColor:
                                                Colors.green.shade700,
                                            side: BorderSide(
                                              color: Colors.green.shade700,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 20,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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

  // Get button action based on registration status
  VoidCallback? _getButtonAction(Map<String, dynamic> tournament) {
    final tournamentId = tournament['id'];
    final isRegistered = userRegistrations[tournamentId] ?? false;
    final status = tournament['status'] ?? '';

    if (isRegistered) {
      return null; // Disabled for already registered
    } else if (status == 'Registration Open') {
      return () {
        _showRegistrationDialog(context, tournament);
      };
    } else {
      return null; // Disabled for other statuses
    }
  }

  // Get button text based on registration status
  String _getButtonText(Map<String, dynamic> tournament) {
    final tournamentId = tournament['id'];
    final isRegistered = userRegistrations[tournamentId] ?? false;
    final status = tournament['status'] ?? '';

    if (isRegistered) {
      return 'Already Registered';
    } else if (status == 'Registration Open') {
      return 'Register Now';
    } else {
      return status;
    }
  }

  // Get button color based on registration status
  Color _getButtonColor(Map<String, dynamic> tournament) {
    final tournamentId = tournament['id'];
    final isRegistered = userRegistrations[tournamentId] ?? false;
    final status = tournament['status'] ?? '';

    if (isRegistered) {
      return Colors.blue.shade600; // Different color for registered
    } else if (status == 'Registration Open') {
      return Colors.green.shade700;
    } else {
      return Colors.grey.shade500;
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
                ).then((result) {
                  // Refresh tournaments after returning from payment
                  if (result == true) {
                    _loadUpcomingTournaments();
                  }
                });
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
    final tournamentId = tournament['id'];
    final isRegistered = userRegistrations[tournamentId] ?? false;
    final status = tournament['status'] ?? '';

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

                // Registration Status
                if (isRegistered) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'You are already registered for this tournament',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
            // Show register button only if not already registered and registration is open
            if (!isRegistered && status == 'Registration Open')
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Register Now'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close details dialog
                  _showRegistrationDialog(context, tournament);
                },
              )
            else if (isRegistered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Already Registered'),
                onPressed: null, // Disabled
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade500,
                  foregroundColor: Colors.white,
                ),
                child: Text(status),
                onPressed: null, // Disabled
              ),
          ],
        );
      },
    );
  }
}
