import '../models/maintenance_schedule.dart';
import '../services/maintenance_service.dart';

class BookingMaintenanceHelper {
  static final MaintenanceService _maintenanceService = MaintenanceService.instance;

  /// Check if a booking time slot is available (not blocked by maintenance)
  static Future<bool> isTimeSlotAvailable(DateTime startTime, DateTime endTime) async {
    final conflictingMaintenance = await _maintenanceService.getConflictingMaintenance(startTime, endTime);
    return conflictingMaintenance.isEmpty;
  }

  /// Get maintenance message for a specific time slot
  static Future<String?> getMaintenanceMessage(DateTime startTime, DateTime endTime) async {
    final conflictingMaintenance = await _maintenanceService.getConflictingMaintenance(startTime, endTime);
    
    if (conflictingMaintenance.isNotEmpty) {
      final maintenance = conflictingMaintenance.first;
      return maintenance.reason ?? 'Ground unavailable due to maintenance';
    }
    
    return null;
  }

  /// Get all unavailable time slots for a specific date
  static Future<List<Map<String, dynamic>>> getUnavailableSlots(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final conflictingMaintenance = await _maintenanceService.getConflictingMaintenance(startOfDay, endOfDay);
    
    return conflictingMaintenance.map((maintenance) => {
      'startTime': maintenance.startTime,
      'endTime': maintenance.endTime,
      'reason': maintenance.reason ?? 'Maintenance',
      'type': 'maintenance',
    }).toList();
  }

  /// Validate a proposed booking against maintenance schedules
  static Future<BookingValidationResult> validateBooking(DateTime startTime, DateTime endTime) async {
    final conflictingMaintenance = await _maintenanceService.getConflictingMaintenance(startTime, endTime);
    
    if (conflictingMaintenance.isEmpty) {
      return BookingValidationResult(
        isValid: true,
        message: 'Booking time is available',
      );
    }

    final maintenance = conflictingMaintenance.first;
    String message = 'Cannot book during maintenance period';
    
    if (maintenance.reason != null) {
      message += ': ${maintenance.reason}';
    }
    
    message += '\nMaintenance: ${_formatDateTime(maintenance.startTime)} - ${_formatDateTime(maintenance.endTime)}';

    return BookingValidationResult(
      isValid: false,
      message: message,
      conflictingMaintenance: conflictingMaintenance,
    );
  }

  /// Get suggested alternative time slots avoiding maintenance
  static Future<List<DateTime>> getSuggestedAlternatives(
    DateTime preferredStart,
    Duration bookingDuration,
    {int maxSuggestions = 3}
  ) async {
    final suggestions = <DateTime>[];
    final date = DateTime(preferredStart.year, preferredStart.month, preferredStart.day);
    
    // Check time slots throughout the day
    for (int hour = 6; hour <= 22; hour++) {
      final proposedStart = DateTime(date.year, date.month, date.day, hour);
      final proposedEnd = proposedStart.add(bookingDuration);
      
      if (await isTimeSlotAvailable(proposedStart, proposedEnd)) {
        suggestions.add(proposedStart);
        
        if (suggestions.length >= maxSuggestions) {
          break;
        }
      }
    }
    
    return suggestions;
  }

  /// Format DateTime for display
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Check if there's any active maintenance right now
  static Future<bool> isMaintenanceActive() async {
    final activeMaintenance = await _maintenanceService.getActiveMaintenance();
    return activeMaintenance.isNotEmpty;
  }

  /// Get current active maintenance details
  static Future<MaintenanceSchedule?> getCurrentActiveMaintenance() async {
    final activeMaintenance = await _maintenanceService.getActiveMaintenance();
    return activeMaintenance.isNotEmpty ? activeMaintenance.first : null;
  }

  /// Get upcoming maintenance within next few hours
  static Future<List<MaintenanceSchedule>> getUpcomingMaintenanceToday() async {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    final allMaintenance = await _maintenanceService.getAllMaintenanceSchedules();
    
    return allMaintenance.where((maintenance) {
      return maintenance.startTime.isAfter(now) && 
             maintenance.startTime.isBefore(endOfDay);
    }).toList();
  }
}

class BookingValidationResult {
  final bool isValid;
  final String message;
  final List<MaintenanceSchedule>? conflictingMaintenance;

  BookingValidationResult({
    required this.isValid,
    required this.message,
    this.conflictingMaintenance,
  });
}
