# 📱 APP FLUTTER - TÀI LIỆU CHI TIẾT (PHẦN 1)

> **Ứng dụng di động đa nền tảng cho hệ thống Health IoT**

---

## 📋 MỤC LỤC PHẦN 1

- [1. Tổng Quan](#1-tổng-quan)
- [2. Kiến Trúc Ứng Dụng](#2-kiến-trúc-ứng-dụng)
- [3. Công Nghệ & Dependencies](#3-công-nghệ--dependencies)
- [4. Cấu Trúc Thư Mục](#4-cấu-trúc-thư-mục)
- [5. Core Module](#5-core-module)
- [6. Models Module](#6-models-module)
- [7. Service Layer](#7-service-layer)

---

## 1. TỔNG QUAN

### 1.1 Thông Tin Ứng Dụng

| Thuộc tính | Giá trị |
|------------|---------|
| **Tên ứng dụng** | Health IoT |
| **Package name** | `health_iot` |
| **Version** | 1.0.0+1 |
| **Flutter SDK** | >=3.24.0 |
| **Dart SDK** | ^3.9.2 |
| **Platforms** | Android, iOS, Windows |

### 1.2 Mục Đích

Ứng dụng mobile cho phép:

👨‍⚕️ **Bác sĩ**:
- Quản lý lịch hẹn và bệnh nhân
- Tư vấn từ xa qua video call
- Kê đơn thuốc điện tử
- Xem dữ liệu sức khỏe real-time
- Chat với bệnh nhân

👩‍💼 **Bệnh nhân**:
- Đặt lịch khám với bác sĩ
- Theo dõi sức khỏe từ thiết bị IoT
- Dự đoán bệnh tim với AI
- Video call với bác sĩ
- Xem đơn thuốc & nhắc uống thuốc
- Đọc tin tức sức khỏe

### 1.3 Tính Năng Chính

✅ **Authentication**: Đăng nhập/Đăng ký với JWT  
✅ **Real-time Monitoring**: Theo dõi sinh hiệu từ ESP32  
✅ **AI Prediction**: Dự đoán bệnh tim (89.3% accuracy)  
✅ **Video Calling**: HD calls với ZegoCloud SDK  
✅ **Chat**: Real-time messaging với Socket.IO  
✅ **Appointments**: Đặt lịch, hủy, đánh giá  
✅ **E-Prescription**: Đơn thuốc điện tử  
✅ **Reminders**: Nhắc uống thuốc thông minh  
✅ **Articles**: Tin tức sức khỏe  
✅ **Push Notifications**: Firebase Cloud Messaging  

---

## 2. KIẾN TRÚC ỨNG DỤNG

### 2.1 Mô Hình Kiến Trúc: MVVM + Service Layer

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                    │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────┐ │
│  │   Screens     │  │    Widgets    │  │   Dialogs   │ │
│  │  (UI Pages)   │  │  (Components) │  │  (Modals)   │ │
│  └───────┬───────┘  └───────┬───────┘  └──────┬──────┘ │
│          │                  │                  │         │
│          └──────────────────┼──────────────────┘         │
│                             │                            │
└─────────────────────────────┼────────────────────────────┘
                              │
                 State Management (Provider)
                              │
┌─────────────────────────────▼────────────────────────────┐
│                     SERVICE LAYER                         │
├──────────────────────────────────────────────────────────┤
│                                                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │ Auth Service │  │ Socket Svc   │  │ Zego Service │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│                                                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │ API Service  │  │ MQTT Service │  │  FCM Service │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│                                                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │Predict Svc   │  │Reminder Svc  │  │ Doctor Svc   │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│                                                            │
└─────────────────────────────┬────────────────────────────┘
                              │
┌─────────────────────────────▼────────────────────────────┐
│                      CORE LAYER                           │
├──────────────────────────────────────────────────────────┤
│                                                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │  API Client  │  │   Routing    │  │  Constants   │   │
│  │  (HTTP)      │  │  (GoRouter)  │  │              │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│                                                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │    Theme     │  │   Widgets    │  │    Utils     │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│                                                            │
└─────────────────────────────┬────────────────────────────┘
                              │
┌─────────────────────────────▼────────────────────────────┐
│                      DATA LAYER                           │
├──────────────────────────────────────────────────────────┤
│                                                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │    Models    │  │SharedPref    │  │  Local DB    │   │
│  │  (Entities)  │  │  (Storage)   │  │   (Future)   │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### 2.2 Luồng Dữ Liệu

#### 2.2.1 Luồng Đăng Nhập

```
LoginScreen (UI)
    │
    │ 1. User nhập email/password
    │ 2. Tap "Đăng nhập"
    │
    ▼
AuthService
    │
    │ 3. Gọi POST /api/auth/login
    │    via ApiClient
    │
    ▼
Backend API
    │
    │ 4. Verify credentials
    │ 5. Generate JWT token
    │
    ▼
AuthService
    │
    │ 6. Lưu token vào SharedPreferences
    │ 7. Init Socket.IO connection
    │ 8. Init FCM token
    │
    ▼
LoginScreen
    │
    │ 9. Navigate to Dashboard
    │    (GoRouter context.go('/patient'))
```

#### 2.2.2 Luồng Real-time Monitoring

```
ESP32 Device          Backend          SocketService          UI Screen
     │                   │                    │                    │
     │ MQTT Publish      │                    │                    │
     │──────────────────>│                    │                    │
     │                   │                    │                    │
     │                   │ Socket.IO emit     │                    │
     │                   │───────────────────>│                    │
     │                   │  vital_update      │                    │
     │                   │                    │                    │
     │                   │                    │ 1. Parse data      │
     │                   │                    │ 2. Update state    │
     │                   │                    │─────────────────────>│
     │                   │                    │   notifyListeners()│
     │                   │                    │                    │
     │                   │                    │                    │ 3. Rebuild UI
     │                   │                    │                    │   (Chart update)
```

#### 2.2.3 Luồng Video Call

```
Patient App         ZegoCallService      ZegoCloud       Doctor App
     │                     │                  │               │
     │ 1. Tap "Call"       │                  │               │
     │────────────────────>│                  │               │
     │                     │                  │               │
     │                     │ 2. Generate token│               │
     │                     │─────────────────>│               │
     │                     │                  │               │
     │                     │ 3. Join room     │               │
     │                     │─────────────────>│               │
     │                     │                  │               │
     │                     │                  │ 4. Notify     │
     │                     │                  │───────────────>│
     │                     │                  │  incoming_call│
     │                     │                  │               │
     │                     │                  │               │ 5. Accept
     │                     │                  │<───────────────│
     │                     │                  │               │
     │                     │  6. P2P WebRTC connection        │
     │<──────────────────────────────────────────────────────>│
```

### 2.3 State Management: Provider Pattern

```dart
// Provider Setup (main.dart)
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => SocketProvider()),
    ChangeNotifierProvider(create: (_) => VitalSignsProvider()),
    // ... more providers
  ],
  child: MaterialApp.router(...)
)

// Sử dụng trong Widget
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Listen to changes
    final vitalSigns = context.watch<VitalSignsProvider>();
    
    return Column(
      children: [
        Text('HR: ${vitalSigns.heartRate}'),
        Text('SpO2: ${vitalSigns.spo2}'),
      ],
    );
  }
}

// Update state
class SocketService {
  void handleVitalUpdate(Map<String, dynamic> data) {
    _vitalSignsProvider.updateHeartRate(data['heart_rate']);
    _vitalSignsProvider.updateSpO2(data['spo2']);
    // Provider sẽ tự động notifyListeners()
  }
}
```

---

## 3. CÔNG NGHỆ & DEPENDENCIES

### 3.1 Core Dependencies

#### 3.1.1 Framework
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
```

#### 3.1.2 Navigation & Routing
```yaml
  go_router: ^17.0.1        # Declarative routing
```

**Tính năng**:
- Deep linking support
- Nested navigation
- Route guards (auth check)
- Type-safe navigation

#### 3.1.3 State Management
```yaml
  provider: ^6.1.5+1        # Simple state management
```

**Providers trong app**:
- `AuthProvider`: Quản lý authentication state
- `SocketProvider`: Socket.IO connection state
- `VitalSignsProvider`: IoT data state
- `AppointmentProvider`: Lịch hẹn state

#### 3.1.4 UI & Styling
```yaml
  google_fonts: ^6.3.3      # Custom fonts
  flutter_animate: ^4.5.0   # Animations
  fl_chart: ^1.1.1          # Charts & graphs
  photo_view: ^0.15.0       # Image zoom
  qr_flutter: ^4.1.0        # QR code generation
```

### 3.2 Backend Communication

#### 3.2.1 HTTP Client
```yaml
  http: ^1.2.1              # REST API calls
  http_parser: ^4.0.2       # HTTP parsing
```

**Sử dụng**:
```dart
class ApiClient {
  final String baseUrl = 'http://localhost:3000/api';
  
  Future<Response> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(uri, headers: _headers);
    return response;
  }
}
```

#### 3.2.2 Real-time Communication
```yaml
  socket_io_client: ^3.1.2  # Real-time chat & notifications
```

**Events**:
- `vital_update`: Cập nhật sinh hiệu
- `new_message`: Tin nhắn mới
- `appointment_confirmed`: Lịch hẹn được xác nhận
- `incoming_call`: Cuộc gọi đến

#### 3.2.3 IoT Protocol (Đã loại bỏ - dùng Socket.IO gateway)
```yaml
  # mqtt_client: ^10.3.1    # KHÔNG còn dùng
```

### 3.3 Video Calling

#### 3.3.1 ZegoCloud SDK
```yaml
  zego_uikit_prebuilt_call: ^4.22.2      # Video call UI
  zego_uikit_signaling_plugin: ^2.8.6    # Incoming call handling
```

**Cấu hình** (`lib/config/app_info.dart`):
```dart
class AppInfo {
  static const String appName = 'Health IoT';
  static const int zegoAppID = 123456789;
  static const String zegoAppSign = 'your_app_sign_here';
}
```

**Features**:
- HD video/audio calling
- Incoming call notifications
- Background call handling
- Call history tracking

### 3.4 Notifications & Messaging

#### 3.4.1 Firebase
```yaml
  firebase_core: ^4.3.0                    # Firebase core
  firebase_messaging: ^16.1.0              # Push notifications
  flutter_local_notifications: ^19.5.0     # Local notifications
```

**Channels**:
- **Urgent**: Cảnh báo sức khỏe nguy hiểm
- **Reminders**: Nhắc uống thuốc
- **Appointments**: Lịch hẹn
- **Chat**: Tin nhắn mới

#### 3.4.2 Audio
```yaml
  audioplayers: ^6.0.0      # Notification sounds
```

### 3.5 File & Media Handling

#### 3.5.1 Image & File Picker
```yaml
  image_picker: ^1.0.7      # Camera & gallery
  file_picker: ^10.3.7      # File selection
  gal: ^2.3.2               # Save to gallery
```

#### 3.5.2 Utilities
```yaml
  mime: ^2.0.0              # MIME type detection
  url_launcher: ^6.3.2      # Open external URLs
```

### 3.6 Data Storage & Formatting

#### 3.6.1 Local Storage
```yaml
  shared_preferences: ^2.2.2  # Key-value storage
```

**Lưu trữ**:
- `auth_token`: JWT token
- `refresh_token`: Refresh token
- `user_id`: ID người dùng
- `user_role`: patient/doctor
- `fcm_token`: Firebase token

#### 3.6.2 Formatting
```yaml
  intl: ^0.20.2               # Internationalization
```

**Sử dụng**:
```dart
// Date formatting
DateFormat('dd/MM/yyyy').format(date);
DateFormat('HH:mm').format(time);

// Number formatting
NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(price);
```

### 3.7 Permissions & Connectivity

```yaml
  permission_handler: ^12.0.1    # Request permissions
  connectivity_plus: ^6.1.2      # Network status
```

**Permissions**:
- Camera
- Microphone
- Notifications
- Storage

### 3.8 Additional UI Components

```yaml
  flutter_rating_bar: ^4.0.1     # Star ratings
  webview_flutter: ^4.13.0       # Webview for articles
```

---

## 4. CẤU TRÚC THƯ MỤC

```
App/
├── lib/
│   ├── main.dart                      # Entry point
│   ├── firebase_options.dart          # Firebase config
│   │
│   ├── config/                        # App configuration
│   │   └── app_info.dart              # App constants (Zego keys, etc.)
│   │
│   ├── core/                          # Core utilities
│   │   ├── api/
│   │   │   └── api_client.dart        # HTTP client wrapper
│   │   ├── constants/
│   │   │   ├── colors.dart
│   │   │   ├── text_styles.dart
│   │   │   └── api_endpoints.dart
│   │   ├── routing/
│   │   │   └── app_router.dart        # GoRouter configuration
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── app_scroll_behavior.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── date_utils.dart
│   │   │   └── snackbar_utils.dart
│   │   └── widgets/
│   │       ├── loading_widget.dart
│   │       ├── error_widget.dart
│   │       └── custom_button.dart
│   │
│   ├── models/                        # Data models
│   │   ├── common/
│   │   │   ├── user_model.dart
│   │   │   ├── appointment_model.dart
│   │   │   └── doctor_model.dart
│   │   ├── patient/
│   │   │   ├── vital_signs_model.dart
│   │   │   ├── prescription_model.dart
│   │   │   └── reminder_model.dart
│   │   └── doctor/
│   │       ├── schedule_model.dart
│   │       └── patient_record_model.dart
│   │
│   ├── service/                       # Business logic services
│   │   ├── auth_service.dart          # Authentication
│   │   ├── socket_service.dart        # Socket.IO
│   │   ├── zego_call_service.dart     # Video calling
│   │   ├── mqtt_service.dart          # IoT (DEPRECATED)
│   │   ├── fcm_service.dart           # Push notifications
│   │   ├── predict_service.dart       # AI predictions
│   │   ├── appointment_service.dart
│   │   ├── prescription_service.dart
│   │   ├── reminder_service.dart
│   │   ├── doctor_service.dart
│   │   ├── user_service.dart
│   │   ├── chat_service.dart
│   │   ├── article_service.dart
│   │   └── notification_service.dart
│   │
│   ├── presentation/                  # UI Layer
│   │   ├── auth/                      # Authentication screens
│   │   │   └── screens/
│   │   │       ├── splash_screen.dart
│   │   │       ├── login_screen.dart
│   │   │       ├── register_screen.dart
│   │   │       ├── forgot_password_screen.dart
│   │   │       └── otp_verify_screen.dart
│   │   │
│   │   ├── patient/                   # Patient screens
│   │   │   ├── patient_shell_screen.dart    # Bottom nav
│   │   │   ├── dashboard/
│   │   │   │   └── patient_dashboard_screen.dart
│   │   │   ├── statistics/
│   │   │   │   └── patient_stats_screen.dart
│   │   │   ├── appointments/
│   │   │   │   ├── appointments_screen.dart
│   │   │   │   ├── appointment_detail_screen.dart
│   │   │   │   ├── book_appointment_screen.dart
│   │   │   │   └── booking_success_screen.dart
│   │   │   ├── find_doctor/
│   │   │   │   ├── find_doctor_screen.dart
│   │   │   │   └── doctor_detail_screen.dart
│   │   │   ├── prescriptions/
│   │   │   │   ├── prescriptions_list_screen.dart
│   │   │   │   └── prescription_detail_screen.dart
│   │   │   ├── chat/
│   │   │   │   └── chat_list_screen.dart
│   │   │   ├── reminders/
│   │   │   │   ├── medication_reminders_screen.dart
│   │   │   │   └── add_reminder_screen.dart
│   │   │   ├── articles/
│   │   │   │   ├── health_articles_screen.dart
│   │   │   │   └── article_detail_screen.dart
│   │   │   ├── profile/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   ├── personal_info_screen.dart
│   │   │   │   ├── health_record_screen.dart
│   │   │   │   └── settings_screen.dart
│   │   │   └── reviews/
│   │   │       ├── doctor_reviews_list_screen.dart
│   │   │       └── write_review_screen.dart
│   │   │
│   │   ├── doctor/                    # Doctor screens
│   │   │   ├── doctor_shell_screen.dart
│   │   │   ├── dashboard/
│   │   │   │   ├── doctor_dashboard_screen.dart
│   │   │   │   └── appointment_requests_screen.dart
│   │   │   ├── schedule/
│   │   │   │   ├── doctor_schedule_screen.dart
│   │   │   │   └── manage_availability_screen.dart
│   │   │   ├── patients/
│   │   │   │   ├── patient_list_screen.dart
│   │   │   │   ├── patient_record_screen.dart
│   │   │   │   └── patient_stats_detail_screen.dart
│   │   │   ├── consultation/
│   │   │   │   ├── consultation_screen.dart
│   │   │   │   └── prescription_detail_screen.dart
│   │   │   ├── chat/
│   │   │   │   └── doctor_chat_list_screen.dart
│   │   │   ├── Notes/
│   │   │   │   └── doctor_notes_screen.dart
│   │   │   └── profile/
│   │   │       ├── doctor_profile_screen.dart
│   │   │       ├── professional_info_screen.dart
│   │   │       └── doctor_settings_screen.dart
│   │   │
│   │   ├── shared/                    # Shared UI components
│   │   │   ├── chat_detail_screen.dart
│   │   │   ├── full_image_viewer_screen.dart
│   │   │   └── zego_call_wrapper.dart
│   │   │
│   │   └── widgets/                   # Reusable widgets
│   │       ├── custom_app_bar.dart
│   │       ├── doctor_card.dart
│   │       ├── appointment_card.dart
│   │       ├── vital_sign_card.dart
│   │       └── chat_bubble.dart
│   │
│   └── examples/                      # Example code
│       └── mqtt_example.dart
│
├── android/                           # Android configuration
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/AndroidManifest.xml
│   └── build.gradle
│
├── ios/                               # iOS configuration
│   ├── Runner/
│   │   └── Info.plist
│   └── Podfile
│
├── windows/                           # Windows configuration
│   └── runner/
│
├── assets/                            # Static resources
│   ├── images/
│   │   ├── app_icon.png
│   │   ├── logo.png
│   │   └── placeholder_avatar.png
│   └── sounds/
│       └── notification.mp3
│
├── pubspec.yaml                       # Dependencies
├── analysis_options.yaml              # Linter rules
└── README.md                          # Documentation
```

---

## 5. CORE MODULE

### 5.1 API Client (`core/api/api_client.dart`)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();
  
  // Get auth token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Build headers
  Future<Map<String, String>> _buildHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _buildHeaders();
      final response = await http.get(uri, headers: headers);
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }
  
  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _buildHeaders();
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }
  
  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _buildHeaders();
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }
  
  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _buildHeaders();
      final response = await http.delete(uri, headers: headers);
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }
  
  // Handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Request failed');
    }
  }
  
  // Upload file (multipart)
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath,
    String fieldName,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final token = await _getToken();
      
      final request = http.MultipartRequest('POST', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.files.add(await http.MultipartFile.fromPath(
        fieldName,
        filePath,
      ));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }
}
```

**Sử dụng**:
```dart
final api = ApiClient();

// GET
final user = await api.get('/users/me');

// POST
final result = await api.post('/auth/login', {
  'email': 'test@example.com',
  'password': '123456',
});

// Upload
final uploaded = await api.uploadFile(
  '/users/avatar',
  '/path/to/image.jpg',
  'avatar',
);
```

### 5.2 App Router (`core/routing/app_router.dart`)

```dart
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,  // From main.dart
    initialLocation: '/',
    debugLogDiagnostics: true,
    
    // Redirect logic
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final role = prefs.getString('user_role');
      
      final isLoggedIn = token != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
                         state.matchedLocation.startsWith('/register');
      
      // If not logged in, redirect to login
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      
      // If logged in and on auth page, redirect to dashboard
      if (isLoggedIn && isAuthRoute) {
        return role == 'doctor' ? '/doctor' : '/patient';
      }
      
      return null; // No redirect
    },
    
    routes: [
      // Auth routes
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Patient routes with bottom navigation
      ShellRoute(
        navigatorKey: _patientShellNavigatorKey,
        builder: (context, state, child) {
          return PatientShellScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/patient',
            builder: (context, state) => const PatientDashboardScreen(),
          ),
          GoRoute(
            path: '/patient/stats',
            builder: (context, state) => const PatientStatsScreen(),
          ),
          GoRoute(
            path: '/patient/appointments',
            builder: (context, state) => const AppointmentsScreen(),
          ),
          GoRoute(
            path: '/patient/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // Doctor routes with bottom navigation
      ShellRoute(
        navigatorKey: _doctorShellNavigatorKey,
        builder: (context, state, child) {
          return DoctorShellScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/doctor',
            builder: (context, state) => const DoctorDashboardScreen(),
          ),
          GoRoute(
            path: '/doctor/schedule',
            builder: (context, state) => const DoctorScheduleScreen(),
          ),
          GoRoute(
            path: '/doctor/patients',
            builder: (context, state) => const PatientListScreen(),
          ),
          GoRoute(
            path: '/doctor/profile',
            builder: (context, state) => const DoctorProfileScreen(),
          ),
        ],
      ),
      
      // Detail routes (không có bottom nav)
      GoRoute(
        path: '/appointment/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppointmentDetailScreen(appointmentId: id);
        },
      ),
      GoRoute(
        path: '/doctor/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DoctorDetailScreen(doctorId: id);
        },
      ),
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          final extra = state.extra as Map<String, dynamic>;
          return ChatDetailScreen(
            conversationId: conversationId,
            doctorName: extra['doctorName'],
            doctorAvatar: extra['doctorAvatar'],
          );
        },
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
}
```

**Navigation**:
```dart
// Navigate
context.go('/patient');
context.push('/appointment/123');

// Navigate with parameters
context.push('/doctor/456');

// Navigate with extra data
context.push(
  '/chat/789',
  extra: {
    'doctorName': 'Dr. John',
    'doctorAvatar': 'https://...',
  },
);

// Go back
context.pop();
```

### 5.3 App Theme (`core/theme/app_theme.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF4A90E2);
  static const Color secondaryColor = Color(0xFF50C878);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color successColor = Color(0xFF27AE60);
  
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF2C3E50);
  static const Color textSecondaryColor = Color(0xFF7F8C8D);
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
      ),
      
      // Text Theme
      textTheme: GoogleFonts.robotoTextTheme().copyWith(
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: textPrimaryColor,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: textSecondaryColor,
        ),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
      ),
      
      // Card
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
```

### 5.4 Constants (`core/constants/`)

#### 5.4.1 API Endpoints
```dart
// core/constants/api_endpoints.dart
class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String forgotPassword = '/auth/forgot-password';
  
  // Users
  static const String userProfile = '/users/me';
  static const String updateProfile = '/users/profile';
  static const String uploadAvatar = '/users/avatar';
  
  // Doctors
  static const String doctors = '/doctors';
  static String doctorById(String id) => '/doctors/$id';
  static String doctorSchedule(String id) => '/doctors/$id/schedule';
  
  // Appointments
  static const String appointments = '/appointments';
  static String appointmentById(String id) => '/appointments/$id';
  static String confirmAppointment(String id) => '/appointments/$id/confirm';
  static String cancelAppointment(String id) => '/appointments/$id/cancel';
  
  // Prescriptions
  static const String prescriptions = '/prescriptions';
  static String prescriptionById(String id) => '/prescriptions/$id';
  
  // Predictions
  static const String predictHeart = '/predict/heart-disease';
  
  // MQTT/IoT
  static const String iotVital = '/mqtt/vital';
  static const String iotEcg = '/mqtt/ecg';
  
  // Chat
  static const String conversations = '/chat/conversations';
  static String conversationMessages(String id) => '/chat/$id/messages';
  
  // Articles
  static const String articles = '/articles';
  
  // Notifications
  static const String notifications = '/notifications';
}
```

#### 5.4.2 Colors
```dart
// core/constants/colors.dart
class AppColors {
  static const Color primary = Color(0xFF4A90E2);
  static const Color secondary = Color(0xFF50C878);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color success = Color(0xFF27AE60);
  
  // Health indicators
  static const Color heartRate = Color(0xFFE74C3C);
  static const Color spo2 = Color(0xFF3498DB);
  static const Color temperature = Color(0xFFF39C12);
  static const Color bloodPressure = Color(0xFF9B59B6);
}
```

---

## 6. MODELS MODULE

### 6.1 User Model

```dart
// models/common/user_model.dart
class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final String role; // 'patient', 'doctor', 'admin'
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    required this.role,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
      role: json['role'],
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  User copyWith({
    String? name,
    String? phone,
    String? avatar,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role,
      isVerified: isVerified,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
```

### 6.2 Appointment Model

```dart
// models/common/appointment_model.dart
class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final String? doctorAvatar;
  final DateTime appointmentDate;
  final String timeSlot;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String? reason;
  final String? notes;
  final DateTime createdAt;
  
  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    this.doctorAvatar,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    this.reason,
    this.notes,
    required this.createdAt,
  });
  
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'].toString(),
      patientId: json['patient_id'].toString(),
      doctorId: json['doctor_id'].toString(),
      patientName: json['patient_name'],
      doctorName: json['doctor_name'],
      doctorAvatar: json['doctor_avatar'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      timeSlot: json['time_slot'],
      status: json['status'],
      reason: json['reason'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'patient_name': patientName,
      'doctor_name': doctorName,
      'doctor_avatar': doctorAvatar,
      'appointment_date': appointmentDate.toIso8601String(),
      'time_slot': timeSlot,
      'status': status,
      'reason': reason,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
  
  Color get statusColor {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }
}
```

### 6.3 Vital Signs Model

```dart
// models/patient/vital_signs_model.dart
class VitalSigns {
  final String id;
  final String userId;
  final int heartRate;
  final int spo2;
  final double temperature;
  final int? systolic;
  final int? diastolic;
  final DateTime timestamp;
  
  VitalSigns({
    required this.id,
    required this.userId,
    required this.heartRate,
    required this.spo2,
    required this.temperature,
    this.systolic,
    this.diastolic,
    required this.timestamp,
  });
  
  factory VitalSigns.fromJson(Map<String, dynamic> json) {
    return VitalSigns(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      heartRate: json['heart_rate'],
      spo2: json['spo2'],
      temperature: double.parse(json['temperature'].toString()),
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'heart_rate': heartRate,
      'spo2': spo2,
      'temperature': temperature,
      'systolic': systolic,
      'diastolic': diastolic,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  // Health status checks
  bool get isHeartRateNormal => heartRate >= 60 && heartRate <= 100;
  bool get isSpO2Normal => spo2 >= 95;
  bool get isTemperatureNormal => temperature >= 36.1 && temperature <= 37.2;
  bool get isBloodPressureNormal {
    if (systolic == null || diastolic == null) return true;
    return systolic! < 120 && diastolic! < 80;
  }
  
  bool get hasAbnormalVitals {
    return !isHeartRateNormal ||
           !isSpO2Normal ||
           !isTemperatureNormal ||
           !isBloodPressureNormal;
  }
}
```

---

## 7. SERVICE LAYER

### 7.1 Auth Service

```dart
// service/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../models/common/user_model.dart';

class AuthService {
  final ApiClient _api = ApiClient();
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _api.post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response['token']);
      await prefs.setString('user_id', response['user']['id'].toString());
      await prefs.setString('user_role', response['user']['role']);
      
      return response;
    } catch (e) {
      throw Exception('Đăng nhập thất bại: $e');
    }
  }
  
  // Register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final response = await _api.post('/auth/register', {
        'email': email,
        'password': password,
        'name': name,
        'role': role,
      });
      
      return response;
    } catch (e) {
      throw Exception('Đăng ký thất bại: $e');
    }
  }
  
  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  // Check if logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null;
  }
  
  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final response = await _api.get('/users/me');
      return User.fromJson(response['user']);
    } catch (e) {
      return null;
    }
  }
}
```

### 7.2 Socket Service

```dart
// service/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();
  
  IO.Socket? _socket;
  bool _isConnected = false;
  
  // Callbacks
  Function(Map<String, dynamic>)? onVitalUpdate;
  Function(Map<String, dynamic>)? onNewMessage;
  Function(Map<String, dynamic>)? onAppointmentUpdate;
  Function(Map<String, dynamic>)? onIncomingCall;
  
  // Initialize and connect
  Future<void> connect() async {
    if (_isConnected) return;
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getString('user_id');
    
    if (token == null) return;
    
    _socket = IO.io(
      'http://localhost:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .build(),
    );
    
    _socket!.onConnect((_) {
      print('Socket connected');
      _isConnected = true;
      
      // Join user room
      _socket!.emit('join_room', {'userId': userId});
    });
    
    _socket!.onDisconnect((_) {
      print('Socket disconnected');
      _isConnected = false;
    });
    
    // Listen to events
    _socket!.on('vital_update', (data) {
      if (onVitalUpdate != null) {
        onVitalUpdate!(data as Map<String, dynamic>);
      }
    });
    
    _socket!.on('new_message', (data) {
      if (onNewMessage != null) {
        onNewMessage!(data as Map<String, dynamic>);
      }
    });
    
    _socket!.on('appointment_confirmed', (data) {
      if (onAppointmentUpdate != null) {
        onAppointmentUpdate!(data as Map<String, dynamic>);
      }
    });
    
    _socket!.on('incoming_call', (data) {
      if (onIncomingCall != null) {
        onIncomingCall!(data as Map<String, dynamic>);
      }
    });
  }
  
  // Disconnect
  void disconnect() {
    _socket?.disconnect();
    _isConnected = false;
  }
  
  // Send message
  void sendMessage(String conversationId, String message) {
    if (!_isConnected) return;
    
    _socket!.emit('send_message', {
      'conversationId': conversationId,
      'message': message,
    });
  }
  
  // Typing indicator
  void sendTyping(String conversationId, bool isTyping) {
    if (!_isConnected) return;
    
    _socket!.emit('typing', {
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }
}
```

---

**📌 Tiếp tục ở PHẦN 2** với:
- Presentation Layer (UI Screens)
- ZegoCloud Integration
- FCM Service
- MQTT Service
- Predict Service
- Best Practices
