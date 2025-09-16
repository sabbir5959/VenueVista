class RevenueData {
  final double totalRevenue;
  final double ownerShare; // 30% of total revenue
  final double monthlyProfit;
  final double profitPercentage;
  final List<BookingIncomeItem> bookingIncomes;

  RevenueData({
    required this.totalRevenue,
    required this.ownerShare,
    required this.monthlyProfit,
    required this.profitPercentage,
    required this.bookingIncomes,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      totalRevenue: (json['total_revenue'] ?? 0.0).toDouble(),
      ownerShare: (json['owner_share'] ?? 0.0).toDouble(),
      monthlyProfit: (json['monthly_profit'] ?? 0.0).toDouble(),
      profitPercentage: (json['profit_percentage'] ?? 0.0).toDouble(),
      bookingIncomes:
          (json['booking_incomes'] as List<dynamic>?)
              ?.map((item) => BookingIncomeItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class BookingIncomeItem {
  final String type; // 'tournament' or 'daily_booking'
  final String title;
  final String subtitle;
  final double amount;
  final double ownerAmount; // 30% of amount
  final int count;

  BookingIncomeItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.ownerAmount,
    required this.count,
  });

  factory BookingIncomeItem.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] ?? 0.0).toDouble();
    return BookingIncomeItem(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      amount: amount,
      ownerAmount: amount * 0.3, // 30% of total amount
      count: json['count'] ?? 0,
    );
  }
}

class MonthlyRevenueData {
  final String month;
  final double totalRevenue;
  final double ownerShare;
  final int tournamentCount;
  final int bookingCount;

  MonthlyRevenueData({
    required this.month,
    required this.totalRevenue,
    required this.ownerShare,
    required this.tournamentCount,
    required this.bookingCount,
  });

  factory MonthlyRevenueData.fromJson(Map<String, dynamic> json) {
    final totalRevenue = (json['total_revenue'] ?? 0.0).toDouble();
    return MonthlyRevenueData(
      month: json['month'] ?? '',
      totalRevenue: totalRevenue,
      ownerShare: totalRevenue * 0.3,
      tournamentCount: json['tournament_count'] ?? 0,
      bookingCount: json['booking_count'] ?? 0,
    );
  }
}
