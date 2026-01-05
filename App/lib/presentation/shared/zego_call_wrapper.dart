import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../../main.dart'; // For navigatorKey

/// ═══════════════════════════════════════════════════════════════════
/// ZegoCallWrapper - Wrap toàn bộ app để nhận incoming call
/// ═══════════════════════════════════════════════════════════════════
/// 
/// Usage in main.dart:
/// ```dart
/// MaterialApp(
///   builder: (context, child) {
///     return ZegoCallWrapper(child: child!);
///   },
/// )
/// ```
///
/// ═══════════════════════════════════════════════════════════════════

class ZegoCallWrapper extends StatefulWidget {
  final Widget child;
  
  const ZegoCallWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ZegoCallWrapper> createState() => _ZegoCallWrapperState();
}

class _ZegoCallWrapperState extends State<ZegoCallWrapper> {
  // No auto-initialization - only init after user login to avoid plugin errors

  @override
  Widget build(BuildContext context) {
    // Stack pattern: app content + mini overlay for minimized calls
    return Stack(
      children: [
        widget.child,
        
        // Mini overlay appears on top when call is minimized
        ZegoUIKitPrebuiltCallMiniOverlayPage(
          contextQuery: () {
            return navigatorKey.currentState?.context ?? context;
          },
        ),
      ],
    );
  }
}
