import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit/zego_uikit.dart';
import '../config/zego_config.dart';
import 'socket_service.dart';

enum CallState {
  idle,
  calling,
  ringing,
  connected,
  ended,
}

class ZegoService {
  // Singleton pattern
  static final ZegoService _instance = ZegoService._internal();
  factory ZegoService() => _instance;
  ZegoService._internal();

  // State management
  CallState _currentState = CallState.idle;
  String? _currentCallId;
  String? _remoteUserId;
  String? _remoteUserName;
  bool _isVideoCall = false;
  bool _isInitialized = false;
  DateTime? _callStartTime;

  // Stream controllers
  final _callStateController = StreamController<CallState>.broadcast();
  Stream<CallState> get callStateStream => _callStateController.stream;
  CallState get currentState => _currentState;
  bool get isVideoCall => _isVideoCall;
  String? get currentCallId => _currentCallId;

  /// Khởi tạo ZegoCloud SDK
  Future<void> initialize({
    required String userId,
    required String userName,
  }) async {
    if (_isInitialized) {
      print('✅ [ZEGO] Already initialized');
      return;
    }

    if (!ZegoConfig.isConfigured) {
      throw Exception(ZegoConfig.configError);
    }

    print('\n🎬 [ZEGO] ═══ INITIALIZING ZEGO SDK ═══');
    print('   AppID: ${ZegoConfig.appID}');
    print('   User ID: $userId');
    print('   User Name: $userName');

    try {
      // Khởi tạo ZegoUIKit
      ZegoUIKit().init(
        appID: ZegoConfig.appID,
        appSign: ZegoConfig.appSign,
      );

      // Login user
      ZegoUIKit().login(userId, userName);

      _isInitialized = true;
      print('✅ [ZEGO] SDK initialized successfully');
      print('═══════════════════════════════════════════\n');
    } catch (e) {
      print('❌ [ZEGO] Initialization failed: $e');
      print('═══════════════════════════════════════════\n');
      rethrow;
    }
  }

  /// Bắt đầu cuộc gọi (Caller)
  Future<bool> startCall({
    required String targetUserId,
    required String targetUserName,
    required bool isVideoCall,
  }) async {
    if (!_isInitialized) {
      print('❌ [ZEGO] Not initialized');
      return false;
    }

    print('\n📞 [ZEGO] ═══ STARTING CALL ═══');
    print('   To: $targetUserName ($targetUserId)');
    print('   Type: ${isVideoCall ? 'Video' : 'Audio'}');

    try {
      _currentCallId = 'call_${DateTime.now().millisecondsSinceEpoch}';
      _remoteUserId = targetUserId;
      _remoteUserName = targetUserName;
      _isVideoCall = isVideoCall;
      _callStartTime = null; // Reset call start time
      _updateState(CallState.calling);

      // Send invitation via socket
      SocketService().sendCallInvitation(
        targetUserId: targetUserId,
        callId: _currentCallId!,
        isVideoCall: isVideoCall,
      );

      print('✅ [ZEGO] Call invitation sent');
      print('   Call ID: $_currentCallId');
      print('═══════════════════════════════════════════\n');
      return true;
    } catch (e) {
      print('❌ [ZEGO] Start call failed: $e');
      print('═══════════════════════════════════════════\n');
      return false;
    }
  }

  /// Xử lý khi có cuộc gọi đến (Receiver)
  void onIncomingCall({
    required String callId,
    required String callerId,
    required String callerName,
    required bool isVideoCall,
  }) {
    print('\n📲 [ZEGO] ═══ INCOMING CALL ═══');
    print('   From: $callerName ($callerId)');
    print('   Type: ${isVideoCall ? 'Video' : 'Audio'}');
    print('   Call ID: $callId');
    print('═══════════════════════════════════════════\n');

    _currentCallId = callId;
    _remoteUserId = callerId;
    _remoteUserName = callerName;
    _isVideoCall = isVideoCall;
    _updateState(CallState.ringing);
  }

  /// Accept call
  void acceptCall() {
    print('\n✅ [ZEGO] Accepting call: $_currentCallId\n');
    _callStartTime = DateTime.now();
    _updateState(CallState.connected);
  }

