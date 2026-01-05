# 📱 APP FLUTTER - TÀI LIỆU CHI TIẾT (PHẦN 2)

> **Presentation Layer, Services nâng cao và Best Practices**

---

## 📋 MỤC LỤC PHẦN 2

- [8. Presentation Layer (UI)](#8-presentation-layer-ui)
- [9. Services Nâng Cao](#9-services-nâng-cao)
- [10. Firebase Integration](#10-firebase-integration)
- [11. ZegoCloud Video Calling](#11-zegocloud-video-calling)
- [12. Best Practices](#12-best-practices)
- [13. Troubleshooting](#13-troubleshooting)
- [14. Build & Deployment](#14-build--deployment)

---

## 8. PRESENTATION LAYER (UI)

### 8.1 Authentication Screens

#### 8.1.1 Login Screen
```dart
// presentation/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../service/auth_service.dart';
import '../../../service/socket_service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Init Socket.IO after login
      await SocketService().connect();

      // Navigate based on role
      if (!mounted) return;
      
      final role = result['user']['role'];
      if (role == 'doctor') {
        context.go('/doctor');
      } else {
        context.go('/patient');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thất bại: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Đăng nhập',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Chào mừng bạn trở lại!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword 
                            ? Icons.visibility_off 
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 8),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Quên mật khẩu?'),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Login button
                CustomButton(
                  text: 'Đăng nhập',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 16),
                
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản?'),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Đăng ký ngay'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

### 8.2 Patient Dashboard

#### 8.2.1 Dashboard Screen
```dart
// presentation/patient/dashboard/patient_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../../service/socket_service.dart';
import '../../../models/patient/vital_signs_model.dart';
import '../../widgets/vital_sign_card.dart';
import '../../widgets/quick_action_card.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final _socketService = SocketService();
  VitalSigns? _latestVital;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initSocketListener();
  }

  void _initSocketListener() {
    _socketService.onVitalUpdate = (data) {
      setState(() {
        _latestVital = VitalSigns.fromJson(data);
        _isConnected = true;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/patient/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              _buildGreeting(),
              const SizedBox(height: 24),
              
              // Connection status
              _buildConnectionStatus(),
              const SizedBox(height: 16),
              
              // Vital signs
              _buildVitalSigns(),
              const SizedBox(height: 24),
              
              // Quick actions
              _buildQuickActions(),
              const SizedBox(height: 24),
              
              // Upcoming appointments
              _buildUpcomingAppointments(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Hãy chăm sóc sức khỏe của bạn!',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isConnected ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isConnected ? Colors.green : Colors.orange,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isConnected ? Icons.check_circle : Icons.warning,
            color: _isConnected ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isConnected 
                  ? 'Thiết bị đã kết nối' 
                  : 'Đang chờ kết nối thiết bị...',
              style: TextStyle(
                color: _isConnected ? Colors.green[900] : Colors.orange[900],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSigns() {
    if (_latestVital == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.monitor_heart_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có dữ liệu sinh hiệu',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng kết nối thiết bị IoT',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sinh hiệu',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: VitalSignCard(
                icon: Icons.favorite,
                label: 'Nhịp tim',
                value: '${_latestVital!.heartRate}',
                unit: 'BPM',
                color: AppColors.heartRate,
                isNormal: _latestVital!.isHeartRateNormal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: VitalSignCard(
                icon: Icons.air,
                label: 'SpO2',
                value: '${_latestVital!.spo2}',
                unit: '%',
                color: AppColors.spo2,
                isNormal: _latestVital!.isSpO2Normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: VitalSignCard(
                icon: Icons.thermostat,
                label: 'Nhiệt độ',
                value: _latestVital!.temperature.toStringAsFixed(1),
                unit: '°C',
                color: AppColors.temperature,
                isNormal: _latestVital!.isTemperatureNormal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: VitalSignCard(
                icon: Icons.monitor_heart,
                label: 'Huyết áp',
                value: _latestVital!.systolic != null 
                    ? '${_latestVital!.systolic}/${_latestVital!.diastolic}'
                    : '--',
                unit: 'mmHg',
                color: AppColors.bloodPressure,
                isNormal: _latestVital!.isBloodPressureNormal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thao tác nhanh',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            QuickActionCard(
              icon: Icons.medical_services,
              label: 'Đặt lịch khám',
              color: Colors.blue,
              onTap: () => context.push('/patient/find-doctor'),
            ),
            QuickActionCard(
              icon: Icons.analytics,
              label: 'Dự đoán bệnh',
              color: Colors.purple,
              onTap: () => context.push('/patient/predict'),
            ),
            QuickActionCard(
              icon: Icons.medication,
              label: 'Đơn thuốc',
              color: Colors.green,
              onTap: () => context.push('/patient/prescriptions'),
            ),
            QuickActionCard(
              icon: Icons.article,
              label: 'Tin tức',
              color: Colors.orange,
              onTap: () => context.push('/patient/articles'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _refreshData() async {
    // Reload data from API
    await Future.delayed(const Duration(seconds: 1));
  }
}
```

### 8.3 Custom Widgets

#### 8.3.1 Vital Sign Card
```dart
// presentation/widgets/vital_sign_card.dart
import 'package:flutter/material.dart';

class VitalSignCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool isNormal;

  const VitalSignCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.isNormal = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                if (!isNormal)
                  const Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isNormal ? color : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 9. SERVICES NÂNG CAO

### 9.1 Predict Service (AI)

```dart
// service/predict_service.dart
import '../core/api/api_client.dart';

class PredictService {
  final ApiClient _api = ApiClient();

  // Predict heart disease
  Future<Map<String, dynamic>> predictHeartDisease({
    required int age,
    required int sex,
    required int cp,
    required int trestbps,
    required int chol,
    required int fbs,
    required int restecg,
    required int thalach,
    required int exang,
    required double oldpeak,
    required int slope,
  }) async {
    try {
      final response = await _api.post('/predict/heart-disease', {
        'age': age,
        'sex': sex,
        'cp': cp,
        'trestbps': trestbps,
        'chol': chol,
        'fbs': fbs,
        'restecg': restecg,
        'thalach': thalach,
        'exang': exang,
        'oldpeak': oldpeak,
        'slope': slope,
      });

      return {
        'probability': response['probability'],
        'risk': response['risk'],
        'recommendations': response['recommendations'],
      };
    } catch (e) {
      throw Exception('Dự đoán thất bại: $e');
    }
  }

  // Get risk level color
  Color getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get risk level text
  String getRiskText(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return 'Nguy cơ thấp';
      case 'medium':
        return 'Nguy cơ trung bình';
      case 'high':
        return 'Nguy cơ cao';
      default:
        return 'Không xác định';
    }
  }
}
```

### 9.2 Appointment Service

```dart
// service/appointment_service.dart
import '../core/api/api_client.dart';
import '../models/common/appointment_model.dart';

class AppointmentService {
  final ApiClient _api = ApiClient();

  // Get appointments
  Future<List<Appointment>> getAppointments({
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (fromDate != null) {
        queryParams['from_date'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['to_date'] = toDate.toIso8601String();
      }

      final query = queryParams.isNotEmpty 
          ? '?${Uri(queryParameters: queryParams).query}'
          : '';

      final response = await _api.get('/appointments$query');
      final List data = response['appointments'];
      
      return data.map((json) => Appointment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lấy danh sách lịch hẹn thất bại: $e');
    }
  }

  // Book appointment
  Future<Appointment> bookAppointment({
    required String doctorId,
    required DateTime appointmentDate,
    required String timeSlot,
    String? reason,
  }) async {
    try {
      final response = await _api.post('/appointments', {
        'doctor_id': doctorId,
        'appointment_date': appointmentDate.toIso8601String(),
        'time_slot': timeSlot,
        'reason': reason,
      });

      return Appointment.fromJson(response['appointment']);
    } catch (e) {
      throw Exception('Đặt lịch thất bại: $e');
    }
  }

  // Confirm appointment (Doctor only)
  Future<void> confirmAppointment(String appointmentId) async {
    try {
      await _api.put('/appointments/$appointmentId/confirm', {});
    } catch (e) {
      throw Exception('Xác nhận lịch hẹn thất bại: $e');
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {
      await _api.put('/appointments/$appointmentId/cancel', {
        'reason': reason,
      });
    } catch (e) {
      throw Exception('Hủy lịch hẹn thất bại: $e');
    }
  }

  // Rate appointment
  Future<void> rateAppointment({
    required String appointmentId,
    required int rating,
    String? review,
  }) async {
    try {
      await _api.post('/appointments/$appointmentId/review', {
        'rating': rating,
        'review': review,
      });
    } catch (e) {
      throw Exception('Đánh giá thất bại: $e');
    }
  }
}
```

### 9.3 Reminder Service

```dart
// service/reminder_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/api/api_client.dart';
import '../models/patient/reminder_model.dart';

class ReminderService {
  final ApiClient _api = ApiClient();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Get reminders
  Future<List<Reminder>> getReminders() async {
    try {
      final response = await _api.get('/reminders');
      final List data = response['reminders'];
      return data.map((json) => Reminder.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lấy danh sách nhắc nhở thất bại: $e');
    }
  }

  // Create reminder
  Future<Reminder> createReminder({
    required String prescriptionId,
    required String medicationName,
    required List<String> times,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _api.post('/reminders', {
        'prescription_id': prescriptionId,
        'medication_name': medicationName,
        'times': times,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      });

      final reminder = Reminder.fromJson(response['reminder']);
      
      // Schedule local notifications
      await _scheduleNotifications(reminder);
      
      return reminder;
    } catch (e) {
      throw Exception('Tạo nhắc nhở thất bại: $e');
    }
  }

  // Schedule notifications
  Future<void> _scheduleNotifications(Reminder reminder) async {
    for (var time in reminder.times) {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      await _notifications.zonedSchedule(
        reminder.id.hashCode + hour,
        'Nhắc uống thuốc',
        'Đã đến giờ uống ${reminder.medicationName}',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders',
            'Nhắc uống thuốc',
            channelDescription: 'Nhắc nhở uống thuốc đúng giờ',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = TZDateTime.now(local);
    var scheduledDate = TZDateTime(
      local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // Delete reminder
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _api.delete('/reminders/$reminderId');
      
      // Cancel notifications
      await _notifications.cancel(reminderId.hashCode);
    } catch (e) {
      throw Exception('Xóa nhắc nhở thất bại: $e');
    }
  }
}
```

---

## 10. FIREBASE INTEGRATION

### 10.1 FCM Service

```dart
// service/fcm_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiClient _api = ApiClient();

  // Initialize
  Future<void> initialize() async {
    // Request permission
    await _requestPermission();

    // Initialize local notifications
    await _initLocalNotifications();

    // Get FCM token
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveFcmToken(token);
    }

    // Listen to token refresh
    _fcm.onTokenRefresh.listen(_saveFcmToken);

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/terminated messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Create notification channels
    const urgentChannel = AndroidNotificationChannel(
      'urgent',
      'Cảnh báo khẩn cấp',
      description: 'Cảnh báo sức khỏe nguy hiểm',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const remindersChannel = AndroidNotificationChannel(
      'reminders',
      'Nhắc uống thuốc',
      description: 'Nhắc nhở uống thuốc đúng giờ',
      importance: Importance.high,
    );

    const appointmentsChannel = AndroidNotificationChannel(
      'appointments',
      'Lịch hẹn',
      description: 'Thông báo về lịch hẹn',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(urgentChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(remindersChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(appointmentsChannel);
  }

  Future<void> _saveFcmToken(String token) async {
    print('FCM Token: $token');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);

    // Send to backend
    try {
      await _api.post('/users/fcm-token', {'token': token});
    } catch (e) {
      print('Failed to save FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');

    // Show local notification
    _showLocalNotification(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.notification?.title}');
    
    // Handle navigation based on message data
    final data = message.data;
    if (data.containsKey('type')) {
      // Navigate to specific screen
      // Use navigatorKey.currentContext to navigate
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    
    // Handle navigation
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            message.data['channel_id'] ?? 'default',
            message.data['channel_name'] ?? 'Notifications',
            channelDescription: message.data['channel_description'],
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }

  // Subscribe to topic
  Future<void> subscribeTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  Future<void> unsubscribeTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }
}
```

---

## 11. ZEGOCLOUD VIDEO CALLING

### 11.1 ZegoCall Service

```dart
// service/zego_call_service.dart
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../config/app_info.dart';
import '../core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZegoCallService {
  static final ZegoCallService _instance = ZegoCallService._internal();
  factory ZegoCallService() => _instance;
  ZegoCallService._internal();

  final ApiClient _api = ApiClient();

  // Initialize Zego for incoming calls
  Future<void> initIncomingCall(String userId, String userName) async {
    try {
      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: AppInfo.zegoAppID,
        appSign: AppInfo.zegoAppSign,
        userID: userId,
        userName: userName,
        plugins: [ZegoUIKitSignalingPlugin()],
        ringtoneConfig: const ZegoRingtoneConfig(
          incomingCallPath: 'assets/sounds/incoming_call.mp3',
          outgoingCallPath: 'assets/sounds/outgoing_call.mp3',
        ),
        requireConfig: (ZegoCallInvitationData data) {
          return ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            ..onOnlySelfInRoom = (context) {
              // Leave when only self in room
              Navigator.of(context).pop();
            };
        },
      );
    } catch (e) {
      print('Failed to init Zego: $e');
    }
  }

  // Uninitialize (on logout)
  Future<void> uninit() async {
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
  }

  // Send call invitation
  Future<void> sendCallInvitation({
    required String targetUserId,
    required String targetUserName,
    required bool isVideoCall,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('user_id')!;
      final currentUserName = prefs.getString('user_name')!;

      await ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [
          ZegoCallUser(
            id: targetUserId,
            name: targetUserName,
          ),
        ],
        isVideoCall: isVideoCall,
      );

      // Log call to backend
      await _logCall(
        callerId: currentUserId,
        calleeId: targetUserId,
        isVideo: isVideoCall,
      );
    } catch (e) {
      print('Failed to send call invitation: $e');
    }
  }

  Future<void> _logCall({
    required String callerId,
    required String calleeId,
    required bool isVideo,
  }) async {
    try {
      await _api.post('/call/history', {
        'caller_id': callerId,
        'callee_id': calleeId,
        'call_type': isVideo ? 'video' : 'audio',
        'start_time': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to log call: $e');
    }
  }
}
```

### 11.2 Zego Call Wrapper

```dart
// presentation/shared/zego_call_wrapper.dart
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoCallWrapper extends StatelessWidget {
  final Widget child;

  const ZegoCallWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCallMiniOverlayPage(
      contextQuery: () => navigatorKey.currentContext!,
      child: child,
    );
  }
}
```

---

## 12. BEST PRACTICES

### 12.1 Code Organization

✅ **DO**: Tách logic khỏi UI
```dart
// ❌ Bad
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  Future<void> loadData() async {
    final response = await http.get(Uri.parse('...'));
    // Process data here
  }
}

// ✅ Good
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final _service = MyService();
  
  Future<void> loadData() async {
    final data = await _service.getData();
    // Only update UI
  }
}
```

### 12.2 Error Handling

✅ **DO**: Luôn xử lý errors
```dart
try {
  final result = await _api.get('/endpoint');
  // Handle success
} on SocketException {
  // No internet connection
  showSnackBar('Không có kết nối internet');
} on HttpException {
  // HTTP error
  showSnackBar('Lỗi server');
} catch (e) {
  // Other errors
  showSnackBar('Đã xảy ra lỗi: $e');
}
```

### 12.3 State Management

✅ **DO**: Sử dụng Provider cho global state
```dart
// ✅ Good
class VitalSignsProvider extends ChangeNotifier {
  VitalSigns? _latest;
  
  VitalSigns? get latest => _latest;
  
  void updateVital(VitalSigns vital) {
    _latest = vital;
    notifyListeners();
  }
}

// In widget
final vital = context.watch<VitalSignsProvider>().latest;
```

### 12.4 Performance

✅ **DO**: Sử dụng const constructors
```dart
// ✅ Good
const Text('Hello')
const SizedBox(height: 16)
const Icon(Icons.home)
```

✅ **DO**: Dispose controllers
```dart
@override
void dispose() {
  _controller.dispose();
  _scrollController.dispose();
  super.dispose();
}
```

---

## 13. TROUBLESHOOTING

### 13.1 Build Errors

**Android Gradle Error**:
```bash
# Solution: Update Gradle version
android/gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6.3-all.zip
```

**iOS Pod Install Error**:
```bash
cd ios
pod deintegrate
pod install
```

### 13.2 Runtime Issues

**Socket.IO not connecting**:
```dart
// Check if token exists
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('auth_token');
print('Token: $token');
```

**ZegoCloud call not working**:
```dart
// Ensure navigatorKey is set before MaterialApp
ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
```

---

## 14. BUILD & DEPLOYMENT

### 14.1 Build Android APK

```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### 14.2 Build iOS

```bash
# Ensure CocoaPods updated
cd ios
pod install
cd ..

# Build
flutter build ios --release
```

### 14.3 Build Windows

```bash
flutter build windows --release
```

---

**✅ Hoàn thành tài liệu App Flutter!**
