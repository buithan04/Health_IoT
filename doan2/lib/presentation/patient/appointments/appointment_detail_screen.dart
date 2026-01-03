import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_iot/presentation/widgets/custom_avatar.dart';
import 'package:intl/intl.dart';
import 'package:app_iot/service/appointment_service.dart';
import 'package:app_iot/models/common/appointment_model.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  late Future<Appointment?> _appointmentFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _appointmentFuture = _appointmentService.getAppointmentDetail(widget.appointmentId);
    });
  }

  String _formatCurrency(num price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text('Chi tiết lịch hẹn',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
      ),
      body: FutureBuilder<Appointment?>(
        future: _appointmentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Không tìm thấy lịch hẹn hoặc lỗi kết nối"));
          }

          final appt = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. QR Code
                      _buildQrCodeCard(appt.id),
                      const SizedBox(height: 16),

                      // 2. Cảnh báo nếu đã hủy (Model đã có cancellationReason)
                      if (appt.status == 'cancelled')
                        _buildCancellationCard(appt.cancellationReason),

                      if (appt.status == 'cancelled') const SizedBox(height: 16),

                      // 3. Thông tin Bác sĩ
                      _buildDoctorCard(context, appt),
                      const SizedBox(height: 16),

                      // 4. Thông tin Dịch vụ & Chi phí (Model đã có serviceName, price...)
                      _buildServiceInfoCard(appt),
                      const SizedBox(height: 16),

                      // 5. Ghi chú
                      if (appt.notes.isNotEmpty) _buildNotesCard(appt.notes),
                    ],
                  ),
                ),
              ),

              // Nút hành động
              _buildActionButtons(context, appt),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGETS CON ---

  Widget _buildCancellationCard(String? reason) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text("Lịch hẹn đã bị hủy",
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.red.shade700)),
            ],
          ),
          if (reason != null && reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text("Lý do: $reason", style: GoogleFonts.inter(color: Colors.red.shade900)),
          ]
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Appointment appt) {
    // Ưu tiên hiển thị địa chỉ phòng khám nếu có (Model đã có clinicAddress)
    final displayAddress = (appt.clinicAddress != null && appt.clinicAddress!.isNotEmpty)
        ? appt.clinicAddress!
        : appt.hospitalName;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: InkWell(
              onTap: () => context.push('/find-doctor/profile/${appt.doctorId}'),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CustomAvatar(
                      imageUrl: appt.avatarUrl,
                      radius: 28,
                      fallbackText: appt.doctorName,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appt.doctorName,
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17)),
                          Text(appt.specialty,
                              style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(Icons.calendar_today_outlined, "Thời gian", appt.fullDateTimeStr),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.location_on_outlined, "Địa điểm", displayAddress),
                const SizedBox(height: 12),
                _buildStatusRow(appt.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfoCard(Appointment appt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Thông tin dịch vụ",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Loại khám", style: GoogleFonts.inter(color: Colors.grey.shade600)),
              // Model đã có serviceName
              Text(appt.serviceName ?? "Khám thường",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Thời lượng", style: GoogleFonts.inter(color: Colors.grey.shade600)),
              // Model đã có duration
              Text("${appt.duration ?? 30} phút",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
          // SỬA LỖI DIVIDER TẠI ĐÂY (Xóa style: BorderStyle.solid)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tổng phí", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
              // Model đã có price
              Text(_formatCurrency(appt.price ?? 0),
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
            ],
          ),
        ],
      ),
    );
  }

  // ... Các widget còn lại giữ nguyên ...
  Widget _buildQrCodeCard(String id) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Image.network(
            'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$id',
            width: 120, height: 120,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.qr_code_2, size: 100, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text('Mã hẹn: #$id', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ghi chú của bạn', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(notes, style: GoogleFonts.inter(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: GoogleFonts.inter(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)),
              Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String status) {
    Color color;
    String text;
    switch (status) {
      case 'confirmed': color = Colors.green; text = 'Đã duyệt'; break;
      case 'pending': color = Colors.orange; text = 'Chờ duyệt'; break;
      case 'cancelled': color = Colors.red; text = 'Đã hủy'; break;
      default: color = Colors.blue; text = 'Hoàn thành';
    }
    return Row(
      children: [
        Icon(Icons.info_outline, color: color, size: 20),
        const SizedBox(width: 12),
        Text(text, style: GoogleFonts.inter(fontSize: 15, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Appointment appt) {
    if (appt.status == 'completed') {
      return appt.isReviewed ? _buildReviewedState() : _buildReviewButton(context, appt);
    }
    if (appt.status == 'cancelled') return const SizedBox.shrink();

    // --- LOGIC KIỂM TRA THỜI GIAN ---
    final DateTime startTime = appt.date;
    final DateTime now = DateTime.now();

    // Chỉ cho phép hủy trước 1 tiếng
    final bool canCancel = now.isBefore(startTime.subtract(const Duration(hours: 1)));

    // Nếu đã quá hạn hủy (đối với trạng thái confirmed hoặc pending)
    if (!canCancel) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12)
            ),
            alignment: Alignment.center,
            child: Text(
              "Đã quá thời gian hủy lịch (trước 1h)",
              style: GoogleFonts.inter(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    // Nếu thỏa mãn điều kiện, hiển thị nút bấm bình thường
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showCancelDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Hủy lịch'),
              ),
            ),
            if (appt.status == 'pending') ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/find-doctor/profile/${appt.doctorId}/book?source=reschedule&appointmentId=${appt.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Dời lịch'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildReviewedState() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text("Đã đánh giá", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewButton(BuildContext context, Appointment appt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await context.push('/write-review', extra: appt);
              if (result == true) _loadData();
            },
            icon: const Icon(Icons.star_rate_rounded, color: Colors.white),
            label: const Text('Viết đánh giá'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    // 1. Tạo controller để lấy nội dung nhập
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn có chắc chắn muốn hủy lịch hẹn này?'),
            const SizedBox(height: 16),

            // 2. Thêm TextField để nhập lý do
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Lý do hủy (Không bắt buộc)',
                hintText: 'Nhập lý do...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Đóng dialog trước

              // 3. Gọi service kèm theo lý do
              final success = await _appointmentService.cancelAppointment(
                widget.appointmentId,
                reason: reasonController.text.trim().isEmpty
                    ? "Bệnh nhân hủy (không nhập lý do)"
                    : reasonController.text.trim(),
              );

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy thành công')));
                context.go('/appointments'); // Hoặc reload lại trang
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi hủy lịch')));
              }
            },
            child: const Text('Hủy ngay', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}