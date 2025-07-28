import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/maintenance_schedule.dart';
import '../services/maintenance_service.dart';
import '../widgets/booking_calendar_widget.dart';
import '../widgets/venue_owner_sidebar.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({Key? key}) : super(key: key);

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MaintenanceService _maintenanceService = MaintenanceService.instance;
  
  // Form controllers
  DateTime? _startDateTime;
  DateTime? _endDateTime;
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BookingExamplePage(),
            ),
          );
        },
        backgroundColor: Colors.blue[700],
        icon: const Icon(Icons.calendar_month),
        label: const Text('Test Booking'),
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
                  const Text(
                    'Schedule a Maintenance Break',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  
                  // Start Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDateTime(true),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _startDateTime != null
                                ? DateFormat('MMM dd, yyyy - HH:mm').format(_startDateTime!)
                                : 'Select Start Time',
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
                  
                  // End Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDateTime(false),
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            _endDateTime != null
                                ? DateFormat('MMM dd, yyyy - HH:mm').format(_endDateTime!)
                                : 'Select End Time',
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
                      const Text(
                        'Repeat This Maintenance',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
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
                        const Text('Repeat every: '),
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
                          title: Text('End after $_repeatOccurrences occurrences'),
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
                                const Text('Occurrences: '),
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
                          title: const Text('End on specific date'),
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
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.grey[100],
            child: const TabBar(
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs: [
                Tab(text: 'Upcoming'),
                Tab(text: 'Ongoing'),
                Tab(text: 'Past'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMaintenanceList('upcoming'),
                _buildMaintenanceList('ongoing'),
                _buildMaintenanceList('past'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceList(String status) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final MaintenanceStatus statusEnum = status == 'upcoming' 
        ? MaintenanceStatus.upcoming 
        : status == 'ongoing' 
            ? MaintenanceStatus.ongoing 
            : MaintenanceStatus.past;
    
    final now = DateTime.now();
    final filteredList = _maintenanceSchedules.where((schedule) {
      switch (statusEnum) {
        case MaintenanceStatus.upcoming:
          return schedule.startTime.isAfter(now);
        case MaintenanceStatus.ongoing:
          return schedule.startTime.isBefore(now) && schedule.endTime.isAfter(now);
        case MaintenanceStatus.past:
          return schedule.endTime.isBefore(now);
      }
    }).toList();
    
    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'upcoming' ? Icons.schedule : 
              status == 'ongoing' ? Icons.build : Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${status} maintenance',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final maintenance = filteredList[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(status).withOpacity(0.2),
              child: Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
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
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat('MMM dd, HH:mm').format(maintenance.startTime)} - ${DateFormat('HH:mm').format(maintenance.endTime)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                if (maintenance.isRepeating) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.repeat, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Repeats ${maintenance.repeatFrequency}',
                        style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: status == 'upcoming' ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editMaintenance(maintenance),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteMaintenance(maintenance.id),
                ),
              ],
            ) : null,
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.orange;
      case 'past':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'upcoming':
        return Icons.schedule;
      case 'ongoing':
        return Icons.build;
      case 'past':
        return Icons.history;
      default:
        return Icons.build;
    }
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStartTime) {
            _startDateTime = selectedDateTime;
            // Auto-set end time to 2 hours later if not set
            if (_endDateTime == null) {
              _endDateTime = selectedDateTime.add(const Duration(hours: 2));
            }
          } else {
            _endDateTime = selectedDateTime;
          }
        });
      }
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
    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end times'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDateTime!.isBefore(_startDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newMaintenance = MaintenanceSchedule(
        id: DateTime.now().millisecondsSinceEpoch,
        startTime: _startDateTime!,
        endTime: _endDateTime!,
        reason: _reasonController.text.isNotEmpty ? _reasonController.text : null,
        status: MaintenanceSchedule.getStatusForTime(_startDateTime!, _endDateTime!),
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
        _startDateTime = null;
        _endDateTime = null;
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
