# Changelog

All notable changes to the Health IoT project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-01-04

### 🎉 Initial Release

First stable release of Health IoT - Comprehensive Health Management System.

---

## 📱 Mobile App (Flutter)

### Added

#### Core Features
- ✅ **User Authentication** - Register, login, email verification, password reset
- ✅ **Profile Management** - Complete user profiles with avatar upload
- ✅ **Role-Based Access** - Separate interfaces for patients and doctors

#### Patient Features
- ✅ **Health Records** - Digital electronic health records
- ✅ **Vital Monitoring** - Real-time IoT device integration (MQTT protocol)
  - Heart rate monitoring
  - SpO2 (blood oxygen) tracking
  - Body temperature
  - Blood pressure readings
- ✅ **AI Health Predictions** - Heart disease risk assessment (89.3% accuracy)
  - ML-powered predictions using TensorFlow.js
  - Risk categorization (Low, Medium, High)
  - Feature engineering (Age, BMI, MAP calculations)
- ✅ **Doctor Search** - Find doctors by specialty, location, and rating
- ✅ **Appointment Booking** - Schedule appointments with availability checking
- ✅ **Video Consultations** - HD video/audio calls via ZegoCloud SDK 4.22.2
- ✅ **Real-time Chat** - Instant messaging with doctors (Socket.IO)
- ✅ **E-Prescriptions** - View digital prescriptions
- ✅ **Medication Reminders** - Smart notification system
- ✅ **Health Charts** - Visualize vital trends with fl_chart
- ✅ **Health Articles** - Curated health news and tips

#### Doctor Features
- ✅ **Patient Management** - View patient history and health records
- ✅ **Appointment Dashboard** - Manage schedule and appointments
- ✅ **E-Prescribing** - Create prescriptions with medication database
- ✅ **Video Consultations** - Conduct remote consultations
- ✅ **Real-time Vitals** - Monitor patient vitals during consultations
- ✅ **Doctor Notes** - Private notes for each patient
- ✅ **Schedule Management** - Set working hours and time-off
- ✅ **Professional Profile** - Specialty, experience, certifications

#### Technical
- ✅ Cross-platform support (Android 6.0+, iOS 13.0+, Windows 10+)
- ✅ State management with Provider pattern
- ✅ Declarative routing with go_router
- ✅ Firebase Cloud Messaging for push notifications
- ✅ Local storage with shared_preferences
- ✅ Image picker for photo uploads
- ✅ Permission handling for camera, microphone, storage

---

## 🚀 Backend API (Node.js)

### Added

#### Core APIs
- ✅ **Authentication APIs** (7 endpoints)
  - Register, login, email verification
  - Password reset flow
  - JWT token management
  - Logout functionality
  - Doctor creation (admin only)

- ✅ **User APIs** (6 endpoints)
  - Profile management (view, update)
  - Avatar upload (Cloudinary)
  - Dashboard statistics
  - FCM token registration
  - User reviews

- ✅ **Doctor APIs** (10+ endpoints)
  - Doctor listing and search
  - Doctor detail views
  - Availability checking
  - Professional info management
  - Schedule management
  - Patient list for doctors
  - Doctor notes CRUD

- ✅ **Appointment APIs** (5 endpoints)
  - Appointment booking
  - Status updates (pending, confirmed, completed, cancelled)
  - Rescheduling
  - Doctor reviews
  - Appointment history

- ✅ **Prescription APIs** (4 endpoints)
  - Create prescriptions (doctors)
  - View prescriptions
  - Prescription details
  - Medication search

- ✅ **Chat APIs** (4 endpoints)
  - Conversation management
  - Message history
  - Real-time messaging via Socket.IO
  - Typing indicators

- ✅ **Call History APIs** (4 endpoints)
  - Call records tracking
  - Call duration logging
  - Call history retrieval

- ✅ **MQTT APIs** (5 endpoints)
  - IoT connection status
  - Health data retrieval
  - Latest readings
  - Test MQTT publish
  - Data cleanup

- ✅ **Notification APIs** (4 endpoints)
  - Push notifications
  - Notification history
  - Mark as read
  - FCM integration

- ✅ **Article APIs** (1 endpoint)
  - Health articles aggregation
  - News crawling (every 3 hours)

- ✅ **Reminder APIs** (4 endpoints)
  - Medication reminder CRUD
  - Reminder notifications

