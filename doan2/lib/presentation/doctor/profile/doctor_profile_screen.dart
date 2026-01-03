import 'dart:io'; // [MỚI] Import File

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // [MỚI] Import ImagePicker
import 'package:app_iot/service/doctor_service.dart';
import 'package:app_iot/models/doctor/doctor_model.dart';
import 'package:app_iot/models/common/user_model.dart';
import 'package:app_iot/service/auth_service.dart';
import 'package:app_iot/service/user_service.dart';
import 'package:app_iot/core/api/api_client.dart';
import 'package:app_iot/core/constants/app_config.dart';


class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final DoctorService _doctorService = DoctorService();
  final UserService _userService = UserService(ApiClient());

  // [MỚI] Các biến xử lý ảnh
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingAvatar = false;

  Doctor? _doctor;
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = await _userService.getUserProfile();

    if (user != null) {
      final doctor = await _doctorService.getDoctorDetail(user.id.toString());
      if (mounted) {
        setState(() {
          _user = user;
          _doctor = doctor;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- [LOGIC MỚI] XỬ LÝ ẢNH ---

  // 1. Hiển thị Bottom Sheet chọn ảnh
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text("Đổi ảnh đại diện", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildOptionItem(Icons.photo_library_rounded, Colors.blue, "Chọn từ thư viện", () => _pickImage(ImageSource.gallery)),
            const SizedBox(height: 12),
            _buildOptionItem(Icons.camera_alt_rounded, Colors.teal, "Chụp ảnh mới", () => _pickImage(ImageSource.camera)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, Color color, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(text, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 2. Chọn ảnh và Upload
  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Đóng modal
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        _uploadAvatar(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
    }
  }

  // 3. Gọi API Upload
  Future<void> _uploadAvatar(File imageFile) async {
    setState(() => _isUploadingAvatar = true);
    final newUrl = await _userService.uploadAvatar(imageFile); // Hàm này có sẵn trong UserService

    if (mounted) {
      setState(() {
        _isUploadingAvatar = false;
        // Cập nhật URL mới vào Model để hiển thị ngay lập tức
        // Chúng ta update cả User và Doctor object (nếu có) để UI đồng bộ
        _fetchProfile(); // Reload lại toàn bộ cho chắc chắn
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi ảnh thành công!'), backgroundColor: Colors.teal),
        );
            });
    }
  }

  // --- UI CHÍNH ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Hồ sơ Bác sĩ',
          style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(), // Avatar có thể click
            const SizedBox(height: 24),
            _buildProfileMenu(context),
            const SizedBox(height: 24),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    if (_doctor == null && _user == null) return const SizedBox();

    final displayEmail = _user?.email ?? _doctor?.email ?? 'Email không tồn tại';
    // Logic hiển thị Avatar:
    final rawUrl = _doctor?.avatarUrl ?? _user?.avatarUrl;
    final avatarUrl = AppConfig.formatUrl(rawUrl);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // [MỚI] Avatar bọc trong GestureDetector để click
          GestureDetector(
            onTap: _isUploadingAvatar ? null : _showImagePickerOptions,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.teal.withOpacity(0.3), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.teal.shade100,
                    backgroundImage: (avatarUrl.isNotEmpty)
                        ? NetworkImage(avatarUrl)
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                    onBackgroundImageError: (avatarUrl.isNotEmpty) ? (_, __) {} : null,
                    // Nếu đang upload thì làm mờ ảnh cũ
                    child: _isUploadingAvatar
                        ? Container(
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(35),
                      ),
                    )
                        : null,
                  ),
                ),

                // Hiển thị Loading khi đang upload
                if (_isUploadingAvatar)
                  const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),

                // Hiển thị Icon Camera nhỏ (nếu không upload)
                if (!_isUploadingAvatar)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                    ),
                  )
              ],
            ),
          ),

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BS. ${_doctor?.fullName ?? _user?.fullName ?? "Bác sĩ"}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  displayEmail,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CÁC WIDGET MENU (Giữ nguyên) ---
  Widget _buildProfileMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            onTap: () => context.push('/doctor/profile/personal-info'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _ProfileMenuItem(
            icon: Icons.badge_outlined,
            title: 'Thông tin chuyên môn',
            onTap: () => context.push('/doctor/profile/professional-info'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _ProfileMenuItem(
            icon: Icons.star_outline,
            title: 'Xem đánh giá',
            onTap: () => context.push('/doctor/profile/reviews'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Cài đặt tài khoản',
            onTap: () => context.push('/doctor/profile/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        final authService = AuthService(ApiClient());
        await authService.logout();
        context.go('/login');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(Icons.logout, color: Colors.red.shade500),
            const SizedBox(width: 12),
            Text(
              'Đăng xuất',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.red.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}