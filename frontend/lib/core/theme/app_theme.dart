import 'package:flutter/material.dart';

class AppTheme {
  // Colour palette
  static const Color primaryGreen = Color(0xFF2E7D32);      // Progress & positive states
  static const Color accentTeal = Color(0xFF4DB6AC);        // Warm accent
  static const Color accentOrange = Color(0xFFFF9800);      // Warm accent
  static const Color accentGold = Color(0xFFFFC107);        // Warm accent
  static const Color accentLightGreen = Color(0xFF66BB6A);  // Warm accent
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkText = Color(0xFF212121);
  static const Color mediumText = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        secondary: accentTeal,
        tertiary: accentOrange,
        surface: white,
        background: lightGrey,
        error: Colors.red, // Kept for validation, but not used for spending
      ),
      scaffoldBackgroundColor: lightGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardTheme(
        color: white,
        elevation: 1,
        margin: EdgeInsets.all(0),
      ),
      textTheme: const TextTheme(
        // Large metric display (36pt)
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        // Titles (18pt)
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        // Body text (14pt)
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkText,
        ),
        // Labels (12pt)
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: mediumText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
