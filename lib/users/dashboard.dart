import 'package:flutter/material.dart';
import 'search_grounds.dart';
import 'widgets/common_drawer.dart';
import 'screens/tournaments_page.dart';
import 'screens/tournament_details.dart';
import 'ground_details.dart';

class HomeActivity extends StatefulWidget {
  const HomeActivity({super.key});

  @override
  State<HomeActivity> createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  int index = 0;

  // Ground data similar to search_grounds.dart
  final List<Map<String, String>> _featuredGrounds = [
    {
      'name': 'Club Volta',
      'image':
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
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
      'name': 'Kings Arena',
      'image':
          'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=400&q=80',
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
      'name': 'Dbox Stadium',
      'image':
          'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
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
  ];

  // Tournament data for featured tournaments
  final List<Map<String, String>> _featuredTournaments = [
    {
      'name': 'UCL',
      'image':
          'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=400&q=80',
      'date': '2025-09-15',
      'time': '4:00 PM',
      'location': 'Bangabandhu National Stadium',
      'prize': '৳50,000',
      'participants': '32 teams',
      'playerFormat': '11v11',
      'status': 'Registration Open',
      'description':
          'The ultimate club-level championship featuring the best teams from across the region. A prestigious tournament with professional standards.',
      'entryFee': '৳5,000',
      'organizer': 'Bangladesh Football Federation',
    },
    {
      'name': 'Premier League',
      'image':
          'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
      'date': '2025-08-25',
      'time': '2:00 PM',
      'location': 'Dhanmondi Football Ground',
      'prize': '৳30,000',
      'participants': '16 teams',
      'playerFormat': '7v7',
      'status': 'Registration Open',
      'description':
          'Local premier league tournament for amateur and semi-professional teams. Great opportunity to showcase talent.',
      'entryFee': '৳3,000',
      'organizer': 'Dhaka Sports Association',
    },
    {
      'name': 'Copa America',
      'image':
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      'date': '2025-10-10',
      'time': '6:00 PM',
      'location': 'Sher-e-Bangla Stadium',
      'prize': '৳25,000',
      'participants': '12 teams',
      'playerFormat': '5v5',
      'status': 'Registration Open',
      'description':
          'Fast-paced 5v5 tournament inspired by Copa America format. Perfect for skilled small teams.',
      'entryFee': '৳2,000',
      'organizer': 'Copa Bangladesh',
    },
  ];

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
                      AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 500),
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
                        child: Text("OWN THE GROUND"),
                      ),
                      SizedBox(height: 8),
                      AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 500),
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
                        child: Text("UNLEASH YOUR FULL\nPOTENTIAL"),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 28),

            // Choose Grounds
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _featuredGrounds.length,
                itemBuilder: (context, index) {
                  final ground = _featuredGrounds[index];
                  return groundCard(ground['name']!, ground['image']!, ground);
                },
              ),
            ),

            SizedBox(height: 28),

            // News & Events
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tournaments",
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
            SizedBox(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _featuredTournaments.length,
                itemBuilder: (context, index) {
                  final tournament = _featuredTournaments[index];
                  return newsCard(
                    tournament['name']!,
                    tournament['image']!,
                    tournament,
                  );
                },
              ),
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
    return _HoverScale(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => GroundDetails(
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
      ),
    );
  }

  Widget newsCard(
    String title,
    String imageUrl,
    Map<String, String> tournamentData,
  ) {
    return _HoverScale(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TournamentDetails(
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
      ),
    );
  }
}

class _HoverScale extends StatefulWidget {
  final Widget child;
  const _HoverScale({required this.child});

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.08 : 1.0,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
