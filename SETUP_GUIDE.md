# 🚀 Hướng Dẫn Setup Dự Án Health IoT Trên Máy Mới

## 📋 Yêu Cầu Hệ Thống

### 1. Backend (HealthAI_Server)
- Node.js 16+ và npm
- PostgreSQL 14+ hoặc TimescaleDB 2.0+
- pgAdmin 4 (recommended for database management)
- Git

### 2. Admin Portal
- Node.js 16+ và npm
- Git

### 3. Flutter Mobile App (doan2)
- Flutter SDK 3.0+
- Android Studio (cho Android)
- Xcode (cho iOS - chỉ trên macOS)
- Visual Studio 2022 (cho Windows desktop)

---

## 🔧 Bước 1: Clone Repository

```bash
# Clone dự án từ GitHub
git clone https://github.com/buithan04/Health_IoT.git

# Di chuyển vào thư mục dự án
cd Health_IoT
```

---

## 🗄️ Bước 2: Setup Backend (HealthAI_Server)

### 2.1. Cài Đặt Dependencies

```bash
cd HealthAI_Server
npm install
```

### 2.2. Tạo File .env

Tạo file `.env` trong thư mục `HealthAI_Server/`:

```env
# Database Configuration (PostgreSQL/TimescaleDB)
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=your_postgres_password
DB_NAME=health_db
DB_PORT=5432

# Server Configuration
PORT=3000
NODE_ENV=development

# JWT Secret
JWT_SECRET=your_secret_key_here_min_32_characters

# Email Configuration (Gmail)
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password

# Cloudinary Configuration (for image uploads)
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# MQTT Configuration
MQTT_BROKER_URL=mqtt://localhost:1883
MQTT_USERNAME=
MQTT_PASSWORD=

# Firebase Admin SDK
# Tạo file serviceAccountKey.json riêng (xem bước 2.3)
```

### 2.3. Setup Firebase Service Account (Optional - for Push Notifications)

**Nếu bạn muốn bật push notifications:**

1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Project Settings > Service Accounts
4. Click "Generate New Private Key"
5. Lưu file JSON vào `HealthAI_Server/config/serviceAccountKey.json`

**Nếu không cần push notifications:**
- Server vẫn chạy bình thường, chỉ bỏ qua push notifications
- Sẽ có cảnh báo: "Push notification skipped: Firebase not initialized"

> **⚠️ Lưu ý:** File `serviceAccountKey.json` đã được thêm vào `.gitignore` và sẽ không được push lên Git (chứa credentials).

### 2.4. Tạo Database

**Sử dụng pgAdmin:**
1. Mở pgAdmin 4
2. Connect tới PostgreSQL server
3. Right-click "Databases" → Create → Database
4. Đặt tên: `health_db`
5. Encoding: UTF8
6. Click "Save"

**Hoặc sử dụng psql command line:**
```bash
# Đăng nhập PostgreSQL
psql -U postgres

# Tạo database
CREATE DATABASE health_db WITH ENCODING 'UTF8';

# Kết nối vào database
\c health_db

# (Optional) Enable TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb;

# Thoát
\q
```

### 2.5. Chạy Migrations

```bash
# Chạy migrations để tạo tables
node run_migrations.js

# Chạy seed data (dữ liệu mẫu)
node run_seed.js
```

### 2.6. Khởi Động Server

```bash
# Development mode
npm run dev

# Production mode
npm start
```

Server sẽ chạy tại: `http://localhost:3000`

---

## 🎨 Bước 3: Setup Admin Portal

### 3.1. Cài Đặt Dependencies

```bash
cd ../admin-portal
npm install
```

### 3.2. Tạo File .env.local

Tạo file `.env.local` trong thư mục `admin-portal/`:

```env
# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:3000
NEXT_PUBLIC_API_BASE_URL=http://localhost:3000

# App Configuration
NEXT_PUBLIC_APP_NAME=HealthAI Admin Portal
NEXT_PUBLIC_APP_VERSION=1.0.0
```

### 3.3. Khởi Động Admin Portal

```bash
# Development mode
npm run dev

# Production build
npm run build
npm start
```

Admin Portal sẽ chạy tại: `http://localhost:3001`

**Tài khoản admin mặc định:**
- Email: `admin@healthai.com`
- Password: `admin123`

---

## 📱 Bước 4: Setup Flutter Mobile App

### 4.1. Cài Đặt Flutter Dependencies

```bash
cd ../doan2
flutter pub get
```

### 4.2. Cấu Hình API Endpoint

Mở file `lib/config/api_config.dart` và cập nhật:

