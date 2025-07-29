import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AdminEventsPage extends StatelessWidget {
  const AdminEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: AppColors.background,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                isMobile ? 'Events' : 'Events Management',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                isMobile
                    ? 'Manage events'
                    : 'Manage all venue events and activities',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isMobile ? 16 : 32),

              // Event Statistics
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 2 : 4,
                childAspectRatio: isMobile ? 1.8 : 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatCard(
                    'Total Events',
                    '125',
                    Icons.event,
                    AppColors.primary,
                    isMobile,
                  ),
                  _buildStatCard(
                    'Active Events',
                    '68',
                    Icons.event_available,
                    AppColors.success,
                    isMobile,
                  ),
                  _buildStatCard(
                    'Completed Events',
                    '35',
                    Icons.event_available,
                    AppColors.info,
                    isMobile,
                  ),
                  _buildStatCard(
                    'This Month',
                    '42',
                    Icons.calendar_month,
                    AppColors.secondary,
                    isMobile,
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Search and Filter Bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText:
                        isMobile
                            ? 'Search events...'
                            : 'Search events by name or venue...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: isMobile ? 20 : 24,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
                    hintStyle: TextStyle(fontSize: isMobile ? 14 : 16),
                  ),
                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                ),
              ),

              SizedBox(height: 24),

              // Events List
              SizedBox(
                height: isMobile ? 400 : 500,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.all(isMobile ? 16 : 20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Recent Events',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 8 : 12,
                                vertical: isMobile ? 4 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Export',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: isMobile ? 12 : 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Events List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _demoEvents.length,
                          itemBuilder: (context, index) {
                            return _buildEventCard(
                              _demoEvents[index],
                              isMobile,
                            );
                          },
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
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 6 : 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: isMobile ? 14 : 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 9 : 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 8),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child:
          isMobile
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mobile Layout - Stack vertically
                  Row(
                    children: [
                      // Event Type Icon
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _getEventTypeColor(
                            event['type'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _getEventTypeIcon(event['type']),
                          color: _getEventTypeColor(event['type']),
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 12),
                      // Event Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            SizedBox(height: 2),
                            Text(
                              event['venue'],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getEventStatusColor(
                            event['status'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getEventStatusColor(event['status']),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Date and Actions Row
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        event['date'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.people_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${event['attendees']} attendees',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.more_vert,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ),
                ],
              )
              : Row(
                children: [
                  // Event Type Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getEventTypeColor(event['type']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getEventTypeIcon(event['type']),
                      color: _getEventTypeColor(event['type']),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  // Event Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['name'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          event['venue'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              event['date'],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(
                              Icons.people_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${event['attendees']} attendees',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status and Actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getEventStatusColor(
                            event['status'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getEventStatusColor(event['status']),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Color _getEventTypeColor(String type) {
    switch (type) {
      case 'Tournament':
        return AppColors.success;
      case 'League':
        return AppColors.primary;
      case 'Training':
        return AppColors.info;
      case 'Match':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getEventTypeIcon(String type) {
    switch (type) {
      case 'Tournament':
        return Icons.sports_soccer;
      case 'League':
        return Icons.emoji_events;
      case 'Training':
        return Icons.fitness_center;
      case 'Match':
        return Icons.sports;
      default:
        return Icons.sports_soccer;
    }
  }

  Color _getEventStatusColor(String status) {
    switch (status) {
      case 'Active':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      case 'Completed':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  static final List<Map<String, dynamic>> _demoEvents = [
    {
      'name': 'Inter-College Football Tournament',
      'venue': 'Green Valley Football Complex',
      'date': '2024-07-25',
      'attendees': 150,
      'status': 'Active',
      'type': 'Tournament',
    },
    {
      'name': 'Premier Football League 2024',
      'venue': 'National Football Stadium',
      'date': '2024-07-28',
      'attendees': 300,
      'status': 'Active',
      'type': 'League',
    },
    {
      'name': 'Youth Football Training Camp',
      'venue': 'Elite Football Academy',
      'date': '2024-07-30',
      'attendees': 80,
      'status': 'Active',
      'type': 'Training',
    },
    {
      'name': 'Dhaka vs Chittagong Football Match',
      'venue': 'Bangabandhu National Stadium',
      'date': '2024-08-02',
      'attendees': 450,
      'status': 'Completed',
      'type': 'Match',
    },
    {
      'name': 'School Football Championship',
      'venue': 'Dhanmondi Football Ground',
      'date': '2024-08-05',
      'attendees': 120,
      'status': 'Active',
      'type': 'Tournament',
    },
    {
      'name': 'Professional Football League Match',
      'venue': 'Sylhet District Stadium',
      'date': '2024-08-10',
      'attendees': 280,
      'status': 'Completed',
      'type': 'League',
    },
    {
      'name': 'Football Skills Development Workshop',
      'venue': 'BKSP Football Ground',
      'date': '2024-08-12',
      'attendees': 60,
      'status': 'Active',
      'type': 'Training',
    },
    {
      'name': 'Division Football League Final',
      'venue': 'Rajshahi Divisional Stadium',
      'date': '2024-08-15',
      'attendees': 380,
      'status': 'Active',
      'type': 'League',
    },
    {
      'name': 'Women\'s Football Tournament',
      'venue': 'Jessore Stadium',
      'date': '2024-08-18',
      'attendees': 90,
      'status': 'Completed',
      'type': 'Tournament',
    },
    {
      'name': 'Football Coaching Certification',
      'venue': 'Bangladesh Football Federation',
      'date': '2024-08-20',
      'attendees': 45,
      'status': 'Active',
      'type': 'Training',
    },
    {
      'name': 'Corporate Football Tournament',
      'venue': 'Uttara Football Complex',
      'date': '2024-08-22',
      'attendees': 160,
      'status': 'Active',
      'type': 'Tournament',
    },
    {
      'name': 'Football Fitness Training Session',
      'venue': 'Army Stadium Dhaka',
      'date': '2024-08-25',
      'attendees': 75,
      'status': 'Completed',
      'type': 'Training',
    },
    {
      'name': 'National Football Championship',
      'venue': 'Chittagong MA Aziz Stadium',
      'date': '2024-08-28',
      'attendees': 500,
      'status': 'Active',
      'type': 'Tournament',
    },
    {
      'name': 'Under-18 Football League',
      'venue': 'Mymensingh Stadium',
      'date': '2024-09-02',
      'attendees': 220,
      'status': 'Active',
      'type': 'League',
    },
    {
      'name': 'Football Referee Training Program',
      'venue': 'BFF Training Center',
      'date': '2024-09-05',
      'attendees': 35,
      'status': 'Active',
      'type': 'Training',
    },
  ];
}
