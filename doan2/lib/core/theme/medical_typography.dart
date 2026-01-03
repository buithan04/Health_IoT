// lib/core/theme/medical_typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography chuẩn quốc tế cho ứng dụng Y tế
/// Sử dụng font Inter - font sans-serif hiện đại, dễ đọc
/// Phù hợp cho medical apps theo khuyến nghị của Apple Human Interface Guidelines
class MedicalTypography {
  // Font family chính - Inter (professional, clean, highly legible)
  static const String primaryFontFamily = 'Inter';
  
  // Font family phụ cho số liệu - Roboto Mono (monospaced for numbers)
  static const String monoFontFamily = 'Roboto Mono';

  /// Text theme cho ứng dụng y tế
  static TextTheme get textTheme {
    return TextTheme(
      // Display - Tiêu đề lớn (hiếm khi dùng trong medical apps)
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline - Tiêu đề sections
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600, // Semi-bold cho rõ ràng
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title - Tiêu đề cards, dialogs
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body - Text chính
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label - Labels, buttons
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  /// Text styles đặc biệt cho medical data
  static TextStyle get vitalSignsNumber => GoogleFonts.robotoMono(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.0,
      );

  static TextStyle get vitalSignsUnit => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: Colors.grey[600],
      );

  static TextStyle get medicalRecordTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
      );

  static TextStyle get medicalRecordBody => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.53,
      );

  static TextStyle get prescriptionDrug => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.50,
      );

  static TextStyle get prescriptionDosage => GoogleFonts.robotoMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.43,
      );

  static TextStyle get alertText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: Colors.red[700],
      );

  static TextStyle get successText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: Colors.green[700],
      );

  /// Platform-specific adjustments
  static TextTheme getPlatformTextTheme(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        // iOS/macOS prefer slightly larger text for better readability
        return _scaleTextTheme(textTheme, 1.05);
      
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return textTheme;
      
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        // Desktop platforms can handle slightly denser text
        return _scaleTextTheme(textTheme, 0.98);
      
      default:
        return textTheme;
    }
  }

  /// Scale all text in theme by a factor
  static TextTheme _scaleTextTheme(TextTheme theme, double scaleFactor) {
    return TextTheme(
      displayLarge: theme.displayLarge?.copyWith(fontSize: (theme.displayLarge?.fontSize ?? 0) * scaleFactor),
      displayMedium: theme.displayMedium?.copyWith(fontSize: (theme.displayMedium?.fontSize ?? 0) * scaleFactor),
      displaySmall: theme.displaySmall?.copyWith(fontSize: (theme.displaySmall?.fontSize ?? 0) * scaleFactor),
      headlineLarge: theme.headlineLarge?.copyWith(fontSize: (theme.headlineLarge?.fontSize ?? 0) * scaleFactor),
      headlineMedium: theme.headlineMedium?.copyWith(fontSize: (theme.headlineMedium?.fontSize ?? 0) * scaleFactor),
      headlineSmall: theme.headlineSmall?.copyWith(fontSize: (theme.headlineSmall?.fontSize ?? 0) * scaleFactor),
      titleLarge: theme.titleLarge?.copyWith(fontSize: (theme.titleLarge?.fontSize ?? 0) * scaleFactor),
      titleMedium: theme.titleMedium?.copyWith(fontSize: (theme.titleMedium?.fontSize ?? 0) * scaleFactor),
      titleSmall: theme.titleSmall?.copyWith(fontSize: (theme.titleSmall?.fontSize ?? 0) * scaleFactor),
      bodyLarge: theme.bodyLarge?.copyWith(fontSize: (theme.bodyLarge?.fontSize ?? 0) * scaleFactor),
      bodyMedium: theme.bodyMedium?.copyWith(fontSize: (theme.bodyMedium?.fontSize ?? 0) * scaleFactor),
      bodySmall: theme.bodySmall?.copyWith(fontSize: (theme.bodySmall?.fontSize ?? 0) * scaleFactor),
      labelLarge: theme.labelLarge?.copyWith(fontSize: (theme.labelLarge?.fontSize ?? 0) * scaleFactor),
      labelMedium: theme.labelMedium?.copyWith(fontSize: (theme.labelMedium?.fontSize ?? 0) * scaleFactor),
      labelSmall: theme.labelSmall?.copyWith(fontSize: (theme.labelSmall?.fontSize ?? 0) * scaleFactor),
    );
  }
}

/// Color palette chuyên nghiệp cho ứng dụng y tế
class MedicalColors {
  // Primary - Cyan/Teal (tin cậy, y tế, công nghệ)
  static const Color primary = Color(0xFF06B6D4); // Cyan 500
  static const Color primaryLight = Color(0xFF22D3EE); // Cyan 400
  static const Color primaryDark = Color(0xFF0891B2); // Cyan 600

  // Secondary - Teal (hỗ trợ, cân bằng)
  static const Color secondary = Color(0xFF14B8A6); // Teal 500
  static const Color secondaryLight = Color(0xFF2DD4BF); // Teal 400
  static const Color secondaryDark = Color(0xFF0D9488); // Teal 600

  // Status colors
  static const Color success = Color(0xFF10B981); // Green 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Neutrals
  static const Color background = Color(0xFFFAFAFA); // Gray 50
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF3F4F6); // Gray 100

  // Text
  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray 400

  // Borders
  static const Color border = Color(0xFFE5E7EB); // Gray 200
  static const Color borderFocus = Color(0xFF06B6D4); // Primary

  // Vital signs specific colors
  static const Color heartRate = Color(0xFFEF4444); // Red
  static const Color bloodPressure = Color(0xFF8B5CF6); // Purple
  static const Color temperature = Color(0xFFF59E0B); // Amber
  static const Color oxygen = Color(0xFF3B82F6); // Blue
  static const Color glucose = Color(0xFF10B981); // Green
}
