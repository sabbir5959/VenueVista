import 'package:flutter/material.dart';
import '../widgets/venue_owner_sidebar.dart';
import '../widgets/owner_profile_widget.dart';

class RevenueTrackingScreen extends StatelessWidget {
  const RevenueTrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earning Overview'),
        backgroundColor: Colors.green[700],
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Colors.green[700],
                size: 24,
              ),
            ),
          ),
        ],
      ),
      drawer: const VenueOwnerSidebar(currentPage: 'revenue'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Summary Card
            Card(
              color: Colors.cyan,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Current Value',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\u09F3 2,50000',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '+ \u09F3 15,000',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.greenAccent,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Profit in this Month',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: CircularProgressIndicator(
                            value: 0.025,
                            strokeWidth: 6,
                            color: Colors.white,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        const Text(
                          '+2.5%',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

           
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (String range in ['1M', '3M', '6M', '9M', '1Y'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(range),
                        selected: range == '1M',
                        onSelected: (bool selected) {},
                        selectedColor: Colors.green[700],
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: range == '1M' ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sales Revenue Section
            const Text(
              'Booking Income',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Metrics List
            Expanded(
              child: ListView(
                children: [
                  for (var metric in [
                    {'icon': Icons.pie_chart, 'title': 'Tournament', 'subtitle': 'Since Last Month', 'value': '\u09F3 10,000', 'background': Colors.cyan},
                    {'icon': Icons.widgets, 'title': 'Daily Booking', 'subtitle': 'Since Last Month', 'value': '\u09F3 5,000', 'background': Colors.purpleAccent},
                  ])
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: metric['background'] as Color? ?? Colors.green[700],
                        child: Icon(metric['icon'] as IconData, color: Colors.white),
                      ),
                      title: Text(metric['title'] as String),
                      subtitle: Text(metric['subtitle'] as String),
                      trailing: Text(
                        metric['value'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
