// lib/models/chat_model.dart
import 'package:intl/intl.dart';
import '../../core/constants/app_config.dart';
// 1. Model cho Cuộc trò chuyện (Danh sách bên ngoài)
class ChatConversation {
  final String id;
  final String partnerId;
  final String partnerName;
  final String partnerAvatar;
  final String lastMessage;
  final DateTime? lastMessageAt;

  ChatConversation({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.partnerAvatar,
    required this.lastMessage,
    this.lastMessageAt,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    // SỬA: Key phải khớp với alias trong file chat_service.js của Backend
    // Backend trả về: "partnerAvatar", "partnerName", "lastMessage", "id"

    // [SỬA] Dùng AppConfig để format ảnh
    String rawAvatar = AppConfig.formatUrl(json['partnerAvatar']);

    return ChatConversation(
      id: json['id']?.toString() ?? '', // Backend trả về 'id'
      partnerId: json['partnerId']?.toString() ?? '', // Backend trả về 'partnerId'
      partnerName: json['partnerName'] ?? 'Người dùng', // Backend trả về 'partnerName'
      partnerAvatar: rawAvatar,
      lastMessage: json['lastMessage'] ?? 'Bắt đầu cuộc trò chuyện', // Backend trả về 'lastMessage'
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at']).toLocal()
          : null,
    );

  }

  // Helper hiển thị thời gian
  String get timeDisplay {
    if (lastMessageAt == null) return '';
    final now = DateTime.now();
    if (lastMessageAt!.year == now.year &&
        lastMessageAt!.month == now.month &&
        lastMessageAt!.day == now.day) {
      return DateFormat('HH:mm').format(lastMessageAt!);
    } else {
      return DateFormat('dd/MM').format(lastMessageAt!);
    }
  }
}

// 2. Model cho Tin nhắn (Chi tiết bên trong)
enum MessageType { text, image, file, unknown }
enum MessageStatus { sending, sent, delivered, seen, failed }

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId; // SỬA: Nên để String để nhất quán, nhưng nếu muốn giữ int thì phải parse kỹ
  final String content;
  final MessageType type;
  final DateTime createdAt;
  MessageStatus status;
  final String senderName;   // [THÊM]
  final String senderAvatar; // [THÊM]

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.senderName = '',   // [THÊM] Default rỗng
    this.senderAvatar = '', // [THÊM]
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {

    String rawStatus = json['status'] ?? 'sent';
    bool isReadDB = json['is_read'] == true;
    MessageStatus status = MessageStatus.sent;

    if (rawStatus == 'seen' || rawStatus == 'read' || isReadDB) {
      status = MessageStatus.seen;
    } else if (rawStatus == 'delivered') status = MessageStatus.delivered;

    String rawType = json['type'] ?? json['message_type'] ?? 'text';
    String content = json['content'] ?? '';
    MessageType msgType = MessageType.text;

    // Logic fallback giữ nguyên
    if (rawType == 'text' && content.startsWith('http')) {
      if (content.contains('cloudinary')) {
        if (content.endsWith('.pdf') || content.endsWith('.doc') || content.endsWith('.docx')) {
          msgType = MessageType.file;
        } else {
          msgType = MessageType.image;
        }
      }
    } else if (rawType == 'image') {
      msgType = MessageType.image;
    } else if (rawType == 'file' || rawType == 'raw') {
      msgType = MessageType.file;
    }


    return ChatMessage(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      // ÉP KIỂU MẠNH TAY VỀ STRING
      senderId: (json['senderId'] ?? json['sender_id'])?.toString() ?? '',
      content: content,
      type: msgType,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      status: status,
      senderName: json['senderName'] ?? '',     // [HỨNG DỮ LIỆU]
      senderAvatar: json['senderAvatar'] ?? '', // [HỨNG DỮ LIỆU]
    );
  }
}