import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/venue_owner_sidebar.dart';
import '../widgets/owner_profile_widget.dart';
import '../models/discount_schedule.dart';
import '../services/dynamic_pricing_service.dart';
import 'edit_schedule_page.dart';

class DynamicPricingPage extends StatefulWidget {
  const DynamicPricingPage({Key? key}) : super(key: key);

  @override
  State<DynamicPricingPage> createState() => _DynamicPricingPageState();
}

class _DynamicPricingPageState extends State<DynamicPricingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DynamicPricingService _pricingService = DynamicPricingService.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Owner venue information
  Map<String, dynamic>? _ownerVenue;
  
  // Base price
  double _basePrice = 500.0;
  final TextEditingController _basePriceController = TextEditingController();
  
  // Discount form controllers
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _discountValueController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  String _discountType = 'percentage'; // 'percentage' or 'flat'
  
  // Data
  bool _isLoading = false;
  
  // Applied discounts storage (in-memory for now)
  List<Map<String, dynamic>> _appliedDiscounts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _basePriceController.text = _basePrice.toString();
    _loadOwnerVenue();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _basePriceController.dispose();
    _discountValueController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _loadOwnerVenue() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('venues')
            .select('id, name, address, city, price_per_hour')
            .eq('owner_id', user.id)
            .single();
        
        setState(() {
          _ownerVenue = response;
          _basePrice = (response['price_per_hour'] as num?)?.toDouble() ?? 500.0;
          _basePriceController.text = _basePrice.toString();
        });
      }
    } catch (e) {
      print('Error loading owner venue: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading venue information: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _applyDynamicDiscount() async {
    if (_ownerVenue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Venue information not loaded'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_discountValueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter discount value'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final discountValue = double.parse(_discountValueController.text);
      final originalPrice = _basePrice;
      double discountedPrice;

      if (_discountType == 'percentage') {
        discountedPrice = originalPrice - (originalPrice * discountValue / 100);
      } else {
        discountedPrice = originalPrice - discountValue;
      }

      // Ensure price doesn't go below 0
      discountedPrice = discountedPrice < 0 ? 0 : discountedPrice;

      // Store discount information (don't update venue price in database)
      final discountInfo = {
        'venue_id': _ownerVenue!['id'],
        'venue_name': _ownerVenue!['name'],
        'original_price': originalPrice,
        'discounted_price': discountedPrice,
        'discount_value': discountValue,
        'discount_type': _discountType,
        'start_date': _startDate!.toIso8601String(),
        'end_date': _endDate!.toIso8601String(),
        'label': _labelController.text.isNotEmpty ? _labelController.text : 'Discount Applied',
        'created_at': DateTime.now().toIso8601String(),
      };

      // Add to applied discounts list
      setState(() {
        _appliedDiscounts.add(discountInfo);
        _isLoading = false;
        
        // Clear form
        _startDate = null;
        _endDate = null;
        _discountValueController.clear();
        _labelController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Discount scheduled successfully! ৳${discountedPrice.toStringAsFixed(2)} (${discountValue}${_discountType == 'percentage' ? '%' : ' Tk'} off)',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error applying discount: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Simple wrapper method for button calls
  // ignore: unused_element
  Future<void> _applyDiscount() async {
    await _applyDynamicDiscount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Pricing'),
        backgroundColor: Colors.green[700],
        actions: [
          OwnerProfileWidget(),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.price_change),
              text: 'Manage Pricing',
            ),
            Tab(
              icon: Icon(Icons.list_alt),
              text: 'Scheduled Discounts',
            ),
          ],
        ),
      ),
      drawer: const VenueOwnerSidebar(currentPage: 'pricing'),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildManagePricingTab(),
          _buildScheduledDiscountsTab(),
        ],
      ),
    );
  }

  Widget _buildManagePricingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Venue Information Display
          _buildVenueInfoCard(),
          
          const SizedBox(height: 20),
          
          // Current Base Price Display
          _buildBasePriceCard(),
          
          const SizedBox(height: 20),
          
          // Discount Scheduler
          _buildDiscountSchedulerCard(),
          
          const SizedBox(height: 40),
          
          // Apply Discount Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _scheduleDiscount,
              icon: const Icon(Icons.schedule),
              label: const Text(
                'Apply Discount',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueInfoCard() {
    if (_ownerVenue == null) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Loading venue information...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: Colors.green[700], size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Venue Information',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.place, 'Venue Name', _ownerVenue!['name'] ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_city, 'City', _ownerVenue!['city'] ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.home, 'Address', _ownerVenue!['address'] ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.monetization_on, 'Current Price', '৳${_basePrice.toStringAsFixed(2)}/hour'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildBasePriceCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green[700], size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Current Base Price',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Base Rate',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        '৳${_basePrice.toStringAsFixed(0)}/hour',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _updateBasePrice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Update'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountSchedulerCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.orange[700], size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Schedule New Discount',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Date Selection
            const Text(
              'Select Date Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(true),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _startDate != null
                          ? DateFormat('MMM dd, yyyy').format(_startDate!)
                          : 'Start Date',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      foregroundColor: Colors.green[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(false),
                    icon: const Icon(Icons.event, size: 16),
                    label: Text(
                      _endDate != null
                          ? DateFormat('MMM dd, yyyy').format(_endDate!)
                          : 'End Date',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      foregroundColor: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Discount Type & Value
            const Text(
              'Discount Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _discountType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Discount Type',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'percentage', child: Text('% Off')),
                      DropdownMenuItem(value: 'flat', child: Text('Flat Off')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _discountType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _discountValueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: _discountType == 'percentage' ? 'Percentage' : 'Amount (৳)',
                      hintText: _discountType == 'percentage' ? 'e.g., 20' : 'e.g., 100',
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Label/Reason
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Label/Reason (Optional)',
                hintText: 'e.g., "Independence Day Special", "Kickoff Deals"',
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Apply Discount Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _applyDynamicDiscount,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.discount),
                label: Text(_isLoading ? 'Applying...' : 'Apply Discount'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledDiscountsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Venue Pricing Status
          _buildCurrentPricingCard(),
          
          const SizedBox(height: 20),
          
          // Applied Discounts Section
          Text(
            'Applied Discounts',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // If no venue loaded yet
          if (_ownerVenue == null)
            _buildNoVenueCard()
          else
            _buildAppliedDiscountCard(),
        ],
      ),
    );
  }

  Widget _buildCurrentPricingCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Current Pricing Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_ownerVenue != null) ...[
              Text('Venue: ${_ownerVenue!['name']}'),
              const SizedBox(height: 4),
              Text('Location: ${_ownerVenue!['address']}, ${_ownerVenue!['city']}'),
              const SizedBox(height: 4),
              Text(
                'Current Price: ৳${_basePrice.toStringAsFixed(2)}/hour',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ] else ...[
              const Text('Loading venue information...'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoVenueCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No venue information available',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliedDiscountCard() {
    if (_appliedDiscounts.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.discount_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'No discounts applied yet',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'Use the Dynamic Pricing tab to create discounts',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _appliedDiscounts.map((discount) => _buildDiscountDisplayCard(discount)).toList(),
    );
  }

  Widget _buildDiscountDisplayCard(Map<String, dynamic> discount) {
    final originalPrice = discount['original_price'] as double;
    final discountedPrice = discount['discounted_price'] as double;
    final discountValue = discount['discount_value'] as double;
    final discountType = discount['discount_type'] as String;
    final startDate = DateTime.parse(discount['start_date']);
    final endDate = DateTime.parse(discount['end_date']);
    final label = discount['label'] as String;

    final dateRange = '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}';
    final discountText = discountType == 'percentage' ? '${discountValue.toInt()}% off' : '৳${discountValue.toInt()} off';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _editDiscount(discount),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Price display with strikethrough
            Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                // Discounted price (bold)
                Text(
                  '৳${discountedPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                // Original price with strikethrough
                Text(
                  '৳${originalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                // Discount badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    discountText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Date range
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Valid: $dateRange',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Venue info
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Venue: ${discount['venue_name']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editDiscount(Map<String, dynamic> discount) {
    // Create a discount schedule object for editing
    final startDate = DateTime.parse(discount['start_date']);
    final endDate = DateTime.parse(discount['end_date']);
    
    final scheduleForEdit = DiscountSchedule(
      id: 0,
      startDate: startDate,
      endDate: endDate,
      startTime: const TimeOfDay(hour: 0, minute: 0),
      endTime: const TimeOfDay(hour: 23, minute: 59),
      discountType: discount['discount_type'] == 'percentage' ? DiscountType.percentage : DiscountType.flat,
      discountValue: discount['discount_value'] as double,
      label: discount['label'] as String,
      applyToIndividual: true,
      applyToTeams: true,
      allowOverlapping: false,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSchedulePage(
          schedule: scheduleForEdit,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh data after editing
        setState(() {});
      }
    });
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime now = DateTime.now();
    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? tomorrow 
          : (_startDate != null ? _startDate!.add(const Duration(days: 1)) : tomorrow),
      firstDate: isStartDate 
          ? tomorrow 
          : (_startDate != null ? _startDate!.add(const Duration(days: 1)) : tomorrow),
      lastDate: DateTime(now.year + 2),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // Reset end date if it's before or same as the new start date
          if (_endDate != null && (_endDate!.isBefore(pickedDate) || _endDate!.isAtSameMomentAs(pickedDate))) {
            _endDate = null;
          }
        } else {
          // Additional validation: End date must be after start date
          if (_startDate != null && !pickedDate.isAfter(_startDate!)) {
            _showError('End date must be after start date');
            return;
          }
          _endDate = pickedDate;
        }
      });
    }
  }

  void _updateBasePrice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Base Price'),
        content: TextFormField(
          controller: _basePriceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Base Price per Hour (৳)',
            hintText: 'e.g., 500',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(_basePriceController.text);
              if (newPrice != null && newPrice > 0) {
                await _pricingService.updateBasePrice(newPrice);
                setState(() {
                  _basePrice = newPrice;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Base price updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid price'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _scheduleDiscount() async {
    // Validation
    if (_startDate == null) {
      _showError('Please select a start date');
      return;
    }
    
    // Validate end date 
    if (_endDate != null) {
      if (_endDate!.isBefore(_startDate!) || _endDate!.isAtSameMomentAs(_startDate!)) {
        _showError('End date must be after start date');
        return;
      }
    }
    
    if (_discountValueController.text.isEmpty) {
      _showError('Please enter a discount value');
      return;
    }
    
    final discountValue = double.tryParse(_discountValueController.text);
    if (discountValue == null || discountValue <= 0) {
      _showError('Please enter a valid discount value');
      return;
    }
    
    if (_discountType == 'percentage' && discountValue >= 100) {
      _showError('Percentage discount must be less than 100%');
      return;
    }

    try {
      final newDiscount = DiscountSchedule(
        id: DateTime.now().millisecondsSinceEpoch,
        startDate: _startDate!,
        endDate: _endDate,
        // Fixed times for full-day discounts - shows date pickers
        startTime: const TimeOfDay(hour: 0, minute: 0), // All day start
        endTime: const TimeOfDay(hour: 23, minute: 59), // All day end
        discountType: _discountType == 'percentage' ? DiscountType.percentage : DiscountType.flat,
        discountValue: discountValue,
        label: _labelController.text,
        applyToIndividual: true,
        applyToTeams: true,
        allowOverlapping: false,
      );
      //save using service
      await _pricingService.addDiscountSchedule(newDiscount);
      await _loadOwnerVenue();

      // Clear form
      setState(() {
        _startDate = null;
        _endDate = null;
        _discountValueController.clear();
        _labelController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Discount scheduled successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Switch to scheduled discounts tab
      _tabController.animateTo(1);
    } catch (e) {
      _showError('Error scheduling discount: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
