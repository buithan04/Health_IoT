// lib/models/notification_model.dart
import 'package:intl/intl.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type; // 'APPOINTMENT_CONFIRMED', 'NEW_MESSAGE', ...
  final String relatedId;
  bool isRead; // Không final vì có thể thay đổi trạng thái trên UI
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.relatedId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? 'Thông báo mới',
      message: json['message'] ?? '',
      type: json['type'] ?? 'SYSTEM',
      relatedId: json['related_id']?.toString() ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
    );
  }

  // Helper hiển thị thời gian: "14:30 25/11"
  String get timeDisplay {
    return DateFormat('HH:mm dd/MM').format(createdAt);
  }
}