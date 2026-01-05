import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import package
import 'package:health_iot/service/auth_service.dart';
import 'package:health_iot/core/api/api_client.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
            _RegisterHeader(),
            Padding(
              padding: EdgeInsets.all(24.0),
              child: _RegisterForm(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
              'Tạo tài khoản mới',
              style:
              theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Bắt đầu hành trình sức khỏe của bạn',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic);
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false;

  final ApiClient _apiClient = ApiClient();
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    // "Bơm" ApiClient vào AuthService
    _authService = AuthService(_apiClient);
  }
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // === BƯỚC 4: SỬA HÀM _submitForm ĐỂ GỌI API ===
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // 1. Hiển thị loading
      setState(() => _isLoading = true);

      final fullName = _fullNameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      // 2. Bọc hàm gọi API trong try...catch
      try {
        // 3. Gọi hàm register (giờ nó sẽ ném lỗi nếu thất bại)
        // (Đảm bảo thứ tự là fullName, email, password)
        await _authService.register(fullName, email, password);

        // 4. Nếu code chạy đến đây, NÓ ĐÃ THÀNH CÔNG
        if (mounted) {
          context.go('/register/success');
        }
      } catch (error) {
        // 5. Bắt lỗi (từ server hoặc từ mạng)
        if (mounted) {
          // Hiển thị chính xác thông báo lỗi đã bị ném ra
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()), // <-- IN RA LỖI THẬT
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // 6. Luôn ẩn loading, dù thành công hay thất bại
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
          // --- TRƯỜNG NHẬP HỌ VÀ TÊN ---
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline),
              hintText: 'Họ và tên',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập họ và tên';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // --- TRƯỜNG NHẬP EMAIL ---
          TextFormField(
            controller: _emailController,
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
          const SizedBox(height: 24),

          // --- TRƯỜNG NHẬP MẬT KHẨU ---
          TextFormField(
            controller: _passwordController,
            obscureText: _isPasswordObscured,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: 'Mật khẩu',
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
                return 'Vui lòng nhập mật khẩu';
              }
              if (value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // --- TRƯỜNG XÁC NHẬN MẬT KHẨU ---
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
                return 'Vui lòng xác nhận mật khẩu';
              }
              if (value != _passwordController.text) {
                return 'Mật khẩu không khớp';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),

          // --- NÚT ĐĂNG KÝ ---
          ElevatedButton(
            // Tắt nút khi đang tải
            onPressed: _isLoading ? null : _submitForm,
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text('Đăng ký'),
          ),
          const SizedBox(height: 32),

          // --- LINK ĐĂNG NHẬP ---
          Center(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'Đã có tài khoản? '),
                  TextSpan(
                    text: 'Đăng nhập',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.go('/login'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ]
            .animate(interval: 80.ms) // Hiệu ứng xuất hiện cách nhau 80ms
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.5, end: 0, curve: Curves.easeOutCubic),
      ),
    );
  }
}