import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../models/patient/reminder_model.dart'; // Import Model

class ReminderService {
  final ApiClient _apiClient = ApiClient();

  // 1. Lấy danh sách (Trả về List<Reminder>)
  Future<List<Reminder>> getReminders() async {
    try {
      final response = await _apiClient.get('/reminders');
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((json) => Reminder.fromJson(json)).toList();
      }
    } catch (e) {
      print("Lỗi lấy nhắc nhở: $e");
    }
    return [];
  }

  // 2. Thêm mới (Giữ nguyên logic)
  Future<bool> addReminder(String name, String instruction, TimeOfDay time) async {
    try {
      final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      final body = {
        'name': name,
        'instruction': instruction,
        'time': timeStr
      };
      final response = await _apiClient.post('/reminders', body);
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi thêm: $e");
      return false;
    }
  }

  // 3. Cập nhật (Giữ nguyên logic)
  Future<bool> updateReminder(int id, {String? name, String? instruction, TimeOfDay? time, bool? isActive}) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (instruction != null) body['instruction'] = instruction;
      if (isActive != null) body['isActive'] = isActive;

      if (time != null) {
        body['time'] = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }

      final response = await _apiClient.put('/reminders/$id', body);
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi cập nhật: $e");
      return false;
    }
  }

  // 4. Xóa
  Future<bool> deleteReminder(int id) async {
    try {
      final response = await _apiClient.delete('/reminders/$id');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}