# Dynamic Pricing Feature

## Overview
The Dynamic Pricing feature allows venue owners to schedule discounts on specific future dates or time ranges, enabling users to automatically pay reduced prices during promotional periods. This helps owners optimize venue utilization and attract customers during off-peak hours.

## Features

### 1. 🧾 Current Base Price Display
- **Base Rate Card**: Shows current hourly price (e.g., "Base Rate: ৳500/hour")
- **Update Button**: Allows owners to modify the base price
- **Visual Emphasis**: Highlighted pricing information in a dedicated card

### 2. 📅 Discount Scheduler (Future Dates Only)
- **Date Picker**: Restricted to future dates only (no past dates or today)
  - Start Date (must be after today)
  - End Date (optional, for multi-day discounts)
- **Time Range Picker**: Select specific hours for discount (e.g., 10:00 AM – 2:00 PM)
- **Discount Configuration**:
  - Type: Percentage (%) or Flat amount (৳)
  - Value input with validation
  - Optional label/reason (e.g., "Independence Day Special", "Morning Rush")

### 3. 📋 Scheduled Discounts Management
- **Tabbed Interface**: Separate tabs for creating and viewing discounts
- **Discount Cards**: Visual display of all scheduled discounts showing:
  - Date and time range
  - Discount type and value
  - Label/reason
  - Applicable booking types (Individual/Teams)
  - Edit and delete actions for future discounts
- **Auto-cleanup**: Expired discounts are automatically filtered out

### 4. ⚙️ Rules & Controls
- **Booking Type Controls**:
  - Apply to individual bookings (toggle)
  - Apply to team bookings/tournaments (toggle)
- **Overlap Management**: Option to allow/prevent overlapping discounts
- **Smart Validation**: Prevents conflicts and invalid configurations

### 5. 🔧 Backend Logic & Validation
- **Future-only Scheduling**: Prevents discounts on current or past dates
- **Conflict Detection**: Identifies overlapping discount periods
- **Booking Integration**: Automatically applies best available discount
- **Price Calculation**: Smart discount application with validation

## File Structure

```
lib/owners/
├── screens/
│   └── dynamic_pricing.dart              # Main pricing UI
├── models/
│   └── discount_schedule.dart            # Discount data model
├── services/
│   └── dynamic_pricing_service.dart      # Business logic and persistence
└── utils/
    └── booking_pricing_helper.dart       # Booking integration utilities
```

## Usage

### 1. Access Dynamic Pricing
Navigate to **Owner Dashboard → Sidebar → Dynamic Pricing**

### 2. Update Base Price
1. View current base price in the top card
2. Click "Update" button
3. Enter new hourly rate
4. Confirm changes

### 3. Schedule New Discount
1. Go to "Manage Pricing" tab
2. Select future start date (and optional end date)
3. Choose time range for the discount
4. Set discount type (% or flat amount) and value
5. Add optional label for organization
6. Configure rules (individual/team bookings, overlapping)
7. Click "Schedule Discount"

### 4. Manage Scheduled Discounts
1. Go to "Scheduled Discounts" tab
2. View all upcoming discounts
3. Edit or delete future discounts as needed
4. Monitor discount effectiveness

## Technical Implementation

### Data Model
The `DiscountSchedule` class includes:
- Date and time range information
- Discount type (percentage or flat)
- Booking applicability settings
- Conflict detection methods
- Price calculation utilities

### Persistence
- Uses `SharedPreferences` for local storage
- Automatic JSON serialization/deserialization
- CRUD operations with validation

### Integration Features
The `BookingPricingHelper` utility provides:
- Real-time price calculation with discounts
- Booking validation against pricing rules
- Calendar integration for showing discounted periods
- Price comparison and savings calculation

### Key Features Implemented
✅ Future-only date selection with validation  
✅ Time range picker for targeted discounts  
✅ Dual discount types (percentage & flat rate)  
✅ Optional labeling for discount organization  
✅ Booking type controls (individual/team)  
✅ Overlap prevention and conflict detection  
✅ Automatic price calculation and application  
✅ Visual discount management interface  
✅ Persistent storage and data management  
✅ Integration with booking systems  

## Integration with Booking System

To integrate dynamic pricing with your booking system:

1. **Calculate booking price**:
   ```dart
   import '../utils/booking_pricing_helper.dart';
   
   final priceResult = await BookingPricingHelper.calculateBookingPrice(
     bookingDateTime: selectedDateTime,
     isTeamBooking: false,
   );
   
   // Display original price: priceResult.formattedBasePrice
   // Display final price: priceResult.formattedFinalPrice
   // Show savings: priceResult.formattedDiscountAmount
   ```

2. **Check for available discounts**:
   ```dart
   final hasDiscount = await BookingPricingHelper.hasDiscountAtTime(
     bookingDateTime: selectedDateTime,
     isTeamBooking: false,
   );
   
   if (hasDiscount) {
     final badgeText = await BookingPricingHelper.getDiscountBadgeText(
       bookingDateTime: selectedDateTime,
       isTeamBooking: false,
     );
     // Show discount badge with badgeText
   }
   ```

3. **Get pricing summary for calendar**:
   ```dart
   final summaries = await BookingPricingHelper.getPricingSummaryForDateRange(
     startDate: DateTime.now(),
     endDate: DateTime.now().add(Duration(days: 30)),
     isTeamBooking: false,
   );
   
   // Display pricing information for each day
   for (final summary in summaries) {
     if (summary.hasDiscounts) {
       // Show discounted pricing: summary.formattedMinDiscountedPrice
       // Show discount badge: summary.bestDiscountText
     }
   }
   ```

## UX Design Notes

### Visual Indicators
- **Light Blue**: Scheduled discount periods
- **Gold**: Special promotional offers
- **Green**: Base pricing
- **Red**: Validation errors

### User Flow
1. **Create Discount**: Date → Time → Value → Rules → Save
2. **Manage Discounts**: View → Edit/Delete → Confirm
3. **Price Updates**: View Current → Modify → Apply

### Validation & Feedback
- Real-time validation with clear error messages
- Success confirmations for all actions
- Automatic navigation to relevant tabs
- Visual feedback for form states

## Future Enhancements

Potential improvements:
- **Analytics Dashboard**: Track discount effectiveness and revenue impact
- **Popular Times Heatmap**: Help owners identify optimal discount periods
- **Bulk Operations**: Create multiple discounts at once
- **Template System**: Save and reuse common discount patterns
- **Notification System**: Alert owners about upcoming discount periods
- **Revenue Forecasting**: Predict revenue impact of discount strategies
- **Integration APIs**: Connect with external pricing tools
- **Advanced Rules**: Complex pricing strategies and conditions

## Navigation Path
**Owner Dashboard** → **Sidebar** → **Dynamic Pricing**

## Benefits for Venue Owners
- **Increased Bookings**: Attract customers during off-peak hours
- **Revenue Optimization**: Strategic pricing to maximize income
- **Competitive Advantage**: Flexible pricing strategies
- **Customer Retention**: Reward loyal customers with special offers
- **Easy Management**: Simple interface for complex pricing rules
