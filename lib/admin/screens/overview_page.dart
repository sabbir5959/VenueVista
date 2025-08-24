import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: AppColors.background,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.dashboard_outlined,
                  size: isMobile ? 24 : 32,
                  color: AppColors.primary,
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Welcome to VenueVista Admin Panel',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 24 : 32),

            // Stats Cards
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Top Stats Row
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isMobile ? 2 : 4,
                      childAspectRatio: isMobile ? 1.2 : 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildStatCard(
                          'Total Users',
                          '2,547',
                          Icons.people_outline,
                          AppColors.primary,
                        ),
                        _buildStatCard(
                          'Football Venues',
                          '145',
                          Icons.sports_soccer,
                          AppColors.secondary,
                        ),
                        _buildStatCard(
                          'Match Bookings',
                          '8,934',
                          Icons.calendar_today_outlined,
                          AppColors.success,
                        ),
                        _buildStatCard(
                          'Total Income',
                          '৳12,45,000',
                          Icons.monetization_on_outlined,
                          AppColors.warning,
                        ),
                      ],
                    ),

                    SizedBox(height: 32),

                    // Recent Activity Section
                    Container(
                      width: double.infinity,
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
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 20),
                            ..._buildActivityList(),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    // Quick Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickStatCard(
                            'Today\'s Matches',
                            '47',
                            Icons.sports_soccer,
                            AppColors.info,
                          ),
                        ),
                        SizedBox(width: 18),
                        Expanded(
                          child: _buildQuickStatCard(
                            'Total Income',
                            '৳2.5L',
                            Icons.monetization_on_outlined,
                            AppColors.success,
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
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActivityList() {
    final activities = [
      {
        'title': 'New football ground "Dhanmondi Football Complex" added',
        'time': '2 minutes ago',
        'icon': Icons.sports_soccer,
        'color': AppColors.primary,
      },
      {
        'title': 'Player "Ahmed Rahman" completed match booking',
        'time': '15 minutes ago',
        'icon': Icons.check_circle_outline,
        'color': AppColors.success,
      },
      {
        'title': 'Football tournament fee ৳2,500 received',
        'time': '1 hour ago',
        'icon': Icons.payment_outlined,
        'color': AppColors.warning,
      },
      {
        'title': 'New football venue registration completed',
        'time': '2 hours ago',
        'icon': Icons.sports_soccer,
        'color': AppColors.success,
      },
      {
        'title': 'Football league weekly report generated',
        'time': '1 day ago',
        'icon': Icons.analytics_outlined,
        'color': AppColors.secondary,
      },
    ];

    return activities.map((activity) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (activity['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                activity['icon'] as IconData,
                color: activity['color'] as Color,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    activity['time'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
