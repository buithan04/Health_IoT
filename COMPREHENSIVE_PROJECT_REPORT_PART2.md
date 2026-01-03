# BÁO CÁO TOÀN DIỆN DỰ ÁN HEALTH IoT - PHẦN 2

## 5. BACKEND API DOCUMENTATION

### 5.1. API Overview

**Base URL:** `http://localhost:5000/api`

**Total Endpoints:** 100+ across 14 route groups

**Authentication:** JWT Token (Bearer Authorization)

### 5.2. Authentication APIs (`/api/auth`)

#### 1. POST /api/auth/register
**Đăng ký tài khoản mới**

Request:
```json
{
  "email": "user@example.com",
  "password": "Password123!",
  "role": "patient",
  "full_name": "Nguyễn Văn A",
  "phone_number": "0912345678",
  "date_of_birth": "1990-01-01",
  "gender": "male"
}
```

Response (200):
```json
{
  "message": "Registration successful. Please check your email.",
  "userId": 123,
  "verificationToken": "abc123xyz..."
}
```

#### 2. POST /api/auth/verify-email
**Xác thực email**

Request:
```json
{
  "token": "abc123xyz..."
}
```

Response (200):
```json
{
  "message": "Email verified successfully"
}
```

#### 3. POST /api/auth/login
**Đăng nhập**

Request:
```json
{
  "email": "user@example.com",
  "password": "Password123!"
}
```

