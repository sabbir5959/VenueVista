import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/edit_profile_page_new.dart';

class OwnerProfileWidget extends StatefulWidget {
  const OwnerProfileWidget({Key? key}) : super(key: key);

  @override
  State<OwnerProfileWidget> createState() => _OwnerProfileWidgetState();
}

class _OwnerProfileWidgetState extends State<OwnerProfileWidget> {
  Map<String, dynamic>? ownerData;
  Map<String, dynamic>? venueData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOwnerData();
  }

  Future<void> _loadOwnerData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Fetch owner profile data
      final profileResponse = await Supabase.instance.client
          .from('user_profiles')
          .select('*')
          .eq('id', user.id)
          .single();

      // Fetch owner's venue data
      final venueResponse = await Supabase.instance.client
          .from('venues')
          .select('*')
          .eq('owner_id', user.id)
          .maybeSingle();

      setState(() {
        ownerData = profileResponse;
        venueData = venueResponse;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading owner data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () => _showProfileDialog(context),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            color: Colors.green[700],
            size: 24,
          ),
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 350,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85, // Limit height to 85% of screen
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fixed header (non-scrollable)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.green[100],
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLoading 
                                ? 'Loading...' 
                                : (ownerData?['full_name'] ?? 'Owner Profile'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Venue Owner',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                    child: Column(
                      children: [

                // Profile Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        Icons.person_outline,
                        'Owner ID',
                        isLoading ? 'Loading...' : (ownerData?['id']?.toString() ?? 'N/A'),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.phone_outlined,
                        'Contact',
                        isLoading ? 'Loading...' : (ownerData?['phone'] ?? 'N/A'),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.email_outlined,
                        'Email',
                        isLoading ? 'Loading...' : (ownerData?['email'] ?? 'N/A'),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        'Joined Date',
                        isLoading ? 'Loading...' : (ownerData?['created_at'] != null 
                          ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(ownerData!['created_at']))
                          : 'N/A'),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.business_outlined,
                        'Company Name',
                        isLoading ? 'Loading...' : (ownerData?['company_name'] ?? 'N/A'),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.verified_outlined,
                        'Status',
                        isLoading ? 'Loading...' : (ownerData?['status'] ?? 'N/A'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Venue Details Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_city,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Venue Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              // Navigate to edit venue details page
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfilePage(
                                    ownerData: ownerData,
                                    venueData: venueData,
                                  ),
                                ),
                              );
                              
                              // If profile was updated successfully, refresh data
                              if (result == true) {
                                _loadOwnerData();
                              }
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blue[700],
                              size: 18,
                            ),
                            tooltip: 'Edit Venue Details',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.business,
                        'Venue Name',
                        isLoading ? 'Loading...' : (venueData?['name'] ?? 'No Venue Found'),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.star,
                        'Rating',
                        isLoading ? 'Loading...' : '${venueData?['rating'] ?? 0.0} / 5.0',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.category,
                        'Venue Type',
                        isLoading ? 'Loading...' : (venueData?['venue_type'] ?? 'N/A'),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.location_on,
                        'Address',
                        isLoading ? 'Loading...' : (venueData?['address'] ?? 'N/A'),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.location_city,
                        'City',
                        isLoading ? 'Loading...' : (venueData?['city'] ?? 'N/A'),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.straighten,
                        'Ground Size',
                        isLoading ? 'Loading...' : (venueData?['ground_size'] ?? 'N/A'),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.people,
                        'Capacity',
                        isLoading ? 'Loading...' : '${venueData?['capacity'] ?? 'N/A'} people',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.check_circle,
                        'Status',
                        isLoading ? 'Loading...' : (venueData?['status'] ?? 'N/A'),
                      ),
                      const SizedBox(height: 16),
                      
                      // Facilities Section
                      Text(
                        'Facilities',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.featured_play_list,
                        'Available Facilities',
                        isLoading ? 'Loading...' : (venueData?['facilities'] != null 
                          ? (venueData!['facilities'] as List).join(', ')
                          : 'No facilities listed'),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.description,
                        'Description',
                        isLoading ? 'Loading...' : (venueData?['description'] ?? 'No description available'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          // Navigate to edit profile page with real data
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                ownerData: ownerData,
                                venueData: venueData,
                              ),
                            ),
                          );
                          
                          // If profile was updated successfully, refresh data
                          if (result == true) {
                            _loadOwnerData();
                          }
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Profile'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green[700],
                          side: BorderSide(color: Colors.green[700]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.green[700],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
