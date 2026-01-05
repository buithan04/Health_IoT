import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Import Core, Service & Models
import 'package:health_iot/core/api/api_client.dart';
import 'package:health_iot/service/user_service.dart';
import 'package:health_iot/service/mqtt_service.dart';
import 'package:health_iot/models/patient/health_model.dart'; // <--- IMPORT QUAN TRỌNG (includes AIDiagnosis)
import 'package:health_iot/models/common/user_model.dart'; // <--- IMPORT USER MODEL
import 'package:health_iot/core/constants/app_config.dart';
import 'package:health_iot/core/responsive/responsive.dart';
import 'package:health_iot/core/utils/io.dart' as io;
import 'package:health_iot/service/notification_service.dart';
import 'package:health_iot/service/socket_service.dart';
import 'package:health_iot/presentation/patient/dashboard/widgets/professional_ecg_monitor.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  // Services
  final UserService _userService = UserService(ApiClient());
  final MqttService _mqttService = MqttService();
  final NotificationService _notifService = NotificationService();
  final SocketService _socketService = SocketService();
  final ImagePicker _picker = ImagePicker();

  // State User Info
  String _fullName = "Đang tải...";
  String? _avatarUrl;
  bool _isUploading = false;
  int _unreadNotifCount = 0;

  @override
  void initState() {
    super.initState();
    _initDashboard();
    _setupSocket();
  }

  void _setupSocket() {
    _socketService.connect();
    
    // Listen for general notifications
    _socketService.notificationStream.listen((_) {
      if (mounted) {
        setState(() {
          _unreadNotifCount++;
        });
      }
    });

    // Listen for health alerts (real-time dangerous condition warnings)
    _socketService.healthAlertStream.listen((alertData) {
      if (mounted) {
        _showHealthAlert(alertData);
      }
    });
  }

  void _initDashboard() async {
    // Connect MQTT in background (không block UI)
    _mqttService.connect().catchError((error) {
      print("⚠️ MQTT connection error: $error");
    });

    try {
      // Lấy số lượng thông báo chưa đọc
      final unread = await _notifService.getUnreadCount();

      // userData bây giờ là User object (có thể null)
      final userData = await _userService.getUserProfile();

      if (mounted && userData != null) {
        setState(() {
          _unreadNotifCount = unread;
          // SỬA Ở ĐÂY: Dùng dấu chấm (.) thay vì ['key']
          _fullName = userData.fullName;
          _avatarUrl = userData.avatarUrl;
        });
      }
    } catch (e) {
      print("❌ Lỗi tải dashboard: $e");
    }
  }

  // --- LOGIC UPLOAD ẢNH (Giữ nguyên) ---
  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        height: 150,
        child: Column(
          children: [
            const Text("Đổi ảnh đại diện", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconBtn(Icons.camera_alt, "Chụp ảnh", ImageSource.camera),
                _buildIconBtn(Icons.photo_library, "Thư viện", ImageSource.gallery),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, String label, ImageSource source) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _pickAndUploadImage(source);
      },
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.teal),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi ảnh chưa hỗ trợ trên web'), backgroundColor: Colors.orange),
        );
      }
      return;
    }
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 600,
      );
      if (pickedFile == null) return;

      setState(() => _isUploading = true);
      io.File imageFile = io.File(pickedFile.path);

      String newAvatarUrl = await _userService.uploadAvatar(imageFile);

      setState(() {
        _avatarUrl = newAvatarUrl;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật ảnh thành công!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi upload: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Show health alert dialog when dangerous condition detected
  void _showHealthAlert(Map<String, dynamic> alertData) {
    final riskLevel = alertData['riskLevel'] ?? 'warning';
    final alert = alertData['alert'] as Map<String, dynamic>?;
    final recommendations = alertData['recommendations'] as List?;

    // Determine color based on risk level
    Color alertColor = Colors.orange;
    IconData alertIcon = Icons.warning_amber;
    
    if (riskLevel == 'critical') {
      alertColor = Colors.red;
      alertIcon = Icons.medical_services;
    } else if (riskLevel == 'danger') {
      alertColor = Colors.deepOrange;
      alertIcon = Icons.error_outline;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(alertIcon, color: alertColor, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                alert?['title'] ?? 'Cảnh báo sức khỏe',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: alertColor,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (alert != null) ...[
                Text(
                  alert['message'] ?? '',
                  style: GoogleFonts.inter(fontSize: 15),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: alertColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: alertColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Giá trị: ${alert['value']} ${alert['unit'] ?? ''}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: alertColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (recommendations != null && recommendations.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Khuyến nghị:',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: alertColor)),
                      Expanded(
                        child: Text(
                          rec.toString(),
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Đã hiểu', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
          if (riskLevel == 'critical' || riskLevel == 'danger')
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/find-doctor'); // Navigate to find doctor
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: alertColor,
              ),
              child: Text('Liên hệ bác sĩ', style: GoogleFonts.inter(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final padding = Responsive.pagePadding(context);
          final maxContentWidth = Responsive.maxContentWidth(context);

          return CustomScrollView(
            slivers: [
              _buildHeader(context),
              SliverPadding(
                padding: padding,
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StreamBuilder<HealthMetric>(
                            stream: _mqttService.healthStream,
                            initialData: HealthMetric.empty(),
                            builder: (context, snapshot) {
                              final health = snapshot.data!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Connection Status VITALS với realtime từ Socket
                                  StreamBuilder<bool>(
                                    stream: _mqttService.vitalsConnectionStream,
                                    initialData: false,
                                    builder: (context, connectionSnapshot) {
                                      final isOnline = connectionSnapshot.data ?? false;
                                      return Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: isOnline ? Colors.green : Colors.red,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isOnline
                                                ? "Vitals Online: Đang nhận dữ liệu SpO2, HR, BP"
                                                : "Vitals Offline: Chưa có dữ liệu sinh hiệu",
                                            style: GoogleFonts.inter(
                                              color: isOnline ? Colors.green : Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          if (isOnline)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.sensors, size: 10, color: Colors.green),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Realtime",
                                                    style: GoogleFonts.inter(
                                                      color: Colors.green,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  const _SectionTitle(title: 'Sức khỏe hôm nay'),
                                  const SizedBox(height: 16),
                                  _HealthStatsGrid(metric: health, width: width),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 24),
                          
                          // AI Diagnosis Card (hiển thị kết quả chẩn đoán)
                          StreamBuilder<Map<String, dynamic>>(
                            stream: _socketService.aiDiagnosisStream,
                            builder: (context, diagnosisSnapshot) {
                              if (!diagnosisSnapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final diagnosisData = diagnosisSnapshot.data!;
                              final diagnosis = AIDiagnosis.fromJson(diagnosisData);

                              return _AIDiagnosisCard(diagnosis: diagnosis);
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          _EcgChartCard(
                            mqttService: _mqttService,
                            connectionStatusStream: _socketService.connectionStatusStream,
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle(title: 'Tính năng'),
                          const SizedBox(height: 16),
                          _FeaturesGrid(width: width),
                          const SizedBox(height: 16),
                          const _OtherFeaturesList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;
    final String displayAvatar = AppConfig.formatUrl(_avatarUrl);

    return SliverPadding(
      padding: EdgeInsets.only(
        top: topInset + 10,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      sliver: SliverAppBar(
        backgroundColor: Colors.transparent,
        pinned: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        expandedHeight: 120,
        collapsedHeight: 70,
        toolbarHeight: 70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF2DD4BF), Color(0xFF06B6D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showImageSourcePicker,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.0),
                        ),
                        child: _isUploading
                            ? const CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                ),
                              )
                            : CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.teal.shade100,
                                backgroundImage: displayAvatar.isNotEmpty
                                    ? NetworkImage(displayAvatar)
                                    : null,
                                onBackgroundImageError: displayAvatar.isNotEmpty ? (_, __) {} : null,
                                child: displayAvatar.isEmpty
                                    ? Icon(Icons.person, size: 24, color: Colors.teal.shade700)
                                    : null,
                              ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 12, color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Chào mừng,', style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
                    Text(
                      _fullName,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () async {
                        await context.push('/notifications');
                        final count = await _notifService.getUnreadCount();
                        if (mounted) setState(() => _unreadNotifCount = count);
                      },
                    ),
                    if (_unreadNotifCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _unreadNotifCount > 99 ? '99+' : '$_unreadNotifCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
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
}

// --- CÁC WIDGET CON ---

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF374151)),
    );
  }
}

// Widget Grid nhận Model HealthMetric
class _HealthStatsGrid extends StatelessWidget {
  final HealthMetric metric; // <--- Dùng Model thay vì từng biến lẻ
  final double width;

  const _HealthStatsGrid({required this.metric, required this.width});

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = Responsive.columnsForStats(width);
    final spacing = Responsive.gridSpacing(context);
    final aspect = Responsive.statsAspect(width);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: aspect,
      children: [
        _StatCard(
            icon: Icons.water_drop_outlined,
            title: 'SpO2',
            value: metric.spo2, // Lấy từ model
            unit: '%',
            color: const Color(0xFF14B8A6)),
        _StatCard(
            icon: Icons.favorite_border,
            title: 'Nhịp tim',
            value: metric.heartRate, // Lấy từ model
            unit: 'BPM',
            color: Colors.red.shade500),
        _StatCard(
            icon: Icons.thermostat_outlined,
            title: 'Thân nhiệt',
            value: metric.temperature, // Lấy từ model
            unit: '°C',
            color: Colors.orange.shade500),
        _StatCard(
            icon: Icons.speed,
            title: 'Huyết áp',
            value: metric.bloodPressure, // Lấy từ model
            unit: 'mmHg',
            color: Colors.purple.shade500),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              unit,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... (Các Widget _EcgChartCard, _FeaturesGrid, _OtherFeaturesList, _FeatureGridItem, _FeatureListItem GIỮ NGUYÊN NHƯ CŨ) ...
// Bạn copy lại phần code của các widget này từ file cũ vào đây là được.
// Chú ý: Nhớ copy class _EcgChartCard, _FeaturesGrid, v.v... vào cuối file này.
class _EcgChartCard extends StatelessWidget {
  final MqttService mqttService;
  final Stream<bool> connectionStatusStream;
  const _EcgChartCard({required this.mqttService, required this.connectionStatusStream});
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: mqttService.ecgStream,
      builder: (context, snapshot) {
        // Dữ liệu ECG từ MQTT
        List<int>? dataPoints;
        String? packetId;
        DateTime? timestamp;
        
        if (snapshot.hasData) {
          final ecgData = snapshot.data!;
          dataPoints = List<int>.from(ecgData['dataPoints'] ?? []);
          packetId = ecgData['packet_id']?.toString();
          final timestampStr = ecgData['timestamp'];
          if (timestampStr != null) {
            timestamp = DateTime.tryParse(timestampStr);
          }
        } else if (mqttService.currentECGData != null) {
          // Hiển thị dữ liệu cũ nếu không có dữ liệu mới
          final ecgData = mqttService.currentECGData!;
          dataPoints = List<int>.from(ecgData['dataPoints'] ?? []);
          packetId = ecgData['packet_id']?.toString();
          final timestampStr = ecgData['timestamp'];
          if (timestampStr != null) {
            timestamp = DateTime.tryParse(timestampStr);
          }
        }
        
        // Use Professional ECG Monitor
        return StreamBuilder<bool>(
          stream: mqttService.ecgConnectionStream,
          initialData: false,
          builder: (context, connectionSnapshot) {
            final isConnected = connectionSnapshot.data ?? false;
            
            return ProfessionalECGMonitor(
              dataPoints: dataPoints,
              packetId: packetId,
              timestamp: timestamp,
              isConnected: isConnected,
              samplingRate: 125,
            );
          },
        );
      },
    );
  }
}

// === AI DIAGNOSIS CARD ===
class _AIDiagnosisCard extends StatelessWidget {
  final AIDiagnosis diagnosis;

  const _AIDiagnosisCard({required this.diagnosis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: diagnosis.severityColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: diagnosis.severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  diagnosis.severityIcon,
                  color: diagnosis.severityColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '🤖 Chẩn đoán AI',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: diagnosis.model == 'MLP' 
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            diagnosis.model,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: diagnosis.model == 'MLP' ? Colors.blue : Colors.purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm - dd/MM/yyyy').format(diagnosis.timestamp),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Kết quả chẩn đoán
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kết quả',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diagnosis.result,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: diagnosis.severityColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Độ tin cậy',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${diagnosis.confidence.toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          diagnosis.confidence >= 80 
                            ? Icons.verified 
                            : Icons.info_outline,
                          color: diagnosis.confidence >= 80 
                            ? Colors.green 
                            : Colors.orange,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Recommendation (nếu có)
          if (diagnosis.recommendation != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: diagnosis.severityColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: diagnosis.severityColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: diagnosis.severityColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      diagnosis.recommendation!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF1F2937),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Actions
          if (diagnosis.severity == 'DANGER' || diagnosis.severity == 'WARNING') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/find-doctor');
                },
                icon: const Icon(Icons.medical_services, size: 18),
                label: Text(
                  'Liên hệ bác sĩ ngay',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: diagnosis.severityColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  final double width;
  const _FeaturesGrid({required this.width});
  @override
  Widget build(BuildContext context) {
    final crossAxisCount = Responsive.columnsForFeatures(width);
    final spacing = Responsive.gridSpacing(context);
    final aspect = Responsive.featureAspect(width);

    return GridView.count(crossAxisCount: crossAxisCount, crossAxisSpacing: spacing, mainAxisSpacing: spacing, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: aspect, children: [
      _FeatureGridItem(icon: Icons.search, title: 'Tìm Bác sĩ', subtitle: 'Đặt lịch khám', iconBgColor: Colors.teal.shade100, iconColor: Colors.teal, onTap: () => context.push('/find-doctor')),
      _FeatureGridItem(icon: Icons.calendar_today_outlined, title: 'Lịch hẹn', subtitle: 'Quản lý lịch', iconBgColor: Colors.indigo.shade100, iconColor: Colors.indigo, onTap: () => context.push('/appointments')),
      _FeatureGridItem(icon: Icons.description_outlined, title: 'Đơn thuốc', subtitle: 'Xem toa thuốc', iconBgColor: Colors.amber.shade100, iconColor: Colors.amber, onTap: () => context.push('/prescriptions')),
      _FeatureGridItem(icon: Icons.chat_bubble_outline, title: 'Tư vấn', subtitle: 'Trò chuyện 24/7', iconBgColor: Colors.lightBlue.shade100, iconColor: Colors.lightBlue, onTap: () => context.push('/chat')),
    ]);
  }
}

class _FeatureGridItem extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color iconBgColor; final Color iconColor; final VoidCallback onTap;
  const _FeatureGridItem({required this.icon, required this.title, required this.subtitle, required this.iconBgColor, required this.iconColor, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(elevation: 4, shadowColor: Colors.black.withOpacity(0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Padding(padding: const EdgeInsets.all(16.0), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)), Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]))]))]))));
  }
}

class _OtherFeaturesList extends StatelessWidget {
  const _OtherFeaturesList();
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _FeatureListItem(title: 'Nhắc nhở uống thuốc', subtitle: 'Đừng bỏ lỡ liều thuốc nào', icon: Icons.notifications_active_outlined, iconColor: Colors.teal, onTap: () => context.push('/medication-reminders')),
      const SizedBox(height: 12),
      _FeatureListItem(title: 'Bài viết sức khỏe', subtitle: 'Cập nhật tin tức & lời khuyên', icon: Icons.article_outlined, iconColor: Colors.purple, onTap: () => context.push('/health-articles')),
    ]);
  }
}

class _FeatureListItem extends StatelessWidget {
  final String title; final String subtitle; final IconData icon; final Color iconColor; final VoidCallback onTap;
  const _FeatureListItem({required this.title, required this.subtitle, required this.icon, required this.iconColor, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(elevation: 4, shadowColor: Colors.black.withOpacity(0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]))])), Icon(icon, color: iconColor, size: 32)]))));
  }
}