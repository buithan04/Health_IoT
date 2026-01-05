import 'dart:async';
import 'dart:ui';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For MissingPluginException
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_uikit/zego_uikit.dart'; // For ZegoLayout, ZegoViewPosition, ZegoUIKitUser
import '../config/zego_config.dart';
import '../main.dart'; // For navigatorKey
import '../core/constants/app_config.dart'; // For avatar URLs

/// ═══════════════════════════════════════════════════════════════════
/// ZegoCallService - Sử dụng ZegoCloud UI có sẵn (SIMPLE & CLEAN)
/// ═══════════════════════════════════════════════════════════════════

class ZegoCallService {
  static final ZegoCallService _instance = ZegoCallService._internal();
  factory ZegoCallService() => _instance;
  ZegoCallService._internal();

  bool _isInitialized = false;
  String? _currentUserId;
  String? _currentUserName;

  /// ═══════════════════════════════════════════════════════════════
  /// INITIALIZE - Gọi 1 lần khi user login
  /// ═══════════════════════════════════════════════════════════════
  Future<void> initialize({
    required String userId,
    required String userName,
    String? userAvatar,
  }) async {
    // Platform check - ZegoCloud not supported on Windows
    if (!kIsWeb && Platform.isWindows) {
      print('⚠️ [ZEGO] Video/Voice calls are NOT SUPPORTED on Windows platform');
      print('   Please use Android or iOS devices for video/voice calling');
      _isInitialized = false;
      return; // Skip initialization on Windows
    }

    // Always re-initialize to ensure pageManager is properly set up
    if (_isInitialized && _currentUserId == userId) {
      print('⚠️ [ZEGO] Already initialized for user $userId - forcing re-init to fix pageManager');
      await uninitialize();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (!ZegoConfig.isConfigured) {
      throw Exception(ZegoConfig.configError);
    }

    print('\n🎬 [ZEGO] ═══ INITIALIZING ZEGO CALL SERVICE ═══');
    print('   AppID: ${ZegoConfig.appID}');
    print('   User ID: $userId');
    print('   User Name: $userName');
    print('   User Avatar: $userAvatar');

    try {
      _currentUserId = userId;
      _currentUserName = userName;

      // Format: "displayName|avatarUrl"
      final formattedUserName = userAvatar != null && userAvatar.isNotEmpty
          ? '$userName|$userAvatar'
          : userName;

      /// CRITICAL: Must provide navigatorKey for pageManager
      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: ZegoConfig.appID,
        appSign: ZegoConfig.appSign,
        userID: userId,
        userName: formattedUserName,
        plugins: [ZegoUIKitSignalingPlugin()],
        
        // 📱 Incoming call UI - Messenger style with avatar
        uiConfig: ZegoCallInvitationUIConfig(
          invitee: ZegoCallInvitationInviteeUIConfig(
            showAvatar: true,
            showCentralName: true,
            showCallingText: true,
            spacingBetweenAvatarAndName: 16,
            
            // Custom background with caller's avatar (blurred)
            backgroundBuilder: (context, size, info) {
              return Stack(
                children: [
                  // Gradient background
                  Container(
                    decoration: const BoxDecoration(
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
                  ),
                  // Blurred avatar overlay
                  if (userAvatar != null && userAvatar.isNotEmpty)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage('${AppConfig.baseUrl}$userAvatar'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                          child: Container(
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        
        notificationConfig: ZegoCallInvitationNotificationConfig(
          androidNotificationConfig: ZegoCallAndroidNotificationConfig(
            channelID: "ZegoUIKit",
            channelName: "Call Notifications",
          ),
        ),
        
        requireConfig: (ZegoCallInvitationData data) {
          // Auto config based on call type
          var config = (data.invitees.length > 1)
              ? (data.type == ZegoCallType.videoCall
                  ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                  : ZegoUIKitPrebuiltCallConfig.groupVoiceCall())
              : (data.type == ZegoCallType.videoCall
                  ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                  : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall());

          // 🎨 Messenger-style customization
          _customizeCallConfig(config);
          
          return config;
        },
      );

      _isInitialized = true;
      print('✅ [ZEGO] Service initialized successfully');
      print('   PageManager should be ready (navigatorKey was set in main.dart)');
      print('═══════════════════════════════════════════\n');
    } on MissingPluginException catch (e) {
      // Windows platform: ZegoCloud plugin not fully implemented
      // Mark as initialized anyway to allow API calls
      print('⚠️ [ZEGO] Plugin not available (Windows platform): $e');
      print('   Marking as initialized anyway - calls may work partially');
      
      _isInitialized = true; // Allow calls to proceed
      _currentUserId = userId;
      _currentUserName = userName;
      
      print('═══════════════════════════════════════════\n');
    } catch (e) {
      _isInitialized = false; // Mark as failed
      _currentUserId = null;
      _currentUserName = null;
      print('❌ [ZEGO] Initialization failed: $e');
      print('═══════════════════════════════════════════\n');
      rethrow;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// START VIDEO CALL
  /// ═══════════════════════════════════════════════════════════════
  Future<void> startVideoCall({
    required BuildContext context,
    required String targetUserId,
    required String targetUserName,
    String? targetUserAvatar,
  }) async {
    // Platform check first
    if (!kIsWeb && Platform.isWindows) {
      throw Exception('🚫 Cuộc gọi video không khả dụng trên Windows.\nVui lòng sử dụng điện thoại Android/iOS để gọi.');
    }

    if (!_isInitialized) {
      throw Exception('ZegoCallService not initialized');
    }

    print('\n📞 [ZEGO] Starting video call to: $targetUserName');

    try {
      // Format: "displayName|avatarUrl"
      final userName = targetUserAvatar != null && targetUserAvatar.isNotEmpty
          ? '$targetUserName|$targetUserAvatar'
          : targetUserName;
      
      await ZegoUIKitPrebuiltCallInvitationService().send(
        isVideoCall: true,
        invitees: [
          ZegoCallUser(
            targetUserId,
            userName,
          ),
        ],
        // Optional: Custom data
        customData: 'video_call_from_${_currentUserId}',
      );
    } on AssertionError catch (e) {
      // pageManager is null on Windows platform
      print('❌ [ZEGO] Assertion error (Windows): $e');
      throw Exception('Video calls not supported on Windows. Please use Android or iOS.');
    } on MissingPluginException catch (e) {
      print('⚠️ [ZEGO] Plugin error on Windows: $e');
      throw Exception('Video calls not supported on Windows platform. Please use Android or iOS.');
    } catch (e) {
      print('❌ [ZEGO] Error sending video call: $e');
      rethrow;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// START VOICE CALL
  /// ═══════════════════════════════════════════════════════════════
  Future<void> startVoiceCall({
    required BuildContext context,
    required String targetUserId,
    required String targetUserName,
    String? targetUserAvatar,
  }) async {
    // Platform check first
    if (!kIsWeb && Platform.isWindows) {
      throw Exception('🚫 Cuộc gọi thoại không khả dụng trên Windows.\nVui lòng sử dụng điện thoại Android/iOS để gọi.');
    }

    if (!_isInitialized) {
      throw Exception('ZegoCallService not initialized');
    }

    print('\n📞 [ZEGO] Starting voice call to: $targetUserName');

    try {
      // Format: "displayName|avatarUrl"
      final userName = targetUserAvatar != null && targetUserAvatar.isNotEmpty
          ? '$targetUserName|$targetUserAvatar'
          : targetUserName;
      
      await ZegoUIKitPrebuiltCallInvitationService().send(
        isVideoCall: false,
        invitees: [
          ZegoCallUser(
            targetUserId,
            userName,
          ),
        ],
        customData: 'voice_call_from_${_currentUserId}',
      );
    } on AssertionError catch (e) {
      // pageManager is null on Windows platform
      print('❌ [ZEGO] Assertion error (Windows): $e');
      throw Exception('Voice calls not supported on Windows. Please use Android or iOS.');
    } on MissingPluginException catch (e) {
      print('⚠️ [ZEGO] Plugin error on Windows: $e');
      throw Exception('Voice calls not supported on Windows platform. Please use Android or iOS.');
    } catch (e) {
      print('❌ [ZEGO] Error sending voice call: $e');
      rethrow;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// MESSENGER-STYLE CALL UI CUSTOMIZATION
  /// ═══════════════════════════════════════════════════════════════
  void _customizeCallConfig(ZegoUIKitPrebuiltCallConfig config) {
    // 📐 Layout - Picture-in-picture (Messenger style)
    config.layout = ZegoLayout.pictureInPicture(
      isSmallViewDraggable: true,
      switchLargeOrSmallViewByClick: true,
      smallViewSize: const Size(90, 160),
      smallViewPosition: ZegoViewPosition.topRight,
      smallViewMargin: const EdgeInsets.all(16),
    );

    // 🎨 Background gradient
    config.background = Container(
      decoration: const BoxDecoration(
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

    // 👤 Avatar builder - Always show image (never letter)
    config.avatarBuilder = (BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
      if (user == null) {
        print('⚠️ [ZEGO AVATAR] User is null');
        return const SizedBox();
      }
      
      // Extract avatar URL from user name (format: "name|avatarUrl")
      final parts = user.name.split('|');
      final displayName = parts[0];
      final avatarUrl = parts.length > 1 ? parts[1] : '';
      
      print('👤 [ZEGO AVATAR] Building avatar for ${user.id}');
      print('   Raw name: ${user.name}');
      print('   Display name: $displayName');
      print('   Avatar URL: $avatarUrl');
      print('   Full URL: ${avatarUrl.isNotEmpty ? "${AppConfig.baseUrl}$avatarUrl" : "default"}');
      
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: size.width / 2,
          backgroundColor: Colors.grey[300],
          child: ClipOval(
            child: avatarUrl.isNotEmpty
              ? Image.network(
                  '${AppConfig.baseUrl}$avatarUrl',
                  width: size.width,
                  height: size.width,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('❌ [ZEGO AVATAR] Failed to load: ${AppConfig.baseUrl}$avatarUrl');
                    print('   Error: $error');
                    // Fallback to default avatar on error
                    return Image.asset(
                      'assets/images/default_avatar.png',
                      width: size.width,
                      height: size.width,
                      fit: BoxFit.cover,
                    );
                  },
                )
              : Image.asset(
                  'assets/images/default_avatar.png',
                  width: size.width,
                  height: size.width,
                  fit: BoxFit.cover,
                ),
          ),
        ),
      );
    };

    // 📹 Audio/Video view customization - Name overlay
    config.audioVideoViewConfig.foregroundBuilder = (
      BuildContext context,
      Size size,
      ZegoUIKitUser? user,
      Map extraInfo,
    ) {
      if (user == null) return const SizedBox();
      
      // Extract display name (format: "name|avatarUrl")
      final parts = user.name.split('|');
      final displayName = parts[0];
      
      return Positioned(
        bottom: 8,
        left: 8,
        right: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    };

    config.audioVideoViewConfig.useVideoViewAspectFill = true;
    config.audioVideoViewConfig.showUserNameOnView = true;

    // 🏛️ Bottom menu bar - Messenger style (always visible)
    config.bottomMenuBarConfig = ZegoBottomMenuBarConfig(
      maxCount: 5,
      hideByClick: false,
      hideAutomatically: false,
      buttons: [
        ZegoMenuBarButtonName.toggleCameraButton,
        ZegoMenuBarButtonName.toggleMicrophoneButton,
        ZegoMenuBarButtonName.hangUpButton,
        ZegoMenuBarButtonName.switchCameraButton,
        ZegoMenuBarButtonName.switchAudioOutputButton,
      ],
      backgroundColor: Colors.black.withOpacity(0.3),
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
    );

    // 📊 Top menu bar
    config.topMenuBarConfig = ZegoTopMenuBarConfig(
      buttons: [
        ZegoMenuBarButtonName.minimizingButton,
        ZegoMenuBarButtonName.showMemberListButton,
      ],
      height: 60,
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    );

    // ⚙️ Call defaults
    config.turnOnCameraWhenJoining = true;
    config.turnOnMicrophoneWhenJoining = true;
    // Windows: Don't use speaker (setAudioRouteToSpeaker not supported)
    config.useSpeakerWhenJoining = !(!kIsWeb && Platform.isWindows);
    
    // ✅ Hang up confirmation dialog (only title and message are supported)
    config.hangUpConfirmDialog.info = ZegoCallHangUpConfirmDialogInfo(
      title: 'Kết thúc cuộc gọi?',
      message: 'Bạn có chắc chắn muốn kết thúc cuộc gọi này không?',
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// UNINITIALIZE - Gọi khi user logout
  /// ═══════════════════════════════════════════════════════════════
  Future<void> uninitialize() async {
    if (!_isInitialized) return;

    print('\n🔴 [ZEGO] Uninitializing service...');

    try {
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
      _isInitialized = false;
      _currentUserId = null;
      _currentUserName = null;

      print('✅ [ZEGO] Service uninitialized');
    } catch (e) {
      print('❌ [ZEGO] Error uninitializing: $e');
    }
  }

  /// Get current user ID
  String? get currentUserId => _currentUserId;
  
  /// Get current user name
  String? get currentUserName => _currentUserName;
  
  /// Check if initialized
  bool get isInitialized => _isInitialized;
}
