# 🔔 HƯỚNG DẪN XỬ LÝ SENSOR WARNINGS - FLUTTER APP

## 📋 Tổng Quan

Hệ thống sensor validation đã được triển khai để **chỉ chẩn đoán khi dữ liệu thực sự đúng và đủ**. Khi phát hiện dữ liệu cảm biến không hợp lệ, server sẽ:
1. ❌ **Từ chối chẩn đoán** (không lưu kết quả sai vào database)
2. 🔔 **Gửi cảnh báo realtime** qua Socket.IO đến user
3. 📡 **Publish MQTT warning** về ESP32 để hiển thị LED cảnh báo
4. 💾 **Lưu lịch sử cảnh báo** vào database để user xem lại

---

## 🚨 Socket.IO Events - Realtime Warnings

### Event 1: `sensor_warning` (Vital Signs)
**Trigger**: Khi SpO2, Heart Rate, hoặc Temperature không hợp lệ

```dart
socket.on('sensor_warning', (data) {
  final warning = SensorWarning.fromJson(data);
  
  if (warning.type == 'vital_signs') {
    // Hiển thị notification cho user
    showNotification(
      title: '⚠️ Lỗi Cảm Biến',
      message: warning.message, // "Dữ liệu cảm biến không hợp lệ. Vui lòng kiểm tra thiết bị."
      severity: warning.severity, // 'warning'
    );
    
    // Hiển thị chi tiết vấn đề
    print('Details: ${warning.details}'); 
    // Example: "Cannot diagnose with invalid vital signs: Invalid SpO2: 0%, Invalid HR: 0 bpm"
    
    // Hiển thị data bị lỗi
    print('Invalid Data:');
    print('  SpO2: ${warning.data['spo2']}%'); // 0
    print('  HR: ${warning.data['heart_rate']} bpm'); // 0
    print('  Temp: ${warning.data['temperature']}°C'); // 29.4
  }
});
```

**Payload Structure**:
```json
{
  "type": "vital_signs",
  "message": "Dữ liệu cảm biến không hợp lệ. Vui lòng kiểm tra thiết bị.",
  "details": "Cannot diagnose with invalid vital signs: Invalid SpO2: 0%, Invalid HR: 0 bpm",
  "data": {
    "spo2": 0,
    "heart_rate": 0,
    "temperature": 29.4
  },
  "timestamp": "2026-01-04T10:30:00Z",
  "severity": "warning"
}
```

---

### Event 2: `sensor_warning` (ECG Signal)
**Trigger**: Khi tín hiệu ECG bị saturated hoặc flat line

```dart
socket.on('sensor_warning', (data) {
  final warning = SensorWarning.fromJson(data);
  
  if (warning.type == 'ecg_signal') {
    // Hiển thị notification cho user
    showNotification(
      title: '⚠️ Lỗi ECG',
      message: warning.message, // "Tín hiệu ECG không hợp lệ. Vui lòng kiểm tra điện cực dán."
      severity: warning.severity, // 'warning' or 'error'
    );
    
    // Hiển thị chi tiết vấn đề
    print('ECG Issue: ${warning.details}'); 
    // Example: "ECG signal saturated: 100/100 points maxed out"
    
    // Hiển thị ECG data info
    print('Device ID: ${warning.data['device_id']}');
    print('Packet ID: ${warning.data['packet_id']}');
    print('Datapoints: ${warning.data['datapoints_count']}'); // Should be 100
  }
});
```

**Payload Structure**:
```json
{
  "type": "ecg_signal",
  "message": "Tín hiệu ECG không hợp lệ. Vui lòng kiểm tra điện cực dán.",
  "details": "ECG signal saturated: 100/100 points maxed out",
  "data": {
    "device_id": "ESP32_001",
    "packet_id": "PKT_12345",
    "datapoints_count": 100
  },
  "timestamp": "2026-01-04T10:30:00Z",
  "severity": "error"
}
```

---

## 📊 REST API - Sensor Warnings History

### 1. GET `/api/sensor-warnings` - Lấy danh sách cảnh báo

**Query Parameters**:
```
?limit=50               // Số lượng records (default: 50)
&offset=0               // Phân trang (default: 0)
&warning_type=vital_signs|ecg_signal  // Lọc theo loại
&severity=info|warning|error|critical // Lọc theo mức độ
&resolved=true|false    // Lọc theo trạng thái đã xử lý
&device_id=ESP32_001    // Lọc theo thiết bị
```

**Request Example**:
```dart
final response = await http.get(
  Uri.parse('$baseUrl/api/sensor-warnings?limit=20&resolved=false'),
  headers: {'Authorization': 'Bearer $token'},
);

final data = json.decode(response.body);
final warnings = (data['data']['warnings'] as List)
    .map((w) => SensorWarning.fromJson(w))
    .toList();
```

