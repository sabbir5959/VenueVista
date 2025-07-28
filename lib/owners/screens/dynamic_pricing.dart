import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/venue_owner_sidebar.dart';
import '../models/discount_schedule.dart';
import '../services/dynamic_pricing_service.dart';

class DynamicPricingPage extends StatefulWidget {
  const DynamicPricingPage({Key? key}) : super(key: key);

  @override
  State<DynamicPricingPage> createState() => _DynamicPricingPageState();
}

class _DynamicPricingPageState extends State<DynamicPricingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DynamicPricingService _pricingService = DynamicPricingService.instance;
  
  // Base price
  double _basePrice = 500.0;
  final TextEditingController _basePriceController = TextEditingController();
  
  // Discount form controllers
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final TextEditingController _discountValueController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  String _discountType = 'percentage'; // 'percentage' or 'flat'
  
  // Settings
  bool _applyToIndividualBookings = true;
  bool _applyToTeamBookings = true;
  bool _allowOverlappingDiscounts = false;
  
  // Data
  List<DiscountSchedule> _discountSchedules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _basePriceController.text = _basePrice.toString();
    _loadDiscountSchedules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _basePriceController.dispose();
    _discountValueController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _loadDiscountSchedules() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final schedules = await _pricingService.getAllDiscountSchedules();
      final basePrice = await _pricingService.getBasePrice();
      setState(() {
        _discountSchedules = schedules;
        _basePrice = basePrice;
        _basePriceController.text = _basePrice.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading discount schedules: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Pricing'),
        backgroundColor: Colors.green[700],
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
          // Current Base Price Display
          _buildBasePriceCard(),
          
          const SizedBox(height: 20),
          
          // Discount Scheduler
          _buildDiscountSchedulerCard(),
          
          const SizedBox(height: 20),
          
          // Rules & Controls
          _buildRulesControlsCard(),
          
          const SizedBox(height: 30),
          
          // Schedule Discount Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _scheduleDiscount,
              icon: const Icon(Icons.schedule),
              label: const Text('Schedule Discount'),
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
                const Text(
                  'Current Base Price',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                const Text(
                  'Schedule New Discount',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _startDate != null
                          ? DateFormat('MMM dd, yyyy').format(_startDate!)
                          : 'Start Date',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      foregroundColor: Colors.green[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(false),
                    icon: const Icon(Icons.event),
                    label: Text(
                      _endDate != null
                          ? DateFormat('MMM dd, yyyy').format(_endDate!)
                          : 'End Date (Optional)',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      foregroundColor: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Time Selection
            const Text(
              'Select Time Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectTime(true),
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      _startTime != null
                          ? _startTime!.format(context)
                          : 'From Time',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      foregroundColor: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectTime(false),
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      _endTime != null
                          ? _endTime!.format(context)
                          : 'To Time',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      foregroundColor: Colors.blue[700],
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
                      DropdownMenuItem(value: 'flat', child: Text('Flat Amount Off')),
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
                hintText: 'e.g., "Independence Day Special", "Morning Rush"',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesControlsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.purple[700], size: 30),
                const SizedBox(width: 12),
                const Text(
                  'Rules & Controls',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Apply to Individual Bookings'),
              subtitle: const Text('Single user bookings will get discount'),
              value: _applyToIndividualBookings,
              onChanged: (value) {
                setState(() {
                  _applyToIndividualBookings = value;
                });
              },
              activeColor: Colors.green[700],
            ),
            
            SwitchListTile(
              title: const Text('Apply to Team Bookings/Tournaments'),
              subtitle: const Text('Group bookings and tournaments will get discount'),
              value: _applyToTeamBookings,
              onChanged: (value) {
                setState(() {
                  _applyToTeamBookings = value;
                });
              },
              activeColor: Colors.green[700],
            ),
            
            SwitchListTile(
              title: const Text('Allow Overlapping Discounts'),
              subtitle: const Text('Multiple discounts can apply to same time slot'),
              value: _allowOverlappingDiscounts,
              onChanged: (value) {
                setState(() {
                  _allowOverlappingDiscounts = value;
                });
              },
              activeColor: Colors.green[700],
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

    final futureDiscounts = _discountSchedules.where((discount) {
      return discount.startDate.isAfter(DateTime.now());
    }).toList();

    if (futureDiscounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.discount,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No scheduled discounts',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first discount to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheduled Discounts (${futureDiscounts.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          ...futureDiscounts.map((discount) => _buildDiscountCard(discount)).toList(),
        ],
      ),
    );
  }

  Widget _buildDiscountCard(DiscountSchedule discount) {
    final isPercentage = discount.discountType == DiscountType.percentage;
    final discountText = isPercentage 
        ? '${discount.discountValue.toStringAsFixed(0)}% Off'
        : '৳${discount.discountValue.toStringAsFixed(0)} Off';
    
    final dateText = discount.endDate != null
        ? '${DateFormat('MMM dd').format(discount.startDate)} - ${DateFormat('MMM dd, yyyy').format(discount.endDate!)}'
        : DateFormat('MMM dd, yyyy').format(discount.startDate);
    
    final timeText = '${discount.startTime.format(context)} - ${discount.endTime.format(context)}';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPercentage ? Colors.orange[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    discountText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPercentage ? Colors.orange[700] : Colors.blue[700],
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editDiscount(discount);
                    } else if (value == 'delete') {
                      _deleteDiscount(discount.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (discount.label.isNotEmpty) ...[
              Text(
                discount.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(dateText, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(timeText, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            if (discount.applyToIndividual || discount.applyToTeams) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (discount.applyToIndividual)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Individual',
                        style: TextStyle(fontSize: 12, color: Colors.green[700]),
                      ),
                    ),
                  if (discount.applyToTeams)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Teams',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime now = DateTime.now();
    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? tomorrow : (_startDate ?? tomorrow),
      firstDate: tomorrow,
      lastDate: DateTime(now.year + 2),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // Reset end date if it's before the new start date
          if (_endDate != null && _endDate!.isBefore(pickedDate)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime 
          ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 17, minute: 0)),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
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
    
    if (_startTime == null || _endTime == null) {
      _showError('Please select both start and end times');
      return;
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
        startTime: _startTime!,
        endTime: _endTime!,
        discountType: _discountType == 'percentage' ? DiscountType.percentage : DiscountType.flat,
        discountValue: discountValue,
        label: _labelController.text,
        applyToIndividual: _applyToIndividualBookings,
        applyToTeams: _applyToTeamBookings,
        allowOverlapping: _allowOverlappingDiscounts,
      );

      await _pricingService.addDiscountSchedule(newDiscount);
      await _loadDiscountSchedules();

      // Clear form
      setState(() {
        _startDate = null;
        _endDate = null;
        _startTime = null;
        _endTime = null;
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

  void _editDiscount(DiscountSchedule discount) {
    // Implementation for editing discount
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Discount'),
        content: const Text('Edit functionality would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteDiscount(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Discount'),
        content: const Text('Are you sure you want to delete this discount schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _pricingService.deleteDiscountSchedule(id);
                await _loadDiscountSchedules();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Discount deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                _showError('Error deleting discount: $e');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
