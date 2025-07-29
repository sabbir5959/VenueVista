import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AdminPaymentsPage extends StatefulWidget {
  const AdminPaymentsPage({super.key});

  @override
  State<AdminPaymentsPage> createState() => _AdminPaymentsPageState();
}

class _AdminPaymentsPageState extends State<AdminPaymentsPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _currentPage = 1;
  final int _itemsPerPage = 8;
  String _selectedPaymentType = 'All';
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final filteredPayments = _getFilteredPayments();
    final totalPages = (filteredPayments.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(
      0,
      filteredPayments.length,
    );
    final currentPagePayments = filteredPayments.sublist(startIndex, endIndex);

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
                        isMobile ? 'Payments' : 'Payment Management',
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
                            ? 'Manage all payments'
                            : 'Track payments from users and to venue owners',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 16 : 24),

            // Payment Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Received',
                    '৳${_calculateTotalReceived()}',
                    Icons.south_east,
                    Colors.green[600]!,
                    'From users',
                    isMobile,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Paid',
                    '৳${_calculateTotalPaid()}',
                    Icons.north_east,
                    Colors.red[600]!,
                    'To owners',
                    isMobile,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Refunded',
                    '৳${_calculateTotalRefunded()}',
                    Icons.undo,
                    Colors.orange[600]!,
                    'Refund processed',
                    isMobile,
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 16 : 20),

            // Filter Section
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Payments',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        'All Payments',
                        'All',
                        _selectedPaymentType,
                        (value) {
                          setState(() {
                            _selectedPaymentType = value;
                            _selectedStatus = 'All';
                            _currentPage = 1;
                          });
                        },
                      ),
                      _buildFilterChip(
                        'From Users',
                        'From User',
                        _selectedPaymentType,
                        (value) {
                          setState(() {
                            _selectedPaymentType = value;
                            _selectedStatus = 'All';
                            _currentPage = 1;
                          });
                        },
                      ),
                      _buildFilterChip(
                        'To Owners',
                        'To Owner',
                        _selectedPaymentType,
                        (value) {
                          setState(() {
                            _selectedPaymentType = value;
                            _selectedStatus = 'All';
                            _currentPage = 1;
                          });
                        },
                      ),
                      _buildFilterChip(
                        'Refunds',
                        'Refund',
                        _selectedPaymentType,
                        (value) {
                          setState(() {
                            _selectedPaymentType = value;
                            _selectedStatus = 'All';
                            _currentPage = 1;
                          });
                        },
                      ),
                      _buildFilterChip(
                        'Completed',
                        'Completed',
                        _selectedStatus,
                        (value) {
                          setState(() {
                            _selectedStatus = value;
                            _currentPage = 1;
                          });
                        },
                      ),
                      _buildFilterChip(
                        'Processing',
                        'Processing',
                        _selectedStatus,
                        (value) {
                          setState(() {
                            _selectedStatus = value;
                            _currentPage = 1;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // Payments List
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
                              ? 'Payment History'
                              : 'All Payment Transactions',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Showing ${startIndex + 1}-${endIndex} of ${filteredPayments.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Payments List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: currentPagePayments.length,
                    separatorBuilder:
                        (context, index) =>
                            Divider(color: AppColors.borderLight, height: 1),
                    itemBuilder: (context, index) {
                      return _buildPaymentListItem(
                        currentPagePayments[index],
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

  Widget _buildSummaryCard(
    String title,
    String amount,
    IconData icon,
    Color color,
    String subtitle,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
              Icon(Icons.trending_up, color: color, size: 16),
            ],
          ),
          SizedBox(height: 12),
          Text(
            amount,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String currentValue,
    Function(String) onTap,
  ) {
    final isSelected = currentValue == value;

    return InkWell(
      onTap: () => onTap(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentListItem(Map<String, dynamic> payment, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Row(
        children: [
          // Payment Type Icon
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getPaymentTypeColor(payment['type']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPaymentTypeIcon(payment['type']),
              color: _getPaymentTypeColor(payment['type']),
              size: isMobile ? 20 : 24,
            ),
          ),
          SizedBox(width: 16),

          // Payment Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        payment['description'],
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPaymentStatusColor(
                          payment['status'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        payment['status'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getPaymentStatusColor(payment['status']),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  '${payment['type']} • ${payment['method']} • ${payment['person']}',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      payment['date'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      payment['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '৳${payment['amount']}',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w700,
                        color:
                            payment['type'] == 'From User'
                                ? Colors.green[600]
                                : Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),

          // Details Button
          InkWell(
            onTap: () => _showPaymentDetails(payment),
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

  List<Map<String, dynamic>> _getFilteredPayments() {
    List<Map<String, dynamic>> filtered = _demoPayments;

    // Filter by payment type
    if (_selectedPaymentType != 'All') {
      filtered =
          filtered
              .where((payment) => payment['type'] == _selectedPaymentType)
              .toList();
    }

    // Filter by status
    if (_selectedStatus != 'All') {
      filtered =
          filtered
              .where((payment) => payment['status'] == _selectedStatus)
              .toList();
    }

    // Filter by date range
    if (_startDate != null || _endDate != null) {
      filtered =
          filtered.where((payment) {
            DateTime paymentDate = DateTime.parse(payment['date']);

            if (_startDate != null && paymentDate.isBefore(_startDate!)) {
              return false;
            }

            if (_endDate != null &&
                paymentDate.isAfter(_endDate!.add(Duration(days: 1)))) {
              return false;
            }

            return true;
          }).toList();
    }

    return filtered;
  }

  String _calculateTotalReceived() {
    return _demoPayments
        .where((p) => p['type'] == 'From User' && p['status'] == 'Completed')
        .fold(0, (sum, p) => sum + (p['amount'] as int))
        .toString();
  }

  String _calculateTotalPaid() {
    return _demoPayments
        .where((p) => p['type'] == 'To Owner' && p['status'] == 'Completed')
        .fold(0, (sum, p) => sum + (p['amount'] as int))
        .toString();
  }

  String _calculateTotalRefunded() {
    return _demoPayments
        .where((p) => p['type'] == 'Refund' && p['status'] == 'Completed')
        .fold(0, (sum, p) => sum + (p['amount'] as int))
        .toString();
  }

  Color _getPaymentTypeColor(String type) {
    switch (type) {
      case 'From User':
        return Colors.green[600]!;
      case 'To Owner':
        return Colors.orange[600]!;
      case 'Refund':
        return Colors.red[600]!;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getPaymentTypeIcon(String type) {
    switch (type) {
      case 'From User':
        return Icons.south_east;
      case 'To Owner':
        return Icons.north_east;
      case 'Refund':
        return Icons.undo;
      default:
        return Icons.payment;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green[600]!;
      case 'Processing':
        return Colors.blue[600]!;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
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
                    color: _getPaymentTypeColor(
                      payment['type'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getPaymentTypeIcon(payment['type']),
                    color: _getPaymentTypeColor(payment['type']),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Details',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        payment['description'],
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
                    color: _getPaymentStatusColor(
                      payment['status'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payment['status'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getPaymentStatusColor(payment['status']),
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Container(
            padding: EdgeInsets.all(16),
            width: isMobile ? double.maxFinite : 400,
            height: MediaQuery.of(context).size.height * 0.5,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentDetailSection('Payment Information', [
                    _buildPaymentDetailItem(
                      'Amount',
                      '৳${payment['amount']}',
                      Icons.monetization_on,
                    ),
                    _buildPaymentDetailItem(
                      'Type',
                      payment['type'],
                      Icons.swap_horiz,
                    ),
                    _buildPaymentDetailItem(
                      'Status',
                      payment['status'],
                      Icons.info_outline,
                    ),
                    _buildPaymentDetailItem(
                      'Method',
                      payment['method'],
                      Icons.payment,
                    ),
                  ], isMobile),
                  SizedBox(height: 16),
                  _buildPaymentDetailSection('Transaction Details', [
                    _buildPaymentDetailItem(
                      'Date',
                      payment['date'],
                      Icons.calendar_today,
                    ),
                    _buildPaymentDetailItem(
                      'Time',
                      payment['time'],
                      Icons.access_time,
                    ),
                    _buildPaymentDetailItem(
                      'Transaction ID',
                      payment['transactionId'],
                      Icons.receipt_long,
                    ),
                  ], isMobile),
                  SizedBox(height: 16),
                  _buildPaymentDetailSection('Party Details', [
                    _buildPaymentDetailItem(
                      'Person',
                      payment['person'],
                      Icons.person,
                    ),
                    _buildPaymentDetailItem(
                      'Contact',
                      payment['contact'],
                      Icons.phone,
                    ),
                    _buildPaymentDetailItem(
                      'Description',
                      payment['description'],
                      Icons.description,
                    ),
                  ], isMobile),

                  // Refund-specific details
                  if (payment['type'] == 'Refund') ...[
                    SizedBox(height: 16),
                    _buildPaymentDetailSection('Refund Details', [
                      if (payment['bookingId'] != null)
                        _buildPaymentDetailItem(
                          'Booking ID',
                          payment['bookingId'],
                          Icons.bookmark_outline,
                        ),
                      if (payment['reason'] != null)
                        _buildPaymentDetailItem(
                          'Reason',
                          payment['reason'],
                          Icons.help_outline,
                        ),
                      if (payment['refundFee'] != null)
                        _buildPaymentDetailItem(
                          'Processing Fee',
                          payment['refundFee'] == 0
                              ? 'Free'
                              : '৳${payment['refundFee']}',
                          Icons.account_balance_wallet_outlined,
                        ),
                    ], isMobile),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            // Show refund action buttons for refunds in processing status
            if (payment['type'] == 'Refund' &&
                payment['status'] == 'Processing') ...[
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _completeRefund(payment);
                },
                icon: Icon(Icons.check, size: 16),
                label: Text('Mark Complete'),
                style: TextButton.styleFrom(foregroundColor: Colors.green[700]),
              ),
            ],
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

  Widget _buildPaymentDetailSection(
    String title,
    List<Widget> items,
    bool isMobile,
  ) {
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

  Widget _buildPaymentDetailItem(String label, String value, IconData icon) {
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

  static final List<Map<String, dynamic>> _demoPayments = [
    {
      'id': 'PAY001',
      'description': 'Tournament booking payment',
      'amount': 1500,
      'type': 'From User',
      'status': 'Completed',
      'method': 'bKash',
      'person': 'Md. Rahman',
      'contact': '+8801712345678',
      'date': '2024-07-25',
      'time': '10:30 AM',
      'transactionId': 'BKS2024072501',
    },
    {
      'id': 'PAY002',
      'description': 'Venue commission payment',
      'amount': 3000,
      'type': 'To Owner',
      'status': 'Completed',
      'method': 'Bank Transfer',
      'person': 'Green Valley Sports Club',
      'contact': '+8801876543210',
      'date': '2024-07-24',
      'time': '02:15 PM',
      'transactionId': 'BT2024072402',
    },
    {
      'id': 'PAY003',
      'description': 'Futsal court booking',
      'amount': 800,
      'type': 'From User',
      'status': 'Completed',
      'method': 'Nagad',
      'person': 'Salam Ahmed',
      'contact': '+8801534567890',
      'date': '2024-07-26',
      'time': '09:45 AM',
      'transactionId': 'NGD2024072603',
    },
    {
      'id': 'PAY004',
      'description': 'Monthly venue payment',
      'amount': 5000,
      'type': 'To Owner',
      'status': 'Completed',
      'method': 'bKash',
      'person': 'Elite Futsal Academy',
      'contact': '+8801698765432',
      'date': '2024-07-27',
      'time': '11:20 AM',
      'transactionId': 'BKS2024072704',
    },
    {
      'id': 'PAY005',
      'description': 'Tournament entry fee',
      'amount': 2000,
      'type': 'From User',
      'status': 'Completed',
      'method': 'Rocket',
      'person': 'Karim Uddin',
      'contact': '+8801723456789',
      'date': '2024-07-23',
      'time': '03:30 PM',
      'transactionId': 'RKT2024072305',
    },
    {
      'id': 'PAY006',
      'description': 'Equipment rental payment',
      'amount': 1200,
      'type': 'To Owner',
      'status': 'Completed',
      'method': 'Cash',
      'person': 'BKSP Sports Authority',
      'contact': '+8801812345678',
      'date': '2024-07-22',
      'time': '04:45 PM',
      'transactionId': 'CSH2024072206',
    },
    {
      'id': 'PAY007',
      'description': 'League registration',
      'amount': 1800,
      'type': 'From User',
      'status': 'Completed',
      'method': 'bKash',
      'person': 'Nasir Hossain',
      'contact': '+8801656789012',
      'date': '2024-07-28',
      'time': '12:15 PM',
      'transactionId': 'BKS2024072807',
    },
    {
      'id': 'PAY008',
      'description': 'Facility maintenance fee',
      'amount': 2500,
      'type': 'To Owner',
      'status': 'Completed',
      'method': 'Bank Transfer',
      'person': 'Dhanmondi Futsal Ground',
      'contact': '+8801789012345',
      'date': '2024-07-21',
      'time': '01:00 PM',
      'transactionId': 'BT2024072108',
    },
    {
      'id': 'PAY009',
      'description': 'Training session payment',
      'amount': 600,
      'type': 'From User',
      'status': 'Completed',
      'method': 'Nagad',
      'person': 'Habib Rahman',
      'contact': '+8801567890123',
      'date': '2024-07-29',
      'time': 'AM',
      'transactionId': 'NGD2024072909',
    },
    {
      'id': 'PAY010',
      'description': 'Tournament prize money',
      'amount': 4000,
      'type': 'To Owner',
      'status': 'Completed',
      'method': 'bKash',
      'person': 'Rajshahi Sports Council',
      'contact': '+8801890123456',
      'date': '2024-07-30',
      'time': '05:20 PM',
      'transactionId': 'BKS2024073010',
    },
    // Refund Transactions
    {
      'id': 'REF001',
      'description': 'Refund: Chittagong Football Stadium booking cancellation',
      'amount': 5500,
      'type': 'Refund',
      'status': 'Completed',
      'method': 'bKash',
      'person': 'Ruhul Amin',
      'contact': '+8801723456789',
      'date': '2024-07-24',
      'time': '03:15 PM',
      'transactionId': 'REF2024072401',
      'bookingId': 'BK009',
      'reason': 'Customer requested due to emergency',
      'refundFee': 50, // 1% refund processing fee
    },
    {
      'id': 'REF002',
      'description': 'Refund: University Football Field booking cancellation',
      'amount': 900,
      'type': 'Refund',
      'status': 'Completed',
      'method': 'Nagad',
      'person': 'Salma Khatun',
      'contact': '+8801534567890',
      'date': '2024-07-18',
      'time': '11:45 AM',
      'transactionId': 'REF2024071802',
      'bookingId': 'BK006',
      'reason': 'Weather conditions - venue closed',
      'refundFee': 0, // No fee for venue-caused cancellation
    },
    {
      'id': 'REF003',
      'description': 'Refund: Rajshahi Football Complex booking cancellation',
      'amount': 3200,
      'type': 'Refund',
      'status': 'Processing',
      'method': 'Bank Transfer',
      'person': 'Mizanur Rahman',
      'contact': '+8801876543210',
      'date': '2024-07-29',
      'time': '02:30 PM',
      'transactionId': 'REF2024072903',
      'bookingId': 'BK013',
      'reason': 'Double booking error - venue issue',
      'refundFee': 0, // No fee for venue error
    },
    {
      'id': 'REF004',
      'description': 'Refund: Training session cancellation',
      'amount': 750,
      'type': 'Refund',
      'status': 'Processing',
      'method': 'bKash',
      'person': 'Ahmed Hassan',
      'contact': '+8801698765432',
      'date': '2024-07-30',
      'time': '04:20 PM',
      'transactionId': 'REF2024073004',
      'bookingId': 'BK016',
      'reason': 'Customer illness - medical emergency',
      'refundFee': 25, // Reduced fee for medical reasons
    },
  ];

  void _completeRefund(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700]),
              SizedBox(width: 8),
              Text('Complete Refund'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mark this refund as completed?'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refund Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Amount: ৳${payment['amount']}'),
                    Text('To: ${payment['person']}'),
                    Text('Method: ${payment['method']}'),
                    if (payment['bookingId'] != null)
                      Text('Booking: ${payment['bookingId']}'),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                '⚠️ This action cannot be undone',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  // In a real app, this would update the database
                  final index = _demoPayments.indexWhere(
                    (p) => p['id'] == payment['id'],
                  );
                  if (index != -1) {
                    _demoPayments[index]['status'] = 'Completed';
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Refund marked as completed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(
                'Mark Complete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