**Response**:
```json
{
  "success": true,
  "data": {
    "warnings": [
      {
        "id": 123,
        "user_id": 1,
        "device_id": "ESP32_001",
        "warning_type": "vital_signs",
        "severity": "warning",
        "message": "Dữ liệu cảm biến không hợp lệ. Vui lòng kiểm tra thiết bị.",
        "details": "Cannot diagnose with invalid vital signs: Invalid SpO2: 0%",
        "sensor_data": {
          "spo2": 0,
          "heart_rate": 0,
          "temperature": 29.4
        },
        "resolved": false,
        "resolved_at": null,
        "created_at": "2026-01-04T10:30:00Z"
      }
    ],
    "pagination": {
      "total": 45,
      "limit": 20,
      "offset": 0,
      "has_more": true
    }
  }
}
```

---

### 2. GET `/api/sensor-warnings/summary` - Tóm tắt cảnh báo

**Query Parameters**:
```
?days=7  // Số ngày lấy thống kê (default: 7)
```

**Response**:
```json
{
  "success": true,
  "data": {
    "summary": [
      {
        "warning_type": "vital_signs",
        "severity": "warning",
        "count": 32,
        "unresolved_count": 5
      },
      {
        "warning_type": "ecg_signal",
        "severity": "error",
        "count": 13,
        "unresolved_count": 8
      }
    ],
    "recent_unresolved": [
      {
        "id": 123,
        "warning_type": "vital_signs",
        "severity": "warning",
        "message": "Dữ liệu cảm biến không hợp lệ...",
        "details": "Invalid SpO2: 0%",
        "created_at": "2026-01-04T10:30:00Z"
      }
    ],
    "period_days": 7
  }
}
```

---

### 3. PATCH `/api/sensor-warnings/:id/resolve` - Đánh dấu đã xử lý

```dart
final response = await http.patch(
  Uri.parse('$baseUrl/api/sensor-warnings/123/resolve'),
  headers: {'Authorization': 'Bearer $token'},
);
```

**Response**:
```json
{
  "success": true,
  "message": "Đã đánh dấu cảnh báo là đã xử lý",
  "data": {
    "id": 123,
    "resolved": true,
    "resolved_at": "2026-01-04T11:00:00Z"
  }
}
```

---

### 4. DELETE `/api/sensor-warnings/:id` - Xóa cảnh báo

```dart
final response = await http.delete(
  Uri.parse('$baseUrl/api/sensor-warnings/123'),
  headers: {'Authorization': 'Bearer $token'},
);
```

---

## 🎨 UI/UX Recommendations

### 1. Dashboard Widget - Sensor Status
```dart
class SensorStatusCard extends StatelessWidget {
  final List<SensorWarning> recentWarnings;

  Widget build(BuildContext context) {
    final hasIssues = recentWarnings.any((w) => !w.resolved);
    
    return Card(
      color: hasIssues ? Colors.orange.shade50 : Colors.green.shade50,
      child: ListTile(
        leading: Icon(
          hasIssues ? Icons.warning_amber : Icons.check_circle,
          color: hasIssues ? Colors.orange : Colors.green,
        ),
        title: Text(
          hasIssues 
            ? '⚠️ Có ${recentWarnings.length} vấn đề cảm biến'
            : '✅ Cảm biến hoạt động bình thường'
        ),
        subtitle: hasIssues 
          ? Text('Nhấn để xem chi tiết')
          : null,
        onTap: hasIssues 
          ? () => Navigator.push(context, SensorWarningsPage())
          : null,
      ),
    );
  }
}
```

### 2. Warning List Screen
```dart
class SensorWarningsPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lịch Sử Cảnh Báo Cảm Biến')),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final warning = warnings[index];
          return WarningListTile(warning: warning);
        },
      ),
    );
  }
}

class WarningListTile extends StatelessWidget {
  final SensorWarning warning;

  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _getIconForType(warning.type),
        color: _getColorForSeverity(warning.severity),
      ),
      title: Text(warning.message),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chi tiết: ${warning.details}'),
          Text('Thời gian: ${formatTime(warning.createdAt)}'),
        ],
      ),
      trailing: warning.resolved 
        ? Icon(Icons.check, color: Colors.green)
        : IconButton(
            icon: Icon(Icons.done),
            onPressed: () => _resolveWarning(warning.id),
          ),
    );
  }
}
```

### 3. Realtime Toast Notification
```dart
void setupSocketListeners() {
  socket.on('sensor_warning', (data) {
    final warning = SensorWarning.fromJson(data);
    
    // Show toast/snackbar
    Get.snackbar(
      '⚠️ Cảnh Báo Cảm Biến',
      warning.message,
      backgroundColor: Colors.orange.shade100,
      duration: Duration(seconds: 5),
      mainButton: TextButton(
        child: Text('Xem Chi Tiết'),
        onPressed: () => Navigator.push(
          context, 
          SensorWarningDetailPage(warning: warning)
        ),
      ),
    );
    
    // Play alert sound
    AudioPlayer().play('assets/sounds/warning.mp3');
    
    // Vibrate
    Vibration.vibrate(pattern: [0, 200, 100, 200]);
  });
}
```

---

## 📱 Data Model - Dart Class

