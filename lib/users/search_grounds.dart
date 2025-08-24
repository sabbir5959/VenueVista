import 'package:flutter/material.dart';
import 'ground_details.dart';
import 'widgets/common_drawer.dart';

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

  final List<String> locations = [
    'All Locations',
    'Mirpur',
    'Dhanmondi',
    'Gulshan',
    'Uttara',
    'Mohammadpur',
    'Pallabi',
  ];

  final List<String> playerCounts = ['Any', '5v5', '7v7', '11v11'];

  final List<Map<String, String>> grounds = [
    {
      'name': 'Club Volta',
      'image':
          'https://img.olympics.com/images/image/private/t_s_pog_staticContent_hero_lg_2x/f_auto/primary/sv4zhez2lyydydg8a4tb',
      'location': 'Mirpur',
      'description':
          'Premier indoor football facility with FIFA-approved turf and professional lighting. Perfect for 5v5 and 7v7 matches.',
      'price': '2000/hour',
      'groundPayment': '400',
      'rating': '4.8',
      'facilities':
          'Changing Rooms, Showers, Parking, Floodlights, Refreshments',
      'size': '40m x 20m',
    },
    {
      'name': 'Kings Arena',
      'image':
          'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?auto=format&fit=crop&w=400&q=80',
      'location': 'Dhanmondi',
      'description':
          'State-of-the-art outdoor football ground with natural grass. Ideal for full-size matches and training sessions.',
      'price': '2500/hour',
      'groundPayment': '600',
      'rating': '4.9',
      'facilities':
          'Locker Rooms, Cafe, First Aid, Training Equipment, Spectator Seating',
      'size': '100m x 64m',
    },
    {
      'name': 'Dbox',
      'image':
          'https://imgresizer.tntsports.io/unsafe/2560x1440/filters:format(jpeg)/origin-imgresizer.tntsports.io/2025/03/11/image-2c33751b-72bd-4b98-9cc2-8873bbd18247-85-2560-1440.jpeg',
      'location': 'Gulshan',
      'description':
          'Professional stadium with international standard facilities. Hosts major tournaments and events.',
      'price': '3000/hour',
      'groundPayment': '750',
      'rating': '4.9',
      'facilities':
          'VIP Lounge, Media Room, Professional Lighting, Medical Center, Premium Seating',
      'size': '105m x 68m',
    },
    {
      'name': 'Volta',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4TANOHp0yLFOUYKQWhbk_segU6KLW6WjGlg&s',
      'location': 'Uttara',
      'description':
          'Multi-purpose sports facility with high-quality artificial turf. Suitable for both training and matches.',
      'price': '2200/hour',
      'groundPayment': '500',
      'rating': '4.7',
      'facilities':
          'Training Equipment, Cafe, Changing Rooms, Floodlights, Parking',
      'size': '90m x 45m',
    },
    {
      'name': 'Soccer',
      'image':
          'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?auto=format&fit=crop&w=400&q=80',
      'location': 'Mirpur',
      'description':
          'Indoor 5-a-side facility with climate control. Perfect for small group games and practice.',
      'price': '1800/hour',
      'groundPayment': '350',
      'rating': '4.6',
      'facilities':
          'Air Conditioning, Lockers, Shop, First Aid, Water Dispensers',
      'size': '30m x 15m',
    },
    {
      'name': 'Masters',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4TANOHp0yLFOUYKQWhbk_segU6KLW6WjGlg&s',
      'location': 'Mohammadpur',
      'description':
          'Community sports complex with multiple fields. Great for tournaments and events.',
      'price': '2400/hour',
      'groundPayment': '550',
      'rating': '4.8',
      'facilities':
          'Multiple Fields, Event Space, Cafeteria, Training Areas, Security',
      'size': '95m x 50m',
    },
    {
      'name': 'GreenTurf',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSgznYPPwkW9y1Lt2iSL_4QjEZGZLmHddtI0bSoKiq_EcFq5oBGjRjj9w0PF8I4rJwZ1fY&usqp=CAU',
      'location': 'Dhanmondi',
      'description':
          'Eco-friendly facility with natural grass. Includes professional coaching services.',
      'price': '2300/hour',
      'groundPayment': '520',
      'rating': '4.7',
      'facilities':
          'Professional Coaching, Equipment Rental, Gym, Refreshments, Analysis Room',
      'size': '100m x 64m',
    },
    {
      'name': 'Kings Valley',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBgJlu4IYS6mZEEyLToTSTSUd8DY5Yj0mCNW95wQe-VZUNe7QiOyA_nqrEFzkKWX71tyw&usqp=CAU',
      'location': 'Gulshan',
      'description':
          'Premium sports facility with hybrid grass technology. Hosts professional matches.',
      'price': '2800/hour',
      'groundPayment': '650',
      'rating': '4.9',
      'facilities':
          'Premium Grass, Professional Setup, VIP Area, Video Analysis, Recovery Zone',
      'size': '105m x 68m',
    },
    {
      'name': 'SportsHub',
      'image':
          'https://images.unsplash.com/photo-1556056504-5c7696c4c28d?auto=format&fit=crop&w=400&q=80',
      'location': 'Uttara',
      'description':
          'Modern sports complex with latest amenities. Suitable for all skill levels.',
      'price': '2100/hour',
      'groundPayment': '450',
      'rating': '4.6',
      'facilities':
          'Modern Equipment, Training Programs, Cafe, Shop, Physio Room',
      'size': '85m x 45m',
    },
    {
      'name': 'GStation',
      'image':
          'https://images.unsplash.com/photo-1517466787929-bc90951d0974?auto=format&fit=crop&w=400&q=80',
      'location': 'Mohammadpur',
      'description':
          'Versatile football facility with multiple pitch sizes. Perfect for various game formats.',
      'price': '2000/hour',
      'groundPayment': '400',
      'rating': '4.7',
      'facilities':
          'Multiple Pitches, Training Zones, Changing Rooms, Floodlights, Parking',
      'size': '80m x 40m',
    },
  ];

  List<Map<String, String>> get filteredGrounds {
    return grounds.where((ground) {
      bool locationMatch =
          selectedLocation == 'All Locations' ||
          ground['location'] == selectedLocation;
      return locationMatch;
    }).toList();
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
              itemCount: filteredGrounds.length,
              itemBuilder: (context, index) {
                final ground = filteredGrounds[index];
                return _GroundCard(
                  title: ground['name']!,
                  imageUrl: ground['image']!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => GroundDetails(
                              name: ground['name']!,
                              imageUrl: ground['image']!,
                              location: ground['location']!,
                              description: ground['description']!,
                              price: ground['price']!,
                              groundPayment: ground['groundPayment']!,
                              rating: ground['rating']!,
                              facilities: ground['facilities']!,
                              size: ground['size']!,
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
