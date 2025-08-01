import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _currentPage = 1;
  final int _itemsPerPage = 8;
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final filteredEvents = _getFilteredEvents();
    final totalPages = (filteredEvents.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(
      0,
      filteredEvents.length,
    );
    final currentPageEvents = filteredEvents.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMobile ? 'Tournaments' : 'Tournament Management',
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isMobile
                            ? 'Manage all tournaments'
                            : 'Monitor and track all futsal tournaments and competitions',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Export Button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _showExportDialog(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.download_outlined,
                          color: Colors.white,
                          size: isMobile ? 18 : 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Export',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 20 : 32),

            // Stats Cards (Clickable Filters)
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 2 : 4,
              childAspectRatio: isMobile ? 1.3 : 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Total Tournaments',
                  '${_demoEvents.length}',
                  Icons.emoji_events,
                  Colors.blue[600]!,
                  isMobile,
                  'All',
                ),
                _buildStatCard(
                  'Active Tournaments',
                  '${_demoEvents.where((e) => e['status'] == 'Active').length}',
                  Icons.event_available,
                  Colors.green[600]!,
                  isMobile,
                  'Active',
                ),
                _buildStatCard(
                  'Completed Tournaments',
                  '${_demoEvents.where((e) => e['status'] == 'Completed').length}',
                  Icons.done_all_outlined,
                  Colors.purple[600]!,
                  isMobile,
                  'Completed',
                ),
                _buildStatCard(
                  'Upcoming Tournaments',
                  '${_demoEvents.where((e) => e['status'] == 'Upcoming').length}',
                  Icons.schedule_outlined,
                  Colors.orange[600]!,
                  isMobile,
                  'Upcoming',
                ),
              ],
            ),

            SizedBox(height: isMobile ? 20 : 24),

            // Events List
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // List Header
                  Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isMobile
                              ? 'Recent Tournaments'
                              : 'Futsal Tournament History',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Showing ${startIndex + 1}-${endIndex} of ${filteredEvents.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Events List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: currentPageEvents.length,
                    separatorBuilder:
                        (context, index) =>
                            Divider(color: AppColors.borderLight, height: 1),
                    itemBuilder: (context, index) {
                      return _buildEventListItem(
                        currentPageEvents[index],
                        isMobile,
                      );
                    },
                  ),

                  // Pagination
                  if (totalPages > 1)
                    Container(
                      padding: EdgeInsets.all(isMobile ? 16 : 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Previous Button
                          IconButton(
                            onPressed:
                                _currentPage > 1
                                    ? () => setState(() => _currentPage--)
                                    : null,
                            icon: Icon(Icons.chevron_left),
                            color:
                                _currentPage > 1
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                          ),

                          // Page Numbers
                          ...List.generate(totalPages, (index) {
                            final page = index + 1;
                            final isCurrentPage = page == _currentPage;
                            return InkWell(
                              onTap: () => setState(() => _currentPage = page),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isCurrentPage
                                          ? AppColors.primary
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        isCurrentPage
                                            ? AppColors.primary
                                            : AppColors.borderLight,
                                  ),
                                ),
                                child: Text(
                                  '$page',
                                  style: TextStyle(
                                    color:
                                        isCurrentPage
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                    fontWeight:
                                        isCurrentPage
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Next Button
                          IconButton(
                            onPressed:
                                _currentPage < totalPages
                                    ? () => setState(() => _currentPage++)
                                    : null,
                            icon: Icon(Icons.chevron_right),
                            color:
                                _currentPage < totalPages
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 40), // Bottom spacing
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
    bool isMobile,
    String filterStatus,
  ) {
    final isSelected = _selectedStatus == filterStatus;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = filterStatus;
          _currentPage = 1; // Reset to first page when filter changes
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              isSelected
                  ? Border.all(color: color, width: 3)
                  : Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected ? color.withOpacity(0.2) : AppColors.shadowLight,
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: isMobile ? 20 : 24),
            ),
            SizedBox(height: isMobile ? 8 : 10),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 2),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventListItem(Map<String, dynamic> event, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Row(
        children: [
          // Event Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event['name'],
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: isMobile ? 2 : 1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getEventStatusColor(
                          event['status'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event['status'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getEventStatusColor(event['status']),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Tournament at ${event['venue']} • ${event['participants']} participants • ${event['playersPerTeam']} per team',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 8),
                // Mobile: Stack vertically, Desktop: Row
                isMobile
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${event['date']} at ${event['startTime']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${event['duration']} hours duration',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(
                              Icons.groups_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${event['participants']} players',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getEventTypeColor(
                              event['type'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'By ${event['owner']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getEventTypeColor(event['type']),
                            ),
                          ),
                        ),
                      ],
                    )
                    : Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${event['date']} at ${event['startTime']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(
                          Icons.schedule_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${event['duration']}h',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(
                          Icons.groups_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${event['participants']} players',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getEventTypeColor(
                              event['type'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'By ${event['owner']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getEventTypeColor(event['type']),
                            ),
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          // Show Details Button
          InkWell(
            onTap: () => _showEventDetails(event),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 12,
                vertical: isMobile ? 4 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child:
                  isMobile
                      ? Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: AppColors.primary,
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredEvents() {
    List<Map<String, dynamic>> filtered = _demoEvents;

    // Filter by status
    if (_selectedStatus != 'All') {
      filtered =
          filtered
              .where((event) => event['status'] == _selectedStatus)
              .toList();
    }

    // Filter by date range
    if (_startDate != null || _endDate != null) {
      filtered =
          filtered.where((event) {
            DateTime eventDate = DateTime.parse(event['date']);

            if (_startDate != null && eventDate.isBefore(_startDate!)) {
              return false;
            }

            if (_endDate != null &&
                eventDate.isAfter(_endDate!.add(Duration(days: 1)))) {
              return false;
            }

            return true;
          }).toList();
    }

    return filtered;
  }

  void _showEventDetails(Map<String, dynamic> event) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
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
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tournament Details',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        event['name'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getEventStatusColor(
                      event['status'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event['status'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getEventStatusColor(event['status']),
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Container(
            padding: EdgeInsets.all(16),
            width: isMobile ? double.maxFinite : 400,
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection('Tournament Information', [
                    _buildDetailItem(
                      'Tournament Name',
                      event['name'],
                      Icons.emoji_events,
                    ),
                    _buildDetailItem(
                      'Tournament Type',
                      event['type'],
                      Icons.category,
                    ),
                    _buildDetailItem(
                      'Status',
                      event['status'],
                      Icons.info_outline,
                    ),
                    _buildDetailItem(
                      'Created By',
                      event['owner'],
                      Icons.person_outline,
                    ),
                  ], isMobile),
                  SizedBox(height: 16),
                  _buildDetailSection('Tournament Setup', [
                    _buildDetailItem(
                      'Total Participants',
                      '${event['participants']} players',
                      Icons.groups,
                    ),
                    _buildDetailItem(
                      'Players per Team',
                      '${event['playersPerTeam']} players',
                      Icons.sports_soccer,
                    ),
                    _buildDetailItem(
                      'Duration',
                      '${event['duration']} hours',
                      Icons.schedule,
                    ),
                  ], isMobile),
                  SizedBox(height: 16),
                  _buildDetailSection('Venue Details', [
                    _buildDetailItem(
                      'Venue',
                      event['venue'],
                      Icons.location_on,
                    ),
                    _buildDetailItem(
                      'Date',
                      event['date'],
                      Icons.calendar_today,
                    ),
                    _buildDetailItem(
                      'Start Time',
                      event['startTime'],
                      Icons.access_time,
                    ),
                  ], isMobile),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.download_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Export Tournaments',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              content: Container(
                width: isMobile ? double.maxFinite : 450,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Export Format Options
                      Text(
                        'Export Format',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Choose your preferred export format for tournaments',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Export Options Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildExportOption(
                              'Excel',
                              Icons.table_chart,
                              Colors.green[600]!,
                              'Spreadsheet format',
                              () => _exportToExcel(),
                              isMobile,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildExportOption(
                              'PDF',
                              Icons.picture_as_pdf,
                              Colors.red[600]!,
                              'Document format',
                              () => _exportToPDF(),
                              isMobile,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Filter Section
                      Text(
                        'Filter Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Status Filter
                      Text(
                        'Tournament Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.surface,
                        ),
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          isExpanded: true,
                          underline: SizedBox(),
                          icon: Icon(
                            Icons.expand_more,
                            color: AppColors.textSecondary,
                          ),
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'All',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    size: 18,
                                    color: Colors.blue[600],
                                  ),
                                  SizedBox(width: 8),
                                  Text('All Tournaments'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Active',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    size: 18,
                                    color: Colors.green[600],
                                  ),
                                  SizedBox(width: 8),
                                  Text('Active Tournaments'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Completed',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.done_all,
                                    size: 18,
                                    color: Colors.purple[600],
                                  ),
                                  SizedBox(width: 8),
                                  Text('Completed Tournaments'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Upcoming',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 18,
                                    color: Colors.orange[600],
                                  ),
                                  SizedBox(width: 8),
                                  Text('Upcoming Tournaments'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setDialogState(() {
                                _selectedStatus = newValue;
                              });
                            }
                          },
                        ),
                      ),

                      SizedBox(height: 16),

                      // Time Period Filters
                      Text(
                        'Time Period',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTimePeriodChip('Today', () {
                            setDialogState(() {
                              _startDate = DateTime.now();
                              _endDate = DateTime.now();
                            });
                          }),
                          _buildTimePeriodChip('This Week', () {
                            final now = DateTime.now();
                            final startOfWeek = now.subtract(
                              Duration(days: now.weekday - 1),
                            );
                            setDialogState(() {
                              _startDate = startOfWeek;
                              _endDate = now;
                            });
                          }),
                          _buildTimePeriodChip('This Month', () {
                            final now = DateTime.now();
                            setDialogState(() {
                              _startDate = DateTime(now.year, now.month, 1);
                              _endDate = now;
                            });
                          }),
                          _buildTimePeriodChip('All Time', () {
                            setDialogState(() {
                              _startDate = null;
                              _endDate = null;
                            });
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildExportOption(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
    bool isMobile,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isMobile ? 28 : 32),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePeriodChip(String label, VoidCallback onTap) {
    final isSelected = _getTimePeriodSelection(label);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1.5,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool _getTimePeriodSelection(String label) {
    final now = DateTime.now();

    switch (label) {
      case 'Today':
        return _startDate != null &&
            _endDate != null &&
            _startDate!.year == now.year &&
            _startDate!.month == now.month &&
            _startDate!.day == now.day &&
            _endDate!.year == now.year &&
            _endDate!.month == now.month &&
            _endDate!.day == now.day;

      case 'This Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return _startDate != null &&
            _endDate != null &&
            _startDate!.year == startOfWeek.year &&
            _startDate!.month == startOfWeek.month &&
            _startDate!.day == startOfWeek.day;

      case 'This Month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        return _startDate != null &&
            _endDate != null &&
            _startDate!.year == startOfMonth.year &&
            _startDate!.month == startOfMonth.month &&
            _startDate!.day == startOfMonth.day;

      case 'All Time':
        return _startDate == null && _endDate == null;

      default:
        return false;
    }
  }

  void _exportToExcel() async {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tournaments exported to Excel successfully!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
          textColor: Colors.white,
        ),
      ),
    );
  }

  void _exportToPDF() async {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tournaments exported to PDF successfully!'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
          textColor: Colors.white,
        ),
      ),
    );
  }

  Color _getEventTypeColor(String type) {
    switch (type) {
      case 'Tournament':
        return Colors.green[600]!;
      case 'League':
        return AppColors.primary;
      case 'Training':
        return Colors.blue[600]!;
      case 'Match':
        return Colors.orange[600]!;
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
        return Colors.green[600]!;
      case 'Upcoming':
        return Colors.orange[600]!;
      case 'Completed':
        return Colors.purple[600]!;
      default:
        return AppColors.textSecondary;
    }
  }

  static final List<Map<String, dynamic>> _demoEvents = [
    {
      'name': 'Inter-College Futsal Tournament',
      'venue': 'Green Valley Futsal Complex',
      'date': '2024-07-25',
      'startTime': '09:00 AM',
      'duration': 6,
      'participants': 32,
      'playersPerTeam': 5,
      'status': 'Active',
      'type': 'Tournament',
      'venueImage': 'assets/images/venue1.jpg',
      'owner': 'Green Valley Sports Club',
    },
    {
      'name': 'Premier Futsal Tournament 2024',
      'venue': 'National Futsal Stadium',
      'date': '2024-07-28',
      'startTime': '10:00 AM',
      'duration': 8,
      'participants': 64,
      'playersPerTeam': 5,
      'status': 'Active',
      'type': 'Tournament',
      'venueImage': 'assets/images/venue2.jpg',
      'owner': 'National Sports Authority',
    },
    {
      'name': 'Youth Futsal Championship',
      'venue': 'Elite Futsal Academy',
      'date': '2024-07-30',
      'startTime': '08:00 AM',
      'duration': 5,
      'participants': 24,
      'playersPerTeam': 5,
      'status': 'Active',
      'type': 'Tournament',
      'venueImage': 'assets/images/venue3.jpg',
      'owner': 'Elite Futsal Academy',
    },
    {
      'name': 'Dhaka vs Chittagong Futsal Cup',
      'venue': 'Bangabandhu Futsal Arena',
      'date': '2024-08-02',
      'startTime': '03:00 PM',
      'duration': 4,
      'participants': 16,
      'playersPerTeam': 5,
      'status': 'Completed',
      'type': 'Tournament',
      'venueImage': 'assets/images/venue4.jpg',
      'owner': 'Bangladesh Futsal Federation',
    },
    {
      'name': 'School Futsal Championship',
      'venue': 'Dhanmondi Futsal Ground',
      'date': '2024-08-05',
      'startTime': '02:00 PM',
      'duration': 6,
      'participants': 20,
      'playersPerTeam': 5,
      'status': 'Active',
      'type': 'Tournament',
      'venueImage': 'assets/images/venue5.jpg',
      'owner': 'Dhaka School Sports Committee',
    },
    {
      'name': 'Professional Futsal League',
      'venue': 'Sylhet District Futsal Arena',
      'date': '2024-08-10',
      'startTime': '11:00 AM',
      'duration': 7,
      'participants': 48,
      'playersPerTeam': 5,
      'status': 'Completed',
      'type': 'Tournament',
      'venueImage': 'assets/images/venue6.jpg',
      'owner': 'Sylhet Futsal Association',
    },
    {
      'name': 'District Futsal Championship',
      'venue': 'BKSP Futsal Ground',
      'date': '2024-08-12',
      'startTime': '09:30 AM',
      'duration': 5,
      'participants': 28,
      'playersPerTeam': 5,
      'status': 'Active',
      'type': 'Tournament',
      'venueImage': 'assets/images/venue7.jpg',
      'owner': 'BKSP Sports Authority',
    },
    {
      'name': 'Division Futsal Tournament Final',
      'venue': 'Rajshahi Divisional Futsal Court',
      'date': '2024-08-15',
      'startTime': '04:00 PM',
      'duration': 3,
      'participants': 8,
      'playersPerTeam': 5,
      'status': 'Active',
      'type': 'Tournament',
      'venueImage': 'assets/images/venue8.jpg',
      'owner': 'Rajshahi Sports Council',
    },
    {
      'name': 'Women Futsal Tournament',
      'venue': 'Jessore Futsal Arena',
      'date': '2024-08-18',
      'startTime': '01:00 PM',
      'duration': 4,
      'participants': 16,
      'playersPerTeam': 5,
      'status': 'Completed',
      'type': 'Tournament',
      'venueImage': 'assets/images/venue9.jpg',
      'owner': 'Women Futsal Association',
    },
    {
      'name': 'Corporate Futsal Tournament',
      'venue': 'Uttara Futsal Complex',
      'date': '2024-08-22',
      'startTime': '10:30 AM',
      'duration': 6,
      'participants': 32,
      'playersPerTeam': 5,
      'status': 'Active',
      'type': 'Tournament',
      'venueImage': 'assets/images/venue10.jpg',
      'owner': 'Corporate Sports League',
    },
    {
      'name': 'National Futsal Championship',
      'venue': 'Chittagong MA Aziz Futsal Hall',
      'date': '2024-08-28',
      'startTime': '12:00 PM',
      'duration': 8,
      'participants': 64,
      'playersPerTeam': 5,
      'status': 'Upcoming',
      'type': 'Tournament',
      'venueImage': 'assets/images/venue11.jpg',
      'owner': 'Bangladesh Futsal Federation',
    },
    {
      'name': 'Under-18 Futsal Tournament',
      'venue': 'Mymensingh Futsal Court',
      'date': '2024-09-02',
      'startTime': '08:30 AM',
      'duration': 5,
      'participants': 24,
      'playersPerTeam': 5,
      'status': 'Upcoming',
      'type': 'Tournament',
      'venueImage': 'assets/images/venue12.jpg',
      'owner': 'Youth Sports Development',
    },
    {
      'name': 'International Futsal Cup',
      'venue': 'BFF Futsal Training Center',
      'date': '2024-09-05',
      'startTime': '02:30 PM',
      'duration': 4,
      'participants': 16,
      'playersPerTeam': 5,
      'status': 'Upcoming',
      'type': 'Tournament',
      'venueImage': 'assets/images/venue13.jpg',
      'owner': 'International Futsal Committee',
    },
  ];
}
