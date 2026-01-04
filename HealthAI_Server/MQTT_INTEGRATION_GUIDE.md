# MQTT Integration Guide - HiveMQ Cloud
## Hệ thống Đơn giản: Backend chỉ xử lý khi có dữ liệu mới

## 📋 Tổng quan

**Frontend (App)** kết nối trực tiếp với **HiveMQ Cloud** để nhận dữ liệu real-time.

**Backend (Server)** cũng lắng nghe HiveMQ nhưng CHỈ xử lý khi có dữ liệu MỚI:
- Lấy dữ liệu mới
- Chẩn đoán
- Gửi cảnh báo (nếu có bất thường)
- Lưu database

**Đồng bộ**: Cả Frontend và Backend lấy **cùng 1 bộ dữ liệu** từ HiveMQ (dựa vào `packet_id`)

---

## 🔧 Cấu hình HiveMQ Cloud

### Thông tin kết nối
```javascript
Host: 7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud
Port: 8883 (TLS/SSL)
Protocol: mqtts
Username: DoAn1
Password: Th123321
```

### Topics
```javascript
device/medical_data  // Dữ liệu y tế: {temp, spo2, hr}
device/ecg_data      // Dữ liệu ECG: {device_id, packet_id, dataPoints[]}
```

---

## 📡 Định dạng dữ liệu

### 1. Medical Data
```json
{
  "temp": 36.5,
  "spo2": 98,
  "hr": 75,
  "device_id": "ESP32",
  "user_id": 123
}
```

### 2. ECG Data
```json
{
  "device_id": "ESP32",
  "packet_id": 54065,
  "dataPoints": [0, 0, 614, 430, 301, ...],
  "user_id": 123
}
```

**Quan trọng**: `packet_id` dùng để đồng bộ - Backend và Frontend nhận cùng packet_id thì là cùng 1 bộ dữ liệu

---

## 🚀 Backend Setup

### Database
Database đã có sẵn trong `migrations.sql`:
- `health_records` - Lưu medical data
- `ecg_readings` - Lưu ECG data

Không cần tạo file migration riêng.

### Khởi động
```bash
cd HealthAI_Server
npm start
```

Backend sẽ:
1. Kết nối HiveMQ Cloud
2. Subscribe `device/medical_data` và `device/ecg_data`
3. **CHỈ** xử lý khi nhận dữ liệu mới (kiểm tra packet_id)
4. Phân tích → Cảnh báo → Lưu DB

### Logic xử lý dữ liệu mới

#### Medical Data
```javascript
// Server track last packet_id
if (dataHash === lastPacketId) {
  return; // Bỏ qua, không xử lý
}

// Dữ liệu mới → Xử lý
lastPacketId = dataHash;
// → Lưu DB
// → Phân tích
// → Gửi cảnh báo nếu có
```

#### ECG Data
```javascript
// Kiểm tra packet_id
if (packet_id === lastPacketId) {
  return; // Đã xử lý rồi
}

// Dữ liệu mới → Xử lý
lastPacketId = packet_id;
// → Lưu DB
// → Phân tích
// → Gửi cảnh báo nếu có
```

---

## 📱 Frontend (Flutter) Integration

### 1. Thêm MQTT package
```yaml
# pubspec.yaml
dependencies:
  mqtt_client: ^10.0.0
```

