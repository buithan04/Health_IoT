import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'dart:async';

/// Full-screen Incoming Call UI - giống Messenger
/// 
/// Features:
/// - Full screen với background blur
/// - Avatar lớn
/// - Animation pulse cho avatar
/// - Ringtone tự động
/// - Nút Accept/Decline lớn và rõ ràng
class IncomingCallScreen extends StatefulWidget {
  final String callerName;
  final String? callerAvatar;
  final bool isVideoCall;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallScreen({
    super.key,
    required this.callerName,
    this.callerAvatar,
    required this.isVideoCall,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _ringtoneTimer;

  @override
  void initState() {
    super.initState();

    // Setup pulse animation for avatar
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Play ringtone
    _startRingtone();
  }

  void _startRingtone() {
    // Play ringtone immediately
    FlutterRingtonePlayer().play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.glass,
      looping: true,
      volume: 1.0,
    );
  }

  void _stopRingtone() {
    FlutterRingtonePlayer().stop();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringtoneTimer?.cancel();
    _stopRingtone();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive sizing based on screen size
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;
    final avatarRadius = isDesktop ? 110.0 : 85.0;
    final buttonSize = isDesktop ? 80.0 : 70.0;
    final fontSize = isDesktop ? 36.0 : 28.0;
    final labelFontSize = isDesktop ? 18.0 : 16.0;
    
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        body: Container(
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
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top section - Call info
                Padding(
                  padding: EdgeInsets.only(top: isDesktop ? 80 : 60),
                  child: Column(
                    children: [
                      // Call type label
                      Container(
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
                              widget.isVideoCall ? 'Incoming Video Call' : 'Incoming Voice Call',
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
                      SizedBox(height: isDesktop ? 60 : 40),

                      // Avatar with pulse animation
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: isDesktop ? 40 : 30,
                                spreadRadius: isDesktop ? 15 : 10,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            backgroundImage: widget.callerAvatar != null &&
                                    widget.callerAvatar!.isNotEmpty
                                ? NetworkImage(widget.callerAvatar!)
                                : null,
                            child: widget.callerAvatar == null ||
                                    widget.callerAvatar!.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: avatarRadius * 0.8,
                                    color: Colors.white.withOpacity(0.9),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(height: isDesktop ? 40 : 32),

                      // Caller name
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 32),
                        child: Text(
                          widget.callerName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: isDesktop ? 16 : 12),

                      // Ringing text with animation
                      _RingingIndicator(isDesktop: isDesktop),
                    ],
                  ),
                ),

                // Bottom section - Action buttons (Messenger style)
                Padding(
                  padding: EdgeInsets.only(bottom: isDesktop ? 100 : 80),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Decline button (red circle with icon)
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _stopRingtone();
                              widget.onDecline();
                            },
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
                                    spreadRadius: 3,
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
                          SizedBox(height: isDesktop ? 16 : 12),
                          Text(
                            'Từ chối',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: labelFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // Accept button (green circle with icon)
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _stopRingtone();
                              widget.onAccept();
                            },
                            child: Container(
                              width: buttonSize,
                              height: buttonSize,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.isVideoCall ? Icons.videocam : Icons.call,
                                color: Colors.white,
                                size: buttonSize * 0.45,
                              ),
                            ),
                          ),
                          SizedBox(height: isDesktop ? 16 : 12),
                          Text(
                            'Trả lời',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: labelFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

/// Ringing indicator with animated dots
class _RingingIndicator extends StatefulWidget {
  final bool isDesktop;
  
  const _RingingIndicator({this.isDesktop = false});
  
  @override
  State<_RingingIndicator> createState() => _RingingIndicatorState();
}

class _RingingIndicatorState extends State<_RingingIndicator> {
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;
    return Text(
      'Đang gọi$dots',
      style: TextStyle(
        color: Colors.white.withOpacity(0.8),
        fontSize: widget.isDesktop ? 20 : 18,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
