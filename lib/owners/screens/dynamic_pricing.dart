import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/venue_owner_sidebar.dart';
import '../widgets/owner_profile_widget.dart';

class DynamicPricingPage extends StatefulWidget {
  const DynamicPricingPage({Key? key}) : super(key: key);

  @override
  State<DynamicPricingPage> createState() => _DynamicPricingPageState();
}

class _DynamicPricingPageState extends State<DynamicPricingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Venue data
  Map<String, dynamic>? _ownerVenue;
  double _basePrice = 0;
  final TextEditingController _basePriceController = TextEditingController();

  // Active discount (stored in venue row)
  double? _discountPrice; // discount_per_hour
  DateTime? _discountStartDate; // discount_start_date
  DateTime? _discountEndDate; // discount_end_date (nullable/open-ended)

  // Scheduling form
  String _discountType = 'percentage'; // 'percentage' or 'flat'
  final TextEditingController _discountValueController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();

  // Local list of scheduled/applied discounts (only holds current + session history)
  final List<Map<String, dynamic>> _appliedDiscounts = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOwnerVenue();
    _loadAppliedDiscounts();
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
      if (user == null) return;
      final response = await _supabase
          .from('venues')
          .select('id, name, address, city, price_per_hour, discount_per_hour, discount_start_date, discount_end_date')
          .eq('owner_id', user.id)
          .single();

      setState(() {
        _ownerVenue = response;
        _basePrice = (response['price_per_hour'] as num?)?.toDouble() ?? 0;
        _basePriceController.text = _basePrice.toStringAsFixed(0);
        _discountPrice = (response['discount_per_hour'] as num?)?.toDouble();
        final startIso = response['discount_start_date'];
        final endIso = response['discount_end_date'];
        _discountStartDate = startIso != null ? DateTime.parse(startIso).toLocal() : null;
        _discountEndDate = endIso != null ? DateTime.parse(endIso).toLocal() : null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading venue: $e'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  Future<void> _loadAppliedDiscounts() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('venues')
          .select('id, name, address, city, price_per_hour, discount_per_hour, discount_start_date, discount_end_date')
          .eq('owner_id', user.id)
          .single();

      setState(() {
        _appliedDiscounts.clear();
        
        // Check if venue has discount data
        final discountPerHour = (response['discount_per_hour'] as num?)?.toDouble();
        final basePrice = (response['price_per_hour'] as num?)?.toDouble() ?? 0;
        final startDateIso = response['discount_start_date'];
        final endDateIso = response['discount_end_date'];
        
        if (discountPerHour != null && discountPerHour < basePrice && startDateIso != null) {
          // Calculate discount value based on the difference
          final discountValue = basePrice - discountPerHour;
          
          // Determine discount type (we'll assume flat amount since we can calculate it)
          final discountPercentage = (discountValue / basePrice) * 100;
          final isPercentage = discountPercentage % 1 == 0 && discountPercentage <= 50; // Simple heuristic
          
          _appliedDiscounts.add({
            'id': response['id'],
            'venue_id': response['id'],
            'venue_name': response['name'],
            'original_price': basePrice,
            'discounted_price': discountPerHour,
            'discount_value': isPercentage ? discountPercentage : discountValue,
            'discount_type': isPercentage ? 'percentage' : 'flat',
            'start_date': startDateIso,
            'end_date': endDateIso,
            'label': 'Active Discount',
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading discounts: $e'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  bool _isDiscountCurrentlyActive() {
    if (_discountPrice == null || _discountStartDate == null) return false;
    if (_discountPrice! >= _basePrice) return false; // not a real discount or reset state
    final now = DateTime.now();
    final started = !now.isBefore(_discountStartDate!);
    final notEnded = _discountEndDate == null || !now.isAfter(_discountEndDate!.add(const Duration(hours: 23, minutes: 59, seconds: 59)));
    return started && notEnded;
  }

  Future<void> _scheduleDiscount() async {
    if (_ownerVenue == null) { _showError('Venue not loaded'); return; }
    if (_discountStartDate == null) { _showError('Select start date'); return; }
    if (_discountEndDate != null && !_discountEndDate!.isAfter(_discountStartDate!)) { _showError('End date must be after start'); return; }
    if (_discountValueController.text.isEmpty) { _showError('Enter discount value'); return; }

    final rawValue = double.tryParse(_discountValueController.text);
    if (rawValue == null || rawValue <= 0) { _showError('Invalid discount value'); return; }
    if (_discountType == 'percentage' && rawValue >= 100) { _showError('Percentage must be < 100'); return; }
    if (_discountType == 'flat' && rawValue >= _basePrice) { _showError('Flat amount must be < base price'); return; }

    double discountedPrice = _basePrice;
    if (_discountType == 'percentage') {
      discountedPrice = _basePrice - (_basePrice * rawValue / 100.0);
    } else { // flat
      discountedPrice = _basePrice - rawValue;
    }
    if (discountedPrice < 0) discountedPrice = 0;

    try {
      setState(() { _isLoading = true; });
      await _supabase.from('venues').update({
        'discount_per_hour': discountedPrice,
        'discount_start_date': DateTime(_discountStartDate!.year, _discountStartDate!.month, _discountStartDate!.day).toUtc().toIso8601String(),
        'discount_end_date': _discountEndDate != null ? DateTime(_discountEndDate!.year, _discountEndDate!.month, _discountEndDate!.day).toUtc().toIso8601String() : null,
      }).eq('id', _ownerVenue!['id']);

      await _loadOwnerVenue();
      await _loadAppliedDiscounts();

      setState(() {
        _discountPrice = discountedPrice;
        // Clear form
        _discountValueController.clear();
        _labelController.clear();
        _discountStartDate = null;
        _discountEndDate = null;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Discount scheduled (৳${discountedPrice.toStringAsFixed(2)})'), backgroundColor: Colors.green),
        );
        _tabController.animateTo(1);
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      _showError('Error scheduling discount: $e');
    }
  }

  Future<void> _clearDiscount() async {
    if (_ownerVenue == null) return;
    try {
      setState(() { _isLoading = true; });
      await _supabase.from('venues').update({
        'discount_per_hour': _basePrice,
        'discount_start_date': null,
        'discount_end_date': null,
      }).eq('id', _ownerVenue!['id']);
      await _loadOwnerVenue();
      await _loadAppliedDiscounts();
      setState(() {
        _discountPrice = null;
        _discountStartDate = null;
        _discountEndDate = null;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Discount cleared'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      _showError('Error clearing discount: $e');
    }
  }

  Future<void> _selectDiscountDate(bool isStart) async {
    final now = DateTime.now();
    final firstSelectable = DateTime(now.year, now.month, now.day + 1);
    final initial = isStart
        ? (_discountStartDate ?? firstSelectable)
        : (_discountStartDate != null ? _discountStartDate!.add(const Duration(days: 1)) : firstSelectable);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: isStart ? firstSelectable : (_discountStartDate != null ? _discountStartDate!.add(const Duration(days: 1)) : firstSelectable),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _discountStartDate = picked;
        if (_discountEndDate != null && !_discountEndDate!.isAfter(picked)) {
          _discountEndDate = null;
        }
      } else {
        if (_discountStartDate != null && !picked.isAfter(_discountStartDate!)) {
          _showError('End date must be after start date');
          return;
        }
        _discountEndDate = picked;
      }
    });
  }

  void _updateBasePrice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(_basePriceController.text);
              if (newPrice == null || newPrice <= 0) {
                _showError('Enter valid price');
                return;
              }
              try {
                if (_ownerVenue != null) {
                  await _supabase.from('venues').update({
                    'price_per_hour': newPrice,
                    if (_discountPrice == null || _discountPrice == _basePrice) 'discount_per_hour': newPrice,
                  }).eq('id', _ownerVenue!['id']);
                }
                await _loadOwnerVenue();
              } catch (e) {
                _showError('Update failed: $e');
                return;
              }
              if (mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Base price updated'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Pricing'),
        backgroundColor: Colors.green[700],
        actions: const [OwnerProfileWidget()],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.price_change), text: 'Manage Pricing'),
            Tab(icon: Icon(Icons.list_alt), text: 'Scheduled Discounts'),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVenueInfoCard(),
          const SizedBox(height: 20),
          _buildBasePriceCard(),
          const SizedBox(height: 20),
          _buildDiscountSchedulerCard(),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _scheduleDiscount,
                  icon: _isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.schedule),
                  label: Text(_isLoading ? 'Scheduling...' : 'Schedule Discount'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (_isDiscountCurrentlyActive())
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _clearDiscount,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
            ],
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
              Text('Loading venue information...', style: TextStyle(color: Colors.grey[600])),
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
                const Expanded(
                  child: Text('Venue Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            _buildInfoRow(Icons.monetization_on, 'Base Price', '৳${_basePrice.toStringAsFixed(2)}/hour'),
            if (_isDiscountCurrentlyActive() && _discountPrice != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.local_offer, 'Effective Price', '৳${_discountPrice!.toStringAsFixed(2)}/hour'),
            ],
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
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value, style: TextStyle(color: Colors.grey[700]))),
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
                const Expanded(
                  child: Text('Current Base Price', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
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
                      const Text('Base Rate', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('৳${_basePrice.toStringAsFixed(0)}/hour', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700])),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _updateBasePrice,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], foregroundColor: Colors.white),
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
                const Expanded(child: Text('Schedule New Discount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Select Date Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDiscountDate(true),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _discountStartDate != null ? DateFormat('MMM dd, yyyy').format(_discountStartDate!) : 'Select Start Date',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDiscountDate(false),
                    icon: const Icon(Icons.event, size: 16),
                    label: Text(
                      _discountEndDate != null ? DateFormat('MMM dd, yyyy').format(_discountEndDate!) : 'Select End Date',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Discount Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _discountType,
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(value: 'percentage', child: Text('% Off')),
                      DropdownMenuItem(value: 'flat', child: Text('Flat Off')),
                    ],
                    onChanged: (v) => setState(() => _discountType = v!),
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Label / Reason (optional)',
                hintText: 'e.g., Independence Day Offer',
              ),
            ),
            const SizedBox(height: 12),
            if (_isDiscountCurrentlyActive()) _buildActiveDiscountBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledDiscountsTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentPricingCard(),
          const SizedBox(height: 20),
          const Text('Applied Discounts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_appliedDiscounts.isEmpty) _buildNoDiscountsCard() else ..._appliedDiscounts.map(_buildDiscountDisplayCard),
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
                const Text('Current Pricing Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (_ownerVenue != null) ...[
              Text('Venue: ${_ownerVenue!['name']}'),
              const SizedBox(height: 4),
              Text('Location: ${_ownerVenue!['address']}, ${_ownerVenue!['city']}'),
              const SizedBox(height: 4),
              Text('Current Price: ৳${_basePrice.toStringAsFixed(2)}/hour', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              if (_isDiscountCurrentlyActive() && _discountPrice != null)
                Text('Discounted: ৳${_discountPrice!.toStringAsFixed(2)}/hour', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600)),
            ] else ...[
              const Text('Loading venue information...'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoDiscountsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.discount_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('No discounts scheduled', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),
            const Text('Use the Manage Pricing tab to add one', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountDisplayCard(Map<String, dynamic> discount) {
    final originalPrice = (discount['original_price'] as num?)?.toDouble() ?? 0.0;
    final discountedPrice = (discount['discounted_price'] as num?)?.toDouble() ?? 0.0;
    final discountValue = (discount['discount_value'] as num?)?.toDouble() ?? 0.0;
    final discountType = discount['discount_type'] as String? ?? 'derived';
    final startDateIso = discount['start_date'];
    final endDateIso = discount['end_date'];
    final label = discount['label'] as String? ?? 'Discount';
    final startDate = startDateIso != null ? DateTime.parse(startDateIso) : null;
    final endDate = endDateIso != null ? DateTime.parse(endDateIso) : null;
    final discountText = discountType == 'percentage'
        ? '${discountValue.toInt()}% off'
        : discountType == 'flat'
            ? '৳${discountValue.toInt()} off'
            : '৳${(originalPrice - discountedPrice).toStringAsFixed(0)} off';
    final dateRange = startDate != null
        ? '${DateFormat('MMM dd').format(startDate)} - ${endDate != null ? DateFormat('MMM dd, yyyy').format(endDate) : 'Open'}'
        : 'N/A';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                if (_isDiscountCurrentlyActive() && discountedPrice == _discountPrice)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
                    child: Text('Active', style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text('৳${discountedPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(width: 12),
                Text('৳${originalPrice.toStringAsFixed(2)}', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey[600])),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(12)),
                  child: Text(discountText, style: TextStyle(color: Colors.orange[700], fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.blue[700]),
                const SizedBox(width: 6),
                Text('Valid: $dateRange'),
              ],
            ),
            if (discount['venue_name'] != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: Colors.red[700]),
                  const SizedBox(width: 6),
                  Expanded(child: Text('Venue: ${discount['venue_name']}')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDiscountBanner() {
    if (_discountPrice == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer, color: Colors.green[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Active discount: ৳${_discountPrice!.toStringAsFixed(2)} until '
                '${_discountEndDate != null ? DateFormat('MMM dd, yyyy').format(_discountEndDate!) : 'open-ended'}'),
          ),
        ],
      ),
    );
  }
}
