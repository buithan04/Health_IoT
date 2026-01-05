import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_iot/service/doctor_service.dart';
import 'package:health_iot/service/chat_service.dart';
import 'package:health_iot/models/common/appointment_model.dart';

// --- CONSTANTS ---
const Color kPrimaryColor = Color(0xFF0D9488); // Teal
const Color kScaffoldColor = Color(0xFFF1F5F9); // Slate 100
const Color kTextDark = Color(0xFF1E293B); // Slate 800
const Color kTextLight = Color(0xFF64748B); // Slate 500

class DoctorAppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;
  const DoctorAppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<DoctorAppointmentDetailScreen> createState() => _DoctorAppointmentDetailScreenState();
}

class _DoctorAppointmentDetailScreenState extends State<DoctorAppointmentDetailScreen> {
  final DoctorService _doctorService = DoctorService();
  final ChatService _chatService = ChatService();

  // --- 2. THÊM BIẾN TIMER ---
  Timer? _timer;

  Appointment? _appointment;
  bool _isLoading = true;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    // --- 3. KHỞI TẠO TIMER ĐỂ CẬP NHẬT UI MỖI 30 GIÂY ---
    // Giúp nút "Hoàn thành" tự động hiện lên khi đến giờ mà không cần tải lại trang
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _appointment != null && _appointment!.status == 'confirmed') {
        setState(() {}); // Trigger build lại để check DateTime.now()
      }
    });
  }

  @override
  void dispose() {
    // --- 4. HỦY TIMER KHI THOÁT MÀN HÌNH ---
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    try {
      final data = await _doctorService.getAppointmentDetail(widget.appointmentId);
      if (mounted) {
        setState(() {
          _appointment = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus, {String? reason}) async {
    if (_appointment == null) return;
    setState(() => _isActionLoading = true);

    try {
      final success = await _doctorService.respondToAppointment(
          _appointment!.id,
          newStatus,
          reason: reason
      );

      if (mounted) {
        setState(() => _isActionLoading = false);
        if (success) {
          // --- [FIX START] SỬA LOGIC THÔNG BÁO ---
          String message = "";
          Color snackBarColor = kPrimaryColor;

          switch (newStatus) {
            case 'confirmed':
              message = "Đã chấp nhận lịch hẹn";
              snackBarColor = kPrimaryColor;
              break;
            case 'completed': // Thêm case này
              message = "Đã hoàn thành buổi khám";
              snackBarColor = Colors.teal;
              break;
            case 'cancelled':
              message = "Đã hủy lịch hẹn";
              snackBarColor = Colors.red;
              break;
            default:
              message = "Cập nhật thành công";
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: snackBarColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // --- [FIX END] ---

          context.pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi cập nhật trạng thái")));
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _completeAppointment() async {
    if (_appointment == null) return;

    final now = DateTime.now();

    // [FIX] Tương tự: Force lấy giờ gốc làm local
    String rawDate = _appointment!.date.toIso8601String().replaceAll('Z', '');
    final DateTime startTime = DateTime.parse(rawDate);

    // Logic: Cho phép hoàn thành sớm 15 phút
    final allowCompletionTime = startTime.subtract(const Duration(minutes: 15));

    if (now.isBefore(allowCompletionTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chưa đến giờ khám, không thể hoàn thành sớm.")),
      );
      return;
    }

    await _updateStatus('completed');
  }


  void _showConfirmDialog(String actionName, String statusToUpdate) {
    final TextEditingController reasonController = TextEditingController();
    bool isCancel = statusToUpdate == 'cancelled';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            const Text("Xác nhận", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bạn có muốn $actionName lịch hẹn này không?", style: const TextStyle(color: kTextLight)),
            if (isCancel) ...[
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Lý do hủy',
                  labelStyle: const TextStyle(color: kTextLight),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
                ),
                maxLines: 2,
              )
            ]
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Quay lại", style: TextStyle(color: kTextLight)),
          ),
          ElevatedButton(
            onPressed: () {
              if (isCancel && reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập lý do")));
                return;
              }
              Navigator.pop(ctx);
              _updateStatus(statusToUpdate, reason: isCancel ? reasonController.text : null);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text("Đồng ý $actionName"),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToChat() async {
    if (_appointment == null) return;
    if (_appointment!.patientId.isEmpty || _appointment!.patientId == '0') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi ID bệnh nhân")));
      return;
    }
    setState(() => _isActionLoading = true);
    try {
      final conversationId = await _chatService.startChat(_appointment!.patientId);
      if (mounted) setState(() => _isActionLoading = false);

      if (conversationId != null) {
        final encodedName = Uri.encodeComponent(_appointment!.patientName);
        final encodedAvatar = Uri.encodeComponent(_appointment!.patientAvatar);
        if (mounted) {
          context.push('/doctor/chat/details/$conversationId?name=$encodedName&partnerId=${_appointment!.patientId}&avatar=$encodedAvatar');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldColor,
      appBar: AppBar(
        title: Text('Chi tiết Lịch hẹn', style: GoogleFonts.inter(color: kTextDark, fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: kTextDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
            : _appointment == null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text("Không tải được dữ liệu", style: TextStyle(color: kTextLight)),
              const SizedBox(height: 8),
              TextButton(onPressed: _fetchDetail, child: const Text("Thử lại", style: TextStyle(color: kPrimaryColor)))
            ],
          ),
        )
            : Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PatientProfileCard(appointment: _appointment!),
                  const SizedBox(height: 24),

                  if (_appointment!.status == 'cancelled') ...[
                    _CancellationReasonCard(reason: _appointment!.cancellationReason ?? "Không có lý do"),
                    const SizedBox(height: 24),
                  ],

                  _SectionTitle(title: 'THÔNG TIN DỊCH VỤ'),
                  const SizedBox(height: 12),
                  _ServiceInfoCard(appointment: _appointment!),

                  const SizedBox(height: 24),
                  _SectionTitle(title: 'THỜI GIAN & ĐỊA ĐIỂM'),
                  const SizedBox(height: 12),
                  _AppointmentInfoCard(appointment: _appointment!),

                  const SizedBox(height: 24),
                  _SectionTitle(title: 'GHI CHÚ Y TẾ'),
                  const SizedBox(height: 12),
                  _MedicalNotesCard(notes: _appointment!.notes),

                  const SizedBox(height: 24),
                  _QuickActionsGrid(patientId: _appointment!.patientId),
                ],
              ),
            ),
            if (_isActionLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
          ],
        ),
      ),
      bottomNavigationBar: (!_isLoading && _appointment != null)
          ? _BottomActionBar(
        appointment: _appointment!, // <--- THAY ĐỔI: Truyền cả object appointment
        onChat: _navigateToChat,
        onAccept: () => _updateStatus('confirmed'),
        onCancel: () {
          if (_appointment!.status == 'pending') {
            _showConfirmDialog("từ chối", 'cancelled');
          } else if (_appointment!.status == 'confirmed') _showConfirmDialog("hủy", 'cancelled');
        },
        onComplete: _completeAppointment, // <--- THAY ĐỔI: Truyền hàm hoàn thành
      )
          : null,
    );
  }
}

// ================= WIDGETS CON ĐÃ ĐƯỢC LÀM ĐẸP =================

class _PatientProfileCard extends StatelessWidget {
  final Appointment appointment;
  const _PatientProfileCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    bool validAvatar = appointment.patientAvatar.isNotEmpty &&
        appointment.patientAvatar.startsWith('http');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF64748B).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: ClipOval(
              child: validAvatar
                  ? Image.network(
                appointment.patientAvatar,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => _buildDefaultAvatar(),
              )
                  : _buildDefaultAvatar(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.patientName.isNotEmpty ? appointment.patientName : "Bệnh nhân ẩn danh",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, color: kTextDark),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Mã BN: #${appointment.patientId.length > 6 ? appointment.patientId.substring(0, 6) : appointment.patientId}',
                    style: GoogleFonts.inter(color: kTextLight, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                _StatusBadge(status: appointment.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(Icons.person, size: 40, color: Colors.grey.shade400),
    );
  }
}

class _ServiceInfoCard extends StatelessWidget {
  final Appointment appointment;
  const _ServiceInfoCard({required this.appointment});

  String _safeMoney(dynamic price) {
    if (price == null) return "0 đ";
    try {
      int val = price is int ? price : (price is double ? price.toInt() : int.tryParse(price.toString()) ?? 0);
      String s = val.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
      return "$s đ";
    } catch (e) {
      return "0 đ";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildRow(Icons.medical_services_rounded, "Dịch vụ khám", appointment.serviceName ?? "Khám tổng quát", Colors.blue),
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),
          _buildRow(Icons.access_time_filled_rounded, "Thời lượng", "${appointment.duration ?? 30} phút", Colors.orange),
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),
          _buildRow(Icons.payments_rounded, "Chi phí", _safeMoney(appointment.price), Colors.green, isBold: true),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(color: kTextLight, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.inter(
                    fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 16,
                    color: isBold ? Colors.green.shade700 : kTextDark
                )),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _AppointmentInfoCard extends StatelessWidget {
  final Appointment appointment;
  const _AppointmentInfoCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    String address = appointment.clinicAddress?.isNotEmpty == true
        ? appointment.clinicAddress!
        : (appointment.hospitalName.isNotEmpty ? appointment.hospitalName : "HealthFlow Clinic");

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.calendar_month_rounded,
            "Thời gian hẹn",
            appointment.fullDateTimeStr,
            const Color(0xFF6366F1),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),
          _buildDetailRow(
            Icons.location_on_rounded,
            "Địa điểm",
            address,
            const Color(0xFFEC4899),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(color: kTextLight, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: kTextDark, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _MedicalNotesCard extends StatelessWidget {
  final String notes;
  const _MedicalNotesCard({required this.notes});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sticky_note_2_rounded, size: 18, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              Text("Lời nhắn từ bệnh nhân:", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: kTextLight, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notes.isNotEmpty ? notes : "Không có ghi chú nào.",
            style: GoogleFonts.inter(height: 1.6, color: kTextDark, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _CancellationReasonCard extends StatelessWidget {
  final String reason;
  const _CancellationReasonCard({required this.reason});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lịch hẹn đã bị hủy", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF991B1B))),
                const SizedBox(height: 4),
                Text(reason, style: GoogleFonts.inter(color: const Color(0xFF7F1D1D))),
              ],
            ),
          ),
        ],
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
      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: kTextLight, letterSpacing: 0.5),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final String patientId;
  const _QuickActionsGrid({required this.patientId});
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _ActionItem(
          icon: Icons.folder_shared_rounded,
          label: "Hồ sơ sức khỏe",
          color: Colors.blue,
          onTap: () => context.push('/doctor/patient-record/$patientId'),
        ),
        _ActionItem(
          icon: Icons.monitor_heart_rounded,
          label: "Chỉ số cơ thể",
          color: Colors.pink,
          onTap: () => context.push('/doctor/patient-stats/$patientId'),
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ActionItem({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: kTextDark, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    Color bg;

    switch (status) {
      case 'pending':
        text = 'Chờ duyệt';
        color = const Color(0xFFD97706);
        bg = const Color(0xFFFFFBEB);
        break;
      case 'confirmed':
        text = 'Đã xác nhận';
        color = const Color(0xFF2563EB);
        bg = const Color(0xFFEFF6FF);
        break;
      case 'completed':
        text = 'Hoàn thành';
        color = const Color(0xFF059669);
        bg = const Color(0xFFECFDF5);
        break;
      case 'cancelled':
        text = 'Đã hủy';
        color = const Color(0xFFDC2626);
        bg = const Color(0xFFFEF2F2);
        break;
      default:
        text = status;
        color = Colors.grey;
        bg = Colors.grey.shade100;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

// [CẬP NHẬT] Widget BottomActionBar với logic hiển thị nút linh hoạt hơn
// --- 5. CẬP NHẬT LOGIC TRONG _BottomActionBar ---
class _BottomActionBar extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onChat;
  final VoidCallback onAccept;
  final VoidCallback onCancel;
  final VoidCallback onComplete;

  const _BottomActionBar({
    required this.appointment,
    required this.onChat,
    required this.onAccept,
    required this.onCancel,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    // [FIX] Force lấy giờ gốc làm local
    String rawDate = appointment.date.toIso8601String().replaceAll('Z', '');
    final DateTime startTime = DateTime.parse(rawDate);

    final DateTime now = DateTime.now();
    final String status = appointment.status;

    // Logic kiểm tra điều kiện (Như bên màn hình danh sách)
    bool canCancel = now.isBefore(startTime.subtract(const Duration(minutes: 30)));
    bool canComplete = now.isAfter(startTime.add(const Duration(minutes: 1)));

    // [FIX] Ưu tiên CanComplete
    if (canComplete) canCancel = false;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Nút Chat luôn hiện
            InkWell(
              onTap: onChat,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF2563EB)),
              ),
            ),
            const SizedBox(width: 16),

            if (status == 'pending') ...[
              Expanded(child: _buildButton("Từ chối", Colors.white, Colors.red, onCancel, isOutlined: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildButton("Chấp nhận", kPrimaryColor, Colors.white, onAccept)),

            ] else if (status == 'confirmed') ...[

              // LOGIC ƯU TIÊN HIỂN THỊ
              if (canComplete) ...[
                // Ưu tiên cao nhất: Đã đến giờ (hoặc sát giờ) -> Hiện nút Hoàn thành
                Expanded(child: _buildButton("Hoàn thành ca khám", Colors.teal, Colors.white, onComplete)),

              ] else if (canCancel) ...[
                // Còn sớm -> Hiện nút Hủy
                Expanded(child: _buildButton("Hủy lịch hẹn", Colors.red.shade50, Colors.red, onCancel)),

              ] else ...[
                // Rơi vào khoảng "Gap" (ví dụ từ 30p trước đến 15p trước giờ hẹn)
                // Lúc này không cho hủy nữa, nhưng chưa cho hoàn thành.
                Expanded(
                  child: Container(
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time_filled, size: 18, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                            "Sắp diễn ra",
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.orange.shade800)
                        ),
                      ],
                    ),
                  ),
                )
              ]
            ] else ...[
              // Trạng thái Cancelled hoặc Completed
              Expanded(
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                  child: Text(
                      status == 'completed' ? "Đã hoàn thành" : "Đã kết thúc",
                      style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w700)
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
  Widget _buildButton(String label, Color bg, Color text, VoidCallback onTap, {bool isOutlined = false}) {
    if (isOutlined) {
      return SizedBox(
        height: 54,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: text.withOpacity(0.5)),
            foregroundColor: text,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      );
    }
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: text,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}