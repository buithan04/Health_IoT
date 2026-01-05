// lib/models/health_model.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// AI Diagnosis Model
class AIDiagnosis {
  final String model; // 'MLP' or 'CNN'
  final String result; // Risk level or ECG classification
  final double confidence; // Percentage
  final String severity; // 'NORMAL', 'WARNING', 'DANGER'
  final String? recommendation;
  final DateTime timestamp;

  AIDiagnosis({
    required this.model,
    required this.result,
    required this.confidence,
    required this.severity,
    this.recommendation,
    required this.timestamp,
  });

  factory AIDiagnosis.fromJson(Map<String, dynamic> json) {
    return AIDiagnosis(
      model: json['model'] ?? 'Unknown',
      result: json['riskLabel'] ?? json['result'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0).toDouble(),
      severity: json['severity'] ?? 'NORMAL',
      recommendation: json['recommendation'],
      timestamp: json['timestamp'] != null 
        ? DateTime.parse(json['timestamp'])
        : DateTime.now(),
    );
  }

  Color get severityColor {
    switch (severity) {
      case 'DANGER':
        return Color(0xFFDC2626);
      case 'WARNING':
        return Color(0xFFF59E0B);
      default:
        return Color(0xFF10B981);
    }
  }

  IconData get severityIcon {
    switch (severity) {
      case 'DANGER':
        return Icons.warning_amber_rounded;
      case 'WARNING':
        return Icons.info_outline;
      default:
        return Icons.check_circle_outline;
    }
  }
}

class HealthMetric {
  final String heartRate;
  final String spo2;
  final String temperature;
  final String bloodPressure;
  final DateTime timestamp;

  HealthMetric({
    required this.heartRate,
    required this.spo2,
    required this.temperature,
    required this.bloodPressure,
    required this.timestamp,
  });

  // Giá trị mặc định
  factory HealthMetric.empty() {
    return HealthMetric(
      heartRate: '0',
      spo2: '0',
      temperature: '0',
      bloodPressure: '0/0',
      timestamp: DateTime.now(),
    );
  }

  // Parse thông minh: Chấp nhận cả dữ liệu từ MQTT (camelCase) và API Database (snake_case)
  factory HealthMetric.fromJson(Map<String, dynamic> json) {

    // Helper function: Lấy giá trị từ nhiều key có thể có
    String getValue(List<String> keys) {
      for (var key in keys) {
        if (json[key] != null) {
          return json[key].toString();
        }
      }
      return '--';
    }

    // Xử lý thời gian
    DateTime time = DateTime.now();
    if (json['measured_at'] != null) {
      // Trường hợp lấy từ Database
      time = DateTime.parse(json['measured_at']).toLocal();
    } else if (json['timestamp'] != null) {
      // Trường hợp lấy từ MQTT/Socket
      try {
        time = DateTime.parse(json['timestamp']).toLocal();
      } catch (_) {}
    }

    // Xử lý huyết áp (Nếu API tách riêng sys/dia)
    String bp = '--';
    if (json['sys_bp'] != null && json['dia_bp'] != null) {
      bp = "${json['sys_bp']}/${json['dia_bp']}";
    } else {
      bp = getValue(['bloodPressure', 'blood_pressure']);
    }

    return HealthMetric(
      heartRate: getValue(['heartRate', 'heart_rate']),   // MQTT: heartRate, DB: heart_rate
      spo2: getValue(['spo2', 'SPO2']),                   // DB thường viết thường hoặc hoa
      temperature: getValue(['temperature', 'temp']),
      bloodPressure: bp,
      timestamp: time,
    );
  }

  // Helper để hiển thị giờ: "10:30"
  String get timeDisplay => DateFormat('HH:mm').format(timestamp);
}