```dart
class ApiConfig {
  // Thay đổi IP này thành IP máy chạy backend
  static const String baseUrl = 'http://192.168.1.100:3000';
  
  // Hoặc sử dụng localhost nếu test trên emulator
  // Android Emulator: http://10.0.2.2:3000
  // iOS Simulator: http://localhost:3000
}
```

### 4.3. Setup Firebase

1. Tải file `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)
2. Đặt vào thư mục tương ứng:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 4.4. Setup ZegoCloud (Video Call)

Mở file `lib/config/zego_config.dart` và cập nhật:

```dart
class ZegoConfig {
  static const int appID = YOUR_ZEGO_APP_ID;
  static const String appSign = 'YOUR_ZEGO_APP_SIGN';
}
```

Đăng ký tài khoản tại: https://www.zegocloud.com/

### 4.5. Chạy App

```bash
# Kiểm tra devices
flutter devices

# Chạy trên Android
flutter run

# Chạy trên iOS (macOS only)
flutter run -d ios

# Chạy trên Windows
flutter run -d windows

# Build APK
flutter build apk --release
```

---

## 🔐 Bước 5: Tạo Tài Khoản Test

### 5.1. Tạo User Qua API

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "fullName": "Test User",
    "phone": "0123456789"
  }'
```

### 5.2. Hoặc Sử Dụng Seed Data

Seed data đã tạo sẵn các tài khoản:

**Admin:**
- Email: `admin@healthai.com`
- Password: `admin123`

**Doctor:**
- Email: `doctor1@healthai.com`
- Password: `doctor123`

**Patient:**
- Email: `patient1@healthai.com`
- Password: `patient123`

---

## 🧪 Bước 6: Kiểm Tra Hoạt Động

### 6.1. Test Backend API

```bash
# Health check
curl http://localhost:3000/health

# Login test
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@healthai.com",
    "password": "admin123"
  }'
```

### 6.2. Test Admin Portal

1. Mở browser: `http://localhost:3001`
2. Login với tài khoản admin
3. Kiểm tra các chức năng:
   - Dashboard
   - User Management
   - Doctor Management
   - Appointments

### 6.3. Test Mobile AppPostgreSQL**
```bash
# Kiểm tra PostgreSQL đang chạy
# Windows:
# Check services hoặc:
pg_ctl -D "C:\Program Files\PostgreSQL\14\data" status

# Linux:
sudo systemctl status postgresql
sudo systemctl start postgresql

# macOS:
brew services start postgresql
```

**Lỗi: Password authentication failed**
- Kiểm tra password trong file .env
- Reset password PostgreSQL nếu cần:
```bash
# Windows: mở psql với user postgres, sau đó:
ALTER USER postgres WITH PASSWORD 'new_password';

---

## 🐛 Troubleshooting

### Backend Issues

**Lỗi: Cannot connect to MySQL**
```bash
# Kiểm tra MySQL đang chạy
# Windows:
net start MySQL80

# Linux/macOS:
sudo systemctl start mysql
```

**Lỗi: Port 3000 already in use**
```bash
# Đổi PORT trong file .env
PORT=3001
```

### Admin Portal Issues

**Lỗi: Cannot connect to API**
- Kiểm tra backend đang chạy
- Kiểm tra `NEXT_PUBLIC_API_URL` trong `.env.local`

### Flutter Issues

**Lỗi: Pub get failed**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

**Lỗi: Cannot connect to backend**
- Kiểm tra IP trong `api_config.dart`
- Nếu dùng emulator, dùng IP đặc biệt:
  - Android: `10.0.2.2`
  - iOS: `localhost`

**Lỗi: Build failed**
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📚 Tài Liệu Tham Khảo

- [Backend API Documentation](./HealthAI_Server/README.md)
- [Admin Portal Documentation](./admin-portal/README.md)
- [Flutter App Documentation](./doan2/README.md)
- [Comprehensive Project Report](./COMPREHENSIVE_PROJECT_REPORT.md)
- [Contributing Guidelines](./CONTRIBUTING.md)
- [Changelog](./CHANGELOG.md)

---

## 🆘 Hỗ Trợ

Nếu gặp vấn đề:

1. Kiểm tra [Issues](https://github.com/buithan04/Health_IoT/issues)
2. Tạo issue mới với:
   - Mô tả chi tiết lỗi
   - Log/Error message
   - Các bước để reproduce
   - Environment (OS, Node version, Flutter version)

---

## 📞 Liên Hệ

- GitHub: [@buithan04](https://github.com/buithan04)
- Repository: [Health_IoT](https://github.com/buithan04/Health_IoT)

---

**Chúc bạn setup thành công! 🎉**
