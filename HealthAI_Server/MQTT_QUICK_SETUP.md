# MQTT Setup - Quick Guide

## 🎯 Hệ thống đơn giản

- **Frontend (App)**: Kết nối trực tiếp HiveMQ → Hiển thị real-time
- **Backend (Server)**: CHỈ xử lý khi có dữ liệu MỚI → Chẩn đoán → Cảnh báo → Lưu DB
- **Đồng bộ**: Cùng `packet_id` = Cùng dữ liệu

## 📡 HiveMQ Cloud

```
Host: 7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud
Port: 8883
Username: DoAn1
Password: Th123321

Topics:
- device/medical_data  // {temp, spo2, hr}
- device/ecg_data      // {device_id, packet_id, dataPoints[]}
```

## 🚀 Backend

**Files quan trọng:**
- `config/mqtt.js` - Cấu hình HiveMQ
- `services/mqtt_service.js` - Logic xử lý MQTT
- `database/migrations.sql` - Đã có bảng health_records, ecg_readings

**Khởi động:**
```bash
npm start
```

Backend sẽ tự động kết nối HiveMQ và xử lý dữ liệu mới.

## 📱 Frontend (Flutter)

### 1. Add package
```yaml
dependencies:
  mqtt_client: ^10.0.0
```

### 2. Get credentials
```dart
GET /api/mqtt-api/credentials
```

### 3. Connect & Subscribe
```dart
client = MqttServerClient.withPort(host, clientId, port);
client.secure = true;
await client.connect();
client.subscribe('device/medical_data', MqttQos.atLeastOnce);
client.subscribe('device/ecg_data', MqttQos.atLeastOnce);
```

### 4. Display data
```dart
client.updates!.listen((messages) {
  // Parse & update UI
  currentMedicalData = data;
  currentECGData = data;
});
```

## 🔔 Alerts (Socket.IO)

Backend tự động gửi cảnh báo:
```dart
socket.on('health_alert', (data) {
  showNotification(data['message']);
});
```

## 📊 API Endpoints

```
GET /api/mqtt-api/credentials        - MQTT credentials
GET /api/mqtt-api/status             - Connection status
GET /api/mqtt-api/health-records     - Lịch sử medical data
GET /api/mqtt-api/ecg-records        - Lịch sử ECG data
GET /api/mqtt-api/ecg/:packetId      - ECG theo packet_id
```

## ✅ Xem chi tiết

[MQTT_INTEGRATION_GUIDE.md](MQTT_INTEGRATION_GUIDE.md)

---

**Completed!** 🎉
