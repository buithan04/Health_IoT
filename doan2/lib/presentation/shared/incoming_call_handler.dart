// FILE MẪU: lib/presentation/shared/incoming_call_handler.dart
// Thêm file này để xử lý cuộc gọi đến (ZegoCloud version)

import 'package:flutter/material.dart';
import 'package:app_iot/service/socket_service.dart';
import 'package:app_iot/service/zego_service.dart';
import 'package:app_iot/presentation/shared/widgets/incoming_call_screen.dart';

class IncomingCallHandler {
  static void initialize(BuildContext context, String myUserId, String myUserName) {
    // Lắng nghe cuộc gọi ZegoCloud đến
    SocketService().zegoCallInvitationStream.listen((callData) {
      _showIncomingCallDialog(
        context,
        callData: callData,
        myUserId: myUserId,
        myUserName: myUserName,
      );
    });
  }

  static void _showIncomingCallDialog(
    BuildContext context, {
    required Map<String, dynamic> callData,
    required String myUserId,
    required String myUserName,
  }) {
    final String callId = callData['callId']?.toString() ?? '';
    final String callerId = callData['callerId']?.toString() ?? '';
    final String callerName = callData['callerName']?.toString() ?? 'Ai đó';
    final String? callerAvatar = callData['callerAvatar']?.toString();
    final bool isVideoCall = callData['isVideoCall'] as bool? ?? true;

    // Show Full-Screen Incoming Call UI
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => IncomingCallScreen(
          callerName: callerName,
          callerAvatar: callerAvatar,
          isVideoCall: isVideoCall,
          onAccept: () {
            Navigator.of(ctx).pop(); // Close incoming screen
            ZegoService().acceptCall();
            // Navigate to ZegoCloud call screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ZegoService().buildCallPage(
                  context: context,
                  callId: callId,
                  localUserId: myUserId,
                  localUserName: myUserName,
                  remoteUserId: callerId,
                  remoteUserName: callerName,
                  isVideoCall: isVideoCall,
                  onCallEnd: () {
                    ZegoService().endCall();
                  },
                ),
              ),
            );
          },
          onDecline: () {
            Navigator.of(ctx).pop(); // Close incoming screen
            ZegoService().declineCall();
          },
        ),
      ),
    );
  }
}
