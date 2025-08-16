import 'package:flutter/material.dart';

enum DiscountType {
  percentage,
  flat,
}

class DiscountSchedule {
  final int id;
  final DateTime startDate;
  final DateTime? endDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final DiscountType discountType;
  final double discountValue;
  final String label;
  final bool applyToIndividual;
  final bool applyToTeams;
  final bool allowOverlapping;
  final DateTime createdAt;

  DiscountSchedule({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.startTime,
    required this.endTime,
    required this.discountType,
    required this.discountValue,
    this.label = '',
    this.applyToIndividual = true,
    this.applyToTeams = true,
    this.allowOverlapping = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Check if the discount is currently active (simplified for full-day discounts)
  bool get isActive {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if today is within the date range
    bool isInDateRange = !startDate.isAfter(today);
    if (endDate != null) {
      isInDateRange = isInDateRange && !endDate!.isBefore(today);
    } else {
      isInDateRange = isInDateRange && startDate.isAtSameMomentAs(today);
    }
    
    // Since we use full-day discounts (00:00-23:59), no time check needed
    return isInDateRange;
  }

  // Check if this discount applies to a specific booking (simplified for full-day)
  bool appliesToBooking(DateTime bookingDateTime, bool isTeamBooking) {
    if (isTeamBooking && !applyToTeams) return false;
    if (!isTeamBooking && !applyToIndividual) return false;
    
    final bookingDate = DateTime(bookingDateTime.year, bookingDateTime.month, bookingDateTime.day);
    
    // Check date range only (no time check)
    if (bookingDate.isBefore(startDate)) return false;
    if (endDate != null && bookingDate.isAfter(endDate!)) return false;
    if (endDate == null && !bookingDate.isAtSameMomentAs(startDate)) return false;
    
    return true; // Discount applies for the entire day
  }

  // Calculate discounted price
  double calculateDiscountedPrice(double basePrice) {
    if (discountType == DiscountType.percentage) {
      return basePrice * (1 - (discountValue / 100));
    } else {
      return (basePrice - discountValue).clamp(0, basePrice);
    }
  }

  // Get discount description
  String getDiscountDescription() {
    if (discountType == DiscountType.percentage) {
      return '${discountValue.toStringAsFixed(0)}% Off';
    } else {
      return '৳${discountValue.toStringAsFixed(0)} Off';
    }
  }

  // Check if this discount conflicts with another discount (date-only)
  bool conflictsWith(DiscountSchedule other) {
    if (allowOverlapping || other.allowOverlapping) return false;
    
    // Check date overlap only (no time check)
    bool dateOverlap = false;
    if (endDate == null && other.endDate == null) {
      dateOverlap = startDate.isAtSameMomentAs(other.startDate);
    } else if (endDate == null) {
      dateOverlap = !other.startDate.isAfter(startDate) && !other.endDate!.isBefore(startDate);
    } else if (other.endDate == null) {
      dateOverlap = !startDate.isAfter(other.startDate) && !endDate!.isBefore(other.startDate);
    } else {
      dateOverlap = !startDate.isAfter(other.endDate!) && !endDate!.isBefore(other.startDate);
    }
    
    // Since all discounts are full-day (00:00-23:59), date overlap = conflict
    return dateOverlap;
  }

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'discountType': discountType.toString(),
      'discountValue': discountValue,
      'label': label,
      'applyToIndividual': applyToIndividual,
      'applyToTeams': applyToTeams,
      'allowOverlapping': allowOverlapping,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory DiscountSchedule.fromMap(Map<String, dynamic> map) {
    final startTimeParts = map['startTime'].split(':');
    final endTimeParts = map['endTime'].split(':');
    
    return DiscountSchedule(
      id: map['id'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      discountType: DiscountType.values.firstWhere(
        (e) => e.toString() == map['discountType'],
        orElse: () => DiscountType.percentage,
      ),
      discountValue: map['discountValue'].toDouble(),
      label: map['label'] ?? '',
      applyToIndividual: map['applyToIndividual'] ?? true,
      applyToTeams: map['applyToTeams'] ?? true,
      allowOverlapping: map['allowOverlapping'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  DiscountSchedule copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    DiscountType? discountType,
    double? discountValue,
    String? label,
    bool? applyToIndividual,
    bool? applyToTeams,
    bool? allowOverlapping,
    DateTime? createdAt,
  }) {
    return DiscountSchedule(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      label: label ?? this.label,
      applyToIndividual: applyToIndividual ?? this.applyToIndividual,
      applyToTeams: applyToTeams ?? this.applyToTeams,
      allowOverlapping: allowOverlapping ?? this.allowOverlapping,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Extension to make DiscountType more readable
extension DiscountTypeExtension on DiscountType {
  String get displayName {
    switch (this) {
      case DiscountType.percentage:
        return '% Off';
      case DiscountType.flat:
        return 'Flat Amount';
    }
  }
}
