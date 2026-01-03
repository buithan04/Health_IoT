import 'package:flutter/material.dart';

// 1. Model cho một điểm dữ liệu (VD: Nhịp tim lúc 10:00 là 80)
class HealthDataPoint {
  final DateTime time;
  final double value;

  HealthDataPoint(this.time, this.value);
}

// 2. Model cấu hình cho từng loại chỉ số (Màu sắc, ngưỡng an toàn, icon...)
class HealthMetricConfig {
  final String key;         // ID định danh (vd: 'heartRate')
  final String title;       // Tên hiển thị
  final String unit;        // Đơn vị
  final IconData icon;
  final Color color;
  final double minNormal;   // Ngưỡng thấp nhất bình thường
  final double maxNormal;   // Ngưỡng cao nhất bình thường
  final String description; // Mô tả y khoa

  const HealthMetricConfig({
    required this.key,
    required this.title,
    required this.unit,
    required this.icon,
    required this.color,
    required this.minNormal,
    required this.maxNormal,
    required this.description,
  });
}

// 3. Dữ liệu cấu hình mặc định (Static Data)
// Tách biệt phần cấu hình ra khỏi UI để dễ quản lý
class HealthConfigData {
  static final Map<String, HealthMetricConfig> metrics = {
    'heartRate': const HealthMetricConfig(
      key: 'heartRate',
      title: 'Nhịp tim',
      unit: 'BPM',
      icon: Icons.favorite_rounded,
      color: Color(0xFFFF5252), // Đỏ tươi
      minNormal: 60,
      maxNormal: 100,
      description: 'Nhịp tim nghỉ ngơi bình thường: 60-100 BPM.',
    ),
    'spo2': const HealthMetricConfig(
      key: 'spo2',
      title: 'SpO2',
      unit: '%',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF448AFF), // Xanh dương tươi
      minNormal: 95,
      maxNormal: 100,
      description: 'Nồng độ oxy trong máu bình thường: 95-100%.',
    ),
    'temperature': const HealthMetricConfig(
      key: 'temperature',
      title: 'Thân nhiệt',
      unit: '°C',
      icon: Icons.thermostat_rounded,
      color: Color(0xFFFFAB40), // Cam tươi
      minNormal: 36.1,
      maxNormal: 37.2,
      description: 'Nhiệt độ cơ thể ổn định: 36.1°C - 37.2°C.',
    ),
  };
}