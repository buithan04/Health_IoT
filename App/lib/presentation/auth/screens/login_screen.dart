import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_iot/core/api/api_client.dart';
import 'package:health_iot/service/auth_service.dart';
import 'package:health_iot/service/fcm_service.dart';
import 'package:health_iot/service/zego_call_service.dart';
import 'package:health_iot/models/common/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
// --- THÊM IMPORT NÀY ---
import 'package:health_iot/service/user_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- XỬ LÝ THÔNG BÁO HẾT HẠN SESSION ---
    // Lấy dữ liệu extra từ Router (do Splash gửi sang)
    final state = GoRouterState.of(context);
    final Map<String, dynamic>? extra = state.extra as Map<String, dynamic>?;
    final String? errorMessage = extra?['error'];

    // Nếu có lỗi, hiển thị SnackBar sau khi build xong
    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }

    return const Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _LoginHeader(),
            Padding(
              padding: EdgeInsets.all(24.0),
              child: _LoginForm(),
            ),
          ],
        ),
      ),
    );
  }
}

// ... (Phần _LoginHeader và _LoginForm bên dưới GIỮ NGUYÊN code cũ của bạn)
// Tôi chỉ copy lại để file hoàn chỉnh, không thay đổi logic bên trong form

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.cyan.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
      ),
      child: Column(
        children: [
          const Icon(Icons.health_and_safety_outlined, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          Text(
            'Chào mừng bạn!',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final ApiClient _apiClient = ApiClient();
  late final AuthService _authService;
  int _selectedRoleIndex = 0;
  bool _isPasswordObscured = true;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(_apiClient);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        AuthResponse authData = await _authService.login(
          _emailController.text,
          _passwordController.text,
        );

        try { await FcmService().syncTokenAfterLogin(); } catch (_) {}

        // Initialize ZegoCloud for video/voice calls
        try {
          print('\ud83c\udfac [LOGIN] Initializing ZegoCloud with avatar: ${authData.avatar}');
          
          await ZegoCallService().initialize(
            userId: authData.userId.toString(),
            userName: authData.userName,
            userAvatar: authData.avatar,
          );
          print('✅ [LOGIN] ZegoCloud initialized');
        } catch (e) {
          print('⚠️ [LOGIN] ZegoCloud init failed: $e');
        }

        if (mounted) {
          final bool isTabDoctor = _selectedRoleIndex == 1;
          final bool isAccDoctor = authData.role == UserRole.doctor;

          if (isTabDoctor && !isAccDoctor) {
            await _authService.logout();
            throw Exception("Tài khoản này không có quyền Bác sĩ.");
          }
          if (!isTabDoctor && isAccDoctor) {
            throw Exception("Bạn là Bác sĩ, vui lòng chọn tab 'Bác sĩ'.");
          }

          // WebRTC không cần init tại đây, init trong chat_detail_screen

          if (authData.role == UserRole.doctor) {
            context.go('/doctor/dashboard');
          } else {
            context.go('/dashboard');
          }
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceFirst("Exception: ", "")),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
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
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(99)),
            child: Row(children: [_buildRoleTab(context, 'Bệnh nhân', 0), _buildRoleTab(context, 'Bác sĩ', 1)]),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline), hintText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Vui lòng nhập email';
              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Email không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _passwordController,
            obscureText: _isPasswordObscured,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: 'Mật khẩu',
              suffixIcon: IconButton(
                icon: Icon(_isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
              ),
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () => context.push('/forgot-password'), child: const Text('Quên mật khẩu?')),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Đăng nhập'),
          ),
          const SizedBox(height: 32),
          Center(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'Chưa có tài khoản? '),
                  TextSpan(
                    text: 'Đăng ký ngay',
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                    recognizer: TapGestureRecognizer()..onTap = () => context.push('/register'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTab(BuildContext context, String text, int index) {
    final theme = Theme.of(context);
    final isSelected = _selectedRoleIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRoleIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}