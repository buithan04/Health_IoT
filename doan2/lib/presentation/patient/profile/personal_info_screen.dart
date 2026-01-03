import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:app_iot/core/api/api_client.dart';
import 'package:app_iot/service/user_service.dart';
import 'package:app_iot/models/common/user_model.dart'; // Import

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final UserService _userService = UserService(ApiClient());
  bool _isEditing = false;
  bool _isLoading = true;

  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController; // Thêm controller địa chỉ
  // 1. Thêm Controller
  late final TextEditingController _insuranceController;
  late final TextEditingController _occupationController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;

  String _selectedGender = 'male'; // Biến lưu giới tính (mặc định Nam)

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dobController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController(); // Init

    // 2. Init Controller (initState)
    _insuranceController = TextEditingController();
    _occupationController = TextEditingController();
    _emergencyNameController = TextEditingController();
    _emergencyPhoneController = TextEditingController();

    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // 1. Đổi kiểu thành User? (có thể null)
      final User? user = await _userService.getUserProfile();

      // 2. Kiểm tra: Nếu user null thì dừng lại, không làm gì cả
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // 3. Lúc này Dart đã biết 'user' chắc chắn có dữ liệu
      if (mounted) {
        setState(() {
          _nameController.text = user.fullName;

          if (user.dateOfBirth != null) {
            _dobController.text = DateFormat('yyyy-MM-dd').format(user.dateOfBirth!);
          }

          _emailController.text = user.email;
          _phoneController.text = user.phoneNumber ?? '';
          _addressController.text = user.address ?? '';

          // --- CÁC DÒNG GÂY LỖI ĐÃ ĐƯỢC FIX ---
          // Vì đã check (user == null) ở trên, nên ở đây truy cập thoải mái
          _insuranceController.text = user.insuranceNumber ?? '';
          _occupationController.text = user.occupation ?? '';
          _emergencyNameController.text = user.emergencyContactName ?? '';
          _emergencyPhoneController.text = user.emergencyContactPhone ?? '';

          if (user.gender != null) {
            _selectedGender = user.gender!;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tải thông tin')));
      }
    }
  }

  Future<void> _saveChanges() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang cập nhật...')));

    final success = await _userService.updateProfile({
      'full_name': _nameController.text,
      'date_of_birth': _dobController.text,
      'phone_number': _phoneController.text,
      'address': _addressController.text, // Gửi địa chỉ
      'gender': _selectedGender,          // Gửi giới tính
      'insurance_number': _insuranceController.text,
      'occupation': _occupationController.text,
      'emergency_contact_name': _emergencyNameController.text,
      'emergency_contact_phone': _emergencyPhoneController.text,
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu thay đổi thành công!'), backgroundColor: Colors.green),
        );
        setState(() => _isEditing = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thất bại'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Thông tin cá nhân', style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(
              _isEditing ? 'Hủy' : 'Sửa',
              style: GoogleFonts.inter(color: Colors.teal.shade500, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoTextField(
              label: 'Họ và tên',
              controller: _nameController,
              icon: Icons.person_outline,
              isEnabled: _isEditing,
            ),
            const SizedBox(height: 24),

            // --- Dropdown Giới tính ---
            _buildGenderDropdown(),

            const SizedBox(height: 24),
            _buildInfoTextField(
              label: 'Ngày sinh',
              controller: _dobController,
              icon: Icons.calendar_today_outlined,
              isEnabled: _isEditing,
              isDate: true,
            ),
            const SizedBox(height: 24),
            _buildInfoTextField(
              label: 'Email',
              controller: _emailController,
              icon: Icons.mail_outline,
              isEnabled: false,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            _buildInfoTextField(
              label: 'Số điện thoại',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              isEnabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // --- Trường Địa chỉ ---
            _buildInfoTextField(
              label: 'Địa chỉ',
              controller: _addressController,
              icon: Icons.location_on_outlined,
              isEnabled: _isEditing,
              keyboardType: TextInputType.streetAddress,
            ),

            // 5. Update build (Thêm TextField vào UI)
// Chèn xuống dưới phần Số điện thoại/Địa chỉ
            const SizedBox(height: 24),
            Text("Thông tin bổ sung", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
            const SizedBox(height: 16),
            _buildInfoTextField(label: 'Nghề nghiệp', controller: _occupationController, icon: Icons.work, isEnabled: _isEditing),
            const SizedBox(height: 16),
            _buildInfoTextField(label: 'Số BHYT', controller: _insuranceController, icon: Icons.card_membership, isEnabled: _isEditing),

            const SizedBox(height: 24),
            Text("Liên hệ khẩn cấp", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
            const SizedBox(height: 16),
            _buildInfoTextField(label: 'Tên người thân', controller: _emergencyNameController, icon: Icons.person_add, isEnabled: _isEditing),
            const SizedBox(height: 16),
            _buildInfoTextField(label: 'SĐT người thân', controller: _emergencyPhoneController, icon: Icons.phone_callback, isEnabled: _isEditing, keyboardType: TextInputType.phone),

            const SizedBox(height: 40),
            Visibility(
              visible: _isEditing,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                ),
                child: Text('Lưu thay đổi', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Dropdown cho Giới tính
  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Giới tính', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _isEditing ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
              style: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
              onChanged: _isEditing ? (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              } : null, // Disable nếu không phải chế độ sửa
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Nam')),
                DropdownMenuItem(value: 'female', child: Text('Nữ')),
                DropdownMenuItem(value: 'other', child: Text('Khác')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget TextField dùng chung (Giữ nguyên style cũ)
  Widget _buildInfoTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEnabled,
    TextInputType keyboardType = TextInputType.text,
    bool isDate = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: isEnabled,
          keyboardType: keyboardType,
          readOnly: isDate,
          onTap: isDate && isEnabled
              ? () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            }
          }
              : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade500),
            filled: true,
            fillColor: isEnabled ? Colors.white : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal.shade500, width: 2)),
          ),
        ),
      ],
    );
  }
}