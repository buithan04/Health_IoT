import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final IconData icon;

  const SuccessScreen({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
    this.icon = Icons.check_circle_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- PHẦN HEADER VỚI NỀN MÀU SẮC ---
          _SuccessHeader(title: title, message: message, icon: icon),

          // --- PHẦN NÚT HÀNH ĐỘNG ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Spacer(), // Đẩy nút bấm xuống dưới
                  ElevatedButton(
                    onPressed: onButtonPressed,
                    child: Text(buttonText),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Sử dụng MediaQuery để header chiếm một phần cân đối của màn hình
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.cyan.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tái tạo hiệu ứng icon 2 vòng tròn từ HTML
          CircleAvatar(
            radius: 56,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white,
              child: Icon(icon, color: theme.primaryColor, size: 48),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: (theme.textTheme.headlineMedium ??
                const TextStyle(fontSize: 28))
                .copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: (theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16))
                .copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

