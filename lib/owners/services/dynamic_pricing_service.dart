import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/discount_schedule.dart';

class DynamicPricingService {
  static const String _discountSchedulesKey = 'discount_schedules';
  static const String _basePriceKey = 'base_price';
  static const double _defaultBasePrice = 500.0;
  
  static DynamicPricingService? _instance;
  
  DynamicPricingService._();
  
  static DynamicPricingService get instance {
    _instance ??= DynamicPricingService._();
    return _instance!;
  }

  // Get all discount schedules
  Future<List<DiscountSchedule>> getAllDiscountSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String? schedulesJson = prefs.getString(_discountSchedulesKey);
    
    if (schedulesJson == null) {
      return [];
    }
    
    final List<dynamic> schedulesList = json.decode(schedulesJson);
    return schedulesList
        .map((json) => DiscountSchedule.fromMap(json))
        .toList();
  }

  // Save discount schedules
  Future<void> saveDiscountSchedules(List<DiscountSchedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final String schedulesJson = json.encode(
      schedules.map((schedule) => schedule.toMap()).toList(),
    );
    await prefs.setString(_discountSchedulesKey, schedulesJson);
  }

  // Add a new discount schedule
  Future<void> addDiscountSchedule(DiscountSchedule schedule) async {
    final schedules = await getAllDiscountSchedules();
    
    // Check for conflicts if overlapping is not allowed
    if (!schedule.allowOverlapping) {
      final conflicts = schedules.where((existing) => 
        existing.conflictsWith(schedule)).toList();
      
      if (conflicts.isNotEmpty) {
        throw Exception('Discount conflicts with existing schedule: ${conflicts.first.label}');
      }
    }
    
    schedules.add(schedule);
    await saveDiscountSchedules(schedules);
  }

  // Update an existing discount schedule
  Future<void> updateDiscountSchedule(DiscountSchedule updatedSchedule) async {
    final schedules = await getAllDiscountSchedules();
    final index = schedules.indexWhere((s) => s.id == updatedSchedule.id);
    
    if (index != -1) {
      // Check for conflicts with other schedules (excluding self)
      if (!updatedSchedule.allowOverlapping) {
        final conflicts = schedules.where((existing) => 
          existing.id != updatedSchedule.id && 
          existing.conflictsWith(updatedSchedule)).toList();
        
        if (conflicts.isNotEmpty) {
          throw Exception('Discount conflicts with existing schedule: ${conflicts.first.label}');
        }
      }
      
      schedules[index] = updatedSchedule;
      await saveDiscountSchedules(schedules);
    }
  }

  // Delete a discount schedule
  Future<void> deleteDiscountSchedule(int id) async {
    final schedules = await getAllDiscountSchedules();
    schedules.removeWhere((schedule) => schedule.id == id);
    await saveDiscountSchedules(schedules);
  }

  // Get active discount schedules for current time
  Future<List<DiscountSchedule>> getActiveDiscounts() async {
    final allSchedules = await getAllDiscountSchedules();
    return allSchedules.where((schedule) => schedule.isActive).toList();
  }

  // Get discounts that apply to a specific booking
  Future<List<DiscountSchedule>> getDiscountsForBooking(
    DateTime bookingDateTime,
    bool isTeamBooking,
  ) async {
    final allSchedules = await getAllDiscountSchedules();
    return allSchedules.where((schedule) => 
      schedule.appliesToBooking(bookingDateTime, isTeamBooking)).toList();
  }

  // Calculate price with discounts applied
  Future<double> calculateDiscountedPrice(
    DateTime bookingDateTime,
    bool isTeamBooking,
    {double? customBasePrice}
  ) async {
    final basePrice = customBasePrice ?? await getBasePrice();
    final applicableDiscounts = await getDiscountsForBooking(bookingDateTime, isTeamBooking);
    
    if (applicableDiscounts.isEmpty) {
      return basePrice;
    }
    
    // Apply the best discount (highest discount amount)
    double bestDiscountedPrice = basePrice;
    
    for (final discount in applicableDiscounts) {
      final discountedPrice = discount.calculateDiscountedPrice(basePrice);
      if (discountedPrice < bestDiscountedPrice) {
        bestDiscountedPrice = discountedPrice;
      }
    }
    
    return bestDiscountedPrice;
  }

  // Get the best discount for a booking
  Future<DiscountSchedule?> getBestDiscountForBooking(
    DateTime bookingDateTime,
    bool isTeamBooking,
  ) async {
    final basePrice = await getBasePrice();
    final applicableDiscounts = await getDiscountsForBooking(bookingDateTime, isTeamBooking);
    
    if (applicableDiscounts.isEmpty) {
      return null;
    }
    
    DiscountSchedule? bestDiscount;
    double bestDiscountedPrice = basePrice;
    
    for (final discount in applicableDiscounts) {
      final discountedPrice = discount.calculateDiscountedPrice(basePrice);
      if (discountedPrice < bestDiscountedPrice) {
        bestDiscountedPrice = discountedPrice;
        bestDiscount = discount;
      }
    }
    
    return bestDiscount;
  }

  // Get base price
  Future<double> getBasePrice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_basePriceKey) ?? _defaultBasePrice;
  }

  // Update base price
  Future<void> updateBasePrice(double newPrice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_basePriceKey, newPrice);
  }

  // Get upcoming discounts within next N days
  Future<List<DiscountSchedule>> getUpcomingDiscounts({int days = 7}) async {
    final allSchedules = await getAllDiscountSchedules();
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    
    return allSchedules.where((schedule) {
      return schedule.startDate.isAfter(now) && 
             schedule.startDate.isBefore(futureDate);
    }).toList();
  }

  // Clean up expired discount schedules
  Future<void> cleanupExpiredDiscounts() async {
    final allSchedules = await getAllDiscountSchedules();
    final now = DateTime.now();
    
    final activeSchedules = allSchedules.where((schedule) {
      // Keep schedules that haven't ended yet
      if (schedule.endDate != null) {
        return !schedule.endDate!.isBefore(now);
      } else {
        // For single-day schedules, keep if not before today
        final scheduleDate = DateTime(
          schedule.startDate.year,
          schedule.startDate.month,
          schedule.startDate.day,
        );
        final today = DateTime(now.year, now.month, now.day);
        return !scheduleDate.isBefore(today);
      }
    }).toList();
    
    await saveDiscountSchedules(activeSchedules);
  }

  // Validate discount schedule
  Future<String?> validateDiscountSchedule(DiscountSchedule schedule) async {
    // Check if start date is in the future
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduleDate = DateTime(
      schedule.startDate.year,
      schedule.startDate.month,
      schedule.startDate.day,
    );
    
    if (scheduleDate.isBefore(today) || scheduleDate.isAtSameMomentAs(today)) {
      return 'Discount can only be scheduled for future dates';
    }
    
    // Check if end date is after start date
    if (schedule.endDate != null && schedule.endDate!.isBefore(schedule.startDate)) {
      return 'End date must be after start date';
    }
    
    // Check if start time is before end time
    final startMinutes = schedule.startTime.hour * 60 + schedule.startTime.minute;
    final endMinutes = schedule.endTime.hour * 60 + schedule.endTime.minute;
    
    if (startMinutes >= endMinutes) {
      return 'Start time must be before end time';
    }
    
    // Check discount value validity
    if (schedule.discountValue <= 0) {
      return 'Discount value must be greater than 0';
    }
    
    if (schedule.discountType == DiscountType.percentage && schedule.discountValue >= 100) {
      return 'Percentage discount must be less than 100%';
    }
    
    // Check for conflicts if overlapping is not allowed
    if (!schedule.allowOverlapping) {
      final allSchedules = await getAllDiscountSchedules();
      final conflicts = allSchedules.where((existing) => 
        existing.id != schedule.id && existing.conflictsWith(schedule)).toList();
      
      if (conflicts.isNotEmpty) {
        return 'Discount conflicts with existing schedule: ${conflicts.first.label}';
      }
    }
    
    return null; // No validation errors
  }

  // Get discount statistics
  Future<Map<String, dynamic>> getDiscountStatistics() async {
    final allSchedules = await getAllDiscountSchedules();
    final now = DateTime.now();
    
    final activeDiscounts = allSchedules.where((s) => s.isActive).length;
    final upcomingDiscounts = allSchedules.where((s) => s.startDate.isAfter(now)).length;
    final expiredDiscounts = allSchedules.where((s) {
      if (s.endDate != null) {
        return s.endDate!.isBefore(now);
      } else {
        final scheduleDate = DateTime(s.startDate.year, s.startDate.month, s.startDate.day);
        final today = DateTime(now.year, now.month, now.day);
        return scheduleDate.isBefore(today);
      }
    }).length;
    
    return {
      'total': allSchedules.length,
      'active': activeDiscounts,
      'upcoming': upcomingDiscounts,
      'expired': expiredDiscounts,
    };
  }
}
