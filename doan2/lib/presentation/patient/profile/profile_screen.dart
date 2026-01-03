import 'dart:io'; // Thêm thư viện xử lý File
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Thêm thư viện chọn ảnh
import 'package:app_iot/core/api/api_client.dart';
import 'package:app_iot/service/user_service.dart';
import 'package:app_iot/models/common/user_model.dart'; // Import User Model
import 'package:app_iot/service/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService(ApiClient());
  final ImagePicker _picker = ImagePicker(); // Khởi tạo trình chọn ảnh

  User? _user;
  bool _isLoading = true;
  bool _isUploading = false; // Biến trạng thái khi đang upload

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = await _userService.getUserProfile(); // Trả về User
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HÀM 1: Hiển thị Popup chọn nguồn ảnh ---
  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        height: 150,
        child: Column(
          children: [
            const Text("Đổi ảnh đại diện", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconBtn(Icons.camera_alt, "Chụp ảnh", ImageSource.camera),
                _buildIconBtn(Icons.photo_library, "Thư viện", ImageSource.gallery),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, String label, ImageSource source) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _pickAndUploadImage(source);
      },
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.teal),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  // --- HÀM 2: Xử lý chọn và upload ảnh ---
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 600,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      File imageFile = File(pickedFile.path);

      // Gọi API Upload
      String newAvatarUrl = await _userService.uploadAvatar(imageFile);

      if (mounted) {
        setState(() {
          // Cập nhật lại Object User (Tạo bản sao mới hoặc reload lại từ server)
          // Cách nhanh nhất là fetch lại profile, hoặc update field local nếu User có copyWith
          _fetchProfile();
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật ảnh thành công!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi upload: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String fullName = _user?.fullName ?? 'Người dùng';
    final String email = _user?.email ?? 'Đang tải...';
    // Sử dụng Getter từ Model để lấy URL chuẩn
    final String avatarUrl = _user?.fullAvatarUrl ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hồ sơ cá nhân',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Info Card
            Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // --- PHẦN AVATAR ĐƯỢC CẬP NHẬT ---
                    GestureDetector(
                      onTap: _showImageSourcePicker, // Bấm vào để đổi ảnh
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.teal.shade100, width: 2),
                            ),
                            child: _isUploading
                                ? const CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey,
                              child: SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              ),
                            )
                                : CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.teal.shade100,
                              backgroundImage: (avatarUrl.isNotEmpty)
                                  ? NetworkImage(avatarUrl)
                                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                              onBackgroundImageError: (avatarUrl.isNotEmpty) ? (_, __) {} : null,
                            ),
                          ),
                          // Icon camera nhỏ
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Icon(Icons.camera_alt, size: 14, color: Colors.teal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ----------------------------------

                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _isLoading
                              ? Container(height: 20, width: 150, color: Colors.grey.shade200)
                              : Text(
                            fullName,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _isLoading
                              ? Container(height: 14, width: 100, color: Colors.grey.shade200)
                              : Text(
                            email,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Profile Options
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  _buildProfileOption(
                    context,
                    theme: theme,
                    icon: Icons.person_outline,
                    title: 'Thông tin cá nhân',
                    onTap: () {
                      context.push('/profile/personal-info');
                    },
                  ),
                  _buildProfileOption(
                    context,
                    theme: theme,
                    icon: Icons.monitor_heart_outlined,
                    title: 'Hồ sơ sức khỏe',
                    onTap: () {
                      context.push('/profile/health-record');
                    },
                  ),
                  _buildProfileOption(
                    context,
                    theme: theme,
                    icon: Icons.star_outline,
                    title: 'Đánh giá của tôi',
                    onTap: () {
                      context.push('/profile/my-reviews');
                    },
                  ),
                  _buildProfileOption(
                    context,
                    theme: theme,
                    icon: Icons.settings_outlined,
                    title: 'Cài đặt',
                    onTap: () {
                      context.push('/profile/settings');
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildProfileOption(
                    context,
                    theme: theme,
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    color: Colors.red[600],
                    onTap: () async {
                      final authService = AuthService(ApiClient());
                      await authService.logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
      BuildContext context, {
        required ThemeData theme,
        required IconData icon,
        required String title,
        Color? color,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: color ?? theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color ?? theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: color ?? Colors.grey[400],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}