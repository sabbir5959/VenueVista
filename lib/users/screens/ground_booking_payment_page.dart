import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common_drawer.dart';
import 'ground_booking_success_page.dart';
import '../../services/payment_service.dart';
import '../../services/booking_service.dart';
import '../../services/auth_service.dart';

class GroundBookingPaymentPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const GroundBookingPaymentPage({super.key, required this.booking});

  @override
  State<GroundBookingPaymentPage> createState() =>
      _GroundBookingPaymentPageState();
}

class _GroundBookingPaymentPageState extends State<GroundBookingPaymentPage> {
  String selectedPaymentMethod = '';
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const CommonDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Info Card
                _buildBookingInfoCard(),
                const SizedBox(height: 24),

                // Payment Method Selection
                _buildPaymentMethodSection(),
                const SizedBox(height: 24),

                // Mobile Number Input
                if (selectedPaymentMethod.isNotEmpty) ...[
                  _buildMobileNumberSection(),
                  const SizedBox(height: 24),
                ],

                // PIN Input
                if (selectedPaymentMethod.isNotEmpty) ...[
                  _buildPinSection(),
                  const SizedBox(height: 32),
                ],

                // Payment Summary
                if (selectedPaymentMethod.isNotEmpty) ...[
                  _buildPaymentSummary(),
                  const SizedBox(height: 32),
                ],

