import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/common_drawer.dart';
import 'screens/ground_booking_payment_page.dart';
import '../../services/booking_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroundDetails extends StatefulWidget {
  final String area;
  final String? venueId; // Add venue ID
  final String name;
  final String imageUrl;
  final String location;
  final String description;
  final String price;
  final String groundPayment;
  final String rating;
  final String facilities;
  final String size;

  const GroundDetails({
    super.key,
    this.venueId, // Optional for backward compatibility
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.description,
    required this.price,
    required this.groundPayment,
    required this.rating,
    required this.facilities,
    required this.size,
    required this.area,
  });

  @override
  State<GroundDetails> createState() => _GroundDetailsState();
}

class _GroundDetailsState extends State<GroundDetails> {
  final supabase = Supabase.instance.client;
  // Helper to extract area from location string (e.g., 'Uptown, Dhaka' -> 'Uptown')
  String extractArea(String location) {
    if (location.contains(',')) {
      return location.split(',')[0].trim();
    }
    return location.trim();
  }

  List<String> selectedTimeSlots = [];
  final List<String> timeSlots = List.generate(13, (index) {
    final startHour = index + 9;
    return '${startHour.toString().padLeft(2, '0')}:00 to ${(startHour + 1).toString().padLeft(2, '0')}:00';
  });

  void onSlotTapped(String slot) {
    setState(() {
      if (selectedTimeSlots.contains(slot)) {
        selectedTimeSlots.remove(slot);
      } else {
        selectedTimeSlots.add(slot);
      }
    });
  }

  List<Map<String, dynamic>> recommendedVenues = [];
  bool isLoadingRecommended = false;