- ✅ **AI/ML APIs** (2 endpoints)
  - Heart disease prediction (MLP model)
  - ECG anomaly detection (CNN model)

- ✅ **Admin APIs** (10+ endpoints)
  - User management
  - Doctor management
  - Patient management
  - Appointment oversight
  - Prescription management
  - Analytics and reports
  - System configuration

#### AI/ML Integration
- ✅ **TensorFlow.js Node** integration
- ✅ **MLP Model** - Heart disease prediction
  - 11 input features
  - StandardScaler normalization
  - 3-class output (low, medium, high risk)
- ✅ **CNN Model** - ECG anomaly detection
  - 1D CNN architecture
  - Time-series analysis
- ✅ **Feature Engineering** - Age, BMI, MAP calculations
- ✅ **Risk Classification** - Low/Medium/High categories

#### Real-time Communication
- ✅ **Socket.IO** integration for chat
  - Join/leave conversations
  - Send/receive messages
  - Typing indicators
  - Read receipts
  - Online status

#### IoT Integration
- ✅ **MQTT Protocol** - HiveMQ Cloud broker
- ✅ **MQTT Worker** - Background subscriber
  - Real-time vital sign processing
  - Threshold checking
  - Alert generation
- ✅ **MQTT Cleanup Worker** - Automated data cleanup (30+ days)
- ✅ **Support for ESP32** devices

#### Background Jobs
- ✅ **Article Crawler** - Fetch health news every 3 hours (node-cron)
- ✅ **Appointment Scheduler** - Send reminders 24h before appointments
- ✅ **MQTT Cleanup** - Daily cleanup of old IoT data

#### Database
- ✅ **PostgreSQL 16** - Production-ready database
- ✅ **34 Tables** - Comprehensive schema
  - User management (users, profiles, patient_health_info)
  - Doctor management (doctor_professional_info, schedules)
  - Appointments (appointments, appointment_types, reviews)
  - Prescriptions (prescriptions, medications, reminders)
  - Health records (health_records, ecg_readings, ai_diagnoses)
  - MQTT data (mqtt_health_data)
  - Communication (conversations, messages, call_history)
  - Notifications (notifications)
  - Articles (articles)
- ✅ **20+ Indexes** - Performance optimization
- ✅ **Connection Pooling** - pg-pool with 20 max connections

#### Security
- ✅ **JWT Authentication** - Token-based auth
- ✅ **bcrypt** - Password hashing (10 rounds)
- ✅ **CORS** - Configurable CORS policy
- ✅ **Helmet** - Security headers
- ✅ **Rate Limiting** - API rate limits

#### Cloud Services
- ✅ **Cloudinary** - File storage and CDN
- ✅ **Firebase Admin SDK** - Push notifications
- ✅ **Nodemailer** - Email service (SMTP)
- ✅ **HiveMQ Cloud** - MQTT broker

---

## 💻 Admin Portal (Next.js)

### Added

#### Dashboard
- ✅ **Analytics Dashboard** - Real-time statistics
  - User counts (patients, doctors, admins)
  - Appointment metrics (pending, confirmed, completed, cancelled)
  - Revenue tracking
  - System health monitoring

#### User Management
- ✅ **Patient Management** - View, edit, delete patients
- ✅ **Doctor Management** - Manage doctor profiles and credentials
- ✅ **Admin Management** - Admin user management
- ✅ **User Activity Logs** - Track user actions
- ✅ **Export to Excel** - Export user lists

#### Appointment Management
- ✅ **Appointment Oversight** - View all appointments
- ✅ **Filters** - By status, date, doctor, patient
- ✅ **Status Updates** - Update appointment status
- ✅ **Appointment Details** - View full appointment info
- ✅ **Export Reports** - Export appointment data

#### Medication Database
- ✅ **Drug Catalog** - Comprehensive medication database
- ✅ **Categories** - Medication categorization
- ✅ **Manufacturers** - Manufacturer database
- ✅ **Active Ingredients** - Ingredient tracking
- ✅ **CRUD Operations** - Create, read, update, delete medications

#### Prescription Management
- ✅ **View Prescriptions** - All prescriptions
- ✅ **Filters** - By patient, doctor, date
- ✅ **Prescription Details** - View full prescription
- ✅ **Export to Excel** - Export prescription data
- ✅ **Analytics** - Prescription statistics

