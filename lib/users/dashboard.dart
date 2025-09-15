import 'package:flutter/material.dart';
import 'search_grounds.dart';
import 'widgets/common_drawer.dart';
import 'screens/tournaments_page.dart';
import 'screens/tournament_details.dart';
import 'ground_details.dart';
import '../services/venue_service.dart';
import '../services/tournament_service.dart';

class HomeActivity extends StatefulWidget {
  const HomeActivity({super.key});

  @override
  State<HomeActivity> createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  String? _selectedArea;
  List<String> _areas = [];
  int index = 0;

  // Dynamic data from backend
  List<Map<String, dynamic>> _featuredGrounds = [];
  List<Map<String, dynamic>> _featuredTournaments = [];
  bool _isLoadingVenues = true;
  bool _isLoadingTournaments = true;

  @override
  void initState() {
    super.initState();
    _loadFeaturedData();
  }

  // Load featured venues and tournaments from backend
  Future<void> _loadFeaturedData() async {
    setState(() {
      _isLoadingVenues = true;
      _isLoadingTournaments = true;
    });

    try {
      // Load venues
      final venues = await VenueService.getFeaturedVenues(limit: 10);
      if (venues.isEmpty) {
        final allVenues = await VenueService.getAllVenues();
        _featuredGrounds = allVenues.take(10).toList();
      } else {
        _featuredGrounds = venues;
      }

      // Extract unique areas from locations
      final areaSet = <String>{};
      for (var v in _featuredGrounds) {
        final loc = v['location']?.toString() ?? '';
        if (loc.contains(',')) {
          areaSet.add(loc.split(',')[0].trim());
        } else {
          areaSet.add(loc.trim());
        }
      }
      _areas = areaSet.toList()..sort();
      if (_areas.isNotEmpty && _selectedArea == null) {
        _selectedArea = _areas[0];
      }

      // Load tournaments
      final tournaments = await TournamentService.getFeaturedTournaments(
        limit: 5,
      );
      if (tournaments.isEmpty) {
        final upcomingTournaments =
            await TournamentService.getUpcomingTournaments(limit: 5);
        _featuredTournaments = upcomingTournaments;
      } else {
        _featuredTournaments = tournaments;
      }
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      // Keep fallback data if backend fails
      _loadFallbackData();
    } finally {
      setState(() {
        _isLoadingVenues = false;
        _isLoadingTournaments = false;
      });
    }
  }

  // Fallback data for offline scenarios
  void _loadFallbackData() {
    _loadFallbackVenues();
    _loadFallbackTournaments();
  }

  // Load fallback tournaments
  void _loadFallbackTournaments() {
    _featuredTournaments = [
      {
        'id': 'fallback_t1',
        'name': 'UCL Championship',
        'image_url':
            'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=400&q=80',
        'tournament_date': '2025-09-15',
        'start_time': '16:00:00',
        'venue_id': 'fallback_venue',
        'venues': {'name': 'Club Volta Arena', 'address': 'Uttara, Dhaka'},
        'first_prize': 50000,
        'max_teams': 32,
        'entry_fee': 5000,
        'registered_teams': 15,
        'description':
            'The ultimate club-level championship featuring the best teams.',
        'player_format': '11v11',
      },
    ];
  }

  // Fallback static data in case backend fails
  void _loadFallbackVenues() {
    _featuredGrounds = [
      {
        'id': 'fallback1',
        'name': 'Club Volta',
        'image_urls': [
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
        ],
        'location': 'Uttara',
        'description':
            'Multi-purpose sports facility with high-quality artificial turf.',
        'price_per_hour': 2200,
        'rating': 4.7,
        'facilities':
            'Training Equipment, Cafe, Changing Rooms, Floodlights, Parking',
        'ground_size': '90m x 45m',
      },
    ];
  }

