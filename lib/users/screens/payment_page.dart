import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common_drawer.dart';
import 'payment_success_page.dart' as success;

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> tournament;

  const PaymentPage({super.key, required this.tournament});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
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
                // Tournament Info Card
                _buildTournamentInfoCard(),
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

  Widget _buildTournamentInfoCard() {
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
            const Icon(Icons.emoji_events, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              widget.tournament['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.tournament['description'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  widget.tournament['date'],
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(width: 24),
                Icon(Icons.sports_soccer, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  widget.tournament['playerFormat'],
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
                    Column(
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
                        ),
                      ],
                    ),
                    const Spacer(),
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
                    Column(
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
                        ),
                      ],
                    ),
                    const Spacer(),
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
                  'Tournament Entry Fee:',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  widget.tournament['entryFee'],
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
                const Text(
                  '৳10',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                  _calculateTotal(),
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
    final entryFee = widget.tournament['entryFee']
        .replaceAll('৳', '')
        .replaceAll(',', '');
    final entryAmount = int.tryParse(entryFee) ?? 0;
    final total = entryAmount + 10; // Adding transaction fee
    return '৳${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  void _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        isProcessing = false;
      });

      // Navigate to success page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => success.PaymentSuccessPage(
                tournament: widget.tournament,
                paymentMethod: selectedPaymentMethod,
                mobileNumber: mobileController.text,
                totalAmount: _calculateTotal(),
                transactionId: _generateTransactionId(),
              ),
        ),
      );
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
