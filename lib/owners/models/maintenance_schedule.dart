class MaintenanceSchedule {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final String? reason;
  final MaintenanceStatus status;
  final bool isRepeating;
  final String? repeatFrequency;
  final int? repeatOccurrences;
  final DateTime? repeatEndDate;

  MaintenanceSchedule({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.reason,
    required this.status,
    this.isRepeating = false,
    this.repeatFrequency,
    this.repeatOccurrences,
    this.repeatEndDate,
  });

  // Check if the maintenance is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  // Check if bookings should be disabled for a given time
  bool blocksBookingAt(DateTime bookingTime) {
    return bookingTime.isAfter(startTime) && bookingTime.isBefore(endTime);
  }

  // Get the status based on current time
  static MaintenanceStatus getStatusForTime(DateTime startTime, DateTime endTime) {
    final now = DateTime.now();
    if (now.isBefore(startTime)) {
      return MaintenanceStatus.upcoming;
    } else if (now.isAfter(endTime)) {
      return MaintenanceStatus.past;
    } else {
      return MaintenanceStatus.ongoing;
    }
  }

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'reason': reason,
      'status': status.toString(),
      'isRepeating': isRepeating,
      'repeatFrequency': repeatFrequency,
      'repeatOccurrences': repeatOccurrences,
      'repeatEndDate': repeatEndDate?.toIso8601String(),
    };
  }

  // Create from Map
  factory MaintenanceSchedule.fromMap(Map<String, dynamic> map) {
    return MaintenanceSchedule(
      id: map['id'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      reason: map['reason'],
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => MaintenanceStatus.upcoming,
      ),
      isRepeating: map['isRepeating'] ?? false,
      repeatFrequency: map['repeatFrequency'],
      repeatOccurrences: map['repeatOccurrences'],
      repeatEndDate: map['repeatEndDate'] != null 
          ? DateTime.parse(map['repeatEndDate']) 
          : null,
    );
  }

  MaintenanceSchedule copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    String? reason,
    MaintenanceStatus? status,
    bool? isRepeating,
    String? repeatFrequency,
    int? repeatOccurrences,
    DateTime? repeatEndDate,
  }) {
    return MaintenanceSchedule(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      isRepeating: isRepeating ?? this.isRepeating,
      repeatFrequency: repeatFrequency ?? this.repeatFrequency,
      repeatOccurrences: repeatOccurrences ?? this.repeatOccurrences,
      repeatEndDate: repeatEndDate ?? this.repeatEndDate,
    );
  }
}

enum MaintenanceStatus {
  upcoming,
  ongoing,
  past,
}

// Extension to make status more readable
extension MaintenanceStatusExtension on MaintenanceStatus {
  String get displayName {
    switch (this) {
      case MaintenanceStatus.upcoming:
        return 'Upcoming';
      case MaintenanceStatus.ongoing:
        return 'Ongoing';
      case MaintenanceStatus.past:
        return 'Past';
    }
  }
}