Response (200):
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 123,
    "email": "user@example.com",
    "role": "patient",
    "is_verified": true,
    "avatar_url": "https://...",
    "profile": {
      "full_name": "Nguyễn Văn A",
      "phone_number": "0912345678",
      "date_of_birth": "1990-01-01",
      "gender": "male"
    }
  }
}
```

#### 4. POST /api/auth/forgot-password
**Quên mật khẩu**

Request:
```json
{
  "email": "user@example.com"
}
```

Response (200):
```json
{
  "message": "Password reset email sent"
}
```

#### 5. POST /api/auth/reset-password
**Đặt lại mật khẩu**

Request:
```json
{
  "token": "reset-token-123",
  "newPassword": "NewPassword123!"
}
```

Response (200):
```json
{
  "message": "Password reset successfully"
}
```

#### 6. POST /api/auth/logout
**Đăng xuất**

Headers:
```
Authorization: Bearer <token>
```

Response (200):
```json
{
  "message": "Logged out successfully"
}
```

#### 7. POST /api/auth/create-doctor
**Tạo tài khoản bác sĩ (Admin only)**

Request:
```json
{
  "email": "doctor@hospital.com",
  "password": "Doctor123!",
  "full_name": "BS. Trần Văn B",
  "phone_number": "0987654321",
  "specialty": "Cardiology",
  "hospital_name": "Bệnh viện Chợ Rẫy",
  "years_of_experience": 10,
  "license_number": "BS123456"
}
```

### 5.3. User APIs (`/api/user`)

#### 1. GET /api/user/profile
**Lấy thông tin profile**

Headers:
```
Authorization: Bearer <token>
```

Response (200):
```json
{
  "id": 123,
  "email": "user@example.com",
  "role": "patient",
  "avatar_url": "https://cloudinary.com/...",
  "profile": {
    "full_name": "Nguyễn Văn A",
    "phone_number": "0912345678",
    "date_of_birth": "1990-01-01",
    "gender": "male",
    "address": "123 Lê Lợi, Q1, HCM"
  },
  "health_info": {
    "height": 170,
    "weight": 65,
    "blood_type": "A+",
    "allergies": "Penicillin",
    "medical_history": "Diabetes",
    "insurance_number": "INS123456",
    "emergency_contact_name": "Nguyễn Thị C",
    "emergency_contact_phone": "0909123456"
  }
}
```

#### 2. PUT /api/user/profile
**Cập nhật profile**

Request:
```json
{
  "full_name": "Nguyễn Văn A Updated",
  "phone_number": "0912345679",
  "address": "456 Nguyễn Huệ, Q1, HCM",
  "height": 171,
  "weight": 66
}
```

#### 3. POST /api/user/upload-avatar
**Upload avatar**

Request (multipart/form-data):
```
file: <image file>
```

Response (200):
```json
{
  "message": "Avatar uploaded successfully",
  "avatar_url": "https://res.cloudinary.com/..."
}
```

#### 4. GET /api/user/dashboard-info
**Dashboard info (Patient)**

Response (200):
```json
{
  "upcoming_appointments": 2,
  "total_appointments": 15,
  "unread_messages": 3,
  "active_prescriptions": 2,
  "recent_health_records": [
    {
      "id": 456,
      "heart_rate": 75,
      "spo2": 98,
      "temperature": 36.5,
      "measured_at": "2026-01-04T10:30:00Z"
    }
  ],
  "latest_ai_diagnosis": {
    "id": 789,
    "model_type": "mlp",
    "diagnosis_result": "Low risk",
    "confidence_score": 0.92,
    "severity_level": "low",
    "created_at": "2026-01-04T09:00:00Z"
  }
}
```

#### 5. POST /api/user/fcm-token
**Cập nhật FCM token**

Request:
```json
{
  "fcm_token": "fVL8F5X... (Firebase token)"
}
```

#### 6. GET /api/user/my-reviews
**Lấy danh sách reviews của user**

Response (200):
```json
{
  "reviews": [
    {
      "id": 101,
      "doctor_id": 5,
      "doctor_name": "BS. Trần Văn B",
      "rating": 5,
      "comment": "Rất chuyên nghiệp!",
      "created_at": "2025-12-20T14:30:00Z"
    }
  ]
}
```

### 5.4. Doctor APIs (`/api/doctors`)

#### 1. GET /api/doctors
**Danh sách bác sĩ (with filters)**

Query Parameters:
```
?specialty=Cardiology
&hospital=Chợ Rẫy
&minRating=4.0
&page=1
&limit=10
```

Response (200):
```json
{
  "doctors": [
    {
      "id": 5,
      "full_name": "BS. Trần Văn B",
      "email": "doctor@hospital.com",
      "avatar_url": "https://...",
      "specialty": "Cardiology",
      "hospital_name": "Bệnh viện Chợ Rẫy",
      "years_of_experience": 10,
      "rating_average": 4.8,
      "review_count": 120,
      "consultation_fee": 500000,
      "license_number": "BS123456",
      "education": "MD - University of Medicine",
      "languages": ["Vietnamese", "English"],
      "bio": "Chuyên gia tim mạch...",
      "clinic_address": "215 Hồng Bàng, Q5, HCM"
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

#### 2. GET /api/doctors/:id
**Chi tiết bác sĩ**

Response (200):
```json
{
  "doctor": {
    "id": 5,
    "full_name": "BS. Trần Văn B",
    "specialty": "Cardiology",
    "hospital_name": "Bệnh viện Chợ Rẫy",
    "years_of_experience": 10,
    "rating_average": 4.8,
    "review_count": 120,
    "consultation_fee": 500000,
    "bio": "...",
    "education": "...",
    "languages": ["Vietnamese", "English"],
    "clinic_address": "...",
    "clinic_images": ["https://...", "https://..."]
  },
  "schedules": [
    {
      "day_of_week": 1,
      "start_time": "08:00:00",
      "end_time": "12:00:00",
      "is_active": true
    },
    {
      "day_of_week": 1,
      "start_time": "14:00:00",
      "end_time": "18:00:00",
      "is_active": true
    }
  ],
  "reviews": [
    {
      "id": 201,
      "patient_name": "Nguyễn Văn A",
      "rating": 5,
      "comment": "Bác sĩ rất tận tâm",
      "created_at": "2025-12-15T10:00:00Z"
    }
  ]
}
```

#### 3. GET /api/doctors/:id/availability
**Kiểm tra lịch trống**

Query:
```
?date=2026-01-10&type_id=1
```

Response (200):
```json
{
  "available_slots": [
    {
      "time": "08:00",
      "is_available": true
    },
    {
      "time": "09:00",
      "is_available": false
    },
    {
      "time": "10:00",
      "is_available": true
    }
  ]
}
```

#### 4. GET /api/doctors/my-appointments
**Lịch hẹn của bác sĩ (Doctor only)**

Query:
```
?date=2026-01-10&status=confirmed
```

Response (200):
```json
{
  "appointments": [
    {
      "id": 301,
      "patient_id": 123,
      "patient_name": "Nguyễn Văn A",
      "patient_avatar": "https://...",
      "appointment_date": "2026-01-10T08:00:00Z",
      "status": "confirmed",
      "type_name": "Consultation",
      "notes": "Chest pain"
    }
  ]
}
```

#### 5. GET /api/doctors/my-patients
**Danh sách bệnh nhân (Doctor only)**

Response (200):
```json
{
  "patients": [
    {
      "id": 123,
      "full_name": "Nguyễn Văn A",
      "avatar_url": "https://...",
      "phone_number": "0912345678",
      "last_appointment": "2025-12-20T10:00:00Z",
      "total_appointments": 5
    }
  ]
}
```

#### 6. POST /api/doctors/notes
**Tạo doctor note**

Request:
```json
{
  "patient_id": 123,
  "note_content": "Patient shows improvement..."
}
```

#### 7. PUT /api/doctors/professional-info
**Cập nhật thông tin bác sĩ (Doctor only)**

Request:
```json
{
  "specialty": "Cardiology & Internal Medicine",
  "bio": "Updated bio...",
  "consultation_fee": 550000
}
```

### 5.5. Appointment APIs (`/api/appointments`)

#### 1. POST /api/appointments/book
**Đặt lịch khám**

Request:
```json
{
  "doctor_id": 5,
  "appointment_date": "2026-01-15T10:00:00Z",
  "type_id": 1,
  "notes": "I have chest pain for 2 days"
}
```

Response (201):
```json
{
  "message": "Appointment booked successfully",
  "appointment": {
    "id": 401,
    "doctor_id": 5,
    "appointment_date": "2026-01-15T10:00:00Z",
    "status": "confirmed",
    "type_name": "Consultation"
  }
}
```

#### 2. GET /api/appointments/my-appointments
**Lịch hẹn của tôi (Patient)**

Query:
```
?status=confirmed&upcoming=true
```

Response (200):
```json
{
  "appointments": [
    {
      "id": 401,
      "doctor_id": 5,
      "doctor_name": "BS. Trần Văn B",
      "doctor_avatar": "https://...",
      "doctor_specialty": "Cardiology",
      "appointment_date": "2026-01-15T10:00:00Z",
      "status": "confirmed",
      "type_name": "Consultation",
      "notes": "Chest pain",
      "is_reviewed": false
    }
  ]
}
```

#### 3. PATCH /api/appointments/:id/status
**Cập nhật trạng thái (Doctor/Patient)**

Request:
```json
{
  "status": "completed",
  "cancellation_reason": "" 
}
```

Possible statuses:
- `confirmed` - Đã xác nhận
- `cancelled` - Đã hủy
- `completed` - Hoàn thành
- `no_show` - Không đến

#### 4. POST /api/appointments/:id/review
**Đánh giá bác sĩ (sau appointment)**

Request:
```json
{
  "rating": 5,
  "comment": "Bác sĩ rất tận tâm và chuyên nghiệp"
}
```

#### 5. POST /api/appointments/:id/reschedule
**Đổi lịch hẹn**

Request:
```json
{
  "new_appointment_date": "2026-01-16T14:00:00Z"
}
```

### 5.6. Prescription APIs (`/api/prescriptions`)

#### 1. POST /api/prescriptions
**Kê đơn thuốc (Doctor only)**

Request:
```json
{
  "patient_id": 123,
  "diagnosis": "Hypertension Stage 1",
  "chief_complaint": "Headache, dizziness",
  "clinical_findings": "BP 140/90 mmHg, HR 80 bpm",
  "notes": "Take medication after meals",
  "follow_up_date": "2026-02-15",
  "medications": [
    {
      "medication_id": 50,
      "quantity": "30 tablets",
      "dosage_instruction": "1 tablet twice daily"
    },
    {
      "medication_id": 51,
      "quantity": "1 bottle",
      "dosage_instruction": "5ml three times daily"
    }
  ]
}
```

Response (201):
```json
{
  "message": "Prescription created successfully",
  "prescription": {
    "id": 501,
    "patient_id": 123,
    "doctor_id": 5,
    "diagnosis": "Hypertension Stage 1",
    "follow_up_date": "2026-02-15",
    "created_at": "2026-01-04T11:00:00Z"
  }
}
```

#### 2. GET /api/prescriptions/my-prescriptions
**Đơn thuốc của tôi (Patient)**

Response (200):
```json
{
  "prescriptions": [
    {
      "id": 501,
      "doctor_id": 5,
      "doctor_name": "BS. Trần Văn B",
      "doctor_specialty": "Cardiology",
      "diagnosis": "Hypertension Stage 1",
      "notes": "Take medication after meals",
      "follow_up_date": "2026-02-15",
      "created_at": "2026-01-04T11:00:00Z",
      "medications": [
        {
          "medication_name": "Amlodipine 5mg",
          "quantity": "30 tablets",
          "dosage_instruction": "1 tablet twice daily"
        }
      ]
    }
  ]
}
```

#### 3. GET /api/prescriptions/:id
**Chi tiết đơn thuốc**

Response (200):
```json
{
  "prescription": {
    "id": 501,
    "patient": {
      "id": 123,
      "full_name": "Nguyễn Văn A",
      "date_of_birth": "1990-01-01",
      "gender": "male"
    },
    "doctor": {
      "id": 5,
      "full_name": "BS. Trần Văn B",
      "specialty": "Cardiology",
      "license_number": "BS123456"
    },
    "diagnosis": "Hypertension Stage 1",
    "chief_complaint": "Headache, dizziness",
    "clinical_findings": "BP 140/90 mmHg",
    "notes": "Take medication after meals",
    "follow_up_date": "2026-02-15",
    "created_at": "2026-01-04T11:00:00Z",
    "medications": [
      {
        "id": 50,
        "medication_name": "Amlodipine 5mg",
        "registration_number": "VD-12345-16",
        "manufacturer_name": "Pfizer",
        "quantity": "30 tablets",
        "dosage_instruction": "1 tablet twice daily",
        "unit_price": 5000,
        "total_price": 150000
      }
    ]
  }
}
```

#### 4. GET /api/prescriptions/medications
**Danh sách thuốc (tìm kiếm khi kê đơn)**

Query:
```
?search=amlodipine&category_id=1&page=1&limit=20
```

Response (200):
```json
{
  "medications": [
    {
      "id": 50,
      "name": "Amlodipine 5mg",
      "registration_number": "VD-12345-16",
      "category_name": "Cardiovascular",
      "manufacturer_name": "Pfizer",
      "unit": "tablet",
      "price": 5000,
      "stock": 5000,
      "usage_instruction": "Take with or without food"
    }
  ],
  "pagination": {
    "total": 1,
    "page": 1,
    "limit": 20
  }
}
```

### 5.7. Chat APIs (`/api/chat`)

#### 1. POST /api/chat/start
**Bắt đầu cuộc trò chuyện**

Request:
```json
{
  "other_user_id": 5
}
```

Response (200):
```json
{
  "conversation_id": "12345678901234567890",
  "participants": [
    {
      "user_id": 123,
      "full_name": "Nguyễn Văn A"
    },
    {
      "user_id": 5,
      "full_name": "BS. Trần Văn B"
    }
  ]
}
```

#### 2. GET /api/chat/conversations
**Danh sách cuộc trò chuyện**

Response (200):
```json
{
  "conversations": [
    {
      "conversation_id": "12345678901234567890",
      "other_user": {
        "id": 5,
        "full_name": "BS. Trần Văn B",
        "avatar_url": "https://...",
        "role": "doctor"
      },
      "last_message": {
        "content": "Thank you for your consultation",
        "message_type": "text",
        "created_at": "2026-01-04T15:30:00Z"
      },
      "unread_count": 2
    }
  ]
}
```

#### 3. GET /api/chat/conversations/:id/messages
**Lấy tin nhắn**

Query:
```
?page=1&limit=50
```

Response (200):
```json
{
  "messages": [
    {
      "id": "98765432109876543210",
      "sender_id": 123,
      "sender_name": "Nguyễn Văn A",
      "content": "Hello doctor, I have a question",
      "message_type": "text",
      "status": "sent",
      "is_read": true,
      "created_at": "2026-01-04T15:00:00Z"
    },
    {
      "id": "98765432109876543211",
      "sender_id": 5,
      "sender_name": "BS. Trần Văn B",
      "content": "Hello, how can I help you?",
      "message_type": "text",
      "status": "sent",
      "is_read": true,
      "created_at": "2026-01-04T15:02:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "hasMore": false
  }
}
```

#### 4. POST /api/chat/conversations/:id/upload
**Upload file trong chat**

Request (multipart/form-data):
```
file: <file>
```

Response (200):
```json
{
  "message": "File uploaded successfully",
  "file_url": "https://res.cloudinary.com/...",
  "file_type": "image/jpeg"
}
```

**Note:** Gửi tin nhắn thực tế qua Socket.IO (xem phần Real-time Communication)

### 5.8. Call History APIs (`/api/call-history`)

#### 1. GET /api/call-history
**Lịch sử cuộc gọi**

Query:
```
?call_type=video&status=completed&page=1&limit=20
```

Response (200):
```json
{
  "calls": [
    {
      "id": 601,
      "call_id": "call_123456789",
      "caller": {
        "id": 123,
        "full_name": "Nguyễn Văn A",
        "avatar_url": "https://..."
      },
      "receiver": {
        "id": 5,
        "full_name": "BS. Trần Văn B",
        "avatar_url": "https://..."
      },
      "call_type": "video",
      "status": "completed",
      "duration": 1234,
      "start_time": "2026-01-04T10:00:00Z",
      "end_time": "2026-01-04T10:20:34Z"
    }
  ],
  "pagination": {
    "total": 15,
    "page": 1,
    "limit": 20
  }
}
```

#### 2. GET /api/call-history/statistics
**Thống kê cuộc gọi (Doctor)**

Query:
```
?from=2025-12-01&to=2026-01-04
```

Response (200):
```json
{
  "total_calls": 150,
  "completed_calls": 130,
  "missed_calls": 20,
  "total_duration": 123456,
  "average_duration": 949,
  "calls_by_type": {
    "video": 100,
    "audio": 50
  },
  "calls_by_status": {
    "completed": 130,
    "missed": 20
  }
}
```

#### 3. POST /api/call-history
**Tạo call record (khi bắt đầu cuộc gọi)**

Request:
```json
{
  "call_id": "call_123456789",
  "receiver_id": 5,
  "call_type": "video"
}
```

#### 4. PATCH /api/call-history/:id
**Cập nhật call record (khi kết thúc)**

Request:
```json
{
  "status": "completed",
  "duration": 1234,
  "end_time": "2026-01-04T10:20:34Z"
}
```

### 5.9. MQTT APIs (`/api/mqtt`)

#### 1. GET /api/mqtt/status
**MQTT connection status**

Response (200):
```json
{
  "connected": true,
  "client_id": "health_iot_server_123",
  "broker": "mqtt://broker.hivemq.com:1883",
  "subscribed_topics": [
    "health/patient_123/vitals",
    "health/patient_123/ecg"
  ]
}
```

#### 2. GET /api/mqtt/health-data
**Lấy dữ liệu IoT (Patient)**

Query:
```
?from=2026-01-01&to=2026-01-04&page=1&limit=50
```

Response (200):
```json
{
  "data": [
    {
      "id": 701,
      "heart_rate": 75,
      "blood_pressure_systolic": 120,
      "blood_pressure_diastolic": 80,
      "temperature": 36.5,
      "spo2": 98,
      "steps": 5000,
      "calories": 300,
      "sleep_hours": 7.5,
      "device_id": "ESP32_001",
      "received_at": "2026-01-04T10:00:00Z"
    }
  ],
  "pagination": {
    "total": 150,
    "page": 1,
    "limit": 50
  }
}
```

#### 3. GET /api/mqtt/latest
**Latest IoT reading**

Response (200):
```json
{
  "latest": {
    "heart_rate": 78,
    "blood_pressure_systolic": 125,
    "blood_pressure_diastolic": 82,
    "temperature": 36.6,
    "spo2": 97,
    "steps": 6543,
    "calories": 380,
    "device_id": "ESP32_001",
    "received_at": "2026-01-04T16:30:00Z"
  }
}
```

#### 4. POST /api/mqtt/publish-test
**Test MQTT publish (Admin/Doctor)**

Request:
```json
{
  "topic": "health/patient_123/vitals",
  "payload": {
    "heart_rate": 75,
    "spo2": 98,
    "temperature": 36.5
  }
}
```

#### 5. DELETE /api/mqtt/cleanup
**Cleanup old MQTT data (Admin)**

Query:
```
?days=30
```

Response (200):
```json
{
  "message": "Deleted data older than 30 days",
  "deleted_count": 15000
}
```

### 5.10. Notification APIs (`/api/notifications`)

#### 1. GET /api/notifications
**Danh sách thông báo**

Query:
```
?page=1&limit=20&is_read=false
```

Response (200):
```json
{
  "notifications": [
    {
      "id": 801,
      "title": "Appointment Reminder",
      "message": "You have an appointment with BS. Trần Văn B at 10:00 AM tomorrow",
      "type": "appointment",
      "related_id": 401,
      "is_read": false,
      "created_at": "2026-01-04T08:00:00Z"
    },
    {
      "id": 802,
      "title": "New Message",
      "message": "BS. Trần Văn B sent you a message",
      "type": "message",
      "related_id": 12345678901234567890,
      "is_read": false,
      "created_at": "2026-01-04T15:30:00Z"
    }
  ],
  "pagination": {
    "total": 25,
    "page": 1,
    "limit": 20
  }
}
```

#### 2. PATCH /api/notifications/:id/read
**Đánh dấu đã đọc**

Response (200):
```json
{
  "message": "Notification marked as read"
}
```

#### 3. GET /api/notifications/unread-count
**Số lượng chưa đọc**

Response (200):
```json
{
  "unread_count": 5
}
```

#### 4. DELETE /api/notifications/:id
**Xóa thông báo**

Response (200):
```json
{
  "message": "Notification deleted"
}
```

### 5.11. Article APIs (`/api/articles`)

#### 1. GET /api/articles
**Tin tức sức khỏe**

Query:
```
?category=health&page=1&limit=10
```

Response (200):
```json
{
  "articles": [
    {
      "id": 901,
      "title": "10 Tips for a Healthy Heart",
      "description": "Learn how to keep your heart healthy...",
      "image_url": "https://...",
      "content_url": "https://newsapi.org/...",
      "category": "health",
      "source_name": "Health Magazine",
      "published_at": "2026-01-03T12:00:00Z"
    }
  ],
  "pagination": {
    "total": 100,
    "page": 1,
    "limit": 10
  }
}
```

### 5.12. Reminder APIs (`/api/reminders`)

#### 1. POST /api/reminders
**Tạo nhắc nhở uống thuốc**

Request:
```json
{
  "medication_name": "Amlodipine 5mg",
  "dosage": "1 tablet",
  "frequency": "twice_daily",
  "reminder_times": ["08:00", "20:00"],
  "start_date": "2026-01-05",
  "end_date": "2026-02-05",
  "notes": "Take after meal"
}
```

Response (201):
```json
{
  "message": "Reminder created successfully",
  "reminder": {
    "id": 1001,
    "medication_name": "Amlodipine 5mg",
    "dosage": "1 tablet",
    "frequency": "twice_daily",
    "reminder_times": ["08:00", "20:00"],
    "start_date": "2026-01-05",
    "end_date": "2026-02-05",
    "is_active": true
  }
}
```

#### 2. GET /api/reminders
**Danh sách nhắc nhở**

Response (200):
```json
{
  "reminders": [
    {
      "id": 1001,
      "medication_name": "Amlodipine 5mg",
      "dosage": "1 tablet",
      "frequency": "twice_daily",
      "reminder_times": ["08:00", "20:00"],
      "next_reminder": "2026-01-05T08:00:00Z",
      "is_active": true
    }
  ]
}
```

#### 3. PATCH /api/reminders/:id
**Cập nhật nhắc nhở**

Request:
```json
{
  "reminder_times": ["09:00", "21:00"],
  "is_active": true
}
```

#### 4. DELETE /api/reminders/:id
**Xóa nhắc nhở**

Response (200):
```json
{
  "message": "Reminder deleted successfully"
}
```

### 5.13. Predict APIs (`/api/predict`)

#### 1. POST /api/predict/mlp
**Dự đoán nguy cơ bệnh tim (MLP Model)**

Request:
```json
{
  "heart_rate": 75,
  "spo2": 98,
  "temperature": 36.5,
  "systolic_bp": 120,
  "diastolic_bp": 80
}
```

Response (200):
```json
{
  "model_type": "mlp",
  "prediction": {
    "diagnosis_result": "Low risk",
    "risk_level": "low",
    "confidence_score": 0.92,
    "probability": {
      "low": 0.92,
      "medium": 0.06,
      "high": 0.02
    }
  },
  "features_used": {
    "age": 36,
    "gender": 1,
    "height": 1.70,
    "weight": 65,
    "bmi": 22.49,
    "heart_rate": 75,
    "spo2": 98,
    "temperature": 36.5,
    "systolic_bp": 120,
    "diastolic_bp": 80,
    "map": 93.33
  },
  "recommendations": [
    "Maintain healthy lifestyle",
    "Regular exercise",
    "Balanced diet"
  ],
  "created_at": "2026-01-04T17:00:00Z"
}
```

**Feature Engineering trong predict_service.js:**
```javascript
// transformData function
const transformData = (inputArray, scaler) => {
  // StandardScaler: (value - mean) / scale
  return inputArray.map((value, index) => {
    const mean = scaler.mean[index];
    const scale = scaler.scale[index];
    return (value - mean) / scale;
  });
};

// processVitals function
const processVitals = async (userId, vitals) => {
  // 1. Get user profile (gender, birth_year, weight, height)
  const profile = await getUserProfile(userId);
  
  // 2. Calculate features
  const age = new Date().getFullYear() - profile.birth_year;
  const height_m = profile.height / 100;
  const bmi = profile.weight / (height_m * height_m);
  const gender = profile.gender === 'male' ? 1 : 0;
  const map = (vitals.sys_bp + 2 * vitals.dia_bp) / 3;
  
  // 3. Feature vector [11 features]
  const features = [
    age,
    gender,
    height_m,
    profile.weight,
    bmi,
    vitals.heart_rate,
    vitals.spo2,
    vitals.temperature,
    vitals.sys_bp,
    vitals.dia_bp,
    map
  ];
  
  // 4. Normalize with StandardScaler
  const normalized = transformData(features, scaler_mlp);
  
  // 5. TensorFlow.js prediction
  const tensor = tf.tensor2d([normalized]);
  const prediction = model_mlp.predict(tensor);
  const probabilities = await prediction.data();
  
  // 6. Risk encoding
  const risk_index = probabilities.indexOf(Math.max(...probabilities));
  const risk_level = risk_encoder[risk_index]; // ["low", "medium", "high"]
  
  return {
    diagnosis_result: risk_level,
    confidence_score: probabilities[risk_index],
    severity_level: risk_level
  };
};
```

#### 2. POST /api/predict/ecg
**Phát hiện bất thường ECG (ECG Model)**

Request:
```json
{
  "device_id": "ESP32_001",
  "packet_id": "PKT123456",
  "data_points": [0.5, 0.6, 0.8, 1.2, ..., 0.4],
  "sample_rate": 250,
  "duration_seconds": 10
}
```

Response (200):
```json
{
  "model_type": "ecg",
  "prediction": {
    "diagnosis_result": "Normal Sinus Rhythm",
    "anomaly_detected": false,
    "confidence_score": 0.95,
    "classifications": {
      "normal": 0.95,
      "abnormal_q_wave": 0.02,
      "st_elevation": 0.01,
      "atrial_fibrillation": 0.02
    }
  },
  "ecg_metrics": {
    "average_heart_rate": 72,
    "rr_interval": 0.833,
    "qt_interval": 0.380
  },
  "created_at": "2026-01-04T17:05:00Z"
}
```

### 5.14. Admin APIs (`/api/admin`)

#### 1. GET /api/admin/dashboard
**Admin dashboard statistics**

Response (200):
```json
{
  "total_users": 1250,
  "total_doctors": 50,
  "total_patients": 1200,
  "total_appointments": 3500,
  "pending_appointments": 15,
  "completed_appointments": 3200,
  "total_prescriptions": 2800,
  "total_medications": 500,
  "revenue": {
    "today": 15000000,
    "this_week": 75000000,
    "this_month": 250000000
  },
  "user_growth": {
    "this_month": 120,
    "last_month": 95
  },
  "popular_specialties": [
    {"specialty": "Cardiology", "count": 850},
    {"specialty": "Dermatology", "count": 620}
  ]
}
```

#### 2. GET /api/admin/users
**Quản lý users**

Query:
```
?role=patient&search=nguyen&page=1&limit=20
```

Response (200):
```json
{
  "users": [
    {
      "id": 123,
      "email": "user@example.com",
      "full_name": "Nguyễn Văn A",
      "role": "patient",
      "is_verified": true,
      "created_at": "2025-12-01T10:00:00Z",
      "last_login": "2026-01-04T09:00:00Z"
    }
  ],
  "pagination": {...}
}
```

#### 3. PATCH /api/admin/users/:id/role
**Thay đổi role**

Request:
```json
{
  "role": "doctor"
}
```

#### 4. GET /api/admin/medications
**Quản lý thuốc**

Query:
```
?search=amlodipine&category_id=1&low_stock=true&page=1
```

Response (200):
```json
{
  "medications": [
    {
      "id": 50,
      "name": "Amlodipine 5mg",
      "registration_number": "VD-12345-16",
      "category_name": "Cardiovascular",
      "manufacturer_name": "Pfizer",
      "stock": 100,
      "min_stock": 500,
      "price": 5000,
      "is_active": true,
      "created_at": "2025-10-01T10:00:00Z"
    }
  ],
  "low_stock_count": 25,
  "pagination": {...}
}
```

#### 5. POST /api/admin/medications
**Thêm thuốc mới**

Request:
```json
{
  "name": "Metformin 500mg",
  "registration_number": "VD-67890-20",
  "category_id": 2,
  "manufacturer_id": 3,
  "unit": "tablet",
  "packing_specification": "Box of 100 tablets",
  "usage_route": "oral",
  "usage_instruction": "Take with food",
  "price": 3000,
  "stock": 10000,
  "min_stock": 1000,
  "active_ingredient_ids": [10, 11]
}
```

---

## 6. FRONTEND FEATURES

### 6.1. Mobile App (Flutter) Screens

#### 6.1.1. Authentication Screens

**1. Login Screen (`presentation/auth/login_screen.dart`)**
- Email & password input
- Remember me checkbox
- Forgot password link
- Register navigation
- JWT token storage (SharedPreferences)
- FCM token registration

**2. Register Screen (`presentation/auth/register_screen.dart`)**
- Full form: email, password, full name, phone, date of birth, gender
- Role selection (patient/doctor)
- Email verification notice
- Navigate to login after successful registration

**3. Forgot Password Screen**
- Email input
- Send reset email
- Navigate to login

#### 6.1.2. Patient Screens

**1. Home Dashboard (`presentation/patient/home/`)**
```dart
// Features:
- Welcome message with user name
- Quick stats cards:
  * Upcoming appointments count
  * Unread messages count
  * Active prescriptions count
- Latest health reading (from MQTT):
  * Heart rate
  * SpO2
  * Temperature
  * Blood pressure
- AI diagnosis badge (if available)
- Quick actions:
  * Book appointment
  * Video call doctor
  * View prescriptions
  * IoT monitoring
- Health articles carousel
```

**2. Appointments Screen (`presentation/patient/appointments/`)**
```dart
// appointment_list_screen.dart
- Tab navigation: Upcoming | Completed | Cancelled
- Appointment card:
  * Doctor avatar & name
  * Specialty
  * Date & time
  * Status badge
  * Actions: Reschedule, Cancel, Review (if completed)
- FAB: Book new appointment

// book_appointment_screen.dart
- Doctor search & filter (by specialty)
- Doctor profile view
- Date picker
- Time slot selection (check availability)
- Appointment type selection
- Notes input
- Booking confirmation
```

**3. Doctors Screen (`presentation/patient/doctors/`)**
```dart
// doctor_list_screen.dart
- Search bar
- Filter: Specialty, Hospital, Rating
- Doctor card:
  * Avatar
  * Name & specialty
  * Hospital name
  * Rating stars (x.x ⭐ based on n reviews)
  * Experience years
  * Consultation fee
  * "Book" button
- Sort: Rating, Price, Experience

// doctor_detail_screen.dart
- Header: Avatar, name, specialty, rating
- Info tabs:
  * About (bio, education, languages)
  * Schedule (weekly availability calendar)
  * Reviews (patient reviews with ratings)
  * Clinic info (address, images)
- FAB: Book appointment
- FAB: Start chat
```

**4. Health Monitoring (`presentation/patient/health/`)**
```dart
// health_dashboard_screen.dart
- Real-time vitals (MQTT subscription):
  * Heart rate gauge chart
  * SpO2 gauge chart
  * Temperature gauge chart
  * Blood pressure (systolic/diastolic)
- Historical charts (fl_chart):
  * Heart rate line chart (last 24h)
  * SpO2 line chart
  * Temperature line chart
  * Steps bar chart
- AI prediction card:
  * Risk level badge (Low/Medium/High)
  * Confidence score
  * Recommendations
  * "Analyze Now" button
- Export data to PDF

// health_records_screen.dart
- Date range filter
- List of health records
- Record card: Date, vitals, source (manual/MQTT)
- Tap to view detail

// ecg_screen.dart
- Live ECG waveform (from MQTT)
- Start/Stop recording button
- ECG history list
- AI analysis button
- Result: Normal/Abnormal with confidence
```

**5. Chat Screen (`presentation/patient/chat/`)**
```dart
// conversation_list_screen.dart
- Search conversations
- Conversation card:
  * Avatar (doctor)
  * Name
  * Last message preview
  * Timestamp
  * Unread badge count
- Start new chat FAB

// chat_screen.dart (Socket.IO)
- Message list (scrollable)
- Message bubble:
  * Text message
  * Image message (image_picker)
  * File attachment
  * Timestamp
  * Read status (double check mark)
- Input bar:
  * Text field
  * Attachment button
  * Image button
  * Send button
- Real-time updates via Socket.IO
```

**6. Video Call Screen (`presentation/shared/video_call_screen.dart`)**
```dart
// Using ZegoCloud SDK
- Full-screen video
- Camera switch button
- Microphone toggle
- Speaker toggle
- End call button
- Participant info (name, avatar)
- Call duration timer
- Save call history on end
```

**7. Prescriptions Screen (`presentation/patient/prescriptions/`)**
```dart
// prescription_list_screen.dart
- Tab: Active | Expired
- Prescription card:
  * Doctor info
  * Diagnosis
  * Date
  * Medication count
  * "View detail" button

// prescription_detail_screen.dart
- Header: Doctor info, date, diagnosis
- Chief complaint
- Clinical findings
- Medications list:
  * Medication name
  * Quantity
  * Dosage instruction
  * Price
- Doctor's notes
- Follow-up date
- Total price
- Actions:
  * Download PDF
  * Set reminders
  * Share
```

**8. Medication Reminders (`presentation/patient/reminders/`)**
```dart
// reminder_list_screen.dart
- Active reminders list
- Reminder card:
  * Medication name
  * Dosage
  * Times (e.g., 8:00 AM, 8:00 PM)
  * Next dose countdown
  * Toggle active/inactive
- Add reminder FAB

// add_reminder_screen.dart
- Medication name input
- Dosage input
- Frequency selection:
  * Once daily
  * Twice daily
  * Three times daily
  * Custom
- Time picker(s)
- Start date & end date
- Notes
- Save button
```

**9. Profile Screen (`presentation/patient/profile/`)**
```dart
// profile_screen.dart
- Avatar with edit button (image_picker)
- User info section:
  * Full name
  * Email
  * Phone
  * Date of birth
  * Gender
- Health info section (expandable):
  * Height & Weight
  * Blood type
  * Allergies
  * Medical history
  * Insurance number
  * Emergency contact
- Edit profile button
- Settings button
- Logout button

// edit_profile_screen.dart
- Form with all fields
- Save button
```

#### 6.1.3. Doctor Screens

**1. Doctor Dashboard (`presentation/doctor/dashboard/`)**
```dart
// Features:
- Welcome message
- Today's appointments summary
- Quick stats:
  * Total patients
  * Today's appointments
  * Pending appointments
  * Total revenue (this month)
- Today's schedule (timeline):
  * Time slots with patient info
  * Status indicators
- Quick actions:
  * View all appointments
  * My patients
  * Prescriptions
  * Chat
- Recent patients list
```

**2. Doctor Appointments (`presentation/doctor/appointments/`)**
```dart
// appointments_screen.dart
- Calendar view (month/week/day)
- Date selector
- Time slots with patient info:
  * Patient avatar & name
  * Appointment type
  * Status
  * Notes
- Actions per appointment:
  * View patient profile
  * Start video call
  * Mark as completed
  * Cancel
  * Reschedule
- Filter by status
```

**3. My Patients (`presentation/doctor/patients/`)**
```dart
// patient_list_screen.dart
- Search patients
- Patient card:
  * Avatar
  * Name, age, gender
  * Last appointment date
  * Total appointments
  * "View" button
- Sort: Recent, Name, Appointments count

// patient_detail_screen.dart
- Patient header: Avatar, name, age, gender, contact
- Tabs:
  * Overview:
    - Health info (height, weight, BMI, blood type)
    - Allergies
    - Medical history
    - Insurance info
  * Appointments:
    - History of appointments with this patient
  * Prescriptions:
    - All prescriptions for this patient
  * Health Records:
    - Latest vitals (MQTT data)
    - AI diagnoses
    - ECG readings
  * Notes:
    - Doctor's private notes
    - Add/edit note
- Actions:
  * Start chat
  * Video call
  * Create prescription
```

**4. Create Prescription (`presentation/doctor/prescriptions/create_prescription_screen.dart`)**
```dart
// Form:
- Patient selector (if not from patient detail)
- Chief complaint (text area)
- Clinical findings (text area)
- Diagnosis (text input)
- Medications section:
  * Search medications (autocomplete)
  * Selected medications list:
    - Medication card (name, manufacturer)
    - Quantity input
    - Dosage instruction (text area)
    - Remove button
  * Add medication button
- Doctor's notes (text area)
- Follow-up date (date picker)
- Submit button

// On submit:
- POST /api/prescriptions
- Navigate back with success message
- Send notification to patient
```

**5. Doctor Profile & Settings**
```dart
// professional_info_screen.dart
- Editable fields:
  * Specialty
  * Hospital name
  * Bio
  * Consultation fee
  * License number
  * Education
  * Languages (chip selector)
  * Clinic address
  * Clinic images (image picker)
- Save button

// schedule_management_screen.dart
- Weekly schedule editor
- Day of week selector
- Time slots:
  * Start time (time picker)
  * End time (time picker)
  * Active toggle
- Add time slot button
- Delete time slot
- Save schedule button

// time_off_screen.dart
- Calendar view
- Time off list
- Add time off:
  * Start date
  * End date
  * Reason
- Delete time off
```

#### 6.1.4. Shared Widgets

**1. CustomButton** - Styled button with loading state
**2. CustomTextField** - Text field with validation
**3. LoadingDialog** - Full-screen loading overlay
**4. ErrorDialog** - Error message dialog
**5. SuccessDialog** - Success message dialog
**6. AvatarCircle** - User avatar with placeholder
**7. RatingStars** - Star rating display/input
**8. StatusBadge** - Colored status badge
**9. VitalCard** - Health vital display card with icon
**10. ChartCard** - Chart container with title
**11. EmptyState** - Empty list placeholder
**12. AppointmentCard** - Reusable appointment card
**13. DoctorCard** - Reusable doctor card
**14. PatientCard** - Reusable patient card
**15. MedicationCard** - Reusable medication card

### 6.2. Admin Portal (Next.js) Pages

#### 6.2.1. Authentication

**Login Page (`app/auth/login/page.tsx`)**
```tsx
// Features:
- Email & password input
- Remember me checkbox
- Login button (with loading state)
- Error message display
- JWT token storage (localStorage)
- Redirect to dashboard on success
```

#### 6.2.2. Dashboard Pages

**Main Dashboard (`app/dashboard/page.tsx`)**
```tsx
// Stats Cards:
- Total Users (with growth %)
- Total Doctors
- Total Patients
- Total Appointments
- Total Revenue (this month)
- Pending Appointments

// Charts:
- User growth line chart (last 6 months)
- Appointments by status pie chart
- Revenue bar chart (last 12 months)
- Popular specialties bar chart

// Recent Activities:
- Recent appointments
- Recent prescriptions
- Recent users

// Quick Actions:
- Manage users
- Manage doctors
- Manage medications
- View reports
```

**Users Management (`app/dashboard/users/page.tsx`)**
```tsx
// Features:
- Search bar (by name, email)
- Filter dropdown (by role, verified status)
- Data table (@tanstack/react-table):
  * Columns: ID, Email, Full Name, Role, Verified, Created At, Actions
  * Sortable columns
  * Pagination (10/20/50/100 per page)
- Row actions (dropdown):
  * View detail
  * Change role
  * Verify email
  * Deactivate
  * Delete
- Export to Excel (xlsx)
- Add user button (opens dialog)
```

**Doctors Management (`app/dashboard/doctors/page.tsx`)**
```tsx
// Features:
- Search (by name, specialty, hospital)
- Filter (by specialty, rating)
- Data table:
  * Columns: ID, Name, Specialty, Hospital, Rating, Experience, Fee, Status, Actions
  * Avatar column
  * Rating column with stars
- Row actions:
  * View detail
  * Edit info
  * View appointments
  * View prescriptions
  * Deactivate
- Doctor detail dialog:
  * Profile info
  * Professional info
  * Schedule
  * Statistics (total appointments, patients, revenue)
- Add doctor button
- Export to Excel
```

**Patients Management (`app/dashboard/patients/page.tsx`)**
```tsx
// Similar to users but filtered to role='patient'
- Additional columns: Blood Type, Last Appointment
- Row actions:
  * View health records
  * View appointments
  * View prescriptions
  * View AI diagnoses
- Patient detail sidebar:
  * Personal info
  * Health info
  * Latest vitals
  * Appointment history
  * Prescription history
```

**Appointments Management (`app/dashboard/appointments/page.tsx`)**
```tsx
// Features:
- Date range filter (date picker)
- Status filter (Confirmed, Completed, Cancelled, No Show)
- Doctor filter (dropdown)
- Patient search
- Data table:
  * Columns: ID, Patient, Doctor, Date & Time, Type, Status, Notes, Actions
  * Color-coded status
- Row actions:
  * View detail
  * Update status
  * Cancel
  * Delete
- Appointment detail dialog:
  * Patient info
  * Doctor info
  * Appointment info
  * Update status form
- Export to Excel
- Statistics cards:
  * Total appointments
  * Confirmed
  * Completed
  * Cancelled
  * Revenue
```

**Prescriptions Management (`app/dashboard/prescriptions/page.tsx`)**
```tsx
// Features:
- Date range filter
- Doctor filter
- Patient search
- Data table:
  * Columns: ID, Patient, Doctor, Diagnosis, Medications Count, Date, Actions
- Row actions:
  * View detail
  * Download PDF
  * Delete
- Prescription detail modal:
  * Patient & doctor info
  * Diagnosis
  * Clinical findings
  * Medications table:
    - Name
    - Quantity
    - Dosage
    - Price
  * Total price
  * Notes
  * Follow-up date
- Export to Excel
```

**Medications Management (`app/dashboard/medications/page.tsx`)**
```tsx
// Features:
- Search (by name, registration number)
- Category filter (dropdown)
- Manufacturer filter (dropdown)
- Low stock filter (toggle)
- Data table:
  * Columns: ID, Name, Registration Number, Category, Manufacturer, Stock, Min Stock, Price, Status, Actions
  * Stock column with warning indicator (if stock < min_stock)
  * Price formatted as VND
- Row actions:
  * Edit
  * View ingredients
  * Deactivate
  * Delete
- Add medication button (opens form dialog):
  * Name
  * Registration number
  * Category (select)
  * Manufacturer (select)
  * Unit
  * Packing specification
  * Usage route
  * Usage instruction
  * Price
  * Stock
  * Min stock
  * Active ingredients (multi-select)
- Low stock alerts (notifications)
- Export to Excel
- Import from Excel
```

**Analytics & Reports (`app/dashboard/analytics/page.tsx`)**
```tsx
// Date range selector
// Revenue Analytics:
- Total revenue (line chart)
- Revenue by doctor (bar chart)
- Revenue by specialty (pie chart)

// Appointment Analytics:
- Appointments over time (line chart)
- Appointments by status (pie chart)
- Appointments by specialty (bar chart)
- Peak hours heatmap

// User Analytics:
- User growth (line chart)
- Users by role (pie chart)
- User engagement metrics

// Doctor Performance:
- Top doctors by appointments
- Top doctors by revenue
- Top doctors by rating
- Doctor comparison table

// Export all reports to PDF/Excel
```

#### 6.2.3. Settings & Configuration

**System Settings (`app/dashboard/settings/page.tsx`)**
```tsx
// Tabs:
1. General Settings:
   - System name
   - Logo upload
   - Contact info
   - Working hours

2. Email Configuration:
   - SMTP settings
   - Email templates

3. Notification Settings:
   - FCM configuration
   - Notification templates

4. Payment Settings:
   - Consultation fees
   - Payment methods

5. MQTT Settings:
   - Broker URL
   - Topics configuration

6. AI/ML Settings:
   - Model paths
   - Threshold values
   - Alert settings
```

### 6.3. Key UI Components (shadcn/ui)

**Used Components:**
- Button (Primary, Secondary, Outline, Ghost, Destructive)
- Dialog (Modal dialogs)
- Dropdown Menu
- Input (Text, Number, Email, Password)
- Label
- Select (Single, Multi)
- Table (with sorting, filtering, pagination)
- Avatar
- Badge
- Card
- Alert Dialog (Confirmation)
- Checkbox
- Radio Group
- Textarea
- Date Picker
- Tabs
- Accordion
- Toast (Notifications via sonner)

---

*(Tiếp tục phần 3 trong file riêng...)*
