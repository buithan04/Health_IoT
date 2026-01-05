// lib/core/widgets/responsive_layout.dart
import 'package:flutter/material.dart';
import 'package:health_iot/core/utils/platform_helper.dart';

/// Widget responsive hỗ trợ nhiều layout khác nhau cho mobile/tablet/desktop
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Desktop layout
        if (PlatformHelper.isDesktopLayout(width) && desktop != null) {
          return desktop!;
        }

        // Tablet layout
        if (PlatformHelper.isTabletLayout(width) && tablet != null) {
          return tablet!;
        }

        // Mobile layout (default)
        return mobile;
      },
    );
  }
}

/// Builder widget cho responsive design linh hoạt hơn
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints, bool isMobile, bool isTablet, bool isDesktop) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = PlatformHelper.isMobileLayout(width);
        final isTablet = PlatformHelper.isTabletLayout(width);
        final isDesktop = PlatformHelper.isDesktopLayout(width);

        return builder(context, constraints, isMobile, isTablet, isDesktop);
      },
    );
  }
}

/// Padding responsive
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? mobilePadding;
  final double? tabletPadding;
  final double? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double padding;

        if (PlatformHelper.isDesktopLayout(width)) {
          padding = desktopPadding ?? 32.0;
        } else if (PlatformHelper.isTabletLayout(width)) {
          padding = tabletPadding ?? 24.0;
        } else {
          padding = mobilePadding ?? 16.0;
        }

        return Padding(
          padding: EdgeInsets.all(padding),
          child: child,
        );
      },
    );
  }
}

/// Container với max width cho desktop
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final contentMaxWidth = maxWidth ?? PlatformHelper.getMaxContentWidth(width);

        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            padding: padding,
            child: child,
          ),
        );
      },
    );
  }
}