### 2. Kết nối trực tiếp HiveMQ
```dart
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  MqttServerClient? client;
  
  // Dữ liệu hiển thị hiện tại
  Map<String, dynamic>? currentMedicalData;
  Map<String, dynamic>? currentECGData;
  
  Future<void> connect() async {
    client = MqttServerClient.withPort(
      '7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud',
      'app_${DateTime.now().millisecondsSinceEpoch}',
      8883,
    );
    
    client!.secure = true;
    client!.keepAlivePeriod = 60;
    client!.autoReconnect = true;
    
    final connMessage = MqttConnectMessage()
        .authenticateAs('DoAn1', 'Th123321')
        .withWillQos(MqttQos.atLeastOnce)
        .startClean()
        .keepAliveFor(60);
    
    client!.connectionMessage = connMessage;
    
    try {
      await client!.connect();
      
      if (client!.connectionStatus!.state == MqttConnectionState.connected) {
        print('✅ Connected to HiveMQ');
        
        // Subscribe
        client!.subscribe('device/medical_data', MqttQos.atLeastOnce);
        client!.subscribe('device/ecg_data', MqttQos.atLeastOnce);
        
        // Listen
        client!.updates!.listen(_onMessage);
      }
    } catch (e) {
      print('❌ Connection failed: $e');
    }
  }
  
  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    final recMess = messages[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    final topic = messages[0].topic;
    
    final data = jsonDecode(payload);
    
    if (topic == 'device/medical_data') {
      _handleMedicalData(data);
    } else if (topic == 'device/ecg_data') {
      _handleECGData(data);
    }
  }
  
  void _handleMedicalData(Map<String, dynamic> data) {
    // Cập nhật dữ liệu hiển thị
    currentMedicalData = {
      'temp': data['temp'],
      'spo2': data['spo2'],
      'hr': data['hr'],
      'timestamp': DateTime.now(),
    };
    
    // Update UI
    print('Medical: HR=${data['hr']}, SpO2=${data['spo2']}, Temp=${data['temp']}');
    
    // Notify listeners (StreamController, setState, etc.)
    // _medicalDataController.add(currentMedicalData);
  }
  
  void _handleECGData(Map<String, dynamic> data) {
    final packetId = data['packet_id'];
    final dataPoints = List<int>.from(data['dataPoints']);
    
    // Cập nhật dữ liệu hiển thị
    currentECGData = {
      'packet_id': packetId,
      'dataPoints': dataPoints,
      'timestamp': DateTime.now(),
    };
    
    // Vẽ biểu đồ ECG
    print('ECG: Packet $packetId, ${dataPoints.length} points');
    
    // _ecgDataController.add(currentECGData);
  }
}
```

### 3. Hiển thị dữ liệu
```dart
// App luôn hiển thị dữ liệu mới nhất từ currentMedicalData/currentECGData
// Khi không có dữ liệu mới → Vẫn hiển thị dữ liệu cũ
// Khi có dữ liệu mới → Cập nhật UI

Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Nhịp tim: ${currentMedicalData?['hr'] ?? '--'} BPM'),
      Text('SpO2: ${currentMedicalData?['spo2'] ?? '--'}%'),
      Text('Nhiệt độ: ${currentMedicalData?['temp'] ?? '--'}°C'),
      
      // ECG Chart
      if (currentECGData != null)
        ECGChart(dataPoints: currentECGData!['dataPoints']),
    ],
  );
}
```

---

## 🔔 Nhận cảnh báo (Socket.IO)

Backend gửi cảnh báo qua Socket.IO khi phát hiện bất thường:

### Backend emit events:
```javascript
// Health alert
io.to(`user_${userId}`).emit('health_alert', {
  level: 'WARNING',
  type: 'HEART_RATE',
  message: 'Nhịp tim bất thường: 120 BPM',
  value: 120,
  timestamp: '2024-01-04T10:30:00Z'
});

// ECG alert
io.to(`user_${userId}`).emit('ecg_alert', {
  packet_id: 54065,
  suspicious_points: 8,
  message: 'Phát hiện tín hiệu ECG bất thường',
  timestamp: '2024-01-04T10:30:00Z'
});
```

### App listen:
```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket socket = IO.io('http://your-server:5000', {
  'transports': ['websocket'],
  'auth': {'token': token},
});

socket.on('health_alert', (data) {
  showNotification(
    title: 'Cảnh báo sức khỏe',
    body: data['message'],
  );
});

socket.on('ecg_alert', (data) {
  showNotification(
    title: 'Cảnh báo ECG',
    body: data['message'],
  );
});
```

---

## ⚡ Luồng dữ liệu

```
ESP32 Device
    │
    ↓ Publish
HiveMQ Cloud (device/medical_data, device/ecg_data)
    │
    ├──────────────────┬──────────────────┐
    ↓                  ↓                  ↓
Backend Server    Flutter App 1    Flutter App 2
    │                  │                  │
    │ (CHỈ khi MỚI)    │ (Real-time)      │ (Real-time)
    ↓                  ↓                  ↓
1. Check packet_id   Hiển thị ngay    Hiển thị ngay
2. Nếu mới:          trên UI          trên UI
   - Lưu DB
   - Phân tích
   - Cảnh báo
3. Nếu cũ:
   - Bỏ qua
    │
    ↓ (Nếu có cảnh báo)
Socket.IO → Tất cả Apps nhận thông báo
```

