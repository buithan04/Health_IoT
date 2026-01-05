// lib/models/user_model.dart
import '../../core/constants/app_config.dart'; // [MỚI] Import Config
// 1. Định nghĩa Role bằng Enum
enum UserRole { patient, doctor, admin, unknown }

// 2. Class User: Định nghĩa cấu trúc người dùng
class User {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final UserRole role;

  // --- Các trường bổ sung cho Profile & Sức khỏe ---
  final String? phoneNumber;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? height;
  final double? weight;
  final String? bloodType; // [QUAN TRỌNG] Đã thêm trường này để sửa lỗi
  final String? medicalHistory;
  final String? allergies;

  // --- Các trường hành chính ---
  final String? insuranceNumber;
  final String? occupation;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    this.phoneNumber,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    this.bloodType, // [QUAN TRỌNG] Thêm vào constructor
    this.medicalHistory,
    this.allergies,
    this.insuranceNumber,
    this.occupation,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  // [SỬA] Sử dụng AppConfig để format URL ảnh
  String get fullAvatarUrl {
    return AppConfig.formatUrl(avatarUrl);
  }

  // Tính BMI tự động
  String get bmi {
    if (height == null || weight == null || height == 0) return '-';
    double hM = height! / 100;
    return (weight! / (hM * hM)).toStringAsFixed(1);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['email'] ?? 'Người dùng',
      avatarUrl: json['avatar_url'],
      role: _parseRole(json['role']),
      phoneNumber: json['phone_number'],
      address: json['address'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'] != null ? DateTime.tryParse(json['date_of_birth'].toString()) : null,

      // Map dữ liệu sức khỏe
      height: double.tryParse(json['height']?.toString() ?? ''),
      weight: double.tryParse(json['weight']?.toString() ?? ''),
      bloodType: json['blood_type'], // [QUAN TRỌNG] Map từ JSON 'blood_type' sang biến Dart
      medicalHistory: json['medical_history'],
      allergies: json['allergies'],

      // Map dữ liệu hành chính
      insuranceNumber: json['insurance_number'],
      occupation: json['occupation'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
    );
  }

  static UserRole _parseRole(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'patient': return UserRole.patient;
      case 'doctor': return UserRole.doctor;
      case 'admin': return UserRole.admin;
      default: return UserRole.patient;
    }
  }
}

// 3. Class AuthResponse
class AuthResponse {
  final String token;
  final UserRole role;
  final String userId;
  final String userName;
  final String? avatar;

  AuthResponse({
    required this.token, 
    required this.role,
    required this.userId,
    required this.userName,
    this.avatar,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      role: User._parseRole(json['role']),
      userId: json['userId']?.toString() ?? '',
      userName: json['userName'] ?? '',
      avatar: json['avatar'],
    );
  }
}