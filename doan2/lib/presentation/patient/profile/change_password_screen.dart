import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_iot/core/api/api_client.dart';
import 'package:app_iot/service/auth_service.dart';


class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthService _authService = AuthService(ApiClient());
  final _formKey = GlobalKey<FormState>();

  // Thêm controller cho mật khẩu cũ để gửi lên server
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isOldPasswordObscured = true;
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      // THAY BẰNG:
      final result = await _authService.changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      setState(() => _isSubmitting = false);

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
          );
          context.pop(); // Quay lại trang trước
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... (Phần AppBar giữ nguyên)
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text('Đổi mật khẩu', style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // --- Mật khẩu cũ ---
              _buildPasswordField(
                label: 'Mật khẩu cũ',
                hint: 'Nhập mật khẩu hiện tại',
                controller: _oldPasswordController, // Gắn controller
                isObscured: _isOldPasswordObscured,
                onToggleVisibility: () {
                  setState(() => _isOldPasswordObscured = !_isOldPasswordObscured);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu cũ';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // --- Mật khẩu mới ---
              _buildPasswordField(
                label: 'Mật khẩu mới',
                hint: 'Ít nhất 6 ký tự',
                controller: _newPasswordController,
                isObscured: _isNewPasswordObscured,
                onToggleVisibility: () {
                  setState(() => _isNewPasswordObscured = !_isNewPasswordObscured);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                  if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // --- Xác nhận mật khẩu mới ---
              _buildPasswordField(
                label: 'Xác nhận mật khẩu mới',
                hint: 'Nhập lại mật khẩu mới',
                isObscured: _isConfirmPasswordObscured,
                onToggleVisibility: () {
                  setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                  if (value != _newPasswordController.text) return 'Mật khẩu không khớp';
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // --- Nút Lưu ---
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm, // Disable khi đang gửi
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  elevation: 4,
                  shadowColor: Colors.teal.withOpacity(0.3),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Lưu mật khẩu', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Giữ nguyên hàm _buildPasswordField của bạn)
  Widget _buildPasswordField({
    required String label,
    required String hint,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    TextEditingController? controller,
  }) {
    // Copy y nguyên code cũ
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscured,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal.shade500, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade600, width: 2)),
          ),
        ),
      ],
    );
  }
}