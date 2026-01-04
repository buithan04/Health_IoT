# ✅ MQTT Real-time Integration - Hoàn thành!

## 📊 Tổng quan hệ thống

### Backend (Node.js)
✅ **Server đang chạy:** http://localhost:5000
✅ **MQTT Connected:** 7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud:8883
✅ **Topics subscribed:**
- `device/medical_data` - Nhịp tim, SpO2, Nhiệt độ
- `device/ecg_data` - Dữ liệu ECG waveform
- `health/+/vitals` - Legacy support

### Frontend (Flutter)
✅ **Dashboard real-time:** StreamBuilder cho Medical & ECG
✅ **MQTT Service:** Kết nối trực tiếp HiveMQ
⚠️ **Đang fix:** Connection timeout issue

---

## 🔥 ESP32 đang publish dữ liệu!

### Log từ Backend:
```
📩 NEW Medical data: HR=0, SpO2=0, Temp=34.2°C
💾 Medical data saved: Record ID 17
⚠️ No user_id, skipping analysis

📊 NEW ECG data: Packet 42047, 100 points
💾 ECG data saved: Record ID 18, Packet 42047
⚠️ No user_id or data points, skipping ECG analysis
```

### ⚠️ Vấn đề hiện tại:

**1. ESP32 thiếu user_id:**
- Dữ liệu từ ESP32: `{ "temp": 34.2, "spo2": 0, "hr": 0 }`
- Cần thêm: `{ "user_id": 10, "temp": 34.2, "spo2": 0, "hr": 0 }`

**2. Sensors chưa kết nối:**
- HR = 0 (Cần MAX30102/MAX30100)
- SpO2 = 0 (Cần MAX30102/MAX30100)
- Temp = OK (DS18B20 hoạt động)

**3. Flutter MQTT timeout:**
- Error: `NoConnectionException: The maximum allowed connection attempts were exceeded`
- Fix: Đã tăng timeout lên 30s và maxConnectionAttempts = 5

---

## 🔧 Cần làm gì tiếp?

### 1. Fix ESP32 Code (QUAN TRỌNG!)

Thêm `user_id` vào ESP32 publish:

```cpp
// ESP32 - Thêm user_id
void publishMedicalData() {
    StaticJsonDocument<256> doc;
    doc["user_id"] = 10; // ← THÊM DÒNG NÀY
    doc["temp"] = temperature;
    doc["spo2"] = spo2;
    doc["hr"] = heartRate;
    
    char buffer[256];
    serializeJson(doc, buffer);
    mqtt_client.publish("device/medical_data", buffer);
}

void publishECGData() {
    StaticJsonDocument<2048> doc;
    doc["user_id"] = 10; // ← THÊM DÒNG NÀY
    doc["device_id"] = "ESP32";
    doc["packet_id"] = packetId++;
    
    JsonArray dataPoints = doc.createNestedArray("dataPoints");
    for (int i = 0; i < 100; i++) {
        dataPoints.add(ecgBuffer[i]);
    }
    
    char buffer[2048];
    serializeJson(doc, buffer);
    mqtt_client.publish("device/ecg_data", buffer);
}
```

### 2. Kết nối MAX30102 sensor

```
ESP32 Pin → MAX30102
----------------------
3.3V      → VIN
GND       → GND
GPIO21    → SDA
GPIO22    → SCL
```

### 3. Test Flutter App

```bash
cd doan2
flutter run
```

Khi vào Dashboard, bạn sẽ thấy:
- 🟢 Live indicator (khi connect)
- 📊 Medical metrics tự động update
- 📈 ECG chart real-time

---

## 📱 Dashboard Features

### Medical Metrics Card
```
┌─────────────────────────────────────┐
│ 🟢 Live: Đang nhận dữ liệu          │
├─────────────────────────────────────┤
│  💧 SpO2    │  ❤️ Nhịp tim          │
│  98%        │  75 BPM               │
├─────────────┼───────────────────────┤
│  🌡️ Thân nhiệt │  🏃 Huyết áp       │
│  36.5°C      │  0/0 mmHg           │
└─────────────┴───────────────────────┘
```

### ECG Chart
```
┌─────────────────────────────────────┐
│ 💚 Điện tâm đồ (ECG)  🟢 Live       │
│ Vừa xong | Packet: 42047 | 100 điểm │
├─────────────────────────────────────┤
│      /\     /\      /\              │
│   __/  \___/  \____/  \___          │
└─────────────────────────────────────┘
```

---

## 🎯 Luồng dữ liệu Real-time

```
ESP32 Device
    ↓ Publish
HiveMQ Cloud (7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud:8883)
    ↓
    ├──→ Backend (Node.js)
    │    ├─ Subscribe: device/medical_data, device/ecg_data
    │    ├─ Save to PostgreSQL
    │    ├─ Analyze health (nếu có user_id)
    │    └─ Send alert qua Socket.IO (nếu nguy hiểm)
    │
    └──→ Flutter App
         ├─ Subscribe: device/medical_data, device/ecg_data
         ├─ Stream to Dashboard UI
         └─ Auto-update real-time
```

---

## 🧪 Test với MQTTX

Nếu chưa có ESP32 hoạt động, test bằng MQTTX:

### Connect to HiveMQ:
- Host: `7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud`
- Port: `8883` (SSL/TLS)
- Username: `DoAn1`
- Password: `Th123321`

### Publish Test Data:

**Topic: `device/medical_data`**
```json
{
  "user_id": 10,
  "temp": 36.5,
  "spo2": 98,
  "hr": 75
}
```

**Topic: `device/ecg_data`**
```json
{
  "user_id": 10,
  "device_id": "ESP32",
  "packet_id": 12345,
  "dataPoints": [2048, 2100, 2200, 2500, 2800, 2600, 2200, 2100, 2048, 2050]
}
```

---

## 📊 Database Status

### Tables created:
✅ `health_records` - Medical data history
✅ `ecg_readings` - ECG waveform data

### Current data (từ ESP32):
- **18+ medical records** saved
- **18+ ECG readings** saved (100 points each)
- ⚠️ Chưa có analysis vì thiếu `user_id`

---

## 🚀 Next Steps

### Immediate (Cần làm ngay):
1. ✅ Thêm `user_id = 10` vào ESP32 code
2. ✅ Flash ESP32 với code mới
3. ✅ Test Flutter app - verify real-time data

### Short-term:
4. ⚡ Kết nối MAX30102 sensor (HR + SpO2)
5. 📊 Verify health analysis & alerts
6. 🔔 Test Socket.IO notifications

### Future enhancements:
7. 📈 History charts (7 days, 30 days)
8. 📄 Export health reports to PDF
9. 👨‍⚕️ Share with doctors
10. 🤖 AI predictions & insights

---

## ✅ Checklist

- [x] Backend MQTT service
- [x] HiveMQ Cloud connection
- [x] Database schema & migrations
- [x] Health analysis logic
- [x] Socket.IO alerts
- [x] Flutter MQTT service
- [x] Dashboard UI with StreamBuilder
- [x] Real-time ECG chart
- [ ] ESP32 send user_id
- [ ] MAX30102 sensor connection
- [ ] End-to-end testing
- [ ] Health alert notifications

---

**Status:** 🟡 Backend running, ESP32 publishing, Flutter needs connection fix

**Test khi nào:** Sau khi update ESP32 code với user_id và restart Flutter app

**Expected result:** Dashboard hiển thị dữ liệu real-time từ ESP32, health alerts xuất hiện khi metrics bất thường
