import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class PaymentService {
  static final _client = SupabaseConfig.client;

  /// Create a new booking payment record
  static Future<String?> createBookingPayment({
    required String userId,
    required String bookingId,
    required double amount,
    required String paymentMethod,
    required String mobileNumber,
    required String pin,
  }) async {
    try {
      // Generate unique payment ID
      final paymentId = _generatePaymentId(paymentMethod);

      print('💳 Creating payment record...');
      print('   Payment ID: $paymentId');
      print('   User ID: $userId');
      print('   Booking ID: $bookingId');
      print('   Amount: $amount');
      print('   Method: $paymentMethod');

      // Create payment record
      await _client.from('payments').insert({
        'payment_id': paymentId,
        'user_id': userId,
        'booking_id': bookingId,
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_status': 'completed', // Assuming payment is successful
      });

      print('✅ Payment created successfully: $paymentId');
      return paymentId;
    } catch (e) {
      print('❌ Error creating payment: $e');
      print('❌ Error details: ${e.toString()}');
      return null;
    }
  }

  /// Create a new tournament registration payment record
  static Future<String?> createTournamentPayment({
    required String userId,
    required String tournamentRegistrationId,
    required double amount,
    required String paymentMethod,
    required String mobileNumber,
    required String pin,
  }) async {
    try {
      // Generate unique payment ID
      final paymentId = _generatePaymentId(paymentMethod);

      // Create payment record
      await _client.from('payments').insert({
        'payment_id': paymentId,
        'user_id': userId,
        'tournament_registration_id': tournamentRegistrationId,
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_status': 'completed', // Assuming payment is successful
      });

      print('✅ Tournament payment created successfully: $paymentId');
      return paymentId;
    } catch (e) {
      print('❌ Error creating tournament payment: $e');
      return null;
    }
  }

  /// Get user's payment history
  static Future<List<Map<String, dynamic>>> getUserPayments(
    String userId,
  ) async {
    try {
      final response = await _client
          .from('payments')
          .select('''
            *,
            bookings:booking_id (
              venue_id,
              booking_date,
              start_time,
              end_time,
              venues:venue_id (name, location)
            ),
            tournament_registrations:tournament_registration_id (
              tournament_id,
              tournaments:tournament_id (name, tournament_date)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('✅ User payments fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching user payments: $e');
      return [];
    }
  }

  /// Get payment by ID
  static Future<Map<String, dynamic>?> getPaymentById(String paymentId) async {
    try {
      final response =
          await _client
              .from('payments')
              .select('''
            *,
            bookings:booking_id (
              venue_id,
              booking_date,
              start_time,
              end_time,
              venues:venue_id (name, location)
            ),
            tournament_registrations:tournament_registration_id (
              tournament_id,
              tournaments:tournament_id (name, tournament_date)
            )
          ''')
              .eq('payment_id', paymentId)
              .single();

      print('✅ Payment details fetched for ID: $paymentId');
      return response;
    } catch (e) {
      print('❌ Error fetching payment details: $e');
      return null;
    }
  }

  /// Update payment status
  static Future<bool> updatePaymentStatus(
    String paymentId,
    String status,
  ) async {
    try {
      await _client
          .from('payments')
          .update({'payment_status': status})
          .eq('payment_id', paymentId);

      print('✅ Payment status updated: $paymentId -> $status');
      return true;
    } catch (e) {
      print('❌ Error updating payment status: $e');
      return false;
    }
  }

  /// Create a refund
  static Future<String?> createRefund({
    required String originalPaymentId,
    required String userId,
    required double amount,
    required String reason,
  }) async {
    try {
      final refundPaymentId = _generatePaymentId('REFUND');

      await _client.from('payments').insert({
        'payment_id': refundPaymentId,
        'user_id': userId,
        'amount': -amount, // Negative amount for refund
        'payment_method': 'Refund',
        'payment_status': 'completed',
      });

      print('✅ Refund created successfully: $refundPaymentId');
      return refundPaymentId;
    } catch (e) {
      print('❌ Error creating refund: $e');
      return null;
    }
  }

  /// Simulate payment processing (bKash/Nagad integration would go here)
  static Future<bool> processPayment({
    required String paymentMethod,
    required String mobileNumber,
    required String pin,
    required double amount,
  }) async {
    try {
      // Simulate payment gateway call
      print('💳 Processing ${paymentMethod} payment...');
      print('   Mobile: $mobileNumber');
      print('   Amount: ৳${amount.toStringAsFixed(2)}');

      await Future.delayed(const Duration(seconds: 2));

      // Validate mobile number
      if (mobileNumber.length != 11 || !mobileNumber.startsWith('01')) {
        throw Exception('Invalid mobile number format');
      }

      // Validate PIN
      if (pin.length < 4) {
        throw Exception('PIN must be at least 4 digits');
      }

      // Validate amount
      if (amount <= 0) {
        throw Exception('Invalid payment amount');
      }

      // Special test PIN for guaranteed success (for testing purposes)
      if (pin == '1234' || pin == '0000') {
        print('✅ Test PIN used - payment guaranteed to succeed');
        print('✅ ${paymentMethod} payment processed successfully');
        return true;
      }

      // For demo purposes, make payment successful most of the time
      // In production, this would call actual bKash/Nagad API
      final random = DateTime.now().millisecond % 100;
      final success =
          random >
          15; // 85% success rate (reduced slightly for more realistic simulation)

      if (!success) {
        throw Exception(
          'Payment gateway temporarily unavailable. Please try again.',
        );
      }

      print('✅ ${paymentMethod} payment processed successfully');
      return true;
    } catch (e) {
      print('❌ Payment processing failed: $e');
      rethrow; // Re-throw to let the UI handle the error
    }
  }

  /// Generate unique payment ID
  static String _generatePaymentId(String paymentMethod) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final prefix =
        paymentMethod == 'bKash'
            ? 'BKS'
            : paymentMethod == 'Nagad'
            ? 'NGD'
            : 'PAY';
    return '${prefix}_${timestamp.toString().substring(5)}';
  }
}
