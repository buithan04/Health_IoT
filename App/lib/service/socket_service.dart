import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:health_iot/core/api/api_client.dart';
import 'package:health_iot/service/mqtt_service.dart';

class SocketService {
  // Singleton Pattern
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final ApiClient _apiClient = ApiClient();

  // --- STREAMS ---
  // Giữ StreamController luôn mở trong suốt vòng đời App (vì là Singleton)

  // 1. Stream cho Chat (Tin nhắn mới)
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  // 2. Stream cho Thông báo (Global)
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;

  // 3. Stream cho Health Alerts (Real-time dangerous condition warnings)
  final _healthAlertController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get healthAlertStream => _healthAlertController.stream;

  // 3b. Stream cho AI Diagnosis Results (hiển thị trên dashboard)
  final _aiDiagnosisController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get aiDiagnosisStream => _aiDiagnosisController.stream;

  // 3c. Stream cho Connection Status (online/offline dựa trên data activity)
  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  
  // Timer để track data activity
  Timer? _dataActivityTimer;
  DateTime? _lastDataReceivedAt;
  static const _dataTimeoutSeconds = 10; // Offline sau 10 giây không có dữ liệu

  // 4. Stream cho Incoming Call (OLD - giữ cho tương thích)
  final _incomingCallController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get incomingCallStream => _incomingCallController.stream;

  // 5. Stream cho WebRTC Video Call
  final _webrtcOfferController = StreamController<Map<String, dynamic>>.broadcast();
  final _webrtcAnswerController = StreamController<Map<String, dynamic>>.broadcast();
  final _webrtcIceCandidateController = StreamController<Map<String, dynamic>>.broadcast();
  final _callRejectedController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get webrtcOfferStream => _webrtcOfferController.stream;
  Stream<Map<String, dynamic>> get webrtcAnswerStream => _webrtcAnswerController.stream;
  Stream<Map<String, dynamic>> get webrtcIceCandidateStream => _webrtcIceCandidateController.stream;
  Stream<Map<String, dynamic>> get callRejectedStream => _callRejectedController.stream;

  // 6. Stream cho ZegoCloud Calls
  final _zegoCallInvitationController = StreamController<Map<String, dynamic>>.broadcast();
  final _zegoCallAcceptedController = StreamController<Map<String, dynamic>>.broadcast();
  final _zegoCallDeclinedController = StreamController<Map<String, dynamic>>.broadcast();
  final _zegoCallEndedController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get zegoCallInvitationStream => _zegoCallInvitationController.stream;
  Stream<Map<String, dynamic>> get zegoCallAcceptedStream => _zegoCallAcceptedController.stream;
  Stream<Map<String, dynamic>> get zegoCallDeclinedStream => _zegoCallDeclinedController.stream;
  Stream<Map<String, dynamic>> get zegoCallEndedStream => _zegoCallEndedController.stream;

  IO.Socket? get socket => _socket;
  bool get isConnected => _socket?.connected ?? false;
  
  // Cập nhật data activity và reset timer
  void _updateDataActivity() {
    _lastDataReceivedAt = DateTime.now();
    
    print('✅ [STATUS] Data activity updated - Timer reset');
    
    // Emit online status
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(true);
      print('   → Status: ONLINE (emitted to stream)');
    }
    
