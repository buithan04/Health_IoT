import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:health_iot/service/doctor_service.dart';
import 'package:health_iot/service/chat_service.dart';
import 'package:health_iot/models/common/appointment_model.dart';
import 'package:health_iot/core/constants/app_config.dart';

class DoctorScheduleScreen extends StatelessWidget {
  const DoctorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text('Lịch làm việc'),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.inter(
            color: const Color(0xFF1A202C),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1A202C)),
            onPressed: () => context.go('/doctor/dashboard'),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: TabBar(
                isScrollable: false,
                labelColor: const Color(0xFF009688),
                unselectedLabelColor: const Color(0xFF718096),
                indicatorColor: const Color(0xFF009688),
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: const [
                  Tab(text: 'Chờ duyệt'),
                  Tab(text: 'Sắp tới'),
                  Tab(text: 'Hoàn thành'),
                  Tab(text: 'Đã hủy'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _AppointmentList(status: 'pending'),
            _AppointmentList(status: 'confirmed'),
            _AppointmentList(status: 'completed'),
            _AppointmentList(status: 'cancelled'),
          ],
        ),
      ),
    );
  }
}

class _AppointmentList extends StatefulWidget {
  final String status;
  const _AppointmentList({required this.status});

  @override
  State<_AppointmentList> createState() => _AppointmentListState();
}

class _AppointmentListState extends State<_AppointmentList> with AutomaticKeepAliveClientMixin {
  final DoctorService _doctorService = DoctorService();
  final ChatService _chatService = ChatService();

