import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/maintenance_schedule.dart';

class MaintenanceService {
  static const String _maintenanceKey = 'maintenance_schedules';
  static MaintenanceService? _instance;
  
  MaintenanceService._();
  
  static MaintenanceService get instance {
    _instance ??= MaintenanceService._();
    return _instance!;
  }

  // Get all maintenance schedules
  Future<List<MaintenanceSchedule>> getAllMaintenanceSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String? schedulesJson = prefs.getString(_maintenanceKey);
    
    if (schedulesJson == null) {
      return [];
    }
    
    final List<dynamic> schedulesList = json.decode(schedulesJson);
    return schedulesList
        .map((json) => MaintenanceSchedule.fromMap(json))
        .toList();
  }

  // Save maintenance schedules
  Future<void> saveMaintenanceSchedules(List<MaintenanceSchedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final String schedulesJson = json.encode(
      schedules.map((schedule) => schedule.toMap()).toList(),
    );
    await prefs.setString(_maintenanceKey, schedulesJson);
  }

  // Add a new maintenance schedule
  Future<void> addMaintenanceSchedule(MaintenanceSchedule schedule) async {
    final schedules = await getAllMaintenanceSchedules();
    schedules.add(schedule);
    await saveMaintenanceSchedules(schedules);
  }

  // Update an existing maintenance schedule
  Future<void> updateMaintenanceSchedule(MaintenanceSchedule updatedSchedule) async {
    final schedules = await getAllMaintenanceSchedules();
    final index = schedules.indexWhere((s) => s.id == updatedSchedule.id);
    
    if (index != -1) {
      schedules[index] = updatedSchedule;
      await saveMaintenanceSchedules(schedules);
    }
  }

  // Delete a maintenance schedule
  Future<void> deleteMaintenanceSchedule(int id) async {
    final schedules = await getAllMaintenanceSchedules();
    schedules.removeWhere((schedule) => schedule.id == id);
    await saveMaintenanceSchedules(schedules);
  }

  // Get maintenance schedules by status
  Future<List<MaintenanceSchedule>> getMaintenanceSchedulesByStatus(MaintenanceStatus status) async {
    final allSchedules = await getAllMaintenanceSchedules();
    final now = DateTime.now();
    
    return allSchedules.where((schedule) {
      switch (status) {
        case MaintenanceStatus.upcoming:
          return schedule.startTime.isAfter(now);
        case MaintenanceStatus.ongoing:
          return schedule.startTime.isBefore(now) && schedule.endTime.isAfter(now);
        case MaintenanceStatus.past:
          return schedule.endTime.isBefore(now);
      }
    }).toList();
  }

  // Check if bookings should be disabled at a specific time
  Future<bool> isBookingDisabledAt(DateTime bookingTime) async {
    final allSchedules = await getAllMaintenanceSchedules();
    
    return allSchedules.any((schedule) => schedule.blocksBookingAt(bookingTime));
  }

  // Get active maintenance (currently ongoing)
  Future<List<MaintenanceSchedule>> getActiveMaintenance() async {
    return await getMaintenanceSchedulesByStatus(MaintenanceStatus.ongoing);
  }

  // Get maintenance reason for a specific time (if any)
  Future<String?> getMaintenanceReasonAt(DateTime bookingTime) async {
    final allSchedules = await getAllMaintenanceSchedules();
    
    for (final schedule in allSchedules) {
      if (schedule.blocksBookingAt(bookingTime)) {
        return schedule.reason ?? 'Maintenance in progress';
      }
    }
    
    return null;
  }

  // Generate recurring maintenance schedules
  List<MaintenanceSchedule> generateRecurringSchedules(
    MaintenanceSchedule baseSchedule,
    int occurrences,
    String frequency,
  ) {
    final schedules = <MaintenanceSchedule>[];
    var currentStart = baseSchedule.startTime;
    var currentEnd = baseSchedule.endTime;
    
    Duration interval;
    switch (frequency.toLowerCase()) {
      case 'week':
        interval = const Duration(days: 7);
        break;
      case 'biweekly':
        interval = const Duration(days: 14);
        break;
      case 'monthly':
        interval = const Duration(days: 30);
        break;
      default:
        interval = const Duration(days: 7);
    }
    
    for (int i = 0; i < occurrences; i++) {
      schedules.add(MaintenanceSchedule(
        id: DateTime.now().millisecondsSinceEpoch + i,
        startTime: currentStart,
        endTime: currentEnd,
        reason: baseSchedule.reason,
        status: MaintenanceSchedule.getStatusForTime(currentStart, currentEnd),
        isRepeating: true,
        repeatFrequency: frequency,
      ));
      
      currentStart = currentStart.add(interval);
      currentEnd = currentEnd.add(interval);
    }
    
    return schedules;
  }

  // Get maintenance schedules that conflict with a proposed booking time
  Future<List<MaintenanceSchedule>> getConflictingMaintenance(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final allSchedules = await getAllMaintenanceSchedules();
    
    return allSchedules.where((schedule) {
      // Check if there's any overlap between the booking time and maintenance
      return (startTime.isBefore(schedule.endTime) && endTime.isAfter(schedule.startTime));
    }).toList();
  }

  // Clean up past maintenance schedules (optional maintenance)
  Future<void> cleanupPastMaintenance({int daysToKeep = 30}) async {
    final allSchedules = await getAllMaintenanceSchedules();
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    
    final filteredSchedules = allSchedules.where((schedule) {
      return schedule.endTime.isAfter(cutoffDate);
    }).toList();
    
    await saveMaintenanceSchedules(filteredSchedules);
  }

  // Get upcoming maintenance within next N days
  Future<List<MaintenanceSchedule>> getUpcomingMaintenance({int days = 7}) async {
    final allSchedules = await getAllMaintenanceSchedules();
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    
    return allSchedules.where((schedule) {
      return schedule.startTime.isAfter(now) && schedule.startTime.isBefore(futureDate);
    }).toList();
  }
}
