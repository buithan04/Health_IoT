import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_iot/core/api/api_client.dart'; // Import
import 'package:health_iot/service/auth_service.dart';

class CreateNewPasswordScreen extends StatelessWidget {
  final String email;
  final String otp; // [FIX 1] Khai báo biến otp

  // [FIX 2] Nhận otp từ constructor
  const CreateNewPasswordScreen({
    super.key,
    this.email = '',
    this.otp = '' // Mặc định rỗng
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _NewPasswordHeader(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              // [FIX 3] Truyền cả email và otp xuống Form
              child: _NewPasswordForm(email: email, otp: otp),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewPasswordHeader extends StatelessWidget {
  const _NewPasswordHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 100, 32, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.cyan.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              'Tạo mật khẩu mới',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Mật khẩu mới phải khác mật khẩu cũ.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewPasswordForm extends StatefulWidget {
  final String email;
  final String otp; // [FIX 4] Khai báo nhận otp

  const _NewPasswordForm({
    required this.email,
    required this.otp // [FIX 4] Constructor nhận otp
  });

  @override
  State<_NewPasswordForm> createState() => _NewPasswordFormState();
}

class _NewPasswordFormState extends State<_NewPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  // State loading và Service
  bool _isLoading = false;
  final ApiClient _apiClient = ApiClient();
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(_apiClient);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // --- HÀM GỬI FORM ---
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Kiểm tra dữ liệu đầu vào
      if (widget.email.isEmpty || widget.otp.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Thiếu thông tin xác thực (Email hoặc OTP).')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // [FIX 5] Gọi API Reset Password với đủ 3 tham số
        await _authService.resetPassword(
            widget.email,
            _passwordController.text,
            widget.otp // <-- Đây là tham số thứ 3 còn thiếu
        );

        if (mounted) {
          // Thành công -> Chuyển đến trang Success
          context.go('/forgot-password/success');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.toString()),
                backgroundColor: Colors.red
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          TextFormField(
            controller: _passwordController,
            obscureText: _isPasswordObscured,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: 'Mật khẩu mới',
              suffixIcon: IconButton(
                icon: Icon(_isPasswordObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu mới';
              }
              if (value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            obscureText: _isConfirmPasswordObscured,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: 'Xác nhận mật khẩu',
              suffixIcon: IconButton(
                icon: Icon(_isConfirmPasswordObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận lại mật khẩu';
              }
              if (value != _passwordController.text) {
                return 'Mật khẩu không khớp';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            child: _isLoading
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Text('Lưu mật khẩu'),
          ),
        ],
      ),
    );
  }
}