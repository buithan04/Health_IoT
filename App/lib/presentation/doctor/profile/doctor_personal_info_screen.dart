import 'dart:io'; // [MỚI] Import để xử lý File

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // [MỚI] Import image_picker
import 'package:intl/intl.dart';
import 'package:health_iot/service/user_service.dart';
import 'package:health_iot/core/api/api_client.dart';

class DoctorPersonalInfoScreen extends StatefulWidget {
  const DoctorPersonalInfoScreen({super.key});

  @override
  State<DoctorPersonalInfoScreen> createState() => _DoctorPersonalInfoScreenState();
}

class _DoctorPersonalInfoScreenState extends State<DoctorPersonalInfoScreen> {
  final UserService _userService = UserService(ApiClient());
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  // [MỚI] Biến trạng thái cho việc upload ảnh
  bool _isUploadingAvatar = false;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _selectedGender = 'Nam';

  // Biến lưu URL avatar
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final user = await _userService.getUserProfile();
    if (user != null && mounted) {
      setState(() {
        _nameController.text = user.fullName;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber ?? '';
        _addressController.text = user.address ?? '';

        // Lấy Avatar URL từ Model
        _avatarUrl = user.fullAvatarUrl;

        if (user.dateOfBirth != null) {
          _dobController.text = DateFormat('yyyy-MM-dd').format(user.dateOfBirth!);
        }
        _selectedGender = user.gender ?? 'Nam';
        _isLoading = false;
      });
    }
  }

  // [MỚI] Hàm xử lý chọn ảnh từ nguồn (Camera/Gallery)
  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Đóng modal bottom sheet
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Nén ảnh nhẹ để upload nhanh hơn
      );

      if (pickedFile != null) {
        _uploadAvatar(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể chọn ảnh. Vui lòng thử lại.')),
        );
      }
    }
  }

  // [MỚI] Hàm gọi service để upload ảnh
  Future<void> _uploadAvatar(File imageFile) async {
    setState(() => _isUploadingAvatar = true);

    // Gọi hàm upload trong UserService (Bạn cần đảm bảo hàm này đã được thêm ở Bước 2)
    final newAvatarUrl = await _userService.uploadAvatar(imageFile);

    if (mounted) {
      setState(() => _isUploadingAvatar = false);
      // Cập nhật URL mới và hiển thị thông báo
      setState(() => _avatarUrl = newAvatarUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!'), backgroundColor: Colors.teal),
      );
      // Gọi lại fetchData để đồng bộ hóa hoàn toàn dữ liệu user nếu cần
      _fetchData();
        }
  }

  void _showImagePickerOptions() {
    // Chỉ hiện khi đang ở chế độ Edit
    if (!_isEditing) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Để làm bo góc đẹp hơn
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thanh gạch ngang nhỏ ở trên cùng (Handle bar)
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Cập nhật ảnh đại diện",
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Nút chọn Thư viện
            _buildOptionItem(
              icon: Icons.photo_library_rounded,
              color: Colors.blue.shade600,
              text: "Chọn từ thư viện",
              onTap: () => _pickImage(ImageSource.gallery),
            ),

            const SizedBox(height: 12),

            // Nút chọn Camera
            _buildOptionItem(
              icon: Icons.camera_alt_rounded,
              color: Colors.teal,
              text: "Chụp ảnh mới",
              onTap: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

// Widget con hỗ trợ vẽ nút chọn
  Widget _buildOptionItem({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
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
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }


  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    String dobToSend = _dobController.text;

    final success = await _userService.updateProfile({
      'full_name': _nameController.text,
      'phone_number': _phoneController.text,
      'address': _addressController.text,
      'gender': _selectedGender,
      'date_of_birth': dobToSend,
    });

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.teal),
      );
      setState(() => _isEditing = false);
      _fetchData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi cập nhật. Vui lòng thử lại.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!_isEditing) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.teal),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Thông tin cá nhân', style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: () => setState(() => _isEditing = !_isEditing),
              child: Text(
                _isEditing ? 'Hủy' : 'Sửa',
                style: GoogleFonts.inter(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    // Logic: Chỉ cho phép tap khi đang sửa VÀ không đang upload
                    onTap: (_isEditing && !_isUploadingAvatar) ? _showImagePickerOptions : null,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 1. Container Ảnh chính
                        Container(
                          width: 110, // Tăng kích thước một chút cho đẹp
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              // Viền xanh khi đang sửa, viền mờ khi xem
                              color: _isEditing ? Colors.teal : Colors.grey.shade200,
                              width: _isEditing ? 3 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                ? Image.network(
                              _avatarUrl!,
                              fit: BoxFit.cover,
                              width: 110,
                              height: 110,
                              // Thêm loading khi đang tải ảnh từ mạng
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(color: Colors.grey.shade100);
                              },
                              errorBuilder: (context, error, stack) => Image.asset(
                                'assets/images/default_avatar.png',
                                fit: BoxFit.cover,
                              ),
                            )
                                : Image.asset(
                              'assets/images/default_avatar.png',
                              fit: BoxFit.cover,
                              width: 110,
                              height: 110,
                            ),
                          ),
                        ),

                        // 2. Lớp phủ Loading khi đang upload
                        if (_isUploadingAvatar)
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          ),

                        // 3. Icon Camera nhỏ (Chỉ hiện khi Edit và không Upload)
                        if (_isEditing && !_isUploadingAvatar)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email text
                  Text(
                    _emailController.text,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500
                    ),
                  ),

                  // Hướng dẫn text
                  AnimatedOpacity(
                    opacity: _isEditing ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Chạm vào ảnh để thay đổi",
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.teal,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- FORM NHẬP LIỆU (Giữ nguyên) ---
            _buildSectionHeader("Thông tin cơ bản"),
            _buildCardContainer([
              _buildModernInput("Họ và tên", Icons.person_outline, _nameController),
              const SizedBox(height: 20),
              _buildModernInput("Email", Icons.email_outlined, _emailController, enabled: false),
              const SizedBox(height: 20),
              _buildModernInput("Số điện thoại", Icons.phone_outlined, _phoneController, isNumber: true),
            ]),

            const SizedBox(height: 24),
            _buildSectionHeader("Chi tiết cá nhân"),
            _buildCardContainer([
              _buildModernDropdown("Giới tính", Icons.wc, ['Nam', 'Nữ', 'Khác'], _selectedGender, (val) => setState(() => _selectedGender = val!)),
              const SizedBox(height: 20),
              _buildModernDatePicker("Ngày sinh", Icons.calendar_today_outlined, _dobController),
              const SizedBox(height: 20),
              _buildModernInput("Địa chỉ liên hệ", Icons.location_on_outlined, _addressController, maxLines: 2),
            ]),

            const SizedBox(height: 40),

            // --- NÚT LƯU ---
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    shadowColor: Colors.teal.withOpacity(0.3),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Lưu thay đổi', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET GIAO DIỆN MỚI (Giữ nguyên) ---
  // ... (Các hàm _buildSectionHeader, _buildCardContainer, _buildModernInput,
  //      _buildModernDropdown, _buildModernDatePicker giữ nguyên như file cũ của bạn)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
            letterSpacing: 1.2
        ),
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // 1. Input Field Hiện Đại
  Widget _buildModernInput(String label, IconData icon, TextEditingController controller, {bool isNumber = false, int maxLines = 1, bool enabled = true}) {
    final isFieldEnabled = _isEditing && enabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.teal),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: isFieldEnabled,
          keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: isFieldEnabled ? 'Nhập thông tin...' : 'Chưa cập nhật',
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: isFieldEnabled ? Colors.grey.shade50 : Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.teal, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
          ),
        ),
      ],
    );
  }

  // 2. Dropdown Hiện Đại
  Widget _buildModernDropdown(String label, IconData icon, List<String> items, String value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.teal),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: _isEditing ? onChanged : null,
          style: GoogleFonts.inter(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: _isEditing ? Colors.grey.shade50 : Colors.transparent,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.teal, width: 1.5)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
      ],
    );
  }

  // 3. Date Picker Hiện Đại
  Widget _buildModernDatePicker(String label, IconData icon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.teal),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(12),
          child: IgnorePointer(
            child: TextFormField(
              controller: controller,
              enabled: _isEditing,
              style: GoogleFonts.inter(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Chọn ngày',
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: _isEditing ? Colors.grey.shade50 : Colors.transparent,
                suffixIcon: Icon(Icons.calendar_month, color: _isEditing ? Colors.teal : Colors.grey.shade400, size: 20),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.teal, width: 1.5)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}