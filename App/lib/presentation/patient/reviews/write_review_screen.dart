import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_iot/presentation/widgets/custom_avatar.dart';
// Import Service và Model có sẵn của bạn
import '../../../service/doctor_service.dart';
import '../../../models/common/appointment_model.dart';

class WriteReviewScreen extends StatefulWidget {
  // THAY ĐỔI: Nhận cả object Appointment
  final Appointment appointment;

  const WriteReviewScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final DoctorService _doctorService = DoctorService();
  final TextEditingController _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;
  String _ratingLabel = "Tuyệt vời";

  void _updateRatingLabel(double rating) {
    setState(() {
      _rating = rating;
      if (rating <= 1) {
        _ratingLabel = "Rất tệ";
      } else if (rating <= 2) _ratingLabel = "Tệ";
      else if (rating <= 3) _ratingLabel = "Bình thường";
      else if (rating <= 4) _ratingLabel = "Tốt";
      else _ratingLabel = "Tuyệt vời";
    });
  }

  Future<void> _submit() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng viết vài dòng chia sẻ trải nghiệm của bạn")),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 800));

    // THAY ĐỔI: Lấy ID từ widget.appointment
    final success = await _doctorService.submitReview(
      doctorId: widget.appointment.doctorId,
      appointmentId: widget.appointment.id,
      rating: _rating.toInt(),
      comment: _commentController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cảm ơn đánh giá của bạn!"),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop(true); // Trả về true để màn hình trước reload lại data
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi: Có thể bạn đã đánh giá rồi")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rút gọn code bằng cách gán vào biến local
    final appt = widget.appointment;

    // Sử dụng helper có sẵn trong Model của bạn để hiển thị ngày tháng
    // appt.fullDateTimeStr là getter bạn đã viết trong model
    final timeStr = appt.fullDateTimeStr;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Viết đánh giá", style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Header thông tin Bác sĩ & Lịch hẹn ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CustomAvatar(
                      imageUrl: appt.avatarUrl,
                      radius: 30,
                      fallbackText: appt.doctorName,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Đánh giá trải nghiệm với", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            appt.doctorName, // Tên bác sĩ từ Model
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Hiển thị ngày khám cho rõ ràng
                          Text(
                            "Khám lúc: $timeStr",
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.teal.shade600, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- Phần Rating ---
              Text("Bạn cảm thấy thế nào?", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 48,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Colors.amber),
                onRatingUpdate: _updateRatingLabel,
                glowColor: Colors.amber.withOpacity(0.4),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _ratingLabel,
                  key: ValueKey<String>(_ratingLabel),
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.amber.shade800),
                ),
              ),

              const SizedBox(height: 32),

              // --- Phần Comment ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Chia sẻ thêm chi tiết (Tùy chọn)", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 5,
                maxLength: 500,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  hintText: "Bác sĩ tư vấn có nhiệt tình không? Cơ sở vật chất thế nào?...",
                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.teal, width: 1.5)),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 32),

              // --- Nút Gửi ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.teal.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text("Gửi đánh giá", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0),
            ],
          ),
        ),
      ),
    );
  }
}