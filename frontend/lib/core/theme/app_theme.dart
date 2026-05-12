import 'package:flutter/material.dart';

class AppTheme {
  // Brand palette — teal/mint
  static const Color primaryMint   = Color(0xFF32B5A0); // primary teal
  static const Color lightMint     = Color(0xFFA7E9DA); // light teal
  static const Color darkTeal      = Color(0xFF1A806D); // dark teal accent
  static const Color cyanAccent    = Color(0xFF00E1FD); // cyan highlight
  static const Color navyVisor     = Color(0xFF141E28); // dark surfaces
  static const Color noteGreen     = Color(0xFF88D4AB); // positive states
  static const Color scaffoldLight = Color(0xFFF0FAFA); // light background
  static const Color white          = Color(0xFFFFFFFF);
  static const Color darkText       = Color(0xFF1A1C1E); // neutral near-black
  static const Color mediumText     = Color(0xFF6B7280); // neutral gray-500

  // Dark theme surfaces
  static const Color darkSurface    = Color(0xFF1C2128); // neutral dark surface
  static const Color lightText      = Color(0xFFFFFFFF);
  static const Color lightGreyText  = Color(0xFFD9E2EC); // neutral light gray
  static const Color mediumGreyText = Color(0xFF8B9BB4); // neutral medium gray

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryMint,
        secondary: primaryMint,
        tertiary: cyanAccent,
        error: Colors.red,
      ),
      scaffoldBackgroundColor: scaffoldLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryMint,
        foregroundColor: white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: white,
        elevation: 1,
        margin: EdgeInsets.all(0),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryMint,
          foregroundColor: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMint,
          foregroundColor: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: darkText),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkText),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkText),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: darkText),
        labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: mediumText),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: primaryMint,
        secondary: primaryMint,
        tertiary: cyanAccent,
        surface: navyVisor,
        error: Colors.red,
      ),
      scaffoldBackgroundColor: navyVisor,
      appBarTheme: const AppBarTheme(
        backgroundColor: navyVisor,
        foregroundColor: white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: darkSurface,
        elevation: 1,
        margin: EdgeInsets.all(0),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryMint,
          foregroundColor: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMint,
          foregroundColor: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: lightText),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: lightText),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: lightText),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: lightGreyText),
        labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: mediumGreyText),
      ),
    );
  }
}
