# Maintenance Schedule Feature

## Overview
The Maintenance Schedule feature allows venue owners to temporarily disable bookings during specific timeframes for maintenance, upgrades, or issues. This ensures that bookings are automatically blocked during maintenance periods.

## Features

### 1. Schedule Maintenance
- **Date & Time Picker**: Select start and end times for maintenance periods
- **Reason Field**: Optional text area to describe the maintenance (e.g., "Grass trimming, light repair, net change...")
- **Recurring Maintenance**: Set up recurring maintenance with customizable frequency:
  - Weekly, Biweekly, or Monthly intervals
  - End after X occurrences or until a specific date

### 2. Maintenance Overview
- **Tabbed View**: Shows maintenance schedules in three categories:
  - **Upcoming**: Future maintenance scheduled
  - **Ongoing**: Currently active maintenance
  - **Past**: Historical maintenance records
- **Management Actions**: Edit or delete upcoming maintenance schedules

### 3. Booking Integration
- **Automatic Blocking**: Bookings are automatically disabled during maintenance periods
- **Visual Indicators**: Maintenance slots are shown as "Unavailable" in red/grey
- **Tooltip Messages**: Shows maintenance reason when hovering over blocked slots

## File Structure

```
lib/owners/
├── screens/
│   └── maintenance.dart              # Main maintenance UI
├── models/
│   └── maintenance_schedule.dart     # Data model for maintenance
├── services/
│   └── maintenance_service.dart      # Business logic and persistence
├── utils/
│   └── booking_maintenance_helper.dart # Booking integration utilities
└── widgets/
    └── booking_calendar_widget.dart  # Example booking calendar integration
```

## Usage

### 1. Access Maintenance Schedule
Navigate to **Owner Dashboard → Sidebar → Maintenance Schedule**

### 2. Schedule New Maintenance
1. Go to "Schedule Maintenance" tab
2. Select start and end date/time using the date/time pickers
3. Optionally add a reason for maintenance
4. For recurring maintenance:
   - Toggle "Repeat this maintenance"
   - Choose frequency (Week/Biweekly/Monthly)
   - Set end condition (number of occurrences or end date)
5. Click "Schedule Maintenance"

### 3. View & Manage Schedules
1. Go to "View Schedule" tab
2. Browse through Upcoming, Ongoing, and Past maintenance
3. Edit or delete upcoming maintenance as needed

### 4. Test Booking Integration
- Use the "Test Booking" button to see how maintenance affects booking availability
- Time slots during maintenance will be marked as "MAINTENANCE" and disabled

## Technical Implementation

### Data Model
The `MaintenanceSchedule` class includes:
- Start/end times
- Optional reason description
- Recurring schedule settings
- Status tracking (upcoming/ongoing/past)

### Persistence
- Uses `SharedPreferences` for local storage
- Automatic conversion between model objects and JSON
- Supports CRUD operations

### Booking Integration
The `BookingMaintenanceHelper` utility provides:
- Time slot availability checking
- Conflict detection with maintenance schedules
- Alternative time suggestions
- Integration methods for booking systems

### Features Implemented
✅ Date & Time Picker with validation  
✅ Optional reason field  
✅ Recurring maintenance setup  
✅ Maintenance schedule overview (calendar/list view)  
✅ Edit/Delete upcoming maintenance  
✅ Automatic booking disabling  
✅ Visual indicators for unavailable slots  
✅ Persistent storage  
✅ Integration with booking systems  

## Integration with Existing Booking System

To integrate with your existing booking system:

1. **Import the helper**:
   ```dart
   import '../utils/booking_maintenance_helper.dart';
   ```

2. **Check availability before allowing bookings**:
   ```dart
   final isAvailable = await BookingMaintenanceHelper.isTimeSlotAvailable(startTime, endTime);
   if (!isAvailable) {
     // Show maintenance message
     final message = await BookingMaintenanceHelper.getMaintenanceMessage(startTime, endTime);
   }
   ```

3. **Get unavailable slots for calendar display**:
   ```dart
   final unavailableSlots = await BookingMaintenanceHelper.getUnavailableSlots(date);
   // Mark these slots as unavailable in your calendar UI
   ```

4. **Validate bookings**:
   ```dart
   final validation = await BookingMaintenanceHelper.validateBooking(startTime, endTime);
   if (!validation.isValid) {
     // Show error message: validation.message
   }
   ```

## Future Enhancements

Potential improvements:
- Push notifications for upcoming maintenance
- Integration with external calendar systems
- Bulk maintenance scheduling
- Maintenance cost tracking
- Equipment-specific maintenance schedules
- Maintenance history analytics

## Navigation Path
**Owner Dashboard** → **Sidebar** → **Maintenance Schedule**