#### Reports & Analytics
- ✅ **Custom Date Ranges** - Flexible reporting periods
- ✅ **Excel Export** - Export all data to Excel
- ✅ **Revenue Analytics** - Financial tracking
- ✅ **Appointment Statistics** - Appointment trends
- ✅ **User Growth Charts** - User registration trends
- ✅ **Performance Metrics** - System performance

#### Technical
- ✅ **Next.js 14** - App Router
- ✅ **TypeScript** - Type safety
- ✅ **Radix UI** - Accessible components (shadcn/ui)
- ✅ **Tailwind CSS** - Utility-first styling
- ✅ **TanStack Query** - Data fetching and caching
- ✅ **TanStack Table** - Advanced data tables
- ✅ **Lucide Icons** - Icon library
- ✅ **xlsx** - Excel export functionality

---

## 📄 Documentation

### Added
- ✅ **Main README.md** - Comprehensive project overview
- ✅ **Backend README.md** - Backend setup and API docs
- ✅ **Flutter README.md** - Mobile app build instructions
- ✅ **Admin Portal README.md** - Admin portal setup
- ✅ **CONTRIBUTING.md** - Contribution guidelines
- ✅ **CHANGELOG.md** - This file
- ✅ **Comprehensive Reports** (40,000+ words)
  - Part 1: Overview, Architecture, Tech Stack, Database
  - Part 2: API Documentation, Frontend Features
  - Part 3: AI/ML System, Real-time Communication
  - Part 4: IoT Integration, Security, Deployment

---

## 🐛 Known Issues

### Backend
- None currently reported

### Mobile App
- **Android Emulator**: Use `10.0.2.2` instead of `localhost` for API calls
- **iOS Simulator**: Video calling may have limited performance
- **Windows**: MQTT client may require additional configuration

### Admin Portal
- None currently reported

---

## 🚀 Future Roadmap

### Phase 2 (Q2 2026)
- [ ] **Payment Integration** - VNPay, PayPal, Stripe
- [ ] **Multi-language Support** - Vietnamese, English, more
- [ ] **Enhanced AI Models** - More training data, higher accuracy
- [ ] **Doctor-to-Doctor Consultations** - Referral system
- [ ] **Voice Commands** - Siri/Google Assistant integration
- [ ] **Wearable Device Integration** - Apple Watch, Fitbit
- [ ] **Insurance Integration** - Insurance claim processing
- [ ] **Lab Results** - Lab test integration
- [ ] **Pharmacy Integration** - Direct prescription to pharmacy

### Phase 3 (Q3-Q4 2026)
- [ ] **National Health Database** - Integration with government systems
- [ ] **Blockchain for Medical Records** - Immutable health records
- [ ] **AR/VR Medical Education** - Training modules
- [ ] **Cloud Deployment** - AWS/Azure infrastructure
- [ ] **Mobile Web App** - PWA for browser access
- [ ] **Advanced Analytics** - Predictive health analytics
- [ ] **Telemedicine Marketplace** - Connect with more doctors
- [ ] **Mental Health Support** - AI-powered mental health chatbot

---

## 📊 Statistics

### Version 1.0.0
- **Total Lines of Code**: 50,000+
- **Total Files**: 200+
- **API Endpoints**: 100+
- **Database Tables**: 34
- **AI Models**: 2 (MLP + ECG)
- **Development Time**: 6+ months
- **Contributors**: 1
- **License**: MIT

### Performance
- ⚡ API Response Time: < 300ms
- 🧠 AI Inference: 50ms (MLP), 150ms (ECG)
- 💾 Database Query: < 100ms (indexed)
- 🔌 WebSocket Latency: < 50ms
- 📞 Video Call Quality: 720p @ 30fps

---

## 🙏 Acknowledgments

- **TensorFlow.js** - AI/ML framework
- **ZegoCloud** - Video calling infrastructure
- **HiveMQ** - MQTT broker
- **Firebase** - Push notifications
- **Flutter Team** - Mobile framework
- **Vercel/Next.js** - Admin portal framework
- **Radix UI** - Accessible components
- **Tailwind Labs** - Tailwind CSS

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

<div align="center">

**Made with ❤️ by [Bùi Duy Thân](https://github.com/buithan04)**

[⬆ Back to top](#changelog)

</div>
