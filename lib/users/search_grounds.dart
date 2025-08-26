import 'package:flutter/material.dart';
import 'ground_details.dart';
import 'widgets/common_drawer.dart';
import '../services/venue_service.dart';

class SearchGrounds extends StatefulWidget {
  const SearchGrounds({super.key});

  @override
  State<SearchGrounds> createState() => _SearchGroundsState();
}

class _SearchGroundsState extends State<SearchGrounds> {
  String selectedLocation = 'All Locations';
  String selectedPlayers = 'Any';
  DateTime selectedDate = DateTime.now();
  final String locationLabel = "Location";
  final String pvpLabel = "PVP (Players)";

  // Dynamic data from backend
  List<Map<String, dynamic>> allVenues = [];
  List<Map<String, dynamic>> filteredVenues = [];
  bool isLoadingVenues = true;

  @override
  void initState() {
    super.initState();
    _loadAllVenues();
  }

  // Load all venues from backend
  Future<void> _loadAllVenues() async {
    setState(() {
      isLoadingVenues = true;
    });

    try {
      final venues = await VenueService.getAllVenues();
      if (venues.isNotEmpty) {
        allVenues = venues;
        filteredVenues = venues;

        // Extract unique locations from venues
        final venueLocations =
            venues
                .map((venue) => venue['location']?.toString() ?? '')
                .where((location) => location.isNotEmpty)
                .toSet()
                .toList();

        // Update locations list with actual venue locations
        _updateLocationsList(venueLocations);

        print('✅ All venues loaded: ${venues.length}');
      } else {
        // Fallback to static data if no venues from backend
        _loadFallbackVenues();
      }
    } catch (e) {
      print('❌ Error loading venues: $e');
      _loadFallbackVenues();
    } finally {
      setState(() {
        isLoadingVenues = false;
      });
    }
  }

  // Update locations list with real venue locations
  void _updateLocationsList(List<String> venueLocations) {
    final defaultLocations = [
      'All Locations',
      'Mirpur',
      'Dhanmondi',
      'Gulshan',
      'Uttara',
      'Mohammadpur',
      'Pallabi',
    ];

    // Combine default locations with actual venue locations
    final allLocationSet = {...defaultLocations, ...venueLocations};
    locations = allLocationSet.toList();
  }

  // Fallback static venues data
  void _loadFallbackVenues() {
    allVenues = [
      {
        'id': 'fallback1',
        'name': 'Club Volta',
        'image_url':
            'https://img.olympics.com/images/image/private/t_s_pog_staticContent_hero_lg_2x/f_auto/primary/sv4zhez2lyydydg8a4tb',
        'location': 'Mirpur',
        'description':
            'Premier indoor football facility with FIFA-approved turf and professional lighting.',
        'price_per_hour': 2000,
        'rating': 4.8,
        'facilities':
            'Changing Rooms, Showers, Parking, Floodlights, Refreshments',
        'ground_size': '40m x 20m',
        'sport_type': 'Football',
      },
      {
        'id': 'fallback2',
        'name': 'Kings Arena',
        'image_url':
            'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?auto=format&fit=crop&w=400&q=80',
        'location': 'Dhanmondi',
        'description':
            'State-of-the-art outdoor football ground with natural grass.',
        'price_per_hour': 2500,
        'rating': 4.9,
        'facilities':
            'Locker Rooms, Cafe, First Aid, Training Equipment, Spectator Seating',
        'ground_size': '100m x 64m',
        'sport_type': 'Football',
      },
      {
        'id': 'fallback3',
        'name': 'Dbox Stadium',
        'image_url':
            'https://imgresizer.tntsports.io/unsafe/2560x1440/filters:format(jpeg)/origin-imgresizer.tntsports.io/2025/03/11/image-2c33751b-72bd-4b98-9cc2-8873bbd18247-85-2560-1440.jpeg',
        'location': 'Gulshan',
        'description':
            'Professional stadium with international standard facilities.',
        'price_per_hour': 3000,
        'rating': 4.9,
        'facilities':
            'VIP Lounge, Media Room, Professional Lighting, Medical Center, Premium Seating',
        'ground_size': '105m x 68m',
        'sport_type': 'Football',
      },
      {
        'id': 'fallback4',
        'name': 'Volta Sports',
        'image_url':
            'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=400&q=80',
        'location': 'Uttara',
        'description': 'Multi-purpose sports facility with artificial turf.',
        'price_per_hour': 2200,
        'rating': 4.7,
        'facilities': 'Training Equipment, Cafe, Changing Rooms, Floodlights',
        'ground_size': '90m x 45m',
        'sport_type': 'Football',
      },
      {
        'id': 'fallback5',
        'name': 'Green Field',
        'image_url':
            'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?auto=format&fit=crop&w=400&q=80',
        'location': 'Mohammadpur',
        'description': 'Indoor 5-a-side facility with climate control.',
        'price_per_hour': 1800,
        'rating': 4.6,
        'facilities': 'Air Conditioning, Lockers, Shop, First Aid',
        'ground_size': '30m x 15m',
        'sport_type': 'Football',
      },
    ];
    filteredVenues = allVenues;
  }

