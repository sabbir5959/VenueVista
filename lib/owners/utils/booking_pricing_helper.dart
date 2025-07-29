import '../models/discount_schedule.dart';
import '../services/dynamic_pricing_service.dart';

class BookingPricingHelper {
  static final DynamicPricingService _pricingService = DynamicPricingService.instance;

  /// Calculate the final price for a booking with any applicable discounts
  static Future<BookingPriceResult> calculateBookingPrice({
    required DateTime bookingDateTime,
    required bool isTeamBooking,
    double? customBasePrice,
  }) async {
    final basePrice = customBasePrice ?? await _pricingService.getBasePrice();
    final discountedPrice = await _pricingService.calculateDiscountedPrice(
      bookingDateTime,
      isTeamBooking,
      customBasePrice: customBasePrice,
    );
    
    final appliedDiscount = await _pricingService.getBestDiscountForBooking(
      bookingDateTime,
      isTeamBooking,
    );
    
    return BookingPriceResult(
      basePrice: basePrice,
      finalPrice: discountedPrice,
      discountAmount: basePrice - discountedPrice,
      appliedDiscount: appliedDiscount,
      hasDiscount: appliedDiscount != null,
    );
  }

  /// Get all available discounts for a specific date
  static Future<List<DiscountSchedule>> getDiscountsForDate(DateTime date) async {
    final allDiscounts = await _pricingService.getAllDiscountSchedules();
    
    return allDiscounts.where((discount) {
      final discountDate = DateTime(
        discount.startDate.year,
        discount.startDate.month,
        discount.startDate.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      
      // Check if the date is within the discount range
      if (discount.endDate != null) {
        final endDate = DateTime(
          discount.endDate!.year,
          discount.endDate!.month,
          discount.endDate!.day,
        );
        return !targetDate.isBefore(discountDate) && !targetDate.isAfter(endDate);
      } else {
        return discountDate.isAtSameMomentAs(targetDate);
      }
    }).toList();
  }

  /// Check if a time slot has any discounts available
  static Future<bool> hasDiscountAtTime({
    required DateTime bookingDateTime,
    required bool isTeamBooking,
  }) async {
    final applicableDiscounts = await _pricingService.getDiscountsForBooking(
      bookingDateTime,
      isTeamBooking,
    );
    return applicableDiscounts.isNotEmpty;
  }

  /// Get discount badge text for UI display
  static Future<String?> getDiscountBadgeText({
    required DateTime bookingDateTime,
    required bool isTeamBooking,
  }) async {
    final bestDiscount = await _pricingService.getBestDiscountForBooking(
      bookingDateTime,
      isTeamBooking,
    );
    
    if (bestDiscount == null) return null;
    
    return bestDiscount.getDiscountDescription();
  }

  /// Validate if pricing can be applied to a booking
  static Future<PricingValidationResult> validateBookingPricing({
    required DateTime bookingDateTime,
    required bool isTeamBooking,
  }) async {
    final now = DateTime.now();
    
    // Check if booking is for a future date
    if (bookingDateTime.isBefore(now)) {
      return PricingValidationResult(
        isValid: false,
        message: 'Cannot apply dynamic pricing to past bookings',
      );
    }
    
    // Check if there are any applicable discounts
    final applicableDiscounts = await _pricingService.getDiscountsForBooking(
      bookingDateTime,
      isTeamBooking,
    );
    
    if (applicableDiscounts.isEmpty) {
      return PricingValidationResult(
        isValid: true,
        message: 'Base price applies - no discounts available',
        hasDiscounts: false,
      );
    }
    
    return PricingValidationResult(
      isValid: true,
      message: 'Discounts available for this booking',
      hasDiscounts: true,
      availableDiscounts: applicableDiscounts,
    );
  }

  /// Get pricing summary for a date range (useful for booking calendars)
  static Future<List<DayPricingSummary>> getPricingSummaryForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    required bool isTeamBooking,
  }) async {
    final summaries = <DayPricingSummary>[];
    final basePrice = await _pricingService.getBasePrice();
    
    DateTime currentDate = startDate;
    while (!currentDate.isAfter(endDate)) {
      final discountsForDay = await getDiscountsForDate(currentDate);
      final hasDiscounts = discountsForDay.any((discount) =>
        (isTeamBooking && discount.applyToTeams) ||
        (!isTeamBooking && discount.applyToIndividual));
      
      double? minDiscountedPrice;
      String? bestDiscountText;
      
      if (hasDiscounts) {
        // Find the best discount for this day (checking different times)
        final sampleTimes = [9, 12, 15, 18]; // Sample times to check
        double bestPrice = basePrice;
        DiscountSchedule? bestDiscount;
        
        for (final hour in sampleTimes) {
          final sampleDateTime = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            hour,
          );
          
          final dayDiscount = await _pricingService.getBestDiscountForBooking(
            sampleDateTime,
            isTeamBooking,
          );
          
          if (dayDiscount != null) {
            final discountedPrice = dayDiscount.calculateDiscountedPrice(basePrice);
            if (discountedPrice < bestPrice) {
              bestPrice = discountedPrice;
              bestDiscount = dayDiscount;
            }
          }
        }
        
        if (bestDiscount != null) {
          minDiscountedPrice = bestPrice;
          bestDiscountText = bestDiscount.getDiscountDescription();
        }
      }
      
      summaries.add(DayPricingSummary(
        date: currentDate,
        basePrice: basePrice,
        hasDiscounts: hasDiscounts,
        minDiscountedPrice: minDiscountedPrice,
        bestDiscountText: bestDiscountText,
        discountCount: discountsForDay.length,
      ));
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return summaries;
  }

  /// Get current active discounts
  static Future<List<DiscountSchedule>> getCurrentActiveDiscounts() async {
    return await _pricingService.getActiveDiscounts();
  }

  /// Format price with currency
  static String formatPrice(double price) {
    return '৳${price.toStringAsFixed(0)}';
  }

  /// Calculate savings amount and percentage
  static Map<String, dynamic> calculateSavings(double basePrice, double discountedPrice) {
    final savings = basePrice - discountedPrice;
    final savingsPercentage = (savings / basePrice) * 100;
    
    return {
      'amount': savings,
      'percentage': savingsPercentage,
      'formattedAmount': formatPrice(savings),
      'formattedPercentage': '${savingsPercentage.toStringAsFixed(1)}%',
    };
  }
}

