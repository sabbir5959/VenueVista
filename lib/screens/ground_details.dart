import 'package:flutter/material.dart';

class GroundDetails extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String location;
  final String description;
  final String price;
  final String rating;
  final String facilities;
  final String size;

  const GroundDetails({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.description,
    required this.price,
    required this.rating,
    required this.facilities,
    required this.size,
  });

  @override
  State<GroundDetails> createState() => _GroundDetailsState();
}

class _GroundDetailsState extends State<GroundDetails> {
  String? selectedTimeSlot;
  final List<String> timeSlots = List.generate(13, (index) {
    final startHour = index + 9; // Starts from 9 AM
    return '${startHour.toString().padLeft(2, '0')}:00 to ${(startHour + 1).toString().padLeft(2, '0')}:00';
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ground Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Ground Details
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text(
                              widget.rating,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.location,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ground Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.straighten,
                          title: 'Size',
                          value: widget.size,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.attach_money,
                          title: 'Price',
                          value: widget.price,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Facilities
                  Text(
                    'Facilities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        widget.facilities.split(', ').map((facility) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              border: Border.all(color: Colors.green.shade200),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              facility,
                              style: TextStyle(color: Colors.green.shade900),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Time Slots Section
                  Text(
                    'Available Time Slots',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time Slots Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final timeSlot = timeSlots[index];
                      final isSelected = selectedTimeSlot == timeSlot;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedTimeSlot = timeSlot;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.green.shade100
                                    : Colors.white,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Colors.green.shade700
                                      : Colors.green.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            timeSlot,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.green.shade900
                                      : Colors.black87,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Rating Section
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rate This Ground',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Share your experience with other players',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 1; i <= 5; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => _RatingDialog(
                                              groundName: widget.name,
                                            ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.star,
                                      size: 40,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              selectedTimeSlot == null
                  ? null
                  : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Booking confirmed for $selectedTimeSlot',
                        ),
                        backgroundColor: Colors.green.shade900,
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    color: Colors.amber,
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
                            // TODO: Submit rating and feedback to backend
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
                  child: const Text('Submit'),
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
