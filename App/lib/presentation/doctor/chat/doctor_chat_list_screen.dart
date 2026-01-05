import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_iot/presentation/widgets/custom_avatar.dart';
import 'package:health_iot/service/chat_service.dart';
import 'package:health_iot/service/socket_service.dart';
import 'package:health_iot/models/common/chat_model.dart';

class DoctorChatListScreen extends StatefulWidget {
  const DoctorChatListScreen({super.key});

  @override
  State<DoctorChatListScreen> createState() => _DoctorChatListScreenState();
}

class _DoctorChatListScreenState extends State<DoctorChatListScreen> {
  final ChatService _chatService = ChatService();
  final SocketService _socketService = SocketService();
  StreamSubscription? _notifSubscription;

  List<ChatConversation> _conversations = [];
  List<ChatConversation> _filteredConversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
    _listenToSocket();
    
    // [FIX] Setup listener cho message_status_update ngay từ đầu
    _setupStatusListener();
  }
  
  void _setupStatusListener() {
    // Remove old listeners nếu có
    _socketService.socket?.off('message_status_update');
    _socketService.socket?.off('conversation_updated');
    
    // Setup listener cho message status updates
    _socketService.socket?.on('message_status_update', (data) {
      if (!mounted) return;
      
      print('🔄 [DOCTOR_CHAT_LIST] STATUS UPDATE RECEIVED: $data');
      
      // Fetch lại conversations để cập nhật status và last message
      _fetchConversations();
    });
    
    // [MESSENGER LOGIC] Setup listener cho conversation updates (new message, etc)
    _socketService.socket?.on('conversation_updated', (data) {
      if (!mounted) return;
      
      print('🔄 [DOCTOR_CHAT_LIST] CONVERSATION UPDATED: $data');
      
      final conversationId = data['conversationId']?.toString();
      final lastMessage = data['lastMessage'] ?? 'Tin nhắn mới';
      
      // [MESSENGER LOGIC] Update conversation cụ thể NGAY LậP TỨC, không cần fetch lại
      if (conversationId != null) {
        setState(() {
          final index = _conversations.indexWhere((c) => c.id == conversationId);
          if (index != -1) {
            // Move conversation to top và update last message
            final chat = _conversations.removeAt(index);
            final updatedChat = ChatConversation(
              id: chat.id,
              partnerId: chat.partnerId,
              partnerName: chat.partnerName,
              partnerAvatar: chat.partnerAvatar,
              lastMessage: lastMessage,
              lastMessageAt: DateTime.now()
            );
            _conversations.insert(0, updatedChat);
            _filteredConversations = List.from(_conversations);
            print('✅ [DOCTOR_CHAT_LIST] Updated conversation on top');
          } else {
            // Conversation chưa có trong list, fetch lại
            print('⚠️ [DOCTOR_CHAT_LIST] Conversation not found, fetching...');
            _fetchConversations();
          }
        });
      }
    });
  }

  void _listenToSocket() async {
    // Đảm bảo socket luôn kết nối khi vào chat list
    if (!_socketService.isConnected) {
      print("🔄 [DOCTOR_CHAT_LIST] Reconnecting socket...");
      await _socketService.connect();
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    // Listen for new messages
    _notifSubscription = _socketService.messageStream.listen((data) {
      if (!mounted) return;
      print("🔔 [DOCTOR_CHAT_LIST] Nhận tin mới: $data");
      
      final conversationId = (data['conversationId'] ?? data['conversation_id'])?.toString();
      final content = data['content'] ?? 'Tin nhắn mới';
      final type = data['type'] ?? 'text';

      String displayMessage = type == 'image' ? '[Hình ảnh]' : content;

      if (conversationId != null) {
        // Fetch lại để có tin mới nhất từ server (realtime)
        _fetchConversations();
      }
    });
  }

  void _updateConversationOnTop(String conversationId, String newContent) {
    setState(() {
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        final chat = _conversations.removeAt(index);
        final updatedChat = ChatConversation(
            id: chat.id,
            partnerId: chat.partnerId,
            partnerName: chat.partnerName,
            partnerAvatar: chat.partnerAvatar,
            lastMessage: newContent,
            lastMessageAt: DateTime.now()
        );
        _conversations.insert(0, updatedChat);
        _filteredConversations = List.from(_conversations);
      } else {
        _fetchConversations();
      }
    });
  }

  Future<void> _fetchConversations() async {
    final data = await _chatService.getConversations();
    if (mounted) {
      setState(() {
        _conversations = data;
        _filteredConversations = data;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    // Clean up socket listeners
    _socketService.socket?.off('message_status_update');
    _socketService.socket?.off('conversation_updated');
    super.dispose();
  }

  void _filterChats(String query) {
    if (query.isEmpty) {
      setState(() => _filteredConversations = _conversations);
    } else {
      setState(() {
        _filteredConversations = _conversations
            .where((chat) => chat.partnerName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [UPDATE] Màu nền chuẩn 0xFFF0F4F8
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110.0),
        child: _CustomAppBar(),
      ),
      body: Column(
        children: [
          _SearchBar(onChanged: _filterChats),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)))
                : _filteredConversations.isEmpty
                ? const _EmptyState()
                : RefreshIndicator(
              onRefresh: _fetchConversations,
              color: const Color(0xFF06B6D4),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredConversations.length,
                itemBuilder: (context, index) {
                  return _ChatListItem(
                    chat: _filteredConversations[index],
                    onTap: () async {
                      final chat = _filteredConversations[index];
                      final encodedName = Uri.encodeComponent(chat.partnerName);
                      final encodedAvatar = Uri.encodeComponent(chat.partnerAvatar);

                      await context.push(
                          '/doctor/chat/details/${chat.id}?name=$encodedName&partnerId=${chat.partnerId}&avatar=$encodedAvatar'
                      );

                      _fetchConversations();
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: const BoxDecoration(
        // [UPDATE] Gradient chuẩn Teal -> Cyan, Radius 40
        gradient: LinearGradient(
          colors: [Color(0xFF2DD4BF), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton.filledTonal(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
              style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.15)),
            ),
            const SizedBox(width: 12),
            Text(
              'Tư vấn bệnh nhân',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Tìm tên bệnh nhân...',
            hintStyle: GoogleFonts.inter(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF2DD4BF)), // Icon Teal sáng
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final ChatConversation chat;
  final VoidCallback onTap;

  const _ChatListItem({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        leading: CustomAvatar(
          imageUrl: chat.partnerAvatar,
          radius: 28,
          fallbackText: chat.partnerName,
          backgroundColor: Colors.grey[100],
        ),
        title: Text(chat.partnerName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        subtitle: Text(
          chat.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(color: Colors.grey[600]),
        ),
        trailing: Text(
          chat.timeDisplay,
          style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Chưa có tin nhắn nào', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade600))
        ],
      ),
    );
  }
}