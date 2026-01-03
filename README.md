# 🏥 Health IoT - Hệ Thống Quản Lý Sức Khỏe Thông Minh

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20.x-339933?logo=node.js)](https://nodejs.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql)](https://www.postgresql.org)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Hệ thống quản lý sức khỏe toàn diện với các tính năng:
- 📱 Ứng dụng di động (Flutter) cho Bệnh nhân & Bác sĩ
- 🖥️ Admin Dashboard (Next.js)
- ⚡ Backend API (Node.js + Express)
- 📊 IoT Health Monitoring
- 📞 Video/Audio Call (ZegoCloud)
- 💬 Real-time Chat (Socket.IO)

## 📋 Mục Lục

- [Yêu Cầu Hệ Thống](#yêu-cầu-hệ-thống)
- [Cấu Trúc Project](#cấu-trúc-project)
- [Cài Đặt](#cài-đặt)
  - [Backend Setup](#1-backend-setup)
  - [Flutter App Setup](#2-flutter-app-setup)
  - [Admin Portal Setup](#3-admin-portal-setup)
- [Chạy Ứng Dụng](#chạy-ứng-dụng)
- [Tính Năng](#tính-năng)
- [API Documentation](#api-documentation)
- [Contributing](#contributing)
- [License](#license)

## 🔧 Yêu Cầu Hệ Thống

### Backend
- **Node.js**: >= 20.x
- **PostgreSQL**: >= 16.x
- **Redis** (optional): >= 7.x cho caching

### Mobile App
- **Flutter SDK**: >= 3.24.0
- **Dart SDK**: >= 3.5.0
- **Android**: minSdkVersion 23 (Android 6.0+)
- **iOS**: iOS 13.0+
- **Windows**: Windows 10 1809+

### Admin Portal
- **Node.js**: >= 20.x
- **Next.js**: 14.x

## 📁 Cấu Trúc Project

```
Health_IoT/
├── doan2/                      # Flutter Mobile App
│   ├── lib/
│   │   ├── core/              # Core utilities, API client
│   │   ├── models/            # Data models
│   │   ├── presentation/      # UI screens & widgets
│   │   ├── service/           # Services (Socket, Zego, Auth, etc.)
│   │   └── main.dart          # Entry point
│   ├── android/               # Android configuration
│   ├── ios/                   # iOS configuration
│   ├── windows/               # Windows configuration
│   ├── pubspec.yaml           # Flutter dependencies
│   └── README.md
│
├── HealthAI_Server/           # Node.js Backend API
│   ├── config/                # Database, MQTT, configs
│   ├── controllers/           # Request handlers
│   ├── middleware/            # Authentication, validation
│   ├── models/                # Database models
│   ├── routes/                # API routes
│   ├── services/              # Business logic
│   ├── socket_manager.js      # Socket.IO configuration
│   ├── app.js                 # Express app
│   ├── package.json
│   └── README.md
│
├── admin-portal/              # Next.js Admin Dashboard
│   ├── src/
│   │   ├── app/              # Next.js 14 App Router
│   │   ├── components/       # React components
│   │   └── lib/              # Utilities
│   ├── package.json
│   └── README.md
│
└── README.md                  # This file
```

## 🚀 Cài Đặt

### 1. Backend Setup

```bash
# Clone repository
git clone git@github.com:buithan04/Health_IoT.git
cd Health_IoT/HealthAI_Server

# Cài đặt dependencies
npm install

# Tạo file .env (copy từ .env.example)
cp .env.example .env

# Cấu hình database trong .env:
# DB_HOST=localhost
# DB_PORT=5432
# DB_USER=postgres
# DB_PASSWORD=your_password
# DB_NAME=health_db
# JWT_SECRET=your_secret_key
# PORT=5000

# Chạy migrations
npm run db:migrate

# Seed data (optional)
npm run db:seed

# Chạy server
npm start
# hoặc development mode với auto-reload:
npm run dev
```

**⚙️ Cấu hình môi trường:** Xem [HealthAI_Server/README.md](HealthAI_Server/README.md) để biết chi tiết về các biến môi trường.

### 2. Flutter App Setup

```bash
cd ../doan2

# Cài đặt Flutter dependencies
flutter pub get

# Kiểm tra Flutter doctor
flutter doctor

# Cấu hình API endpoint trong lib/core/api/api_client.dart
# Thay đổi _baseUrl thành địa chỉ backend của bạn

# Chạy trên Android/iOS
flutter run

# Chạy trên Windows (yêu cầu Visual Studio 2022)
flutter run -d windows

# Build release APK
flutter build apk --release

# Build iOS (macOS only)
flutter build ios --release
```

**📱 Cấu hình bổ sung:**
- **ZegoCloud**: Thêm AppID và AppSign trong `lib/service/zego_service.dart`
- **Firebase**: Cấu hình FCM cho push notifications
- **Google Maps**: Thêm API key trong Android/iOS manifest

Xem chi tiết: [doan2/README.md](doan2/README.md)

### 3. Admin Portal Setup

```bash
cd ../admin-portal

# Cài đặt dependencies
npm install

# Tạo file .env.local
cp .env.example .env.local

# Cấu hình API endpoint
# NEXT_PUBLIC_API_URL=http://localhost:5000/api

# Chạy development server
npm run dev

# Build production
npm run build

# Start production server
npm start
```

## ▶️ Chạy Ứng Dụng

### Development Mode

1. **Start Backend:**
   ```bash
   cd HealthAI_Server
   npm run dev
   ```

2. **Start Mobile App:**
   ```bash
   cd doan2
   flutter run
   ```

3. **Start Admin Portal:**
   ```bash
   cd admin-portal
   npm run dev
   ```

### Production Mode

Xem hướng dẫn deploy chi tiết trong file [DEPLOYMENT.md](DEPLOYMENT.md)

## ✨ Tính Năng

### 📱 Mobile App (Bệnh nhân)
- ✅ Đăng ký / Đăng nhập
- ✅ Quản lý hồ sơ sức khỏe
- ✅ Tìm kiếm & đặt lịch bác sĩ
- ✅ Video/Audio call với bác sĩ (ZegoCloud)
- ✅ Chat real-time với bác sĩ
- ✅ Xem đơn thuốc & lịch sử khám
- ✅ Theo dõi chỉ số sức khỏe (IoT)
- ✅ Nhắc nhở uống thuốc
- ✅ Đọc tin tức sức khỏe

### 👨‍⚕️ Mobile App (Bác sĩ)
- ✅ Quản lý lịch làm việc
- ✅ Xem danh sách bệnh nhân & lịch hẹn
- ✅ Video/Audio call với bệnh nhân
- ✅ Chat real-time
- ✅ Kê đơn thuốc điện tử
- ✅ Xem hồ sơ & chỉ số sức khỏe bệnh nhân
- ✅ Ghi chú khám bệnh

### 🖥️ Admin Portal
- ✅ Dashboard & thống kê
- ✅ Quản lý người dùng (Bệnh nhân & Bác sĩ)
- ✅ Quản lý lịch hẹn
- ✅ Quản lý thuốc & dịch vụ
- ✅ Phê duyệt bác sĩ mới
- ✅ Báo cáo & analytics

### ⚡ Backend API
- ✅ RESTful API
- ✅ JWT Authentication
- ✅ Real-time Socket.IO
- ✅ MQTT IoT Integration
- ✅ PostgreSQL Database
- ✅ File Upload (Cloudinary)
- ✅ Email Service
- ✅ Push Notifications (FCM)

## 📚 API Documentation

API documentation được tạo tự động với Swagger/OpenAPI:

```bash
# Chạy server
npm start

# Truy cập API docs tại:
http://localhost:5000/api-docs
```

### Các Endpoints Chính

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/register` | POST | Đăng ký người dùng mới |
| `/api/auth/login` | POST | Đăng nhập |
| `/api/users/profile` | GET | Lấy thông tin profile |
| `/api/doctors` | GET | Danh sách bác sĩ |
| `/api/appointments` | POST | Đặt lịch hẹn |
| `/api/chat/messages` | GET | Lấy tin nhắn chat |
| `/api/prescriptions` | GET | Danh sách đơn thuốc |

Xem chi tiết: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)

## 🔐 Security

- ✅ JWT tokens với thời gian hết hạn
- ✅ Password hashing với bcrypt
- ✅ SQL injection prevention
- ✅ XSS protection
- ✅ CORS configuration
- ✅ Rate limiting
- ✅ Input validation

## 🧪 Testing

```bash
# Backend tests
cd HealthAI_Server
npm test

# Flutter tests
cd doan2
flutter test

# E2E tests
flutter drive --target=test_driver/app.dart
```

## 📦 Build & Deploy

### Backend (Node.js)
```bash
# Heroku
git push heroku master

# Docker
docker build -t health-iot-backend .
docker run -p 5000:5000 health-iot-backend
```

### Mobile App
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release
```

### Admin Portal
```bash
# Vercel
vercel --prod

# Docker
docker build -t health-iot-admin .
docker run -p 3000:3000 health-iot-admin
```

## 🤝 Contributing

Chúng tôi rất hoan nghênh mọi đóng góp! Xem [CONTRIBUTING.md](CONTRIBUTING.md) để biết thêm chi tiết.

### Quy Trình Contribute

1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. Push lên branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📝 License

Project này được phân phối dưới giấy phép MIT. Xem file [LICENSE](LICENSE) để biết thêm chi tiết.

## 👥 Team

- **Bùi Duy Thân** - Full Stack Developer - [buithan04](https://github.com/buithan04)

## 📧 Liên Hệ

- Email: buithan160904@gmail.com
- GitHub Issues: [https://github.com/buithan04/Health_IoT/issues](https://github.com/buithan04/Health_IoT/issues)

## 🙏 Acknowledgments

- Flutter Team
- Node.js Community
- ZegoCloud for video calling SDK
- PostgreSQL Team

---

**⭐ Nếu thấy project hữu ích, hãy cho chúng tôi một star!**
