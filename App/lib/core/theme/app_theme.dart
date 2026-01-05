import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- MÀU SẮC CHỦ ĐẠO ---
  static const Color primaryColor = Color(0xFF14B8A6); // Tương đương Teal-500
  static const Color primaryColorDark = Color(0xFF0D9488); // Tương đương Teal-600
  static const Color scaffoldBackgroundColor = Color(0xFFF0F4F8); // Tương đương bg-gray-50
  static const Color textColor = Color(0xFF374151); // Tương đương text-gray-700
  static const Color secondaryTextColor = Color(0xFF6B7280); // Tương đương text-gray-500

  // --- CHỦ ĐỀ SÁNG (LIGHT THEME) ---
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    fontFamily: 'Inter',

    // Cấu hình ColorScheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: primaryColorDark,
      background: scaffoldBackgroundColor,
      error: Colors.red[600],
    ),

    // Cấu hình TextTheme
    textTheme: _buildTextTheme(),

    // Cấu hình AppBarTheme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textColor),
      titleTextStyle: GoogleFonts.manrope(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),

    // Cấu hình ElevatedButtonTheme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        textStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
      ),
    ),

    // Cấu hình TextFormField (InputDecorationTheme)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      hintStyle: const TextStyle(color: secondaryTextColor),
      prefixIconColor: Colors.grey[400],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: primaryColor, width: 2.0),
      ),
    ),

    // Cấu hình BottomNavigationBarTheme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: secondaryTextColor,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),

    // Cấu hình CardTheme
    cardTheme: const CardThemeData(
      elevation: 2,
      shadowColor: Color(0x0D000000), // Tương đương black.withOpacity(0.05)
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );

  static TextTheme _buildTextTheme() {
    final base = ThemeData.light().textTheme;
    final body = GoogleFonts.interTextTheme(base).apply(bodyColor: textColor, displayColor: textColor);

    return body.copyWith(
      displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: textColor),
      displayMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: textColor),
      displaySmall: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: textColor),
      headlineLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: textColor),
      headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: textColor),
      headlineSmall: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: textColor),
      titleLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: textColor),
      titleMedium: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: textColor),
      titleSmall: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: GoogleFonts.inter(color: textColor, fontSize: body.bodyLarge?.fontSize),
      bodyMedium: GoogleFonts.inter(color: secondaryTextColor, fontSize: body.bodyMedium?.fontSize),
      bodySmall: GoogleFonts.inter(color: secondaryTextColor, fontSize: body.bodySmall?.fontSize),
      labelLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: textColor),
      labelMedium: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: textColor),
      labelSmall: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: textColor),
    );
  }
}

