import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/common_drawer.dart';
import '../../widgets/weather_popup.dart';
import 'payment_page.dart';
import '../../services/tournament_service.dart';
import '../../services/supabase_config.dart';

class TournamentDetails extends StatefulWidget {
  final String? id;
  final String name;
  final String imageUrl;
  final String date;
  final String time;
  final String location;
  final String prize;
  final String participants;
  final String playerFormat;
  final String status;
  final String description;
  final String entryFee;
  final String organizer;

  const TournamentDetails({
    super.key,
    this.id,
    required this.name,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.location,
    required this.prize,
    required this.participants,
    required this.playerFormat,
    required this.status,
    required this.description,
    required this.entryFee,
    required this.organizer,
  });

  @override
  State<TournamentDetails> createState() => _TournamentDetailsState();
}

class _TournamentDetailsState extends State<TournamentDetails> {
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    if (widget.id == null) return;

    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId != null) {
        print(
          '🔍 TournamentDetails: Checking registration for tournament ID: ${widget.id}',
        );
        print('🔍 TournamentDetails: User ID: $userId');
        print('🔍 TournamentDetails: Tournament name: ${widget.name}');

        final hasRegistered = await TournamentService.hasUserRegistered(
          widget.id!,
          userId,
        );

        print(
          '✅ TournamentDetails: Registration status for ${widget.name}: $hasRegistered',
        );

        setState(() {
          isRegistered = hasRegistered;
        });
      }
    } catch (e) {
      print('❌ TournamentDetails: Error checking registration status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(
          'Tournament Details',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      drawer: CommonDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament Image Header
            Container(
              height: 250,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                child: Stack(
                  children: [
                    // Tournament Image
                    Image.network(
                      widget.imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 250,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.green,
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ Tournament image load error: $error');
                        return Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade700,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  size: 80,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Tournament Image',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Gradient Overlay with Content
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  widget.location,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
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
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          widget.status == 'Registration Open'
                              ? Colors.green
                              : widget.status == 'Ongoing'
                              ? Colors.orange
                              : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.status,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Tournament Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.calendar_today,
                          title: 'Date',
                          value: widget.date,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.access_time,
                          title: 'Time',
                          value: widget.time,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.emoji_events,
                          title: 'Prize',
                          value: widget.prize,
                          color: Colors.amber,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.people,
                          title: 'Format',
                          value: widget.playerFormat,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Description Section
                  Text(
                    'About Tournament',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 25),

                  // Tournament Details
                  _DetailSection(
                    title: 'Tournament Details',
                    children: [
                      _DetailRow('Participants', widget.participants),
                      _DetailRow('Entry Fee', widget.entryFee),
                      _DetailRow('Organizer', widget.organizer),
                      _DetailRow('Player Format', widget.playerFormat),
                    ],
                  ),

                  SizedBox(height: 25),

                  // Rules Section
                  _DetailSection(
                    title: 'Tournament Rules',
                    children: [
                      _RuleItem(
                        'All players must be registered before the tournament starts',
                      ),
                      _RuleItem(
                        'Each team must have minimum ${widget.playerFormat.split('v')[0]} players',
                      ),
                      _RuleItem(
                        'Fair play is mandatory - any misconduct will result in disqualification',
                      ),
                      _RuleItem('Entry fee must be paid during registration'),
                      _RuleItem(
                        'Tournament organizer\'s decision will be final',
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  // Register Button - Updated logic to check registration status
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isRegistered
                                ? Colors.blue.shade600
                                : (widget.status == 'Registration Open'
                                    ? Colors.green.shade700
                                    : Colors.grey.shade500),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                      ),
                      onPressed:
                          isRegistered
                              ? null
                              : (widget.status == 'Registration Open'
                                  ? () {
                                    _showRegistrationDialog();
                                  }
                                  : null),
                      child: Text(
                        isRegistered
                            ? 'Already Registered'
                            : (widget.status == 'Registration Open'
                                ? 'Register for Tournament'
                                : widget.status),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Registration Status Indicator
                  if (isRegistered) ...[
                    SizedBox(height: 16),
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
                          Expanded(
                            child: Text(
                              'You are already registered for this tournament',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _InfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _DetailSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _DetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _RuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              rule,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRegistrationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Tournament Registration',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You are about to register for:'),
              SizedBox(height: 10),
              Text(
                widget.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.location,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.cloud,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    onPressed:
                        () => _showWeatherPopup(
                          context,
                          widget.location,
                          _parseDate(widget.date),
                          widget.name,
                        ),
                    tooltip: 'Weather Update',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.directions,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    onPressed: () => _openDirections(context, widget.location),
                    tooltip: 'Get Directions',
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text('Entry Fee: ${widget.entryFee}'),
              SizedBox(height: 10),
              Text(
                'Please confirm your registration. You will be redirected to payment after confirmation.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Create tournament data for payment page
                final tournamentData = <String, dynamic>{
                  'id': widget.id, // Include tournament ID
                  'name': widget.name,
                  'image': widget.imageUrl,
                  'date': widget.date,
                  'time': widget.time,
                  'location': widget.location,
                  'prize': widget.prize,
                  'participants': widget.participants,
                  'playerFormat': widget.playerFormat,
                  'status': widget.status,
                  'description': widget.description,
                  'entryFee': widget.entryFee,
                  'organizer': widget.organizer,
                };

                // Close dialog first
                Navigator.of(context).pop();

                // Navigate directly to payment page
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                PaymentPage(tournament: tournamentData),
                      ),
                    )
                    .then((result) {
                      // Refresh registration status after payment
                      if (result == true) {
                        _checkRegistrationStatus();
                      }
                    });
              },
              child: Text('Confirm Registration'),
            ),
          ],
        );
      },
    );
  }

  // Helper methods for weather and directions
  void _showWeatherPopup(
    BuildContext context,
    String location,
    DateTime tournamentDate,
    String tournamentName,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => WeatherPopup(
            location: location,
            bookingDate: tournamentDate,
            groundName: tournamentName,
          ),
    );
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  Future<void> _openDirections(BuildContext context, String location) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$location';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open map for directions')),
        );
      }
    }
  }
}