  // Helper function to convert Map<String, dynamic> to Map<String, String>
  Map<String, String> _convertToStringMap(Map<String, dynamic> data) {
    String imageUrl = '';
    if (data['image_urls'] != null &&
        data['image_urls'] is List &&
        data['image_urls'].isNotEmpty) {
      imageUrl = data['image_urls'][0].toString();
    }

    return {
      'id': data['id']?.toString() ?? '', // Add venue ID
      'name': data['name']?.toString() ?? '',
      'image': imageUrl,
      'location': data['location']?.toString() ?? '',
      'description': data['description']?.toString() ?? '',
      'price': '৳${data['price_per_hour']?.toString() ?? '0'}/hour',
      'groundPayment': '${((data['price_per_hour'] ?? 0) * 0.2).toInt()}',
      'rating': data['rating']?.toString() ?? '0.0',
      'facilities': data['facilities']?.toString() ?? '',
      'size': data['ground_size']?.toString() ?? '',
      'area': data['area']?.toString() ?? '',
    };
  }

  // Helper function to convert tournament data to string map
  Map<String, String> _convertTournamentToStringMap(Map<String, dynamic> data) {
    String imageUrl = '';
    if (data['image_url'] != null && data['image_url'].toString().isNotEmpty) {
      imageUrl = data['image_url'].toString();
    }

    String formattedTime = '';
    if (data['start_time'] != null) {
      formattedTime = data['start_time'].toString();
    }

    // Get venue name from the joined venue data
    String venueName = 'Tournament Venue'; // Default fallback
    if (data['venues'] != null && data['venues'] is Map) {
      final venueData = data['venues'] as Map<String, dynamic>;
      venueName = venueData['name']?.toString() ?? 'Tournament Venue';
    }

    return {
      'id': data['id']?.toString() ?? '', // Add tournament ID
      'name': data['name']?.toString() ?? '',
      'image': imageUrl,
      'date': data['tournament_date']?.toString() ?? '',
      'time': formattedTime,
      'location': venueName,
      'prize': '৳${data['first_prize']?.toString() ?? '0'}',
      'participants': '${data['max_teams']?.toString() ?? '0'} teams',
      'playerFormat': data['player_format']?.toString() ?? '',
      'status':
          (data['registered_teams'] ?? 0) < (data['max_teams'] ?? 0)
              ? 'Registration Open'
              : 'Full',
      'description': data['description']?.toString() ?? '',
      'entryFee': '৳${data['entry_fee']?.toString() ?? '0'}',
      'organizer': venueName, // Use venue name as organizer
    };
  }

  void mySnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text('VenueVista', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: const CommonDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade700, Colors.green.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Image.network(
                    'https://static.vecteezy.com/system/resources/previews/012/141/976/non_2x/soccer-football-badge-logo-design-templates-vector.jpg',
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.3),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "OWN THE GROUND",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black45,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "UNLEASH YOUR FULL\nPOTENTIAL",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black54,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 28),

