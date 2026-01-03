import 'dart:convert';
import 'package:intl/intl.dart';
import '../core/api/api_client.dart';
import '../models/doctor/doctor_model.dart';
import '../models/common/appointment_model.dart';
import '../models/doctor/doctor_review_model.dart';
import '../models/doctor/patient_record_model.dart';

class DoctorService {
  final ApiClient _apiClient = ApiClient();

  // ---------------------------------------------------------------------------
  // 1. CÁC API CHUNG (PUBLIC / SEARCH)
  // ---------------------------------------------------------------------------

  // Lấy danh sách bác sĩ
  Future<List<Doctor>> getAllDoctors({String? query}) async {
    try {
      String endpoint = '/doctors';
      if (query != null && query.isNotEmpty) {
        endpoint += '?q=$query';
      }
      final response = await _apiClient.get(endpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Doctor.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Lỗi get doctors: $e');
      return [];
    }
  }

  // Lấy chi tiết bác sĩ
  Future<Doctor?> getDoctorDetail(String id) async {
    try {
      final response = await _apiClient.get('/doctors/$id');
      if (response.statusCode == 200) {
        return Doctor.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Error detail: $e");
    }
    return null;
  }

  // Gửi đánh giá
  Future<bool> submitReview({
    required String doctorId,
    required String appointmentId,
    required int rating,
    required String comment,
  }) async {
    try {
      final body = {
        "doctorId": doctorId,
        "appointmentId": appointmentId,
        "rating": rating,
        "comment": comment
      };
      final response = await _apiClient.post('/doctors/review', body);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. DASHBOARD BÁC SĨ (DASHBOARD & APPOINTMENTS)
  // ---------------------------------------------------------------------------

  // Thống kê Dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiClient.get('/doctors/dashboard-stats');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Lỗi stats: $e");
    }
    return {'pending_requests': 0, 'today_appointments': 0};
  }

  // Lịch hẹn hôm nay
  Future<List<Appointment>> getTodayAppointments() async {
    try {
      final response = await _apiClient.get('/doctors/appointments?date=today');
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((json) => Appointment.fromJson(json)).toList();
      }
    } catch (e) {
      print("Lỗi today schedule: $e");
    }
    return [];
  }

  // Xử lý trạng thái lịch hẹn (Duyệt/Hủy)
  Future<bool> respondToAppointment(String appointmentId, String status, {String? reason}) async {
    try {
      final Map<String, dynamic> body = {'status': status};
      if (reason != null && reason.isNotEmpty) {
        body['cancellationReason'] = reason;
      }

      final response = await _apiClient.put('/doctors/appointments/$appointmentId', body);
      return response.statusCode == 200;
    } catch (e) {
      print("Error respondToAppointment: $e");
      return false;
    }
  }

  // Lấy lịch hẹn theo trạng thái
  Future<List<Appointment>> getAppointmentsByStatus(String status) async {
    try {
      final response = await _apiClient.get('/doctors/appointments?status=$status');
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((json) => Appointment.fromJson(json)).toList();
      }
    } catch (e) {
      print("Lỗi getAppointmentsByStatus: $e");
    }
    return [];
  }

  // Lấy chi tiết lịch hẹn (Góc nhìn bác sĩ)
  Future<Appointment?> getAppointmentDetail(String id) async {
    try {
      final response = await _apiClient.get('/doctors/appointments/$id');
      if (response.statusCode == 200) {
        return Appointment.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Lỗi getAppointmentDetail: $e");
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // 3. QUẢN LÝ LỊCH RẢNH (AVAILABILITY)
  // ---------------------------------------------------------------------------

  Future<List<String>> getAvailableSlots(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await _apiClient.get('/doctors/availability?date=$dateStr');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['slots'] ?? []);
      }
    } catch (e) {
      print("Lỗi getAvailableSlots: $e");
    }
    return [];
  }

