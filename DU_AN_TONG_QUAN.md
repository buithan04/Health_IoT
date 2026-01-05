# 🏥 HEALTH IOT - TÀI LIỆU TỔNG QUAN DỰ ÁN

> **Hệ thống chăm sóc sức khỏe thông minh kết hợp IoT, AI và Telemedicine**

---

## 📋 MỤC LỤC

- [1. Giới Thiệu Dự Án](#1-giới-thiệu-dự-án)
- [2. Kiến Trúc Tổng Thể](#2-kiến-trúc-tổng-thể)
- [3. Các Module Chính](#3-các-module-chính)
- [4. Công Nghệ Sử Dụng](#4-công-nghệ-sử-dụng)
- [5. Luồng Dữ Liệu](#5-luồng-dữ-liệu)
- [6. Tính Năng Nổi Bật](#6-tính-năng-nổi-bật)
- [7. Cấu Trúc Thư Mục](#7-cấu-trúc-thư-mục)
- [8. Hướng Dẫn Cài Đặt](#8-hướng-dẫn-cài-đặt)
- [9. Bảo Mật](#9-bảo-mật)
- [10. Roadmap](#10-roadmap)

---

## 1. GIỚI THIỆU DỰ ÁN

### 1.1 Tổng Quan

**Health IoT** là hệ thống chăm sóc sức khỏe toàn diện kết hợp 4 công nghệ chính:

| Công Nghệ | Mục Đích | Thành Phần |
|-----------|----------|------------|
| **📱 Mobile App** | Giao diện người dùng | Flutter (Android, iOS, Windows) |
| **🖥️ Web Admin** | Quản trị hệ thống | Next.js 14 + TypeScript |
| **🚀 Backend API** | Xử lý logic nghiệp vụ | Node.js + Express + AI/ML |
| **🔌 IoT Device** | Thu thập dữ liệu sức khỏe | ESP32 + Sensors |

### 1.2 Mục Tiêu Dự Án

✅ **Telemedicine**: Kết nối bệnh nhân - bác sĩ từ xa qua video call HD  
✅ **IoT Monitoring**: Theo dõi sức khỏe real-time (nhịp tim, SpO2, nhiệt độ, ECG)  
✅ **AI Diagnosis**: Dự đoán bệnh tim mạch với độ chính xác 89.3%  
✅ **E-Prescription**: Kê đơn thuốc điện tử với cơ sở dữ liệu 5000+ thuốc  
✅ **Smart Reminders**: Nhắc nhở uống thuốc thông minh  
✅ **Real-time Chat**: Nhắn tin tức thời với Socket.IO  

### 1.3 Đối Tượng Sử Dụng

👨‍⚕️ **Bác sĩ**: Quản lý bệnh nhân, kê đơn, tư vấn từ xa  
👩‍💼 **Bệnh nhân**: Đặt lịch khám, theo dõi sức khỏe, nhận tư vấn  
🔧 **Quản trị viên**: Quản lý hệ thống, phân tích dữ liệu  

---

## 2. KIẾN TRÚC TỔNG THỂ

### 2.1 Sơ Đồ Kiến Trúc

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────┐  │
│  │  Flutter App     │    │  Next.js Admin   │    │  ESP32 IoT   │  │
│  │  (Mobile/Win)    │    │  (Web Dashboard) │    │  (Wearable)  │  │
│  ├──────────────────┤    ├──────────────────┤    ├──────────────┤  │
│  │ • Android        │    │ • Analytics      │    │ • MAX30102   │  │
│  │ • iOS            │    │ • User Mgmt      │    │ • MLX90614   │  │
│  │ • Windows        │    │ • Reports        │    │ • ECG AD8232 │  │
│  │ • ZegoCloud Call │    │ • Settings       │    │ • WiFi Setup │  │
│  └────────┬─────────┘    └────────┬─────────┘    └──────┬───────┘  │
│           │                       │                       │          │
│           └───────────────────────┼───────────────────────┘          │
│                                   │                                  │
└───────────────────────────────────┼──────────────────────────────────┘
                                    │
                          HTTPS/WSS/MQTT
                                    │
┌───────────────────────────────────▼──────────────────────────────────┐
│                      APPLICATION LAYER                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  🚀 Node.js Backend Server (Port 3000)                               │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                     API GATEWAY                                 │ │
│  │  • JWT Authentication      • Rate Limiting                      │ │
│  │  • Request Validation      • CORS Policy                        │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │  REST API    │  │  Socket.IO   │  │ MQTT Client  │              │
│  │  100+ Routes │  │  Real-time   │  │  IoT Bridge  │              │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘              │
│         │                 │                   │                      │
│         └─────────────────┼───────────────────┘                      │
│                           │                                          │
│  ┌────────────────────────▼────────────────────────┐                │
│  │          BUSINESS LOGIC SERVICES                │                │
│  ├─────────────────────────────────────────────────┤                │
│  │ • Auth Service        • Appointment Service     │                │
│  │ • User Service        • Prescription Service    │                │
│  │ • Doctor Service      • Chat Service            │                │
│  │ • AI/ML Service       • Notification Service    │                │
│  │ • MQTT Service        • Email Service           │                │
│  │ • Article Crawler     • Health Analysis         │                │
│  └─────────────────────────────────────────────────┘                │
│                                                                       │
└───────────────────────────────────┬───────────────────────────────────┘
                                    │
┌───────────────────────────────────▼───────────────────────────────────┐
│                         DATA LAYER                                     │
├────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐    │
│  │  PostgreSQL 14+  │  │   HiveMQ Cloud   │  │   Cloudinary     │    │
│  │  + TimescaleDB   │  │   MQTT Broker    │  │   File Storage   │    │
│  ├──────────────────┤  ├──────────────────┤  ├──────────────────┤    │
│  │ • Users          │  │ • IoT Data       │  │ • Avatars        │    │
│  │ • Appointments   │  │ • Real-time      │  │ • Prescriptions  │    │
│  │ • Prescriptions  │  │ • Pub/Sub        │  │ • Medical Docs   │    │
│  │ • Health Stats   │  │                  │  │                  │    │
│  │ • Time-series    │  │                  │  │                  │    │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘    │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐                          │
│  │  Firebase FCM    │  │   AI/ML Models   │                          │
│  │  Push Notify     │  │   TensorFlow.js  │                          │
│  ├──────────────────┤  ├──────────────────┤                          │
│  │ • Cloud Msg      │  │ • Heart Disease  │                          │
│  │ • Topic Subscribe│  │ • ECG Analysis   │                          │
│  │                  │  │ • Scaler Models  │                          │
│  └──────────────────┘  └──────────────────┘                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Mô Hình Hoạt Động

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLOW: Theo dõi sức khỏe                       │
└─────────────────────────────────────────────────────────────────┘

ESP32 Device                Backend Server              Mobile App
     │                            │                          │
     │ 1. Đo sinh hiệu            │                          │
     │ (HR, SpO2, Temp, ECG)      │                          │
     │                            │                          │
     │ 2. Publish MQTT            │                          │
     │───────────────────────────>│                          │
     │    Topic: iot/vital/10     │                          │
     │                            │                          │
     │                            │ 3. Lưu vào TimescaleDB   │
     │                            │ + Kiểm tra ngưỡng cảnh báo│
     │                            │                          │
     │                            │ 4. Socket.IO emit        │
     │                            │─────────────────────────>│
     │                            │   Event: vital_update    │
     │                            │                          │
     │                            │                          │ 5. Update UI
     │                            │                          │ (Real-time)
     │                            │                          │
     │                            │ 6. Nếu có cảnh báo       │
     │                            │    → Gửi FCM Push        │
     │                            │─────────────────────────>│
     │                            │                          │

┌─────────────────────────────────────────────────────────────────┐
│                 FLOW: Tư vấn từ xa qua Video                     │
└─────────────────────────────────────────────────────────────────┘

Patient App              Backend Server              Doctor App
     │                         │                          │
     │ 1. Đặt lịch khám        │                          │
     │────────────────────────>│                          │
     │    POST /api/appointments                          │
     │                         │                          │
     │                         │ 2. Thông báo bác sĩ      │
     │                         │─────────────────────────>│
     │                         │    FCM Push + Socket     │
     │                         │                          │
     │                         │ 3. Bác sĩ xác nhận       │
     │                         │<─────────────────────────│
     │                         │                          │
     │ 4. Nhận thông báo       │                          │
     │<────────────────────────│                          │
     │    Socket: appointment_confirmed                   │
     │                         │                          │
     │ 5. Khi đến giờ hẹn      │                          │
     │ → Gọi video ZegoCloud   │                          │
     │────────────────────────────────────────────────────>│
     │          (P2P Connection via Zego Server)          │
     │                         │                          │
     │ 6. Sau cuộc gọi         │                          │
     │ → Bác sĩ kê đơn         │                          │
     │                         │<─────────────────────────│
     │                         │    POST /api/prescriptions
     │                         │                          │
     │ 7. Nhận đơn thuốc       │                          │
     │<────────────────────────│                          │
     │    Socket: new_prescription                        │
```

---

## 3. CÁC MODULE CHÍNH

### 3.1 Module Mobile App (Flutter)

📱 **Nền tảng**: Android, iOS, Windows  
🎨 **UI Framework**: Material Design 3 + Custom Widgets  
🔧 **State Management**: Provider Pattern  
🌐 **Routing**: GoRouter 17.0  

**Cấu trúc thư mục**:
```
App/lib/
├── core/                    # Tiện ích chung
│   ├── api_client.dart     # HTTP client wrapper
│   ├── app_routes.dart     # Định nghĩa routes
│   └── constants.dart      # Hằng số
├── models/                  # Data models
│   ├── user_model.dart
│   ├── appointment_model.dart
│   └── prescription_model.dart
├── presentation/            # UI Screens
│   ├── auth/               # Đăng nhập/Đăng ký
│   ├── patient/            # Giao diện bệnh nhân
│   ├── doctor/             # Giao diện bác sĩ
│   ├── home/               # Màn hình chính
│   └── shared/             # Widget dùng chung
├── service/                 # Business logic
│   ├── auth_service.dart
│   ├── socket_service.dart
│   ├── zego_call_service.dart
│   ├── mqtt_service.dart
│   └── predict_service.dart
└── main.dart               # Entry point
```

**Tính năng chính**:
- ✅ Đăng nhập/Đăng ký với JWT
- ✅ Theo dõi sinh hiệu real-time
- ✅ Dự đoán bệnh tim với AI
- ✅ Đặt lịch khám với bác sĩ
- ✅ Video call HD (ZegoCloud SDK 4.22.2)
- ✅ Chat real-time (Socket.IO)
- ✅ Xem đơn thuốc & nhắc uống thuốc
- ✅ Đọc tin tức sức khỏe

### 3.2 Module Backend API (Node.js)

🚀 **Framework**: Express.js 4.19  
💾 **Database**: PostgreSQL 14 + TimescaleDB  
🤖 **AI/ML**: TensorFlow.js 4.22  
⚡ **Real-time**: Socket.IO 4.8  

**Cấu trúc thư mục**:
```
HealthAI_Server/
├── config/                  # Cấu hình
│   ├── database.js         # PostgreSQL connection
│   ├── mqtt_config.js      # HiveMQ settings
│   └── cloudinary.js       # File storage
├── controllers/             # Request handlers
│   ├── auth_controller.js
│   ├── appointment_controller.js
│   ├── predict_controller.js
│   └── mqtt_controller.js
├── services/                # Business logic
│   ├── auth_service.js
│   ├── predict_service.js  # AI/ML service
│   ├── mqtt_service.js
│   └── email_service.js
├── models/                  # Database schemas
│   ├── user_model.js
│   ├── appointment_model.js
│   └── iot_data_model.js
├── routes/                  # API routes
│   ├── auth_routes.js
│   ├── appointment_routes.js
│   ├── predict_routes.js
│   └── mqtt_routes.js
├── middleware/              # Middleware
│   ├── auth_middleware.js  # JWT verification
│   └── validate.js         # Input validation
├── workers/                 # Background jobs
│   ├── mqtt_worker.js      # MQTT subscriber
│   └── cron_jobs.js        # Scheduled tasks
├── socket_manager.js        # Socket.IO config
└── app.js                  # Express app
```

**API Endpoints** (100+ routes):

| Module | Routes | Mô tả |
|--------|--------|-------|
| Auth | `/api/auth/*` | Đăng ký, đăng nhập, verify email |
| Users | `/api/users/*` | Quản lý profile, avatar |
| Doctors | `/api/doctors/*` | Danh sách bác sĩ, lịch làm việc |
| Appointments | `/api/appointments/*` | Đặt lịch, hủy, đánh giá |
| Prescriptions | `/api/prescriptions/*` | Kê đơn, xem đơn thuốc |
| Chat | `/api/chat/*` | Tin nhắn, lịch sử chat |
| MQTT | `/api/mqtt/*` | Dữ liệu IoT, cảnh báo |
| Predict | `/api/predict/*` | Dự đoán bệnh AI |
| Articles | `/api/articles/*` | Tin tức sức khỏe |
| Admin | `/api/admin/*` | Thống kê, báo cáo |

**AI/ML Models**:
- 🧠 **Heart Disease Prediction**: MLP 11 features → 89.3% accuracy
- 📈 **ECG Anomaly Detection**: CNN 1D cho phân tích ECG
- 🔢 **Data Preprocessing**: StandardScaler, Feature Engineering

### 3.3 Module Web Admin (Next.js)

🖥️ **Framework**: Next.js 14 App Router  
💅 **UI**: shadcn/ui + Radix UI + Tailwind CSS  
📊 **Charts**: Recharts + Custom Analytics  
🔍 **Tables**: TanStack Table  

**Cấu trúc thư mục**:
```
Web_admin/src/
├── app/                     # App Router
│   ├── (dashboard)/        # Dashboard layout
│   │   ├── page.tsx        # Trang chủ
│   │   ├── users/          # Quản lý users
│   │   ├── doctors/        # Quản lý bác sĩ
│   │   ├── appointments/   # Quản lý lịch hẹn
│   │   ├── prescriptions/  # Quản lý đơn thuốc
│   │   └── settings/       # Cài đặt hệ thống
│   └── layout.tsx          # Root layout
├── components/              # React components
│   ├── ui/                 # shadcn/ui components
│   ├── dashboard/          # Dashboard widgets
│   └── tables/             # Data tables
├── lib/                     # Utilities
│   ├── api.ts              # API client
│   └── utils.ts            # Helper functions
└── styles/                  # Styling
    └── globals.css
```

**Tính năng**:
- 📊 Dashboard analytics với biểu đồ
- 👥 Quản lý users (bệnh nhân, bác sĩ, admin)
- 📅 Theo dõi lịch hẹn
- 💊 Quản lý cơ sở dữ liệu thuốc
- 📈 Báo cáo & export Excel
- ⚙️ Cấu hình MQTT, email, notifications

### 3.4 Module ESP32 Firmware (C++)

🔌 **Platform**: ESP32 DevKit  
📡 **Protocol**: MQTT + HTTP  
🔧 **Framework**: Arduino  

**Hardware**:
- **MAX30102**: Pulse oximeter (HR + SpO2)
- **MLX90614**: Infrared thermometer
- **AD8232**: ECG sensor
- **WiFi**: Built-in ESP32

**Chức năng**:
```cpp
// 2 chế độ đo
enum MeasureMode {
    MODE_VITAL,  // Đo sinh hiệu (HR, SpO2, Temp)
    MODE_ECG     // Đo điện tim
};

// Vital Signs Mode
- Đo nhịp tim: 60-180 BPM
- Đo SpO2: 90-100%
- Đo nhiệt độ: 35-42°C
- Gửi MQTT mỗi 10s

// ECG Mode
- Sampling rate: 125Hz
- Batch size: 100 samples
- Digital gain: 6.0x
- Low-pass filter: α = 0.2
```

**MQTT Topics**:
```
Publish:
- iot/vital/{userId}     # Dữ liệu sinh hiệu
- iot/ecg/{userId}       # Dữ liệu ECG

Subscribe:
- iot/control/{userId}   # Nhận lệnh điều khiển
```

**Web Configuration**:
- Portal WiFi setup tại `192.168.4.1`
- Scan & connect WiFi
- Lưu credentials vào EEPROM

---

## 4. CÔNG NGHỆ SỬ DỤNG

### 4.1 Frontend Technologies

| Công nghệ | Version | Mục đích |
|-----------|---------|----------|
| **Flutter** | 3.24.0 | Mobile app framework |
| **Dart** | 3.9.2 | Programming language |
| **Next.js** | 14.2.15 | Web admin framework |
| **TypeScript** | 5.x | Type-safe JavaScript |
| **React** | 18.3.1 | UI library |
| **Tailwind CSS** | 3.4 | Styling |
| **shadcn/ui** | Latest | UI components |
| **ZegoCloud SDK** | 4.22.2 | Video calling |

### 4.2 Backend Technologies

| Công nghệ | Version | Mục đích |
|-----------|---------|----------|
| **Node.js** | 16+ | Runtime environment |
| **Express.js** | 4.19.2 | Web framework |
| **PostgreSQL** | 14+ | Relational database |
| **TimescaleDB** | 2.0+ | Time-series extension |
| **Socket.IO** | 4.8.1 | Real-time communication |
| **TensorFlow.js** | 4.22.0 | AI/ML models |
| **MQTT** | 5.14.1 | IoT protocol |
| **JWT** | 9.0.2 | Authentication |
| **bcrypt** | 6.0.0 | Password hashing |
| **Cloudinary** | 2.8.0 | File storage |
| **Firebase Admin** | 13.6.0 | Push notifications |
| **Nodemailer** | 7.0.10 | Email service |

### 4.3 IoT Technologies

| Công nghệ | Version | Mục đích |
|-----------|---------|----------|
| **ESP32** | DevKit | Microcontroller |
| **Arduino Framework** | Latest | Development framework |
| **PlatformIO** | Latest | Build system |
| **PubSubClient** | 2.8 | MQTT library |
| **ArduinoJson** | 6.21.3 | JSON parsing |
| **MAX30102** | 1.1.2 | Pulse sensor library |
| **MLX90614** | 2.1.3 | Temperature sensor |

### 4.4 DevOps & Tools

| Công nghệ | Mục đích |
|-----------|----------|
| **Git** | Version control |
| **GitHub** | Code repository |
| **pgAdmin** | Database management |
| **Postman** | API testing |
| **VS Code** | IDE |
| **Android Studio** | Android development |
| **Xcode** | iOS development |

---

## 5. LUỒNG DỮ LIỆU

### 5.1 Luồng Đăng Ký & Đăng Nhập

```
Mobile App                   Backend Server              Database
    │                              │                          │
    │ 1. POST /api/auth/register   │                          │
    │──────────────────────────────>│                          │
    │   {email, password, name}    │                          │
    │                              │                          │
    │                              │ 2. Hash password (bcrypt)│
    │                              │ 3. INSERT user           │
    │                              │─────────────────────────>│
    │                              │                          │
    │                              │ 4. Send verification email│
    │                              │    (Nodemailer)          │
    │                              │                          │
    │ 5. Response {success, userId}│                          │
    │<──────────────────────────────│                          │
    │                              │                          │
    │ 6. User clicks email link    │                          │
    │ GET /api/auth/verify/:token  │                          │
    │──────────────────────────────>│                          │
    │                              │                          │
    │                              │ 7. UPDATE is_verified    │
    │                              │─────────────────────────>│
    │                              │                          │
    │ 8. POST /api/auth/login      │                          │
    │──────────────────────────────>│                          │
    │   {email, password}          │                          │
    │                              │                          │
    │                              │ 9. Verify credentials    │
    │                              │<─────────────────────────│
    │                              │                          │
    │                              │ 10. Generate JWT token   │
    │                              │     + Refresh token      │
    │                              │                          │
    │ 11. Response {token, user}   │                          │
    │<──────────────────────────────│                          │
    │                              │                          │
    │ 12. Save to SharedPreferences│                          │
    │     + Init Socket.IO         │                          │
```

### 5.2 Luồng Theo Dõi Sinh Hiệu IoT

```
ESP32                    MQTT Broker           Backend Worker        Database         Mobile App
  │                           │                       │                  │                 │
  │ 1. Đo MAX30102           │                       │                  │                 │
  │    + MLX90614            │                       │                  │                 │
  │                          │                       │                  │                 │
  │ 2. PUBLISH               │                       │                  │                 │
  │────────────────────────> │                       │                  │                 │
  │ Topic: iot/vital/10      │                       │                  │                 │
  │ Payload: {hr, spo2, temp}│                       │                  │                 │
  │                          │                       │                  │                 │
  │                          │ 3. Forward message    │                  │                 │
  │                          │──────────────────────>│                  │                 │
  │                          │                       │                  │                 │
  │                          │                       │ 4. Parse JSON    │                 │
  │                          │                       │ 5. Validate data │                 │
  │                          │                       │                  │                 │
  │                          │                       │ 6. INSERT        │                 │
  │                          │                       │─────────────────>│                 │
  │                          │                       │  into iot_vital  │                 │
  │                          │                       │  (TimescaleDB)   │                 │
  │                          │                       │                  │                 │
  │                          │                       │ 7. Check thresholds                │
  │                          │                       │    (HR > 120 → Warning)            │
  │                          │                       │                  │                 │
  │                          │                       │ 8. Emit Socket.IO                  │
  │                          │                       │────────────────────────────────────>│
  │                          │                       │  Event: vital_update               │
  │                          │                       │  Room: user_10                     │
  │                          │                       │                  │                 │
  │                          │                       │                  │                 │ 9. Update UI
  │                          │                       │                  │                 │   (Real-time chart)
  │                          │                       │                  │                 │
  │                          │                       │ 10. If warning → FCM Push          │
  │                          │                       │────────────────────────────────────>│
  │                          │                       │                  │                 │
```

### 5.3 Luồng Dự Đoán Bệnh Tim AI

```
Mobile App                Backend API              AI Service            Database
    │                          │                        │                   │
    │ 1. POST /api/predict/heart                      │                   │
    │──────────────────────────>│                        │                   │
    │  {age, sex, cp, trestbps,│                        │                   │
    │   chol, fbs, restecg, ... }                      │                   │
    │                          │                        │                   │
    │                          │ 2. Feature engineering │                   │
    │                          │─────────────────────────>                  │
    │                          │  • Calculate age_group │                   │
    │                          │  • Calculate bmi       │                   │
    │                          │  • Calculate map       │                   │
    │                          │                        │                   │
    │                          │ 3. Load StandardScaler │                   │
    │                          │    from file (.bin)    │                   │
    │                          │                        │                   │
    │                          │ 4. Normalize features  │                   │
    │                          │    X_scaled = scaler.transform(X)          │
    │                          │                        │                   │
    │                          │ 5. Load TensorFlow model                   │
    │                          │    (heart_disease_model.json)              │
    │                          │                        │                   │
    │                          │ 6. Predict             │                   │
    │                          │    probability = model.predict(X_scaled)   │
    │                          │                        │                   │
    │                          │ 7. Calculate risk level│                   │
    │                          │    • Low: < 30%        │                   │
    │                          │    • Medium: 30-70%    │                   │
    │                          │    • High: > 70%       │                   │
    │                          │                        │                   │
    │                          │ 8. Save prediction     │                   │
    │                          │─────────────────────────────────────────────>│
    │                          │                        │                   │
    │ 9. Response              │                        │                   │
    │<──────────────────────────│                        │                   │
    │  {probability: 0.15,     │                        │                   │
    │   risk: "low",           │                        │                   │
    │   recommendations: [...]}│                        │                   │
    │                          │                        │                   │
    │ 10. Display result       │                        │                   │
    │     + Show chart         │                        │                   │
```

### 5.4 Luồng Video Call

```
Patient App          ZegoCloud Server         Backend API         Doctor App
     │                       │                      │                  │
     │ 1. Tap "Call"         │                      │                  │
     │                       │                      │                  │
     │ 2. Request call token │                      │                  │
     │───────────────────────────────────────────────>                  │
     │    POST /api/call/token                      │                  │
     │                       │                      │                  │
     │ 3. Generate Zego token                       │                  │
     │<───────────────────────────────────────────────                  │
     │    {token, appID, callID}                    │                  │
     │                       │                      │                  │
     │ 4. Join Zego room     │                      │                  │
     │──────────────────────>│                      │                  │
     │                       │                      │                  │
     │                       │ 5. Notify doctor     │                  │
     │                       │      via FCM + Socket                   │
     │                       │──────────────────────────────────────────>│
     │                       │  Event: incoming_call                   │
     │                       │                      │                  │
     │                       │                      │                  │ 6. Show incoming UI
     │                       │                      │                  │
     │                       │                      │ 7. Doctor accepts│
     │                       │<──────────────────────────────────────────│
     │                       │                      │                  │
     │                       │ 8. P2P connection established            │
     │<─────────────────────────────────────────────────────────────────>│
     │                  (Direct WebRTC stream)                         │
     │                       │                      │                  │
     │                       │                      │                  │
     │ 9. Call ended         │                      │                  │
     │──────────────────────>│                      │                  │
     │                       │                      │                  │
     │                       │ 10. Save call history                   │
     │───────────────────────────────────────────────>                  │
     │    POST /api/call/history                    │                  │
     │    {duration, quality}                       │                  │
```

---

## 6. TÍNH NĂNG NỔI BẬT

### 6.1 Telemedicine (Y tế từ xa)

#### 6.1.1 Video Calling HD
- ✅ **ZegoCloud SDK 4.22.2**: Video call chất lượng cao
- ✅ **P2P Connection**: Kết nối trực tiếp, độ trễ thấp
- ✅ **Adaptive Bitrate**: Tự động điều chỉnh theo băng thông
- ✅ **Background Mode**: Gọi khi app ở background
- ✅ **Call History**: Lịch sử cuộc gọi với duration, quality

#### 6.1.2 Real-time Chat
- ✅ **Socket.IO**: Nhắn tin tức thời
- ✅ **Room-based**: Riêng tư cho từng cuộc trò chuyện
- ✅ **Typing Indicator**: Hiển thị "đang gõ..."
- ✅ **Online Status**: Trạng thái online/offline
- ✅ **Message History**: Lịch sử tin nhắn lưu trữ

#### 6.1.3 Appointment System
- ✅ **Smart Scheduling**: Đặt lịch thông minh với calendar
- ✅ **Doctor Availability**: Kiểm tra lịch trống của bác sĩ
- ✅ **Reminder System**: Nhắc nhở trước 24h
- ✅ **Status Tracking**: Pending → Confirmed → Completed
- ✅ **Rating & Review**: Đánh giá sau mỗi cuộc hẹn

### 6.2 IoT Health Monitoring

#### 6.2.1 Real-time Vital Signs
- ✅ **Heart Rate**: 60-180 BPM (MAX30102)
- ✅ **SpO2**: 90-100% (MAX30102)
- ✅ **Temperature**: 35-42°C (MLX90614)
- ✅ **Blood Pressure**: Systolic/Diastolic (future)
- ✅ **ECG**: 125Hz sampling (AD8232)

#### 6.2.2 MQTT Integration
- ✅ **HiveMQ Cloud**: Managed MQTT broker
- ✅ **TLS/SSL**: Bảo mật end-to-end
- ✅ **QoS 1**: Đảm bảo gửi ít nhất 1 lần
- ✅ **Retained Messages**: Lưu giá trị cuối cùng
- ✅ **Background Worker**: Node.js MQTT subscriber

#### 6.2.3 Data Visualization
- ✅ **FL Chart**: Biểu đồ real-time trong Flutter
- ✅ **Time-series**: TimescaleDB cho dữ liệu theo thời gian
- ✅ **Trend Analysis**: Phân tích xu hướng sức khỏe
- ✅ **Alert Thresholds**: Cảnh báo vượt ngưỡng

### 6.3 AI/ML Features

#### 6.3.1 Heart Disease Prediction
**Model Architecture**:
```python
Input Layer (11 features)
    ↓
Dense(64, activation='relu')
    ↓
Dropout(0.3)
    ↓
Dense(32, activation='relu')
    ↓
Dropout(0.3)
    ↓
Dense(1, activation='sigmoid')
    ↓
Output: Probability [0-1]
```

**Features Used** (11):
1. age (tuổi)
2. sex (giới tính)
3. cp (loại đau ngực)
4. trestbps (huyết áp)
5. chol (cholesterol)
6. fbs (đường huyết)
7. restecg (ECG lúc nghỉ)
8. thalach (nhịp tim tối đa)
9. exang (đau ngực khi tập)
10. oldpeak (ST depression)
11. slope (độ dốc ST)

**Performance**:
- Accuracy: **89.3%**
- Precision: **87.5%**
- Recall: **91.2%**
- F1-Score: **89.3%**

#### 6.3.2 Data Preprocessing
```javascript
// Feature Engineering
age_group = age < 45 ? 0 : (age < 60 ? 1 : 2)
bmi = weight / (height * height)
map = (systolic + 2 * diastolic) / 3

// StandardScaler
X_scaled = (X - mean) / std_dev
```

### 6.4 E-Prescription System

#### 6.4.1 Medication Database
- ✅ **5000+ thuốc**: Cơ sở dữ liệu đầy đủ
- ✅ **Drug Categories**: Phân loại theo nhóm
- ✅ **Dosage Info**: Liều lượng, cách dùng
- ✅ **Contraindications**: Chống chỉ định
- ✅ **Search & Filter**: Tìm kiếm thông minh

#### 6.4.2 Digital Prescription
- ✅ **E-Signing**: Chữ ký điện tử bác sĩ
- ✅ **PDF Export**: Xuất file PDF
- ✅ **QR Code**: Mã QR cho xác thực
- ✅ **Cloud Storage**: Lưu trên Cloudinary
- ✅ **Version Control**: Theo dõi thay đổi

#### 6.4.3 Medication Reminders
- ✅ **Smart Scheduler**: Lên lịch thông minh
- ✅ **Push Notifications**: Nhắc nhở FCM
- ✅ **Dosage Tracking**: Theo dõi uống thuốc
- ✅ **Refill Alerts**: Nhắc mua thuốc mới
- ✅ **Compliance Reports**: Báo cáo tuân thủ

### 6.5 Admin Dashboard

#### 6.5.1 Analytics
- ✅ **User Statistics**: Thống kê người dùng
- ✅ **Appointment Trends**: xu hướng đặt lịch
- ✅ **Revenue Charts**: Biểu đồ doanh thu
- ✅ **Active Users**: Người dùng hoạt động
- ✅ **System Health**: Tình trạng hệ thống

#### 6.5.2 Management
- ✅ **User Management**: Quản lý tất cả users
- ✅ **Doctor Approval**: Phê duyệt bác sĩ
- ✅ **Medication CRUD**: Thêm/Sửa/Xóa thuốc
- ✅ **System Settings**: Cấu hình hệ thống
- ✅ **Export Reports**: Xuất báo cáo Excel

---

## 7. CẤU TRÚC THƯ MỤC

```
Health_IoT/
│
├── App/                           # 📱 Flutter Mobile App
│   ├── android/                   # Android configuration
│   ├── ios/                       # iOS configuration
│   ├── windows/                   # Windows configuration
│   ├── lib/
│   │   ├── core/                  # Core utilities
│   │   │   ├── api_client.dart
│   │   │   ├── app_routes.dart
│   │   │   └── constants.dart
│   │   ├── models/                # Data models
│   │   │   ├── user_model.dart
│   │   │   ├── appointment_model.dart
│   │   │   ├── prescription_model.dart
│   │   │   └── iot_data_model.dart
│   │   ├── presentation/          # UI screens
│   │   │   ├── auth/              # Login, Register
│   │   │   ├── patient/           # Patient screens
│   │   │   ├── doctor/            # Doctor screens
│   │   │   ├── home/              # Home screen
│   │   │   └── shared/            # Shared widgets
│   │   ├── service/               # Business logic
│   │   │   ├── auth_service.dart
│   │   │   ├── socket_service.dart
│   │   │   ├── zego_call_service.dart
│   │   │   ├── mqtt_service.dart
│   │   │   └── predict_service.dart
│   │   └── main.dart              # Entry point
│   ├── assets/                    # Images, fonts
│   ├── pubspec.yaml               # Dependencies
│   └── README.md
│
├── ESP32_firmware/                # 🔌 ESP32 IoT Device
│   ├── include/
│   │   ├── web_interface.h        # WiFi config portal
│   │   └── README
│   ├── lib/                       # External libraries
│   ├── src/
│   │   └── main.cpp               # Main firmware code
│   ├── platformio.ini             # PlatformIO config
│   └── README.md
│
├── HealthAI_Server/               # 🚀 Node.js Backend API
│   ├── config/
│   │   ├── database.js            # PostgreSQL config
│   │   ├── mqtt_config.js         # MQTT HiveMQ
│   │   └── cloudinary.js          # File storage
│   ├── controllers/               # Request handlers
│   │   ├── auth_controller.js
│   │   ├── appointment_controller.js
│   │   ├── predict_controller.js
│   │   └── ...
│   ├── services/                  # Business logic
│   │   ├── auth_service.js
│   │   ├── predict_service.js     # AI/ML service
│   │   ├── mqtt_service.js
│   │   └── ...
│   ├── models/                    # Database models
│   │   ├── user_model.js
│   │   ├── appointment_model.js
│   │   └── ...
│   ├── routes/                    # API routes
│   │   ├── auth_routes.js
│   │   ├── appointment_routes.js
│   │   └── ...
│   ├── middleware/                # Middleware
│   │   ├── auth_middleware.js     # JWT verification
│   │   └── validate.js
│   ├── workers/                   # Background jobs
│   │   ├── mqtt_worker.js         # MQTT subscriber
│   │   └── cron_jobs.js           # Scheduled tasks
│   ├── database/
│   │   ├── migrations/            # DB migrations
│   │   └── seeds/                 # Seed data
│   ├── ai_models/                 # AI/ML models
│   │   ├── heart_disease_model.json
│   │   ├── scaler.bin
│   │   └── ...
│   ├── socket_manager.js          # Socket.IO config
│   ├── app.js                     # Express app
│   ├── package.json
│   └── README.md
│
├── Web_admin/                     # 🖥️ Next.js Admin Dashboard
│   ├── src/
│   │   ├── app/                   # App Router
│   │   │   ├── (dashboard)/
│   │   │   │   ├── page.tsx       # Dashboard home
│   │   │   │   ├── users/
│   │   │   │   ├── doctors/
│   │   │   │   ├── appointments/
│   │   │   │   └── settings/
│   │   │   └── layout.tsx
│   │   ├── components/            # React components
│   │   │   ├── ui/                # shadcn/ui
│   │   │   ├── dashboard/
│   │   │   └── tables/
│   │   └── lib/                   # Utilities
│   │       └── api.ts
│   ├── public/                    # Static files
│   ├── package.json
│   ├── tailwind.config.ts
│   └── README.md
│
├── flutter/                       # 🔧 Flutter SDK (submodule)
│
├── PROJECT_DOCUMENTATION.md       # 📚 Tài liệu tổng quan
├── README.md                      # 📖 Hướng dẫn setup
├── SETUP_GUIDE.md                 # 🚀 Hướng dẫn cài đặt
├── CHANGELOG.md                   # 📝 Nhật ký thay đổi
└── LICENSE                        # ⚖️ Giấy phép MIT
```

---

## 8. HƯỚNG DẪN CÀI ĐẶT

### 8.1 Yêu Cầu Hệ Thống

#### Backend
- **Node.js**: >= 16.x
- **PostgreSQL**: >= 14.x hoặc **TimescaleDB**: >= 2.0
- **pgAdmin**: 4+ (optional)

#### Mobile App
- **Flutter SDK**: >= 3.24.0
- **Dart SDK**: >= 3.9.2
- **Android**: minSdkVersion 23
- **iOS**: iOS 13.0+
- **Windows**: Windows 10 1809+

#### Web Admin
- **Node.js**: >= 20.x
- **Next.js**: 14.x

#### IoT Firmware
- **PlatformIO**: Latest
- **ESP32**: DevKit board

### 8.2 Clone Repository

```bash
git clone https://github.com/buithan04/Health_IoT.git
cd Health_IoT
```

### 8.3 Setup Backend

```bash
cd HealthAI_Server

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Edit .env with your config
# - Database credentials
# - JWT secret
# - MQTT credentials (HiveMQ)
# - Cloudinary config
# - Firebase service account

# Run migrations
npm run db:migrate

# Seed data
npm run db:seed

# Start server
npm start
# hoặc development mode
npm run dev
```

**Environment Variables** (`.env`):
```env
PORT=3000
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASS=your_password
DB_NAME=health_iot

# JWT
JWT_SECRET=your_secret_key
JWT_EXPIRES_IN=7d

# MQTT HiveMQ
MQTT_BROKER=your_broker.hivemq.cloud
MQTT_PORT=8883
MQTT_USER=your_username
MQTT_PASS=your_password

# Cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud
CLOUDINARY_API_KEY=your_key
CLOUDINARY_API_SECRET=your_secret

# Firebase
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_email
```

### 8.4 Setup Mobile App

```bash
cd App

# Install dependencies
flutter pub get

# Create firebase_options.dart (Firebase config)
# Follow: https://firebase.google.com/docs/flutter/setup

# Run app
flutter run

# Build for specific platform
flutter build apk           # Android
flutter build ios           # iOS
flutter build windows       # Windows
```

**Config ZegoCloud** (`lib/config/app_info.dart`):
```dart
class AppInfo {
  static const int zegoAppID = 123456789; // Your Zego App ID
  static const String zegoAppSign = "your_app_sign";
}
```

### 8.5 Setup Web Admin

```bash
cd Web_admin

# Install dependencies
npm install

# Create .env.local
echo "NEXT_PUBLIC_API_URL=http://localhost:3000" > .env.local

# Run dev server
npm run dev

# Build for production
npm run build
npm start
```

### 8.6 Setup ESP32 Firmware

```bash
cd ESP32_firmware

# Install PlatformIO
# VS Code: Install PlatformIO IDE extension

# Edit src/main.cpp - Update MQTT credentials
const char *mqtt_user = "DoAn1";
const char *mqtt_pass = "Th123321";

# Build & upload
pio run -t upload

# Monitor serial
pio device monitor
```

**First Boot**:
1. ESP32 tạo WiFi AP: `ESP32_Config`
2. Connect vào WiFi này
3. Truy cập `http://192.168.4.1`
4. Scan & chọn WiFi nhà bạn
5. Nhập password → Save
6. ESP32 reboot & kết nối WiFi

---

## 9. BẢO MẬT

### 9.1 Authentication & Authorization

#### 9.1.1 JWT Tokens
```javascript
// Access Token (7 days)
{
  userId: 123,
  role: "patient",
  iat: 1234567890,
  exp: 1235172690
}

// Refresh Token (30 days)
{
  userId: 123,
  type: "refresh",
  iat: 1234567890,
  exp: 1237159890
}
```

#### 9.1.2 Password Security
- **Bcrypt**: Hash với cost factor 10
- **Min length**: 8 characters
- **Policy**: Ít nhất 1 chữ hoa, 1 số

#### 9.1.3 Role-Based Access Control (RBAC)
```javascript
Roles:
- admin: Full access
- doctor: Medical operations
- patient: Patient operations

Middleware:
requireRole(['doctor', 'admin'])
```

### 9.2 API Security

#### 9.2.1 Rate Limiting
```javascript
// 100 requests per 15 minutes
app.use(rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
}))
```

#### 9.2.2 CORS Policy
```javascript
cors({
  origin: [
    'http://localhost:3001',  // Web admin
    'capacitor://localhost'    // Mobile app
  ],
  credentials: true
})
```

#### 9.2.3 Input Validation
- **Joi Schema**: Validate tất cả inputs
- **SQL Injection**: Parameterized queries
- **XSS Protection**: Escape HTML

### 9.3 Data Security

#### 9.3.1 Database
- **Encrypted Passwords**: Bcrypt hash
- **Sensitive Data**: Encrypted columns
- **Backup**: Daily automated backup

#### 9.3.2 File Storage
- **Cloudinary**: Signed URLs
- **Access Control**: Private by default
- **Virus Scan**: Auto scan uploads

#### 9.3.3 Communication
- **HTTPS**: TLS 1.3 for API
- **WSS**: Secure WebSocket
- **MQTTS**: TLS for MQTT (port 8883)

### 9.4 IoT Security

#### 9.4.1 Device Authentication
- **User ID**: Mỗi device gắn với user
- **Topic Isolation**: `iot/vital/{userId}`
- **Access Control List**: MQTT ACL

#### 9.4.2 Data Integrity
- **Message Signing**: HMAC verification
- **Timestamp**: Reject old messages (> 5 min)
- **Sequence Number**: Detect replay attacks

---

## 10. ROADMAP

### Phase 1: Core Features (✅ Completed)
- ✅ User authentication & authorization
- ✅ Appointment booking system
- ✅ Video calling integration
- ✅ Real-time chat
- ✅ E-prescription system
- ✅ IoT vital signs monitoring
- ✅ AI heart disease prediction
- ✅ Admin dashboard

### Phase 2: Enhancements (🚧 In Progress)
- 🚧 ECG analysis with CNN
- 🚧 Telemedicine payment gateway
- 🚧 Multi-language support (EN, VI)
- 🚧 Dark mode UI
- 🚧 Enhanced analytics dashboard
- 🚧 Medication refill automation

### Phase 3: Advanced Features (📋 Planned)
- 📋 Blockchain medical records
- 📋 Wearable device integration (Fitbit, Apple Watch)
- 📋 AI chatbot for symptoms
- 📋 Telemedicine marketplace
- 📋 Insurance claim integration
- 📋 3D body scanning
- 📋 AR/VR for medical training
- 📋 Genomic data analysis

### Phase 4: Scale & Optimize (🔮 Future)
- 🔮 Microservices architecture
- 🔮 Kubernetes deployment
- 🔮 Multi-region support
- 🔮 AI-powered diagnosis expansion
- 🔮 Integration with hospital systems (HL7 FHIR)
- 🔮 Regulatory compliance (HIPAA, GDPR)

---

## 📞 Liên Hệ & Hỗ Trợ

**Nhóm Phát Triển**: Health IoT Team  
**Email**: support@healthiot.com  
**GitHub**: [https://github.com/buithan04/Health_IoT](https://github.com/buithan04/Health_IoT)  

---

## 📄 Giấy Phép

Dự án này được phát hành dưới giấy phép **MIT License**.  
Xem file [LICENSE](LICENSE) để biết thêm chi tiết.

---

**🏥 Health IoT - Chăm sóc sức khỏe thông minh, kết nối cuộc sống**
