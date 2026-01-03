// lib/models/reminder_model.dart
import 'package:flutter/material.dart';

class Reminder {
  final int id;
  final String medicationName;
  final String? instruction;
  final String reminderTime; // Chuỗi thô từ Server (VD: "08:00:00")
  final bool isActive;

  Reminder({
    required this.id,
    required this.medicationName,
    this.instruction,
    required this.reminderTime,
    required this.isActive,
  });

  // 1. Getter chuyển đổi String -> TimeOfDay để dùng trong UI
  TimeOfDay get timeOfDay {
    try {
      final parts = reminderTime.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  // 2. Factory: JSON -> Object
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      medicationName: json['medication_name'] ?? 'Thuốc',
      instruction: json['instruction'],
      reminderTime: json['reminder_time'] ?? '00:00',
      isActive: json['is_active'] == true || json['is_active'] == 1, // Xử lý cả boolean và int (0/1)
    );
  }

  // 3. Hàm copyWith: Để tạo bản sao mới khi sửa 1 trường (VD: toggle active)
  Reminder copyWith({
    int? id,
    String? medicationName,
    String? instruction,
    String? reminderTime,
    bool? isActive,
  }) {
    return Reminder(
      id: id ?? this.id,
      medicationName: medicationName ?? this.medicationName,
      instruction: instruction ?? this.instruction,
      reminderTime: reminderTime ?? this.reminderTime,
      isActive: isActive ?? this.isActive,
    );
  }
}