import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_iot/service/chat_service.dart';
import 'package:health_iot/service/socket_service.dart';
import 'package:health_iot/models/common/chat_model.dart';
import 'package:health_iot/core/constants/app_config.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final SocketService _socketService = SocketService();

  StreamSubscription? _notifSubscription;

  List<ChatConversation> _chats = [];
  List<ChatConversation> _filteredChats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
    _listenToSocket();
    
    // [FIX] Setup listener cho message_status_update ngay từ đầu
    // Để nhận được status update từ server khi ở chat list
    _setupStatusListener();
  }
  
  void _setupStatusListener() {
    // Remove old listeners nếu có
    _socketService.socket?.off('message_status_update');
    _socketService.socket?.off('conversation_updated');
    
    // Setup listener cho message status updates
    _socketService.socket?.on('message_status_update', (data) {
      if (!mounted) return;
      
      print('🔄 [CHAT_LIST] STATUS UPDATE RECEIVED: $data');
      
      // Fetch lại conversations để cập nhật status và last message
      _fetchConversations();
    });
    
    // [MESSENGER LOGIC] Setup listener cho conversation updates (new message, etc)
    _socketService.socket?.on('conversation_updated', (data) {
      if (!mounted) return;
      
      print('🔄 [CHAT_LIST] CONVERSATION UPDATED: $data');
      
      final conversationId = data['conversationId']?.toString();
      final lastMessage = data['lastMessage'] ?? 'Tin nhắn mới';
      
      // [MESSENGER LOGIC] Update conversation cụ thể NGAY LậP TỨC, không cần fetch lại
      if (conversationId != null) {
        setState(() {
          final index = _chats.indexWhere((c) => c.id == conversationId);
          if (index != -1) {
            // Move conversation to top và update last message
            final chat = _chats.removeAt(index);
            final updatedChat = ChatConversation(
              id: chat.id,
              partnerId: chat.partnerId,
              partnerName: chat.partnerName,
              partnerAvatar: chat.partnerAvatar,
              lastMessage: lastMessage,
              lastMessageAt: DateTime.now()
            );
            _chats.insert(0, updatedChat);
            _filteredChats = List.from(_chats);
            print('✅ [CHAT_LIST] Updated conversation on top');
          } else {
            // Conversation chưa có trong list, fetch lại
            print('⚠️ [CHAT_LIST] Conversation not found, fetching...');
            _fetchConversations();
          }
        });
      }
    });
  }

  // --- 1. LOGIC SOCKET - ĐẢM BẢO KẾT NỐI ---
  void _listenToSocket() async {
    // Đảm bảo socket luôn kết nối khi vào chat list
    if (!_socketService.isConnected) {
      print("🔄 [CHAT_LIST] Reconnecting socket...");
      await _socketService.connect();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Listen for new messages
    _notifSubscription = _socketService.messageStream.listen((data) {
      if (!mounted) return;

      print("🔔 [CHAT_LIST] Nhận tin mới: $data");

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
      final index = _chats.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        final chat = _chats.removeAt(index);

        final updatedChat = ChatConversation(
            id: chat.id,
            partnerId: chat.partnerId,
            partnerName: chat.partnerName,
            partnerAvatar: chat.partnerAvatar,
            lastMessage: newContent,
            lastMessageAt: DateTime.now()
        );

        _chats.insert(0, updatedChat);
        _filteredChats = List.from(_chats);
      } else {
        _fetchConversations();
      }
    });
  }

  Future<void> _fetchConversations() async {
    try {
      final data = await _chatService.getConversations();
      if (mounted) {
        setState(() {
          _chats = data;
          _filteredChats = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
      setState(() => _filteredChats = _chats);
    } else {
      setState(() {
        _filteredChats = _chats.where((chat) {
          return chat.partnerName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Màu nền chuẩn
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110.0), // Tăng chiều cao để chứa độ cong 40
        child: _CustomAppBar(),
      ),
      body: Column(
        children: [
          _SearchBar(onChanged: _filterChats),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)))
                : _filteredChats.isEmpty
                ? const _EmptyState()
                : RefreshIndicator(
              onRefresh: _fetchConversations,
              color: const Color(0xFF06B6D4),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredChats.length,
                itemBuilder: (context, index) {
                  return _ChatListItem(
                    conversation: _filteredChats[index],
                    onTapItem: () async {
                      final chat = _filteredChats[index];
                      final encodedName = Uri.encodeComponent(chat.partnerName);
                      // Fallback avatar nếu rỗng - sử dụng empty string để chat detail biết dùng default
                      final avatarUrl = chat.partnerAvatar.isNotEmpty ? chat.partnerAvatar : '';
                      final encodedAvatar = Uri.encodeComponent(avatarUrl);

                      await context.push(
                          '/chat/details/${chat.id}?name=$encodedName&partnerId=${chat.partnerId}&avatar=$encodedAvatar'
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

// --- ITEM CHAT ĐÃ ĐƯỢC LÀM MỚI (BỎ CARD CÓ VIỀN, DÙNG SHADOW) ---
class _ChatListItem extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTapItem;

  const _ChatListItem({required this.conversation, required this.onTapItem});

  @override
  Widget build(BuildContext context) {
    final bool hasAvatar = conversation.partnerAvatar.isNotEmpty;
    
    print('\ud83d\udc65 [CHAT LIST] Building chat item:');
    print('   Partner: ${conversation.partnerName}');
    print('   Avatar: ${conversation.partnerAvatar}');
    print('   Has avatar: $hasAvatar');
    print('   Full URL: ${hasAvatar ? "${AppConfig.baseUrl}${conversation.partnerAvatar}" : "default"}');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Bo góc 16 chuẩn
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Shadow nhẹ
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTapItem,
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Padding rộng hơn chút
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade100, width: 1),
                      ),
                      child: ClipOval(
                        child: hasAvatar
                            ? Image.network(
                                '${AppConfig.baseUrl}${conversation.partnerAvatar}',
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  print('\u274c [CHAT LIST] Failed to load avatar: ${AppConfig.baseUrl}${conversation.partnerAvatar}');
                                  print('   Error: $error');
                                  return Image.asset(
                                    'assets/images/default_avatar.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/default_avatar.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    // Có thể thêm chấm xanh online ở đây nếu muốn
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                                conversation.partnerName,
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E293B)),
                                overflow: TextOverflow.ellipsis
                            ),
                          ),
                          Text(
                              conversation.timeDisplay,
                              style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        conversation.lastMessage,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
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

// --- APP BAR GRADIENT MỚI & BO GÓC 40 ---
class _CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2DD4BF), Color(0xFF06B6D4)], // Teal -> Cyan sáng
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)), // Bo góc lớn 40
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                  'Tin nhắn',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- SEARCH BAR ĐỒNG BỘ ---
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.inter(color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm cuộc hội thoại...',
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF2DD4BF)), // Icon Teal sáng
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF2DD4BF).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 60, color: Color(0xFF2DD4BF)),
          ),
          const SizedBox(height: 20),
          Text('Chưa có tin nhắn nào', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text('Hãy đặt lịch hẹn để bắt đầu trò chuyện\nvới bác sĩ.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)
          )
        ],
      ),
    );
  }
}