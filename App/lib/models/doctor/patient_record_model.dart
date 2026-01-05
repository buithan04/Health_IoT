import 'package:intl/intl.dart';
import '../../core/constants/app_config.dart';

class PatientRecord {
  final String id;
  final String fullName;
  final String avatarUrl;
  final String gender;
  final String phone;
  final String address;
  final DateTime? dob;
  final int age;

  // Chỉ số sức khỏe
  final String bloodType;
  final double weight;
  final double height;
  final String allergies;
  final String chronicConditions;

  // List lịch sử
  final List<VisitHistory> history;
  final List<PrescriptionSummary> prescriptions; // Có thể rỗng nếu chưa implement

  // Thông tin hành chính
  final String insuranceNumber;
  final String occupation;
  final String emergencyName;
  final String emergencyPhone;

  PatientRecord({
    required this.id, required this.fullName, required this.avatarUrl,
    required this.gender, required this.phone, required this.address,
    this.dob, required this.age,
    required this.bloodType, required this.weight, required this.height,
    required this.allergies, required this.chronicConditions,
    required this.history, required this.prescriptions,
    required this.insuranceNumber, required this.occupation,
    required this.emergencyName, required this.emergencyPhone,
  });

  factory PatientRecord.fromJson(Map<String, dynamic> json) {
    String parseGender(String? g) {
      if (g == 'male' || g == 'Nam') return 'Nam';
      if (g == 'female' || g == 'Nữ') return 'Nữ';
      return g ?? 'Chưa cập nhật';
    }

    return PatientRecord(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? 'Chưa cập nhật',
      avatarUrl: AppConfig.formatUrl(json['avatarUrl'] ?? json['avatar_url']),
      gender: parseGender(json['gender']),
      phone: json['phone'] ?? json['phone_number'] ?? '',
      address: json['address'] ?? 'Chưa cập nhật',
      dob: json['date_of_birth'] != null ? DateTime.tryParse(json['date_of_birth'].toString()) : null,
      age: int.tryParse(json['age']?.toString() ?? '0') ?? 0,

      // [FIX] Map cả camelCase (nếu service đã xử lý) và snake_case (từ DB)
      bloodType: json['bloodType'] ?? json['blood_type'] ?? '?',
      weight: double.tryParse(json['weight']?.toString() ?? '0') ?? 0,
      height: double.tryParse(json['height']?.toString() ?? '0') ?? 0,
      allergies: json['allergies'] ?? 'Không',

      // Backend map 'medical_history' -> 'chronicConditions' trong JS, hoặc trả về nguyên gốc
      chronicConditions: json['chronicConditions'] ?? json['medical_history'] ?? 'Không',

      // [CẬP NHẬT] Map danh sách lịch sử và đơn thuốc với Model mới
      history: (json['history'] as List? ?? []).map((e) => VisitHistory.fromJson(e)).toList(),
      prescriptions: (json['prescriptions'] as List? ?? []).map((e) => PrescriptionSummary.fromJson(e)).toList(),

      insuranceNumber: json['insuranceNumber'] ?? json['insurance_number'] ?? 'Chưa cập nhật',
      occupation: json['occupation'] ?? 'Chưa cập nhật',
      emergencyName: json['emergencyName'] ?? json['emergency_contact_name'] ?? 'Không có',
      emergencyPhone: json['emergencyPhone'] ?? json['emergency_contact_phone'] ?? '',
    );
  }

  String get dobStr => dob != null ? DateFormat('dd/MM/yyyy').format(dob!) : 'N/A';
}

// --- [SỬA LẠI CLASS NÀY] ---
class VisitHistory {
  final String id;          // Thêm ID để bấm vào xem chi tiết
  final String date;
  final String notes;
  final String hospital;
  final String status;      // Thêm status để lọc "hoàn thành"
  final String doctorName;  // Thêm tên bác sĩ khám

  VisitHistory({
    required this.id,
    required this.date,
    required this.notes,
    required this.hospital,
    required this.status,
    required this.doctorName,
  });

  factory VisitHistory.fromJson(Map<String, dynamic> json) {
    return VisitHistory(
      id: json['id']?.toString() ?? '',
      date: json['date'] ?? json['appointment_date']?.toString() ?? '',
      notes: json['notes'] ?? '',
      hospital: json['hospital'] ?? json['hospital_name'] ?? 'Phòng khám',
      status: json['status'] ?? 'completed', // Mặc định nếu null coi như xong (tùy logic backend)
      doctorName: json['doctor_name'] ?? json['doctorName'] ?? 'Bác sĩ',
    );
  }
}

// --- [SỬA LẠI CLASS NÀY] ---
class PrescriptionSummary {
  final String id;
  final String date;
  final String diagnosis;
  final String doctorName; // Thêm người kê đơn

  PrescriptionSummary({
    required this.id,
    required this.date,
    required this.diagnosis,
    required this.doctorName
  });

  factory PrescriptionSummary.fromJson(Map<String, dynamic> json) {
    return PrescriptionSummary(
      id: json['id']?.toString() ?? '',
      date: json['created_at'] ?? json['date'] ?? '',
      diagnosis: json['diagnosis'] ?? 'Chẩn đoán',
      doctorName: json['doctor_name'] ?? json['doctorName'] ?? 'Bác sĩ',
    );
  }
}