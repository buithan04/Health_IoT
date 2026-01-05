// test/unit/platform_helper_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:health_iot/core/utils/platform_helper.dart';

void main() {
  group('PlatformHelper Unit Tests', () {
    test('Mobile breakpoint detection should work correctly', () {
      expect(PlatformHelper.isMobileLayout(500), true);
      expect(PlatformHelper.isMobileLayout(599), true);
      expect(PlatformHelper.isMobileLayout(600), false);
      expect(PlatformHelper.isMobileLayout(700), false);
    });

    test('Tablet breakpoint detection should work correctly', () {
      expect(PlatformHelper.isTabletLayout(599), false);
      expect(PlatformHelper.isTabletLayout(600), true);
      expect(PlatformHelper.isTabletLayout(899), true);
      expect(PlatformHelper.isTabletLayout(1200), false);
    });

    test('Desktop breakpoint detection should work correctly', () {
      expect(PlatformHelper.isDesktopLayout(1199), false);
      expect(PlatformHelper.isDesktopLayout(1200), true);
      expect(PlatformHelper.isDesktopLayout(1500), true);
    });

    test('Grid columns should be calculated based on width', () {
      expect(PlatformHelper.getGridColumns(500), 1);   // mobile
      expect(PlatformHelper.getGridColumns(700), 2);   // tablet
      expect(PlatformHelper.getGridColumns(1000), 3);  // large tablet
      expect(PlatformHelper.getGridColumns(1300), 4);  // desktop
    });

    test('Responsive padding should scale with screen width', () {
      expect(PlatformHelper.getResponsivePadding(500), 16.0);  // mobile
      expect(PlatformHelper.getResponsivePadding(700), 24.0);  // tablet
      expect(PlatformHelper.getResponsivePadding(1300), 32.0); // desktop
    });

    test('Max content width should be limited on large screens', () {
      // Screens > 1400px should max at 1200
      final maxWidth1 = PlatformHelper.getMaxContentWidth(1500);
      expect(maxWidth1, 1200);
      
      // Screens <= 1400px should be 85% of width
      final maxWidth2 = PlatformHelper.getMaxContentWidth(1000);
      expect(maxWidth2, 850);
      
      final maxWidth3 = PlatformHelper.getMaxContentWidth(1200);
      expect(maxWidth3, 1020);
    });

    test('Video call support should always be true', () {
      // All platforms support video call with Zego
      expect(PlatformHelper.supportsVideoCall, true);
    });

    test('Platform constants should be defined correctly', () {
      expect(PlatformHelper.mobileBreakpoint, 600);
      expect(PlatformHelper.tabletBreakpoint, 900);
      expect(PlatformHelper.desktopBreakpoint, 1200);
    });
  });
}