  /// Decline call
  void declineCall() {
    print('\n❌ [ZEGO] Declining call: $_currentCallId\n');
    if (_currentCallId != null && _remoteUserId != null) {
      SocketService().sendCallDeclined(
        targetUserId: _remoteUserId!,
        callId: _currentCallId!,
      );
    }
    _cleanup();
  }

  /// Kết thúc cuộc gọi
  Future<void> endCall() async {
    if (_currentCallId == null) {
      print('❌ [ZEGO] No active call to end');
      return;
    }

    print('\n📴 [ZEGO] ═══ ENDING CALL ═══');
    print('   Call ID: $_currentCallId');

    try {
      // Tính duration nếu đã kết nối
      int duration = 0;
      if (_callStartTime != null) {
        duration = DateTime.now().difference(_callStartTime!).inSeconds;
        print('   Duration: ${duration}s');
      }

      if (_remoteUserId != null) {
        SocketService().sendCallEnded(
          targetUserId: _remoteUserId!,
          callId: _currentCallId!,
          duration: duration,
        );
      }

      _cleanup();
      print('✅ [ZEGO] Call ended');
      print('═══════════════════════════════════════════\n');
    } catch (e) {
      print('❌ [ZEGO] End call failed: $e');
      print('═══════════════════════════════════════════\n');
    }
  }

  /// Dispose
  void dispose() {
    _cleanup();
  }

  /// Build call page widget - MESSENGER STYLE
  Widget buildCallPage({
    required BuildContext context,
    required String callId,
    required String localUserId,
    required String localUserName,
    required String remoteUserId,
    required String remoteUserName,
    required bool isVideoCall,
    required VoidCallback onCallEnd,
  }) {
    // Detect screen size
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    final config = isVideoCall
        ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    // Turn on camera/mic immediately
    config.turnOnCameraWhenJoining = isVideoCall;
    config.turnOnMicrophoneWhenJoining = true;
    config.useSpeakerWhenJoining = isVideoCall;

    // ══════════════════════════════════════════
    // 🎨 MESSENGER-STYLE CUSTOMIZATION
    // ══════════════════════════════════════════

    // Video layout - Picture-in-Picture
    if (isVideoCall) {
      config.layout = ZegoLayout.pictureInPicture(
        isSmallViewDraggable: true,
        switchLargeOrSmallViewByClick: true,
        smallViewSize: Size(
          isDesktop ? 140 : 90,
          isDesktop ? 200 : 130,
        ),
        smallViewPosition: ZegoViewPosition.topRight,
        smallViewMargin: EdgeInsets.all(isDesktop ? 16 : 12),
      );
    }

    // Avatar - Gradient style
    config.avatarBuilder = (context, size, user, extraInfo) {
      final avatarSize = isDesktop ? size.width * 0.6 : size.width * 0.5;
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: avatarSize / 2,
          backgroundColor: Colors.transparent,
          child: Text(
            user?.name?.substring(0, 1).toUpperCase() ?? '?',
            style: TextStyle(
              fontSize: avatarSize * 0.35,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    };

    // Background - Gradient
    config.background = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
          ],
        ),
      ),
    );

    // Audio/Video view - Name overlay
    config.audioVideoView.foregroundBuilder = (context, size, user, extraInfo) {
      return Positioned(
        bottom: 8,
        left: 8,
        right: 8,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user?.name ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      );
    };

    // Wrap with WillPopScope to handle back button
    return WillPopScope(
      onWillPop: () async {
        print('📴 [ZEGO] Call page closing, triggering onCallEnd');
        onCallEnd();
        return true;
      },
      child: ZegoUIKitPrebuiltCall(
        appID: ZegoConfig.appID,
        appSign: ZegoConfig.appSign,
        callID: callId,
        userID: localUserId,
        userName: localUserName,
        config: config,
      ),
    );
  }

  // --- PRIVATE HELPERS ---

  void _updateState(CallState state) {
    print('📱 [ZEGO] State change: $_currentState → $state');
    _currentState = state;
    _callStateController.add(state);
  }

  void _cleanup() {
    print('🧹 [ZEGO] Cleanup: Resetting state to idle');
    _currentCallId = null;
    _remoteUserId = null;
    _remoteUserName = null;
    _callStartTime = null;
    _updateState(CallState.idle);
    print('   Current state after cleanup: $_currentState');
  }
}