**Đồng bộ**: Cả Backend và App nhận cùng `packet_id` → Cùng 1 bộ dữ liệu

---

## 🎯 Ngưỡng cảnh báo

Cấu hình trong [config/mqtt.js](e:\Fluter\HealthAI_Server\config\mqtt.js):

- **Nhiệt độ**: 35-38.5°C (Nguy hiểm: <34 hoặc >40)
- **Nhịp tim**: 50-100 BPM (Nguy hiểm: <40 hoặc >150)
- **SpO2**: ≥90% (Nguy hiểm: <85%)
- **ECG**: Phát hiện ≥5 điểm bất thường liên tiếp

---

## 📝 API Endpoints

### Get MQTT Credentials
```http
GET /api/mqtt-api/credentials
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "host": "7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud",
    "port": 8883,
    "username": "DoAn1",
    "password": "Th123321",
    "topics": {
      "medicalData": "device/medical_data",
      "ecgData": "device/ecg_data"
    }
  }
}
```

### Get Recent Data
```http
GET /api/mqtt-api/health-records?limit=50
GET /api/mqtt-api/ecg-records?limit=20
Authorization: Bearer {token}
```

---

## 🐛 Troubleshooting

### Backend không xử lý dữ liệu
```bash
# Check logs - Bạn sẽ thấy:
⏭️ Medical data unchanged, skipping...
# hoặc
⏭️ ECG packet 54065 already processed, skipping...

# Đây là ĐÚNG - Backend chỉ xử lý dữ liệu MỚI
```

### App không nhận dữ liệu
```dart
// Check connection
print(client.connectionStatus);

// Enable logging
client.logging(on: true);
```

---

## 🎉 Tóm tắt

✅ **Frontend**: Kết nối trực tiếp HiveMQ → Hiển thị real-time
✅ **Backend**: Lắng nghe HiveMQ → CHỈ xử lý dữ liệu MỚI → Cảnh báo
✅ **Đồng bộ**: Cùng packet_id = Cùng dữ liệu
✅ **Database**: Đã có sẵn trong migrations.sql
✅ **Đơn giản**: Không cần cache, không cần API phức tạp

**Completed!** 🎉

---

## 🔧 Cấu hình HiveMQ Cloud

### Thông tin kết nối
```javascript
Host: 7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud
Port: 8883 (TLS/SSL)
Protocol: mqtts
Username: DoAn1
Password: Th123321
```

### Topics
```javascript
device/medical_data  // Dữ liệu y tế cơ bản
device/ecg_data      // Dữ liệu ECG
```

---

## 📡 Định dạng dữ liệu

### 1. Medical Data (device/medical_data)
```json
{
  "temp": 36.5,
  "spo2": 98,
  "hr": 75,
  "device_id": "ESP32",
  "user_id": 123  // Optional, app sẽ gửi sau
}
```

**Giải thích:**
- `temp`: Nhiệt độ cơ thể (°C)
- `spo2`: Nồng độ oxy trong máu (%)
- `hr`: Nhịp tim (BPM)
- `device_id`: ID thiết bị
- `user_id`: ID người dùng (optional, link sau)

### 2. ECG Data (device/ecg_data)
```json
{
  "device_id": "ESP32",
  "packet_id": 54065,
  "dataPoints": [0, 0, 614, 430, 301, ...],
  "user_id": 123  // Optional
}
```

**Giải thích:**
- `device_id`: ID thiết bị
- `packet_id`: ID gói tin duy nhất (dùng để đồng bộ)
- `dataPoints`: Mảng các điểm dữ liệu ECG (250Hz sampling rate)
- `user_id`: ID người dùng (optional)

---

## 🚀 Backend Setup

### 1. Cấu trúc Files
```
HealthAI_Server/
├── config/
│   └── mqtt.js               # Cấu hình MQTT
├── services/
│   └── mqtt_service.js       # Service xử lý MQTT
├── controllers/
│   └── mqtt_controller.js    # API controllers
├── routes/
│   └── mqtt.js               # API routes
└── database/
    └── migrations/
        └── create_ecg_records_table.sql
```

### 2. Chạy Migration
```bash
cd HealthAI_Server
node run_migrations.js
```