```dart
class SensorWarning {
  final int id;
  final int userId;
  final String deviceId;
  final String warningType; // 'vital_signs' | 'ecg_signal'
  final String severity; // 'info' | 'warning' | 'error' | 'critical'
  final String message;
  final String details;
  final Map<String, dynamic> sensorData;
  final bool resolved;
  final DateTime? resolvedAt;
  final DateTime createdAt;

  SensorWarning({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.warningType,
    required this.severity,
    required this.message,
    required this.details,
    required this.sensorData,
    required this.resolved,
    this.resolvedAt,
    required this.createdAt,
  });

  factory SensorWarning.fromJson(Map<String, dynamic> json) {
    return SensorWarning(
      id: json['id'],
      userId: json['user_id'],
      deviceId: json['device_id'],
      warningType: json['warning_type'] ?? json['type'], // Handle both formats
      severity: json['severity'],
      message: json['message'],
      details: json['details'],
      sensorData: json['sensor_data'] ?? json['data'] ?? {},
      resolved: json['resolved'] ?? false,
      resolvedAt: json['resolved_at'] != null 
        ? DateTime.parse(json['resolved_at']) 
        : null,
      createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.parse(json['timestamp']), // Fallback to timestamp
    );
  }

  // Helper methods
  bool get isVitalSigns => warningType == 'vital_signs';
  bool get isECG => warningType == 'ecg_signal';
  bool get isCritical => severity == 'error' || severity == 'critical';
  
  String get displayTitle {
    if (isVitalSigns) return '⚠️ Lỗi Cảm Biến Vital Signs';
    if (isECG) return '⚠️ Lỗi Tín Hiệu ECG';
    return '⚠️ Cảnh Báo Cảm Biến';
  }
}
```

---

## 🔔 ESP32 MQTT Warnings

ESP32 cũng nhận được warnings qua MQTT topic: `health/device/{device_id}/warning`

**Payload Structure**:
```json
{
  "type": "sensor_error" | "ecg_sensor_error",
  "message": "Sensor data invalid" | "ECG signal quality poor",
  "details": "Invalid SpO2: 0%",
  "timestamp": "2026-01-04T10:30:00Z"
}
```

**ESP32 có thể**:
- Bật LED cảnh báo (đỏ nhấp nháy)
- Hiển thị message lên OLED/LCD
- Phát buzzer sound
- Tự động retry sensor initialization

---

## ✅ Validation Rules Reference

### Vital Signs Thresholds
| Parameter | Valid Range | Example Invalid | Warning Message |
|-----------|-------------|-----------------|-----------------|
| SpO2 | 1-100% | 0% | Invalid SpO2: 0% |
| Heart Rate | 1-250 bpm | 0 bpm | Invalid HR: 0 bpm |
| Temperature | 30-45°C | 29.4°C | Invalid Temp: 29.4°C |

### ECG Signal Quality
| Check | Condition | Reason |
|-------|-----------|--------|
| Flat Line | All values identical | Sensor not connected |
| Saturation | >80% max values (2047) | ADC maxed out, lead-off |
| Empty Data | No datapoints | Sensor initialization failed |

---

## 🚀 Implementation Checklist

Flutter App phải implement:
- [ ] Socket.IO listener cho event `sensor_warning`
- [ ] UI hiển thị realtime toast/snackbar khi nhận warning
- [ ] Screen hiển thị lịch sử sensor warnings
- [ ] API call để fetch warnings với pagination
- [ ] API call để resolve warnings
- [ ] Dashboard widget hiển thị trạng thái sensor
- [ ] Data model `SensorWarning` class
- [ ] Audio/Vibration alert cho critical warnings
- [ ] Filter warnings theo type/severity/device

---

## 📝 Notes

1. **Server chỉ chẩn đoán khi data hợp lệ** - Không có kết quả AI sai vào database
2. **User luôn được thông báo** - Realtime qua Socket.IO + lưu lịch sử trong DB
3. **ESP32 cũng nhận cảnh báo** - Có thể tự động fix hoặc hiển thị LED
4. **Warnings có thể resolve** - User đánh dấu đã sửa, không spam
5. **Traceability đầy đủ** - Lưu sensor_data để phân tích sau này

---

## 🔧 Troubleshooting

**Q: Không nhận được Socket.IO warnings?**
- Check Socket.IO connection status
- Verify `socket.on('sensor_warning')` listener đã setup
- Check user_id trong JWT token match với warning.user_id

**Q: API trả về warnings rỗng?**
- Verify token authentication
- Check database có records với user_id của bạn: `SELECT * FROM sensor_warnings WHERE user_id = X`
- Kiểm tra filters (resolved, warning_type, etc.)

**Q: Warning spam quá nhiều?**
- Server chỉ gửi 1 warning mỗi lần validation fail
- App có thể deduplicate dựa trên device_id + warning_type trong 5 phút
- Implement "Resolve All" để clear cùng lúc

---

Với hệ thống này, **người dùng sẽ luôn biết khi nào data không đủ tốt để chẩn đoán**, và có thể kiểm tra lịch sử để troubleshoot vấn đề ESP32 sensor! 🎯