            // Grounds Section with SEE ALL button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "GROUNDS",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchGrounds(),
                        ),
                      );
                    },
                    child: Text("SEE ALL", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 170,
              child:
                  _isLoadingVenues
                      ? Center(
                        child: CircularProgressIndicator(color: Colors.green),
                      )
                      : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            _featuredGrounds.where((g) {
                              final loc = g['location']?.toString() ?? '';
                              String area =
                                  loc.contains(',')
                                      ? loc.split(',')[0].trim()
                                      : loc.trim();
                              return _selectedArea == null ||
                                  area == _selectedArea;
                            }).length,
                        itemBuilder: (context, index) {
                          final filteredGrounds =
                              _featuredGrounds.where((g) {
                                final loc = g['location']?.toString() ?? '';
                                String area =
                                    loc.contains(',')
                                        ? loc.split(',')[0].trim()
                                        : loc.trim();
                                return _selectedArea == null ||
                                    area == _selectedArea;
                              }).toList();
                          final ground = filteredGrounds[index];
                          final convertedGround = _convertToStringMap(ground);
                          return groundCard(
                            convertedGround['name']!,
                            convertedGround['image']!,
                            convertedGround,
                          );
                        },
                      ),
            ),

            SizedBox(height: 28),

            // Tournaments Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TOURNAMENTS",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TournamentsPage(),
                        ),
                      );
                    },
                    child: Text("SEE ALL", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            // Tournaments Section - now vertical scrollable
            _isLoadingTournaments
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children:
                      _featuredTournaments.map((tournament) {
                        final tournamentStringMap =
                            _convertTournamentToStringMap(tournament);
                        return newsCardFullWidth(
                          tournamentStringMap['name']!,
                          tournamentStringMap['image']!,
                          tournamentStringMap,
                        );
                      }).toList(),
                ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget groundCard(
    String title,
    String imageUrl,
    Map<String, String> groundData,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => GroundDetails(
                  venueId: groundData['id'], // Pass venue ID
                  name: groundData['name']!,
                  imageUrl: groundData['image']!,
                  location: groundData['location']!,
                  description: groundData['description']!,
                  price: groundData['price']!,
                  groundPayment: groundData['groundPayment']!,
                  rating: groundData['rating']!,
                  facilities: groundData['facilities']!,
                  size: groundData['size']!,
                  area: groundData['area']!,
                ),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: EdgeInsets.only(left: 20, right: 8, bottom: 8, top: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.green.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade200.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green.shade900,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget newsCard(
    String title,
    String imageUrl,
    Map<String, String> tournamentData,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => TournamentDetails(
                  id: tournamentData['id'], // Add tournament ID
                  name: tournamentData['name']!,
                  imageUrl: tournamentData['image']!,
                  date: tournamentData['date']!,
                  time: tournamentData['time']!,
                  location: tournamentData['location']!,
                  prize: tournamentData['prize']!,
                  participants: tournamentData['participants']!,
                  playerFormat: tournamentData['playerFormat']!,
                  status: tournamentData['status']!,
                  description: tournamentData['description']!,
                  entryFee: tournamentData['entryFee']!,
                  organizer: tournamentData['organizer']!,
                ),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: EdgeInsets.only(left: 20, right: 8, bottom: 8, top: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [Colors.red.shade100, Colors.red.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade200.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green.shade900,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // New full-width tournament card for vertical scrolling
  Widget newsCardFullWidth(
    String title,
    String imageUrl,
    Map<String, String> tournamentData,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => TournamentDetails(
                  id: tournamentData['id'], // Add tournament ID
                  name: tournamentData['name']!,
                  imageUrl: tournamentData['image']!,
                  date: tournamentData['date']!,
                  time: tournamentData['time']!,
                  location: tournamentData['location']!,
                  prize: tournamentData['prize']!,
                  participants: tournamentData['participants']!,
                  playerFormat: tournamentData['playerFormat']!,
                  status: tournamentData['status']!,
                  description: tournamentData['description']!,
                  entryFee: tournamentData['entryFee']!,
                  organizer: tournamentData['organizer']!,
                ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 160, // Increased height to prevent overflow
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 16, top: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.red.shade100, Colors.red.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade200.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tournament image
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: 120,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: double.infinity,
                    color: Colors.grey.shade300,
                    child: Icon(
                      Icons.sports_soccer,
                      color: Colors.grey.shade600,
                      size: 45,
                    ),
                  );
                },
              ),
            ),
            // Tournament details - now takes full remaining width
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0), // Reduced padding slightly
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceEvenly, // Changed to spaceEvenly for better distribution
                  children: [
                    // Title section
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16, // Reduced font size slightly
                        color: Colors.green.shade900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Details section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date row
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14, // Reduced icon size
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 6), // Reduced spacing
                            Expanded(
                              child: Text(
                                tournamentData['date'] ?? 'TBA',
                                style: TextStyle(
                                  fontSize: 13, // Reduced font size
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4), // Reduced spacing
                        // Location row
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14, // Reduced icon size
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 6), // Reduced spacing
                            Expanded(
                              child: Text(
                                tournamentData['location'] ?? 'TBA',
                                style: TextStyle(
                                  fontSize: 13, // Reduced font size
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4), // Reduced spacing
                        // Participants/Format row
                        if (tournamentData['playerFormat'] != null &&
                            tournamentData['playerFormat']!.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.group,
                                size: 14, // Reduced icon size
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 6), // Reduced spacing
                              Flexible(
                                // Changed to Flexible to prevent overflow
                                child: Text(
                                  tournamentData['playerFormat']!,
                                  style: TextStyle(
                                    fontSize: 13, // Reduced font size
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
