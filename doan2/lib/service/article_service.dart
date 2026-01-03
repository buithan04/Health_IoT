// lib/service/article_service.dart
import 'dart:convert';
import '../core/api/api_client.dart';
import '../models/patient/article_model.dart'; // <--- IMPORT MODEL

class ArticleService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Article>> getArticles({String category = 'Tất cả', String search = ''}) async {
    try {
      final queryParameters = <String, String>{};

      if (category != 'Tất cả') {
        queryParameters['category'] = category;
      }

      if (search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      // Tạo Query String
      String queryString = Uri(queryParameters: queryParameters).query;
      String endpoint = '/articles';
      if (queryString.isNotEmpty) {
        endpoint += '?$queryString';
      }

      final response = await _apiClient.get(endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Chuyển đổi JSON sang List<Article>
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Lỗi lấy bài viết: $e');
      return [];
    }
  }
}