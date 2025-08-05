import 'package:flutter/material.dart';
import '../widgets/venue_owner_sidebar.dart';
import '../widgets/owner_profile_widget.dart';

class CancellationRequest {
  final String userName;
  final String reason;

  CancellationRequest({required this.userName, required this.reason});
}

class CancellationRequestsPage extends StatefulWidget {
  const CancellationRequestsPage({Key? key}) : super(key: key);

  @override
  State<CancellationRequestsPage> createState() => _CancellationRequestsPageState();
}

class _CancellationRequestsPageState extends State<CancellationRequestsPage> {
  List<CancellationRequest> requests = [
    CancellationRequest(userName: "Shohan Khan", reason: "Family emergency."),
    CancellationRequest(userName: "Subhro Roy", reason: "Injury during practice."),
    CancellationRequest(userName: "Reyana Akhter", reason: "Bad weather forecast."),
  ];

  void handleRequest(String userName, bool isAccepted) {
    setState(() {
      requests.removeWhere((req) => req.userName == userName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${isAccepted ? 'Accepted' : 'Rejected'} cancellation for $userName"),
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
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check),
                                  label: const Text("Accept"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => handleRequest(req.userName, true),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.close),
                                  label: const Text("Reject"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => handleRequest(req.userName, false),
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