                // Proceed Button
                if (selectedPaymentMethod.isNotEmpty) _buildProceedButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingInfoCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.green.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.sports_soccer, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              widget.booking['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.booking['location'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  widget.booking['timeSlot'],
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(width: 24),
                Icon(Icons.calendar_today, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  widget.booking['date'] ?? 'Today',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),

            // bKash Option
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedPaymentMethod = 'bKash';
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        selectedPaymentMethod == 'bKash'
                            ? Colors.pink.shade400
                            : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color:
                      selectedPaymentMethod == 'bKash'
                          ? Colors.pink.shade50
                          : Colors.white,
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.pink.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'bKash',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'bKash',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Pay with your bKash account',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (selectedPaymentMethod == 'bKash')
                      Icon(
                        Icons.check_circle,
                        color: Colors.pink.shade400,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Nagad Option
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedPaymentMethod = 'Nagad';
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        selectedPaymentMethod == 'Nagad'
                            ? Colors.orange.shade400
                            : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color:
                      selectedPaymentMethod == 'Nagad'
                          ? Colors.orange.shade50
                          : Colors.white,
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Nagad',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nagad',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Pay with your Nagad account',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (selectedPaymentMethod == 'Nagad')
                      Icon(
                        Icons.check_circle,
                        color: Colors.orange.shade400,
                        size: 24,
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

  Widget _buildMobileNumberSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mobile Number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: InputDecoration(
                hintText: 'Enter your $selectedPaymentMethod number',
                prefixIcon: Icon(
                  Icons.phone_android,
                  color:
                      selectedPaymentMethod == 'bKash'
                          ? Colors.pink.shade400
                          : Colors.orange.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color:
                        selectedPaymentMethod == 'bKash'
                            ? Colors.pink.shade400
                            : Colors.orange.shade400,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your mobile number';
                }
                if (value.length != 11) {
                  return 'Mobile number must be 11 digits';
                }
                if (!value.startsWith('01')) {
                  return 'Mobile number must start with 01';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$selectedPaymentMethod PIN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: InputDecoration(
                hintText: 'Enter your $selectedPaymentMethod PIN',
                prefixIcon: Icon(
                  Icons.lock,
                  color:
                      selectedPaymentMethod == 'bKash'
                          ? Colors.pink.shade400
                          : Colors.orange.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color:
                        selectedPaymentMethod == 'bKash'
                            ? Colors.pink.shade400
                            : Colors.orange.shade400,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your PIN';
                }
                if (value.length != 4) {
                  return 'PIN must be 4 digits';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    print('🔍 Debug _buildPaymentSummary:');
    print('   Raw price: ${widget.booking['price']}');

    final bookingFee = widget.booking['price']
        .replaceAll('৳', '')
        .replaceAll(',', '')
        .replaceAll('/hour', '');
    print('   Cleaned fee: $bookingFee');

    // Parse as double first, then convert to int
    final bookingAmount = (double.tryParse(bookingFee) ?? 0.0).toInt();
    print('   Booking amount: $bookingAmount');

    final transactionFee = _calculateTransactionFee(bookingAmount);
    print('   Transaction fee: $transactionFee');

    final totalAmount = bookingAmount + transactionFee;
    print('   Total amount: $totalAmount');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ground Booking Fee:',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  widget.booking['price'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction Fee:',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  '৳$transactionFee',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "৳$totalAmount",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedPaymentMethod == 'bKash'
                  ? Colors.pink.shade400
                  : Colors.orange.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child:
            isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                  'Pay ${_calculateTotal()} with $selectedPaymentMethod',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  String _calculateTotal() {
    print('🔍 Debug _calculateTotal:');
    print('   Raw price: ${widget.booking['price']}');

    final bookingFee = widget.booking['price']
        .replaceAll('৳', '')
        .replaceAll(',', '')
        .replaceAll('/hour', '');
    print('   Cleaned fee: $bookingFee');

    // Parse as double first, then convert to int
    final bookingAmount = (double.tryParse(bookingFee) ?? 0.0).toInt();
    print('   Booking amount: $bookingAmount');

    final transactionFee = _calculateTransactionFee(bookingAmount);
    print('   Transaction fee: $transactionFee');

    final totalAmount = bookingAmount + transactionFee;
    print('   Total amount: $totalAmount');

    return '৳$totalAmount';
  }

  int _calculateTransactionFee(int amount) {
    // Calculate 2% transaction fee
    // 1000 tk -> 20 tk, 500 tk -> 10 tk, 3000 tk -> 60 tk
    return (amount * 0.02).round();
  }

  // Helper method to format date for database (from "1/1/2025" to "2025-01-01")
  String _formatDateForDatabase(String dateString) {
    try {
      if (dateString.isEmpty) {
        return DateTime.now().toIso8601String().split('T')[0];
      }

      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }

      return DateTime.now().toIso8601String().split('T')[0];
    } catch (e) {
      return DateTime.now().toIso8601String().split('T')[0];
    }
  }

  // Helper method to extract start time from time slot (from "09:00 to 10:00" to "09:00")
  String _extractStartTime(String timeSlot) {
    try {
      if (timeSlot.isEmpty) return '09:00';

      final parts = timeSlot.split(' to ');
      if (parts.isNotEmpty) {
        return parts[0].trim();
      }

      return '09:00';
    } catch (e) {
      return '09:00';
    }
  }

  // Helper method to extract end time from time slot (from "09:00 to 10:00" to "10:00")
  String _extractEndTime(String timeSlot) {
    try {
      if (timeSlot.isEmpty) return '10:00';

      final parts = timeSlot.split(' to ');
      if (parts.length >= 2) {
        return parts[1].trim();
      }

      return '10:00';
    } catch (e) {
      return '10:00';
    }
  }

  void _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      // Get current user
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Calculate amounts - booking fee + transaction fee
      final bookingFee = widget.booking['price']
          .replaceAll('৳', '')
          .replaceAll(',', '')
          .replaceAll('/hour', '');
      final bookingAmount = (double.tryParse(bookingFee) ?? 0.0).toInt();
      final transactionFee = _calculateTransactionFee(bookingAmount);
      final totalAmount = (bookingAmount + transactionFee).toDouble();

      // Process payment through payment gateway
      print('🔄 Processing payment...');
      bool paymentSuccess = false;
      int retryCount = 0;
      const maxRetries = 2;

      // Try payment with retry logic
      while (!paymentSuccess && retryCount <= maxRetries) {
        try {
          paymentSuccess = await PaymentService.processPayment(
            paymentMethod: selectedPaymentMethod,
            mobileNumber: mobileController.text,
            pin: pinController.text,
            amount: totalAmount,
          );

          if (!paymentSuccess && retryCount < maxRetries) {
            retryCount++;
            print('⚠️ Payment attempt ${retryCount} failed, retrying...');
            await Future.delayed(const Duration(seconds: 1));
          }
        } catch (e) {
          if (retryCount < maxRetries) {
            retryCount++;
            print('⚠️ Payment attempt ${retryCount} failed: $e, retrying...');
            await Future.delayed(const Duration(seconds: 1));
          } else {
            throw e; // Re-throw on final failure
          }
        }
      }

      if (!paymentSuccess) {
        throw Exception(
          'Payment failed after ${maxRetries + 1} attempts. Please check your details and try again.',
        );
      }

      print('✅ Payment processed successfully');

      // Create booking in database
      print('🔄 Creating booking...');
      print(
        '📋 Booking data: venueId=${widget.booking['venueId']}, date=${widget.booking['date']}, timeSlot=${widget.booking['timeSlot']}',
      );
      final bookingId = await BookingService.createBooking(
        userId: currentUser.id,
        venueId: widget.booking['venueId'] ?? widget.booking['id'] ?? '',
        bookingDate: _formatDateForDatabase(widget.booking['date'] ?? ''),
        startTime: _extractStartTime(widget.booking['timeSlot'] ?? ''),
        endTime: _extractEndTime(widget.booking['timeSlot'] ?? ''),
        totalAmount: totalAmount,
      );

      if (bookingId == null) {
        throw Exception('Failed to create booking');
      }
      print('✅ Booking created with ID: $bookingId');

      // Create payment record
      print('🔄 Recording payment...');
      final paymentId = await PaymentService.createBookingPayment(
        userId: currentUser.id,
        bookingId: bookingId,
        amount: totalAmount,
        paymentMethod: selectedPaymentMethod,
        mobileNumber: mobileController.text,
        pin: pinController.text,
      );

      if (paymentId == null) {
        throw Exception('Failed to record payment');
      }
      print('✅ Payment recorded with ID: $paymentId');

      // Success - navigate to success page
      if (mounted) {
        setState(() {
          isProcessing = false;
        });

        // Navigate to success page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => GroundBookingSuccessPage(
                  booking: {
                    ...widget.booking,
                    'bookingId': bookingId,
                    'paymentId': paymentId,
                  },
                  paymentMethod: selectedPaymentMethod,
                  mobileNumber: mobileController.text,
                  totalAmount: _calculateTotal(),
                  transactionId: _generateTransactionId(),
                ),
          ),
        );
      }
    } catch (e) {
      // Handle errors
      if (mounted) {
        setState(() {
          isProcessing = false;
        });

        // Show error dialog
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Payment Failed'),
                content: Text(
                  'Error: ${e.toString().replaceAll('Exception: ', '')}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  String _generateTransactionId() {
    final prefix = selectedPaymentMethod == 'bKash' ? 'BKS' : 'NGD';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefix${timestamp.toString().substring(7)}';
  }

  @override
  void dispose() {
    mobileController.dispose();
    pinController.dispose();
    super.dispose();
  }
}
