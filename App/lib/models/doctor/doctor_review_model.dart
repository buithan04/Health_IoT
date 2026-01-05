import 'package:intl/intl.dart';
import '../../core/constants/app_config.dart';

class DoctorReview {
  final String id;
  final String patientName;
  final String avatarUrl;
  final int rating;
  final String comment;
  final DateTime? date;

  DoctorReview({
    required this.id,
    required this.patientName,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    this.date,
  });

  factory DoctorReview.fromJson(Map<String, dynamic> json) {
    // [FIX] Ưu tiên lấy 'patient_name' từ backend trả về
    String name = json['patient_name'] ?? json['patientName'] ?? 'Ẩn danh';

    // [FIX] Ưu tiên lấy 'patient_avatar' từ backend
    String rawUrl = AppConfig.formatUrl(json['patient_avatar'] ?? json['patientAvatar'] ?? json['avatarUrl']);

    return DoctorReview(
      id: json['id']?.toString() ?? '',
      patientName: name,
      avatarUrl: rawUrl,
      rating: int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      comment: json['comment'] ?? '',
      date: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : (json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null),
    );
  }

  String get dateDisplay {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date!);
  }
}