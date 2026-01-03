import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Cần import để format ngày

class BookingSuccessScreen extends StatelessWidget {
  final String? doctorId;
  final bool isReschedule;
  final String? dateStr; // Nhận ngày (YYYY-MM-DD)
  final String? timeStr; // Nhận giờ (HH:mm)

  const BookingSuccessScreen({
    super.key,
    this.doctorId,
    this.isReschedule = false,
    this.dateStr, // Thêm vào constructor
    this.timeStr, // Thêm vào constructor
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BookingSuccessHeader(isReschedule: isReschedule),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Truyền data vào Card
                  _AppointmentInfoCard(dateStr: dateStr, timeStr: timeStr),
                  const Spacer(),

                  ElevatedButton(
                    onPressed: () => context.go('/appointments'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Xem lịch hẹn của tôi'),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 48,
                    child: TextButton(
                      onPressed: () {
                        if (doctorId != null) {
                          context.go('/find-doctor/profile/$doctorId');
                        } else {
                          context.go('/dashboard');
                        }
                      },
                      child: const Text('Quay lại trang bác sĩ'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... _BookingSuccessHeader GIỮ NGUYÊN KHÔNG ĐỔI ...
class _BookingSuccessHeader extends StatelessWidget {
  final bool isReschedule;
  const _BookingSuccessHeader({required this.isReschedule});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.cyan.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(Icons.check_circle_outline, color: Colors.teal, size: 40),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isReschedule ? 'Đổi lịch thành công!' : 'Đặt lịch thành công!',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isReschedule
                ? 'Yêu cầu đổi lịch của bạn đã được gửi đi.'
                : 'Lịch hẹn của bạn đã được ghi nhận.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }
}

// --- SỬA INFO CARD ĐỂ HIỂN THỊ DỮ LIỆU THẬT ---
class _AppointmentInfoCard extends StatelessWidget {
  final String? dateStr;
  final String? timeStr;

  const _AppointmentInfoCard({this.dateStr, this.timeStr});

  @override
  Widget build(BuildContext context) {
    // Logic format ngày tháng đẹp (Ví dụ: 2023-10-30 -> Thứ Hai, 30/10/2023)
    String displayDateTime = 'Chưa có thông tin';
    if (dateStr != null && timeStr != null) {
      try {
        final date = DateTime.parse(dateStr!);
        // Định dạng ngày theo tiếng Việt
        final formattedDate = DateFormat('EEEE, dd/MM/yyyy', 'vi').format(date);
        displayDateTime = '$timeStr - $formattedDate';
      } catch (e) {
        displayDateTime = '$timeStr - $dateStr';
      }
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tạm thời vẫn Hardcode tên bác sĩ vì màn hình này chưa nhận được tên
            // Nếu muốn hiện tên, bạn cần truyền thêm tham số doctorName tương tự như date/time
            const Text('Thông tin lịch hẹn', // Sửa tiêu đề chung chung hơn
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 24),

            // HIỂN THỊ NGÀY GIỜ THẬT
            _buildInfoRow(Icons.calendar_today_outlined, displayDateTime),

            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.location_on_outlined, 'Bệnh viện HealthFlow'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
      ],
    );
  }
}