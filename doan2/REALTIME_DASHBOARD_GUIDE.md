# 🎯 Real-time Dashboard - Patient Health Monitoring

## ✅ Đã hoàn thành

Dashboard của Patient hiện đã hiển thị **dữ liệu real-time** từ MQTT HiveMQ Cloud!

### Tính năng Real-time:

#### 1. **Medical Metrics (SpO2, HR, Temperature)**
- ✅ StreamBuilder lắng nghe `_mqttService.healthStream`
- ✅ Tự động cập nhật khi có dữ liệu mới từ ESP32
- ✅ Hiển thị dữ liệu cuối cùng khi không có dữ liệu mới

#### 2. **ECG Chart (Điện tâm đồ)**
- ✅ StreamBuilder lắng nghe `_mqttService.ecgStream`
- ✅ Vẽ biểu đồ real-time với fl_chart
- ✅ Normalize dữ liệu từ ESP32 ADC (0-4095)
- ✅ Hiển thị packet_id và số điểm dữ liệu
- ✅ Live/Offline indicator

#### 3. **Connection Status**
- ✅ Indicator màu xanh (Live) / đỏ (Offline)
- ✅ Auto-reconnect khi mất kết nối
- ✅ Timestamp cập nhật cuối cùng

#### 4. **Health Alerts**
- ✅ Socket.IO listener cho health_alert
- ✅ Dialog popup với risk level (warning/danger/critical)
- ✅ Recommendations từ backend
- ✅ Quick action: "Liên hệ bác sĩ"

## 📊 Luồng dữ liệu

```
ESP32 Device
    ↓
    📡 Publish to HiveMQ Cloud
    ↓
    ├─→ Backend (Node.js)
    │   ├─ Lưu vào PostgreSQL
    │   ├─ Phân tích & chẩn đoán
    │   └─ Gửi alert qua Socket.IO (nếu có)
    │
    └─→ Flutter App (Direct connection)
        ├─ mqtt_service.dart subscribe topics
        ├─ StreamController emit dữ liệu
        └─ Dashboard UI auto-update
```

## 🎨 UI Components

### 1. Health Stats Grid
```dart
StreamBuilder<HealthMetric>(
  stream: _mqttService.healthStream,
  builder: (context, snapshot) {
    // Hiển thị SpO2, HR, Temperature, BP
    return _HealthStatsGrid(metric: health);
  },
)
```

### 2. ECG Chart
```dart
StreamBuilder<Map<String, dynamic>>(
  stream: mqttService.ecgStream,
  builder: (context, snapshot) {
    // Convert dataPoints[] → FlSpot[]
    // Normalize 0-4095 → 0-3 cho chart
    // Render LineChart
  },
)
```

## 🔧 Cấu hình

### MQTT Connection
```dart
// lib/service/mqtt_service.dart
final String _broker = '7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud';
final int _port = 8883;
final String _username = 'DoAn1';
final String _password = 'Th123321';
```

### Topics
```dart
final String _medicalDataTopic = 'device/medical_data';
final String _ecgDataTopic = 'device/ecg_data';
```

### Data Format

**Medical Data:**
```json
{
  "temp": 36.5,
  "spo2": 98,
  "hr": 75
}
```

**ECG Data:**
```json
{
  "device_id": "ESP32",
  "packet_id": 54065,
  "dataPoints": [2048, 2050, 2200, 2600, 2100, ...]
}
```

## 🚀 Test Dashboard

### 1. Start Backend
```bash
cd HealthAI_Server
node app.js
```

### 2. Run Flutter App
```bash
cd doan2
flutter run
```

### 3. Publish Test Data

**Option A: ESP32**
- Flash code lên ESP32
- Kết nối sensors (MAX30102, DS18B20, ECG sensor)
- ESP32 sẽ tự động publish

**Option B: MQTTX Client**
- Install MQTTX: https://mqttx.app
- Connect to HiveMQ Cloud
- Publish manual:

