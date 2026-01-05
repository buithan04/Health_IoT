import 'package:flutter/material.dart';
import 'package:health_iot/service/socket_service.dart';
import 'package:health_iot/service/zego_service.dart';
import 'package:health_iot/presentation/shared/widgets/incoming_call_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart'; // Import để lấy navigatorKey

class GlobalCallHandler extends StatefulWidget {
  final Widget child;
  const GlobalCallHandler({super.key, required this.child});

  @override
  State<GlobalCallHandler> createState() => _GlobalCallHandlerState();
}

class _GlobalCallHandlerState extends State<GlobalCallHandler> {
  final SocketService _socketService = SocketService();
  final ZegoService _zegoService = ZegoService();

  String? _myUserId;
  String? _myUserName;
  bool _isShowingIncomingCall = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    // Lắng nghe cuộc gọi ngay khi App khởi động
    _setupGlobalCallListener();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _myUserId = prefs.getString('userId');
      _myUserName = prefs.getString('userName') ?? 'User';
    });

    // Nếu chưa init Zego thì init luôn tại đây để sẵn sàng nhận cuộc gọi
    if (_myUserId != null) {
      _zegoService.initialize(userId: _myUserId!, userName: _myUserName!);
    }
  }

  void _setupGlobalCallListener() {
    // Listen for incoming calls
    _socketService.zegoCallInvitationStream.listen((callData) {
      print('🔔 [GLOBAL] Có cuộc gọi đến: ${callData['callId']}');
      print('   _isShowingIncomingCall: $_isShowingIncomingCall');
      print('   _zegoService.currentState: ${_zegoService.currentState}');
      print('   mounted: $mounted');
      print('   _myUserId: $_myUserId');
      
      // 1. Kiểm tra nếu đang có cuộc gọi rồi thì bỏ qua (hoặc báo bận)
      if (_isShowingIncomingCall || _zegoService.currentState != CallState.idle) {
        print('⚠️ [GLOBAL] Đang bận, bỏ qua cuộc gọi mới');
        print('   _isShowingIncomingCall: $_isShowingIncomingCall');
        print('   currentState: ${_zegoService.currentState}');
        // Optional: Gửi socket event 'busy' lại cho người gọi
        return;
      }

      // 2. Hiển thị màn hình cuộc gọi đến
      if (mounted && _myUserId != null) {
        print('✅ [GLOBAL] Showing incoming call screen...');
        _showIncomingCall(callData);
      } else {
        print('❌ [GLOBAL] Cannot show incoming call: mounted=$mounted, userId=$_myUserId');
      }
    });
    
    // Listen for call ended events (cleanup state)
    _socketService.zegoCallEndedStream.listen((data) {
      print('📴 [GLOBAL] Call ended event received: ${data['callId']}');
      
      // Cleanup local state
      if (_isShowingIncomingCall) {
        print('   Closing incoming call screen...');
        setState(() => _isShowingIncomingCall = false);
        navigatorKey.currentState?.pop();
      }
      
      // Reset ZegoService state
      _zegoService.endCall();
      print('   ✅ State reset to idle');
    });
  }

  void _showIncomingCall(Map<String, dynamic> callData) {
    setState(() => _isShowingIncomingCall = true);

    final String callId = callData['callId']?.toString() ?? '';
    final String callerId = callData['callerId']?.toString() ?? '';
    final String callerName = callData['callerName']?.toString() ?? 'Ai đó';
    final String? callerAvatar = callData['callerAvatar']?.toString();
    final bool isVideoCall = callData['isVideoCall'] as bool? ?? true;

    // Sử dụng navigatorKey để đảm bảo đẩy screen lên trên cùng bất kể đang ở đâu
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => IncomingCallScreen(
          callerName: callerName,
          callerAvatar: callerAvatar,
          isVideoCall: isVideoCall,
          onAccept: () {
            // 1. Đóng màn hình incoming ngay lập tức
            navigatorKey.currentState?.pop();
            setState(() => _isShowingIncomingCall = false);

            // 2. Gửi tín hiệu Accept qua socket
            _socketService.sendCallAccepted(
              targetUserId: callerId,
              callId: callId,
            );

            // 3. Cập nhật state ZegoService
            _zegoService.acceptCall(); // Update state to Connected
            _zegoService.onIncomingCall(
                callId: callId,
                callerId: callerId,
                callerName: callerName,
                isVideoCall: isVideoCall
            );

            // 4. Vào màn hình Zego Video Call ngay (không delay)
            // Đảm bảo vào call page trước khi socket event kịp về
            Future.microtask(() {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => _zegoService.buildCallPage(
                    context: context,
                    callId: callId,
                    localUserId: _myUserId!,
                    localUserName: _myUserName ?? 'Me',
                    remoteUserId: callerId,
                    remoteUserName: callerName,
                    isVideoCall: isVideoCall,
                    onCallEnd: () {
                      _zegoService.endCall();
                      // ZegoUIKit tự động pop màn hình khi kết thúc
                    },
                  ),
                ),
              );
            });
          },
          onDecline: () {
            navigatorKey.currentState?.pop();
            setState(() => _isShowingIncomingCall = false);

            _socketService.sendCallDeclined(
              targetUserId: callerId,
              callId: callId,
            );
          },
        ),
      ),
    ).then((_) {
      // Reset trạng thái khi dialog bị đóng (ví dụ back button android)
      if (mounted) {
        setState(() => _isShowingIncomingCall = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}