    // Cancel timer cũ và tạo timer mới
    _dataActivityTimer?.cancel();
    _dataActivityTimer = Timer(Duration(seconds: _dataTimeoutSeconds), () {
      print('\n⚠️ [STATUS] No data for $_dataTimeoutSeconds seconds - Setting status to OFFLINE');
      if (!_connectionStatusController.isClosed) {
        _connectionStatusController.add(false);
        print('   → Status: OFFLINE (emitted to stream)\n');
      }
    });
    print('   → Timer set: $_dataTimeoutSeconds seconds until offline\n');
  }

  // --- HÀM KẾT NỐI ---
  Future<void> connect() async {
    // 1. Kiểm tra nếu đang kết nối rồi thì thôi (hoặc có thể force reconnect nếu cần)
    if (_socket != null && _socket!.connected) {
      print("ℹ️ [SOCKET] Đã kết nối, không cần tạo lại.");
      return;
    }

    // 2. Lấy Token MỚI NHẤT
    String? token = await _apiClient.getToken();
    if (token == null) {
      print("❌ [SOCKET] Không tìm thấy token -> Hủy kết nối.");
      disconnect();
      return;
    }

    // [DEBUG] Log User ID từ token
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
        final userId = payload['id'] ?? payload['userId'] ?? 'Unknown';
        print("🔍 [SOCKET] Connecting for UserID: $userId");
      }
    } catch (e) {
      print("⚠️ [SOCKET] Lỗi decode token debug: $e");
    }

    // 3. Dọn dẹp kết nối cũ (nếu có rác)
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    final String serverUrl = _apiClient.baseUrl.replaceAll('/api', '');
    print("🔄 [SOCKET] Đang kết nối tới: $serverUrl");

    // 4. Khởi tạo Socket
    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew() // Tạo session mới hoàn toàn
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    // 5. Kết nối và Lắng nghe
    _socket!.connect();
    _setupListeners();
  }

  void _setupListeners() {
    _socket?.onConnect((_) {
      print('\n═══════════════════════════════════════════');
      print('✅ [SOCKET] Connected Successfully!');
      print('   Socket ID: ${_socket?.id}');
      print('   Server URL: ${_apiClient.baseUrl}');
      print('═══════════════════════════════════════════\n');
      
      // Không tự động emit online, chờ dữ liệu từ MQTT
      print('⏳ [STATUS] Waiting for MQTT data to go online...');
    });

    _socket?.onDisconnect((_) {
      print('\n🔌 [SOCKET] Disconnected from server');
      print('═══════════════════════════════════════════\n');
      
      // Cancel timer và emit offline
      _dataActivityTimer?.cancel();
      if (!_connectionStatusController.isClosed) {
        _connectionStatusController.add(false);
      }
    });

    _socket?.onConnectError((data) {
      print('\n❌ [SOCKET] Connection Error!');
      print('   Error: $data');
      print('═══════════════════════════════════════════\n');
    });

    _socket?.onError((data) {
      print('\n❌ [SOCKET] Socket Error!');
      print('   Error: $data');
      print('═══════════════════════════════════════════\n');
    });

    _socket?.onReconnect((_) {
      print('\n🔄 [SOCKET] Reconnected!');
      print('═══════════════════════════════════════════\n');
      
      print('⏳ [STATUS] Waiting for MQTT data to go online...');
    });

    // Lắng nghe MQTT data activity từ backend
    _socket?.on('mqtt_data_activity', (data) {
      print('\n📡 [MQTT] ═══ DATA ACTIVITY RECEIVED ═══');
      print('   Type: ${data['type']}');
      print('   User ID: ${data['user_id']}');
      print('   Timestamp: ${data['timestamp']}');
      print('   → Setting status to ONLINE');
      print('═══════════════════════════════════════════\n');
      _updateDataActivity();
    });
    
    // Lắng nghe tin nhắn chat
    _socket?.on('new_message', (data) {
      if (data != null && !_messageController.isClosed) {
        print('\n📩 [SOCKET] NEW MESSAGE RECEIVED:');
        print('   Conversation ID: ${data['conversationId'] ?? data['conversation_id']}');
        print('   Sender ID: ${data['senderId'] ?? data['sender_id']}');
        print('   Content: ${data['content']}');
        print('   Type: ${data['type']}');
        print('   Full Data: $data');
        print('═══════════════════════════════════════════\n');
        _messageController.add(Map<String, dynamic>.from(data));
      }
    });

    // Lắng nghe thông báo chung
    _socket?.on('notification', (data) {
      if (data != null && !_notificationController.isClosed) {
        print("🔔 [SOCKET] Notification: $data");
        _notificationController.add(Map<String, dynamic>.from(data));
      }
    });

    // Lắng nghe cảnh báo sức khỏe (Health Alert)
    _socket?.on('HEALTH_ALERT', (data) {
      if (data != null && !_healthAlertController.isClosed) {
        print("🚨 [SOCKET] Health Alert: $data");
        _healthAlertController.add(Map<String, dynamic>.from(data));
      }
    });

    // --- REAL-TIME HEALTH DATA FROM MQTT ---
    // Listen for medical data from backend MQTT service
    _socket?.on('medical_data_new', (data) {
      if (data != null) {
        print("💓 [SOCKET] Real-time Medical Data: HR=${data['heart_rate']}, SpO2=${data['spo2']}, Temp=${data['temperature']}°C");
        // Forward to MQTT service for dashboard
        final mqttService = MqttService();
        mqttService.handleSocketMedicalData(data);
      }
    });

    // Listen for ECG data from backend MQTT service
    _socket?.on('ecg_data_new', (data) {
      if (data != null) {
        print("📊 [SOCKET] Real-time ECG Data: Packet ${data['packet_id']}");
        // Forward to MQTT service for dashboard
        final mqttService = MqttService();
        mqttService.handleSocketECGData(data);
      }
    });

    // --- AI DIAGNOSIS ALERTS ---
    // Listen for AI medical diagnosis alerts (MLP Model)
    _socket?.on('ai_medical_alert', (data) {
      if (data != null) {
        final diagnosisData = Map<String, dynamic>.from(data);
        print("🤖 [SOCKET] AI Medical Alert: ${data['riskLabel']} (${data['confidence']}%)");
        
        // Emit to alert stream (for popup)
        if (!_healthAlertController.isClosed) {
          _healthAlertController.add(diagnosisData);
        }
        
        // Emit to diagnosis stream (for dashboard display)
        if (!_aiDiagnosisController.isClosed) {
          _aiDiagnosisController.add(diagnosisData);
        }
      }
    });

    // Listen for AI ECG diagnosis alerts (CNN Model)
    _socket?.on('ai_ecg_alert', (data) {
      if (data != null) {
        final diagnosisData = Map<String, dynamic>.from(data);
        print("🚨 [SOCKET] AI ECG Alert: ${data['result']} (${data['confidence']}%)");
        
        // Emit to alert stream (for popup)
        if (!_healthAlertController.isClosed) {
          _healthAlertController.add(diagnosisData);
        }
        
        // Emit to diagnosis stream (for dashboard display)
        if (!_aiDiagnosisController.isClosed) {
          _aiDiagnosisController.add(diagnosisData);
        }
      }
    });

    // Lắng nghe cuộc gọi video đến (OLD - giữ cho tương thích)
    _socket?.on('INCOMING_CALL', (data) {
      if (data != null && !_incomingCallController.isClosed) {
        print("📞 [SOCKET] Incoming Call: $data");
        _incomingCallController.add(Map<String, dynamic>.from(data));
      }
    });

    // Lắng nghe khi cuộc gọi bị từ chối (OLD - giữ cho tương thích)
    _socket?.on('CALL_REJECTED', (data) {
      if (data != null && !_notificationController.isClosed) {
        print("❌ [SOCKET] Call Rejected: $data");
        _notificationController.add(Map<String, dynamic>.from(data));
      }
    });

    // --- WebRTC SIGNALING EVENTS ---
    
    // Nhận offer từ caller
    _socket?.on('webrtc_offer', (data) {
      if (data != null && !_webrtcOfferController.isClosed) {
        print('\n📞 [SOCKET] ═══ WEBRTC OFFER RECEIVED ═══');
        print('   From User: ${data['from']}');
        print('   From Name: ${data['fromName']}');
        print('   From Avatar: ${data['fromAvatar']}');
        print('   Offer SDP Type: ${data['offer']?['type']}');
        print('   Offer SDP Length: ${data['offer']?['sdp']?.toString().length ?? 0} chars');
        print('═══════════════════════════════════════════\n');
        _webrtcOfferController.add(Map<String, dynamic>.from(data));
      }
    });

    // Nhận answer từ callee
    _socket?.on('webrtc_answer', (data) {
      if (data != null && !_webrtcAnswerController.isClosed) {
        print('\n✅ [SOCKET] ═══ WEBRTC ANSWER RECEIVED ═══');
        print('   From User: ${data['from']}');
        print('   Answer SDP Type: ${data['answer']?['type']}');
        print('   Answer SDP Length: ${data['answer']?['sdp']?.toString().length ?? 0} chars');
        print('═══════════════════════════════════════════\n');
        _webrtcAnswerController.add(Map<String, dynamic>.from(data));
      }
    });

    // Nhận ICE candidate
    _socket?.on('webrtc_ice_candidate', (data) {
      if (data != null && !_webrtcIceCandidateController.isClosed) {
        print('\n🧊 [SOCKET] ═══ ICE CANDIDATE RECEIVED ═══');
        print('   From User: ${data['from']}');
        print('   Candidate: ${data['candidate']?['candidate']?.toString().substring(0, 50) ?? 'N/A'}...');
        print('═══════════════════════════════════════════\n');
        _webrtcIceCandidateController.add(Map<String, dynamic>.from(data));
      }
    });

    // Cuộc gọi bị từ chối hoặc kết thúc
    _socket?.on('call_ended', (data) {
      if (data != null && !_callRejectedController.isClosed) {
        print('\n📴 [SOCKET] ═══ CALL ENDED ═══');
        print('   From User: ${data['from']}');
        print('   Reason: ${data['reason'] ?? 'Unknown'}');
        print('═══════════════════════════════════════════\n');
        _callRejectedController.add(Map<String, dynamic>.from(data));
      }
    });

    // --- ZEGOCLOUD SIGNALING EVENTS ---
    
    // Nhận call invitation (ZegoCloud)
    _socket?.on('zego_call_invitation', (data) {
      if (data != null && !_zegoCallInvitationController.isClosed) {
        print('\n📞 [SOCKET] ═══ ZEGO CALL INVITATION ═══');
        print('   Caller ID: ${data['callerId']}');
        print('   Caller Name: ${data['callerName']}');
        print('   Call ID: ${data['callId']}');
        print('   Type: ${data['isVideoCall'] ? 'Video' : 'Audio'}');
        print('═══════════════════════════════════════════\n');
        _zegoCallInvitationController.add(Map<String, dynamic>.from(data));
      }
    });

    // Call accepted
    _socket?.on('zego_call_accepted', (data) {
      if (data != null && !_zegoCallAcceptedController.isClosed) {
        print('\n✅ [SOCKET] ═══ ZEGO CALL ACCEPTED ═══');
        print('   Accepted By: ${data['acceptedBy']}');
        print('   Call ID: ${data['callId']}');
        print('═══════════════════════════════════════════\n');
        _zegoCallAcceptedController.add(Map<String, dynamic>.from(data));
      }
    });

    // Call declined
    _socket?.on('zego_call_declined', (data) {
      if (data != null && !_zegoCallDeclinedController.isClosed) {
        print('\n❌ [SOCKET] ═══ ZEGO CALL DECLINED ═══');
        print('   Declined By: ${data['declinedBy']}');
        print('   Call ID: ${data['callId']}');
        print('═══════════════════════════════════════════\n');
        _zegoCallDeclinedController.add(Map<String, dynamic>.from(data));
      }
    });

    // Call ended
    _socket?.on('zego_call_ended', (data) {
      if (data != null && !_zegoCallEndedController.isClosed) {
        print('\n📴 [SOCKET] ═══ ZEGO CALL ENDED ═══');
        print('   Ended By: ${data['endedBy']}');
        print('   Call ID: ${data['callId']}');
        print('═══════════════════════════════════════════\n');
        _zegoCallEndedController.add(Map<String, dynamic>.from(data));
      }
    });
  }

  // --- OLD METHODS (giữ cho tương thích) ---
  void startCall(String receiverId, String chatId, String callerName) {
    if (isConnected) {
      print("📞 [SOCKET] Starting call to User $receiverId");
      _socket?.emit('start_call', {
        'receiverId': receiverId,
        'chatId': chatId,
        'callerName': callerName,
      });
    } else {
      print("⚠️ [SOCKET] Chưa kết nối, không thể gọi!");
    }
  }

  void rejectCall(String callerId) {
    if (isConnected) {
      print("❌ [SOCKET] Rejecting call from User $callerId");
      _socket?.emit('reject_call', {'callerId': callerId});
    }
  }

  // --- WebRTC SIGNALING METHODS ---
  
  /// Gửi offer tới receiver
  void sendCallOffer({
    required String targetUserId,
    required Map<String, dynamic> offer,
    required String callerName,
    String? callerAvatar,
    String callType = 'video', // 'video' or 'audio'
  }) {
    if (isConnected) {
      print('\n📤 [SOCKET] ═══ SENDING WEBRTC OFFER ═══');
      print('   To User: $targetUserId');
      print('   Caller Name: $callerName');
      print('   Call Type: $callType');
      print('   Offer SDP Type: ${offer['type']}');
      print('   Offer SDP Length: ${offer['sdp']?.toString().length ?? 0} chars');
      print('   Socket ID: ${_socket?.id}');
      _socket?.emit('webrtc_offer', {
        'to': targetUserId,
        'offer': offer,
        'callerName': callerName,
        'callerAvatar': callerAvatar,
        'callType': callType,
      });
      print('   ✅ Offer sent to server');
      print('═══════════════════════════════════════════\n');
    } else {
      print('\n⚠️ [SOCKET] Cannot send offer - Socket not connected!');
      print('═══════════════════════════════════════════\n');
    }
  }

  /// Gửi answer tới caller
  void sendCallAnswer({
    required String targetUserId,
    required Map<String, dynamic> answer,
  }) {
    if (isConnected) {
      print('\n📤 [SOCKET] ═══ SENDING WEBRTC ANSWER ═══');
      print('   To User: $targetUserId');
      print('   Answer SDP Type: ${answer['type']}');
      print('   Answer SDP Length: ${answer['sdp']?.toString().length ?? 0} chars');
      _socket?.emit('webrtc_answer', {
        'to': targetUserId,
        'answer': answer,
      });
      print('   ✅ Answer sent to server');
      print('═══════════════════════════════════════════\n');
    } else {
      print('\n⚠️ [SOCKET] Cannot send answer - Socket not connected!');
      print('═══════════════════════════════════════════\n');
    }
  }

  /// Gửi ICE candidate
  void sendIceCandidate({
    required String targetUserId,
    required Map<String, dynamic> candidate,
  }) {
    if (isConnected) {
      print('\n📤 [SOCKET] ═══ SENDING ICE CANDIDATE ═══');
      print('   To User: $targetUserId');
      print('   Candidate: ${candidate['candidate']?.toString().substring(0, 50) ?? 'N/A'}...');
      _socket?.emit('webrtc_ice_candidate', {
        'to': targetUserId,
        'candidate': candidate,
      });
      print('   ✅ ICE candidate sent');
      print('═══════════════════════════════════════════\n');
    } else {
      print('\n⚠️ [SOCKET] Cannot send ICE candidate - Socket not connected!');
      print('═══════════════════════════════════════════\n');
    }
  }

  // --- ZEGOCLOUD SIGNALING METHODS ---
  
  /// Gửi call invitation (ZegoCloud)
  void sendCallInvitation({
    required String targetUserId,
    required String callId,
    required bool isVideoCall,
  }) {
    if (isConnected) {
      print('\n📤 [SOCKET] ═══ SENDING ZEGO CALL INVITATION ═══');
      print('   To User: $targetUserId');
      print('   Call ID: $callId');
      print('   Type: ${isVideoCall ? 'Video' : 'Audio'}');
      _socket?.emit('zego_call_invitation', {
        'to': targetUserId,
        'callId': callId,
        'isVideoCall': isVideoCall,
      });
      print('   ✅ Invitation sent');
      print('═══════════════════════════════════════════\n');
    } else {
      print('\n⚠️ [SOCKET] Cannot send invitation - Socket not connected!');
      print('═══════════════════════════════════════════\n');
    }
  }

  /// Gửi call accepted (ZegoCloud)
  void sendCallAccepted({
    required String targetUserId,
    required String callId,
  }) {
    if (isConnected) {
      print('\n📤 [SOCKET] ═══ SENDING CALL ACCEPTED ═══');
      print('   To User: $targetUserId');
      print('   Call ID: $callId');
      _socket?.emit('zego_call_accepted', {
        'to': targetUserId,
        'callId': callId,
      });
      print('   ✅ Accepted notification sent');
      print('═══════════════════════════════════════════\n');
    } else {
      print('\n⚠️ [SOCKET] Cannot send accepted - Socket not connected!');
      print('═══════════════════════════════════════════\n');
    }
  }

  /// Gửi call declined (ZegoCloud)
  void sendCallDeclined({
    required String targetUserId,
    required String callId,
  }) {
    if (isConnected) {
      print('\n📤 [SOCKET] ═══ SENDING CALL DECLINED ═══');
      print('   To User: $targetUserId');
      print('   Call ID: $callId');
      _socket?.emit('zego_call_declined', {
        'to': targetUserId,
        'callId': callId,
      });
      print('   ✅ Declined notification sent');
      print('═══════════════════════════════════════════\n');
    } else {
      print('\n⚠️ [SOCKET] Cannot send declined - Socket not connected!');
      print('═══════════════════════════════════════════\n');
    }
  }

  /// Gửi call ended (ZegoCloud)
  void sendCallEnded({
    required String targetUserId,
    required String callId,
    int duration = 0,
  }) {
    if (isConnected) {
      print('\n📤 [SOCKET] ═══ SENDING CALL ENDED ═══');
      print('   To User: $targetUserId');
      print('   Call ID: $callId');
      print('   Duration: ${duration}s');
      _socket?.emit('zego_call_ended', {
        'to': targetUserId,
        'callId': callId,
        'duration': duration,
      });
      print('   ✅ Call ended notification sent');
      print('═══════════════════════════════════════════\n');
    } else {
      print('\n⚠️ [SOCKET] Cannot send call ended - Socket not connected!');
      print('═══════════════════════════════════════════\n');
    }
  }

  /// Legacy method - giữ cho backward compatibility
  void sendCallEndedLegacy({
    required String targetUserId,
    required String reason, // 'ended', 'rejected', 'timeout', 'cancelled'
  }) {
    if (isConnected) {
      print('\n📤 [SOCKET] ═══ SENDING CALL ENDED (LEGACY) ═══');
      print('   To User: $targetUserId');
      print('   Reason: $reason');
      _socket?.emit('call_ended', {
        'to': targetUserId,
        'reason': reason,
      });
      print('   ✅ Call ended notification sent');
      print('═══════════════════════════════════════════\n');
    } else {
      print('\n⚠️ [SOCKET] Cannot send call ended - Socket not connected!');
      print('═══════════════════════════════════════════\n');
    }
  }

  /// Join conversation room
  void joinConversation(String conversationId) {
    if (isConnected) {
      print('\n🔗 [SOCKET] ═══ JOINING CONVERSATION ═══');
      print('   Conversation ID: $conversationId');
      print('   Socket ID: ${_socket?.id}');
      _socket?.emit('join_conversation', {'conversationId': conversationId});
      print('   ✅ Join request sent');
      print('═══════════════════════════════════════════\n');
    } else {
      print('\n⚠️ [SOCKET] Cannot join conversation - Socket not connected!');
      print('═══════════════════════════════════════════\n');
    }
  }

  /// Join conversation room với confirmation (Recommended)
  /// Trả về Future hoàn thành khi server confirm join thành công
  Future<bool> joinConversationWithConfirmation(String conversationId, {Duration timeout = const Duration(seconds: 5)}) async {
    if (!isConnected) {
      print('\n⚠️ [SOCKET] Cannot join conversation - Socket not connected!');
      return false;
    }

    try {
      print('\n🔗 [SOCKET] ═══ JOINING CONVERSATION (WITH ACK) ═══');
      print('   Conversation ID: $conversationId');
      print('   Socket ID: ${_socket?.id}');
      
      final completer = Completer<bool>();
      
      _socket?.emitWithAck('join_conversation', {'conversationId': conversationId}, 
        ack: (response) {
          print('\n📨 [SOCKET] Received join_conversation ACK');
          print('   Response: $response');
          
          if (response != null && response['success'] == true) {
            print('   ✅ Successfully joined room: ${response['room']}');
            print('═══════════════════════════════════════════\n');
            completer.complete(true);
          } else {
            print('   ❌ Failed to join room');
            print('═══════════════════════════════════════════\n');
            completer.complete(false);
          }
        }
      );
      
      // Đợi ACK với timeout
      return await completer.future.timeout(
        timeout,
        onTimeout: () {
          print('   ⏰ [SOCKET] Join confirmation timeout after ${timeout.inSeconds}s');
          print('   ⚠️  Assuming join was successful (fallback)');
          print('═══════════════════════════════════════════\n');
          return true; // Fallback: giả định thành công
        },
      );
      
    } catch (e) {
      print('   ❌ [SOCKET] Error joining conversation: $e');
      print('═══════════════════════════════════════════\n');
      return false;
    }
  }

  /// Leave conversation room
  void leaveConversation(String conversationId) {
    if (isConnected) {
      print('\n👋 [SOCKET] ═══ LEAVING CONVERSATION ═══');
      print('   Conversation ID: $conversationId');
      _socket?.emit('leave_conversation', {'conversationId': conversationId});
      print('   ✅ Leave request sent');
      print('═══════════════════════════════════════════\n');
    }
  }

  void sendMessage(String conversationId, String content, {String type = 'text'}) {
    if (isConnected) {
      print('\n📤 [SOCKET] ═══ SENDING MESSAGE ═══');
      print('   Conversation ID: $conversationId');
      print('   Content: $content');
      print('   Type: $type');
      print('   Socket ID: ${_socket?.id}');
      _socket?.emit('send_message', {
        'conversationId': conversationId,
        'content': content,
        'type': type,
      });
      print('   ✅ Message sent to server');
      print('═══════════════════════════════════════════\n');
    } else {
      print('\n⚠️ [SOCKET] Cannot send message - Socket not connected!');
      print('   Conversation ID: $conversationId');
      print('   Content: $content');
      print('═══════════════════════════════════════════\n');
    }
  }

  // --- NGẮT KẾT NỐI (LOGOUT) ---
  void disconnect() {
    if (_socket != null) {
      print("🛑 [SOCKET] Ngắt kết nối thủ công.");
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    
    // Cancel data activity timer
    _dataActivityTimer?.cancel();
    _dataActivityTimer = null;
    
    // LƯU Ý: Không close _messageController hay _notificationController ở đây
    // để có thể tái sử dụng khi user đăng nhập lại mà không cần khởi động lại app.
  }
}