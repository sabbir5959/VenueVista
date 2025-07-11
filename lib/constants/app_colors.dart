import 'package:flutter/material.dart';

/// VenueVista Application Color Palette
///
/// This file contains all the color constants used throughout the app
/// for consistent theming and easy maintenance.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF2E7D32); // Deep Green
  static const Color primaryLight = Color(0xFF4CAF50); // Light Green
  static const Color primaryDark = Color(0xFF1B5E20); // Dark Green

  // Secondary Colors
  static const Color secondary = Color(0xFF00BCD4); // Cyan
  static const Color secondaryLight = Color(0xFF4DD0E1); // Light Cyan
  static const Color secondaryDark = Color(0xFF00838F); // Dark Cyan

  // Background Colors
  static const Color background = Color(0xFFF5F7FA); // Light Grey Background
  static const Color surface = Color(0xFFFFFFFF); // White Surface
  static const Color surfaceVariant = Color(0xFFF8F9FA); // Off White

  // Text Colors
  static const Color textPrimary = Color(0xFF1E1E1E); // Dark Grey
  static const Color textSecondary = Color(0xFF757575); // Medium Grey
  static const Color textTertiary = Color(0xFF9E9E9E); // Light Grey
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on Primary

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color error = Color(0xFFf44336); // Red
  static const Color info = Color(0xFF2196F3); // Blue

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Gradient Colors
  static const List<Color> primaryGradient = [primary, primaryLight];
  static const List<Color> secondaryGradient = [secondary, secondaryLight];

  // Opacity Variants
  static Color primaryWithOpacity(double opacity) =>
      primary.withOpacity(opacity);
  static Color secondaryWithOpacity(double opacity) =>
      secondary.withOpacity(opacity);
  static Color textPrimaryWithOpacity(double opacity) =>
      textPrimary.withOpacity(opacity);
  static Color textSecondaryWithOpacity(double opacity) =>
      textSecondary.withOpacity(opacity);

  // Shadow Colors
  static Color shadowLight = black.withOpacity(0.05);
  static Color shadowMedium = black.withOpacity(0.1);
  static Color shadowDark = black.withOpacity(0.15);

  // Border Colors
  static Color borderLight = grey200;
  static Color borderMedium = grey300;
  static Color borderDark = grey400;
}
