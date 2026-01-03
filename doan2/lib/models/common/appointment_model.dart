import 'package:intl/intl.dart';
import '../../core/constants/app_config.dart';

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String avatarUrl;
  final String patientId;
  final String patientName;
  final String patientAvatar;
  final DateTime date;
  final String status;
  final String notes;
  final String hospitalName;
  final bool isReviewed;
  final int reviewRating;
  final String reviewComment;
  final String? serviceName;
  final num? price;
  final int? duration;
  final String? cancellationReason;
  final String? clinicAddress;

  Appointment({
    required this.id, required this.doctorId, required this.doctorName,
    required this.specialty, required this.avatarUrl, required this.patientId,
    required this.patientName, required this.patientAvatar, required this.date,
    required this.status, this.notes = '', this.hospitalName = '',
    this.isReviewed = false, this.reviewRating = 0, this.reviewComment = '',
    this.serviceName, this.price, this.duration, this.cancellationReason, this.clinicAddress,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // 1. Xử lý Doctor (Hỗ trợ cả snake_case và camelCase)
    String dId = (json['doctor_id'] ?? json['doctorId'])?.toString() ?? '';
    String dName = json['doctor_name'] ?? json['doctorName'] ?? 'Bác sĩ';
    String dSpec = json['specialty'] ?? 'Chuyên khoa';
    String dAvatar = AppConfig.formatUrl(json['doctor_avatar'] ?? json['doctorAvatar'] ?? json['avatarUrl']);
    String? dClinicAddress = json['clinic_address'];

    // 2. Xử lý Patient
    String pId = (json['patient_id'] ?? json['patientId'])?.toString() ?? '';
    String pName = json['patient_name'] ?? json['patientName'] ?? 'Bệnh nhân';
    String pAvatar = AppConfig.formatUrl(json['patient_avatar'] ?? json['patientAvatar']);

    // 3. Xử lý Date (Hỗ trợ nhiều định dạng)
    DateTime parsedDate = DateTime.now();
    var rawDate = json['appointment_date'] ?? json['fullDateTimeStr'];
    if (rawDate != null) {
      try { parsedDate = DateTime.parse(rawDate.toString()); } catch (_) {}
    }

    // 4. Xử lý Giá & Dịch vụ
    String? sName = json['service_name'] ?? json['name'];
    num? sPrice = num.tryParse(json['price']?.toString() ?? '0');
    int? sDuration = int.tryParse(json['duration']?.toString() ?? '30') ??
        int.tryParse(json['duration_minutes']?.toString() ?? '30');

    return Appointment(
      id: json['id']?.toString() ?? '',
      doctorId: dId, doctorName: dName, specialty: dSpec, avatarUrl: dAvatar,
      patientId: pId, patientName: pName, patientAvatar: pAvatar,
      date: parsedDate, status: json['status'] ?? 'pending',
      notes: json['notes'] ?? '',
      hospitalName: json['hospital_name'] ?? json['hospitalName'] ?? 'Phòng khám',
      isReviewed: json['is_reviewed'] ?? json['isReviewed'] ?? false,
      reviewRating: int.tryParse(json['review_rating']?.toString() ?? '0') ?? 0,
      reviewComment: json['review_comment'] ?? '',
      serviceName: sName, price: sPrice, duration: sDuration,
      cancellationReason: json['cancellation_reason'] ?? json['cancellationReason'],
      clinicAddress: dClinicAddress,
    );
  }

  String get timeStr => DateFormat('HH:mm').format(date);
  String get dateStr => DateFormat('dd/MM/yyyy').format(date);
  String get fullDateTimeStr => '$timeStr - $dateStr';
}