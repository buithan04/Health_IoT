import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_iot/core/api/api_client.dart';
import 'package:app_iot/service/user_service.dart';
import 'package:app_iot/service/doctor_service.dart';
import 'package:app_iot/models/common/user_model.dart';
import 'package:app_iot/models/common/appointment_model.dart';
import 'package:app_iot/core/responsive/responsive.dart';
import 'package:app_iot/core/utils/io.dart' as io;
import 'package:app_iot/service/notification_service.dart';
import 'package:app_iot/service/socket_service.dart';
import 'package:app_iot/presentation/widgets/custom_avatar.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final UserService _userService = UserService(ApiClient());
  final DoctorService _doctorService = DoctorService();
  final NotificationService _notifService = NotificationService();
  final SocketService _socketService = SocketService();
  final ImagePicker _picker = ImagePicker();

  User? _user;
  List<Appointment> _todayAppointments = [];
  int _pendingCount = 0;
  int _unreadNotifCount = 0;
  bool _isLoading = true;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupSocket();
  }

  void _setupSocket() {
    _socketService.connect();
    _socketService.notificationStream.listen((_) {
      if (mounted) {
        setState(() {
          _unreadNotifCount++;
        });
      }
    });
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _userService.getUserProfile(),
        _doctorService.getDashboardStats(),
        _doctorService.getTodayAppointments(),
        _notifService.getUnreadCount(),
      ]);

      if (mounted) {
        setState(() {
          _user = results[0] as User?;
          final stats = results[1] as Map<String, dynamic>;
          _pendingCount = int.tryParse(stats['pending_requests']?.toString() ?? '0') ?? 0;
          _todayAppointments = results[2] as List<Appointment>;
          _unreadNotifCount = results[3] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi Dashboard: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text("Cập nhật ảnh đại diện", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildOptionItem(Icons.photo_library_rounded, Colors.blue, "Chọn từ thư viện", () => _handleImageSelection(ImageSource.gallery)),
            const SizedBox(height: 12),
            _buildOptionItem(Icons.camera_alt_rounded, const Color(0xFF2DD4BF), "Chụp ảnh mới", () => _handleImageSelection(ImageSource.camera)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, Color color, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(text, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi ảnh chưa hỗ trợ trên web'), backgroundColor: Colors.orange),
        );
      }
      return;
    }
    Navigator.pop(context);
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        setState(() => _isUploadingAvatar = true);
        io.File file = io.File(image.path);
        await _userService.uploadAvatar(file);
        await _loadData();
        if (mounted) {
          setState(() => _isUploadingAvatar = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật ảnh thành công!'), backgroundColor: Color(0xFF06B6D4)));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi tải ảnh lên.'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF06B6D4),
              child: LayoutBuilder(
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
                                  _RequestsBanner(pendingCount: _pendingCount),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const _SectionTitle(title: 'Lịch trình hôm nay'),
                                      if (_todayAppointments.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(12)),
                                          child: Text('${_todayAppointments.length} cuộc hẹn', style: GoogleFonts.inter(color: const Color(0xFF0F766E), fontWeight: FontWeight.bold, fontSize: 12)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _TodaySchedule(appointments: _todayAppointments),
                                  const SizedBox(height: 24),
                                  const _SectionTitle(title: 'Tổng quan'),
                                  const SizedBox(height: 16),
                                  _OverviewGrid(width: width),
                                  const SizedBox(height: 24),
                                  const _SectionTitle(title: 'Công cụ & Tính năng'),
                                  const SizedBox(height: 16),
                                  _FeaturesList(doctorId: _user?.id),
                                  const SizedBox(height: 40),
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
            ),
    );
  }

  // --- HÀM HEADER ĐÃ ĐƯỢC FIX LẠI ---
  Widget _buildHeader(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;
    final avatarUrl = _user?.fullAvatarUrl ?? '';
    final name = _user?.fullName ?? 'Bác sĩ';

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
        // Bỏ 'title' ở đây để tránh bị giới hạn chiều cao toolbar
        leading: const SizedBox(),
        leadingWidth: 0,
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
                  onTap: _isUploadingAvatar ? null : _showImagePickerOptions,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.0),
                        ),
                        child: _isUploadingAvatar
                            ? const CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                        )
                            : CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.teal.shade100,
                          backgroundImage: avatarUrl.isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                          onBackgroundImageError: avatarUrl.isNotEmpty ? (_, __) {} : null,
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 14, color: Color(0xFF0F766E)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/doctor/profile'),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Chào buổi sáng,', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(name, style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () async {
                        await context.push('/doctor/notifications');
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
        title,
        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF374151))
    );
  }
}

