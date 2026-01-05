# 🏥 HEALTHAI SERVER - TÀI LIỆU BACKEND (PART 1)

> **Backend API Server cho hệ thống Health_IoT**

---

## 📋 MỤC LỤC

### PART 1 (File này)
- [1. Tổng Quan](#1-tổng-quan)
- [2. Architecture](#2-architecture)
- [3. Tech Stack](#3-tech-stack)
- [4. Database Schema](#4-database-schema)
- [5. API Endpoints](#5-api-endpoints)
- [6. Authentication](#6-authentication)
- [7. MQTT Integration](#7-mqtt-integration)
- [8. Socket.IO Realtime](#8-socketio-realtime)

### PART 2
- [9. AI/ML Models](#9-aiml-models)
- [10. Services Layer](#10-services-layer)
- [11. Background Workers](#11-background-workers)
- [12. Configuration](#12-configuration)
- [13. Deployment](#13-deployment)

---

## 1. TỔNG QUAN

### 1.1 Giới Thiệu

HealthAI_Server là **backend API server** của hệ thống Health_IoT, xử lý:
- ✅ REST API cho Flutter App & Next.js Admin
- ✅ MQTT broker cho thiết bị ESP32
- ✅ Socket.IO cho chat & realtime
- ✅ AI/ML models (Heart disease prediction + ECG anomaly detection)
- ✅ PostgreSQL + TimescaleDB cho time-series data

### 1.2 Thông Tin Dự Án

| Thuộc tính | Giá trị |
|------------|---------|
| **Node.js Version** | 16.x - 20.x |
| **Framework** | Express.js 4.19+ |
| **Database** | PostgreSQL 14+ |
| **AI Engine** | TensorFlow.js (Node) |
| **Realtime** | Socket.IO 4.x |
| **IoT Protocol** | MQTT (HiveMQ Cloud) |

### 1.3 Cấu Trúc Thư Mục

```
HealthAI_Server/
├── app.js                          # Entry point
├── package.json                     # Dependencies
├── socket_manager.js                # Socket.IO setup
├── config/
│   ├── db.js                        # PostgreSQL connection pool
│   ├── aiModels.js                  # TensorFlow.js model loader
│   └── firebase-admin-sdk.json      # FCM credentials
├── controllers/                     # Controller layer (MVC)
│   ├── auth_controller.js
│   ├── predict_controller.js
│   ├── appointment_controller.js
│   ├── chat_controller.js
│   ├── doctor_controller.js
│   ├── mqtt_controller.js
│   ├── notification_controller.js
│   ├── prescription_controller.js
│   ├── reminder_controller.js
│   ├── user_controller.js
│   ├── health_stats_controller.js
│   ├── article_controller.js
│   └── admin_controller.js
├── services/                        # Business logic (Service layer)
│   ├── auth_service.js
│   ├── predict_service.js           # AI model inference
│   ├── appointment_service.js
│   ├── chat_service.js
│   ├── doctor_service.js
│   ├── mqtt_service.js              # MQTT HiveMQ client
│   ├── notification_service.js
│   ├── fcm_service.js               # Firebase Cloud Messaging
│   ├── prescription_service.js
│   ├── reminder_service.js
│   ├── user_service.js
│   ├── email_service.js
│   ├── crawl_service.js             # Web scraping for health articles
│   ├── call_history_service.js
│   └── health_analysis_service.js   # Realtime health data analysis
├── routes/                          # API routing
│   ├── index.js                     # Main router
│   ├── auth_routes.js
│   ├── predict_routes.js
│   ├── appointment_routes.js
│   ├── chat_routes.js
│   ├── doctor_routes.js
│   ├── mqtt_routes.js
│   ├── mqtt.js                      # MQTT API for app
│   ├── notification_routes.js
│   ├── prescription_routes.js
│   ├── reminder_routes.js
│   ├── user_routes.js
│   ├── health_stats_routes.js
│   ├── article_routes.js
│   ├── call_history.js
│   ├── sensor_warnings.js
│   └── admin_routes.js
├── middleware/
│   ├── authMiddleware.js            # JWT verification
│   └── admin_middleware.js          # Admin role check
├── workers/
│   ├── mqtt_worker.js               # MQTT message handler
│   ├── mqtt_cleanup_worker.js       # Cleanup old MQTT data
│   └── scheduler.js                 # Cron jobs (reminder notifications)
├── database/
│   ├── migrations.sql               # DB schema migrations
│   ├── seed_data.sql                # Sample data
│   └── migrations/                  # Migration scripts
├── ai_models/
│   ├── heart_disease_mlp/           # MLP model (89.3% accuracy)
│   │   ├── model.json
│   │   ├── group1-shard1of1.bin
│   │   ├── scaler_params.json
│   │   └── risk_encoder.json
│   └── ecg_anomaly_cnn/             # CNN model (ECG analysis)
│       ├── model.json
│       └── group1-shard1of1.bin
├── uploads/                         # User-uploaded files
│   ├── avatars/
│   ├── prescriptions/
│   └── chat_attachments/
└── logs/                            # Server logs
```

---

## 2. ARCHITECTURE

### 2.1 Kiến Trúc MVC-S (Model-View-Controller-Service)

```
┌─────────────────────────────────────────────────────────────┐
│                      CLIENT LAYER                           │
│  (Flutter App, Next.js Admin, ESP32 Devices)               │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                   ROUTING LAYER                             │
│  routes/index.js → Phân luồng request đến Controllers       │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                 CONTROLLER LAYER                            │
│  - Xử lý HTTP request/response                             │
│  - Validate input                                           │
│  - Gọi Service layer                                        │
│  - Format output                                            │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                  SERVICE LAYER                              │
│  - Business logic                                           │
│  - Database queries                                         │
│  - AI model inference                                       │
│  - External API calls                                       │
│  - MQTT publishing                                          │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                   DATA LAYER                                │
│  - PostgreSQL (Users, Appointments, Messages)              │
│  - TimescaleDB (Health Records, ECG Data)                  │
│  - MQTT Broker (HiveMQ Cloud)                              │
│  - Firebase Cloud Messaging                                │
│  - TensorFlow.js Models                                    │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Flow Diagram: IoT Data Processing

```
┌─────────────┐
│  ESP32 IoT  │ ─── (MQTTS 8883) ──> [HiveMQ Cloud]
│   Device    │                            │
└─────────────┘                            │
                                           ▼
                          ┌────────────────────────────┐
                          │  mqtt_worker.js            │
                          │  - Subscribe topic         │
                          │  - Parse JSON payload      │
                          └────────┬───────────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    ▼              ▼              ▼
         ┌──────────────┐  ┌─────────────┐  ┌──────────────┐
         │  PostgreSQL  │  │ Socket.IO   │  │ AI Analysis  │
         │  (Save data) │  │ (Realtime)  │  │ (Prediction) │
         └──────────────┘  └─────────────┘  └──────────────┘
                                   │
                                   ▼
                          ┌─────────────────┐
                          │  Flutter App    │
                          │  (Live update)  │
                          └─────────────────┘
```

---

## 3. TECH STACK

### 3.1 Core Dependencies

```json
{
  "dependencies": {
    // Web Framework
    "express": "^4.19.2",
    "cors": "^2.8.5",
    "dotenv": "^16.4.5",
    
    // Database
    "pg": "^8.11.5",                    // PostgreSQL driver
    
    // Authentication
    "jsonwebtoken": "^9.0.2",           // JWT tokens
    "bcryptjs": "^2.4.3",               // Password hashing
    
    // Realtime & IoT
    "socket.io": "^4.7.5",              // WebSocket server
    "mqtt": "^5.6.1",                   // MQTT client
    
    // AI/ML
    "@tensorflow/tfjs-node": "^4.18.0", // TensorFlow.js (Node.js backend)
    
    // Push Notifications
    "firebase-admin": "^12.1.0",        // FCM
    
    // Email
    "nodemailer": "^6.9.13",
    
    // Cron Jobs
    "node-cron": "^3.0.3",
    
    // Web Scraping
    "axios": "^1.7.2",
    "cheerio": "^1.0.0-rc.12",
    
    // Utilities
    "moment": "^2.30.1",                // Date/time handling
    "multer": "^1.4.5-lts.1"            // File upload
  }
}
```

### 3.2 Environment Variables

```env
# .env file
PORT=5000
NODE_ENV=production

# PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=health_iot
DB_USER=postgres
DB_PASSWORD=your_password

# JWT Secret
JWT_SECRET=your_secret_key_here

# MQTT HiveMQ Cloud
MQTT_BROKER=7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud
MQTT_PORT=8883
MQTT_USER=DoAn1
MQTT_PASSWORD=Th123321

# Firebase Cloud Messaging
FCM_PROJECT_ID=your_project_id

# Email (Nodemailer)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_app_password

# Frontend URLs
FLUTTER_APP_URL=http://localhost:8080
NEXT_ADMIN_URL=http://localhost:3000
```

---

## 4. DATABASE SCHEMA

### 4.1 Users & Authentication

#### Table: `users`
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,             -- Bcrypt hash
    role VARCHAR(20) NOT NULL DEFAULT 'patient', -- 'patient', 'doctor', 'admin'
    is_verified BOOLEAN DEFAULT FALSE,
    avatar_url TEXT,
    reset_password_token VARCHAR(10),
    reset_password_expires TIMESTAMPTZ,
    fcm_token TEXT,                              -- Firebase token for push
    verification_token VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Table: `profiles`
```sql
CREATE TABLE profiles (
    user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(100),
    phone_number VARCHAR(20),
    date_of_birth DATE,
    gender VARCHAR(10),                          -- 'male', 'female'
    address TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.2 Doctors

#### Table: `doctor_professional_info`
```sql
CREATE TABLE doctor_professional_info (
    doctor_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    specialty VARCHAR(100),                      -- 'Cardiology', 'General', etc.
    hospital_name VARCHAR(150),
    years_of_experience INTEGER,
    bio TEXT,
    consultation_fee NUMERIC(10,2),
    rating_average NUMERIC(3,2) DEFAULT 0.0,     -- 0.00 - 5.00
    review_count INTEGER DEFAULT 0,
    license_number VARCHAR(50),
    education TEXT,
    languages TEXT[],                            -- PostgreSQL array
    clinic_address TEXT,
    clinic_images TEXT[]                         -- Array of image URLs
);
```

#### Table: `doctor_schedules`
```sql
CREATE TABLE doctor_schedules (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    day_of_week INTEGER,                         -- 1=Mon, 7=Sun
    start_time TIME NOT NULL,                    -- '08:00:00'
    end_time TIME NOT NULL,                      -- '17:00:00'
    is_active BOOLEAN DEFAULT TRUE
);
```

#### Table: `doctor_time_off`
```sql
CREATE TABLE doctor_time_off (
    id SERIAL PRIMARY KEY,
    doctor_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.3 Appointments

#### Table: `appointments`
```sql
CREATE TABLE appointments (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    doctor_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    appointment_date TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',        -- 'pending', 'confirmed', 'completed', 'cancelled'
    notes TEXT,
    type_id INTEGER REFERENCES appointment_types(id),
    cancellation_reason TEXT,
    is_reviewed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Table: `appointment_types`
```sql
CREATE TABLE appointment_types (
    id SERIAL PRIMARY KEY,
    doctor_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,                  -- 'Consultation', 'Follow-up', etc.
    duration_minutes INTEGER DEFAULT 30,
    price NUMERIC(10,2),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE
);
```

### 4.4 Health Data (TimescaleDB Hypertables)

#### Table: `health_records`
```sql
CREATE TABLE health_records (
    id SERIAL,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    heart_rate INTEGER,
    spo2 INTEGER,
    temperature NUMERIC(4,2),
    measured_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id, measured_at)
);

-- Convert to hypertable (TimescaleDB)
SELECT create_hypertable('health_records', 'measured_at', 
    chunk_time_interval => INTERVAL '1 day');
```

#### Table: `ecg_readings`
```sql
CREATE TABLE ecg_readings (
    id SERIAL,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    packet_id INTEGER NOT NULL,
    data_points INTEGER[] NOT NULL,              -- Array of 100 values
    measured_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id, measured_at)
);

SELECT create_hypertable('ecg_readings', 'measured_at',
    chunk_time_interval => INTERVAL '1 day');
```

### 4.5 AI Predictions

#### Table: `ai_predictions`
```sql
CREATE TABLE ai_predictions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    model_type VARCHAR(50) NOT NULL,             -- 'MLP_HEART_DISEASE', 'CNN_ECG_ANOMALY'
    input_data JSONB NOT NULL,                   -- Input features
    prediction_class VARCHAR(50),                -- 'Low Risk', 'Medium Risk', etc.
    confidence_score NUMERIC(5,4),               -- 0.0000 - 1.0000
    output_probabilities JSONB,                  -- Softmax output
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.6 Chat & Messaging

#### Table: `conversations`
```sql
CREATE TABLE conversations (
    id SERIAL PRIMARY KEY,
    last_message_content TEXT,
    last_message_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Table: `participants`
```sql
CREATE TABLE participants (
    conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (conversation_id, user_id)
);
```

#### Table: `messages`
```sql
CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id INTEGER NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text',     -- 'text', 'image', 'file'
    status VARCHAR(20) DEFAULT 'sent',           -- 'sent', 'delivered', 'seen'
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
```

### 4.7 Notifications

#### Table: `notifications`
```sql
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,                   -- 'HEALTH_ALERT', 'APPOINTMENT', 'MESSAGE'
    related_id INTEGER,                          -- ID liên quan (appointment_id, message_id, etc.)
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read);
```

### 4.8 Medications & Prescriptions

#### Table: `medications`
```sql
CREATE TABLE medications (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    registration_number VARCHAR(50),
    category_id INTEGER REFERENCES medication_categories(id),
    manufacturer_id INTEGER REFERENCES manufacturers(id),
    unit VARCHAR(50) NOT NULL,                   -- 'Viên', 'Ống', 'Hộp'
    packing_specification VARCHAR(255),
    usage_route VARCHAR(50),                     -- 'Uống', 'Tiêm', 'Bôi ngoài da'
    usage_instruction TEXT,
    price NUMERIC(10,2) DEFAULT 0,
    stock INTEGER DEFAULT 0,
    min_stock INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Table: `prescriptions`
```sql
CREATE TABLE prescriptions (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    doctor_id INTEGER NOT NULL REFERENCES users(id),
    appointment_id INTEGER REFERENCES appointments(id),
    diagnosis TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Table: `prescription_items`
```sql
CREATE TABLE prescription_items (
    id SERIAL PRIMARY KEY,
    prescription_id INTEGER NOT NULL REFERENCES prescriptions(id) ON DELETE CASCADE,
    medication_id INTEGER REFERENCES medications(id),
    medication_name VARCHAR(255) NOT NULL,       -- Lưu tên để backup
    dosage VARCHAR(100),                         -- '1 viên'
    frequency VARCHAR(100),                      -- '2 lần/ngày'
    duration VARCHAR(100),                       -- '7 ngày'
    instructions TEXT
);
```

---

## 5. API ENDPOINTS

### 5.1 Authentication (`/api/auth`)

#### POST `/api/auth/register`
**Description**: Đăng ký tài khoản mới

**Request Body**:
```json
{
  "email": "patient@example.com",
  "password": "Password123!",
  "fullName": "Nguyen Van A",
  "phone": "0901234567",
  "dateOfBirth": "1990-01-01",
  "gender": "male",
  "role": "patient"
}
```

**Response** (201):
```json
{
  "success": true,
  "message": "Đăng ký thành công",
  "user": {
    "id": 10,
    "email": "patient@example.com",
    "role": "patient"
  }
}
```

#### POST `/api/auth/login`
**Description**: Đăng nhập

**Request Body**:
```json
{
  "email": "patient@example.com",
  "password": "Password123!"
}
```

**Response** (200):
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 10,
    "email": "patient@example.com",
    "role": "patient",
    "fullName": "Nguyen Van A",
    "avatarUrl": "https://..."
  }
}
```

#### POST `/api/auth/logout`
**Description**: Đăng xuất (xóa FCM token)

**Headers**: `Authorization: Bearer <token>`

**Response** (200):
```json
{
  "success": true,
  "message": "Đã đăng xuất"
}
```

#### POST `/api/auth/forgot-password`
**Description**: Gửi mã reset password qua email

**Request Body**:
```json
{
  "email": "patient@example.com"
}
```

#### POST `/api/auth/reset-password`
**Description**: Reset password với mã xác nhận

**Request Body**:
```json
{
  "email": "patient@example.com",
  "resetCode": "123456",
  "newPassword": "NewPass123!"
}
```

---

### 5.2 User Profile (`/api/user`)

#### GET `/api/user/profile`
**Description**: Lấy thông tin profile

**Headers**: `Authorization: Bearer <token>`

**Response** (200):
```json
{
  "id": 10,
  "email": "patient@example.com",
  "fullName": "Nguyen Van A",
  "phone": "0901234567",
  "dateOfBirth": "1990-01-01",
  "gender": "male",
  "address": "123 Main St",
  "avatarUrl": "https://...",
  "role": "patient",
  "healthInfo": {
    "height": 170,
    "weight": 65,
    "bloodType": "A+",
    "allergies": "Penicillin"
  }
}
```

#### PUT `/api/user/profile`
**Description**: Cập nhật profile

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "fullName": "Nguyen Van A Updated",
  "phone": "0909999999",
  "address": "New address"
}
```

#### POST `/api/user/upload-avatar`
**Description**: Upload avatar

**Headers**: `Authorization: Bearer <token>`

**Request**: `multipart/form-data` với field `avatar`

---

### 5.3 Doctors (`/api/doctors`)

#### GET `/api/doctors`
**Description**: Lấy danh sách bác sĩ (có filter)

**Query Parameters**:
- `specialty`: Chuyên khoa (Cardiology, General, etc.)
- `search`: Tìm kiếm theo tên
- `page`: Trang (default: 1)
- `limit`: Số lượng/trang (default: 10)

**Response** (200):
```json
{
  "doctors": [
    {
      "id": 2,
      "fullName": "Dr. Tran Thi B",
      "specialty": "Cardiology",
      "hospitalName": "Cho Ray Hospital",
      "yearsOfExperience": 15,
      "consultationFee": 200000,
      "ratingAverage": 4.5,
      "reviewCount": 120,
      "avatarUrl": "https://..."
    }
  ],
  "pagination": {
    "total": 50,
    "page": 1,
    "limit": 10,
    "totalPages": 5
  }
}
```

#### GET `/api/doctors/:id`
**Description**: Lấy thông tin chi tiết bác sĩ

**Response** (200):
```json
{
  "id": 2,
  "fullName": "Dr. Tran Thi B",
  "email": "doctor@example.com",
  "specialty": "Cardiology",
  "hospitalName": "Cho Ray Hospital",
  "yearsOfExperience": 15,
  "bio": "Experienced cardiologist...",
  "consultationFee": 200000,
  "ratingAverage": 4.5,
  "reviewCount": 120,
  "licenseNumber": "BYT-12345",
  "education": "MD from Ho Chi Minh City University",
  "languages": ["Vietnamese", "English"],
  "clinicAddress": "215 Hong Bang, District 5, HCMC",
  "clinicImages": ["https://..."],
  "schedules": [
    {
      "dayOfWeek": 1,
      "startTime": "08:00",
      "endTime": "17:00"
    }
  ]
}
```

#### GET `/api/doctors/:id/availability`
**Description**: Lấy lịch trống 7 ngày tới

**Response** (200):
```json
{
  "availability": [
    {
      "date": "2024-01-10",
      "dayOfWeek": 1,
      "isWorking": true,
      "slots": [
        { "time": "08:00", "isBooked": false },
        { "time": "08:30", "isBooked": true },
        { "time": "09:00", "isBooked": false }
      ]
    },
    {
      "date": "2024-01-11",
      "dayOfWeek": 2,
      "isWorking": false,
      "note": "Nghỉ lễ"
    }
  ]
}
```

---

### 5.4 Appointments (`/api/appointments`)

#### POST `/api/appointments`
**Description**: Đặt lịch hẹn

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "doctorId": 2,
  "appointmentDate": "2024-01-10T08:00:00Z",
  "notes": "Đau ngực, khó thở",
  "typeId": 1
}
```

**Response** (201):
```json
{
  "success": true,
  "appointmentId": 15,
  "message": "Đặt lịch thành công"
}
```

#### GET `/api/appointments/my`
**Description**: Lấy danh sách lịch hẹn của tôi

**Headers**: `Authorization: Bearer <token>`

**Response** (200):
```json
{
  "appointments": [
    {
      "id": 15,
      "doctorName": "Dr. Tran Thi B",
      "doctorAvatar": "https://...",
      "specialty": "Cardiology",
      "appointmentDate": "2024-01-10T08:00:00Z",
      "status": "pending",
      "notes": "Đau ngực, khó thở",
      "createdAt": "2024-01-05T10:00:00Z"
    }
  ]
}
```

#### PUT `/api/appointments/:id/cancel`
**Description**: Hủy lịch hẹn

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "reason": "Có việc đột xuất"
}
```

---

### 5.5 Health Stats (`/api/health-stats`)

#### GET `/api/health-stats/latest`
**Description**: Lấy chỉ số sức khỏe mới nhất

**Headers**: `Authorization: Bearer <token>`

**Response** (200):
```json
{
  "heartRate": 75,
  "spo2": 98,
  "temperature": 36.5,
  "measuredAt": "2024-01-05T10:30:00Z"
}
```

#### GET `/api/health-stats/history`
**Description**: Lấy lịch sử sức khỏe

**Query Parameters**:
- `startDate`: Ngày bắt đầu (ISO 8601)
- `endDate`: Ngày kết thúc
- `metric`: Chỉ số cần lấy (heart_rate, spo2, temperature)

**Response** (200):
```json
{
  "data": [
    {
      "heartRate": 75,
      "spo2": 98,
      "temperature": 36.5,
      "measuredAt": "2024-01-05T10:30:00Z"
    }
  ],
  "stats": {
    "avgHeartRate": 72,
    "minHeartRate": 60,
    "maxHeartRate": 85,
    "avgSpo2": 97,
    "avgTemperature": 36.6
  }
}
```

---

## 6. AUTHENTICATION

### 6.1 JWT Token Strategy

#### Token Generation
```javascript
// services/auth_service.js
const jwt = require('jsonwebtoken');

const generateToken = (user) => {
    const payload = {
        id: user.id,
        email: user.email,
        role: user.role
    };
    
    return jwt.sign(payload, process.env.JWT_SECRET, {
        expiresIn: '30d'  // Token hết hạn sau 30 ngày
    });
};
```

#### Token Verification Middleware
```javascript
// middleware/authMiddleware.js
const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
    
    if (!token) {
        return res.status(401).json({ 
            success: false, 
            message: 'Không có token' 
        });
    }
    
    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ 
                success: false, 
                message: 'Token không hợp lệ' 
            });
        }
        
        req.user = user;  // Gắn user vào request
        next();
    });
};
```

### 6.2 Password Hashing

```javascript
// services/auth_service.js
const bcrypt = require('bcryptjs');

// Hash password khi đăng ký
const register = async ({ email, password, fullName, ... }) => {
    const hashedPassword = await bcrypt.hash(password, 10);
    
    const result = await pool.query(
        'INSERT INTO users (email, password, ...) VALUES ($1, $2, ...)',
        [email, hashedPassword, ...]
    );
    
    return result.rows[0];
};

// Verify password khi đăng nhập
const login = async ({ email, password }) => {
    const user = await pool.query(
        'SELECT * FROM users WHERE email = $1',
        [email]
    );
    
    if (user.rows.length === 0) {
        throw new Error('Email không tồn tại');
    }
    
    const isValid = await bcrypt.compare(password, user.rows[0].password);
    
    if (!isValid) {
        throw new Error('Mật khẩu không đúng');
    }
    
    return user.rows[0];
};
```

### 6.3 Role-Based Access Control (RBAC)

```javascript
// middleware/admin_middleware.js
const requireAdmin = (req, res, next) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({
            success: false,
            message: 'Chỉ admin mới có quyền truy cập'
        });
    }
    next();
};

// Sử dụng trong routes
router.get('/admin/users', authenticateToken, requireAdmin, adminController.getUsers);
```

---

## 7. MQTT INTEGRATION

### 7.1 HiveMQ Cloud Configuration

```javascript
// services/mqtt_service.js
const mqtt = require('mqtt');

const MQTT_CONFIG = {
    broker: '7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud',
    port: 8883,                    // TLS/SSL
    username: 'DoAn1',
    password: 'Th123321',
    protocol: 'mqtts'
};

let mqttClient = null;

const connect = () => {
    return new Promise((resolve, reject) => {
        mqttClient = mqtt.connect(`mqtts://${MQTT_CONFIG.broker}:${MQTT_CONFIG.port}`, {
            username: MQTT_CONFIG.username,
            password: MQTT_CONFIG.password,
            rejectUnauthorized: true,  // Verify SSL certificate
            keepalive: 60,
            reconnectPeriod: 5000
        });
        
        mqttClient.on('connect', () => {
            console.log('✅ MQTT Connected to HiveMQ Cloud');
            resolve();
        });
        
        mqttClient.on('error', (err) => {
            console.error('❌ MQTT Connection Error:', err);
            reject(err);
        });
    });
};
```

### 7.2 Topic Structure

| Topic | Direction | Payload | Description |
|-------|-----------|---------|-------------|
| `iot/vital/{userId}` | ESP32 → Server | Vital signs JSON | Nhịp tim, SpO2, nhiệt độ |
| `device/ecg_data` | ESP32 → Server | ECG batch JSON | 100 điểm ECG |
| `iot/control/{userId}` | Server → ESP32 | Control commands | Lệnh điều khiển thiết bị |

### 7.3 MQTT Worker (Subscriber)

```javascript
// workers/mqtt_worker.js
const { pool } = require('../config/db');
const notifService = require('../services/notification_service');

const TOPIC_VITAL = 'iot/vital/+';       // Wildcard: iot/vital/10, iot/vital/15, etc.
const TOPIC_ECG = 'device/ecg_data';

const connectMQTT = () => {
    mqttService.connect().then(() => {
        // Subscribe to topics
        mqttClient.subscribe([TOPIC_VITAL, TOPIC_ECG], (err) => {
            if (!err) {
                console.log(`📡 Subscribed to: ${TOPIC_VITAL}, ${TOPIC_ECG}`);
            }
        });
        
        // Handle incoming messages
        mqttClient.on('message', async (topic, message) => {
            try {
                const payload = JSON.parse(message.toString());
                
                if (topic.startsWith('iot/vital/')) {
                    await handleVitalData(payload);
                } else if (topic === 'device/ecg_data') {
                    await handleEcgData(payload);
                }
            } catch (error) {
                console.error('❌ MQTT Message Processing Error:', error);
            }
        });
    });
};

const handleVitalData = async (payload) => {
    const { userID, heart_rate, spo2, temperature } = payload;
    
    console.log(`📥 Vital Data from User ${userID}:`, payload);
    
    // 1. Save to database
    const result = await pool.query(`
        INSERT INTO health_records (user_id, heart_rate, spo2, temperature)
        VALUES ($1, $2, $3, $4)
        RETURNING id
    `, [userID, heart_rate, spo2, temperature]);
    
    const recordId = result.rows[0].id;
    
    // 2. Emit Socket.IO event
    if (global.io) {
        global.io.to(`user_${userID}`).emit('mqtt_data_activity', {
            type: 'vital_signs',
            data: payload,
            timestamp: new Date()
        });
    }
    
    // 3. Check alerts (Rule-based)
    const alerts = [];
    if (heart_rate > 100) {
        alerts.push(`Nhịp tim cao: ${heart_rate} BPM`);
    }
    if (spo2 < 90 && spo2 > 0) {
        alerts.push(`SpO2 thấp: ${spo2}%`);
    }
    
    if (alerts.length > 0) {
        await notifService.createNotification({
            userId: userID,
            title: 'CẢNH BÁO SỨC KHỎE ⚠️',
            message: alerts.join(', '),
            type: 'HEALTH_ALERT',
            relatedId: recordId
        });
    }
};

const handleEcgData = async (payload) => {
    const { userID, packet_id, dataPoints } = payload;
    
    // Save ECG batch
    await pool.query(`
        INSERT INTO ecg_readings (user_id, packet_id, data_points)
        VALUES ($1, $2, $3)
    `, [userID, packet_id, dataPoints]);
    
    // Emit Socket.IO
    if (global.io) {
        global.io.to(`user_${userID}`).emit('ecg_batch', payload);
    }
};
```

### 7.4 MQTT Cleanup Worker

```javascript
// workers/mqtt_cleanup_worker.js
const cron = require('node-cron');
const { pool } = require('../config/db');

let cleanupJob = null;

const start = () => {
    // Chạy mỗi ngày lúc 2:00 AM
    cleanupJob = cron.schedule('0 2 * * *', async () => {
        console.log('🧹 [Cleanup] Starting MQTT data cleanup...');
        
        try {
            // Xóa dữ liệu sức khỏe cũ hơn 90 ngày
            const healthResult = await pool.query(`
                DELETE FROM health_records
                WHERE measured_at < NOW() - INTERVAL '90 days'
            `);
            
            // Xóa dữ liệu ECG cũ hơn 30 ngày
            const ecgResult = await pool.query(`
                DELETE FROM ecg_readings
                WHERE measured_at < NOW() - INTERVAL '30 days'
            `);
            
            console.log(`✅ [Cleanup] Deleted ${healthResult.rowCount} health records`);
            console.log(`✅ [Cleanup] Deleted ${ecgResult.rowCount} ECG readings`);
        } catch (error) {
            console.error('❌ [Cleanup] Error:', error);
        }
    });
    
    console.log('✅ MQTT Cleanup Worker started (Daily 2:00 AM)');
};

const stop = () => {
    if (cleanupJob) {
        cleanupJob.stop();
        console.log('⏹️ MQTT Cleanup Worker stopped');
    }
};

module.exports = { start, stop };
```

---

## 8. SOCKET.IO REALTIME

### 8.1 Socket.IO Setup

```javascript
// socket_manager.js
const socketIo = require('socket.io');
const jwt = require('jsonwebtoken');

let io;
const onlineUsers = new Map();  // userId -> socketId

const initSocket = (server) => {
    io = socketIo(server, {
        cors: { origin: "*" },
        pingTimeout: 60000,
        pingInterval: 25000
    });
    
    global.io = io;  // Make io available globally
    
    // JWT Authentication Middleware
    io.use((socket, next) => {
        const token = socket.handshake.auth.token || socket.handshake.query.token;
        
        if (!token) {
            return next(new Error("Authentication error"));
        }
        
        jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
            if (err) return next(new Error("Authentication error"));
            socket.user = user;  // Attach user to socket
            next();
        });
    });
    
    io.on('connection', (socket) => {
        const userId = socket.user.id.toString();
        
        console.log(`\n${'='.repeat(60)}`);
        console.log(`⚡ [SOCKET] USER CONNECTED`);
        console.log(`   User ID: ${userId}`);
        console.log(`   Socket ID: ${socket.id}`);
        console.log(`${'='.repeat(60)}\n`);
        
        // Track online status
        onlineUsers.set(userId, socket.id);
        io.emit('user_status_change', { userId, isOnline: true });
        
        // Join user-specific room
        socket.join(`user_${userId}`);
        
        // Handle events
        setupSocketEvents(socket, userId);
        
        // Handle disconnect
        socket.on('disconnect', () => {
            console.log(`👋 [SOCKET] User ${userId} disconnected`);
            onlineUsers.delete(userId);
            io.emit('user_status_change', { userId, isOnline: false });
        });
    });
};

const setupSocketEvents = (socket, userId) => {
    // Join chat conversation
    socket.on('join_conversation', (data, ack) => {
        const conversationId = data.conversationId || data;
        const room = conversationId.toString();
        socket.join(room);
        
        console.log(`🔗 [SOCKET] User ${userId} joined conversation ${room}`);
        
        if (ack && typeof ack === 'function') {
            ack({ success: true, room, userId });
        }
    });
    
    // Leave conversation
    socket.on('leave_conversation', (data) => {
        const conversationId = data.conversationId || data;
        socket.leave(conversationId.toString());
    });
    
    // Mark messages as read
    socket.on('mark_read', async (data) => {
        const { conversationId } = data;
        
        // Update database
        const updatedMessages = await chatService.markMessagesAsRead(conversationId, userId);
        
        // Emit status update to room
        updatedMessages.forEach(msg => {
            io.to(conversationId.toString()).emit('message_status_update', {
                conversationId,
                messageId: msg.id.toString(),
                status: 'seen',
                readerId: userId
            });
        });
    });
    
    // Typing indicator
    socket.on('typing', (data) => {
        const { conversationId } = data;
        socket.to(conversationId.toString()).emit('user_typing', {
            userId,
            conversationId
        });
    });
};

module.exports = { initSocket };
```

### 8.2 Socket Events

#### Client → Server Events

| Event | Payload | Description |
|-------|---------|-------------|
| `join_conversation` | `{ conversationId: 10 }` | Join chat room |
| `leave_conversation` | `{ conversationId: 10 }` | Leave chat room |
| `mark_read` | `{ conversationId: 10 }` | Mark messages as read |
| `typing` | `{ conversationId: 10 }` | Typing indicator |

#### Server → Client Events

| Event | Payload | Description |
|-------|---------|-------------|
| `user_status_change` | `{ userId: "10", isOnline: true }` | User online/offline |
| `mqtt_data_activity` | `{ type: "vital_signs", data: {...} }` | New IoT data |
| `ecg_batch` | `{ packet_id: 0, dataPoints: [...] }` | New ECG batch |
| `new_message` | `{ conversationId, message: {...} }` | New chat message |
| `message_status_update` | `{ messageId, status: "seen" }` | Message read status |
| `user_typing` | `{ userId, conversationId }` | User is typing |
| `new_notification` | `{ title, message, type }` | New notification |

---

**✅ KẾT THÚC PART 1**

👉 Tiếp tục đọc [SERVER_DOCUMENTATION_PART2.md](SERVER_DOCUMENTATION_PART2.md) để tìm hiểu về:
- AI/ML Models (MLP + CNN)
- Services Layer chi tiết
- Background Workers
- Deployment & Best Practices
