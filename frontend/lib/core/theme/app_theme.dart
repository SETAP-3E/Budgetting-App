import 'package:flutter/material.dart';

class AppTheme {
  // Colour palette
  static const Color primaryTeal = Color(0xFF4DB6AC); // Primary UI colour (warm)
  static const Color successGreen = Color(0xFF2E7D32); // Progress & positive states only
  static const Color accentOrange = Color(0xFFFF9800); // Warm accent
  static const Color accentGold = Color(0xFFFFC107); // Warm accent
  static const Color accentLightGreen = Color(0xFF66BB6A); // Warm accent
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkText = Color(0xFF212121);
  static const Color mediumText = Color(0xFF757575);
  
  // Dark theme colours
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color lightText = Color(0xFFFFFFFF);
  static const Color lightGreyText = Color(0xFFE0E0E0);
  static const Color mediumGreyText = Color(0xFFB0B0B0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryTeal,
        secondary: primaryTeal,
        tertiary: accentOrange,
        surface: white,
        background: lightGrey,
        error: Colors.red, // Kept for validation, but not used for spending
      ),
      scaffoldBackgroundColor: lightGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryTeal,
        foregroundColor: white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
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
          backgroundColor: successGreen,
          foregroundColor: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryTeal,
        secondary: primaryTeal,
        tertiary: accentOrange,
        surface: darkSurface,
        background: darkBg,
        error: Colors.red,
      ),
      scaffoldBackgroundColor: darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryTeal,
        foregroundColor: white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: darkSurface,
        elevation: 1,
        margin: EdgeInsets.all(0),
      ),
      textTheme: const TextTheme(
        // Large metric display (36pt)
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
        // Titles (18pt)
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightText,
        ),
        // Body text (14pt)
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: lightGreyText,
        ),
        // Labels (12pt)
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: mediumGreyText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: successGreen,
          foregroundColor: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
