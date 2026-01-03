# 📊 BÁO CÁO TOÀN DIỆN DỰ ÁN HEALTH IoT

> **Comprehensive Project Report - Based on Real Code Analysis**  
> **Version**: 2.0 (Revised & Accurate)  
> **Date**: January 4, 2026  
> **Author**: Bùi Duy Thân  
> **Repository**: git@github.com:buithan04/Health_IoT.git

---

## 📑 MỤC LỤC

1. [Tổng Quan Dự Án](#1-tổng-quan-dự-án)
2. [Kiến Trúc Hệ Thống](#2-kiến-trúc-hệ-thống)
3. [Công Nghệ & Dependencies](#3-công-nghệ--dependencies)
4. [Database Schema Chi Tiết](#4-database-schema-chi-tiết)
5. [Backend API Documentation](#5-backend-api-documentation)
6. [Frontend Features](#6-frontend-features)
7. [AI/ML System](#7-aiml-system)
8. [Real-time Communication](#8-real-time-communication)
9. [IoT Integration (MQTT)](#9-iot-integration-mqtt)
10. [Security & Authentication](#10-security--authentication)
11. [Deployment Guide](#11-deployment-guide)
12. [Screenshots & Diagrams](#12-screenshots--diagrams)

---

## 1. TỔNG QUAN DỰ ÁN

### 1.1. Giới Thiệu

**Health IoT** là hệ thống quản lý sức khỏe toàn diện kết hợp:
- 📱 **Mobile App** (Flutter) - Windows/Android/iOS
- 💻 **Admin Portal** (Next.js 14) - Web Dashboard
- ⚡ **Backend API** (Node.js + Express)
- 🗄️ **PostgreSQL Database** - 34 tables
- 🤖 **AI/ML Models** - TensorFlow.js (MLP & ECG)
- 📡 **IoT Integration** - MQTT (HiveMQ Cloud)
- 📞 **Video Calling** - ZegoCloud SDK

### 1.2. Core Features

#### Cho Bệnh Nhân (Patient):
- ✅ Quản lý hồ sơ sức khỏe điện tử
- ✅ Giám sát vitals real-time qua IoT (Heart Rate, SpO2, Temperature, Blood Pressure)
- ✅ AI dự đoán nguy cơ bệnh tim
- ✅ Đặt lịch khám với bác sĩ
- ✅ Video/Audio call với bác sĩ (ZegoCloud)
- ✅ Chat real-time (Socket.IO)
- ✅ Xem đơn thuốc điện tử
- ✅ Nhắc nhở uống thuốc
- ✅ Đọc tin tức sức khỏe

#### Cho Bác Sĩ (Doctor):
- ✅ Dashboard quản lý lịch hẹn
- ✅ Xem hồ sơ bệnh nhân & vitals real-time
- ✅ Kê đơn thuốc điện tử
- ✅ Video consultation
- ✅ Chat với bệnh nhân
- ✅ Quản lý lịch làm việc & time-off
- ✅ Ghi chú bệnh án (Doctor Notes)
- ✅ Analytics & statistics

#### Cho Admin:
- ✅ Dashboard tổng quan (Users, Doctors, Appointments, Revenue)
- ✅ Quản lý users, doctors, patients
- ✅ Quản lý thuốc, nhà sản xuất, thành phần
- ✅ Xem prescriptions, appointments
- ✅ Analytics & reports

### 1.3. System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                     HEALTH IoT SYSTEM                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Flutter    │  │   Next.js    │  │   IoT        │          │
│  │   Mobile     │  │   Admin      │  │   Devices    │          │
│  │   App        │  │   Portal     │  │   (MQTT)     │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                  │                  │                   │
│         └──────────────────┼──────────────────┘                   │
│                            ▼                                      │
│                  ┌─────────────────────┐                         │
│                  │   Node.js Express   │                         │
│                  │   Backend API       │                         │
│                  │   + Socket.IO       │                         │
│                  │   + MQTT Client     │                         │
│                  │   + TensorFlow.js   │                         │
│                  └──────────┬──────────┘                         │
│                             │                                     │
│                             ▼                                     │
│                  ┌─────────────────────┐                         │
│                  │   PostgreSQL 16     │                         │
│                  │   34 Tables         │                         │
│                  └─────────────────────┘                         │
│                                                                   │
│  External Services:                                              │
│  • ZegoCloud (Video/Audio calls)                                │
│  • Firebase Cloud Messaging (Push notifications)                │
│  • HiveMQ Cloud (MQTT Broker)                                   │
│  • Cloudinary (File storage)                                    │
│  • NewsAPI (Health articles)                                    │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. KIẾN TRÚC HỆ THỐNG

### 2.1. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Flutter App    │  │  Next.js Admin  │  │  IoT Devices    │ │
│  │  (Windows/      │  │  Portal         │  │  (ESP32/        │ │
│  │   Android/iOS)  │  │  (TypeScript)   │  │   Wearables)    │ │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘ │
│           │                     │                     │           │
│           │      HTTPS/WSS      │                     │   MQTTS   │
└───────────┼─────────────────────┼─────────────────────┼───────────┘
            │                     │                     │
            ▼                     ▼                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Node.js Express Server (Port 5000)             │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │  Middleware Stack:                                          │ │
│  │  • CORS                                                     │ │
│  │  • Body Parser (JSON)                                      │ │
│  │  • JWT Authentication                                       │ │
│  │  • Static Files (/uploads)                                 │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  RESTful API │  │  Socket.IO   │  │  MQTT Client │         │
│  │  26 Routes   │  │  Real-time   │  │  HiveMQ      │         │
│  │  ~100 APIs   │  │  Chat/Call   │  │  Subscribe   │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │           Business Logic (Services)                         │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │  • auth_service      • appointment_service                  │ │
│  │  • user_service      • doctor_service                       │ │
│  │  • chat_service      • prescription_service                 │ │
│  │  • predict_service   • health_analysis_service             │ │
│  │  • mqtt_service      • fcm_service                         │ │
│  │  • article_service   • email_service                       │ │
│  │  • notification_service   • reminder_service               │ │
│  │  • call_history_service   • admin_service                  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              AI/ML Processing                               │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │  • TensorFlow.js Node                                       │ │
│  │  • MLP Model (Heart Disease Prediction)                    │ │
│  │  • ECG Model (Anomaly Detection)                           │ │
│  │  • StandardScaler (Feature Normalization)                  │ │
│  │  • Risk Encoder                                             │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Background Workers                             │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │  • MQTT Worker (Subscribe to health topics)                │ │
│  │  • MQTT Cleanup Worker (Remove old data)                   │ │
│  │  • Article Crawler (News fetching every 3h)                │ │
│  │  • Scheduler (Appointment reminders)                        │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                PostgreSQL Database (Port 5432)              │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │  34 Tables:                                                 │ │
│  │  • users, profiles, patient_health_info                     │ │
│  │  • doctor_professional_info, doctor_schedules               │ │
│  │  • appointments, appointment_types, doctor_reviews          │ │
│  │  • prescriptions, prescription_items                        │ │
│  │  • medications, medication_categories, manufacturers        │ │
│  │  • active_ingredients, medication_ingredients               │ │
│  │  • medication_reminders                                     │ │
│  │  • health_records, ecg_readings, ai_diagnoses              │ │
│  │  • mqtt_health_data, patient_thresholds                    │ │
│  │  • conversations, participants, messages                    │ │
│  │  • call_history, notifications, articles                    │ │
│  │  • medical_attachments, doctor_time_off, doctor_notes      │ │
│  │                                                              │ │
│  │  Indexes: 20+ for performance optimization                 │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2. Backend MVC-S Structure

```
HealthAI_Server/
├── app.js                      # Entry point, server initialization
├── socket_manager.js           # Socket.IO configuration
│
├── config/
│   ├── db.js                   # PostgreSQL connection pool
│   ├── aiModels.js             # TensorFlow.js models loader
│   ├── mqtt.js                 # MQTT configuration
│   └── cloudinary.js           # Cloudinary config
│
├── routes/                     # Route definitions (26 files)
│   ├── index.js                # Main router
│   ├── auth_routes.js          # Authentication
│   ├── user_routes.js          # User management
│   ├── doctor_routes.js        # Doctor operations
│   ├── appointment_routes.js   # Appointment booking
│   ├── prescription_routes.js  # Prescriptions
│   ├── chat_routes.js          # Chat messaging
│   ├── call_history.js         # Video/Audio call logs
│   ├── predict_routes.js       # AI predictions
│   ├── mqtt_routes.js          # IoT data
│   ├── admin_routes.js         # Admin panel
│   └── ...                     # (14 more routes)
│
├── controllers/                # Request handlers (11 files)
│   ├── auth_controller.js
│   ├── user_controller.js
│   ├── doctor_controller.js
│   └── ...
│
├── services/                   # Business logic (17 files)
│   ├── auth_service.js
│   ├── predict_service.js      # AI/ML processing
│   ├── health_analysis_service.js
│   ├── mqtt_service.js
│   ├── fcm_service.js
│   └── ...
│
├── middleware/
│   ├── auth.js                 # JWT verification
│   └── validate.js
│
├── workers/                    # Background jobs
│   ├── mqtt_worker.js          # Subscribe to MQTT topics
│   ├── mqtt_cleanup_worker.js  # Cleanup old data
│   └── scheduler.js            # Appointment reminders
│
├── models/                     # AI/ML models
│   ├── tfjs_mlp_model/         # Heart disease prediction
│   ├── tfjs_ecg_model/         # ECG anomaly detection
│   ├── scaler_mlp.json         # Feature normalization
│   ├── scaler_ecg.json
│   └── risk_encoder.json
│
├── database/
│   ├── migrations.sql          # Schema definition
│   └── seed_data.sql           # Sample data
│
└── uploads/                    # File uploads (avatars, attachments)
```

---

## 3. CÔNG NGHỆ & DEPENDENCIES

### 3.1. Backend (Node.js)

**Core Framework:**
```json
{
  "name": "health-ai-server",
  "version": "1.0.0",
  "main": "app.js",
  "engines": {
    "node": ">=20.0.0"
  }
}
```

**Dependencies (package.json):**
```json
{
  "express": "^4.18.2",              // Web framework
  "socket.io": "^4.6.1",             // Real-time WebSocket
  "pg": "^8.11.3",                   // PostgreSQL client
  "bcrypt": "^5.1.1",                // Password hashing
  "jsonwebtoken": "^9.0.2",          // JWT authentication
  "dotenv": "^16.3.1",               // Environment variables
  "cors": "^2.8.5",                  // CORS middleware
  
  // AI/ML
  "@tensorflow/tfjs-node": "^4.15.0",// TensorFlow.js for Node
  
  // IoT
  "mqtt": "^5.3.4",                  // MQTT protocol client
  
  // File handling
  "multer": "^1.4.5-lts.1",          // File upload
  "cloudinary": "^1.41.1",           // Image storage
  
  // Email
  "nodemailer": "^6.9.7",            // Email service
  
  // Push notifications
  "firebase-admin": "^12.0.0",       // FCM
  
  // Utilities
  "axios": "^1.6.2",                 // HTTP client
  "node-cron": "^3.0.3"              // Task scheduling
}
```

### 3.2. Frontend Mobile (Flutter)

**pubspec.yaml:**
```yaml
name: app_iot
version: 1.0.0+1
environment:
  sdk: ^3.9.2

dependencies:
  flutter:
    sdk: flutter
  
  # Routing & Navigation
  go_router: ^17.0.1
  
  # State Management
  provider: ^6.1.5+1
  
  # Network & API
  http: ^1.2.1
  http_parser: ^4.0.2
  
  # Real-time Communication
  socket_io_client: ^3.1.2
  mqtt_client: ^10.3.1
  
  # Video/Audio Calling
  zego_uikit_prebuilt_call: 4.22.2
  zego_uikit: 2.28.38
  zego_express_engine: 3.22.0
  
  # Firebase
  firebase_core: ^4.3.0
  firebase_messaging: ^16.1.0
  flutter_local_notifications: ^19.5.0
  
  # UI Components
  fl_chart: ^1.1.1                   // Charts & graphs
  google_fonts: ^6.3.3
  flutter_animate: ^4.5.0
  flutter_rating_bar: ^4.0.1
  photo_view: ^0.15.0
  
  # Media
  image_picker: ^1.0.7
  file_picker: ^10.3.7
  gal: ^2.3.2
  audioplayers: ^6.0.0
  flutter_ringtone_player: ^4.0.0
  
  # Utilities
  intl: ^0.20.2                      // Date/Time formatting
  shared_preferences: ^2.2.2         // Local storage
  url_launcher: ^6.3.2
  webview_flutter: ^4.13.0
  permission_handler: ^12.0.1
  connectivity_plus: ^6.1.2
  qr_flutter: ^4.1.0
  mime: ^2.0.0
```

**Flutter Structure:**
```
doan2/lib/
├── main.dart                       # Entry point
├── firebase_options.dart           # Firebase config
│
├── config/
│   └── app_config.dart             # App constants
│
├── core/
│   ├── api/
│   │   └── api_constants.dart      # API endpoints
│   └── constants/
│       └── app_constants.dart
│
├── models/                         # Data models
│   ├── common/
│   │   ├── user.dart
│   │   ├── doctor.dart
│   │   └── appointment.dart
│   ├── chat/
│   │   ├── conversation.dart
│   │   └── message.dart
│   └── health/
│       ├── health_record.dart
│       └── vitals.dart
│
├── presentation/                   # UI Screens
│   ├── auth/                       # Login, Register
│   ├── patient/                    # Patient screens
│   │   ├── home/
│   │   ├── appointments/
│   │   ├── doctors/
│   │   ├── chat/
│   │   ├── health/
│   │   └── profile/
│   ├── doctor/                     # Doctor screens
│   │   ├── dashboard/
│   │   ├── patients/
│   │   ├── appointments/
│   │   └── prescriptions/
│   ├── shared/                     # Shared screens
│   └── widgets/                    # Reusable widgets
│
└── service/                        # Services (15 files)
    ├── auth_service.dart
    ├── user_service.dart
    ├── doctor_service.dart
    ├── appointment_service.dart
    ├── prescription_service.dart
    ├── chat_service.dart
    ├── socket_service.dart
    ├── mqtt_service.dart
    ├── zego_service.dart           # Video calling
    ├── call_manager.dart
    ├── fcm_service.dart
    ├── notification_service.dart
    ├── predict_service.dart
    ├── article_service.dart
    └── reminder_service.dart
```

### 3.3. Admin Portal (Next.js 14)

**package.json:**
```json
{
  "name": "admin-portal",
  "version": "0.1.0",
  "dependencies": {
    "next": "^14.2.15",              // Next.js framework
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    
    // UI Components (shadcn/ui)
    "@radix-ui/react-alert-dialog": "^1.1.15",
    "@radix-ui/react-avatar": "^1.1.11",
    "@radix-ui/react-dialog": "^1.1.15",
    "@radix-ui/react-dropdown-menu": "^2.1.16",
    "@radix-ui/react-label": "^2.1.8",
    "@radix-ui/react-select": "^2.2.6",
    
    // Data Tables
    "@tanstack/react-query": "^5.90.16",
    "@tanstack/react-table": "^8.21.3",
    
    // Styling
    "tailwindcss": "^3.4.14",
    "tailwindcss-animate": "^1.0.7",
    "class-variance-authority": "^0.7.1",
    "clsx": "^2.1.1",
    "tailwind-merge": "^3.4.0",
    
    // Icons & Utilities
    "lucide-react": "^0.562.0",
    "react-icons": "^5.5.0",
    "date-fns": "^4.1.0",
    "sonner": "^2.0.7",
    "xlsx": "^0.18.5"                // Excel export
  },
  "devDependencies": {
    "@types/node": "^20",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "typescript": "^5"
  }
}
```

**Next.js Structure:**
```
admin-portal/src/
├── app/
│   ├── layout.tsx                  # Root layout
│   ├── page.tsx                    # Home page
│   ├── providers.tsx               # Context providers
│   ├── globals.css                 # Global styles
│   │
│   ├── auth/                       # Authentication
│   │   └── login/
│   │
│   ├── dashboard/                  # Dashboard
│   │   ├── page.tsx
│   │   ├── users/
│   │   ├── doctors/
│   │   ├── patients/
│   │   ├── appointments/
│   │   ├── prescriptions/
│   │   ├── medications/
│   │   └── analytics/
│   │
│   └── my-app/                     # Additional pages
│
├── components/
│   ├── ui/                         # shadcn/ui components
│   │   ├── button.tsx
│   │   ├── dialog.tsx
│   │   ├── table.tsx
│   │   └── ...
│   └── custom/                     # Custom components
│       ├── Sidebar.tsx
│       ├── Header.tsx
│       └── DataTable.tsx
│
└── lib/
    ├── utils.ts                    # Utility functions
    └── api.ts                      # API client
```

### 3.4. Database (PostgreSQL 16)

**Connection Configuration:**
```javascript
// config/db.js
const { Pool } = require('pg');

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'health_iot_db',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD,
    max: 20,                        // Connection pool size
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
});
```

---

## 4. DATABASE SCHEMA CHI TIẾT

### 4.1. Complete Entity Relationship Diagram (ERD)

```
┌──────────────────────────────────────────────────────────────────┐
│                 HEALTH IoT DATABASE SCHEMA (34 TABLES)            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────┐
│        users             │  ◄────┐
├──────────────────────────┤       │
│ PK id SERIAL             │       │
│    email VARCHAR(100)    │       │
│    password VARCHAR(255) │       │
│    role VARCHAR(20)      │       │ 1
│    is_verified BOOLEAN   │       │
│    avatar_url TEXT       │       │
│    fcm_token TEXT        │       │
│    created_at TIMESTAMP  │       │
└────────┬─────────────────┘       │
         │ 1                        │
         │                          │
         │ 1                        │
         ▼                          │
┌──────────────────────────┐       │
│       profiles           │       │
├──────────────────────────┤       │
│ PK user_id INTEGER (FK)  │       │
│    full_name VARCHAR     │       │
│    phone_number VARCHAR  │       │
│    date_of_birth DATE    │       │
│    gender VARCHAR(10)    │       │
│    address TEXT          │       │
└──────────────────────────┘       │
                                    │
         ┌──────────────────────────┤
         │ 1                        │
         ▼                          │
┌──────────────────────────────────┐│
│  patient_health_info             ││
├──────────────────────────────────┤│
│ PK patient_id INTEGER (FK)       ││
│    height NUMERIC(5,2)           ││
│    weight NUMERIC(5,2)           ││
│    blood_type VARCHAR(10)        ││
│    medical_history TEXT          ││
│    allergies TEXT                ││
│    insurance_number VARCHAR      ││
│    emergency_contact_name        ││
│    emergency_contact_phone       ││
│    lifestyle_info JSONB          ││
└──────────────────────────────────┘│
                                    │
         ┌──────────────────────────┤
         │ 1                        │
         ▼                          │
┌──────────────────────────────────┐│
│  doctor_professional_info        ││
├──────────────────────────────────┤│
│ PK doctor_id INTEGER (FK)        ││
│    specialty VARCHAR(100)        ││
│    hospital_name VARCHAR         ││
│    years_of_experience INT       ││
│    bio TEXT                      ││
│    consultation_fee NUMERIC      ││
│    rating_average NUMERIC(3,2)   ││
│    review_count INTEGER          ││
│    license_number VARCHAR        ││
│    education TEXT                ││
│    languages TEXT[]              ││
│    clinic_address TEXT           ││
│    clinic_images TEXT[]          ││
└──────────────┬───────────────────┘│
               │                    │
               │ 1                  │
               │                    │
               │ *                  │
               ▼                    │
┌──────────────────────────────────┐│
│     doctor_schedules             ││
├──────────────────────────────────┤│
│ PK id SERIAL                     ││
│ FK user_id INTEGER               ││
│    day_of_week INTEGER           ││
│    start_time TIME               ││
│    end_time TIME                 ││
│    is_active BOOLEAN             ││
└──────────────────────────────────┘│
                                    │
         ┌──────────────────────────┘
         │ *
         ▼
┌──────────────────────────────────┐
│       appointments               │
├──────────────────────────────────┤
│ PK id SERIAL                     │
│ FK patient_id INTEGER            │
│ FK doctor_id INTEGER             │
│    appointment_date TIMESTAMP    │
│    status VARCHAR(20)            │
│    notes TEXT                    │
│ FK type_id INTEGER               │
│    cancellation_reason TEXT      │
│    is_reviewed BOOLEAN           │
│    created_at TIMESTAMP          │
└────────┬─────────────────────────┘
         │ 1
         │
         │ *
         ▼
┌──────────────────────────────────┐
│      prescriptions               │
├──────────────────────────────────┤
│ PK id SERIAL                     │
│ FK patient_id INTEGER            │
│ FK doctor_id INTEGER             │
│    diagnosis TEXT                │
│    notes TEXT                    │
│    chief_complaint TEXT          │
│    clinical_findings TEXT        │
│    follow_up_date DATE           │
│    created_at TIMESTAMP          │
└────────┬─────────────────────────┘
         │ 1
         │
         │ *
         ▼
┌──────────────────────────────────┐
│    prescription_items            │
├──────────────────────────────────┤
│ PK id SERIAL                     │
│ FK prescription_id INTEGER       │
│ FK medication_id INTEGER         │
│    medication_name_snapshot      │
│    quantity VARCHAR(50)          │
│    dosage_instruction TEXT       │
│    created_at TIMESTAMP          │
└──────────────────────────────────┘
         │
         │ *
         ▼
┌──────────────────────────────────┐
│       medications                │
├──────────────────────────────────┤
│ PK id SERIAL                     │
│    name VARCHAR(255)             │
│    registration_number VARCHAR   │
│ FK category_id INTEGER           │
│ FK manufacturer_id INTEGER       │
│    unit VARCHAR(50)              │
│    packing_specification VARCHAR │
│    usage_route VARCHAR(50)       │
│    usage_instruction TEXT        │
│    price NUMERIC(10,2)           │
│    stock INTEGER                 │
│    min_stock INTEGER             │
│    is_active BOOLEAN             │
│    created_at TIMESTAMP          │
└────────┬─────────────────────────┘
         │
         ├─────► medication_categories (id, name, description)
         ├─────► manufacturers (id, name, country, website)
         └─────► medication_ingredients ◄───► active_ingredients

┌──────────────────────────────────┐
│      health_records              │
├──────────────────────────────────┤
│ PK id SERIAL                     │
│ FK user_id INTEGER               │
│    packet_id VARCHAR(50)         │
│    heart_rate INTEGER            │
│    spo2 NUMERIC(5,2)             │
│    temperature NUMERIC(5,2)      │
│    sleep_hours NUMERIC(4,2)      │
│    measured_at TIMESTAMP         │
│    created_at TIMESTAMP          │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│       ecg_readings               │
├──────────────────────────────────┤
│ PK id SERIAL                     │
│ FK user_id INTEGER               │
│    device_id VARCHAR(50)         │
│    packet_id VARCHAR(50)         │
│    data_points JSONB             │
│    sample_rate INTEGER           │
│    duration_seconds INTEGER      │
│    average_heart_rate INTEGER    │
│    result VARCHAR(100)           │
│    measured_at TIMESTAMP         │
│    created_at TIMESTAMP          │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│       ai_diagnoses               │
├──────────────────────────────────┤
│ PK id SERIAL                     │
│ FK user_id INTEGER               │
│ FK health_record_id INTEGER      │
│ FK ecg_reading_id INTEGER        │
│    model_type VARCHAR(20)        │
│    diagnosis_result VARCHAR      │
│    confidence_score NUMERIC(5,4) │
│    severity_level VARCHAR(20)    │
│    is_alert_sent BOOLEAN         │
│    created_at TIMESTAMP          │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│     mqtt_health_data             │
├──────────────────────────────────┤
│ PK id BIGSERIAL                  │
│ FK user_id INTEGER               │
│    topic_name VARCHAR(255)       │
│    heart_rate INTEGER            │
│    blood_pressure_systolic INT   │
│    blood_pressure_diastolic INT  │
│    temperature NUMERIC(5,2)      │
│    spo2 NUMERIC(5,2)             │
│    steps INTEGER                 │
│    calories INTEGER              │
│    sleep_hours NUMERIC(4,2)      │
│    device_id VARCHAR(100)        │
│    raw_data JSONB                │
│    received_at TIMESTAMP         │
│    created_at TIMESTAMP          │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│      conversations               │
├──────────────────────────────────┤
│ PK id BIGSERIAL                  │
│    last_message_content TEXT     │
│    last_message_at TIMESTAMP     │
│    created_at TIMESTAMP          │
└────────┬─────────────────────────┘
         │ 1
         │
         │ *
         ▼
┌──────────────────────────────────┐
│       participants               │
├──────────────────────────────────┤
│ PK conversation_id (FK)          │
│ PK user_id (FK)                  │
└──────────────────────────────────┘
         │
         │ 1
         │
         │ *
         ▼
┌──────────────────────────────────┐
│        messages                  │
├──────────────────────────────────┤
│ PK id BIGSERIAL                  │
│ FK conversation_id BIGINT        │
│ FK sender_id INTEGER             │
│    content TEXT                  │
│    message_type VARCHAR(20)      │
│    status VARCHAR(20)            │
│    is_read BOOLEAN               │
│    created_at TIMESTAMP          │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│       call_history               │
├──────────────────────────────────┤
│ PK id SERIAL                     │
│    call_id VARCHAR(255) UNIQUE   │
│ FK caller_id INTEGER             │
│ FK receiver_id INTEGER           │
│    call_type VARCHAR(20)         │
│    status VARCHAR(20)            │
│    duration INTEGER              │
│    start_time TIMESTAMP          │
│    end_time TIMESTAMP            │
│    created_at TIMESTAMP          │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│      notifications               │
├──────────────────────────────────┤
│ PK id SERIAL                     │
│ FK user_id INTEGER               │
│    title VARCHAR(255)            │
│    message TEXT                  │
│    type VARCHAR(50)              │
│    related_id INTEGER            │
│    is_read BOOLEAN               │
│    created_at TIMESTAMP          │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│        articles                  │
├──────────────────────────────────┤
│ PK id SERIAL                     │
│    title VARCHAR(255)            │
│    description TEXT              │
│    image_url TEXT                │
│    content_url TEXT              │
│    category VARCHAR(100)         │
│    published_at TIMESTAMP        │
│    source_name VARCHAR(100)      │
│    created_at TIMESTAMP          │
└──────────────────────────────────┘

Additional Tables:
• appointment_types
• doctor_reviews
• doctor_time_off
• doctor_notes
• patient_thresholds
• medication_reminders
• medical_attachments
```

### 4.2. Table Details

#### Core Tables Summary:

| Table Name | Purpose | Key Fields | Relationships |
|------------|---------|------------|---------------|
| **users** | User authentication | email, password, role, fcm_token | 1:1 profiles, 1:1 patient_health_info |
| **profiles** | User profile info | full_name, phone, date_of_birth, gender | N:1 users |
| **doctor_professional_info** | Doctor details | specialty, experience, consultation_fee | N:1 users |
| **doctor_schedules** | Working hours | day_of_week, start_time, end_time | N:1 users |
| **appointments** | Booking records | appointment_date, status | N:1 patient, N:1 doctor |
| **prescriptions** | Electronic prescriptions | diagnosis, notes | N:1 patient, N:1 doctor |
| **medications** | Drug database | name, price, stock | N:1 category, N:1 manufacturer |
| **health_records** | Vital readings | heart_rate, spo2, temperature | N:1 users |
| **ecg_readings** | ECG data | data_points (JSONB), sample_rate | N:1 users |
| **ai_diagnoses** | AI predictions | diagnosis_result, confidence_score | N:1 users |
| **mqtt_health_data** | IoT sensor data | All vitals, raw_data (JSONB) | N:1 users |
| **conversations** | Chat threads | last_message_content | M:N users via participants |
| **messages** | Chat messages | content, message_type, status | N:1 conversations |
| **call_history** | Video/Audio logs | call_id, call_type, duration | N:1 caller, N:1 receiver |
| **notifications** | Push notifications | title, message, type | N:1 users |
| **articles** | Health news | title, content_url, category | - |

---

*(Tiếp tục trong phần 2...)*
