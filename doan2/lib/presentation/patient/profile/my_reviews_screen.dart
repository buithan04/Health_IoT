import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:app_iot/core/api/api_client.dart';
import 'package:app_iot/service/user_service.dart';
import 'package:app_iot/models/common/review_model.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final UserService _userService = UserService(ApiClient());
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _userService.getMyReviews();
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
        title: Text(
          'Đánh giá của tôi',
          style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Review>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          final reviews = snapshot.data ?? [];

          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Bạn chưa có đánh giá nào', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index]; // Đây là Object Review

              // KHÔNG CẦN map dữ liệu thủ công nữa, dùng thẳng properties:
              final dateStr = review.createdAt != null
                  ? DateFormat('dd/MM/yyyy').format(review.createdAt!)
                  : '';

              return Card(
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.05),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            // Dùng getter fullDoctorAvatarUrl từ Model
                            backgroundImage: review.fullDoctorAvatarUrl.isNotEmpty
                                ? NetworkImage(review.fullDoctorAvatarUrl)
                                : const NetworkImage('https://via.placeholder.com/150'),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.doctorName,
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                review.specialty,
                                style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          // So sánh trực tiếp với review.rating
                            i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber, size: 20
                        )),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.comment,
                        style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("Đã đánh giá vào $dateStr", style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}