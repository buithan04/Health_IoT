import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/api/api_client.dart';
import '../models/common/user_model.dart';
import '../models/common/review_model.dart';
import '../core/utils/io.dart' as io;

class UserService {
  final ApiClient _apiClient;
  UserService(this._apiClient);

  // 1. [GỘP] Lấy thông tin User / Dashboard Info
  Future<User?> getUserProfile() async {
    try {
      final response = await _apiClient.get('/user/dashboard-info');

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn');
      }
    } catch (e) {
      print("Lỗi getUserProfile: $e");
    }
    return null;
  }

  // 2. Upload Avatar
  Future<String> uploadAvatar(io.File imageFile) async {
    if (kIsWeb) {
      throw Exception('Upload avatar chưa hỗ trợ trên web');
    }
    try {
      final token = await _apiClient.getToken();
      var uri = Uri.parse('${_apiClient.baseUrl}/user/upload-avatar');
      var request = http.MultipartRequest('POST', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      print("📤 Đang upload avatar...");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['avatarUrl'];
      } else {
        throw Exception('Lỗi upload: ${response.body}');
      }
    } catch (e) {
      print("❌ Lỗi Upload Service: $e");
      throw Exception('Không thể upload ảnh');
    }
  }

  // 3. Cập nhật thông tin cá nhân
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/user/profile', data);
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi update profile: $e");
      return false;
    }
  }

  // 4. Lấy danh sách đánh giá của tôi
  Future<List<Review>> getMyReviews() async {
    try {
      final response = await _apiClient.get('/user/my-reviews');
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((json) => Review.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Lỗi lấy reviews: $e");
      return [];
    }
  }

  // 5. Cập nhật FCM Token
  Future<void> updateUserFcmToken(String token) async {
    try {
      await _apiClient.put('/user/fcm-token', {'fcmToken': token});
    } catch (e) {
      print("Lỗi update FCM token: $e");
    }
  }
}