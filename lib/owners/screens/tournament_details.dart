import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'edit_tournament.dart';

class TournamentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> tournament;
  final String? filter;

  const TournamentDetailsPage({
    Key? key, 
    required this.tournament,
    this.filter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime tournamentDate = tournament['date'] as DateTime;
    final String formattedDate = DateFormat('EEEE, MMMM dd, yyyy').format(tournamentDate);
    final String formattedTime = DateFormat('hh:mm a').format(tournamentDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(tournament['name'] as String),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green[700]!, Colors.green[500]!],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_soccer,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tournament['name'] as String,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tournament['sport'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Tournament Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'Tournament Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.calendar_today, 'Date', formattedDate),
                          const SizedBox(height: 12),
                          _buildDetailRow(Icons.access_time, 'Time', formattedTime),
                          const SizedBox(height: 12),
                          _buildDetailRow(Icons.group, 'Team Size', '${tournament['teamSize']} players per team'),
                          const SizedBox(height: 12),
                          _buildDetailRow(Icons.attach_money, 'Entry Fee', tournament['fee'] as String),
                          const SizedBox(height: 12),
                          _buildDetailRow(Icons.location_on, 'Venue', tournament['venue'] ?? 'Main Ground'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Registration Details Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.how_to_reg, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'Registration Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.event_available, 'Registration Deadline', 
                              DateFormat('MMM dd, yyyy').format(tournamentDate.subtract(const Duration(days: 3)))),
                          const SizedBox(height: 12),
                          _buildDetailRow(Icons.groups, 'Max Teams', tournament['maxTeams'] ?? '16'),
                          const SizedBox(height: 12),
                          _buildDetailRow(Icons.people, 'Registered Teams', tournament['registeredTeams'] ?? '8'),
                          const SizedBox(height: 12),
                          _buildDetailRow(Icons.schedule, 'Tournament Duration', tournament['duration'] ?? '1 Day'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Rules and Regulations Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.rule, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'Rules & Regulations',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildRuleItem('All players must be 18 years or older'),
                          _buildRuleItem('Teams must arrive 30 minutes before their match'),
                          _buildRuleItem('Proper sports attire is mandatory'),
                          _buildRuleItem('No outside food or drinks allowed'),
                          _buildRuleItem('Tournament organizer\'s decision is final'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Prize Information Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.emoji_events, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'Prize Pool',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildPrizeRow('🥇 1st Place', tournament['firstPrize'] ?? '৳ 15,000'),
                          const SizedBox(height: 8),
                          _buildPrizeRow('🥈 2nd Place', tournament['secondPrize'] ?? '৳ 10,000'),
                          const SizedBox(height: 8),
                          _buildPrizeRow('🥉 3rd Place', tournament['thirdPrize'] ?? '৳ 5,000'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Contact Information Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.contact_phone, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.person, 'Organizer', tournament['organizer'] ?? 'VenueVista Sports'),
                          const SizedBox(height: 12),
                          _buildDetailRow(Icons.phone, 'Phone', tournament['phone'] ?? '+880 1700-594133'),
                          const SizedBox(height: 12),
                          _buildDetailRow(Icons.email, 'Email', tournament['email'] ?? 'info@venuevista.com'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Button (only show for non-past tournaments)
                  if (filter != 'Past') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          //  to edit tournament page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTournamentPage(
                                tournament: tournament,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Tournament'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.green[700],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rule,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeRow(String position, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          position,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }
}
