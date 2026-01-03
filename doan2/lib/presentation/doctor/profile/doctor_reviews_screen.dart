import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_iot/presentation/widgets/custom_avatar.dart';
import 'package:app_iot/service/doctor_service.dart';
import 'package:app_iot/models/doctor/doctor_review_model.dart';
import 'package:app_iot/service/user_service.dart';
import 'package:app_iot/core/api/api_client.dart';

class DoctorReviewsScreen extends StatefulWidget {
  const DoctorReviewsScreen({super.key});

  @override
  State<DoctorReviewsScreen> createState() => _DoctorReviewsScreenState();
}

class _DoctorReviewsScreenState extends State<DoctorReviewsScreen> {
  final DoctorService _doctorService = DoctorService();
  late Future<List<DoctorReview>> _reviewsFuture;
  final UserService _userService = UserService(ApiClient());

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _fetchReviews();
  }

  Future<List<DoctorReview>> _fetchReviews() async {
    // B1: Lấy User Profile để biết ID
    final user = await _userService.getUserProfile();
    if (user != null) {
      // B2: Dùng ID để lấy Reviews
      return await _doctorService.getDoctorReviews(user.id.toString());
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Đánh giá & Nhận xét',
          style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DoctorReview>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi tải dữ liệu", style: GoogleFonts.inter()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("Chưa có đánh giá nào", style: GoogleFonts.inter(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final reviews = snapshot.data!;
          double averageRating = reviews.map((e) => e.rating).reduce((a, b) => a + b) / reviews.length;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildOverallRatingCard(averageRating, reviews),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _ReviewCard(review: reviews[index]),
                    childCount: reviews.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverallRatingCard(double averageRating, List<DoctorReview> reviews) {
    // Tính toán số lượng từng sao
    Map<int, int> starCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var r in reviews) {
      if (starCounts.containsKey(r.rating)) {
        starCounts[r.rating] = starCounts[r.rating]! + 1;
      }
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => Icon(
                    index < averageRating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber, size: 20,
                  )),
                ),
                const SizedBox(height: 8),
                Text(
                  '${reviews.length} đánh giá',
                  style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 100, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 20)),
          Expanded(
            flex: 6,
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                int count = starCounts[star] ?? 0;
                double percentage = reviews.isEmpty ? 0 : count / reviews.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                      const SizedBox(width: 4),
                      Icon(Icons.star_rounded, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
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
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomAvatar(
                imageUrl: review.avatarUrl,
                radius: 20,
                fallbackText: review.patientName,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.patientName,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                    ),
                    Text(
                      review.dateDisplay,
                      style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toString(),
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.amber.shade800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: GoogleFonts.inter(color: Colors.grey.shade700, height: 1.5, fontSize: 14),
          ),
        ],
      ),
    );
  }
}