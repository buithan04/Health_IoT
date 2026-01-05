import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Enables drag/scroll for mouse, touch, stylus, and trackpads (desktop/web).
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}
