import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'zego_service.dart';
import 'socket_service.dart';

/// Call Manager - Quản lý toàn bộ lifecycle của cuộc gọi
/// 
/// 5 Giai đoạn:
/// 1. Pre-call: Permission, Network, Device check
/// 2. Signaling: Session creation, Push notification, Timeout
/// 3. Handshake: SDP exchange, ICE candidates (tự động bởi ZegoCloud)
/// 4. Active Session: Bitrate adaptation, UI events, PiP
/// 5. Cleanup: End signaling, Release hardware, Call log

class CallManager {
  // Singleton
  static final CallManager _instance = CallManager._internal();
  factory CallManager() => _instance;
  CallManager._internal();

  // Configuration
  static const int CALL_TIMEOUT_SECONDS = 45;
  static const int MIN_NETWORK_SPEED_KBPS = 100; // Minimum 100 kbps
  
  // State
  Timer? _callTimeoutTimer;
  DateTime? _callInitiatedTime;
  String? _pendingCallId;
  
  // Callbacks
  VoidCallback? _onCallTimeout;
  VoidCallback? _onCallAccepted;
  VoidCallback? _onCallDeclined;

  /// ════════════════════════════════════════════════════════
  /// GIAI ĐOẠN 1: PRE-CALL CHECKS
  /// ════════════════════════════════════════════════════════
  
  /// Kiểm tra và yêu cầu quyền Camera/Microphone
  Future<PermissionCheckResult> checkAndRequestPermissions({
    required bool isVideoCall,
  }) async {
    print('\n🔐 [CALL_MANAGER] ═══ CHECKING PERMISSIONS ═══');
    
    try {
      // Kiểm tra microphone (bắt buộc cho cả audio và video call)
      PermissionStatus micStatus = await Permission.microphone.status;
      print('   🎤 Microphone: ${micStatus.name}');
      
      if (!micStatus.isGranted) {
        print('   ⚠️  Requesting microphone permission...');
        micStatus = await Permission.microphone.request();
        
        if (!micStatus.isGranted) {
          print('   ❌ Microphone permission denied');
          return PermissionCheckResult(
            granted: false,
            message: 'Cần quyền truy cập Microphone để thực hiện cuộc gọi',
            shouldOpenSettings: micStatus.isPermanentlyDenied,
          );
        }
      }
      
      // Kiểm tra camera (chỉ cần cho video call)
      if (isVideoCall) {
        PermissionStatus cameraStatus = await Permission.camera.status;
        print('   📹 Camera: ${cameraStatus.name}');
        
        if (!cameraStatus.isGranted) {
          print('   ⚠️  Requesting camera permission...');
          cameraStatus = await Permission.camera.request();
          
          if (!cameraStatus.isGranted) {
            print('   ❌ Camera permission denied');
            return PermissionCheckResult(
              granted: false,
              message: 'Cần quyền truy cập Camera để thực hiện video call',
              shouldOpenSettings: cameraStatus.isPermanentlyDenied,
            );
          }
        }
      }
      
      print('   ✅ All permissions granted');
      print('═══════════════════════════════════════════\n');
      return PermissionCheckResult(granted: true);
      
    } catch (e) {
      print('   ❌ Error checking permissions: $e');
      print('═══════════════════════════════════════════\n');
      return PermissionCheckResult(
        granted: false,
        message: 'Lỗi kiểm tra quyền: ${e.toString()}',
      );
    }
  }
  
