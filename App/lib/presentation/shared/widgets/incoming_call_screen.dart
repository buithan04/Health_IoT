import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

/// Full-screen Incoming Call UI - giống Messenger
/// 
/// Features:
/// - Full screen với background blur
/// - Avatar lớn với pulse animation
/// - Ringtone tự động + Vibration
/// - Nút Accept/Decline lớn và rõ ràng (Messenger style)
/// - Auto-reject sau 45 giây (như Messenger)
/// - Countdown timer hiển thị
class IncomingCallScreen extends StatefulWidget {
  final String callerName;
  final String? callerAvatar;
  final bool isVideoCall;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final int timeoutSeconds; // Auto-reject timeout

  const IncomingCallScreen({
    super.key,
    required this.callerName,
    this.callerAvatar,
    required this.isVideoCall,
    required this.onAccept,
    required this.onDecline,
    this.timeoutSeconds = 45, // Default 45s như Messenger
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _ringtoneTimer;
  Timer? _vibrationTimer;
  Timer? _timeoutTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();

    _remainingSeconds = widget.timeoutSeconds;

    // Setup pulse animation for avatar
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start ringtone + vibration
    _startRingtone();
    _startVibration();

    // Start timeout countdown
    _startTimeoutCountdown();
  }

  /// Start ringtone (looping)
  void _startRingtone() {
    FlutterRingtonePlayer().play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.glass,
      looping: true,
      volume: 1.0,
    );
  }

  /// Stop ringtone
  void _stopRingtone() {
    FlutterRingtonePlayer().stop();
  }

  /// Start vibration pattern (giống Messenger)
  void _startVibration() async {
    // Check if device supports vibration
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      // Vibration pattern: [wait, vibrate, wait, vibrate, ...]
      // Pattern: 0ms wait, 1000ms vibrate, 500ms wait, 1000ms vibrate
      const pattern = [0, 1000, 500, 1000];
      
      // Repeat vibration every 2.5 seconds
      _vibrationTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
        Vibration.vibrate(pattern: pattern);
      });
      
      // Start first vibration immediately
      Vibration.vibrate(pattern: pattern);
    }
  }

  /// Stop vibration
  void _stopVibration() {
    _vibrationTimer?.cancel();
    Vibration.cancel();
  }

  /// Start countdown timer and auto-reject after timeout
  void _startTimeoutCountdown() {
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        // Auto-reject khi hết thời gian
        timer.cancel();
        _handleDecline(autoReject: true);
      }
    });
  }

  /// Handle Accept call
  void _handleAccept() {
    _stopRingtone();
    _stopVibration();
    _timeoutTimer?.cancel();
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    widget.onAccept();
  }

  /// Handle Decline call
  void _handleDecline({bool autoReject = false}) {
    _stopRingtone();
    _stopVibration();
    _timeoutTimer?.cancel();
    
    if (!autoReject) {
      HapticFeedback.mediumImpact();
    }
    
    widget.onDecline();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringtoneTimer?.cancel();
    _vibrationTimer?.cancel();
    _timeoutTimer?.cancel();
    _stopRingtone();
    _stopVibration();
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
                Color(0xFF4A00E0),
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
                              widget.isVideoCall ? 'Cuộc gọi Video' : 'Cuộc gọi thoại',
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
                      
                      SizedBox(height: isDesktop ? 24 : 20),
                      
                      // Countdown timer
                      if (_remainingSeconds > 0 && _remainingSeconds <= 10)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Tự động kết thúc sau $_remainingSeconds giây',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: isDesktop ? 16 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
                      _ActionButton(
                        onTap: () => _handleDecline(),
                        color: Colors.red,
                        icon: Icons.call_end,
                        label: 'Từ chối',
                        size: buttonSize,
                        labelFontSize: labelFontSize,
                        isDesktop: isDesktop,
                      ),

                      // Accept button (green circle with icon)
                      _ActionButton(
                        onTap: _handleAccept,
                        color: Colors.green,
                        icon: widget.isVideoCall ? Icons.videocam : Icons.call,
                        label: 'Trả lời',
                        size: buttonSize,
                        labelFontSize: labelFontSize,
                        isDesktop: isDesktop,
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

/// Action button component (Accept/Decline)
class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final IconData icon;
  final String label;
  final double size;
  final double labelFontSize;
  final bool isDesktop;

  const _ActionButton({
    required this.onTap,
    required this.color,
    required this.icon,
    required this.label,
    required this.size,
    required this.labelFontSize,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size * 0.45,
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
