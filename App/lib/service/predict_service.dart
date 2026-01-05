// lib/core/api/predict_service.dart
import 'dart:convert';
import '../core/api/api_client.dart'; // Import file lõi

class PredictService {
  final ApiClient _apiClient;

  // Nhận ApiClient qua constructor
  PredictService(this._apiClient);

  /// Dự đoán MLP
  Future<Map<String, dynamic>?> predictMLP(List<double> inputData) async {
    try {
      // Chỉ cần gọi post. ApiClient sẽ tự thêm token.
      final response = await _apiClient.post('/predict/mlp', {
        'data': inputData,
      });

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print("PredictService: Dự đoán MLP thành công - $body");
        return body; // Trả về, ví dụ: {"prediction": "Bình thường", "confidence": 0.9}
      } else {
        print("PredictService: Dự đoán MLP thất bại - ${response.body}");
        return null;
      }
    } catch (e) {
      print("PredictService: Lỗi nghiêm trọng khi predict MLP - $e");
      return null;
    }
  }

  /// Dự đoán ECG
  Future<Map<String, dynamic>?> predictECG(List<double> inputData) async {
    try {
      final response = await _apiClient.post('/predict/ecg', {
        'data': inputData,
      });

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print("PredictService: Dự đoán ECG thành công - $body");
        return body;
      } else {
        print("PredictService: Dự đoán ECG thất bại - ${response.body}");
        return null;
      }
    } catch (e) {
      print("PredictService: Lỗi nghiêm trọng khi predict ECG - $e");
      return null;
    }
  }
}