class BookingPriceResult {
  final double basePrice;
  final double finalPrice;
  final double discountAmount;
  final DiscountSchedule? appliedDiscount;
  final bool hasDiscount;

  BookingPriceResult({
    required this.basePrice,
    required this.finalPrice,
    required this.discountAmount,
    this.appliedDiscount,
    required this.hasDiscount,
  });

  String get formattedBasePrice => BookingPricingHelper.formatPrice(basePrice);
  String get formattedFinalPrice => BookingPricingHelper.formatPrice(finalPrice);
  String get formattedDiscountAmount => BookingPricingHelper.formatPrice(discountAmount);
  
  double get savingsPercentage => hasDiscount ? (discountAmount / basePrice) * 100 : 0;
  String get formattedSavingsPercentage => '${savingsPercentage.toStringAsFixed(1)}%';
}

class PricingValidationResult {
  final bool isValid;
  final String message;
  final bool hasDiscounts;
  final List<DiscountSchedule>? availableDiscounts;

  PricingValidationResult({
    required this.isValid,
    required this.message,
    this.hasDiscounts = false,
    this.availableDiscounts,
  });
}

class DayPricingSummary {
  final DateTime date;
  final double basePrice;
  final bool hasDiscounts;
  final double? minDiscountedPrice;
  final String? bestDiscountText;
  final int discountCount;

  DayPricingSummary({
    required this.date,
    required this.basePrice,
    required this.hasDiscounts,
    this.minDiscountedPrice,
    this.bestDiscountText,
    required this.discountCount,
  });

  String get formattedBasePrice => BookingPricingHelper.formatPrice(basePrice);
  String? get formattedMinDiscountedPrice => 
      minDiscountedPrice != null ? BookingPricingHelper.formatPrice(minDiscountedPrice!) : null;
}
