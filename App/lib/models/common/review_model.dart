// lib/models/review_model.dart
import 'package:health_iot/core/constants/app_config.dart';

class Review {
  final String id;
  final String doctorName;
  final String specialty;
  final String? doctorAvatar;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.doctorName,
    required this.specialty,
    this.doctorAvatar,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  // [SỬA] Sử dụng AppConfig để format URL
  String get fullDoctorAvatarUrl {
    return AppConfig.formatUrl(doctorAvatar);
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      doctorName: json['doctor_name'] ?? 'Bác sĩ',
      specialty: json['specialty'] ?? 'Chuyên khoa',
      doctorAvatar: json['doctor_avatar'],
      // Ép kiểu an toàn
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}