Hoặc chạy SQL trực tiếp:
```bash
psql -U your_user -d your_database -f database/migrations/create_ecg_records_table.sql
```

### 3. Khởi động Server
```bash
npm start
# hoặc
npm run dev
```

Server sẽ tự động:
- Kết nối với HiveMQ Cloud
- Subscribe topics: `device/medical_data` và `device/ecg_data`
- Bắt đầu nhận và xử lý dữ liệu

### 4. Kiểm tra kết nối
```bash
# Check logs
# Bạn sẽ thấy:
✅ MQTT Connected successfully to HiveMQ Cloud
✅ Subscribed to: device/medical_data (QoS 1)
✅ Subscribed to: device/ecg_data (QoS 1)
```

---

## 📱 App (Flutter) Integration

### 1. Thêm MQTT package
```yaml
# pubspec.yaml
dependencies:
  mqtt_client: ^10.0.0
```

### 2. Lấy credentials từ API
```dart
// Get MQTT credentials from backend
final response = await http.get(
  Uri.parse('$baseUrl/api/mqtt-api/credentials'),
  headers: {'Authorization': 'Bearer $token'},
);

final credentials = jsonDecode(response.body)['data'];
```

### 3. Kết nối MQTT trong App
```dart
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  MqttServerClient? client;
  
  Future<void> connect(Map<String, dynamic> credentials) async {
    // Create client
    client = MqttServerClient.withPort(
      credentials['host'],
      'healthai_app_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      credentials['port'],
    );
    
    client!.logging(on: true);
    client!.secure = true;
    client!.keepAlivePeriod = 60;
    client!.autoReconnect = true;
    
    // Setup connection message
    final connMessage = MqttConnectMessage()
        .authenticateAs(credentials['username'], credentials['password'])
        .withWillQos(MqttQos.atLeastOnce)
        .startClean()
        .keepAliveFor(60);
    
    client!.connectionMessage = connMessage;
    
    try {
      await client!.connect();
      
      if (client!.connectionStatus!.state == MqttConnectionState.connected) {
        print('✅ Connected to HiveMQ');
        
        // Subscribe to topics
        client!.subscribe('device/medical_data', MqttQos.atLeastOnce);
        client!.subscribe('device/ecg_data', MqttQos.atLeastOnce);
        
        // Listen to messages
        client!.updates!.listen(_onMessage);
      }
    } catch (e) {
      print('❌ Connection failed: $e');
      client!.disconnect();
    }
  }
  
  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    final recMess = messages[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    final topic = messages[0].topic;
    
    final data = jsonDecode(payload);
    
    if (topic == 'device/medical_data') {
      _handleMedicalData(data);
    } else if (topic == 'device/ecg_data') {
      _handleECGData(data);
    }
  }
  
  void _handleMedicalData(Map<String, dynamic> data) {
    // Update UI với dữ liệu mới
    final temp = data['temp'];
    final spo2 = data['spo2'];
    final hr = data['hr'];
    
    // TODO: Update your UI
    print('Medical: HR=$hr, SpO2=$spo2, Temp=$temp');
    
    // Link data to user (gọi API backend)
    _linkDataToUser();
  }
  
  void _handleECGData(Map<String, dynamic> data) {
    final packetId = data['packet_id'];
    final dataPoints = List<int>.from(data['dataPoints']);
    
    // TODO: Vẽ biểu đồ ECG
    print('ECG: Packet $packetId, ${dataPoints.length} points');
  }
  
  Future<void> _linkDataToUser() async {
    // Link dữ liệu với user_id trên backend
    await http.post(
      Uri.parse('$baseUrl/api/mqtt-api/link-data'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'device_id': 'ESP32',
        'timestamp_from': DateTime.now().subtract(Duration(seconds: 10)).toIso8601String(),
        'timestamp_to': DateTime.now().toIso8601String(),
      }),
    );
  }
}
```

---

## 🔔 Real-time Notifications (Socket.IO)

### Backend tự động emit events:

```javascript
// Medical data update
io.emit('medical_data_update', {
  temperature: 36.5,
  spo2: 98,
  heart_rate: 75,
  timestamp: '2024-01-04T10:30:00Z',
  cacheKey: 'medical_1234567890'
});

// ECG data update
io.emit('ecg_data_update', {
  device_id: 'ESP32',
  packet_id: 54065,
  dataPoints: [...],
  cacheKey: 'ecg_54065',
  timestamp: '2024-01-04T10:30:00Z'
});

// Health alert
io.to(`user_${userId}`).emit('health_alert', {
  level: 'WARNING',
  type: 'HEART_RATE',
  message: 'Nhịp tim bất thường: 120 BPM',
  value: 120,
  timestamp: '2024-01-04T10:30:00Z'
});

// ECG alert
io.to(`user_${userId}`).emit('ecg_alert', {
  packet_id: 54065,
  suspicious_points: 8,
  max_value: 2800,
  min_value: 0,
  timestamp: '2024-01-04T10:30:00Z'
});
```

### App listen Socket.IO events:

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket socket = IO.io('http://your-server:5000', <String, dynamic>{
  'transports': ['websocket'],
  'auth': {'token': token},
});

socket.on('medical_data_update', (data) {
  print('New medical data: $data');
  // Update UI
});

socket.on('health_alert', (data) {
  print('⚠️ Health Alert: ${data['message']}');
  // Show notification
});

socket.on('ecg_alert', (data) {
  print('⚠️ ECG Alert: Packet ${data['packet_id']}');
  // Show warning
});
```

---

## 🔍 API Endpoints

### 1. Get MQTT Credentials
```http
GET /api/mqtt-api/credentials
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "host": "7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud",
    "port": 8883,
    "protocol": "mqtts",
    "username": "DoAn1",
    "password": "Th123321",
    "topics": {
      "medicalData": "device/medical_data",
      "ecgData": "device/ecg_data"
    }
  }
}
```

### 2. Get MQTT Status
```http
GET /api/mqtt-api/status
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "isConnected": true,
    "lastProcessed": {
      "medicalData": {...},
      "ecgData": {...}
    },
    "cacheSize": 5
  }
}
```

### 3. Get Recent Health Records
```http
GET /api/mqtt-api/health-records?limit=50
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "heart_rate": 75,
      "spo2": 98,
      "temperature": 36.5,
      "device_id": "ESP32",
      "created_at": "2024-01-04T10:30:00Z"
    }
  ],
  "count": 50
}
```

### 4. Get Recent ECG Records
```http
GET /api/mqtt-api/ecg-records?limit=20
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "device_id": "ESP32",
      "packet_id": 54065,
      "data_points": [0, 0, 614, ...],
      "sample_rate": 250,
      "created_at": "2024-01-04T10:30:00Z"
    }
  ],
  "count": 20
}
```

### 5. Get ECG by Packet ID
```http
GET /api/mqtt-api/ecg/:packetId
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "id": 1,
    "device_id": "ESP32",
    "packet_id": 54065,
    "data_points": [0, 0, 614, ...],
    "sample_rate": 250,
    "created_at": "2024-01-04T10:30:00Z"
  }
}
```

### 6. Link Data to User
```http
POST /api/mqtt-api/link-data
Authorization: Bearer {token}
Content-Type: application/json

{
  "device_id": "ESP32",
  "timestamp_from": "2024-01-04T10:29:00Z",
  "timestamp_to": "2024-01-04T10:31:00Z"
}

Response:
{
  "success": true,
  "message": "Medical data linked to user",
  "linked_records": 5
}
```

---

## ⚡ Luồng dữ liệu

### Medical Data Flow
```
ESP32 Device
    ↓ (Publish)
device/medical_data
    ↓ (Subscribe)
┌─────────────────────┬──────────────────────┐
│   Backend Server    │    Flutter App       │
│   (Luồng 1)         │    (Luồng 2)         │
├─────────────────────┼──────────────────────┤
│ 1. Nhận data        │ 1. Nhận data         │
│ 2. Cache (30s)      │ 2. Hiển thị UI       │
│ 3. Lưu DB          │ 3. Gọi link API      │
│ 4. Phân tích        │                      │
│ 5. Gửi cảnh báo     │                      │
│    (nếu có)         │                      │
└─────────────────────┴──────────────────────┘
        ↓                       ↓
    Socket.IO ←─────────────────┘
    (Đồng bộ cảnh báo)
```

### ECG Data Flow
```
ESP32 Device
    ↓ (Publish with packet_id)
device/ecg_data
    ↓ (Subscribe)
