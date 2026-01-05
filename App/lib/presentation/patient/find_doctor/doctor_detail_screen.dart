import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_iot/service/doctor_service.dart';
import 'package:health_iot/models/doctor/doctor_model.dart';
import 'package:health_iot/service/chat_service.dart';
import '../../widgets/professional_avatar.dart';
import '../../widgets/professional_avatar.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;
  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  final DoctorService _doctorService = DoctorService();
  final ChatService _chatService = ChatService();
  late Future<Doctor?> _doctorDetailFuture;

  @override
  void initState() {
    super.initState();
    _doctorDetailFuture = _doctorService.getDoctorDetail(widget.doctorId);
  }

  // --- HÀM XỬ LÝ TẠO CHAT VỚI DATABASE ---
  Future<void> _navigateToChat(BuildContext context, Doctor doctor) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
      const Center(child: CircularProgressIndicator(color: Colors.teal)),
    );

    try {
      final conversationId = await _chatService.startChat(doctor.id);

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (conversationId != null) {
        final String name = doctor.fullName;
        final String avatarRaw = doctor.avatarUrl.isNotEmpty
            ? doctor.avatarUrl
            : 'https://res.cloudinary.com/dckvzpy22/image/upload/v1/avatars/default_avatar.png';

        final String encodedName = Uri.encodeComponent(name);
        final String encodedAvatar = Uri.encodeComponent(avatarRaw);

        if (mounted) {
          context.push(
              '/chat/details/$conversationId?name=$encodedName&partnerId=${doctor.id}&avatar=$encodedAvatar');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không thể khởi tạo cuộc trò chuyện")),
          );
        }
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }

  // [FIX] Hàm xây dựng SliverAppBar chuẩn
  Widget _buildSliverAppBar(BuildContext context, Doctor doctor) {
    return SliverAppBar(
      pinned: true, // Ghim header để giữ nút Back
      expandedHeight: 280.0,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: Colors.grey.shade100,

      // 1. Nút Back chuẩn (Luôn hiển thị đúng vị trí)
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => context.pop(),
      ),

      // 2. Tiêu đề khi cuộn lên (Tên bác sĩ nhỏ lại)
      centerTitle: true,
      title: Text(
        doctor.fullName,
        style: GoogleFonts.inter(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      // Ẩn tiêu đề khi đang mở rộng (để không đè lên Avatar)
      titleTextStyle: GoogleFonts.inter(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),

      // 3. Nội dung nền (Avatar to + Tên to)
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax, // Hiệu ứng cuộn mượt
        background: Container(
          color: Colors.white,
          // Padding top để nội dung nằm dưới Toolbar
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar có viền đẹp với Hero animation
              Hero(
                tag: 'doctor-avatar-${doctor.id}',
                child: ProfessionalAvatar(
                  imageUrl: doctor.avatarUrl,
                  size: 120,
                  isCircle: true,
                  showBadge: true,
                  badgeIcon: Icons.verified_rounded,
                  badgeColor: Colors.teal,
                  borderWidth: 4,
                  gradientColors: [
                    Colors.teal.shade300,
                    Colors.teal.shade600,
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tên Bác sĩ (To)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  doctor.fullName,
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),

              // Chuyên khoa
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Text(
                  doctor.specialty,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.teal.shade700, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10), // Khoảng cách bottom
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: FutureBuilder<Doctor?>(
        future: _doctorDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.teal));
          } else if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorScreen();
          }

          final doctor = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // [FIX] Chỉ dùng 1 SliverAppBar duy nhất
                    _buildSliverAppBar(context, doctor),

                    // Phần nội dung chi tiết bên dưới
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQuickStats(doctor),
                            const SizedBox(height: 24),
                            _buildSectionTitle("Giới thiệu"),
                            const SizedBox(height: 8),
                            Text(
                              doctor.bioDisplay.isNotEmpty
                                  ? doctor.bioDisplay
                                  : "Bác sĩ chưa cập nhật thông tin giới thiệu.",
                              style: GoogleFonts.inter(
                                  color: Colors.grey.shade700,
                                  height: 1.6,
                                  fontSize: 14),
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle("Thông tin làm việc"),
                            const SizedBox(height: 12),
                            _buildInfoContainer([
                              _buildInfoRow(Icons.local_hospital_rounded,
                                  "Nơi công tác", doctor.hospitalName),
                              _buildDivider(),
                              _buildInfoRow(Icons.medical_services_rounded,
                                  "Chuyên khoa", doctor.specialty),
                              _buildDivider(),
                              _buildInfoRow(Icons.attach_money_rounded,
                                  "Phí tư vấn", doctor.feeDisplay),
                            ]),
                            const SizedBox(height: 24),
                            _buildReviewsPreview(context, doctor),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<Doctor?>(
        future: _doctorDetailFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          return _buildBottomActions(context, snapshot.data!);
        },
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text("Không tìm thấy thông tin bác sĩ"),
          ],
        ),
      ),
    );
  }

  // --- WIDGET CON (Giữ nguyên) ---
  Widget _buildQuickStats(Doctor doctor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Bệnh nhân", "100+", Colors.blue),
          _buildVerticalLine(),
          _buildStatItem(
              "Kinh nghiệm", "${doctor.yearsOfExperience} năm", Colors.teal),
          _buildVerticalLine(),
          _buildStatItem("Đánh giá", doctor.ratingDisplay, Colors.amber),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildVerticalLine() =>
      Container(height: 30, width: 1, color: Colors.grey.shade200);

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildInfoContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100)),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: Colors.teal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(value.isNotEmpty ? value : "Chưa cập nhật",
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDivider() => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Colors.grey.shade100));

  Widget _buildReviewsPreview(BuildContext context, Doctor doctor) {
    return InkWell(
      onTap: () =>
          context.push('/find-doctor/profile/${widget.doctorId}/reviews'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.shade50.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade100),
        ),
        child: Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Đánh giá & Nhận xét",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text("Xem ${doctor.reviewCount} đánh giá từ bệnh nhân",
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, Doctor doctor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _navigateToChat(context, doctor),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                child: Icon(Icons.chat_bubble_outline_rounded,
                    color: Colors.blue.shade700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () => context
                    .push('/find-doctor/profile/${widget.doctorId}/book'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text('Đặt lịch hẹn ngay',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}