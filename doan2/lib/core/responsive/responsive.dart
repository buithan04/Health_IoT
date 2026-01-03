import 'package:flutter/material.dart';

/// Simple responsive helpers for layout decisions across phone/tablet/desktop.
class Responsive {
  static bool isPhone(BuildContext context) => MediaQuery.sizeOf(context).width < 600;
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= 1024;

  static bool useRail(BuildContext context) => MediaQuery.sizeOf(context).width >= 900;

  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1400) return const EdgeInsets.symmetric(horizontal: 40, vertical: 16);
    if (width >= 1100) return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    if (width >= 900) return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  static double gridSpacing(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1400) return 20;
    if (width >= 900) return 16;
    return 12;
  }

  static int columnsForStats(double width) {
    if (width >= 1400) return 4;
    if (width >= 1100) return 3;
    if (width >= 700) return 2;
    return 2;
  }

  static int columnsForFeatures(double width) {
    if (width >= 1200) return 3;
    if (width >= 800) return 2;
    return 2;
  }

  static double statsAspect(double width) {
    if (width >= 1400) return 1.2;
    if (width >= 1100) return 1.15;
    if (width >= 900) return 1.05;
    return 1.0;
  }

  static double featureAspect(double width) {
    if (width >= 1200) return 2.0;
    if (width >= 900) return 1.8;
    if (width >= 700) return 1.6;
    return 1.4;
  }

  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1600) return 1400;
    if (width >= 1400) return 1280;
    if (width >= 1200) return 1180;
    return double.infinity;
  }
}