┌─────────────────────┬──────────────────────┐
│   Backend Server    │    Flutter App       │
├─────────────────────┼──────────────────────┤
│ 1. Nhận data        │ 1. Nhận data         │
│ 2. Cache by         │ 2. Vẽ biểu đồ        │
│    packet_id        │ 3. So sánh packet_id │
│ 3. Lưu DB          │    với cache         │
│ 4. Phân tích ECG    │                      │
│ 5. Phát hiện        │                      │
│    bất thường       │                      │
└─────────────────────┴──────────────────────┘
        ↓ (Cùng packet_id)
    Đồng bộ đảm bảo!
```

---

## 🎯 Ngưỡng cảnh báo

### Nhiệt độ (Temperature)
- **Bình thường**: 35.0 - 38.5°C
- **Cảnh báo**: < 35.0°C hoặc > 38.5°C
- **Nguy hiểm**: < 34.0°C hoặc > 40.0°C

### Nhịp tim (Heart Rate)
- **Bình thường**: 50 - 100 BPM
- **Cảnh báo**: < 50 BPM hoặc > 100 BPM
- **Nguy hiểm**: < 40 BPM hoặc > 150 BPM

### SpO2 (Oxy máu)
- **Bình thường**: ≥ 90%
- **Cảnh báo**: < 90%
- **Nguy hiểm**: < 85%

### ECG
- **Biên độ bình thường**: 0 - 2500
- **Phát hiện bất thường**: ≥ 5 điểm liên tiếp ngoài ngưỡng

Có thể tùy chỉnh trong [config/mqtt.js](e:\Fluter\HealthAI_Server\config\mqtt.js)

---

## 🔒 Bảo mật

1. **MQTT qua TLS**: Port 8883 (mqtts://)
2. **Authentication**: Username/Password
3. **API Authentication**: JWT Token
4. **HTTPS**: Chỉ gửi credentials qua HTTPS
5. **User Isolation**: Socket.IO rooms theo user_id

---

## 🐛 Troubleshooting

### Backend không kết nối được MQTT
```bash
# Check logs
npm start

# Bạn sẽ thấy lỗi cụ thể:
❌ MQTT Connection Error: ...

# Kiểm tra:
1. Internet connection
2. HiveMQ credentials đúng không
3. Port 8883 có bị firewall chặn không
```

### App không nhận được dữ liệu
```dart
// Enable MQTT logging
client.logging(on: true);

// Check:
1. Credentials từ API đúng không
2. Topics subscribe đúng không
3. Internet connection
4. TLS certificate (Android cần config)
```

### Dữ liệu không đồng bộ
```javascript
// Kiểm tra packet_id/timestamp
GET /api/mqtt-api/cache/:cacheKey

// Nếu cache expired (>30s), data không còn
// App cần gọi API lấy từ DB thay vì cache
```

---

## 📊 Testing

### Test với MQTT Client (MQTTX)
```
1. Download MQTTX: https://mqttx.app/
2. Kết nối:
   - Host: 7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud
   - Port: 8883
   - Username: DoAn1
   - Password: Th123321
   - SSL/TLS: Enable
3. Publish test message:
   Topic: device/medical_data
   Payload: {"temp":36.5,"spo2":98,"hr":75}
4. Check backend logs
```

### Test APIs với Postman
```
1. Import collection (tạo từ endpoints trên)
2. Setup environment với JWT token
3. Test các endpoints
```

---

## 📝 Notes

1. **Cache lifetime**: 30 giây - điều chỉnh trong `config/mqtt.js`
2. **ECG data_points**: Có thể rất lớn, cân nhắc compress nếu cần
3. **Database size**: ECG data chiếm nhiều dung lượng, setup auto-cleanup
4. **Real-time**: Socket.IO + MQTT đảm bảo latency thấp
5. **Scalability**: HiveMQ Cloud hỗ trợ horizontal scaling

---

## 🆘 Support

Nếu có vấn đề, kiểm tra:
1. [Backend logs](e:\Fluter\HealthAI_Server\app.js)
2. [MQTT Service](e:\Fluter\HealthAI_Server\services\mqtt_service.js)
3. [Config](e:\Fluter\HealthAI_Server\config\mqtt.js)
4. HiveMQ Cloud console: https://console.hivemq.cloud/

---

**Completed!** 🎉
