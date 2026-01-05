import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:health_iot/core/api/api_client.dart';
import 'package:health_iot/service/auth_service.dart';

class OtpVerifyScreen extends StatelessWidget {
  // FIX: Gán giá trị mặc định là '' để tránh lỗi "missing argument" từ Router
  final String email;

  const OtpVerifyScreen({super.key, this.email = ''});

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
            const _OtpVerifyHeader(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _OtpVerifyForm(email: email),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpVerifyHeader extends StatelessWidget {
  const _OtpVerifyHeader();

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
            const Icon(Icons.mark_chat_read_outlined,
                color: Colors.white, size: 64),
            const SizedBox(height: 24),
            Text(
              'Xác thực OTP',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Mã gồm 6 số đã được gửi đến email của bạn.',
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

class _OtpVerifyForm extends StatefulWidget {
  final String email;
  const _OtpVerifyForm({required this.email});

  @override
  State<_OtpVerifyForm> createState() => _OtpVerifyFormState();
}

class _OtpVerifyFormState extends State<_OtpVerifyForm> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  late Timer _timer;
  int _countdown = 60;
  bool _isLoading = false;

  // Service
  final ApiClient _apiClient = ApiClient();
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(_apiClient);
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdown > 0) {
        if (mounted) {
          setState(() {
            _countdown--;
          });
        }
      } else {
        _timer.cancel();
      }
    });
  }

  void resetTimer() {
    _timer.cancel();
    if (mounted) {
      setState(() {
        _countdown = 60;
      });
    }
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  // --- API: GỬI LẠI MÃ ---
  void _resendCode() async {
    if (widget.email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không tìm thấy email.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.forgotPassword(widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đã gửi mã mới! Mã cũ đã bị hủy.'),
              backgroundColor: Colors.green),
        );
        resetTimer(); // Reset 60s
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- API: XÁC NHẬN MÃ ---
  void _submitForm() async {
    if (widget.email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không tìm thấy email.')),
      );
      return;
    }

    // Kiểm tra đủ 6 ký tự
    if (_otpController.text.length == 6) {
      setState(() => _isLoading = true);
      try {
        // Gọi API verify
        await _authService.verifyOtp(widget.email, _otpController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Xác thực thành công!'),
                backgroundColor: Colors.green),
          );

          context.push('/forgot-password/create-new-password',
              extra: {'email': widget.email, 'otp': _otpController.text});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ 6 số OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          // Ô nhập OTP 6 số
          OtpInputFields(controller: _otpController),

          const SizedBox(height: 24),
          _buildResendCodeWidget(),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            child: _isLoading
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Widget _buildResendCodeWidget() {
    final theme = Theme.of(context);
    final bool isResendEnabled = _countdown == 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chưa nhận được mã? ',
          style: theme.textTheme.bodyMedium,
        ),
        isResendEnabled
            ? TextButton(
          onPressed: _isLoading ? null : _resendCode,
          child: const Text('Gửi lại mã'),
        )
            : Row(
          children: [
            Text(
              'Gửi lại sau ($_countdown s)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.hourglass_bottom_rounded,
              size: 16,
              color: Colors.grey,
            )
          ],
        ),
      ],
    );
  }
}

class OtpInputFields extends StatefulWidget {
  final TextEditingController controller;

  const OtpInputFields({super.key, required this.controller});

  @override
  State<OtpInputFields> createState() => _OtpInputFieldsState();
}

class _OtpInputFieldsState extends State<OtpInputFields> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // FIX: SỬA THÀNH 6 Ô
    const int otpLength = 6;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        children: [
          // TextField ẩn để nhận input
          Opacity(
            opacity: 0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: true,
              maxLength: otpLength,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                counterText: '',
              ),
            ),
          ),
          // Giao diện hiển thị ô
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(otpLength, (index) {
              final text = widget.controller.text;
              final char = index < text.length ? text[index] : '';
              final hasFocus = _focusNode.hasFocus &&
                  (index == text.length || (index == otpLength - 1 && text.length == otpLength));

              return Container(
                // FIX: Giảm kích thước để vừa 6 ô
                width: 45,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: hasFocus ? theme.primaryColor : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    char,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}