class _RequestsBanner extends StatelessWidget {
  final int pendingCount;
  const _RequestsBanner({required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    if (pendingCount == 0) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/doctor/requests'),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade500,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.priority_high_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yêu cầu mới',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange.shade900)),
                      const SizedBox(height: 4),
                      Text('Bạn có $pendingCount lịch hẹn đang chờ duyệt.',
                          style: GoogleFonts.inter(color: Colors.orange.shade800, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.orange.shade800, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodaySchedule extends StatelessWidget {
  final List<Appointment> appointments;
  const _TodaySchedule({required this.appointments});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
              child: Icon(Icons.event_available_rounded, size: 32, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 12),
            Text("Hôm nay bạn rảnh rỗi!",
                style: GoogleFonts.inter(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return SizedBox(
      height: 135,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: appointments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final appt = appointments[index];
          Color statusColor;
          String statusText;
          Color cardBorderColor;

          switch (appt.status.toLowerCase()) {
            case 'pending':
              statusColor = Colors.orange;
              statusText = 'Chờ duyệt';
              cardBorderColor = Colors.orange.shade100;
              break;
            case 'confirmed':
              statusColor = const Color(0xFF0F766E);
              statusText = 'Đã duyệt';
              cardBorderColor = const Color(0xFF0F766E).withOpacity(0.2);
              break;
            case 'cancelled':
              statusColor = Colors.red;
              statusText = 'Đã hủy';
              cardBorderColor = Colors.red.shade100;
              break;
            case 'completed':
              statusColor = Colors.blue;
              statusText = 'Hoàn thành';
              cardBorderColor = Colors.blue.shade100;
              break;
            default:
              statusColor = Colors.grey;
              statusText = appt.status;
              cardBorderColor = Colors.grey.shade200;
          }

          return Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: const Color(0xFF64748B).withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))
              ],
              border: Border.all(color: cardBorderColor, width: 1),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  context.push('/doctor/appointment-details/${appt.id}');
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 16, color: statusColor),
                              const SizedBox(width: 6),
                              Text(appt.timeStr,
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B), fontSize: 15)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusText,
                              style: GoogleFonts.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade100, width: 1),
                            ),
                            child: CustomAvatar(
                              imageUrl: appt.patientAvatar,
                              radius: 20,
                              fallbackText: appt.patientName,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(appt.patientName,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                                const SizedBox(height: 2),
                                Text(appt.serviceName ?? 'Khám dịch vụ',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturesList extends StatelessWidget {
  final String? doctorId;
  const _FeaturesList({this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FeatureCard(
          title: 'Quản lý Dịch vụ khám',
          subtitle: 'Thêm, sửa, xóa các gói khám bệnh',
          icon: Icons.medical_services_outlined,
          color: const Color(0xFF14B8A6),
          onTap: () => doctorId != null
              ? context.push('/doctor/services', extra: doctorId)
              : null,
        ),
        const SizedBox(height: 12),
        _FeatureCard(
            title: 'Ghi chú nhanh',
            subtitle: 'Lưu lại các ghi chú quan trọng',
            icon: Icons.edit_note_rounded,
            color: const Color(0xFFF59E0B),
            onTap: () => context.push('/doctor/notes')
        ),
        const SizedBox(height: 12),
        _FeatureCard(
            title: 'Tư vấn trực tuyến',
            subtitle: 'Trò chuyện với bệnh nhân',
            icon: Icons.chat_bubble_outline_rounded,
            color: const Color(0xFF3B82F6),
            onTap: () => context.push('/doctor/chat')
        ),
        const SizedBox(height: 12),
        _FeatureCard(
            title: 'Danh sách bệnh nhân',
            subtitle: 'Tra cứu hồ sơ và lịch sử',
            icon: Icons.groups_outlined,
            color: const Color(0xFF8B5CF6),
            onTap: () => context.push('/doctor/list_patient')
        ),
        const SizedBox(height: 12),
        _FeatureCard(
            title: 'Quản lý lịch trống',
            subtitle: 'Thiết lập giờ làm việc',
            icon: Icons.calendar_month_outlined,
            color: const Color(0xFFEC4899),
            onTap: () => context.push('/doctor/manage_schedule')
        ),
      ],
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  final double width;
  const _OverviewGrid({required this.width});

  @override
  Widget build(BuildContext context) {
    final isNarrow = width < 720;
    final cardWidth = isNarrow ? double.infinity : 320.0;

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        SizedBox(
          width: cardWidth,
          child: _OverviewCard(
            count: '12',
            label: 'Bệnh nhân',
            icon: Icons.people_alt_rounded,
            color: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFEFF6FF),
            onTap: () => context.push('/doctor/list_patient'),
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: _OverviewCard(
            count: '4.8',
            label: 'Đánh giá',
            icon: Icons.star_rounded,
            color: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFFFBEB),
            onTap: () => context.push('/doctor/profile/reviews'),
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String count; final String label; final IconData icon; final Color color; final Color bgColor; final VoidCallback onTap;
  const _OverviewCard({required this.count, required this.label, required this.icon, required this.onTap, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF64748B).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 16),
                Text(count, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
                Text(label, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title; final String subtitle; final IconData icon; final Color color; final VoidCallback onTap;
  const _FeatureCard({required this.title, required this.subtitle, required this.icon, required this.onTap, this.color = Colors.teal});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF64748B).withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF1E293B))),
                      const SizedBox(height: 2),
                      Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ),
    );
  }
}