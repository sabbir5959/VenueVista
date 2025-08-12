import 'package:flutter/material.dart';
import '../widgets/venue_owner_sidebar.dart';
import '../widgets/owner_profile_widget.dart';

class CancellationRequest {
  final String userName;
  final String reason;
  final DateTime bookedTime;
  final DateTime requestTime;

  CancellationRequest({
    required this.userName, 
    required this.reason,
    required this.bookedTime,
    required this.requestTime,
  });

  String get timingInfo {
    final difference = bookedTime.difference(requestTime);
    final hours = difference.inHours;
    final days = difference.inDays;
    
    if (days > 0) {
      return "$days day${days > 1 ? 's' : ''} before booked time";
    } else if (hours > 0) {
      return "$hours hour${hours > 1 ? 's' : ''} before booked time";
    } else {
      return "Less than 1 hour before booked time";
    }
  }
}

class CancellationRequestsPage extends StatefulWidget {
  const CancellationRequestsPage({Key? key}) : super(key: key);

  @override
  State<CancellationRequestsPage> createState() => _CancellationRequestsPageState();
}

class _CancellationRequestsPageState extends State<CancellationRequestsPage> {
  List<CancellationRequest> requests = [
    CancellationRequest(
      userName: "Shohan Khan", 
      reason: "Family emergency.",
      bookedTime: DateTime.now().add(const Duration(hours: 48)), // Booked for 2 days from now
      requestTime: DateTime.now().subtract(const Duration(hours: 24)), // Requested 1 day ago
    ),
    CancellationRequest(
      userName: "Subhro Roy", 
      reason: "Injury during practice.",
      bookedTime: DateTime.now().add(const Duration(hours: 12)), // Booked for 12 hours from now
      requestTime: DateTime.now().subtract(const Duration(hours: 2)), // Requested 2 hours ago
    ),
    CancellationRequest(
      userName: "Reyana Akhter", 
      reason: "Bad weather forecast.",
      bookedTime: DateTime.now().add(const Duration(hours: 6)), // Booked for 6 hours from now
      requestTime: DateTime.now().subtract(const Duration(minutes: 30)), // Requested 30 minutes ago
    ),
  ];

  void handleRequest(String userName, String action) {
    setState(() {
      requests.removeWhere((req) => req.userName == userName);
    });

    String message = "";
    switch (action) {
      case 'acknowledged':
        message = "Acknowledged cancellation for $userName";
        break;
      case 'full_refund':
        message = "Full refund approved for $userName";
        break;
      case 'half_refund':
        message = "Half refund approved for $userName";
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cancellation Requests"),
        backgroundColor: Colors.green[700],
        actions: [
          OwnerProfileWidget(),
        ],
      ),
      drawer: const VenueOwnerSidebar(currentPage: 'cancellations'),
      body: requests.isEmpty
          ? const Center(
              child: Text(
                "No cancellation requests",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Icon(
                        Icons.person,
                        color: Colors.green[700],
                      ),
                    ),
                    title: Text(
                      req.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: const Text("Tap to view details"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Reason: ${req.reason}",
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.schedule, color: Colors.blue[700], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Cancellation Timing",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                        Text(
                                          "Requested ${req.timingInfo}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Select Action:",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                SizedBox(
                                  width: (MediaQuery.of(context).size.width - 64) / 2,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.visibility, size: 16),
                                    label: const Text("Acknowledged", style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => handleRequest(req.userName, 'acknowledged'),
                                  ),
                                ),
                                SizedBox(
                                  width: (MediaQuery.of(context).size.width - 64) / 2,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.money, size: 16),
                                    label: const Text("Full Refund", style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => handleRequest(req.userName, 'full_refund'),
                                  ),
                                ),
                                SizedBox(
                                  width: (MediaQuery.of(context).size.width - 64) / 2,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.money_off, size: 16),
                                    label: const Text("Half Refund", style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => handleRequest(req.userName, 'half_refund'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
