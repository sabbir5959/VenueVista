import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/discount_schedule.dart';
import '../services/dynamic_pricing_service.dart';

class EditSchedulePage extends StatefulWidget {
  final DiscountSchedule schedule;

  const EditSchedulePage({Key? key, required this.schedule}) : super(key: key);

  @override
  State<EditSchedulePage> createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final DynamicPricingService _pricingService = DynamicPricingService.instance;
  
  // Form controllers
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final TextEditingController _discountValueController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  String _discountType = 'percentage';
  bool _applyToIndividual = true;
  bool _applyToTeams = true;
  bool _allowOverlapping = false;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _populateFormWithScheduleData();
  }

  void _populateFormWithScheduleData() {
    final schedule = widget.schedule;
    setState(() {
      _startDate = schedule.startDate;
      _endDate = schedule.endDate;
      _startTime = schedule.startTime;
      _endTime = schedule.endTime;
      _discountValueController.text = schedule.discountValue.toString();
      _labelController.text = schedule.label;
      _discountType = schedule.discountType == DiscountType.percentage ? 'percentage' : 'flat';
      _applyToIndividual = schedule.applyToIndividual;
      _applyToTeams = schedule.applyToTeams;
      _allowOverlapping = schedule.allowOverlapping;
    });
  }

  @override
  void dispose() {
    _discountValueController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime now = DateTime.now();
    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_startDate ?? tomorrow)
          : (_endDate ?? _startDate ?? tomorrow),
      firstDate: tomorrow,
      lastDate: DateTime(now.year + 2),
      helpText: isStartDate ? 'Select Start Date' : 'Select End Date',
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Reset end date if it's before the new start date
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime 
          ? (_startTime ?? const TimeOfDay(hour: 8, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 22, minute: 0)),
      helpText: isStartTime ? 'Select Start Time' : 'Select End Time',
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _updateSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validation
    if (_startDate == null) {
      _showError('Please select a start date');
      return;
    }
    
    if (_startTime == null || _endTime == null) {
      _showError('Please select start and end times');
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

    if (!_applyToIndividual && !_applyToTeams) {
      _showError('Discount must apply to at least one booking type');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedSchedule = DiscountSchedule(
        id: widget.schedule.id,
        startDate: _startDate!,
        endDate: _endDate,
        startTime: _startTime!,
        endTime: _endTime!,
        discountType: _discountType == 'percentage' ? DiscountType.percentage : DiscountType.flat,
        discountValue: discountValue,
        label: _labelController.text.trim(),
        applyToIndividual: _applyToIndividual,
        applyToTeams: _applyToTeams,
        allowOverlapping: _allowOverlapping,
        createdAt: widget.schedule.createdAt,
      );

      // Update using service
      await _pricingService.updateDiscountSchedule(updatedSchedule);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      _showError('Error updating schedule: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Schedule'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.edit_calendar, 
                           color: Colors.green[700], 
                           size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edit Discount Schedule',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Modify the details of your discount schedule',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Date Selection Section
              _buildSectionCard(
                title: 'Date Range',
                icon: Icons.date_range,
                children: [
                  const Text(
                    'Select the date range for this discount',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(true),
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            _startDate != null
                                ? DateFormat('MMM dd, yyyy').format(_startDate!)
                                : 'Start Date',
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            foregroundColor: Colors.green[700],
                            side: BorderSide(
                              color: _startDate != null ? Colors.green[700]! : Colors.grey,
                              width: _startDate != null ? 2 : 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(false),
                          icon: const Icon(Icons.event, size: 18),
                          label: Text(
                            _endDate != null
                                ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                : 'End Date (Optional)',
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            foregroundColor: Colors.green[700],
                            side: BorderSide(
                              color: _endDate != null ? Colors.green[700]! : Colors.grey,
                              width: _endDate != null ? 2 : 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /* // Time Selection Section
              _buildSectionCard(
                title: 'Time Range',
                icon: Icons.access_time,
                children: [
                  const Text(
                    'Select the time range for this discount',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectTime(true),
                          icon: const Icon(Icons.schedule, size: 18),
                          label: Text(
                            _startTime != null
                                ? _startTime!.format(context)
                                : 'Start Time',
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            foregroundColor: Colors.blue[700],
                            side: BorderSide(
                              color: _startTime != null ? Colors.blue[700]! : Colors.grey,
                              width: _startTime != null ? 2 : 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectTime(false),
                          icon: const Icon(Icons.timer, size: 18),
                          label: Text(
                            _endTime != null
                                ? _endTime!.format(context)
                                : 'End Time',
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            foregroundColor: Colors.blue[700],
                            side: BorderSide(
                              color: _endTime != null ? Colors.blue[700]! : Colors.grey,
                              width: _endTime != null ? 2 : 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),*/

              const SizedBox(height: 16),

              // Discount Details Section
              _buildSectionCard(
                title: 'Discount Details',
                icon: Icons.local_offer,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _discountType,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Discount Type',
                            prefixIcon: const Icon(Icons.percent),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green[700]!),
                            ),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select discount type';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _discountValueController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: _discountType == 'percentage' ? 'Percentage (%)' : 'Amount (৳)',
                            hintText: _discountType == 'percentage' ? 'e.g., 20' : 'e.g., 100',
                            prefixIcon: Icon(_discountType == 'percentage' ? Icons.percent : Icons.attach_money),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green[700]!),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter value';
                            }
                            final number = double.tryParse(value);
                            if (number == null || number <= 0) {
                              return 'Enter valid number';
                            }
                            if (_discountType == 'percentage' && number >= 100) {
                              return 'Must be < 100%';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _labelController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Label/Reason (Optional)',
                      hintText: 'e.g., "Weekend Special", "Holiday Discount"',
                      prefixIcon: const Icon(Icons.label),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green[700]!),
                      ),
                    ),
                    maxLength: 50,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Apply To Section
              _buildSectionCard(
                title: 'Apply To',
                icon: Icons.group,
                children: [
                  const Text(
                    'Choose which booking types this discount applies to',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Individual Bookings'),
                    subtitle: const Text('Apply discount to single player bookings'),
                    value: _applyToIndividual,
                    onChanged: (value) {
                      setState(() {
                        _applyToIndividual = value ?? false;
                      });
                    },
                    activeColor: Colors.green[700],
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    title: const Text('Team Bookings'),
                    subtitle: const Text('Apply discount to team/group bookings'),
                    value: _applyToTeams,
                    onChanged: (value) {
                      setState(() {
                        _applyToTeams = value ?? false;
                      });
                    },
                    activeColor: Colors.green[700],
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Advanced Options Section
              // _buildSectionCard(
              //   title: 'Advanced Options',
              //   icon: Icons.settings,
              //   children: [
              //     SwitchListTile(
              //       title: const Text('Allow Overlapping'),
              //       subtitle: const Text('Allow this discount to overlap with other discounts'),
              //       value: _allowOverlapping,
              //       onChanged: (value) {
              //         setState(() {
              //           _allowOverlapping = value;
              //         });
              //       },
              //       activeColor: Colors.green[700],
              //     ),
              //   ],
              // ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _updateSchedule,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isLoading ? 'Updating...' : 'Update Schedule'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green[700], size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
