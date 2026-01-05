import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

/// Connecting Call Screen - Hiển thị khi đang kết nối cuộc gọi
/// Giống Messenger khi đang gọi đến người khác
/// 
/// Features:
/// - Ripple animation xung quanh avatar (giống Messenger)
/// - Text animation "Đang gọi..."
/// - Smooth gradient background
/// - Professional design
class ConnectingCallScreen extends StatefulWidget {
  final String remoteUserName;
  final String? remoteUserAvatar;
  final bool isVideoCall;
  final VoidCallback onCancel;

  const ConnectingCallScreen({
    super.key,
    required this.remoteUserName,
    this.remoteUserAvatar,
    required this.isVideoCall,
    required this.onCancel,
  });

  @override
  State<ConnectingCallScreen> createState() => _ConnectingCallScreenState();
}

class _ConnectingCallScreenState extends State<ConnectingCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _dotsController;
  String _dotsText = '';
  Timer? _dotsTimer;

  @override
  void initState() {
    super.initState();

    // Ripple animation (3 circles expanding)
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Dots animation for "Calling..."
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Animate dots text
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotsText = '.' * ((timer.tick % 4));
        });
      }
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _dotsController.dispose();
    _dotsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive sizing based on screen size
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;
    final avatarRadius = isDesktop ? 100.0 : 85.0;
    final rippleSize = isDesktop ? 250.0 : 220.0;
    final buttonSize = isDesktop ? 80.0 : 70.0;
    final fontSize = isDesktop ? 32.0 : 28.0;
    final labelFontSize = isDesktop ? 20.0 : 18.0;
    
    return WillPopScope(
      onWillPop: () async {
        widget.onCancel();
        return true;
      },
      child: Scaffold(
        // Đảm bảo không có màu nền mặc định
        backgroundColor: Colors.transparent,
        // Bỏ SafeArea để full màn hình
        body: Container(
          // Full size container
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF667eea),
                const Color(0xFF764ba2),
                const Color(0xFF4A00E0),
              ],
            ),
          ),
          // Wrap với SafeArea nhưng vẫn giữ background full
          child: SafeArea(
            child: Column(
              children: [
                // Top section - Call type
                Padding(
                  padding: EdgeInsets.only(top: isDesktop ? 60 : 40, bottom: isDesktop ? 30 : 20),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 28 : 24,
                      vertical: isDesktop ? 14 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isVideoCall ? Icons.videocam : Icons.phone,
                          color: Colors.white,
                          size: isDesktop ? 24 : 22,
                        ),
                        SizedBox(width: isDesktop ? 12 : 10),
                        Text(
                          widget.isVideoCall ? 'Video Call' : 'Voice Call',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isDesktop ? 18 : 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Center - Avatar with ripple
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ripple circles (3 layers)
                    ...List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _rippleController,
                        builder: (context, child) {
                          final delay = index * 0.33;
                          final value = (_rippleController.value + delay) % 1.0;
                          final scale = 1.0 + (value * 0.8);
                          final opacity = 1.0 - value;

                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: rippleSize,
                              height: rippleSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(opacity * 0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),

                    // Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: isDesktop ? 50 : 40,
                            spreadRadius: isDesktop ? 8 : 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: widget.remoteUserAvatar != null &&
                                widget.remoteUserAvatar!.isNotEmpty
                            ? NetworkImage(widget.remoteUserAvatar!)
                            : null,
                        child: widget.remoteUserAvatar == null ||
                                widget.remoteUserAvatar!.isEmpty
                            ? Icon(
                                Icons.person,
                                size: avatarRadius * 0.8,
                                color: Colors.white.withOpacity(0.9),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isDesktop ? 50 : 40),

                // User name
                Text(
                  widget.remoteUserName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isDesktop ? 16 : 12),

                // "Calling..." with animated dots
                Text(
                  'Đang gọi$_dotsText',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),

                const Spacer(),

                // Bottom - Cancel button
                Padding(
                  padding: EdgeInsets.only(bottom: isDesktop ? 80 : 60),
                  child: Column(
                    children: [
                      // Cancel button (red circle)
                      GestureDetector(
                        onTap: widget.onCancel,
                        child: Container(
                          width: buttonSize,
                          height: buttonSize,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: buttonSize * 0.45,
                          ),
                        ),
                      ),
                      SizedBox(height: isDesktop ? 20 : 16),
                      Text(
                        'Hủy',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isDesktop ? 18 : 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