  List<Appointment> _appointments = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _doctorService.getAppointmentsByStatus(widget.status);
      if (mounted) {
        setState(() {
          _appointments = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _processAvatarUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') {
      return 'assets/images/default-avatar.png';
    }
    if (url.startsWith('http')) return url;
    if (url.startsWith('/')) {
      return '${AppConfig.baseUrl}$url';
    }
    return '${AppConfig.baseUrl}/$url';
  }

  Future<void> _chatWithPatient(Appointment appt) async {
    if (appt.patientId.isEmpty || appt.patientId == '0') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi: Không có ID bệnh nhân")));
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final conversationId = await _chatService.startChat(appt.patientId).timeout(const Duration(seconds: 10));
      if (mounted) setState(() => _isProcessing = false);

      if (conversationId != null) {
        final rawName = (appt.patientName.isNotEmpty) ? appt.patientName : "Bệnh nhân";
        final name = Uri.encodeComponent(rawName);
        final avatarRaw = _processAvatarUrl(appt.patientAvatar);
        final avatar = Uri.encodeComponent(avatarRaw);

        if (mounted) {
          context.push('/doctor/chat/details/$conversationId?name=$name&partnerId=${appt.patientId}&avatar=$avatar');
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi kết nối Chat")));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }

  void _confirmCancelAction(Appointment appt) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xác nhận hủy?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Bạn muốn hủy lịch hẹn với ${appt.patientName}?"),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do hủy (bắt buộc)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Quay lại")),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập lý do hủy")));
                return;
              }
              Navigator.of(ctx).pop();
              _handleAction(appt.id, 'cancelled', reason: reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Đồng ý hủy"),
          ),
        ],
      ),
    );
  }

  void _confirmCompleteAction(Appointment appt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận hoàn thành", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Xác nhận buổi khám với ${appt.patientName} đã kết thúc?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Quay lại")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleAction(appt.id, 'completed');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            child: const Text("Hoàn thành"),
          ),
        ],
      ),
    );
  }

  // --- [FIX] SỬA LOGIC HIỂN THỊ THÔNG BÁO TẠI ĐÂY ---
  Future<void> _handleAction(String id, String newStatus, {String? reason}) async {
    setState(() => _isProcessing = true);

    final index = _appointments.indexWhere((a) => a.id == id);
    final item = index != -1 ? _appointments[index] : null;

    if (item != null) {
      setState(() => _appointments.removeAt(index));
    }

    try {
      final success = await _doctorService.respondToAppointment(id, newStatus, reason: reason);

      if (mounted) setState(() => _isProcessing = false);

      if (success && mounted) {
        // [FIX LOGIC] Phân biệt rõ thông báo cho từng trạng thái
        String message = "";
        Color bgColor = Colors.grey;

        switch (newStatus) {
          case 'confirmed':
            message = 'Đã chấp nhận lịch hẹn ✅';
            bgColor = const Color(0xFF009688);
            break;
          case 'completed':
            message = 'Đã hoàn thành buổi khám 🎉';
            bgColor = Colors.teal;
            break;
          case 'cancelled':
            message = 'Đã hủy lịch hẹn ❌';
            bgColor = Colors.red;
            break;
          default:
            message = 'Cập nhật thành công';
            bgColor = Colors.blue;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: bgColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted && item != null) {
        // Rollback lại UI nếu API lỗi
        setState(() {
          if (index < _appointments.length) {
            _appointments.insert(index, item);
          } else {
            _appointments.add(item);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi cập nhật trạng thái")));
      }
    } catch (e) {
      if (mounted && item != null) {
        // Rollback lại UI nếu Exception
        setState(() {
          if (index < _appointments.length) {
            _appointments.insert(index, item);
          } else {
            _appointments.add(item);
          }
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Có lỗi xảy ra")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: Color(0xFF009688)))
        else if (_appointments.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy_rounded, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Chưa có lịch hẹn nào', style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 16)),
              ],
            ),
          )
        else
          RefreshIndicator(
            onRefresh: _fetchData,
            color: const Color(0xFF009688),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _appointments.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final appt = _appointments[index];
                return _AppointmentCardNew(
                  appointment: appt,
                  status: widget.status,
                  avatarUrl: _processAvatarUrl(appt.patientAvatar),
                  onAccept: () => _handleAction(appt.id, 'confirmed'),
                  onCancel: () => _confirmCancelAction(appt),
                  onChat: () => _chatWithPatient(appt),
                  onComplete: () => _confirmCompleteAction(appt),
                  onTap: () async {
                    final result = await context.push('/doctor/appointment-details/${appt.id}');
                    if (result == true) _fetchData();
                  },
                );
              },
            ),
          ),
        if (_isProcessing)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
      ],
    );
  }
}

// --- [ĐÃ SỬA] WIDGET NÀY GIỮ NGUYÊN FIX MÚI GIỜ ---
class _AppointmentCardNew extends StatelessWidget {
  final Appointment appointment;
  final String status;
  final String avatarUrl;
  final VoidCallback onAccept;
  final VoidCallback onCancel;
  final VoidCallback onChat;
  final VoidCallback onComplete;
  final VoidCallback onTap;

  const _AppointmentCardNew({
    required this.appointment,
    required this.status,
    required this.avatarUrl,
    required this.onAccept,
    required this.onCancel,
    required this.onChat,
    required this.onComplete,
    required this.onTap,
  });

  Map<String, dynamic> _getStatusStyle(String status) {
    switch (status) {
      case 'pending': return {'color': const Color(0xFFD97706), 'bg': const Color(0xFFFFFBEB), 'text': 'Chờ duyệt'};
      case 'confirmed': return {'color': const Color(0xFF2563EB), 'bg': const Color(0xFFEFF6FF), 'text': 'Sắp tới'};
      case 'completed': return {'color': const Color(0xFF059669), 'bg': const Color(0xFFECFDF5), 'text': 'Hoàn thành'};
      case 'cancelled': return {'color': const Color(0xFFDC2626), 'bg': const Color(0xFFFEF2F2), 'text': 'Đã hủy'};
      default: return {'color': Colors.grey, 'bg': Colors.grey.shade100, 'text': status};
    }
  }

  String _formatPrice(num? price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price ?? 0);
  }

  Widget _buildAvatarImage() {
    if (avatarUrl.startsWith('http')) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/default-avatar.png', fit: BoxFit.cover);
        },
      );
    }
    return Image.asset(
      'assets/images/default-avatar.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.person, color: Colors.grey);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- [FIX LOGIC TIME - Múi giờ] ---
    // Force lấy chuỗi giờ server bỏ Z để parse thành Local chính xác
    String rawDate = appointment.date.toIso8601String().replaceAll('Z', '');
    final DateTime startTime = DateTime.parse(rawDate);
    final DateTime now = DateTime.now();

    // 1. Logic hoàn thành: Hiện tại >= (Giờ hẹn - 15 phút)
    bool canComplete = now.isAfter(startTime.add(const Duration(minutes: 15)));

    // 2. Logic hủy: Chỉ được hủy trước 30 phút
    bool canCancel = now.isBefore(startTime.subtract(const Duration(minutes: 30)));

    // [QUAN TRỌNG] Nếu đã đến giờ hoàn thành, thì cưỡng chế tắt nút hủy
    if (canComplete) {
      canCancel = false;
    }

    final style = _getStatusStyle(status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF64748B).withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 1. HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFF0FDFA), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF0D9488)),
                        ),
                        const SizedBox(width: 10),
                        Text(appointment.fullDateTimeStr, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF334155), fontSize: 14)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: style['bg'], borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: style['color']),
                          const SizedBox(width: 6),
                          Text(style['text'], style: GoogleFonts.inter(color: style['color'], fontWeight: FontWeight.w700, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. INFO
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                      ),
                      child: ClipOval(
                        child: _buildAvatarImage(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.patientName.isNotEmpty ? appointment.patientName : "Bệnh nhân",
                            style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18, color: const Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              appointment.serviceName ?? 'Khám thường',
                              style: GoogleFonts.inter(color: Colors.teal.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (appointment.price != null && appointment.price! > 0)
                            Text(
                              _formatPrice(appointment.price),
                              style: GoogleFonts.inter(color: Colors.orange.shade800, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 3. ACTIONS
                if (status == 'pending' || status == 'confirmed') ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(icon: Icons.chat_bubble_outline_rounded, label: 'Nhắn tin', color: const Color(0xFF3B82F6), bgColor: const Color(0xFFEFF6FF), onPressed: onChat),
                      ),
                      const SizedBox(width: 12),

                      if (status == 'pending') ...[
                        Expanded(child: _ActionButton(icon: Icons.close_rounded, label: 'Từ chối', color: const Color(0xFFEF4444), bgColor: Colors.white, isOutlined: true, onPressed: onCancel)),
                        const SizedBox(width: 12),
                        Expanded(child: _ActionButton(icon: Icons.check_rounded, label: 'Duyệt', color: Colors.white, bgColor: const Color(0xFF0D9488), isFilled: true, onPressed: onAccept)),

                      ] else if (status == 'confirmed') ...[

                        if (canComplete) ...[
                          // Nút Hoàn thành hiện khi đến giờ
                          Expanded(child: _ActionButton(icon: Icons.check_circle_outline, label: 'Hoàn thành', color: Colors.white, bgColor: Colors.teal, isFilled: true, onPressed: onComplete)),

                        ] else if (canCancel) ...[
                          // Nút hủy hiện khi còn sớm
                          Expanded(child: _ActionButton(icon: Icons.event_busy_rounded, label: 'Hủy lịch', color: const Color(0xFFEF4444), bgColor: const Color(0xFFFEF2F2), onPressed: onCancel)),

                        ] else ...[
                          // Khoảng thời gian đệm
                          Expanded(
                            child: Container(
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange.shade200)
                              ),
                              child: Text("Sắp diễn ra", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                            ),
                          )
                        ]
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon; final String label; final Color color; final Color bgColor; final VoidCallback onPressed; final bool isFilled; final bool isOutlined;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.bgColor, required this.onPressed, this.isFilled = false, this.isOutlined = false});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    final textStyle = GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13);
    const padding = EdgeInsets.symmetric(vertical: 14);

    if (isFilled) return ElevatedButton.icon(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: bgColor, foregroundColor: color, elevation: 0, shape: RoundedRectangleBorder(borderRadius: borderRadius), padding: padding, textStyle: textStyle), icon: Icon(icon, size: 18), label: Text(label));
    if (isOutlined) return OutlinedButton.icon(onPressed: onPressed, style: OutlinedButton.styleFrom(foregroundColor: color, side: BorderSide(color: color.withOpacity(0.3)), shape: RoundedRectangleBorder(borderRadius: borderRadius), padding: padding, textStyle: textStyle), icon: Icon(icon, size: 18), label: Text(label));
    return TextButton.icon(onPressed: onPressed, style: TextButton.styleFrom(backgroundColor: bgColor, foregroundColor: color, shape: RoundedRectangleBorder(borderRadius: borderRadius), padding: padding, textStyle: textStyle), icon: Icon(icon, size: 18), label: Text(label));
  }
}