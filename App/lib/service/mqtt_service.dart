// lib/service/mqtt_service.dart
// Health Data Service - Nhận dữ liệu real-time từ Backend qua Socket.IO
// Backend làm MQTT gateway - App không connect trực tiếp HiveMQ

import 'dart:async';
import 'package:health_iot/models/patient/health_model.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  // Connection status (theo Socket.IO) - Tách riêng từng topic
  bool isConnected = false;
  bool isEcgOnline = false;     // ECG topic status
  bool isVitalsOnline = false;  // Vitals topic status
  DateTime? _lastEcgUpdate;
  DateTime? _lastVitalsUpdate;

  // --- Stream Controllers ---
  final StreamController<HealthMetric> _healthStreamController = 
      StreamController<HealthMetric>.broadcast();
  final StreamController<Map<String, dynamic>> _ecgStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _ecgConnectionController = 
      StreamController<bool>.broadcast();
  final StreamController<bool> _vitalsConnectionController = 
      StreamController<bool>.broadcast();

  Stream<HealthMetric> get healthStream => _healthStreamController.stream;
  Stream<Map<String, dynamic>> get ecgStream => _ecgStreamController.stream;
  Stream<bool> get ecgConnectionStream => _ecgConnectionController.stream;
  Stream<bool> get vitalsConnectionStream => _vitalsConnectionController.stream;

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
      
      // Update vitals connection status
      _lastVitalsUpdate = DateTime.now();
      isVitalsOnline = true;
      _vitalsConnectionController.add(true);
      isConnected = true;
      
      // Auto-expire after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (_lastVitalsUpdate != null && 
            DateTime.now().difference(_lastVitalsUpdate!).inSeconds >= 5) {
          isVitalsOnline = false;
          _vitalsConnectionController.add(false);
        }
      });
    } catch (e) {
      print('❌ Error handling medical data: $e');
    }
  }

  /// Handle ECG data từ Socket.IO (forwarded from backend MQTT)
  void handleSocketECGData(Map<String, dynamic> data) {
    try {
      _ecgStreamController.add(data);
      currentECGData = data;
      
      // Update ECG connection status
      _lastEcgUpdate = DateTime.now();
      isEcgOnline = true;
      _ecgConnectionController.add(true);
      isConnected = true;
      
      // Auto-expire after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (_lastEcgUpdate != null && 
            DateTime.now().difference(_lastEcgUpdate!).inSeconds >= 5) {
          isEcgOnline = false;
          _ecgConnectionController.add(false);
        }
      });
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
    _ecgConnectionController.close();
    _vitalsConnectionController.close();
  }
}
