import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Import service
import 'package:health_iot/core/api/api_client.dart';
import 'package:health_iot/service/auth_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
      body: const SingleChildScrollView(
        child: Column(
          children: [
            _ForgotPasswordHeader(),
            Padding(
              padding: EdgeInsets.all(24.0),
              child: _ForgotPasswordForm(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgotPasswordHeader extends StatelessWidget {
  const _ForgotPasswordHeader();

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
        child: Text(
          'Khôi phục mật khẩu',
          style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _ForgotPasswordForm extends StatefulWidget {
  const _ForgotPasswordForm();

  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();

  // 1. Thêm Controller để lấy dữ liệu
  final _emailController = TextEditingController();

  // 2. Thêm trạng thái Loading
  bool _isLoading = false;

  // 3. Khởi tạo Service
  final ApiClient _apiClient = ApiClient();
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(_apiClient);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // 4. Logic Gửi Form
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final email = _emailController.text.trim();

      try {
        // Gọi API
        await _authService.forgotPassword(email);

        if (mounted) {
          // Hiển thị thông báo
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mã OTP đã được gửi! Vui lòng kiểm tra email.'),
              backgroundColor: Colors.green,
            ),
          );

          // Điều hướng sang màn hình nhập OTP
          // QUAN TRỌNG: Truyền email sang màn hình sau để dùng tiếp
          context.push('/forgot-password/otp-verify', extra: email);
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'Nhập email đã đăng ký của bạn. Chúng tôi sẽ gửi một mã OTP để xác thực.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // --- INPUT EMAIL ---
          TextFormField(
            controller: _emailController, // Gắn controller vào đây
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.mail_outline),
              hintText: 'Email',
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                return 'Vui lòng nhập một địa chỉ email hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // --- BUTTON GỬI ---
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm, // Disable khi đang loading
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : const Text('Gửi mã OTP'),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Quay lại Đăng nhập'),
          ),
        ],
      ),
    );
  }
}

