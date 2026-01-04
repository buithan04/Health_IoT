// lib/service/mqtt_service.dart
// Health Data Service - Nhận dữ liệu real-time từ Backend qua Socket.IO
// Backend làm MQTT gateway - App không connect trực tiếp HiveMQ

import 'dart:async';
import 'package:app_iot/models/patient/health_model.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  // Connection status (theo Socket.IO)
  bool isConnected = false;

  // --- Stream Controllers ---
  final StreamController<HealthMetric> _healthStreamController = 
      StreamController<HealthMetric>.broadcast();
  final StreamController<Map<String, dynamic>> _ecgStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<HealthMetric> get healthStream => _healthStreamController.stream;
  Stream<Map<String, dynamic>> get ecgStream => _ecgStreamController.stream;

  // Cache data
  HealthMetric? currentHealthData;
  Map<String, dynamic>? currentECGData;

  /// Initialize - Không cần connect MQTT nữa
  Future<void> connect() async {
    print('ℹ️ MqttService: Dùng Socket.IO gateway từ backend');
    isConnected = true; // Giả lập status
  }

  /// Handle medical data từ Socket.IO (forwarded from backend MQTT)
  void handleSocketMedicalData(Map<String, dynamic> data) {
    try {
      final healthMetric = HealthMetric(
        heartRate: data['heart_rate']?.toString() ?? '0',
        spo2: data['spo2']?.toString() ?? '0',
        temperature: data['temperature']?.toString() ?? '0',
        bloodPressure: '0/0', // ESP32 chưa có BP
        timestamp: DateTime.parse(
          data['measured_at'] ?? DateTime.now().toIso8601String()
        ),
      );
      
      _healthStreamController.add(healthMetric);
      currentHealthData = healthMetric;
      isConnected = true;
    } catch (e) {
      print('❌ Error handling medical data: $e');
    }
  }

  /// Handle ECG data từ Socket.IO (forwarded from backend MQTT)
  void handleSocketECGData(Map<String, dynamic> data) {
    try {
      _ecgStreamController.add(data);
      currentECGData = data;
      isConnected = true;
    } catch (e) {
      print('❌ Error handling ECG data: $e');
    }
  }

  /// Disconnect (cleanup)
  void disconnect() {
    isConnected = false;
    print('ℹ️ MqttService: Disconnected');
  }

  /// Dispose streams
  void dispose() {
    _healthStreamController.close();
    _ecgStreamController.close();
  }
}