```json
// Topic: device/medical_data
{
  "temp": 37.2,
  "spo2": 96,
  "hr": 82
}

// Topic: device/ecg_data
{
  "device_id": "ESP32",
  "packet_id": 12345,
  "dataPoints": [2048, 2100, 2200, 2500, 2800, 2600, 2200, 2100, 2048]
}
```

## 📱 Screenshots Expected

### Normal State
```
┌─────────────────────────────────────┐
│  🟢 Live: Đang nhận dữ liệu         │
├─────────────────────────────────────┤
│  💧 SpO2    │  ❤️ Nhịp tim          │
│  98%        │  75 BPM               │
├─────────────┼───────────────────────┤
│  🌡️ Thân nhiệt │  🏃 Huyết áp       │
│  36.5°C      │  120/80 mmHg        │
└─────────────┴───────────────────────┘

┌─────────────────────────────────────┐
│  💚 Điện tâm đồ (ECG)  🟢 Live      │
│  Vừa xong | Packet: 54065 | 50 điểm │
├─────────────────────────────────────┤
│      /\     /\      /\              │
│   __/  \___/  \____/  \___          │
│                                     │
└─────────────────────────────────────┘
```

### Alert State
```
┌─────────────────────────────────────┐
│  ⚠️ Cảnh báo sức khỏe                │
├─────────────────────────────────────┤
│  Nhịp tim cao bất thường            │
│  Giá trị: 120 BPM                   │
│                                     │
│  Khuyến nghị:                       │
│  • Nghỉ ngơi ngay lập tức           │
│  • Thở sâu, bình tĩnh               │
│  • Liên hệ bác sĩ nếu kéo dài       │
├─────────────────────────────────────┤
│  [Đã hiểu]    [Liên hệ bác sĩ]     │
└─────────────────────────────────────┘
```

## 🐛 Troubleshooting

### Không hiển thị dữ liệu?

1. **Check MQTT Connection**
```dart
print(_mqttService.isConnected); // Should be true
```

2. **Check Stream**
```dart
_mqttService.healthStream.listen((data) {
  print('Received: $data');
});
```

3. **Check ESP32 Publishing**
- Mở Serial Monitor
- Kiểm tra log: "Published to device/medical_data"

### ECG Chart không vẽ?

```dart
// Check dataPoints
if (snapshot.hasData) {
  print('ECG Points: ${snapshot.data!['dataPoints'].length}');
}
```

### Alert không hiển thị?

```dart
// Check Socket.IO
_socketService.healthAlertStream.listen((alert) {
  print('Alert received: $alert');
});
```

## 🎯 Performance Tips

### 1. Throttle ECG Updates
Nếu ECG quá nhanh (>10 FPS), add throttle:

```dart
_mqttService.ecgStream
  .transform(StreamTransformer.fromHandlers(
    handleData: (data, sink) {
      // Chỉ emit mỗi 100ms
      sink.add(data);
    },
  ))
```

### 2. Limit ECG Points
```dart
// Trong _EcgChartCard
for (int i = 0; i < dataPoints.length && i < 100; i++) {
  // Chỉ vẽ 100 điểm đầu
}
```

### 3. Dispose Streams
```dart
@override
void dispose() {
  _mqttService.dispose();
  _socketService.disconnect();
  super.dispose();
}
```

## ✨ Next Features

- [ ] **History Charts**: Biểu đồ 7 ngày, 30 ngày
- [ ] **Export PDF**: In báo cáo sức khỏe
- [ ] **Share**: Chia sẻ với bác sĩ
- [ ] **Predictions**: AI dự đoán xu hướng
- [ ] **Offline Mode**: Lưu local khi mất mạng

## 📚 Related Files

- [mqtt_service.dart](lib/service/mqtt_service.dart) - MQTT client
- [patient_dashboard_screen.dart](lib/presentation/patient/dashboard/patient_dashboard_screen.dart) - Dashboard UI
- [health_model.dart](lib/models/patient/health_model.dart) - Data models
- [socket_service.dart](lib/service/socket_service.dart) - Socket.IO alerts

---

**Hoàn thành!** Dashboard hiện đã hiển thị dữ liệu real-time từ MQTT! 🎉
