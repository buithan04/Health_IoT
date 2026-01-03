// lib/service/notification_service.dart
import 'dart:convert';
import '../core/api/api_client.dart';
import '../models/common/notification_model.dart'; // <--- IMPORT MODEL

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  // 1. Lấy danh sách (Trả về List Model)
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.get('/notifications');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("❌ Exception tải thông báo: $e");
      return [];
    }
  }

  // 2. Đánh dấu đã đọc
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiClient.put('/notifications/$notificationId/read', {});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 2.1 Đánh dấu TẤT CẢ đã đọc (Tối ưu)
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiClient.put('/notifications/read-all', {});
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Lỗi markAllAsRead: $e");
      return false;
    }
  }

  // 2.2 Lấy số lượng chưa đọc
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get('/notifications/unread-count');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['unread'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // 3. Xóa thông báo
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await _apiClient.delete('/notifications/$notificationId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}