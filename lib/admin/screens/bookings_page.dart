import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: AppColors.background,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 24), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              isMobile ? 'Bookings' : 'Bookings Management',
              style: TextStyle(
                fontSize: isMobile ? 20 : 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6), // Reduced height
            Text(
              isMobile
                  ? 'Manage bookings'
                  : 'Track and manage all football venue bookings',
              style: TextStyle(
                fontSize: isMobile ? 12 : 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 20), // Further reduced
            // Quick Stats - Made more compact
            Container(
              height: isMobile ? 90 : 110, // Even more reduced height
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 2 : 4,
                childAspectRatio:
                    isMobile
                        ? 2.2
                        : 2.8, // Increased even more for flatter cards
                crossAxisSpacing: 10, // Further reduced spacing
                mainAxisSpacing: 10, // Further reduced spacing
                children: [
                  _buildBookingStatCard(
                    'Match Bookings',
                    '8,934',
                    Icons.sports_soccer,
                    AppColors.primary,
                    isMobile,
                  ),
                  _buildBookingStatCard(
                    'Confirmed',
                    '7,245',
                    Icons.check_circle_outline,
                    AppColors.success,
                    isMobile,
                  ),
                  _buildBookingStatCard(
                    'Pending',
                    '124',
                    Icons.pending_outlined,
                    AppColors.warning,
                    isMobile,
                  ),
                  _buildBookingStatCard(
                    'Completed',
                    '6,892',
                    Icons.done_all_outlined,
                    AppColors.info,
                    isMobile,
                  ),
                ],
              ),
            ), // Close the Container

            SizedBox(height: 12), // Further reduced spacing
            // Bookings List
            Expanded(
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
                            'Recent Football Bookings',
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
                    // Bookings List
                    Expanded(
                      child: ListView.builder(
                        itemCount: _demoBookings.length,
                        itemBuilder: (context, index) {
                          return _buildBookingCard(
                            _demoBookings[index],
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
    );
  }

  Widget _buildBookingStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12), // Reduced padding
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8), // Smaller radius
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6, // Reduced shadow
            offset: const Offset(0, 1), // Smaller offset
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center content
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 4 : 6), // Reduced icon padding
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6), // Smaller radius
            ),
            child: Icon(
              icon,
              color: color,
              size: isMobile ? 16 : 20,
            ), // Smaller icons
          ),
          SizedBox(height: isMobile ? 4 : 6), // Fixed spacing instead of Spacer
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16, // Smaller font
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2), // Reduced spacing
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 9 : 10, // Even smaller font
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1, // Ensure single line
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, bool isMobile) {
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['venue'],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'by ${booking['user']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _getBookingStatusColor(
                            booking['status'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking['status'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getBookingStatusColor(booking['status']),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Booking Details Row
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        booking['date'],
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.access_time_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          booking['time'],
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        booking['amount'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  // No actions - admin can only view
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Booking Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['venue'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Booked by ${booking['user']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getBookingStatusColor(
                            booking['status'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          booking['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getBookingStatusColor(booking['status']),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Booking Details
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              booking['date'],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              booking['time'],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        booking['amount'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      // Admin can only view bookings - no actions available
                    ],
                  ),
                ],
              ),
    );
  }

  Color _getBookingStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return AppColors.success;
      case 'Pending':
        return AppColors.warning;
      case 'Cancelled':
        return AppColors.error;
      case 'Completed':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  static final List<Map<String, dynamic>> _demoBookings = [
    {
      'id': 'BK001',
      'venue': 'Green Valley Football Ground',
      'user': 'Ahmed Rahman',
      'date': '2024-07-20',
      'time': '10:00 - 11:00',
      'amount': '৳1,500',
      'status': 'Confirmed',
    },
    {
      'id': 'BK002',
      'venue': 'Dhanmondi Football Complex',
      'user': 'Fatima Khan',
      'date': '2024-07-21',
      'time': '14:00 - 15:00',
      'amount': '৳1,200',
      'status': 'Pending',
    },
    {
      'id': 'BK003',
      'venue': 'National Football Stadium',
      'user': 'Mohammad Ali',
      'date': '2024-07-22',
      'time': '09:00 - 12:00',
      'amount': '৳3,500',
      'status': 'Confirmed',
    },
    {
      'id': 'BK004',
      'venue': 'Uttara Football Arena',
      'user': 'Rashida Begum',
      'date': '2024-07-19',
      'time': '16:00 - 17:00',
      'amount': '৳800',
      'status': 'Completed',
    },
    {
      'id': 'BK005',
      'venue': 'Gulshan Football Ground',
      'user': 'Karim Hassan',
      'date': '2024-07-23',
      'time': '18:00 - 19:00',
      'amount': '৳1,000',
      'status': 'Pending',
    },
    {
      'id': 'BK006',
      'venue': 'University Football Field',
      'user': 'Salma Khatun',
      'date': '2024-07-18',
      'time': '08:00 - 09:00',
      'amount': '৳900',
      'status': 'Cancelled',
    },
    {
      'id': 'BK007',
      'venue': 'Elite Football Academy',
      'user': 'Abdul Mannan',
      'date': '2024-07-25',
      'time': '16:00 - 18:00',
      'amount': '৳4,000',
      'status': 'Confirmed',
    },
    {
      'id': 'BK008',
      'venue': 'Banani Football Club',
      'user': 'Nazia Ahmed',
      'date': '2024-07-26',
      'time': '17:30 - 18:30',
      'amount': '৳1,200',
      'status': 'Confirmed',
    },
    {
      'id': 'BK009',
      'venue': 'Chittagong Football Stadium',
      'user': 'Ruhul Amin',
      'date': '2024-07-24',
      'time': '14:00 - 16:00',
      'amount': '৳5,500',
      'status': 'Pending',
    },
    {
      'id': 'BK010',
      'venue': 'Mirpur Football Arena',
      'user': 'Fahmida Khan',
      'date': '2024-07-22',
      'time': '19:00 - 20:00',
      'amount': '৳750',
      'status': 'Completed',
    },
    {
      'id': 'BK011',
      'venue': 'Wari Football Field',
      'user': 'Shariful Islam',
      'date': '2024-07-27',
      'time': '15:00 - 16:30',
      'amount': '৳2,800',
      'status': 'Confirmed',
    },
    {
      'id': 'BK012',
      'venue': 'Motijheel Football Ground',
      'user': 'Nasreen Sultana',
      'date': '2024-07-28',
      'time': '07:00 - 08:00',
      'amount': '৳950',
      'status': 'Confirmed',
    },
    {
      'id': 'BK013',
      'venue': 'Rajshahi Football Complex',
      'user': 'Mizanur Rahman',
      'date': '2024-07-29',
      'time': '10:00 - 12:00',
      'amount': '৳3,200',
      'status': 'Pending',
    },
    {
      'id': 'BK014',
      'venue': 'Lalmatia Football Ground',
      'user': 'Sultana Begum',
      'date': '2024-07-21',
      'time': '17:00 - 18:00',
      'amount': '৳1,800',
      'status': 'Completed',
    },
    {
      'id': 'BK015',
      'venue': 'Mohammadpur Football Complex',
      'user': 'Jahangir Alam',
      'date': '2024-07-30',
      'time': '20:00 - 21:00',
      'amount': '৳1,500',
      'status': 'Confirmed',
    },
  ];
}
