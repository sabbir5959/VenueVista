class ActivityData {
  final int totalBookings;
  final int tournamentBookings;
  final int totalReviews;
  final double averageRating;
  final List<ReviewItem> recentReviews;

  ActivityData({
    required this.totalBookings,
    required this.tournamentBookings,
    required this.totalReviews,
    required this.averageRating,
    required this.recentReviews,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      totalBookings: json['total_bookings'] ?? 0,
      tournamentBookings: json['tournament_bookings'] ?? 0,
      totalReviews: json['total_reviews'] ?? 0,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      recentReviews: (json['recent_reviews'] as List<dynamic>?)
              ?.map((item) => ReviewItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_bookings': totalBookings,
      'tournament_bookings': tournamentBookings,
      'total_reviews': totalReviews,
      'average_rating': averageRating,
      'recent_reviews': recentReviews.map((item) => item.toJson()).toList(),
    };
  }
}

class ReviewItem {
  final String id;
  final int rating;
  final String reviewText;
  final String userName;
  final DateTime createdAt;

  ReviewItem({
    required this.id,
    required this.rating,
    required this.reviewText,
    required this.userName,
    required this.createdAt,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      id: json['id'] ?? '',
      rating: json['rating'] ?? 0,
      reviewText: json['review_text'] ?? '',
      userName: json['user_name'] ?? 'Anonymous',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'review_text': reviewText,
      'user_name': userName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}