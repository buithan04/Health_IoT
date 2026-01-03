import 'dart:convert';
import '../core/api/api_client.dart';
import '../models/common/appointment_model.dart';

class AppointmentService {
  final ApiClient _apiClient = ApiClient();

  // 1. Lấy danh sách lịch hẹn
  Future<List<Appointment>> getMyAppointments() async {
    try {
      final response = await _apiClient.get('/appointments/my-appointments');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching appointments: $e");
      return [];
    }
  }

  // 2. Chi tiết lịch hẹn
  Future<Appointment?> getAppointmentDetail(String id) async {
    try {
      final response = await _apiClient.get('/appointments/$id');
      if (response.statusCode == 200) {
        return Appointment.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 3. Lấy lịch rảnh
  Future<List<dynamic>> get7DayAvailability(String doctorId) async {
    try {
      final response = await _apiClient.get('/appointments/availability?doctorId=$doctorId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 4. Đặt lịch mới
  Future<bool> bookAppointment({
    required String doctorId,
    required String dateStr,
    required String time,
    required String reason,
    required String typeId,
  }) async {
    try {
      // [FIX] Kiểm tra nếu time đã có giây (09:30:00) thì không cộng thêm :00 nữa
      // Để tránh lỗi "Double Seconds" (09:30:00:00)
      String timePart = time.split(':').length == 3 ? time : "$time:00";
      String finalDateTime = '$dateStr $timePart';

      final response = await _apiClient.post('/appointments/book', {
        'doctorId': doctorId,
        'appointmentDate': finalDateTime,
        'reason': reason,
        'typeId': typeId,
      });
      return response.statusCode == 200;
    } catch (e) {
      print("BOOKING ERROR: $e"); // In lỗi ra console để debug
      return false;
    }
  }

  // 5. Đổi lịch
  Future<bool> rescheduleAppointment({
    required String appointmentId,
    required String dateStr,
    required String time,
    required String reason,
    required String typeId,
  }) async {
    try {
      // [FIX] Tương tự như trên
      String timePart = time.split(':').length == 3 ? time : "$time:00";
      String finalDateTime = '$dateStr $timePart';

      final response = await _apiClient.post('/appointments/reschedule', {
        'appointmentId': appointmentId,
        'appointmentDate': finalDateTime,
        'reason': reason,
        'typeId': typeId,
      });

      return response.statusCode == 200;
    } catch (e) {
      print("RESCHEDULE ERROR: $e");
      return false;
    }
  }

  // 6. Hủy lịch
  Future<bool> cancelAppointment(String id, {String? reason}) async {
    try {
      // Backend dùng PUT /appointments/:id/status
      final response = await _apiClient.put('/appointments/$id/status', {
        'status': 'cancelled', // Dù controller xử lý logic hủy, nhưng gửi status cho rõ ràng
        'cancellationReason': reason ?? "Người dùng hủy lịch",
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}