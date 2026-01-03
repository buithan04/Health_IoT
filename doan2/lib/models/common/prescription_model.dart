// lib/models/common/prescription_model.dart
import 'package:intl/intl.dart';

// ==========================================================
// 1. MODEL THUỐC (Chi tiết trong đơn)
// ==========================================================
class MedicationItem {
  final String name;
  final String instruction; // Cách dùng (dosage + instruction)
  final String quantity;    // String để chứa cả đơn vị (VD: "10 viên")

  MedicationItem({
    required this.name,
    required this.instruction,
    required this.quantity,
  });

  // Convert từ JSON (Backend trả về) -> Dart
  factory MedicationItem.fromJson(Map<String, dynamic> json) {
    return MedicationItem(
      // Backend có thể trả về 'name' hoặc 'medication_name_snapshot' tùy API
      name: json['name'] ?? json['medication_name_snapshot'] ?? '',

      // Backend có thể trả về 'instruction' hoặc 'dosage_instruction'
      instruction: json['instruction'] ?? json['dosage_instruction'] ?? '',

      quantity: json['quantity']?.toString() ?? '',
    );
  }

  // Convert từ Dart -> JSON (Để gửi lên Backend khi tạo đơn)
  Map<String, dynamic> toJson() => {
    'name': name,
    'instruction': instruction,
    'quantity': quantity,
  };
}

// ==========================================================
// 2. MODEL ĐƠN THUỐC (Tổng quát)
// ==========================================================
class Prescription {
  final int id;
  final String doctorName;  // Tên bác sĩ (để Patient xem)
  final String patientName; // Tên bệnh nhân (để Doctor xem)
  final String diagnosis;
  final String notes;       // Lời dặn
  final DateTime createdAt;
  final List<MedicationItem> medications;

  Prescription({
    required this.id,
    this.doctorName = '',
    this.patientName = '',
    required this.diagnosis,
    required this.notes,
    required this.createdAt,
    required this.medications,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    var listMed = json['medications'] as List? ?? [];
    List<MedicationItem> medObjects = listMed.map((i) => MedicationItem.fromJson(i)).toList();

    return Prescription(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,

      // Map linh hoạt tùy API trả về
      doctorName: json['doctor_name'] ?? 'Bác sĩ',
      patientName: json['patient_name'] ?? 'Bệnh nhân',

      diagnosis: json['diagnosis'] ?? 'Chưa có chẩn đoán',
      notes: json['notes'] ?? json['patient_notes'] ?? '', // Lời dặn

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),

      medications: medObjects,
    );
  }

  // Helper ngày tháng: "25/11/2025"
  String get dateStr => DateFormat('dd/MM/yyyy').format(createdAt);

  // Helper giờ: "14:30"
  String get timeStr => DateFormat('HH:mm').format(createdAt);
}