  Future<void> fetchRecommendedVenues() async {
    setState(() {
      isLoadingRecommended = true;
    });
    try {
      // Use the area from the widget (from DB), not from location string
      final area = widget.area;
      // Query venues with the same area, excluding the current venue
      final data = await supabase
          .from('venues')
          .select()
          .eq('area', area)
          .neq('id', widget.venueId ?? '')
          .limit(10);
      setState(() {
        recommendedVenues = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      setState(() {
        recommendedVenues = [];
      });
    } finally {
      setState(() {
        isLoadingRecommended = false;
      });
    }
  }

  Set<String> bookedSlots = {};
  bool isLoadingSlots = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchBookedSlots();
    fetchRecommendedVenues();
  }

  Future<void> fetchBookedSlots() async {
    setState(() {
      isLoadingSlots = true;
    });
    try {
      final bookings = await BookingService.getBookingsForVenueAndDate(
        widget.venueId ?? '',
        selectedDate,
      );
      print('DEBUG bookings fetched:');
      print(bookings);
      Set<String> booked = {};
      for (var booking in bookings) {
        final start = booking['start_time'];
        final end = booking['end_time'];
        if (start != null && end != null) {
          print('BOOKED SLOT START TIME (separate):');
          print(start);
          int startHour = int.parse(start.split(':')[0]);
          int endHour = int.parse(end.split(':')[0]);
          for (int h = startHour; h < endHour; h++) {
            final slotString =
                '${h.toString().padLeft(2, '0')}:00 to ${(h + 1).toString().padLeft(2, '0')}:00';
            booked.add(slotString);
          }
        }
      }
      print('DEBUG bookedSlots:');
      print(booked);
      setState(() {
        bookedSlots = booked;
        isLoadingSlots = false;
      });
    } catch (e) {
      setState(() {
        isLoadingSlots = false;
      });
      print('Error fetching booked slots: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      drawer: const CommonDrawer(),
      appBar: AppBar(
        title: Text(
          widget.name,
          style: TextStyle(
            color: Colors.green.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green.shade900),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => _LocationDialog(
                      groundName: widget.name,
                      location: widget.location,
                    ),
              );
            },
            icon: Icon(Icons.location_on, color: Colors.green.shade900),
          ),
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _RatingDialog(groundName: widget.name),
              );
            },
            icon: Icon(Icons.star_border, color: Colors.green.shade900),
            label: Text(
              'Rate',
              style: TextStyle(
                color: Colors.green.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _InfoCard(
                          icon: Icons.straighten,
                          title: 'Size',
                          value: widget.size,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _InfoCard(
                          icon: Icons.attach_money,
                          title: 'Price',
                          value: 'Tk ${widget.price}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Description Section
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),

              Text(
                'Facilities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        widget.facilities.split(', ').map((facility) {
                          return Chip(
                            label: Text(facility),
                            backgroundColor: Colors.green.shade50,
                            labelStyle: TextStyle(color: Colors.green.shade900),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.green.shade200),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Available Time Slots',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              const SizedBox(height: 16),
              isLoadingSlots
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final timeSlot = timeSlots[index];
                      final isBooked = bookedSlots.contains(timeSlot);
                      final isSelected = selectedTimeSlots.contains(timeSlot);
                      return InkWell(
                        onTap: isBooked ? null : () => onSlotTapped(timeSlot),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color:
                                isBooked
                                    ? Colors.red.shade200
                                    : isSelected
                                    ? Colors.green.shade100
                                    : Colors.white,
                            border: Border.all(
                              color:
                                  isBooked
                                      ? Colors.red.shade700
                                      : isSelected
                                      ? Colors.green.shade700
                                      : Colors.green.shade200,
                              width: isBooked || isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: Colors.green.shade100,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                    : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            timeSlot,
                            style: TextStyle(
                              color:
                                  isBooked
                                      ? Colors.red.shade900
                                      : isSelected
                                      ? Colors.green.shade900
                                      : Colors.black87,
                              fontWeight:
                                  isBooked || isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              // Recommended Grounds Section (from Supabase by area)
              Text(
                'Recommended Grounds',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              const SizedBox(height: 12),
              if (isLoadingRecommended)
                const Center(child: CircularProgressIndicator())
              else if (recommendedVenues.isEmpty)
                const Text(
                  'No other venues found in this area.',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                )
              else
                SizedBox(
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendedVenues.length,
                    separatorBuilder: (context, i) => const SizedBox(width: 16),
                    itemBuilder: (context, i) {
                      final venue = recommendedVenues[i];
                      final imageUrl =
                          (venue['image_urls'] is List &&
                                  venue['image_urls'].isNotEmpty)
                              ? venue['image_urls'][0]
                              : 'https://via.placeholder.com/140x90.png?text=No+Image';
                      return SizedBox(
                        width: 140,
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              // Optionally, navigate to details of the suggested ground
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(14),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    height: 90,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        venue['name'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              venue['area'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),

              // Average Rating and Rate Button (moved to last)
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 28),
                          const SizedBox(width: 6),
                          Text(
                            widget.rating,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '/ 5',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) =>
                                    _RatingDialog(groundName: widget.name),
                          );
                        },
                        icon: const Icon(Icons.star_border),
                        label: const Text('Rate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade900,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed:
              selectedTimeSlots.isEmpty
                  ? null
                  : () {
                    final bookingData = <String, dynamic>{
                      'venueId': widget.venueId ?? '',
                      'name': widget.name,
                      'location': widget.location,
                      'price': widget.price,
                      'groundPayment': widget.groundPayment,
                      'selectedSlots':
                          selectedTimeSlots.whereType<String>().toList(),
                      'timeSlot':
                          selectedTimeSlots.isNotEmpty
                              ? selectedTimeSlots.first
                              : '',
                      'date':
                          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      'size': widget.size,
                      'facilities': widget.facilities,
                      'rating': widget.rating,
                      'description': widget.description,
                    };
                    print('DEBUG bookingData:');
                    bookingData.forEach((key, value) {
                      print('$key: $value ([33m${value.runtimeType}[0m)');
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                GroundBookingPaymentPage(booking: bookingData),
                      ),
                    );
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade900,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Confirm Booking',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingDialog extends StatefulWidget {
  final String groundName;

  const _RatingDialog({required this.groundName});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rate Your Experience',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.groundName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: const Color.fromARGB(255, 246, 165, 1),
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green.shade700),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Skip',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _rating == 0
                          ? null
                          : () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Thank you for your feedback!'),
                                backgroundColor: Colors.green.shade900,
                              ),
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green.shade700),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.green.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(value, style: TextStyle(color: Colors.black87, fontSize: 16)),
        ],
      ),
    );
  }
}

class _LocationDialog extends StatelessWidget {
  final String groundName;
  final String location;

  const _LocationDialog({required this.groundName, required this.location});

  Future<void> _openDirections(
    BuildContext context,
    String destinationQuery,
  ) async {
    final Uri directionsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(destinationQuery)}',
    );

    try {
      await launchUrl(directionsUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open Google Maps'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Location',
        style: TextStyle(
          color: Colors.green.shade900,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.location_on, size: 48, color: Colors.green.shade700),
                SizedBox(height: 12),
                Text(
                  groundName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  location,
                  style: TextStyle(fontSize: 16, color: Colors.green.shade700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _openDirections(context, '$groundName, $location, Dhaka');
              Navigator.pop(context);
            },
            icon: Icon(Icons.directions, color: Colors.white),
            label: Text(
              'Get Directions',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: Colors.green.shade900)),
        ),
      ],
    );
  }
}
