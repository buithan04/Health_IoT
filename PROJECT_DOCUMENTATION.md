# 🏥 HEALTH IOT - TÀI LIỆU DỰ ÁN TỔNG HỢP

> **Hệ thống chăm sóc sức khỏe từ xa thông minh với AI, IoT và Telemedicine**

---

## 📑 MỤC LỤC

- [Tổng Quan Dự Án](#-tổng-quan-dự-án)
- [Kiến Trúc Hệ Thống](#-kiến-trúc-hệ-thống)
- [Công Nghệ Sử Dụng](#-công-nghệ-sử-dụng)
- [Các Module Chính](#-các-module-chính)
- [Luồng Dữ Liệu](#-luồng-dữ-liệu)
- [Tính Năng Nổi Bật](#-tính-năng-nổi-bật)
- [Bảo Mật](#-bảo-mật)
- [Tài Liệu Chi Tiết](#-tài-liệu-chi-tiết)
- [Roadmap](#-roadmap)

---

## 🎯 TỔNG QUAN DỰ ÁN

**Health IoT** là một hệ thống chăm sóc sức khỏe toàn diện kết hợp:

### Mục Tiêu
- 🏥 **Telemedicine**: Kết nối bệnh nhân - bác sĩ từ xa
- 📊 **IoT Monitoring**: Theo dõi sức khỏe real-time qua thiết bị đeo
- 🤖 **AI Diagnosis**: Chẩn đoán sơ bộ bằng Machine Learning
- 💊 **E-Prescription**: Kê đơn thuốc điện tử
- 📱 **Mobile-First**: Ứng dụng đa nền tảng (Android, iOS, Windows)

### Thành Phần Hệ Thống

```
┌─────────────────────────────────────────────────────────────┐
│                     HEALTH IOT ECOSYSTEM                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐    │
│  │   MOBILE APP │   │  WEB ADMIN   │   │  ESP32 IoT   │    │
│  │   (Flutter)  │   │  (Next.js)   │   │  (C++/MQTT)  │    │
│  └──────┬───────┘   └──────┬───────┘   └──────┬───────┘    │
│         │                  │                   │             │
│         └──────────────────┼───────────────────┘             │
│                            │                                 │
│                   ┌────────▼────────┐                        │
│                   │  BACKEND SERVER │                        │
│                   │   (Node.js)     │                        │
│                   ├─────────────────┤                        │
│                   │ • REST API      │                        │
│                   │ • Socket.IO     │                        │
│                   │ • MQTT Broker   │                        │
│                   │ • AI/ML Models  │                        │
│                   └────────┬────────┘                        │
│                            │                                 │
│              ┌─────────────┼─────────────┐                  │
│              │             │              │                  │
│     ┌────────▼───┐  ┌──────▼─────┐  ┌───▼────────┐         │
│     │ PostgreSQL │  │  HiveMQ    │  │ Cloudinary │         │
│     │ TimescaleDB│  │   Cloud    │  │  Firebase  │         │
│     └────────────┘  └────────────┘  └────────────┘         │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 🏗️ KIẾN TRÚC HỆ THỐNG

### Kiến Trúc Tổng Thể: **Microservices + IoT**

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT LAYER (Presentation)               │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  📱 Flutter Mobile App          🖥️ Next.js Web Admin        │
│  • Patient Interface            • Doctor/Admin Dashboard     │
│  • Doctor Interface             • Analytics & Reports        │
│  • Real-time Monitoring         • User Management            │
│  • Video Calling (Zego)         • System Configuration       │
│                                                               │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ HTTPS/WSS
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                 APPLICATION LAYER (Backend)                  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  🚀 Node.js + Express.js Server (Port 3000)                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  API Gateway                                          │   │
│  │  • Authentication (JWT)                               │   │
│  │  • Rate Limiting                                      │   │
│  │  • Request Validation                                 │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   REST API   │  │  Socket.IO   │  │ MQTT Client  │      │
│  │   Services   │  │   Gateway    │  │   Worker     │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                   │              │
│         └─────────────────┼───────────────────┘              │
│                           │                                  │
│         ┌─────────────────┴─────────────────┐               │
│         │                                    │               │
│  ┌──────▼───────┐                  ┌────────▼─────────┐     │
│  │   Business   │                  │   AI/ML Engine   │     │
│  │   Logic      │                  │                  │     │
│  │   Services   │                  │ • MLP Model      │     │
│  │              │                  │ • CNN Model      │     │
│  │ • Auth       │                  │ • TensorFlow.js  │     │
│  │ • Appointment│                  │ • Prediction     │     │
│  │ • Chat       │                  │ • Analysis       │     │
│  │ • Health     │                  │                  │     │
│  │ • Prescription                  └──────────────────┘     │
│  │ • Notification                                           │
│  └──────────────┘                                           │
│                                                               │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                    DATA LAYER (Storage)                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  🗄️  PostgreSQL 16 + TimescaleDB                            │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  • Users & Profiles          • Appointments          │   │
│  │  • Health Records            • Prescriptions         │   │
│  │  • IoT Data (Time-series)    • Chat Messages         │   │
│  │  • AI Predictions            • Notifications         │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
│  ☁️  External Services                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   HiveMQ     │  │  Cloudinary  │  │   Firebase   │      │
│  │   Cloud      │  │  (Images)    │  │   (FCM/Push) │      │
│  │  (MQTT)      │  │              │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                        │
                        │ MQTT Protocol
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                  IoT DEVICE LAYER                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  📡 ESP32 Health Monitor                                     │
│  • MAX30102 (Heart Rate, SpO2)                              │
│  • MLX90614 (Temperature)                                    │
│  • AD8232 (ECG Signal)                                       │
│  • WiFi + MQTT Publisher                                     │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 💻 CÔNG NGHỆ SỬ DỤNG

### Frontend Technologies

#### 📱 Mobile App (Flutter)
```yaml
Framework: Flutter 3.24.0+
Language: Dart 3.9+
Platforms: Android, iOS, Windows

Core Packages:
  - go_router: ^17.0.1           # Navigation
  - provider: ^6.1.5             # State management
  - socket_io_client: ^3.1.2     # Real-time chat
  - zego_uikit_prebuilt_call: 4.22.2  # Video calls
  - fl_chart: ^1.1.1             # Charts
  - firebase_messaging: ^16.1.0  # Push notifications
  - http: ^1.2.1                 # API client
```

#### 🖥️ Web Admin (Next.js)
```json
Framework: Next.js 14.2
Language: TypeScript 5.x
UI Library: React 18.3

Tech Stack:
  - Tailwind CSS + shadcn/ui     # Styling
  - TanStack Query               # Data fetching
  - TanStack Table               # Data tables
  - Radix UI                     # Components
  - Lucide React                 # Icons
```

### Backend Technologies

#### ⚡ API Server (Node.js)
```json
Runtime: Node.js 20.x
Framework: Express.js 4.19
Language: JavaScript ES6+

Core Dependencies:
  - pg: ^8.16.3                  # PostgreSQL client
  - socket.io: ^4.8.1            # WebSocket
  - mqtt: ^5.14.1                # MQTT protocol
  - jsonwebtoken: ^9.0.2         # JWT auth
  - bcrypt: ^6.0.0               # Password hashing
  - @tensorflow/tfjs-node: ^4.22.0  # AI/ML
  - firebase-admin: ^13.6.0      # FCM
  - cloudinary: ^2.8.0           # Image storage
  - nodemailer: ^7.0.10          # Email
  - node-cron: ^4.2.1            # Scheduled jobs
```

### Database & Storage

#### 🗄️ Database
```
Primary: PostgreSQL 16
Extension: TimescaleDB 2.0+ (Time-series data)

Features:
  - JSONB for flexible schemas
  - Full-text search
  - Hypertables for IoT data
  - Continuous aggregates
  - Data retention policies
```

#### ☁️ Cloud Services
```
HiveMQ Cloud:
  - MQTT broker for IoT devices
  - TLS/SSL encryption
  - QoS levels 0,1,2

Cloudinary:
  - Image/file storage
  - On-the-fly transformations
  - CDN delivery

Firebase:
  - Cloud Messaging (FCM)
  - Push notifications
  - Analytics
```

### IoT Technologies

#### 📡 ESP32 Firmware
```cpp
Platform: ESP32 DevKit v1
Framework: Arduino + PlatformIO
Language: C++11

Libraries:
  - WiFi.h                 # WiFi connectivity
  - PubSubClient.h         # MQTT client
  - ArduinoJson.h          # JSON parsing
  - Wire.h                 # I2C communication
  
Sensors:
  - MAX30102: Heart rate, SpO2 (I2C)
  - MLX90614: Temperature (I2C)
  - AD8232: ECG signal (Analog)

Communication:
  - MQTT over TLS (Port 8883)
  - JSON payload format
  - Publish interval: 500ms
```

### AI/ML Technologies

#### 🤖 Machine Learning Models
```
Framework: TensorFlow.js Node

Model 1: Heart Disease Prediction
  - Type: MLP (Multi-Layer Perceptron)
  - Input: 11 features
  - Output: Risk level (0-2)
  - Accuracy: 89.3%
  - Features: Age, HR, SpO2, Temp, BP, BMI, etc.

Model 2: ECG Classification
  - Type: CNN (Convolutional Neural Network)
  - Input: 187 ECG samples
  - Output: 5 classes
  - Classes: Normal, PVC, PAC, RBBB, LBBB
```

---

## 🔧 CÁC MODULE CHÍNH

### 1️⃣ HealthAI_Server (Backend API)

**Đường dẫn**: `e:\Fluter\HealthAI_Server\`

**Mô tả**: Backend API server xử lý toàn bộ business logic, authentication, database, AI/ML, và real-time communication.

**Chi tiết**: [Xem tài liệu đầy đủ](./HealthAI_Server/DOCUMENTATION.md)

**Thư mục chính**:
```
HealthAI_Server/
├── config/           # Cấu hình (DB, MQTT, email, etc.)
├── controllers/      # Request handlers (API endpoints)
├── middleware/       # Auth, validation, error handling
├── models/           # Database models & queries
├── routes/           # API routing
├── services/         # Business logic layer
├── workers/          # Background jobs (MQTT, cron)
├── database/         # Migrations & seed data
├── app.js            # Express app entry
└── socket_manager.js # Socket.IO configuration
```

**Port**: 3000 (HTTP), WebSocket

**API Endpoints**: 100+ endpoints

**Tính năng chính**:
- ✅ RESTful API với JWT authentication
- ✅ Socket.IO real-time messaging
- ✅ MQTT worker thu thập IoT data
- ✅ AI/ML prediction service
- ✅ Cron jobs tự động
- ✅ Email & push notifications

---

### 2️⃣ App (Flutter Mobile Application)

**Đường dẫn**: `e:\Fluter\App\`

**Mô tả**: Ứng dụng di động đa nền tảng cho bệnh nhân và bác sĩ.

**Chi tiết**: [Xem tài liệu đầy đủ](./App/DOCUMENTATION.md)

**Cấu trúc**:
```
App/lib/
├── config/           # App configuration
├── core/             # Core utilities, API client
├── models/           # Data models (User, Appointment, etc.)
├── presentation/     # UI layers
│   ├── screens/      # App screens
│   ├── widgets/      # Reusable widgets
│   └── providers/    # State management
├── service/          # Services (Socket, Zego, Auth)
└── main.dart         # Entry point
```

**Platforms**: Android (API 23+), iOS (13.0+), Windows (10+)

**Tính năng chính**:
- ✅ Đăng ký/Đăng nhập (Patient & Doctor)
- ✅ Đặt lịch khám với bác sĩ
- ✅ Video call HD (ZegoCloud)
- ✅ Real-time chat (Socket.IO)
- ✅ Theo dõi sức khỏe real-time (MQTT)
- ✅ AI chẩn đoán sơ bộ
- ✅ E-prescription
- ✅ Medication reminders
- ✅ Health trend charts

---

### 3️⃣ ESP32_firmware (IoT Health Monitor)

**Đường dẫn**: `e:\Fluter\ESP32_firmware\`

**Mô tả**: Firmware cho thiết bị đeo theo dõi sức khỏe dựa trên ESP32.

**Chi tiết**: [Xem tài liệu đầy đủ](./ESP32_firmware/DOCUMENTATION.md)

**Cấu trúc**:
```
ESP32_firmware/
├── src/
│   ├── main.cpp           # Main program
│   └── ecg_monitor.py     # ECG testing script
├── include/
│   └── web_interface.h    # WiFi config web UI
├── platformio.ini         # PlatformIO config
└── lib/                   # External libraries
```

**Hardware**:
- **MCU**: ESP32 DevKit v1 (240MHz dual-core)
- **Sensors**:
  - MAX30102: Heart rate & SpO2 (I2C)
  - MLX90614: Non-contact temperature (I2C)
  - AD8232: ECG signal (Analog ADC)
- **Communication**: WiFi + MQTT

**Chức năng**:
- ✅ Đo nhịp tim real-time (BPM)
- ✅ Đo nồng độ oxy máu (SpO2 %)
- ✅ Đo nhiệt độ cơ thể (°C)
- ✅ Ghi tín hiệu ECG (125Hz sampling)
- ✅ Web interface cấu hình WiFi
- ✅ MQTT publish data (500ms interval)
- ✅ LED status indicator

**MQTT Topics**:
```
health/medical/data     → {userID, temp, spo2, hr}
health/ecg/data         → {userID, device_id, packet_id, dataPoints[]}
```

---

### 4️⃣ Web_admin (Admin Dashboard)

**Đường dẫn**: `e:\Fluter\Web_admin\`

**Mô tả**: Dashboard quản trị hệ thống cho admin và bác sĩ.

**Chi tiết**: [Xem tài liệu đầy đủ](./Web_admin/DOCUMENTATION.md)

**Tech Stack**:
- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS + shadcn/ui
- TanStack Query & Table

**Tính năng chính**:
- ✅ Dashboard analytics tổng quan
- ✅ Quản lý users (patients, doctors)
- ✅ Quản lý appointments
- ✅ Xem health records & IoT data
- ✅ Quản lý prescriptions
- ✅ System logs & monitoring
- ✅ Export reports (PDF, Excel)

---

## 🔄 LUỒNG DỮ LIỆU

### Luồng 1: IoT Data Flow (Real-time Monitoring)

```
┌─────────────┐
│   ESP32     │  1. Đọc cảm biến mỗi 500ms
│   Device    │  • Heart Rate: 75 BPM
└──────┬──────┘  • SpO2: 98%
       │         • Temperature: 36.5°C
       │ 2. MQTT Publish
       │ Topic: health/medical/data
       │ Payload: {"userID":10, "hr":75, "spo2":98, "temp":36.5}
       ▼
┌─────────────────┐
│   HiveMQ Cloud  │  3. MQTT Broker
│   Broker        │  • QoS: 1 (At least once)
└──────┬──────────┘
       │ 4. Subscribe
       ▼
┌─────────────────────┐
│  Backend Server     │  5. MQTT Worker nhận data
│  mqtt_worker.js     │  • Parse JSON
└──────┬──────────────┘  • Validate data
       │
       │ 6. Lưu vào DB
       ▼
┌─────────────────────┐
│   PostgreSQL        │  7. INSERT INTO health_records
│   TimescaleDB       │  (user_id, heart_rate, spo2, temperature)
└──────┬──────────────┘
       │
       │ 8. AI Prediction
       ▼
┌─────────────────────┐
│  TensorFlow.js      │  9. Run MLP Model
│  MLP Model          │  • Input: [hr, spo2, temp, ...]
└──────┬──────────────┘  • Output: Risk Level
       │
       │ 10. Nếu High Risk → Alert
       ▼
┌─────────────────────┐
│  Notification       │  11. Gửi cảnh báo
│  Service            │  • Socket.IO → Mobile App
└──────┬──────────────┘  • FCM Push → Device
       │
       │ 12. Real-time update
       ▼
┌─────────────────────┐
│   Mobile App        │  13. Hiển thị kết quả
│   (Patient)         │  • Chart update
└─────────────────────┘  • Alert notification
```

**Thời gian xử lý**: < 1 second (end-to-end)

---

### Luồng 2: Appointment Booking Flow

```
┌─────────────────┐
│  Patient App    │  1. Tìm kiếm bác sĩ
└──────┬──────────┘  • Chuyên khoa: Tim mạch
       │             • Ngày: 2026-01-10
       │ 2. GET /api/doctors?specialty=cardiology
       ▼
┌─────────────────────┐
│  Backend API        │  3. Query database
│  doctor_controller  │  SELECT * FROM doctors
└──────┬──────────────┘  WHERE specialty = 'Cardiology'
       │
       │ 4. Response: Danh sách bác sĩ
       ▼
┌─────────────────┐
│  Patient App    │  5. Chọn bác sĩ & slot time
└──────┬──────────┘  • Doctor: Dr. Nguyễn Văn A
       │             • Time: 10:00 - 10:30
       │ 6. POST /api/appointments
       │ Body: {doctor_id, date, time_slot, type}
       ▼
┌─────────────────────┐
│  Backend API        │  7. Validate
│  appointment_service│  • Check doctor availability
└──────┬──────────────┘  • Check conflicts
       │
       │ 8. Nếu valid → Create appointment
       ▼
┌─────────────────────┐
│   PostgreSQL        │  9. INSERT INTO appointments
└──────┬──────────────┘  Status: 'PENDING'
       │
       │ 10. Send notifications
       ▼
┌─────────────────────┐
│  Notification       │  11. Gửi thông báo
│  Service            │  • Patient: Booking success
└──────┬──────────────┘  • Doctor: New appointment
       │
       │ 12. Real-time update
       ▼
┌──────────────┬──────────────┐
│ Patient App  │  Doctor App  │  13. UI update
└──────────────┴──────────────┘
```

---

### Luồng 3: Video Call Flow

```
┌─────────────────┐
│  Doctor App     │  1. Initiate call
└──────┬──────────┘  • Call patient_id: 25
       │
       │ 2. Socket.IO emit
       │ Event: 'video_call_request'
       ▼
┌─────────────────────┐
│  Backend Server     │  3. Route to patient room
│  Socket.IO          │  io.to(`user_25`).emit(...)
└──────┬──────────────┘
       │
       │ 4. Forward request
       ▼
┌─────────────────┐
│  Patient App    │  5. Nhận incoming call
└──────┬──────────┘  • Hiển thị popup
       │             • Play ringtone
       │ 6. Accept call
       │ Socket.IO emit: 'video_call_accepted'
       ▼
┌─────────────────────┐
│  Backend Server     │  7. Lưu call history
│  call_history_service│ INSERT INTO call_history
└──────┬──────────────┘
       │
       │ 8. Trả về Zego credentials
       ▼
┌──────────────┬──────────────┐
│ Doctor App   │  Patient App │  9. Connect to Zego
└──────┬───────┴──────┬───────┘
       │              │ 10. ZegoCloud SDK
       │              │ • App ID: xxx
       │              │ • Room ID: call_123
       │              │ • Token: yyy
       ▼              ▼
┌─────────────────────────────┐
│     ZegoCloud Server        │  11. P2P Video Stream
│     (External)              │  • Video codec: H.264
└─────────────────────────────┘  • Audio codec: Opus
                                  • Bitrate: Auto-adaptive
```

---

### Luồng 4: AI Diagnosis Flow

```
┌─────────────────┐
│  MQTT Worker    │  1. Nhận vital signs từ ESP32
└──────┬──────────┘  {userID: 10, hr: 110, spo2: 88, temp: 38.2}
       │
       │ 2. Lưu raw data
       ▼
┌─────────────────────┐
│   PostgreSQL        │  3. INSERT health_records
└──────┬──────────────┘
       │
       │ 4. Trigger AI prediction
       ▼
┌─────────────────────┐
│  Predict Service    │  5. Lấy thêm dữ liệu user
│  predict_service.js │  • Age, Gender, Medical history
└──────┬──────────────┘
       │
       │ 6. Feature engineering
       ▼
┌─────────────────────┐
│  Feature Vector     │  7. Tính toán features
│                     │  • BMI = weight / (height^2)
└──────┬──────────────┘  • MAP = (SYS + 2*DIA) / 3
       │                  • Age group, etc.
       │ 8. Normalize (StandardScaler)
       ▼
┌─────────────────────┐
│  TensorFlow.js      │  9. Load MLP model
│  MLP Model          │  • Input: [11 features]
└──────┬──────────────┘  • Hidden layers: [64, 32]
       │                  • Output: [3 classes]
       │ 10. Predict
       ▼
┌─────────────────────┐
│  Prediction Result  │  11. Parse output
│                     │  • Class 0: Low Risk (0.1)
└──────┬──────────────┘  • Class 1: Medium Risk (0.2)
       │                  • Class 2: High Risk (0.7) ✓
       │
       │ 12. Save result
       ▼
┌─────────────────────┐
│   PostgreSQL        │  13. INSERT ai_predictions
│                     │  (record_id, model, result, confidence)
└──────┬──────────────┘
       │
       │ 14. Nếu High Risk → Send alert
       ▼
┌─────────────────────┐
│  Notification       │  15. Gửi cảnh báo khẩn cấp
│  Service            │  • Socket.IO real-time
└──────┬──────────────┘  • FCM push notification
       │                  • Email alert (optional)
       │
       ▼
┌─────────────────┐
│  Patient App    │  16. Hiển thị cảnh báo
└─────────────────┘  • Alert banner
                      • Recommendation
```

---

## ⭐ TÍNH NĂNG NỔI BẬT

### 1. Real-time IoT Monitoring

**Mô tả**: Theo dõi các chỉ số sức khỏe theo thời gian thực từ thiết bị đeo ESP32.

**Công nghệ**:
- ESP32 → MQTT → Backend → Socket.IO → Mobile App
- Latency: < 1 second
- Sampling rate: 2Hz (500ms)

**Chỉ số theo dõi**:
| Metric | Range | Unit | Sensor |
|--------|-------|------|--------|
| Heart Rate | 40-200 | BPM | MAX30102 |
| SpO2 | 70-100 | % | MAX30102 |
| Temperature | 35-42 | °C | MLX90614 |
| ECG Signal | 0-3.3V | mV | AD8232 |

**Alert Thresholds**:
```javascript
{
  heart_rate: { min: 50, max: 120 },
  spo2: { min: 90, max: 100 },
  temperature: { min: 36, max: 38 }
}
```

---

### 2. AI-Powered Health Prediction

**Model 1: Heart Disease Risk (MLP)**

```
Input Features (11):
  1. Age
  2. Gender
  3. Heart Rate
  4. SpO2
  5. Temperature
  6. Systolic BP
  7. Diastolic BP
  8. BMI (calculated)
  9. MAP (calculated)
  10. Pulse Pressure (calculated)
  11. Age Group (encoded)

Output Classes:
  0: Low Risk (Safe)
  1: Medium Risk (Monitor)
  2: High Risk (Alert) ⚠️

Performance:
  - Accuracy: 89.3%
  - Precision: 87.2%
  - Recall: 91.5%
  - F1-Score: 89.3%
```

**Model 2: ECG Classification (CNN)**

```
Input: 187 ECG samples (time-series)
Architecture:
  - Conv1D layers
  - MaxPooling
  - Dense layers
  - Dropout for regularization

Output Classes (5):
  0: Normal Sinus Rhythm
  1: Premature Ventricular Contraction (PVC)
  2: Premature Atrial Contraction (PAC)
  3: Right Bundle Branch Block (RBBB)
  4: Left Bundle Branch Block (LBBB)

Accuracy: 95.8%
```

---

### 3. Video Consultation (ZegoCloud)

**Features**:
- ✅ HD Video (720p/1080p)
- ✅ Clear Audio (Opus codec)
- ✅ Screen Sharing
- ✅ Virtual Background
- ✅ Recording (optional)
- ✅ Chat in-call

**Call Flow**:
1. Doctor initiates call
2. Backend validates & logs
3. Patient receives notification
4. Accept → Connect to Zego room
5. P2P streaming starts
6. Call ends → Save history & duration

**Tech Specs**:
```
SDK: zego_uikit_prebuilt_call 4.22.2
Protocol: WebRTC
Codec: H.264 (video), Opus (audio)
Bitrate: Adaptive (500kbps - 2Mbps)
Latency: < 200ms
```

---

### 4. Real-time Chat (Socket.IO)

**Features**:
- ✅ 1-on-1 messaging (Patient ↔ Doctor)
- ✅ Text, Image, File sharing
- ✅ Typing indicators
- ✅ Read receipts
- ✅ Message history
- ✅ Unread count badges

**Message Types**:
```javascript
{
  TEXT: "Hello doctor",
  IMAGE: "image_url",
  FILE: "file_url",
  PRESCRIPTION: "prescription_id",
  APPOINTMENT: "appointment_id"
}
```

**Real-time Events**:
```javascript
// Client → Server
socket.emit('send_message', { to, message, type });
socket.emit('typing', { to, isTyping: true });

// Server → Client
socket.on('new_message', (message) => { ... });
socket.on('user_typing', ({ from, isTyping }) => { ... });
```

---

### 5. E-Prescription System

**Workflow**:
1. Doctor creates prescription after consultation
2. Select medications from database (10,000+ drugs)
3. Add dosage, frequency, duration, notes
4. Digital signature (Doctor ID)
5. Save to database
6. Patient receives notification
7. View in app or download PDF

**Medication Database**:
- 10,000+ medications
- Vietnamese drug registry
- Generic & brand names
- Dosage forms, strengths
- Manufacturer info
- Active ingredients

**Prescription Fields**:
```sql
{
  id: UUID,
  patient_id: INT,
  doctor_id: INT,
  appointment_id: INT,
  diagnosis: TEXT,
  items: [
    {
      medication_id: INT,
      dosage: "500mg",
      frequency: "2 lần/ngày",
      duration: "7 ngày",
      quantity: 14,
      instructions: "Uống sau ăn"
    }
  ],
  notes: TEXT,
  created_at: TIMESTAMP
}
```

---

### 6. Medication Reminders

**Features**:
- ✅ Multiple medications
- ✅ Custom schedules (daily, weekly)
- ✅ Push notifications
- ✅ Mark as taken/skipped
- ✅ Adherence tracking
- ✅ Low stock alerts

**Reminder Logic**:
```javascript
Frequency Options:
  - Once daily (8:00 AM)
  - Twice daily (8:00 AM, 8:00 PM)
  - Three times (8:00 AM, 1:00 PM, 8:00 PM)
  - Four times (6:00 AM, 12:00 PM, 6:00 PM, 10:00 PM)
  - Custom time

Notification:
  - 15 minutes before scheduled time
  - Sound + Vibration
  - Persistent until acknowledged
```

---

### 7. Health Analytics & Charts

**Metrics Tracked**:
- Heart Rate trend (7/30/90 days)
- SpO2 trend
- Temperature trend
- Blood Pressure trend
- Weight/BMI trend
- AI Risk score history

**Chart Types**:
```
Line Chart: Time-series data
Bar Chart: Daily/weekly averages
Pie Chart: Risk distribution
Gauge Chart: Current status
```

**Export Options**:
- PDF report
- CSV data
- Share with doctor

---

## 🔐 BẢO MẬT

### Authentication & Authorization

**JWT-based Authentication**:
```javascript
Token Structure:
{
  header: { alg: "HS256", typ: "JWT" },
  payload: {
    userId: 123,
    email: "user@example.com",
    role: "PATIENT", // or "DOCTOR"
    iat: 1704451200,
    exp: 1704537600  // 24h expiry
  },
  signature: "..."
}

Access Control:
  - PATIENT: Own data only
  - DOCTOR: Assigned patients
  - ADMIN: Full access
```

**Password Security**:
- Hashing: bcrypt (salt rounds: 10)
- Min length: 8 characters
- Reset via email OTP (5-minute expiry)

---

### Data Encryption

**In Transit**:
```
HTTPS: TLS 1.3
MQTT: TLS/SSL on port 8883
WebSocket: WSS (Secure WebSocket)
Database: SSL connection
```

**At Rest**:
```
Database:
  - Sensitive fields encrypted (AES-256)
  - Passwords: bcrypt hashed
  
Files:
  - Cloudinary: Encrypted storage
  - Access control: Signed URLs
```

---

### MQTT Security

**HiveMQ Cloud Config**:
```javascript
{
  host: "xxx.s1.eu.hivemq.cloud",
  port: 8883,  // TLS/SSL
  protocol: "mqtts",
  username: "DoAn1",
  password: "Th123321",
  rejectUnauthorized: true,
  qos: 1  // At least once delivery
}
```

**Topic Access Control**:
```
Publish:
  - Devices only: health/medical/data, health/ecg/data

Subscribe:
  - Backend only: health/+/data
```

---

### API Security

**Rate Limiting**:
```javascript
{
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 100,  // Max 100 requests per window
  message: "Too many requests"
}
```

**Input Validation**:
- All inputs sanitized
- SQL injection prevention (parameterized queries)
- XSS prevention (escape HTML)
- File upload validation (type, size)

**CORS Policy**:
```javascript
{
  origin: [
    "http://localhost:3001",  // Next.js dev
    "app://health-iot",       // Flutter app
    "https://admin.healthiot.com"
  ],
  credentials: true
}
```

---

## 📚 TÀI LIỆU CHI TIẾT

Mỗi module có tài liệu riêng chi tiết:

### Backend
- **[HealthAI_Server/DOCUMENTATION.md](./HealthAI_Server/DOCUMENTATION.md)**
  - Cấu trúc thư mục
  - API endpoints chi tiết
  - Database schema
  - Services & business logic
  - Background workers
  - Deployment guide

### Mobile App
- **[App/DOCUMENTATION.md](./App/DOCUMENTATION.md)**
  - Project structure
  - Screen flows
  - State management
  - API integration
  - Socket.IO & MQTT
  - Build & release

### IoT Firmware
- **[ESP32_firmware/DOCUMENTATION.md](./ESP32_firmware/DOCUMENTATION.md)**
  - Hardware setup
  - Sensor integration
  - WiFi configuration
  - MQTT implementation
  - Power management
  - Troubleshooting

### Admin Dashboard
- **[Web_admin/DOCUMENTATION.md](./Web_admin/DOCUMENTATION.md)**
  - UI components
  - Data fetching
  - Authentication
  - Analytics dashboard
  - Deployment

---

## 🚀 ROADMAP

### Version 1.0 (Current) ✅
- ✅ Core telemedicine features
- ✅ IoT real-time monitoring
- ✅ AI health prediction (MLP)
- ✅ Video calling
- ✅ E-prescription
- ✅ Medication reminders

### Version 1.1 (Q1 2026) 🔜
- 🔜 ECG CNN model integration
- 🔜 Group chat (Doctor ↔ Multiple patients)
- 🔜 Family account linking
- 🔜 Health insurance integration
- 🔜 Multi-language support (English, Vietnamese)

### Version 2.0 (Q2 2026) 📋
- 📋 Wearable integration (Apple Watch, Fitbit)
- 📋 Blockchain for medical records
- 📋 Advanced analytics dashboard
- 📋 AI chatbot (symptom checker)
- 📋 Lab test result integration

### Version 3.0 (Future) 💡
- 💡 AR/VR consultation room
- 💡 Genetic health risk prediction
- 💡 Mental health monitoring
- 💡 Ambulance dispatch integration
- 💡 Hospital EHR system integration

---

## 📞 HỖ TRỢ & LIÊN HỆ

**GitHub Repository**: [buithan04/Health_IoT](https://github.com/buithan04/Health_IoT)

**Documentation Issues**: Nếu có thắc mắc về tài liệu, vui lòng tạo issue trên GitHub.

---

**Cập nhật lần cuối**: 05/01/2026  
**Version**: 1.0.0  
**Tác giả**: Health IoT Team
