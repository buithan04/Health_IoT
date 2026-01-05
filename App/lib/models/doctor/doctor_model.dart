import 'package:intl/intl.dart';
import '../../core/constants/app_config.dart';

class Doctor {
  final String id;
  final String fullName;
  final String specialty;
  final String avatarUrl;

  final String bio;
  final String hospitalName;
  final String clinicAddress; // [MỚI] Thêm trường này
  final int yearsOfExperience;
  final num consultationFee;
  final num ratingAverage;
  final int reviewCount;
  final String licenseNumber;
  final String education;
  final List<String> languages;
  final String email;
  final String phoneNumber;
  final String address;
  final String gender;
  final DateTime? dateOfBirth;

  Doctor({
    required this.id,
    required this.fullName,
    required this.specialty,
    required this.avatarUrl,
    required this.bio,
    required this.hospitalName,
    required this.clinicAddress, // [MỚI]
    required this.yearsOfExperience,
    required this.consultationFee,
    required this.ratingAverage,
    required this.reviewCount,
    required this.licenseNumber,
    required this.education,
    required this.languages,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    this.dateOfBirth,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    String getString(dynamic val, {String defaultVal = ''}) {
      if (val == null) return defaultVal;
      return val.toString();
    }

    num getNum(dynamic val) {
      if (val == null) return 0;
      return num.tryParse(val.toString()) ?? 0;
    }

    List<String> parseLangs(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is String) {
        String s = val.replaceAll('{', '').replaceAll('}', '').replaceAll('"', '');
        return s.split(',').where((e) => e.trim().isNotEmpty).toList();
      }
      return [];
    }

    return Doctor(
      id: getString(json['id'] ?? json['doctor_id']),
      fullName: getString(json['full_name'] ?? json['fullName'], defaultVal: 'Bác sĩ'),
      specialty: getString(json['specialty'], defaultVal: 'Đa khoa'),
      avatarUrl: AppConfig.formatUrl(json['avatar_url'] ?? json['avatarUrl']),

      bio: getString(json['bio']),
      hospitalName: getString(json['hospital_name'] ?? json['hospitalName']),
      // [MỚI] Map clinic_address
      clinicAddress: getString(json['clinic_address'] ?? json['clinicAddress']),

      yearsOfExperience: getNum(json['years_of_experience']).toInt(),
      consultationFee: getNum(json['consultation_fee']),
      ratingAverage: getNum(json['rating_average']),
      reviewCount: getNum(json['review_count']).toInt(),
      licenseNumber: getString(json['license_number']),
      education: getString(json['education']),
      languages: parseLangs(json['languages']),
      email: getString(json['email']),
      phoneNumber: getString(json['phone_number'] ?? json['phoneNumber']),
      address: getString(json['address']),
      gender: getString(json['gender']),
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'].toString())
          : null,
    );
  }

  // Getters hiển thị
  String get bioDisplay => bio.isEmpty ? 'Chưa cập nhật thông tin giới thiệu.' : bio;
  String get hospitalDisplay => hospitalName.isEmpty ? 'Chưa cập nhật' : hospitalName;
  String get phoneDisplay => phoneNumber.isEmpty ? 'Chưa cập nhật' : phoneNumber;

  String get feeDisplay {
    if (consultationFee == 0) return 'Liên hệ';
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(consultationFee);
  }

  String get ratingDisplay {
    if (reviewCount == 0) return 'Chưa có đánh giá';
    return '$ratingAverage ($reviewCount đánh giá)';
  }
}