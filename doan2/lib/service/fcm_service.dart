import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:app_iot/core/api/api_client.dart';
import 'package:app_iot/main.dart'; // For navigatorKey
import 'package:app_iot/presentation/shared/widgets/incoming_call_screen.dart';
import 'package:app_iot/service/zego_service.dart';
import 'package:app_iot/service/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- HÀM BACKGROUND HANDLER (QUAN TRỌNG NHẤT CHO KHI TẮT APP) ---
// Phải để ở top-level (ngoài class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🌙 (Tắt App) Nhận thông báo: ${message.messageId}");
  // Android tự động hiển thị thông báo nếu payload có 'notification'
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final ApiClient _apiClient = ApiClient();

  // Tạo kênh thông báo ưu tiên cao (Để rung, kêu to, hiện popup)
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'health_ai_high_importance', // ID kênh (Phải trùng với Backend)
    'Cảnh báo khẩn cấp',
    description: 'Kênh thông báo cho các cảnh báo sức khỏe quan trọng',
    importance: Importance.max, // MAX = Popup đè lên màn hình
    playSound: true,
    enableVibration: true,
  );

  Future<void> initialize() async {
    // 1. Xin quyền (Bắt buộc cho Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Đã cấp quyền thông báo');

      // 2. Lấy Token thiết bị
      String? token = await _fcm.getToken();
      if (token != null) {
        print("🔥 FCM Token của máy này: $token");
        _sendTokenToServer(token);
      }

      // Lắng nghe khi token thay đổi
      _fcm.onTokenRefresh.listen(_sendTokenToServer);

      // 3. Cấu hình Local Notification
      await _setupLocalNotifications();

      // 4. Đăng ký hàm xử lý khi TẮT APP
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 5. Xử lý khi App ĐANG MỞ (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("☀️ (Mở App) Nhận thông báo: ${message.notification?.title}");

        // Chỉ hiển thị banner nếu có notification payload
        if (message.notification != null) {
          _showForegroundNotification(message);
        }
      });

      // 6. Xử lý khi BẤM VÀO thông báo
      _setupInteractedMessage();
    }
  }

  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Xử lý khi bấm vào thông báo banner (khi app đang mở)
        if (response.payload != null) {
          print("👆 Bấm vào notification banner: ${response.payload}");
          try {
            final data = jsonDecode(response.payload!);
            _navigateFromNotification(data);
          } catch (e) {
            print("❌ Lỗi parse notification payload: $e");
          }
        }
      },
    );

    // Tạo kênh Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  void _showForegroundNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      // Tạo payload từ data của message
      final payload = jsonEncode(message.data);
      
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF0D9488), // Màu Teal chủ đạo
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(
              notification.body ?? '',
              htmlFormatBigText: true,
              contentTitle: '<b>${notification.title}</b>',
              htmlFormatContentTitle: true,
            ),
          ),
        ),
        payload: payload,
      );
    }
  }

  Future<void> _setupInteractedMessage() async {
    // Case 1: App tắt hoàn toàn -> Bấm mở App
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageNavigation(initialMessage);
    }

    // Case 2: App chạy ngầm -> Bấm mở lại App
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);
  }

  void _handleMessageNavigation(RemoteMessage message) {
    print("🚀 Điều hướng từ thông báo (app background/terminated): ${message.data}");
    _navigateFromNotification(message.data);
  }

  /// Navigate based on notification data
  void _navigateFromNotification(Map<String, dynamic> data) {
    print("📍 Navigation data: $data");
    
    final type = data['type']?.toString();
    final conversationId = data['conversationId']?.toString();
    final partnerId = data['partnerId']?.toString();
    final partnerName = data['partnerName']?.toString();
    final partnerAvatar = data['partnerAvatar']?.toString();
    
    // Đợi một chút để đảm bảo router đã sẵn sàng
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        if (type == 'video_call') {
          // Video call notification - Show incoming call screen DIRECTLY
          print("📞 Incoming call notification - Showing incoming call screen");
          final callId = data['callId']?.toString();
          final callerId = data['callerId']?.toString();
          final callerName = data['callerName']?.toString();
          final callerAvatar = data['callerAvatar']?.toString();
          final isVideoCall = data['isVideoCall']?.toString() == 'true';
          
          if (callId != null && callerId != null && callerName != null) {
            // Import và show IncomingCallScreen trực tiếp
            _showIncomingCallFromNotification(
              callId: callId,
              callerId: callerId,
              callerName: callerName,
              callerAvatar: callerAvatar,
              isVideoCall: isVideoCall,
            );
          } else {
            print("⚠️ Missing call data in notification");
          }
        } else if (type == 'message' && conversationId != null) {
          // Navigate to chat detail - Dùng GoRouter.of(context) thay vì context.push
          print("📱 Navigating to chat: $conversationId");
          final context = navigatorKey.currentContext;
          if (context != null && context.mounted) {
            GoRouter.of(context).push(
              '/chat/details/$conversationId?'
              'partnerId=$partnerId&'
              'name=${Uri.encodeComponent(partnerName ?? '')}&'
              'avatar=${Uri.encodeComponent(partnerAvatar ?? '')}',
            );
          } else {
            print("⚠️ Context not mounted, cannot navigate");
          }
        } else if (type == 'appointment') {
          // Navigate to appointments
          print("📅 Navigating to appointments");
          final context = navigatorKey.currentContext;
          if (context != null && context.mounted) {
            GoRouter.of(context).push('/appointments');
          }
        } else {
          print("ℹ️ Unknown notification type: $type");
        }
      } catch (e) {
        print("❌ Error navigating: $e");
      }
    });
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      await _apiClient.put('/user/fcm-token', {'fcmToken': token}).timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('FCM token timeout'),
      );
      print("✅ Đã gửi FCM Token thành công");
    } catch (e) {
      print("⚠️ Không thể gửi FCM Token (sẽ thử lại sau): ${e.toString().substring(0, 100)}");
      // Không throw exception để không block login/register
    }
  }

  // Gọi hàm này sau khi Login thành công để đảm bảo Token gắn với User đúng
  Future<void> syncTokenAfterLogin() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        print("🔄 Đang đồng bộ lại FCM Token sau khi Login...");
        await _sendTokenToServer(token);
      }
    } catch (e) {
      print("⚠️ Bỏ qua lỗi FCM token sync: $e");
      // Không throw - đảm bảo login vẫn tiếp tục
    }
  }

  /// Show incoming call screen directly from FCM notification
  void _showIncomingCallFromNotification({
    required String callId,
    required String callerId,
    required String callerName,
    String? callerAvatar,
    required bool isVideoCall,
  }) async {
    print('\n🔔 [FCM] Showing incoming call screen');
    print('   Call ID: $callId');
    print('   From: $callerName ($callerId)');
    print('   Type: ${isVideoCall ? 'Video' : 'Audio'}');

    try {
      // Get current user info
      final prefs = await SharedPreferences.getInstance();
      final myUserId = prefs.getString('userId');
      final myUserName = prefs.getString('userName') ?? 'User';

      if (myUserId == null) {
        print('⚠️ [FCM] User not logged in, cannot show incoming call');
        return;
      }

      // Initialize ZegoService if needed
      if (!ZegoService().currentState.toString().contains('idle')) {
        print('⚠️ [FCM] Already in a call, ignoring');
        return;
      }

      // Update ZegoService state
      ZegoService().onIncomingCall(
        callId: callId,
        callerId: callerId,
        callerName: callerName,
        isVideoCall: isVideoCall,
      );

      // Show incoming call screen
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (ctx) => IncomingCallScreen(
            callerName: callerName,
            callerAvatar: callerAvatar,
            isVideoCall: isVideoCall,
            onAccept: () {
              print('✅ [FCM] Call accepted');
              // Close incoming screen
              navigatorKey.currentState?.pop();

              // Send accept signal via socket
              SocketService().sendCallAccepted(
                targetUserId: callerId,
                callId: callId,
              );

              // Update ZegoService state
              ZegoService().acceptCall();

              // Navigate to call page
              Future.microtask(() {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
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
              });
            },
            onDecline: () {
              print('❌ [FCM] Call declined');
              navigatorKey.currentState?.pop();

              // Send decline signal via socket
              SocketService().sendCallDeclined(
                targetUserId: callerId,
                callId: callId,
              );

              // Cleanup ZegoService
              ZegoService().declineCall();
            },
          ),
        ),
      );

      print('✅ [FCM] Incoming call screen shown');
    } catch (e) {
      print('❌ [FCM] Error showing incoming call: $e');
    }
  }
}