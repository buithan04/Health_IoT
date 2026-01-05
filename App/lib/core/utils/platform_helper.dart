// lib/core/utils/platform_helper.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Helper class để xác định platform và responsive breakpoints
class PlatformHelper {
  // Platform checks
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Kiểm tra có phải mobile layout không (dựa vào width)
  static bool isMobileLayout(double width) => width < mobileBreakpoint;
  
  /// Kiểm tra có phải tablet layout không
  static bool isTabletLayout(double width) => 
      width >= mobileBreakpoint && width < desktopBreakpoint;
  
  /// Kiểm tra có phải desktop layout không
  static bool isDesktopLayout(double width) => width >= desktopBreakpoint;

  /// Lấy số cột grid dựa vào width
  static int getGridColumns(double width) {
    if (width < mobileBreakpoint) return 1;
    if (width < tabletBreakpoint) return 2;
    if (width < desktopBreakpoint) return 3;
    return 4;
  }

  /// Lấy padding dựa vào platform
  static double getResponsivePadding(double width) {
    if (width < mobileBreakpoint) return 16.0;
    if (width < desktopBreakpoint) return 24.0;
    return 32.0;
  }

  /// Kiểm tra có hỗ trợ video call không
  static bool get supportsVideoCall {
    // Web và Desktop đều hỗ trợ video call với Zego
    return true;
  }

  /// Lấy max width cho content trên desktop
  static double getMaxContentWidth(double screenWidth) {
    if (isDesktop || isWeb) {
      return screenWidth > 1400 ? 1200 : screenWidth * 0.85;
    }
    return screenWidth;
  }
}
