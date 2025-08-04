import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/maintenance_schedule.dart';
import '../services/maintenance_service.dart';
import '../widgets/venue_owner_sidebar.dart';
import '../widgets/owner_profile_widget.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({Key? key}) : super(key: key);

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MaintenanceService _maintenanceService = MaintenanceService.instance;
  
  // Form controllers
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _reasonController = TextEditingController();
  bool _isRepeating = false;
  String _repeatFrequency = 'Week';
  int _repeatOccurrences = 1;
  DateTime? _repeatEndDate;
  bool _useOccurrences = true;

  // Loading states
  bool _isLoading = false;
  List<MaintenanceSchedule> _maintenanceSchedules = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMaintenanceSchedules();
  }

  Future<void> _loadMaintenanceSchedules() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final schedules = await _maintenanceService.getAllMaintenanceSchedules();
      setState(() {
        _maintenanceSchedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading maintenance schedules: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Schedule'),
        backgroundColor: Colors.green[700],
        actions: [
          OwnerProfileWidget(),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.add_circle_outline),
              text: 'Schedule Maintenance',
            ),
            Tab(
              icon: Icon(Icons.calendar_today),
              text: 'View Schedule',
            ),
          ],
        ),
      ),
      drawer: const VenueOwnerSidebar(currentPage: 'maintenance'),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScheduleMaintenanceTab(),
          _buildViewScheduleTab(),
        ],
      ),
    );
  }

  Widget _buildScheduleMaintenanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.build_circle, color: Colors.green[700], size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Schedule a Maintenance Break',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // Date & Time Picker Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Maintenance Period',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  
                  // Start Date
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(true),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _startDate != null
                                ? DateFormat('MMM dd, yyyy').format(_startDate!)
                                : 'Select Start Date',
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            foregroundColor: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // End Date
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(false),
                          icon: const Icon(Icons.event),
                          label: Text(
                            _endDate != null
                                ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                : 'Select End Date',
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            foregroundColor: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Reason Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_note, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Reason for Maintenance (Optional)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'E.g., Grass trimming, light repair, net change...',
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Repeat Maintenance Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.repeat, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Repeat This Maintenance',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Switch(
                        value: _isRepeating,
                        onChanged: (value) {
                          setState(() {
                            _isRepeating = value;
                          });
                        },
                        activeColor: Colors.green[700],
                      ),
                    ],
                  ),
                  
                  if (_isRepeating) ...[
                    const SizedBox(height: 16),
                    
                    // Repeat Frequency
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Repeat every: ',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _repeatFrequency,
                            isExpanded: true,
                            items: ['Week', 'Biweekly', 'Monthly'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _repeatFrequency = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // End Options
                    Column(
                      children: [
                        RadioListTile<bool>(
                          title: Text(
                            'End after $_repeatOccurrences occurrences',
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: true,
                          groupValue: _useOccurrences,
                          onChanged: (bool? value) {
                            setState(() {
                              _useOccurrences = value!;
                            });
                          },
                          activeColor: Colors.green[700],
                        ),
                        if (_useOccurrences)
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Occurrences: ',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 80,
                                  child: TextFormField(
                                    initialValue: _repeatOccurrences.toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    ),
                                    onChanged: (value) {
                                      _repeatOccurrences = int.tryParse(value) ?? 1;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        RadioListTile<bool>(
                          title: const Text(
                            'End on specific date',
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: false,
                          groupValue: _useOccurrences,
                          onChanged: (bool? value) {
                            setState(() {
                              _useOccurrences = value!;
                            });
                          },
                          activeColor: Colors.green[700],
                        ),
                        if (!_useOccurrences)
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: OutlinedButton.icon(
                              onPressed: () => _selectRepeatEndDate(),
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                _repeatEndDate != null
                                    ? DateFormat('MMM dd, yyyy').format(_repeatEndDate!)
                                    : 'Select End Date',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Schedule Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _scheduleMainenance,
              icon: const Icon(Icons.schedule),
              label: const Text('Schedule Maintenance'),
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

  Widget _buildViewScheduleTab() {
    return _buildMaintenanceList();
  }

  Widget _buildMaintenanceList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_maintenanceSchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No maintenance scheduled',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Schedule your first maintenance to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Sort maintenance schedules in descending order by start date (latest first)
    final sortedList = List<MaintenanceSchedule>.from(_maintenanceSchedules);
    sortedList.sort((a, b) => b.startTime.compareTo(a.startTime));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedList.length,
      itemBuilder: (context, index) {
        final maintenance = sortedList[index];
        final now = DateTime.now();
        
        // Determine status dynamically (only Ongoing or Completed)
        final bool isCompleted = maintenance.endTime.isBefore(now);
        
        String statusText;
        Color statusColor;
        IconData statusIcon;
        
        if (!isCompleted) {
          // Current ongoing maintenance or future maintenance (treat as ongoing)
          statusText = 'Ongoing';
          statusColor = Colors.red;
          statusIcon = Icons.build;
        } else {
          // Completed maintenance
          statusText = 'Completed';
          statusColor = Colors.green;
          statusIcon = Icons.check_circle;
        }
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(
                statusIcon,
                color: statusColor,
              ),
            ),
            title: Text(
              maintenance.reason ?? 'Maintenance',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${DateFormat('MMM dd, yyyy').format(maintenance.startTime)} - ${DateFormat('MMM dd, yyyy').format(maintenance.endTime)}',
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (maintenance.isRepeating) const SizedBox(height: 4),
                if (maintenance.isRepeating) Row(
                  children: [
                    const Icon(Icons.repeat, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Repeats ${maintenance.repeatFrequency}',
                        style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                // Edit/Delete buttons only for non-completed maintenance
                if (!isCompleted) const SizedBox(width: 8),
                if (!isCompleted) IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _editMaintenance(maintenance),
                ),
                if (!isCompleted) IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _deleteMaintenance(maintenance.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // Auto-set end date to same day if not set
          if (_endDate == null) {
            _endDate = pickedDate;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _selectRepeatEndDate() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (pickedDate != null) {
      setState(() {
        _repeatEndDate = pickedDate;
      });
    }
  }

  void _scheduleMainenance() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be after or same as start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // DateTime objects with full day coverage (00:00 to 23:59)
      final startDateTime = DateTime(_startDate!.year, _startDate!.month, _startDate!.day, 0, 0);
      final endDateTime = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59);
      
      final newMaintenance = MaintenanceSchedule(
        id: DateTime.now().millisecondsSinceEpoch,
        startTime: startDateTime,
        endTime: endDateTime,
        reason: _reasonController.text.isNotEmpty ? _reasonController.text : null,
        status: MaintenanceSchedule.getStatusForTime(startDateTime, endDateTime),
        isRepeating: _isRepeating,
        repeatFrequency: _isRepeating ? _repeatFrequency : null,
        repeatOccurrences: _isRepeating && _useOccurrences ? _repeatOccurrences : null,
        repeatEndDate: _isRepeating && !_useOccurrences ? _repeatEndDate : null,
      );

      if (_isRepeating && _useOccurrences) {
        // Generate recurring schedules
        final recurringSchedules = _maintenanceService.generateRecurringSchedules(
          newMaintenance,
          _repeatOccurrences,
          _repeatFrequency,
        );
        
        for (final schedule in recurringSchedules) {
          await _maintenanceService.addMaintenanceSchedule(schedule);
        }
      } else {
        await _maintenanceService.addMaintenanceSchedule(newMaintenance);
      }

      // Reload schedules
      await _loadMaintenanceSchedules();

      // Clear form
      setState(() {
        _startDate = null;
        _endDate = null;
        _reasonController.clear();
        _isRepeating = false;
        _repeatFrequency = 'Week';
        _repeatOccurrences = 1;
        _repeatEndDate = null;
        _useOccurrences = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maintenance scheduled successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Switch to view schedule tab
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scheduling maintenance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editMaintenance(MaintenanceSchedule maintenance) {
    // Implementation for editing maintenance
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Maintenance'),
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

  void _deleteMaintenance(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Maintenance'),
        content: const Text('Are you sure you want to delete this maintenance schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              setState(() {
                _isLoading = true;
              });
              
              try {
                await _maintenanceService.deleteMaintenanceSchedule(id);
                await _loadMaintenanceSchedules();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Maintenance deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting maintenance: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
