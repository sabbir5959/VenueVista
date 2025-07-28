import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/booking_maintenance_helper.dart';

class BookingCalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime startTime, DateTime endTime)? onTimeSlotSelected;

  const BookingCalendarWidget({
    Key? key,
    required this.selectedDate,
    this.onTimeSlotSelected,
  }) : super(key: key);

  @override
  State<BookingCalendarWidget> createState() => _BookingCalendarWidgetState();
}

class _BookingCalendarWidgetState extends State<BookingCalendarWidget> {
  List<Map<String, dynamic>> _unavailableSlots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnavailableSlots();
  }

  @override
  void didUpdateWidget(BookingCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadUnavailableSlots();
    }
  }

  Future<void> _loadUnavailableSlots() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final slots = await BookingMaintenanceHelper.getUnavailableSlots(widget.selectedDate);
      setState(() {
        _unavailableSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Available Time Slots - ${DateFormat('MMM dd, yyyy').format(widget.selectedDate)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildTimeSlots(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    const startHour = 6;
    const endHour = 22;
    const slotDuration = 2; // 2 hours per slot

    final slots = <Widget>[];

    for (int hour = startHour; hour < endHour; hour += slotDuration) {
      final slotStart = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        hour,
      );
      final slotEnd = slotStart.add(const Duration(hours: slotDuration));

      final isUnavailable = _isSlotUnavailable(slotStart, slotEnd);
      final maintenanceReason = _getMaintenanceReason(slotStart, slotEnd);

      slots.add(_buildTimeSlot(slotStart, slotEnd, isUnavailable, maintenanceReason));
    }

    return Column(children: slots);
  }

  Widget _buildTimeSlot(DateTime start, DateTime end, bool isUnavailable, String? maintenanceReason) {
    final timeText = '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: isUnavailable ? 0 : 1,
        borderRadius: BorderRadius.circular(8),
        color: isUnavailable ? Colors.red[50] : Colors.green[50],
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isUnavailable ? null : () {
            widget.onTimeSlotSelected?.call(start, end);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isUnavailable ? Colors.red[200]! : Colors.green[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isUnavailable ? Icons.block : Icons.access_time,
                  color: isUnavailable ? Colors.red[600] : Colors.green[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeText,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isUnavailable ? Colors.red[800] : Colors.green[800],
                        ),
                      ),
                      if (isUnavailable && maintenanceReason != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          maintenanceReason,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isUnavailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'MAINTENANCE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'AVAILABLE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isSlotUnavailable(DateTime start, DateTime end) {
    return _unavailableSlots.any((slot) {
      final slotStart = slot['startTime'] as DateTime;
      final slotEnd = slot['endTime'] as DateTime;
      
      // Check if there's any overlap
      return (start.isBefore(slotEnd) && end.isAfter(slotStart));
    });
  }

  String? _getMaintenanceReason(DateTime start, DateTime end) {
    for (final slot in _unavailableSlots) {
      final slotStart = slot['startTime'] as DateTime;
      final slotEnd = slot['endTime'] as DateTime;
      
      // Check if there's any overlap
      if (start.isBefore(slotEnd) && end.isAfter(slotStart)) {
        return slot['reason'] as String? ?? 'Maintenance in progress';
      }
    }
    return null;
  }
}

// Example usage widget
class BookingExamplePage extends StatefulWidget {
  const BookingExamplePage({Key? key}) : super(key: key);

  @override
  State<BookingExamplePage> createState() => _BookingExamplePageState();
}

class _BookingExamplePageState extends State<BookingExamplePage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Calendar'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Date Picker
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.date_range),
                    const SizedBox(width: 12),
                    const Text('Select Date: '),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                    ),
                  ],
                ),
              ),
            ),
            
            // Booking Calendar
            BookingCalendarWidget(
              selectedDate: _selectedDate,
              onTimeSlotSelected: (start, end) {
                _showBookingDialog(start, end);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(DateTime start, DateTime end) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text(
          'Book ground from ${DateFormat('MMM dd, HH:mm').format(start)} to ${DateFormat('HH:mm').format(end)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking confirmed!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
