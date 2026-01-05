// lib/models/article_model.dart
import '../../core/constants/app_config.dart';
class Article {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final String sourceName;
  final String contentUrl; // Link webview
  final DateTime? publishedAt;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.sourceName,
    required this.contentUrl,
    this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    // [SỬA] Dùng AppConfig để xử lý ảnh (Tự động theo IP máy thật/máy ảo)
    String rawImage = AppConfig.formatUrl(json['image_url']);

    return Article(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Không có tiêu đề',
      description: json['description'] ?? '',
      imageUrl: rawImage,
      category: json['category'] ?? 'Tin tức',
      sourceName: json['source_name'] ?? 'HealthFlow',
      contentUrl: json['content_url'] ?? '',
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'])
          : null,
    );
  }
}