  /// Kiểm tra kết nối mạng
  Future<NetworkCheckResult> checkNetworkConnection() async {
    print('\n📡 [CALL_MANAGER] ═══ CHECKING NETWORK ═══');
    
    try {
      // Kiểm tra connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      
      if (connectivityResult.contains(ConnectivityResult.none)) {
        print('   ❌ No internet connection');
        print('═══════════════════════════════════════════\n');
        return NetworkCheckResult(
          isConnected: false,
          message: 'Không có kết nối Internet',
        );
      }
      
      String connectionType = 'Unknown';
      bool isStableConnection = true;
      
      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        connectionType = 'WiFi';
        isStableConnection = true;
      } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
        connectionType = 'Mobile Data';
        isStableConnection = true; // Giả định 4G/5G ổn định
      } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
        connectionType = 'Ethernet';
        isStableConnection = true;
      }
      
      print('   📶 Connection: $connectionType');
      print('   ✅ Network is available');
      
      if (!isStableConnection) {
        print('   ⚠️  Network might be unstable');
        print('═══════════════════════════════════════════\n');
        return NetworkCheckResult(
          isConnected: true,
          isStable: false,
          connectionType: connectionType,
          message: 'Kết nối mạng không ổn định. Cuộc gọi có thể bị giật.',
        );
      }
      
      print('═══════════════════════════════════════════\n');
      return NetworkCheckResult(
        isConnected: true,
        isStable: true,
        connectionType: connectionType,
      );
      
    } catch (e) {
      print('   ❌ Error checking network: $e');
      print('═══════════════════════════════════════════\n');
      return NetworkCheckResult(
        isConnected: false,
        message: 'Lỗi kiểm tra mạng: ${e.toString()}',
      );
    }
  }
  
  /// Kiểm tra trạng thái thiết bị (có cuộc gọi khác đang diễn ra không)
  Future<DeviceCheckResult> checkDeviceStatus() async {
    print('\n📱 [CALL_MANAGER] ═══ CHECKING DEVICE STATUS ═══');
    
    try {
      // Kiểm tra xem có cuộc gọi đang diễn ra không
      final currentState = ZegoService().currentState;
      
      if (currentState == CallState.calling || 
          currentState == CallState.connected || 
          currentState == CallState.ringing) {
        print('   ⚠️  Another call is in progress');
        print('   Current state: ${currentState.name}');
        print('═══════════════════════════════════════════\n');
        return DeviceCheckResult(
          isAvailable: false,
          message: 'Đang có cuộc gọi khác. Vui lòng kết thúc trước khi gọi mới.',
        );
      }
      
      print('   ✅ Device is available');
      print('═══════════════════════════════════════════\n');
      return DeviceCheckResult(isAvailable: true);
      
    } catch (e) {
      print('   ❌ Error checking device: $e');
      print('═══════════════════════════════════════════\n');
      return DeviceCheckResult(
        isAvailable: false,
        message: 'Lỗi kiểm tra thiết bị: ${e.toString()}',
      );
    }
  }
  
  /// Thực hiện TẤT CẢ kiểm tra pre-call
  Future<PreCallCheckResult> performPreCallChecks({
    required bool isVideoCall,
  }) async {
    print('\n🔍 [CALL_MANAGER] ═══ PERFORMING PRE-CALL CHECKS ═══\n');
    
    // 1. Check permissions
    final permissionResult = await checkAndRequestPermissions(
      isVideoCall: isVideoCall,
    );
    if (!permissionResult.granted) {
      return PreCallCheckResult(
        canProceed: false,
        message: permissionResult.message,
        shouldOpenSettings: permissionResult.shouldOpenSettings,
      );
    }
    
    // 2. Check network
    final networkResult = await checkNetworkConnection();
    if (!networkResult.isConnected) {
      return PreCallCheckResult(
        canProceed: false,
        message: networkResult.message,
      );
    }
    
    // 3. Check device status
    final deviceResult = await checkDeviceStatus();
    if (!deviceResult.isAvailable) {
      return PreCallCheckResult(
        canProceed: false,
        message: deviceResult.message,
      );
    }
    
    // Tất cả đều OK!
    print('✅ [CALL_MANAGER] All pre-call checks passed\n');
    return PreCallCheckResult(
      canProceed: true,
      networkWarning: !networkResult.isStable ? networkResult.message : null,
    );
  }

  /// ════════════════════════════════════════════════════════
  /// GIAI ĐOẠN 2: SIGNALING & TIMEOUT
  /// ════════════════════════════════════════════════════════
  
  /// Bắt đầu timeout timer cho cuộc gọi
  void startCallTimeout({
    required String callId,
    required VoidCallback onTimeout,
  }) {
    print('\n⏱️  [CALL_MANAGER] Starting call timeout (${CALL_TIMEOUT_SECONDS}s)');
    print('   Call ID: $callId\n');
    
    _pendingCallId = callId;
    _callInitiatedTime = DateTime.now();
    _onCallTimeout = onTimeout;
    
    // Cancel existing timer if any
    _callTimeoutTimer?.cancel();
    
    // Start new timer
    _callTimeoutTimer = Timer(Duration(seconds: CALL_TIMEOUT_SECONDS), () {
      print('\n⏰ [CALL_MANAGER] ═══ CALL TIMEOUT ═══');
      print('   Call ID: $_pendingCallId');
      print('   Duration: ${CALL_TIMEOUT_SECONDS}s elapsed');
      print('   Status: No answer\n');
      
      // Trigger timeout callback
      if (_onCallTimeout != null) {
        _onCallTimeout!();
        _onCallTimeout = null;
      }
      
      // Cleanup
      _cleanup();
    });
  }
  
  /// Hủy timeout timer (khi cuộc gọi được accept/decline)
  void cancelCallTimeout() {
    if (_callTimeoutTimer != null) {
      print('\n✅ [CALL_MANAGER] Call timeout cancelled\n');
      _callTimeoutTimer?.cancel();
      _callTimeoutTimer = null;
    }
  }
  
  /// Lấy thời gian đã trôi qua kể từ khi bắt đầu gọi
  int getElapsedSeconds() {
    if (_callInitiatedTime == null) return 0;
    return DateTime.now().difference(_callInitiatedTime!).inSeconds;
  }

  /// ════════════════════════════════════════════════════════
  /// GIAI ĐOẠN 5: CLEANUP & RELEASE
  /// ════════════════════════════════════════════════════════
  
  /// Giải phóng tài nguyên
  void _cleanup() {
    _callTimeoutTimer?.cancel();
    _callTimeoutTimer = null;
    _pendingCallId = null;
    _callInitiatedTime = null;
    _onCallTimeout = null;
    _onCallAccepted = null;
    _onCallDeclined = null;
  }
  
  /// Reset toàn bộ state
  void reset() {
    print('\n🔄 [CALL_MANAGER] Resetting state\n');
    _cleanup();
  }
}

/// ════════════════════════════════════════════════════════
/// RESULT CLASSES
/// ════════════════════════════════════════════════════════

class PermissionCheckResult {
  final bool granted;
  final String? message;
  final bool shouldOpenSettings;

  PermissionCheckResult({
    required this.granted,
    this.message,
    this.shouldOpenSettings = false,
  });
}

class NetworkCheckResult {
  final bool isConnected;
  final bool isStable;
  final String? connectionType;
  final String? message;

  NetworkCheckResult({
    required this.isConnected,
    this.isStable = true,
    this.connectionType,
    this.message,
  });
}

class DeviceCheckResult {
  final bool isAvailable;
  final String? message;

  DeviceCheckResult({
    required this.isAvailable,
    this.message,
  });
}

class PreCallCheckResult {
  final bool canProceed;
  final String? message;
  final String? networkWarning;
  final bool shouldOpenSettings;

  PreCallCheckResult({
    required this.canProceed,
    this.message,
    this.networkWarning,
    this.shouldOpenSettings = false,
  });
}
