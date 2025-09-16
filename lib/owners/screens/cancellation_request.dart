import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/venue_owner_sidebar.dart';
import '../widgets/owner_profile_widget.dart';
import '../services/cancellation_service.dart';

class CancellationRequestsPage extends StatefulWidget {
  const CancellationRequestsPage({Key? key}) : super(key: key);

  @override
  State<CancellationRequestsPage> createState() => _CancellationRequestsPageState();
}

class _CancellationRequestsPageState extends State<CancellationRequestsPage> {
  List<Map<String, dynamic>> cancellationRequests = [];
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getCurrentUser();
    await _loadCancellationRequests();
  }

  Future<void> _getCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.id;
      });
    }
  }

  Future<void> _loadCancellationRequests() async {
    if (currentUserId == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final requests = await CancellationService.getOwnerCancellationRequests(currentUserId!);
      setState(() {
        cancellationRequests = requests;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading cancellation requests: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading cancellation requests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showRefundAmountDialog(Map<String, dynamic> request) async {
    final TextEditingController refundController = TextEditingController();
    final originalAmount = (request['original_amount'] as num).toDouble();
    
    // Set default refund amount as original amount
    refundController.text = originalAmount.toStringAsFixed(2);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Refund Amount'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('User: ${request['user_full_name']}'),
                const SizedBox(height: 8),
                Text('Original Amount: ${CancellationService.formatCurrency(originalAmount)}'),
                const SizedBox(height: 16),
                TextField(
                  controller: refundController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Refund Amount (৳)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Accept & Process Refund'),
              onPressed: () async {
                final refundAmount = double.tryParse(refundController.text);
                if (refundAmount == null || refundAmount < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid refund amount'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                await _acceptCancellationRequest(request['id'], refundAmount);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _acceptCancellationRequest(String cancellationId, double refundAmount) async {
    try {
      final success = await CancellationService.acceptCancellationRequest(
        cancellationId: cancellationId,
        refundAmount: refundAmount,
        ownerId: currentUserId!,
      );

      if (success) {
        await _loadCancellationRequests(); // Reload the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cancellation accepted with refund of ${CancellationService.formatCurrency(refundAmount)}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to accept cancellation request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error accepting cancellation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectCancellationRequest(String cancellationId, String userName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Cancellation'),
          content: Text('Are you sure you want to reject the cancellation request from $userName?\n\nNo refund will be processed.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reject'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final success = await CancellationService.rejectCancellationRequest(
        cancellationId: cancellationId,
        ownerId: currentUserId!,
        rejectionReason: 'Rejected by venue owner',
      );

      if (success) {
        await _loadCancellationRequests(); // Reload the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cancellation request from $userName has been rejected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reject cancellation request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error rejecting cancellation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cancellationRequests.isEmpty
              ? const Center(
                  child: Text(
                    "No pending cancellation requests",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCancellationRequests,
                  child: ListView.builder(
                    itemCount: cancellationRequests.length,
                    itemBuilder: (context, index) {
                      final request = cancellationRequests[index];
                      final userName = request['user_full_name'] ?? 'Unknown User';
                      final bookingDate = request['booking_date'];
                      final startTime = request['start_time'];
                      final endTime = request['end_time'];
                      final originalAmount = (request['original_amount'] as num).toDouble();
                      final cancellationReason = request['cancellation_reason'] ?? 'No reason provided';

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Name
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green[100],
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Booking Details Container
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Booking Details',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, color: Colors.blue[700], size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Date: ${CancellationService.formatDate(bookingDate)}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, color: Colors.blue[700], size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Time: ${CancellationService.formatTime(startTime)} - ${CancellationService.formatTime(endTime)}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.attach_money, color: Colors.green[700], size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Amount: ${CancellationService.formatCurrency(originalAmount)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Requested At Information
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.schedule, color: Colors.orange[700], size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Requested at: ${CancellationService.formatDateTime(request['created_at'])}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Cancellation Reason
                              Text(
                                'Cancellation Reason:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Text(
                                  cancellationReason,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.check_circle, size: 18),
                                      label: const Text('Accept'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () => _showRefundAmountDialog(request),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.cancel, size: 18),
                                      label: const Text('Reject'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () => _rejectCancellationRequest(request['id'], userName),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
