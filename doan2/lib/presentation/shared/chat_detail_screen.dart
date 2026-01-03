import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import 'package:app_iot/core/api/api_client.dart';
import 'package:app_iot/service/chat_service.dart';
import 'package:app_iot/service/socket_service.dart';
import 'package:app_iot/service/user_service.dart';
import 'package:app_iot/models/common/chat_model.dart';

// ZegoCloud imports (thay thế WebRTC)
import 'package:app_iot/service/zego_service.dart';
import 'package:app_iot/service/call_manager.dart';
import 'package:permission_handler/permission_handler.dart';

// Call screens
import 'package:app_iot/presentation/shared/widgets/incoming_call_screen.dart';
import 'package:app_iot/presentation/shared/widgets/connecting_call_screen.dart';
import 'package:app_iot/presentation/shared/widgets/camera_preview_screen.dart';

import 'package:app_iot/core/constants/app_config.dart';

import '../../main.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String? partnerName;
  final String? partnerId;
  final String? partnerAvatar;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    this.partnerName,
    this.partnerId,
    this.partnerAvatar,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  final ChatService _chatService = ChatService();
  final SocketService _socketService = SocketService();
  final ApiClient _apiClient = ApiClient();
  late final UserService _userService;

  String? _selectedMessageId;

  StreamSubscription? _msgSubscription;
  StreamSubscription? _callEndedSub;
  
  List<ChatMessage> _messages = [];
  String _myUserId = "";
  String _myAvatarUrl = "";
  String _myUserName = "";
  bool _isLoading = true;
  bool _isUploading = false;
  bool _isPartnerOnline = false;

  final Color _primaryColor = const Color(0xFF06B6D4);
  final Gradient _appBarGradient = const LinearGradient(
    colors: [Color(0xFF2DD4BF), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  String? _resolvedPartnerId;
  String? _resolvedPartnerName;
  String? _resolvedPartnerAvatar;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    
    _resolvedPartnerId = widget.partnerId;
    _resolvedPartnerName = widget.partnerName;
    _resolvedPartnerAvatar = widget.partnerAvatar;

    _userService = UserService(_apiClient);
    _initializeSafe();
    _setupCallerListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Khi user quay lại app (resume), re-mark messages as read
    if (state == AppLifecycleState.resumed && mounted) {
      print('📱 [CHAT] App resumed - re-marking messages as read');
      if (_resolvedPartnerId != null && _messages.isNotEmpty) {
        // Đợi một chút để socket reconnect (nếu cần)
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _markAsRead();
          }
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Đảm bảo mark_read khi screen xuất hiện (từ notification hoặc navigation)
    if (_resolvedPartnerId != null && _messages.isNotEmpty) {
      // Schedule mark_read sau khi build hoàn thành
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          print('🔄 [CHAT] Screen appeared - marking messages as read');
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _markAsRead();
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    _msgSubscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    
    // Clean up socket listeners
    _socketService.socket?.off('message_status_update');
    _socketService.socket?.off('online_status_result');
    _socketService.socket?.off('user_status_change');
    
    // Leave conversation khi dispose
    _socketService.leaveConversation(widget.chatId);
    
    super.dispose();
  }

  /// Setup ZegoCloud call listeners
  void _setupCallerListeners() {
    // 1. Khi người kia CHẤP NHẬN
    _socketService.zegoCallAcceptedStream.listen((data) {
      // Chỉ xử lý nếu mình đang ở trạng thái "Đang gọi" (Calling)
      if (ZegoService().currentState == CallState.calling) {
        final callId = data['callId']?.toString() ?? '';
        print('✅ [CHAT] Partner accepted call: $callId');

        CallManager().cancelCallTimeout();

        // Đóng màn hình "Connecting..." ngay lập tức
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        // Đợi 1 frame để đảm bảo pop xong, rồi push call page
        // Điều này đảm bảo navigation stack clean
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => ZegoService().buildCallPage(
                  context: context,
                  callId: callId,
                  localUserId: _myUserId,
                  localUserName: _myUserName,
                  remoteUserId: _resolvedPartnerId!,
                  remoteUserName: _resolvedPartnerName!,
                  isVideoCall: ZegoService().isVideoCall,
                  onCallEnd: () {
                    ZegoService().endCall();
                    CallManager().reset();
                  },
                ),
              ),
            );
          }
        });
      }
    });

    // 2. Khi người kia TỪ CHỐI
    _socketService.zegoCallDeclinedStream.listen((data) {
      if (ZegoService().currentState == CallState.calling) {
        print('❌ [CHAT] Partner declined');
        CallManager().cancelCallTimeout();

        // Đóng màn hình "Connecting..."
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Người dùng đang bận hoặc từ chối cuộc gọi')),
        );

        ZegoService().dispose(); // Reset state
      }
    });
  }

  /// Helper method để accept incoming call (COMMENTED OUT - using ZegoCloud)
  /*
  Future<void> _acceptIncomingCall(
    Map<String, dynamic> offer,
    String fromUserId,
    String fromName,
    String? fromAvatar,
    String callType,
  ) async {
    try {
      // Accept call
      await WebRTCService().acceptCall(
        offer: offer,
        callerUserId: fromUserId,
        callerUserName: fromName,
        callerUserAvatar: fromAvatar,
        callType: callType,
      );
      print('   ✅ [CLIENT] AcceptCall completed, navigating to call screen...');

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WebRTCCallScreen(
              remoteUserId: fromUserId,
              remoteUserName: fromName,
              remoteUserAvatar: fromAvatar,
              isOutgoingCall: false,
            ),
          ),
        );
      }
    } catch (e) {
      print('   ❌ [CLIENT] Error accepting call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: ${e.toString()}')),
        );
      }
    }
  }
  */

  Future<void> _initializeSafe() async {
    await _getMyUserId();

    // Initialize ZegoCloud with user credentials
    if (_myUserId.isNotEmpty) {
      try {
        await ZegoService().initialize(
          userId: _myUserId,
          userName: _myUserName,
        );
        print('✅ [ZEGO] Initialized for user: $_myUserName ($_myUserId)');
      } catch (e) {
        print('❌ [ZEGO] Initialization error: $e');
      }
    }

    await _initChat();
  }

  Future<void> _getMyUserId() async {
    try {
      final profile = await _userService.getUserProfile();

      if (profile != null) {
        if(mounted) {
          setState(() {
            _myUserId = profile.id.toString();
            _myUserName = profile.fullName ?? "Người dùng";
            _myAvatarUrl = profile.avatarUrl ?? "";
            if (_myAvatarUrl.isNotEmpty && !_myAvatarUrl.startsWith('http')) {
              _myAvatarUrl = "${AppConfig.baseUrl}$_myAvatarUrl";
            }
            else {
              _myAvatarUrl = "";
            }
          });
        }
      } else {
        // Fallback lấy ID từ token nếu profile lỗi
        final token = await _apiClient.getToken();
        if (token != null && token.isNotEmpty) {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = json.decode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
            final id = payload['id'] ?? payload['userId'] ?? payload['sub'];
            if (id != null) {
              setState(() => _myUserId = id.toString());
            }
          }
        }
      }
    } catch (e) {
      print("❌ Lỗi lấy User ID: $e");
    }
  }

  Future<void> _initChat() async {
    try {
      final history = await _chatService.getMessages(widget.chatId);
      if (mounted) {
        setState(() {
          _messages = history;
          _isLoading = false;

          if (_resolvedPartnerId == null &&
              _messages.isNotEmpty &&
              _myUserId.isNotEmpty) {
            try {
              final partnerMsg =
              _messages.firstWhere((m) => m.senderId != _myUserId);
              _resolvedPartnerId = partnerMsg.senderId;
              _resolvedPartnerName = partnerMsg.senderName.isNotEmpty
                  ? partnerMsg.senderName
                  : "Người dùng";
              _resolvedPartnerAvatar = partnerMsg.senderAvatar;
            } catch (_) {}
          }

          bool hasSeenNewer = false;
          for (var msg in _messages) {
            if (msg.senderId == _myUserId) {
              if (hasSeenNewer) {
                msg.status = MessageStatus.seen;
              } else if (msg.status == MessageStatus.seen) {
                hasSeenNewer = true;
              }
            }
          }

          // [FIX MESSENGER LOGIC]
          // Cascade status: Messages cũ hơn phải có status >= messages mới hơn
          // Tìm message mới nhất có status 'seen' từ mỗi sender
          final Map<String, DateTime> latestSeenBySender = {};
          
          for (var msg in _messages) {
            if (msg.status == MessageStatus.seen) {
              final currentLatest = latestSeenBySender[msg.senderId];
              if (currentLatest == null || msg.createdAt.isAfter(currentLatest)) {
                latestSeenBySender[msg.senderId] = msg.createdAt;
              }
            }
          }
          
          // Cascade: Tất cả messages cũ hơn message seen mới nhất phải là seen
          for (var msg in _messages) {
            final latestSeen = latestSeenBySender[msg.senderId];
            if (latestSeen != null && 
                (msg.createdAt.isBefore(latestSeen) || msg.createdAt.isAtSameMomentAs(latestSeen))) {
              msg.status = MessageStatus.seen;
            }
          }
        });

        // [FIX] Chỉ gọi HTTP API để mark seen
        if (_messages.isNotEmpty) {
          await ChatService().markMessagesAsSeen(widget.chatId);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }

    // Đảm bảo socket luôn kết nối khi vào chat
    if (!_socketService.isConnected) {
      print("🔄 [CHAT] Reconnecting socket...");
      await _socketService.connect();
      // Đợi một chút để socket kết nối xong
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    // [FIX] Join conversation room với confirmation
    print("🔗 [CHAT] Joining room with confirmation: ${widget.chatId}");
    final joinSuccess = await _socketService.joinConversationWithConfirmation(widget.chatId);
    
    if (joinSuccess) {
      print("✅ [CHAT] Successfully joined room: ${widget.chatId}");
      
      // Giờ an toàn gọi mark_read ngay sau khi join thành công
      if (_resolvedPartnerId != null && _messages.isNotEmpty) {
        _markAsRead();
      }
    } else {
      print("⚠️ [CHAT] Join room may have failed, using fallback...");
      // Fallback: Vẫn gọi mark_read sau delay như cũ
      await Future.delayed(const Duration(milliseconds: 300));
      if (_resolvedPartnerId != null && _messages.isNotEmpty) {
        _markAsRead();
      }
    }

    if (_resolvedPartnerId != null) {
      _socketService.socket?.emit('check_online', _resolvedPartnerId);
    }

    _socketService.socket?.on('online_status_result', (data) {
      if (!mounted) return;
      if (data['userId'].toString() == _resolvedPartnerId) {
        setState(() => _isPartnerOnline = data['isOnline']);
      }
    });

    _socketService.socket?.on('user_status_change', (data) {
      if (!mounted) return;
      if (data['userId'].toString() == _resolvedPartnerId) {
        setState(() => _isPartnerOnline = data['isOnline']);
      }
    });

    // Listen for new messages - ĐẢM BẢO LUÔN LUÔN LISTEN
    _msgSubscription = _socketService.messageStream.listen((data) {
      if (!mounted) return;
      print("📩 [CHAT] Received message data: $data");
      
      final incomingChatId =
      (data['conversationId'] ?? data['conversation_id']).toString();
      
      print("📍 [CHAT] Message for room: $incomingChatId, current room: ${widget.chatId}");
      
      if (incomingChatId == widget.chatId) {
        try {
          final newMessage = ChatMessage.fromJson(data);
          print("✅ [CHAT] Processing new message: ${newMessage.content}");
          _handleIncomingMessage(newMessage);
        } catch (e) {
          print("❌ [CHAT] Error parsing message: $e");
        }
      }
    });

    // [FIX] Clean up old listener trước khi setup mới để tránh duplicate
    _socketService.socket?.off('message_status_update');
    
    // Listen for message status updates (sent, delivered, seen)
    _socketService.socket?.on('message_status_update', (data) {
      if (!mounted) return;
      
      print('\n🔄 [CHAT] ═══ MESSAGE STATUS UPDATE ═══');
      print('   Data: $data');
      
      final messageId = data['messageId']?.toString();
      final newStatus = data['status']?.toString();
      final conversationId = data['conversationId']?.toString();
      final updatedBy = data['updatedBy']?.toString() ?? data['readerId']?.toString();

      print('   Message ID: $messageId');
      print('   New Status: $newStatus');
      print('   Conversation: $conversationId');
      print('   Updated By: $updatedBy');

      // Chỉ update nếu đúng conversation
      if (conversationId != widget.chatId || messageId == null || newStatus == null) {
        print('   ⚠️  Skipped - Not for this conversation or missing data');
        print('═══════════════════════════════════════════\n');
        return;
      }

      // Map status string to enum
      MessageStatus? status;
      switch (newStatus) {
        case 'sent':
          status = MessageStatus.sent;
          break;
        case 'delivered':
          status = MessageStatus.delivered;
          break;
        case 'seen':
        case 'read':
          status = MessageStatus.seen;
          break;
      }

      if (status != null) {
        setState(() {
          final msgIndex = _messages.indexWhere((m) => m.id == messageId);
          if (msgIndex != -1) {
            final oldStatus = _messages[msgIndex].status;
            final targetMessage = _messages[msgIndex];
            
            // [MESSENGER LOGIC] Cascade status updates
            // - Delivered: Tất cả messages cũ hơn từ cùng sender phải >= delivered
            // - Seen: Tất cả messages cũ hơn từ cùng sender phải là seen
            
            if (status == MessageStatus.seen) {
              print('   🔄 CASCADE SEEN: Marking all older messages as seen');
              final targetTime = targetMessage.createdAt;
              final senderId = targetMessage.senderId;
              
              int cascadeCount = 0;
              for (var msg in _messages) {
                // Cascade cho messages từ cùng sender và cũ hơn hoặc bằng target message
                if (msg.senderId == senderId && 
                    (msg.createdAt.isBefore(targetTime) || 
                     msg.createdAt.isAtSameMomentAs(targetTime))) {
                  if (msg.status != MessageStatus.seen) {
                    msg.status = MessageStatus.seen;
                    cascadeCount++;
                  }
                }
              }
              print('   ✅ Cascaded $cascadeCount messages to seen');
              
            } else if (status == MessageStatus.delivered) {
              print('   🔄 CASCADE DELIVERED: Marking all older messages as delivered');
              final targetTime = targetMessage.createdAt;
              final senderId = targetMessage.senderId;
              
              int cascadeCount = 0;
              for (var msg in _messages) {
                // Cascade delivered cho messages từ cùng sender, cũ hơn, và có status < delivered
                if (msg.senderId == senderId && 
                    (msg.createdAt.isBefore(targetTime) || 
                     msg.createdAt.isAtSameMomentAs(targetTime)) &&
                    (msg.status == MessageStatus.sending || msg.status == MessageStatus.sent)) {
                  msg.status = MessageStatus.delivered;
                  cascadeCount++;
                }
              }
              print('   ✅ Cascaded $cascadeCount messages to delivered');
              
            } else {
              // Chỉ update message cụ thể cho sent
              targetMessage.status = status!;
            }
            
            print('   ✅ Updated message "${targetMessage.content.substring(0, 20 < targetMessage.content.length ? 20 : targetMessage.content.length)}..."');
            print('   ✅ Status changed: $oldStatus → $status');
          } else {
            print('   ⚠️  Message not found in list');
          }
        });
      }
      print('═══════════════════════════════════════════\n');
    });
  }

  void _markAsRead() {
    if (_resolvedPartnerId != null) {
      print('\n👁️  [CHAT] ═══ MARKING MESSAGES AS READ ═══');
      print('   Conversation: ${widget.chatId}');
      print('   Partner: $_resolvedPartnerId');
      
      // [FIX] Optimistic UI update - instant feedback
      setState(() {
        int updatedCount = 0;
        for (var msg in _messages) {
          if (msg.senderId != _myUserId && msg.status != MessageStatus.seen) {
            msg.status = MessageStatus.seen;
            updatedCount++;
          }
        }
        if (updatedCount > 0) {
          print('   📱 [OPTIMISTIC] Updated $updatedCount messages to seen in UI');
        }
      });
      
      // Emit event để server xác nhận và sync
      _socketService.socket?.emit('mark_read', {
        'conversationId': widget.chatId,
        'partnerId': _resolvedPartnerId
      });
      print('   ✅ mark_read event emitted to server');
      print('═══════════════════════════════════════════\n');
    } else {
      print('⚠️  [CHAT] Cannot mark as read - partner ID not resolved');
    }
  }

  void _handleIncomingMessage(ChatMessage newMessage) {
    setState(() {
      // Check if message already exists (update)
      int existingIndex = _messages.indexWhere((m) => m.id == newMessage.id);
      if (existingIndex != -1) {
        _messages[existingIndex] = newMessage;
        return;
      }

      // Replace temp message với real message (khi nhận echo từ server)
      int tempIndex = -1;
      if (newMessage.senderId == _myUserId) {
        tempIndex = _messages.indexWhere((m) =>
        m.senderId == _myUserId &&
            m.content == newMessage.content &&
            m.id.toString().startsWith('temp_'));
      }

      if (tempIndex != -1) {
        // Replace temp message, set status = sent
        newMessage.status = MessageStatus.sent;
        _messages[tempIndex] = newMessage;
      } else {
        // New message từ partner
        _messages.insert(0, newMessage);
      }

      // Mark as read nếu là tin nhắn từ partner
      if (newMessage.senderId != _myUserId) {
        print('📬 [CHAT] Received message from partner - marking as read');
        _markAsRead();
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = ChatMessage(
      id: tempId,
      conversationId: widget.chatId,
      senderId: _myUserId,
      content: text,
      type: MessageType.text,
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
    );

    setState(() => _messages.insert(0, tempMsg));
    _socketService.sendMessage(widget.chatId, text, type: 'text');

    // Fallback: Nếu sau 3 giây không nhận được echo từ server, set thành sent
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          final msgIndex = _messages.indexWhere((m) => m.id == tempId);
          if (msgIndex != -1 && _messages[msgIndex].status == MessageStatus.sending) {
            _messages[msgIndex].status = MessageStatus.sent;
          }
        });
      }
    });
  }

  Future<void> _uploadAndSend(File file, String msgType) async {
    setState(() => _isUploading = true);
    final result = await _chatService.uploadChatFile(file);
    setState(() => _isUploading = false);

    if (result != null) {
      final String url = result['url'] ?? '';
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

      final tempMessage = ChatMessage(
        id: tempId,
        conversationId: widget.chatId,
        senderId: _myUserId,
        content: url,
        type: msgType == 'image' ? MessageType.image : MessageType.file,
        createdAt: DateTime.now(),
        status: MessageStatus.sending,
      );

      setState(() => _messages.insert(0, tempMessage));
      _socketService.sendMessage(widget.chatId, url, type: msgType);

      // Fallback: Nếu sau 3 giây không nhận được echo, set thành sent
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            final msgIndex = _messages.indexWhere((m) => m.id == tempId);
            if (msgIndex != -1 && _messages[msgIndex].status == MessageStatus.sending) {
              _messages[msgIndex].status = MessageStatus.sent;
            }
          });
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Upload thất bại!")));
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image =
      await _picker.pickImage(source: source, imageQuality: 70);
      if (image != null) await _uploadAndSend(File(image.path), 'image');
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        await _uploadAndSend(File(result.files.single.path!), 'file');
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thư viện ảnh'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Tài liệu'),
              onTap: () {
                Navigator.pop(ctx);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Bắt đầu audio call với ZegoCloud
  void _startAudioCall(BuildContext context) async {
    if (_resolvedPartnerId == null || _resolvedPartnerName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Không thể xác định người nhận')),
      );
      return;
    }

    // ═══ GIAI ĐOẠN 1: PRE-CALL CHECKS ═══
    print('\n🎬 [AUDIO CALL] Starting pre-call checks...\n');
    
    final checkResult = await CallManager().performPreCallChecks(
      isVideoCall: false, // Audio call chỉ cần mic
    );
    
    if (!checkResult.canProceed) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(checkResult.message ?? 'Không thể thực hiện cuộc gọi'),
            duration: const Duration(seconds: 3),
            action: checkResult.shouldOpenSettings
                ? SnackBarAction(
                    label: 'Cài đặt',
                    onPressed: () => openAppSettings(),
                  )
                : null,
          ),
        );
      }
      return;
    }
    
    // Hiển thị cảnh báo mạng nếu có
    if (checkResult.networkWarning != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(checkResult.networkWarning!),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // ═══ GIAI ĐOẠN 2: SIGNALING ═══
    // Bắt đầu gọi ngay lập tức như Messenger (không cần xác nhận)
    if (context.mounted) {
      try {
        print('🎙️ [ZEGO] Starting audio call to: $_resolvedPartnerName ($_resolvedPartnerId)');
        
        bool success = await ZegoService().startCall(
          targetUserId: _resolvedPartnerId!,
          targetUserName: _resolvedPartnerName!,
          isVideoCall: false,
        );

        if (success && context.mounted) {
          final callId = ZegoService().currentCallId!;
          
          // Bắt đầu timeout timer
          CallManager().startCallTimeout(
            callId: callId,
            onTimeout: () {
              print('⏰ [AUDIO CALL] Timeout - No answer');
              
              // Đóng connecting screen
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📵 Người dùng không trả lời')),
                );
              }
              
              // End call
              ZegoService().endCall();
            },
          );
          
          // MESSENGER STYLE: Hiện connecting screen ngay, đợi accept
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => ConnectingCallScreen(
                remoteUserName: _resolvedPartnerName!,
                remoteUserAvatar: _resolvedPartnerAvatar,
                isVideoCall: false,
                onCancel: () {
                  print('📴 [CALL] User cancelled audio call');
                  CallManager().cancelCallTimeout();
                  ZegoService().endCall();
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        } else if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Không thể khởi tạo cuộc gọi')),
          );
        }
      } catch (e) {
        print('❌ [ZEGO] Error starting audio call: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Lỗi: ${e.toString()}')),
          );
        }
      }
    }
  }

  /// Bắt đầu video call với ZegoCloud
  void _startVideoCall(BuildContext context) async {
    if (_resolvedPartnerId == null) return;

    // 1. Check permission & network (giữ nguyên code cũ của bạn)
    final checkResult = await CallManager().performPreCallChecks(isVideoCall: true);
    if (!checkResult.canProceed) return;

    // 2. Gửi yêu cầu gọi qua Socket ngay lập tức (không cần xác nhận)
    if (mounted) {
      try {
        print('📹 [ZEGO] Starting video call to: $_resolvedPartnerName ($_resolvedPartnerId)');
        
        bool success = await ZegoService().startCall(
          targetUserId: _resolvedPartnerId!,
          targetUserName: _resolvedPartnerName!,
          isVideoCall: true,
        );

        if (success && mounted) {
          final callId = ZegoService().currentCallId!;
          
          // 3. Bắt đầu timeout timer
          CallManager().startCallTimeout(
            callId: callId,
            onTimeout: () {
              print('⏰ [VIDEO CALL] Timeout - No answer');
              if (mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📵 Người dùng không trả lời')),
                );
              }
              ZegoService().endCall();
            },
          );

          // 4. Hiện màn hình "Đang kết nối..." ngay
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => ConnectingCallScreen(
                remoteUserName: _resolvedPartnerName!,
                remoteUserAvatar: _resolvedPartnerAvatar,
                isVideoCall: true,
                onCancel: () {
                  print('📴 [CALL] User cancelled video call');
                  CallManager().cancelCallTimeout();
                  ZegoService().endCall();
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        } else if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Không thể khởi tạo cuộc gọi')),
          );
        }
      } catch (e) {
        print('❌ [ZEGO] Error starting video call: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Lỗi: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _MessengerAppBar(
          partnerName: _resolvedPartnerName,
          partnerAvatar: _resolvedPartnerAvatar,
          partnerId: _resolvedPartnerId,
          isOnline: _isPartnerOnline,
          onBack: () => context.pop(),
          gradient: _appBarGradient,
          currentUserAvatar: _myAvatarUrl,
          currentUserName: _myUserName,
          currentUserId: _myUserId,
          onAudioCall: () => _startAudioCall(context),
          onVideoCall: () => _startVideoCall(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: _primaryColor))
                : _messages.isEmpty
                ? Center(
                child: Text("Bắt đầu trò chuyện 👋",
                    style: GoogleFonts.inter(color: Colors.grey)))
                : GestureDetector(
              onTap: () => setState(() => _selectedMessageId = null),
              child: ListView.builder(
                reverse: true,
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                itemCount: _messages.length,
                physics: const BouncingScrollPhysics(), // Smooth scrolling
                cacheExtent: 1000, // Cache more items for better performance
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg.senderId.toString() == _myUserId;

                  bool isLastInGroup = index == 0 ||
                      (_messages.length > index - 1 &&
                          _messages[index - 1].senderId !=
                              msg.senderId);
                  bool isFirstInGroup = index == _messages.length - 1 ||
                      (_messages.length > index + 1 &&
                          _messages[index + 1].senderId !=
                              msg.senderId);
                  bool showGroupGap =
                      isFirstInGroup && index != _messages.length - 1;

                  // Messenger-style: Chỉ hiện status ở tin nhắn CUỐI CÙNG của mỗi GROUP
                  // (không phải tin mới nhất trong toàn bộ list)
                  bool showStatus = isMe && isLastInGroup;

                  bool isSelected = _selectedMessageId == msg.id;

                  return Column(
                    children: [
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0),
                          child: Center(
                            child: Text(
                              DateFormat('EEE, dd/MM HH:mm')
                                  .format(msg.createdAt),
                              style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      if (showGroupGap) const SizedBox(height: 12),
                      _ChatBubble(
                        message: msg,
                        isMe: isMe,
                        isLastInGroup: isLastInGroup,
                        isFirstInGroup: isFirstInGroup,
                        partnerAvatar: (msg.senderAvatar.isNotEmpty)
                            ? msg.senderAvatar
                            : _resolvedPartnerAvatar,
                        primaryColor: _primaryColor,
                        showStatus: showStatus,
                        isSelected: isSelected,
                        onTapBubble: () {
                          setState(() {
                            if (_selectedMessageId == msg.id) {
                              _selectedMessageId = null;
                            } else {
                              _selectedMessageId = msg.id;
                            }
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (_isUploading) const LinearProgressIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_circle, color: _primaryColor, size: 28),
              onPressed: _showAttachmentMenu,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Nhắn tin...',
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: _primaryColor),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// --- CLASS APPBAR (ĐÃ FIX TYPE MISMATCH) ---
class _MessengerAppBar extends StatelessWidget {
  final String? partnerName;
  final String? partnerAvatar;
  final String? partnerId;
  final bool isOnline;
  final VoidCallback onBack;
  final Gradient gradient;
  final String? currentUserAvatar;
  final String? currentUserName;
  final String? currentUserId;
  final VoidCallback onAudioCall;
  final VoidCallback onVideoCall;

  const _MessengerAppBar({
    required this.partnerName,
    required this.partnerAvatar,
    required this.partnerId,
    required this.isOnline,
    required this.onBack,
    required this.gradient,
    required this.currentUserAvatar,
    required this.currentUserName,
    required this.currentUserId,
    required this.onAudioCall,
    required this.onVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = partnerName ?? 'Đang tải...';
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top, bottom: 8),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack),
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                partnerAvatar != null && partnerAvatar!.isNotEmpty
                    ? NetworkImage(partnerAvatar!)
                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                onBackgroundImageError: (partnerAvatar != null && partnerAvatar!.isNotEmpty)
                    ? (exception, stackTrace) {
                        print('⚠️ Failed to load avatar: $exception');
                      }
                    : null,
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(displayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(isOnline ? 'Đang hoạt động' : 'Offline',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),

          // --- [ZEGO] AUDIO CALL BUTTON - Messenger style ---
          if (partnerId != null && partnerId!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.phone, color: Colors.white, size: 22),
                onPressed: onAudioCall,
                tooltip: 'Gọi thoại',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
            ),

          // --- [ZEGO] VIDEO CALL BUTTON - Messenger style ---
          if (partnerId != null && partnerId!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.videocam, color: Colors.white, size: 24),
                onPressed: onVideoCall,
                tooltip: 'Gọi video',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- CLASS CHAT BUBBLE (KHÔI PHỤC CODE CŨ CỦA BẠN) ---
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool isLastInGroup;
  final bool isFirstInGroup;
  final String? partnerAvatar;
  final Color primaryColor;

  final bool showStatus;
  final bool isSelected;
  final VoidCallback onTapBubble;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.isLastInGroup,
    required this.isFirstInGroup,
    required this.primaryColor,
    required this.showStatus,
    required this.isSelected,
    required this.onTapBubble,
    this.partnerAvatar,
  });

  @override
  Widget build(BuildContext context) {
    const double rLarge = 18.0;
    const double rSmall = 4.0;

    BorderRadius borderRadius;
    if (isMe) {
      borderRadius = BorderRadius.only(
        topLeft: const Radius.circular(rLarge),
        bottomLeft: const Radius.circular(rLarge),
        topRight: Radius.circular(isFirstInGroup ? rLarge : rSmall),
        bottomRight: Radius.circular(isLastInGroup ? rLarge : rSmall),
      );
    } else {
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(isFirstInGroup ? rLarge : rSmall),
        bottomLeft: Radius.circular(isLastInGroup ? rLarge : rSmall),
        topRight: const Radius.circular(rLarge),
        bottomRight: const Radius.circular(rLarge),
      );
    }

    return GestureDetector(
      onTap: onTapBubble,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.5),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMe)
                  SizedBox(
                    width: 32,
                    child: isLastInGroup
                        ? Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: partnerAvatar != null &&
                            partnerAvatar!.isNotEmpty
                            ? NetworkImage(partnerAvatar!)
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                        onBackgroundImageError: (partnerAvatar != null && partnerAvatar!.isNotEmpty)
                            ? (exception, stackTrace) {
                                print('⚠️ Failed to load message avatar: $exception');
                              }
                            : null,
                      ),
                    )
                        : const SizedBox(),
                  ),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: message.type == MessageType.image
                        ? EdgeInsets.zero
                        : const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: message.type == MessageType.image
                          ? Colors.transparent
                          : (isMe ? primaryColor : const Color(0xFFE4E6EB)),
                      borderRadius: message.type == MessageType.image
                          ? BorderRadius.circular(16)
                          : borderRadius,
                    ),
                    child: _buildContent(isMe),
                  ),
                ),
              ],
            ),
            // Messenger-style Status: Chỉ icon, không text
            // Hiển thị khi: showStatus (tin cuối group) HOẶC isSelected (khi tap)
            if (isMe && (showStatus || isSelected))
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Timestamp chỉ hiện khi tap vào tin cũ
                    if (isSelected && !showStatus)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          DateFormat('HH:mm').format(message.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    _buildStatusIndicator(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isMe) {
    if (message.type == MessageType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          message.content,
          width: 200,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
              width: 200,
              height: 150,
              color: Colors.grey[300],
              child: const Icon(Icons.error)),
        ),
      );
    }
    return Text(
      message.content,
      style: GoogleFonts.inter(
        fontSize: 15,
        height: 1.3,
        color: isMe ? Colors.white : Colors.black87,
      ),
    );
  }

  /// Messenger-style Status: Icon + Text (như Messenger thật)
  /// - Sending: Loading + "Đang gửi"
  /// - Sent: ✓ + "Đã gửi"
  /// - Delivered: ✓✓ + "Đã nhận"
  /// - Seen: Avatar + "Đã xem"
  Widget _buildStatusIndicator() {
    Widget icon;
    String text = '';
    Color iconColor = Colors.grey[500]!;
    Color textColor = Colors.grey[600]!;

    switch (message.status) {
      case MessageStatus.sending:
        // Đang gửi - loading spinner
        icon = SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        );
        text = 'Đang gửi';
        break;

      case MessageStatus.sent:
        // Đã gửi - 1 checkmark xám
        icon = Icon(Icons.check, size: 14, color: iconColor);
        text = 'Đã gửi';
        break;

      case MessageStatus.delivered:
        // Đã nhận - 2 checkmarks xám
        icon = SizedBox(
          width: 16,
          height: 14,
          child: Stack(
            children: [
              Icon(Icons.check, size: 14, color: iconColor),
              Positioned(
                left: 3,
                child: Icon(Icons.check, size: 14, color: iconColor),
              ),
            ],
          ),
        );
        text = 'Đã nhận';
        break;

      case MessageStatus.seen:
        // Đã xem - Avatar nhỏ hoặc checkmark xanh
        if (partnerAvatar != null && partnerAvatar!.isNotEmpty) {
          icon = Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: Image.network(
                partnerAvatar!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/default_avatar.png',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          );
        } else {
          icon = SizedBox(
            width: 16,
            height: 14,
            child: Stack(
              children: [
                const Icon(Icons.check, size: 14, color: Colors.blue),
                Positioned(
                  left: 3,
                  child: const Icon(Icons.check, size: 14, color: Colors.blue),
                ),
              ],
            ),
          );
        }
        text = 'Đã xem';
        iconColor = Colors.blue;
        textColor = Colors.blue;
        break;

      case MessageStatus.failed:
        // Thất bại - warning icon đỏ
        icon = const Icon(Icons.error_outline, size: 14, color: Colors.red);
        text = 'Gửi thất bại';
        textColor = Colors.red;
        break;

      default:
        return const SizedBox.shrink();
    }

    // Icon + Text (Messenger style)
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        icon,
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: textColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}