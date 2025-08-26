import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/common_drawer.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  // Function to open directions in Google Maps
  Future<void> _openDirections(
    BuildContext context,
    String destinationQuery,
  ) async {
    try {
      
      final Uri geoUri = Uri.parse(
        'geo:0,0?q=${Uri.encodeComponent(destinationQuery)}',
      );

      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Fallback to Google Maps web
      final Uri webMapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(destinationQuery)}',
      );

      if (await canLaunchUrl(webMapsUri)) {
        await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
        return;
      }

      // If all else fails, try the original directions URL
      final Uri directionsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(destinationQuery)}',
      );

      if (await canLaunchUrl(directionsUrl)) {
        await launchUrl(directionsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Google Maps directions.';
      }
    } catch (e) {
      // Show user-friendly error message instead of throwing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open directions. Please check if Google Maps is installed.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> schedules = [
      {
        'groundName': 'Club Volta',
        'date': '2025-07-25',
        'time': '18:00 - 20:00',
        'type': 'Football Match',
        'status': 'Confirmed',
        'locationQuery': 'Club Volta, Dhaka',
      },
      {
        'groundName': 'Kings Arena',
        'date': '2025-07-28',
        'time': '16:30 - 18:30',
        'type': 'Practice Session',
        'status': 'Pending',
        'locationQuery': 'Kings Arena, Dhaka',
      },
      {
        'groundName': 'Dbox Stadium',
        'date': '2025-08-01',
        'time': '19:00 - 21:00',
        'type': 'Tournament Match',
        'status': 'Confirmed',
        'locationQuery': 'Dbox Stadium, Dhaka',
      },
    ];

    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: AppBar(
        title: Text('My Schedules', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        schedule['groundName'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              schedule['status'] == 'Confirmed'
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          schedule['status'],
                          style: TextStyle(
                            color:
                                schedule['status'] == 'Confirmed'
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 8),
                      Text(
                        schedule['date'],
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 8),
                      Text(
                        schedule['time'],
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.sports_soccer,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 8),
                      Text(
                        schedule['type'],
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.cloud_outlined,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.cloud_outlined,
                                      color: Colors.blue.shade700,
                                      size: 28,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Weather Forecast',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      schedule['groundName'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16),
                                        SizedBox(width: 8),
                                        Text(schedule['date']),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.thermostat_outlined,
                                              size: 32,
                                              color: Colors.orange,
                                            ),
                                            Text(
                                              '28°C',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text('Temperature'),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.water_drop_outlined,
                                              size: 32,
                                              color: Colors.blue,
                                            ),
                                            Text(
                                              '65%',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text('Humidity'),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Weather Condition: Partly Cloudy',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('Close'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.location_on,
                          color: Colors.green.shade700,
                          size: 24,
                        ),
                        onPressed: () {
                          _openDirections(context, schedule['locationQuery']);
                          _openDirections(context, schedule['locationQuery']);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        schedule['groundName'],
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Details:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Date: ${schedule['date']}'),
                          Text('Time: ${schedule['time']}'),
                          Text('Event: ${schedule['type']}'),
                          Text('Status: ${schedule['status']}'),
                          SizedBox(height: 16),
                          Text(
                            'Would you like to cancel this booking?',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text('Close'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: Text(
                            'Confirm Cancellation',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.red,
                                        size: 28,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Warning',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Please note:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text('• Cancellation fee may apply'),
                                      Text(
                                        '• Refund will take 3-5 business days',
                                      ),
                                      Text('• This action cannot be undone'),
                                      SizedBox(height: 16),
                                      Text(
                                        'Are you sure you want to cancel this booking?',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('No, Keep Booking'),
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                    ),
                                    TextButton(
                                      child: Text(
                                        'Yes, Cancel',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Cancellation request sent for ${schedule['groundName']}',
                                            ),
                                            backgroundColor:
                                                Colors.red.shade700,
                                            duration: Duration(seconds: 2),
                                            action: SnackBarAction(
                                              label: 'UNDO',
                                              textColor: Colors.white,
                                              onPressed: () {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Cancellation request withdrawn',
                                                    ),
                                                    backgroundColor:
                                                        Colors.green.shade700,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
