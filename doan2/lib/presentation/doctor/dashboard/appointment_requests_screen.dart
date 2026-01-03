import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_iot/presentation/widgets/custom_avatar.dart';
import 'package:app_iot/service/doctor_service.dart';
import 'package:app_iot/models/common/appointment_model.dart';

class AppointmentRequestsScreen extends StatefulWidget {
  const AppointmentRequestsScreen({super.key});

  @override
  State<AppointmentRequestsScreen> createState() => _AppointmentRequestsScreenState();
}

class _AppointmentRequestsScreenState extends State<AppointmentRequestsScreen> {
  final DoctorService _doctorService = DoctorService();
  List<Appointment> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }
  void _showRejectDialog(String appointmentId) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Từ chối lịch hẹn"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Vui lòng nhập lý do từ chối:"),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: "Lý do (Bận, sai chuyên khoa...)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Gọi hàm respond với status cancelled và lý do
              _respond(appointmentId, 'cancelled', reason: reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Từ chối"),
          ),
        ],
      ),
    );
  }
  Future<void> _fetchRequests() async {
    final data = await _doctorService.getAppointmentsByStatus('pending');
    if (mounted) {
      setState(() {
        _requests = data;
        _isLoading = false;
      });
    }
  }

  // Hàm xử lý phản hồi (Accept/Reject) - SỬA LẠI
  Future<void> _respond(String id, String status, {String? reason}) async { // <--- Thêm {reason}
    // Optimistic Update
    final index = _requests.indexWhere((r) => r.id == id);
    final removedItem = index != -1 ? _requests[index] : null;

    setState(() {
      _requests.removeWhere((r) => r.id == id);
    });

    // Gọi Service kèm theo reason
    final success = await _doctorService.respondToAppointment(id, status, reason: reason);

    if (!success && removedItem != null && mounted) {
      // Revert nếu lỗi
      setState(() {
        if (index < _requests.length) {
          _requests.insert(index, removedItem);
        } else {
          _requests.add(removedItem);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi kết nối, vui lòng thử lại")));
    } else if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'confirmed' ? 'Đã chấp nhận lịch hẹn' : 'Đã từ chối lịch hẹn'),
          backgroundColor: status == 'confirmed' ? Colors.green : Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text('Yêu cầu Lịch hẹn mới', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? Center(child: Text("Không có yêu cầu mới", style: GoogleFonts.inter(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final req = _requests[index];
          return _RequestCard(
            appointment: req,
            onAccept: () => _respond(req.id, 'confirmed'),
            // SỬA: Thay vì gọi _respond ngay, hãy gọi Dialog
            onReject: () => _showRejectDialog(req.id),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestCard({
    required this.appointment,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    // Dùng thông tin BỆNH NHÂN từ Model Appointment
    final name = appointment.patientName;
    final avatar = appointment.patientAvatar;
    final time = appointment.fullDateTimeStr;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CustomAvatar(
                  imageUrl: avatar,
                  radius: 24,
                  fallbackText: name,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(time, style: GoogleFonts.inter(color: Colors.teal.shade700, fontWeight: FontWeight.w500)),
                      if (appointment.notes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "Ghi chú: ${appointment.notes}",
                            style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12, fontStyle: FontStyle.italic),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade100),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Chấp nhận'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}