import 'dart:convert';
import '../core/api/api_client.dart';
import '../models/common/prescription_model.dart';
import '../models/common/medication_model.dart';

class PrescriptionService {
  final ApiClient _apiClient = ApiClient();

  // 1. Lấy danh sách đơn thuốc của tôi
  Future<List<Prescription>> getMyPrescriptions() async {
    try {
      final response = await _apiClient.get('/prescriptions/my-prescriptions');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Prescription.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Lỗi lấy đơn thuốc: $e");
      return [];
    }
  }

  // 2. Lấy chi tiết đơn thuốc
  Future<Prescription?> getPrescriptionDetail(String id) async {
    try {
      // [FIX] Route backend là /prescriptions/:id
      final response = await _apiClient.get('/prescriptions/$id');
      if (response.statusCode == 200) {
        return Prescription.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Lỗi lấy chi tiết đơn: $e");
    }
    return null;
  }

  // 3. Kê đơn thuốc (Dành cho Bác sĩ)
  Future<bool> createPrescription({
    required int patientId,
    required String diagnosis,
    required String notes,
    required List<MedicationItem> medications,
    String? chiefComplaint, // [MỚI] Khớp với Backend
    String? clinicalFindings, // [MỚI] Khớp với Backend
  }) async {
    try {
      final body = {
        'patientId': patientId,
        'diagnosis': diagnosis,
        'notes': notes,
        'chiefComplaint': chiefComplaint ?? '',
        'clinicalFindings': clinicalFindings ?? '',
        'medications': medications.map((e) => e.toJson()).toList(),
      };

      // [FIX] Route backend là POST /prescriptions
      final response = await _apiClient.post('/prescriptions', body);

      // Backend trả về 200 OK hoặc 201 Created đều được chấp nhận
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Lỗi tạo đơn thuốc: $e");
      return false;
    }
  }

  // 4. Tìm kiếm thuốc
  Future<List<Medication>> searchMedications(String query) async {
    try {
      final response = await _apiClient.get('/prescriptions/medications?q=$query');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Medication.fromJson(json)).toList();
      }
    } catch (e) {
      print("Lỗi tìm thuốc: $e");
    }
    return [];
  }
}