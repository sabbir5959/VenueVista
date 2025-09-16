import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPaymentService {
  static final _client = Supabase.instance.client;

  /// Fast method to get pending payments count only
  static Future<int> getPendingPaymentsCount() async {
    try {
      final response = await _client
          .from('payments')
          .select('id')
          .eq('payment_status', 'pending');

      return (response as List).length;
    } catch (e) {
      print('Error getting pending payments count: $e');
      return 0;
    }
  }

  /// Fast method to get pending refunds count only
  static Future<int> getPendingRefundsCount() async {
    try {
      final response = await _client
          .from('cancellations')
          .select('id')
          .isFilter('refund_processed_at', null);

      return (response as List).length;
    } catch (e) {
      print('Error getting pending refunds count: $e');
      return 0;
    }
  }

  /// Get all payments for admin dashboard
  static Future<List<Map<String, dynamic>>> getAllPayments() async {
    try {
      // Get regular payments
      final paymentsResponse = await _client
          .from('payments')
          .select('''
            *,
            user_profiles!user_id (full_name, email, phone)
          ''')
          .order('created_at', ascending: false);

      // Get completed refunds from cancellations table
      final refundsResponse = await _client
          .from('cancellations')
          .select('''
            id,
            user_id,
            venue_name,
            original_amount,
            refund_amount,
            cancellation_reason,
            refund_processed_at,
            admin_notes,
            created_at
          ''')
          .eq('refund_status', 'completed')
          .order('refund_processed_at', ascending: false);

      // Get user profiles for refunds separately
      Map<String, Map<String, dynamic>> userProfiles = {};
      if (refundsResponse.isNotEmpty) {
        final userIds =
            refundsResponse.map((r) => r['user_id'] as String).toSet().toList();

        final profiles = await _client
            .from('user_profiles')
            .select('id, full_name, email, phone')
            .filter('id', 'in', '(${userIds.join(',')})');

        for (final profile in profiles) {
          userProfiles[profile['id']] = profile;
        }
      }

      // Convert payments to standard format
      List<Map<String, dynamic>> allTransactions = [];

      // Add regular payments
      for (final payment in paymentsResponse) {
        allTransactions.add({
          ...payment,
          'transaction_type': 'payment',
          'display_type': _getPaymentDisplayType(payment),
        });
      }

      // Add completed refunds
      for (final refund in refundsResponse) {
        final userId = refund['user_id'] as String;
        final userProfile = userProfiles[userId];

        allTransactions.add({
          'id': refund['id'],
          'payment_id': 'REFUND-${refund['id'].toString().substring(0, 8)}',
          'user_id': refund['user_id'],
          'amount': refund['refund_amount'] ?? refund['original_amount'],
          'payment_method': 'Refund',
          'payment_status': 'completed',
          'transaction_reference': 'Refund: ${refund['venue_name']}',
          'created_at': refund['refund_processed_at'] ?? refund['created_at'],
          'user_profiles': userProfile,
          'transaction_type': 'refund',
          'display_type': 'refund',
          'venue_name': refund['venue_name'],
          'cancellation_reason': refund['cancellation_reason'],
          'admin_notes': refund['admin_notes'],
        });
      }

      // Sort all transactions by date (newest first)
      allTransactions.sort((a, b) {
        final dateA = DateTime.parse(a['created_at']);
        final dateB = DateTime.parse(b['created_at']);
        return dateB.compareTo(dateA);
      });

      return allTransactions;
    } catch (e) {
      print('❌ Error fetching all payments and refunds: $e');
      return [];
    }
  }

  /// Helper method to determine payment display type
  static String _getPaymentDisplayType(Map<String, dynamic> payment) {
    final paymentId = payment['payment_id'] as String?;
    if (paymentId != null && paymentId.startsWith('REF')) {
      return 'refund';
    }
    return 'user'; // Default for regular user payments
  }

  /// Get payment statistics for admin
  static Future<Map<String, dynamic>> getPaymentStats() async {
    try {
      // Total received from users (excluding refunds)
      final receivedResponse = await _client
          .from('payments')
          .select('amount, payment_id')
          .eq('payment_status', 'completed');

      double totalReceived = 0.0;
      double totalRefunded = 0.0;

      for (final payment in receivedResponse) {
        final amount = payment['amount'];
        final paymentId = payment['payment_id'] ?? '';

        if (amount != null) {
          final amountDouble =
              (amount is int ? amount.toDouble() : amount as double);

          if (paymentId.startsWith('REF')) {
            totalRefunded += amountDouble; // This is a refund payment
          } else {
            totalReceived += amountDouble; // This is a regular payment
          }
        }
      }

      // Calculate net received (total received - total refunded)
      final netReceived = totalReceived - totalRefunded;

      // Total cash records with proper column names
      final cashResponse = await _client
          .from('owner_record_cash')
          .select('*'); // Select all to avoid column name issues

      final totalCash = cashResponse.fold(0.0, (sum, record) {
        final amount = record['cash amount']; // Space in column name
        if (amount == null) return sum;

        if (amount is String) {
          final parsed = double.tryParse(amount) ?? 0.0;
          return sum + parsed;
        }
        return sum + (amount as num).toDouble();
      });

      // Count totals
      final paymentCount = receivedResponse.length;
      final cashCount = cashResponse.length;

      // Total paid = cash to owners + refunds to users
      final totalPaid = totalCash + totalRefunded;

      return {
        'totalReceived': netReceived, // Net received after refunds
        'totalCash': totalCash,
        'totalRefunded': totalRefunded, // New field for refunds
        'totalPaid': totalPaid, // New field for total paid (cash + refunds)
        'paymentCount': paymentCount,
        'cashCount': cashCount,
        'totalTransactions': paymentCount + cashCount,
      };
    } catch (e) {
      print('❌ Error fetching payment stats: $e');
      return {
        'totalReceived': 0.0,
        'totalCash': 0.0,
        'totalRefunded': 0.0,
        'totalPaid': 0.0,
        'paymentCount': 0,
        'cashCount': 0,
        'totalTransactions': 0,
      };
    }
  }

  /// Get all cash records from owner_record_cash table
  static Future<List<Map<String, dynamic>>> getAllCashRecords() async {
    try {
      print('🔄 Attempting to fetch from owner_record_cash table...');

      final response = await _client
          .from('owner_record_cash')
          .select('*')
          .order('created_at', ascending: false);

      print('✅ Cash records fetched successfully: ${response.length} records');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching cash records: $e');
      return [];
    }
  }

  /// Record cash payment to owner_record_cash table
  static Future<bool> recordCashPayment({
    required String ownerName,
    required String cashAmount,
    required String contact,
    required String description,
  }) async {
    try {
      await _client.from('owner_record_cash').insert({
        'owner name': ownerName, // Column names with spaces as per SQL
        'cash amount': cashAmount, // Column names with spaces as per SQL
        'status': 'successful',
        'contact': contact,
        'description': description,
      });

      return true;
    } catch (e) {
      print('❌ Error recording cash payment: $e');
      return false;
    }
  }

  /// Get venue owners for dropdown
  static Future<List<Map<String, dynamic>>> getVenueOwners() async {
    try {
      final response = await _client
          .from('venues')
          .select('''
            id,
            name,
            user_profiles!owner_id (
              id,
              full_name,
              phone
            )
          ''')
          .eq('status', 'active')
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching venue owners: $e');
      return [];
    }
  }

  /// Filter payments by type (from_user, to_owner, refund, cash)
  static Future<List<Map<String, dynamic>>> getFilteredPayments(
    String type,
  ) async {
    try {
      if (type == 'all') {
        // Get all payments directly without join to avoid complex relation issues
        final response = await _client
            .from('payments')
            .select('*')
            .order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      }

      final response = await _client
          .from('payments')
          .select('''
            *,
            user_profiles!user_id (full_name, email, phone)
          ''')
          .eq('payment_type', type)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching filtered payments: $e');
      return [];
    }
  }

  /// Convert payment data to display format
  static Map<String, dynamic> formatPaymentForDisplay(
    Map<String, dynamic> payment,
  ) {
    final user = payment['user_profiles'];
    final transactionType = payment['transaction_type'] ?? 'payment';

    // Handle refund transactions
    if (transactionType == 'refund') {
      return {
        'id': payment['payment_id'] ?? payment['id'],
        'description': 'Refund',
        'amount': payment['amount'],
        'type': 'refund',
        'status': 'completed',
        'method': 'Refund',
        'person': user?['full_name'] ?? 'Unknown User',
        'contact': user?['phone'] ?? user?['email'] ?? 'N/A',
        'transactionId':
            payment['payment_id'] ??
            'REFUND-${payment['id'].toString().substring(0, 8)}',
        'bookingId': 'Cancelled',
        'venue': payment['venue_name'] ?? 'N/A',
        'date': payment['created_at']?.toString().split('T')[0] ?? '',
        'time':
            payment['created_at']?.toString().split('T')[1].substring(0, 8) ??
            '',
        'reason': payment['cancellation_reason'] ?? 'N/A',
        'adminNotes': payment['admin_notes'] ?? 'N/A',
      };
    }

    // Handle regular payments
    return {
      'id': payment['payment_id'] ?? payment['id'],
      'description': 'From User', // Changed to show payment direction
      'amount': payment['amount'],
      'type': 'user', // Changed to just 'user' instead of 'from_user'
      'status': payment['payment_status'] ?? 'completed',
      'method': payment['payment_method'] ?? 'bKash',
      'person': user?['full_name'] ?? 'Unknown User',
      'contact': user?['phone'] ?? user?['email'] ?? 'N/A',
      'transactionId':
          payment['transaction_reference'] ?? payment['payment_id'],
      'bookingId': payment['booking_id'] ?? 'N/A',
      'venue': 'N/A', // Simplified since we removed booking join
      'date': payment['created_at']?.toString().split('T')[0] ?? '',
      'time':
          payment['created_at']?.toString().split('T')[1].substring(0, 8) ?? '',
    };
  }

  /// Convert cash record data to display format
  static Map<String, dynamic> formatCashRecordForDisplay(
    Map<String, dynamic> cashRecord,
  ) {
    return {
      'id': 'CASH${cashRecord['id']}',
      'description': 'To Owner',
      'amount': double.tryParse(cashRecord['cash_amount'] ?? '0') ?? 0.0,
      'type': 'owner',
      'status': cashRecord['status'] ?? 'successful',
      'method': 'Cash',
      'person':
          cashRecord['owner_name']?.toString().trim().isNotEmpty == true
              ? cashRecord['owner_name']
              : 'Venue Owner',
      'contact': cashRecord['contact'] ?? 'N/A',
      'transactionId': 'CASH${cashRecord['id']}',
      'bookingId': 'N/A',
      'venue': 'N/A',
      'date': cashRecord['created_at']?.toString().split('T')[0] ?? '',
      'time':
          cashRecord['created_at']?.toString().split('T')[1].substring(0, 8) ??
          '',
    };
  }

  /// Get pending refunds from cancellations table
  static Future<List<Map<String, dynamic>>> getPendingRefunds() async {
    try {
      print('🔄 Attempting to fetch from cancellations table...');

      // First try to get all records to check table access
      // Get refunds that are 'accepted' - simple query first
      final response = await _client
          .from('cancellations')
          .select('*')
          .eq('refund_status', 'accepted')
          .order('cancelled_at', ascending: false);

      // Now fetch user details for each refund
      List<Map<String, dynamic>> enrichedRefunds = [];

      for (final refund in response) {
        try {
          final userDetails =
              await _client
                  .from('user_profiles')
                  .select('full_name, phone, email')
                  .eq('id', refund['user_id'])
                  .single();

          // Merge refund data with user details
          enrichedRefunds.add({
            ...refund,
            'user_name': userDetails['full_name'],
            'user_contact':
                userDetails['phone'], // Changed from 'contact' to 'phone'
            'user_email': userDetails['email'],
          });
        } catch (e) {
          // Add refund without user details
          enrichedRefunds.add({
            ...refund,
            'user_name': 'Unknown User',
            'user_contact': 'N/A',
            'user_email': 'N/A',
          });
        }
      }

      return enrichedRefunds;
    } catch (e) {
      print('❌ Error fetching pending refunds: $e');
      return [];
    }
  }

  /// Calculate total pending refund amount
  static Future<double> calculatePendingRefundAmount() async {
    try {
      final pendingRefunds = await getPendingRefunds();
      double total = 0.0;

      for (final refund in pendingRefunds) {
        final amount = refund['refund_amount'];
        if (amount != null) {
          total += (amount as num).toDouble();
        }
      }

      return total;
    } catch (e) {
      print('❌ Error calculating pending refund amount: $e');
      return 0.0;
    }
  }

  /// Process refund payment and update status
  static Future<bool> processRefundPayment({
    required String refundId,
    required String amount,
    required String method,
    required String adminNotes,
    required String userName,
    required String userContact,
    required String venueName,
  }) async {
    try {
      // 1. Update cancellations table - change status to 'completed'
      await _client
          .from('cancellations')
          .update({
            'refund_status':
                'completed', // Now 'completed' is allowed in constraint
            'refund_processed_at': DateTime.now().toIso8601String(),
            'admin_notes':
                adminNotes.isNotEmpty
                    ? adminNotes
                    : 'Refund processed via $method',
          })
          .eq('id', refundId);

      // 2. Add refund entry to payments table with existing columns only
      await _client.from('payments').insert({
        'payment_id':
            'REF${DateTime.now().millisecondsSinceEpoch}', // Generate unique payment_id
        'amount': double.parse(amount),
        'payment_method': method,
        'payment_status': 'completed',
        'transaction_reference': 'Refund: $userName - $venueName',
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Refund payment processed successfully');
      return true;
    } catch (e) {
      print('❌ Error processing refund payment: $e');
      return false;
    }
  }
}