  Future<bool> saveAvailableSlots(DateTime date, List<String> slots) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await _apiClient.post('/doctors/availability', {
        "date": dateStr,
        "slots": slots
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Lỗi saveAvailableSlots: $e");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 4. QUẢN LÝ BỆNH NHÂN (PATIENTS & RECORDS) - [SỬA LỖI getMyPatients, getPatientHealthStats]
  // ---------------------------------------------------------------------------

  // Lấy hồ sơ chi tiết bệnh nhân
  Future<PatientRecord?> getPatientRecord(String patientId) async {
    if (patientId == "null" || patientId.isEmpty) return null;
    try {
      final response = await _apiClient.get('/doctors/patient-record/$patientId');
      if (response.statusCode == 200) {
        return PatientRecord.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Lỗi getPatientRecord: $e");
    }
    return null;
  }

  // [FIX] Hàm lấy danh sách bệnh nhân
  Future<List<Map<String, dynamic>>> getMyPatients() async {
    try {
      final response = await _apiClient.get('/doctors/patients');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (e) {
      print("Lỗi getMyPatients: $e");
    }
    return [];
  }

  // [FIX] Hàm lấy thống kê sức khỏe (Chart)
  Future<Map<String, List<double>>> getPatientHealthStats(String patientId) async {
    try {
      final response = await _apiClient.get('/doctors/patients/$patientId/health-stats');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        List<double> heartRate = [];
        List<double> spo2 = [];
        List<double> temp = [];

        // Parse dữ liệu từ server (ngược chiều thời gian nếu cần)
        for (var item in data) {
          heartRate.add(double.tryParse(item['heart_rate'].toString()) ?? 0);
          spo2.add(double.tryParse(item['spo2'].toString()) ?? 0);
          temp.add(double.tryParse(item['temperature'].toString()) ?? 0);
        }

        return {
          'heart_rate': heartRate,
          'spo2': spo2,
          'temp': temp
        };
      }
    } catch (e) {
      print("Lỗi getPatientHealthStats: $e");
    }
    return {'heart_rate': [], 'spo2': [], 'temp': []};
  }
  // ---------------------------------------------------------------------------
  // 5. GHI CHÚ CÔNG VIỆC (NOTES) - [ĐÃ SỬA HOÀN CHỈNH]
  // ---------------------------------------------------------------------------

  Future<List<Note>> getNotes() async {
    try {
      final response = await _apiClient.get('/doctors/notes');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Note.fromJson(json)).toList();
      }
    } catch (e) {
      print("Lỗi getNotes: $e");
    }
    return [];
  }

  Future<bool> createNote(String content) async {
    try {
      final response = await _apiClient.post('/doctors/notes', {'content': content});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateNote(int id, String content) async {
    try {
      final response = await _apiClient.put('/doctors/notes/$id', {'content': content});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNote(int id) async {
    try {
      final response = await _apiClient.delete('/doctors/notes/$id');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  // ---------------------------------------------------------------------------
  // 6. CÁC API KHÁC (SERVICES, ANALYTICS, PROFILE...)
  // ---------------------------------------------------------------------------

  // Lấy danh sách reviews
  Future<List<DoctorReview>> getDoctorReviews(String doctorId) async {
    try {
      final response = await _apiClient.get('/doctors/$doctorId/reviews');
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((json) => DoctorReview.fromJson(json)).toList();
      }
    } catch (e) {
      print("Lỗi lấy reviews: $e");
    }
    return [];
  }

  // Lấy loại dịch vụ khám
  Future<List<dynamic>> getAppointmentTypes(String? doctorId) async {
    try {
      String url = '/doctors/appointment-types';
      if (doctorId != null) url += '?doctorId=$doctorId';
      final response = await _apiClient.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {}
    return [];
  }

  // CRUD Service
  Future<bool> createService(Map<String, dynamic> data) async => _apiClient.post('/doctors/services', data).then((r) => r.statusCode == 200).catchError((_) => false);
  Future<bool> updateService(String id, Map<String, dynamic> data) async => _apiClient.put('/doctors/services/$id', data).then((r) => r.statusCode == 200).catchError((_) => false);
  Future<bool> deleteService(String id) async => _apiClient.delete('/doctors/services/$id').then((r) => r.statusCode == 200).catchError((_) => false);

  // Analytics
  Future<Map<String, dynamic>?> getAnalytics(String period) async {
    try {
      final response = await _apiClient.get('/doctors/analytics?period=$period');
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {}
    return null;
  }

  // [SỬA LẠI HÀM NÀY]
  Future<bool> updateProfessionalInfo(Map<String, dynamic> data) async {
    try {
      // Gửi toàn bộ map data lên server
      final response = await _apiClient.put('/doctors/profile/professional-info', data);
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi updateProfessionalInfo: $e");
      return false;
    }
  }
}

/// --- MODEL NOTE ĐÃ SỬA LẠI ---
class Note {
  int id;
  String content;
  String? createdAt; // <--- QUAN TRỌNG: Phải có trường này

  Note({required this.id, required this.content, this.createdAt});

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    content: json['content'],
    // Postgres trả về 'created_at', ta map vào biến createdAt
    createdAt: json['created_at']?.toString() ?? DateTime.now().toString(),
  );
}