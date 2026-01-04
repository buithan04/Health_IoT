# Database Sync Report - Backend & Admin Portal

## ✅ Đã đồng bộ đúng

### Backend Services (admin_service.js)
✅ **getAllMedications**: Đúng cấu trúc - stock, min_stock
✅ **getMedicationById**: Đúng cấu trúc  
✅ **createMedication**: Đúng - tạo với stock, min_stock
✅ **updateMedication**: Đúng - cập nhật stock, min_stock
✅ **getAllUsers**: Đúng - sử dụng profiles table
✅ **getAllDoctors**: Đúng - sử dụng doctor_professional_info
✅ **getRecentActivities**: Đúng - sử dụng patient_id

### Database Structure
✅ users: role='patient' (không phải 'user')
✅ profiles: chỉ có thông tin cơ bản (không có height, weight, blood_type)
✅ medications: có stock, min_stock, không có active_ingredient
✅ appointments: có patient_id, type_id, cancellation_reason, is_reviewed
✅ doctor_professional_info: thay thế bảng doctors cũ
✅ patient_health_info: chứa height, weight, blood_type, allergies

## 📋 Các bảng chính trong Database

1. **users** - Người dùng (admin, doctor, patient)
2. **profiles** - Thông tin cá nhân cơ bản
3. **doctor_professional_info** - Thông tin nghề nghiệp bác sĩ
4. **patient_health_info** - Thông tin sức khỏe bệnh nhân  
5. **doctor_schedules** - Lịch làm việc bác sĩ
6. **doctor_time_off** - Ngày nghỉ của bác sĩ
7. **doctor_reviews** - Đánh giá bác sĩ
8. **appointment_types** - Loại lịch hẹn
9. **appointments** - Lịch hẹn
10. **medications** - Thuốc (có stock, min_stock)
11. **medication_categories** - Danh mục thuốc
12. **manufacturers** - Nhà sản xuất
13. **active_ingredients** - Hoạt chất (bảng riêng)
14. **medication_ingredients** - Liên kết thuốc-hoạt chất
15. **medication_reminders** - Nhắc nhở uống thuốc
16. **prescriptions** - Đơn thuốc
17. **prescription_items** - Chi tiết đơn thuốc
18. **health_records** - Bản ghi sức khỏe
19. **ecg_readings** - Dữ liệu ECG
20. **ai_diagnoses** - Chẩn đoán AI
21. **mqtt_health_data** - Dữ liệu MQTT
22. **medical_attachments** - File đính kèm y tế
23. **conversations** - Cuộc hội thoại
24. **participants** - Người tham gia cuộc trò chuyện
25. **messages** - Tin nhắn
26. **notifications** - Thông báo
27. **articles** - Tin tức sức khỏe

## 🎯 Các trường quan trọng

### Users Table
```sql
- role: 'admin' | 'doctor' | 'patient' (không phải 'user')
- verification_token: VARCHAR(255)
- reset_password_token: VARCHAR(10)
- reset_password_expires: TIMESTAMPTZ
```

### Profiles Table (Thông tin cơ bản)
```sql
- full_name, phone_number, date_of_birth, gender, address
- Không có: height, weight, blood_type (đã chuyển sang patient_health_info)
```

### Patient Health Info Table (Thông tin sức khỏe)
```sql
- height, weight, blood_type, medical_history
- allergies, insurance_number, occupation
- emergency_contact_name, emergency_contact_phone
- lifestyle_info: JSONB
```

### Medications Table
```sql
- stock: INTEGER DEFAULT 0
- min_stock: INTEGER DEFAULT 10
- registration_number: VARCHAR(50)
- packing_specification: VARCHAR(255)
- Không có: active_ingredient (đã tách thành bảng riêng)
```

### Appointments Table
```sql
- patient_id (không phải user_id)
- doctor_id
- type_id: INTEGER (link to appointment_types)
- cancellation_reason: TEXT
- is_reviewed: BOOLEAN DEFAULT FALSE
- Không có: diagnosis, prescription (đã tách vào prescriptions)
```

### Prescriptions Table
```sql
- patient_id (không phải user_id)
- doctor_id
- chief_complaint: TEXT
- clinical_findings: TEXT
- follow_up_date: DATE
```

### Prescription Items Table
```sql
- medication_name_snapshot: VARCHAR(255)
- quantity: VARCHAR(50) (không phải INTEGER)
- dosage_instruction: TEXT (gộp từ dosage, frequency, duration)
```

## 🔧 Backend API Endpoints (Đã đồng bộ)

### Medications
- GET /api/admin/medications - ✅ Trả về stock, min_stock
- GET /api/admin/medications/:id - ✅ Đầy đủ thông tin
- POST /api/admin/medications - ✅ Tạo với stock, min_stock
- PUT /api/admin/medications/:id - ✅ Cập nhật stock, min_stock
- DELETE /api/admin/medications/:id - ✅

### Users
- GET /api/admin/users - ✅ Sử dụng profiles
- GET /api/admin/users/:id - ✅
- PUT /api/admin/users/:id - ✅

### Doctors
- GET /api/admin/doctors - ✅ Sử dụng doctor_professional_info
- GET /api/admin/doctors/:id - ✅

## 📱 Frontend Admin Portal (Cần kiểm tra)

### Medications Page
✅ Hiển thị cột "Tồn kho" với Badge màu đỏ khi stock ≤ min_stock
✅ EditModal có trường stock, min_stock
✅ CreateModal có trường stock, min_stock với giá trị mặc định
✅ Import Excel hỗ trợ stock, min_stock

### Users Page
Cần kiểm tra: Có sử dụng đúng role 'patient' thay vì 'user'?

### Doctors Page
Cần kiểm tra: Có sử dụng doctor_professional_info?

## 🚀 Hướng dẫn Migration

### 1. Reset Database (Production)
```bash
# Backup data trước
pg_dump health_db > backup_$(date +%Y%m%d).sql

# Chạy migrations
psql -U postgres -d health_db -f database/migrations.sql

# Seed data
psql -U postgres -d health_db -f database/seed_data.sql
```

### 2. Development
```bash
# Drop và tạo lại
psql -U postgres -d health_db -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
psql -U postgres -d health_db -f database/migrations.sql
psql -U postgres -d health_db -f database/seed_data.sql
```

### 3. Kiểm tra sau Migration
```bash
# Kiểm tra cấu trúc
node check_db_structure.js

# Test API
npm run dev
# Test frontend
cd admin-portal && npm run dev
```

## 🔍 Checklist Đồng bộ

### Backend
- [x] Users queries sử dụng profiles
- [x] Appointments sử dụng patient_id
- [x] Medications có stock, min_stock
- [x] Doctors sử dụng doctor_professional_info
- [x] Prescriptions có chief_complaint, clinical_findings

### Frontend Admin
- [x] Medications page hiển thị stock
- [x] Medications modals có stock, min_stock
- [ ] Users page sử dụng role 'patient'
- [ ] Doctors page load từ doctor_professional_info
- [ ] Appointments page sử dụng patient_id

### API Response Format
- [x] Medications trả về stock, min_stock
- [x] Users trả về profile info
- [x] Doctors trả về professional_info