  List<String> locations = [
    'All Locations',
    'Mirpur',
    'Dhanmondi',
    'Gulshan',
    'Uttara',
    'Mohammadpur',
    'Pallabi',
  ];

  final List<String> playerCounts = ['Any', '5v5', '7v7', '11v11'];

  // Apply filters to venues
  void _applyFilters() {
    setState(() {
      filteredVenues =
          allVenues.where((venue) {
            bool locationMatch =
                selectedLocation == 'All Locations' ||
                venue['location']?.toString().toLowerCase() ==
                    selectedLocation.toLowerCase();

            // Player count filtering based on ground size or sport type
            bool playerMatch = selectedPlayers == 'Any';
            if (!playerMatch) {
              String sportType =
                  venue['sport_type']?.toString().toLowerCase() ?? 'football';
              String groundSize =
                  venue['ground_size']?.toString().toLowerCase() ?? '';

              if (selectedPlayers == '5v5') {
                playerMatch =
                    sportType.contains('5v5') ||
                    groundSize.contains('small') ||
                    groundSize.contains('30m');
              } else if (selectedPlayers == '7v7') {
                playerMatch =
                    sportType.contains('7v7') ||
                    groundSize.contains('medium') ||
                    groundSize.contains('40m');
              } else if (selectedPlayers == '11v11') {
                playerMatch =
                    sportType.contains('11v11') ||
                    groundSize.contains('full') ||
                    groundSize.contains('100m');
              }
            }

            return locationMatch && playerMatch;
          }).toList();
    });
  }

  // Convert dynamic venue data to string map for compatibility
  Map<String, String> _convertVenueToStringMap(Map<String, dynamic> venue) {
    // Debug: Print detailed venue data
    print('🔍 Converting venue data: ${venue['name']}');
    print('   - image_url field: ${venue['image_url']}');
    print('   - image_urls field: ${venue['image_urls']}');

    // Get image from image_urls array (your table uses this field)
    String imageUrl = '';
    if (venue['image_urls'] != null &&
        venue['image_urls'] is List &&
        venue['image_urls'].isNotEmpty) {
      imageUrl = venue['image_urls'][0].toString();
      print('   ✅ Found image from image_urls array: $imageUrl');
    } else if (venue['image_url'] != null &&
        venue['image_url'].toString().trim().isNotEmpty) {
      imageUrl = venue['image_url'].toString();
      print('   ✅ Found image from image_url field: $imageUrl');
    } else {
      print('   ⚠️ No image found in either field');
    }

    return {
      'id': venue['id']?.toString() ?? '', // Add venue ID
      'name': venue['name']?.toString() ?? '',
      'image': imageUrl, // Empty string if no image in table
      'location': venue['location']?.toString() ?? '',
      'description': venue['description']?.toString() ?? '',
      'price': '৳${venue['price_per_hour']?.toString() ?? '0'}/hour',
      'groundPayment': '${((venue['price_per_hour'] ?? 0) * 0.2).toInt()}',
      'rating': venue['rating']?.toString() ?? '0.0',
      'facilities': venue['facilities']?.toString() ?? '',
      'size': venue['ground_size']?.toString() ?? '',
    };
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade900,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.green.shade900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      drawer: const CommonDrawer(),
      appBar: AppBar(
        title: Text(
          'Search Grounds',
          style: TextStyle(
            color: Colors.green.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green.shade900),
      ),
      body: Column(
        children: [
          // Search Filters
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 4),
                            child: Text(
                              locationLabel,
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: selectedLocation,
                              isExpanded: true,
                              underline: SizedBox(),
                              icon: Icon(
                                Icons.location_on,
                                color: Colors.green.shade900,
                              ),
                              items:
                                  locations.map((String location) {
                                    return DropdownMenuItem<String>(
                                      value: location,
                                      child: Text(location),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedLocation = newValue!;
                                });
                                _applyFilters();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 4),
                            child: Text(
                              pvpLabel,
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: selectedPlayers,
                              isExpanded: true,
                              underline: SizedBox(),
                              icon: Icon(
                                Icons.group,
                                color: Colors.green.shade900,
                              ),
                              items:
                                  playerCounts.map((String count) {
                                    return DropdownMenuItem<String>(
                                      value: count,
                                      child: Text(count),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedPlayers = newValue!;
                                });
                                _applyFilters();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green.shade900,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today,
                          color: Colors.green.shade900,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grounds Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: isLoadingVenues ? 6 : filteredVenues.length,
              itemBuilder: (context, index) {
                if (isLoadingVenues) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    ),
                  );
                }

                final venue = filteredVenues[index];
                final groundData = _convertVenueToStringMap(venue);
                return _GroundCard(
                  title: groundData['name']!,
                  imageUrl: groundData['image']!,
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
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroundCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _GroundCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<_GroundCard> createState() => _GroundCardState();
}

class _GroundCardState extends State<_GroundCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.05 : 1.0,
        duration: Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    widget.title,
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
        ),
      ),
    );
  }
}
