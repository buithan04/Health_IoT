// lib/presentation/doctor/patients/doctor_patient_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_iot/presentation/widgets/custom_avatar.dart';
import '../../../core/constants/app_config.dart';
import 'package:app_iot/service/chat_service.dart';

class DoctorPatientDetailScreen extends StatefulWidget { // [SỬA] Đổi thành StatefulWidget
  final Map<String, dynamic> patientData;
  const DoctorPatientDetailScreen({super.key, required this.patientData});

  @override
  State<DoctorPatientDetailScreen> createState() => _DoctorPatientDetailScreenState();
}

class _DoctorPatientDetailScreenState extends State<DoctorPatientDetailScreen> {
  final ChatService _chatService = ChatService(); // [MỚI] Khởi tạo Service
  bool _isNavigating = false; // [MỚI] Biến trạng thái loading

  @override
  Widget build(BuildContext context) {
    // Sửa widget.patientData vì đã chuyển sang State
    final patientId = widget.patientData['patient_id'].toString();
    final name = widget.patientData['patient_name'] ?? 'Bệnh nhân';
    String avatarUrl = AppConfig.formatUrl(widget.patientData['avatar_url']);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Hồ sơ bệnh nhân', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- HEADER INFO ---
            Center(
              child: Column(
                children: [
                  Hero(
                    tag: 'avatar_$patientId',
                    child: CustomAvatar(
                      imageUrl: avatarUrl,
                      radius: 50,
                      fallbackText: name,
                      backgroundColor: Colors.teal.shade100,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "ID: #$patientId",
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- GRID ACTIONS ---
            // Sử dụng GridView hoặc Column các Row để hiển thị nút

            // HÀNG 1: Dữ liệu sức khỏe & Hồ sơ chi tiết
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.monitor_heart_outlined,
                    color: Colors.redAccent,
                    title: "Chỉ số sức khỏe",
                    subtitle: "SpO2, Nhịp tim...",
                    onTap: () {
                      context.push('/doctor/patient-stats/$patientId');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.assignment_ind_outlined,
                    color: Colors.blueAccent,
                    title: "Hồ sơ bệnh án",
                    subtitle: "Tiền sử, Dị ứng...",
                    onTap: () {
                      context.push('/doctor/patient-record/$patientId');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // HÀNG 2: Nhắn tin & Kê đơn [ĐÃ SỬA]
            Row(
              children: [
                // 1. Nút Nhắn tin (Giữ logic cũ)
                Expanded(
                  child: _ActionCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    color: Colors.green,
                    title: "Nhắn tin",
                    subtitle: _isNavigating ? "Đang mở..." : "Trò chuyện",
                    onTap: () async {
                      if (_isNavigating) return;
                      setState(() => _isNavigating = true);
                      final conversationId = await _chatService.startChat(patientId);
                      setState(() => _isNavigating = false);

                      if (conversationId != null) {
                        final encodedName = Uri.encodeComponent(name);
                        final encodedAvatar = Uri.encodeComponent(avatarUrl);
                        context.push(
                            '/doctor/chat/details/$conversationId?name=$encodedName&partnerId=$patientId&avatar=$encodedAvatar'
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lỗi kết nối server chat")),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(width: 16), // Khoảng cách giữa 2 nút

                // 2. Nút Kê đơn thuốc [THÊM MỚI]
                Expanded(
                  child: _ActionCard(
                    icon: Icons.medication_liquid_rounded, // Icon thuốc
                    color: Colors.teal, // Màu xanh Teal đặc trưng y tế
                    title: "Kê đơn thuốc",
                    subtitle: "Tạo đơn mới",
                    onTap: () {
                      // [QUAN TRỌNG] Gọi đúng route đã sửa ở bước trước
                      // Truyền thẳng patientId (ví dụ: "9") vào URL
                      context.push('/doctor/consultation/$patientId');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // HÀNG 3: Lịch sử khám (Ví dụ thêm)
            _FullWidthActionCard(
              icon: Icons.history_edu,
              color: Colors.purple,
              title: "Lịch sử khám bệnh",
              onTap: (){},
            )
          ],
        ),
      ),
    );
  }
}

// Widget con: Card chức năng nhỏ (hình vuông)
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Widget con: Card chức năng dài (Full width)
class _FullWidthActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _FullWidthActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ));
  }
}