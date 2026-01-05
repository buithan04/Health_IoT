import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_iot/presentation/widgets/custom_avatar.dart';
// import 'package:intl/intl.dart'; // Không cần nếu không dùng trực tiếp
import 'package:health_iot/service/doctor_service.dart';
import 'package:health_iot/models/doctor/doctor_model.dart';
import 'package:health_iot/models/doctor/doctor_review_model.dart'; // <--- BẮT BUỘC IMPORT MODEL NÀY
import '../../widgets/professional_avatar.dart';

// ---------------------------------------------------------------------------
// LƯU Ý: ĐÃ XÓA CLASS DoctorReview TẠI ĐÂY ĐỂ TRÁNH XUNG ĐỘT
// ---------------------------------------------------------------------------

class DoctorReviewsListScreen extends StatefulWidget {
  final String doctorId;
  const DoctorReviewsListScreen({super.key, required this.doctorId});

  @override
  State<DoctorReviewsListScreen> createState() => _DoctorReviewsListScreenState();
}

class _DoctorReviewsListScreenState extends State<DoctorReviewsListScreen> {
  final DoctorService _doctorService = DoctorService();
  bool _isLoading = true;

  // Biến này sẽ dùng DoctorReview từ file import 'doctor_review_model.dart'
  List<DoctorReview> _reviews = [];
  Doctor? _doctor;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _doctorService.getDoctorDetail(widget.doctorId),
        _doctorService.getDoctorReviews(widget.doctorId),
      ]);

      if (mounted) {
        setState(() {
          _doctor = results[0] as Doctor?;
          // Ép kiểu dữ liệu an toàn
          // Vì class DoctorReview chỉ có 1 nguồn duy nhất (từ import), nên cast sẽ thành công
          _reviews = (results[1] as List<dynamic>).cast<DoctorReview>();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi tải dữ liệu: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),

          // Phần Header thống kê (Overview)
          if (_doctor != null)
            SliverToBoxAdapter(child: _buildDoctorOverviewCard(_doctor!)),

          // Tiêu đề danh sách
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                "Nhận xét từ bệnh nhân (${_reviews.length})",
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800]
                ),
              ),
            ),
          ),

          // Danh sách review
          _reviews.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _ReviewCard(review: _reviews[index]),
                childCount: _reviews.length,
              ),
            ),
          ),

          // Khoảng trắng dưới cùng
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Đánh giá bác sĩ',
        style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18
        ),
      ),
    );
  }

  Widget _buildDoctorOverviewCard(Doctor doctor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar với ProfessionalAvatar
          ProfessionalAvatar(
            imageUrl: doctor.avatarUrl,
            size: 80,
            isCircle: true,
            showBadge: false,
            borderWidth: 3,
            gradientColors: [
              Colors.white.withOpacity(0.8),
              Colors.white,
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.fullName,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  doctor.specialty,
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amberAccent, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        "${doctor.ratingAverage}",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white
                        ),
                      ),
                      Text(
                        " / 5.0",
                        style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.reviews_outlined, size: 60, color: Colors.teal.shade300),
          ),
          const SizedBox(height: 24),
          Text(
            "Chưa có đánh giá nào",
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800]
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Hãy là người đầu tiên đánh giá bác sĩ này!",
            style: GoogleFonts.inter(color: Colors.blueGrey[400]),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final DoctorReview review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAvatar(
                imageUrl: review.avatarUrl,
                radius: 22,
                fallbackText: review.patientName,
                backgroundColor: Colors.grey.shade100,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.patientName,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.blueGrey[800]
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star_rounded,
                          color: index < review.rating ? Colors.amber : Colors.grey.shade200,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                review.dateDisplay,
                style: GoogleFonts.inter(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 12),

          Text(
            review.comment,
            style: GoogleFonts.inter(
                color: Colors.blueGrey[700],
                height: 1.5,
                fontSize: 14
            ),
          ),
        ],
      ),
    );
  }
}