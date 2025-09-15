import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/maintenance_schedule.dart';

class MaintenanceService {
  static MaintenanceService? _instance;
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  MaintenanceService._();
  
  static MaintenanceService get instance {
    _instance ??= MaintenanceService._();
    return _instance!;
  }

  // Get all maintenance schedules from database
  Future<List<MaintenanceSchedule>> getAllMaintenanceSchedules() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('venues')
          .select('maintenance_reason, maintenance_start, maintenance_end')
          .eq('owner_id', user.id)
          .not('maintenance_reason', 'is', null);

      List<MaintenanceSchedule> schedules = [];
      for (var item in response) {
        if (item['maintenance_start'] != null && item['maintenance_end'] != null) {
          schedules.add(MaintenanceSchedule(
            id: DateTime.now().millisecondsSinceEpoch,
            startTime: DateTime.parse(item['maintenance_start']),
            endTime: DateTime.parse(item['maintenance_end']),
            reason: item['maintenance_reason'],
            status: MaintenanceSchedule.getStatusForTime(
              DateTime.parse(item['maintenance_start']),
              DateTime.parse(item['maintenance_end']),
            ),
            isRepeating: false,
          ));
        }
      }
      return schedules;
    } catch (e) {
      print('Error loading maintenance schedules: $e');
      return [];
    }
  }

  // This method is kept for compatibility but now only returns the database schedules
  Future<void> saveMaintenanceSchedules(List<MaintenanceSchedule> schedules) async {
    // No longer needed since we store directly in venues table
  }

  // Add a new maintenance schedule (updates venue table)
  Future<void> addMaintenanceSchedule(MaintenanceSchedule schedule) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('venues')
          .update({
        'maintenance_reason': schedule.reason,
        'maintenance_start': schedule.startTime.toIso8601String().split('T')[0],
        'maintenance_end': schedule.endTime.toIso8601String().split('T')[0],
        'status': 'maintenance',
      })
          .eq('owner_id', user.id);
    } catch (e) {
      print('Error adding maintenance schedule: $e');
      rethrow;
    }
  }

  // Update an existing maintenance schedule
  Future<void> updateMaintenanceSchedule(MaintenanceSchedule updatedSchedule) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('venues')
          .update({
        'maintenance_reason': updatedSchedule.reason,
        'maintenance_start': updatedSchedule.startTime.toIso8601String().split('T')[0],
        'maintenance_end': updatedSchedule.endTime.toIso8601String().split('T')[0],
      })
          .eq('owner_id', user.id);
    } catch (e) {
      print('Error updating maintenance schedule: $e');
      rethrow;
    }
  }

  // Delete/clear maintenance schedule
  Future<void> deleteMaintenanceSchedule(int id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('venues')
          .update({
        'maintenance_reason': null,
        'maintenance_start': null,
        'maintenance_end': null,
        'status': 'active',
      })
          .eq('owner_id', user.id);
    } catch (e) {
      print('Error deleting maintenance schedule: $e');
      rethrow;
    }
  }

  // Check for tournament conflicts in a date range
  Future<List<Map<String, dynamic>>> checkTournamentConflicts(DateTime startDate, DateTime endDate) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      // Get user's venue ID
      final venueResponse = await _supabase
          .from('venues')
          .select('id')
          .eq('owner_id', user.id)
          .single();

      final venueId = venueResponse['id'];

      // Check for tournaments in the maintenance date range
      final tournamentResponse = await _supabase
          .from('tournaments')
          .select('*')
          .eq('venue_id', venueId)
          .gte('tournament_date', startDate.toIso8601String().split('T')[0])
          .lte('tournament_date', endDate.toIso8601String().split('T')[0]);

      return List<Map<String, dynamic>>.from(tournamentResponse);
    } catch (e) {
      print('Error checking tournament conflicts: $e');
      return [];
    }
  }

  // Check if maintenance blocks tournament scheduling for a specific date
  Future<bool> isMaintenanceScheduledOn(DateTime date, String venueId) async {
    try {
      final response = await _supabase
          .from('venues')
          .select('maintenance_start, maintenance_end')
          .eq('id', venueId)
          .not('maintenance_start', 'is', null)
          .not('maintenance_end', 'is', null)
          .single();

      if (response.isEmpty) return false;

      final startDate = DateTime.parse(response['maintenance_start']);
      final endDate = DateTime.parse(response['maintenance_end']);
      
      return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             date.isBefore(endDate.add(const Duration(days: 1)));
    } catch (e) {
      return false;
    }
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
