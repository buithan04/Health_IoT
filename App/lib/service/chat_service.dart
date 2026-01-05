// lib/service/chat_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../core/api/api_client.dart';
import '../models/common/chat_model.dart'; // <--- IMPORT MODEL

class ChatService {
  final ApiClient _apiClient = ApiClient();

  // 1. Lấy danh sách chat (Trả về List<ChatConversation>)
  Future<List<ChatConversation>> getConversations() async {
    try {
      final response = await _apiClient.get('/chat/conversations');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChatConversation.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Exception getConversations: $e");
      return [];
    }
  }

  // 2. Lấy lịch sử tin nhắn (Trả về List<ChatMessage>)
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final response = await _apiClient.get('/chat/conversations/$conversationId/messages');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Exception getMessages: $e");
      return [];
    }
  }

  // 3. Bắt đầu chat (Giữ nguyên trả về String ID)
  Future<String?> startChat(String partnerId) async {
    try {
      final body = {'partnerId': partnerId};
      final response = await _apiClient.post('/chat/start', body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['conversationId'].toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 4. Upload File (Giữ nguyên logic nhưng thêm log rõ ràng)
  Future<Map<String, String>?> uploadChatFile(File file) async {
    try {
      final token = await _apiClient.getToken();
      var uri = Uri.parse('${_apiClient.baseUrl}/chat/upload');
      var request = http.MultipartRequest('POST', uri);

      if (token != null) request.headers['Authorization'] = 'Bearer $token';

      final mimeTypeData = lookupMimeType(file.path)?.split('/');
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: mimeTypeData != null ? MediaType(mimeTypeData[0], mimeTypeData[1]) : null,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return {
          "url": data['url'].toString(),
          "type": data['type'].toString()
        };
      }
    } catch (e) {
      print("Exception uploadChatFile: $e");
    }
    return null;
  }
  Future<void> markMessagesAsSeen(String conversationId) async {
    try {
      // API PUT/POST tới endpoint Backend của bạn
      await _apiClient.put('/chat/conversations/$conversationId/seen', {});
      print("✅ Đã gửi yêu cầu đánh dấu tin nhắn $conversationId là ĐÃ XEM");
    } catch (e) {
      print("❌ Lỗi khi đánh dấu tin nhắn là đã xem: $e");
    }
  }
}