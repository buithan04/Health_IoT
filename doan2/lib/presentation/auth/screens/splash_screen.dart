import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_iot/core/api/api_client.dart';
import 'package:app_iot/service/auth_service.dart';
import 'package:app_iot/models/common/user_model.dart';
// --- THÊM 2 IMPORT NÀY ---
import 'package:app_iot/service/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Biến này = true: Hiện animation. = false: Hiện màn hình trắng (loading)
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller (nhưng chưa chạy)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Bắt đầu kiểm tra logic
    _checkAppStart();
  }

  void _checkAppStart() async {
    final authService = AuthService(ApiClient());

    // 1. Kiểm tra trạng thái
    final session = await authService.checkSession();
    final status = session['status'];

    if (!mounted) return;

    if (status == 'first_launch') {
      // WebRTC không cần init tại đây
      // === TRƯỜNG HỢP 1: MỚI TẢI APP ===
      // Hiện animation, sau đó đánh dấu đã mở
      setState(() => _showAnimation = true);
      _setupAnimation();
      await authService.markAppLaunched();

      // Đợi animation chạy xong (ví dụ 2.5s) rồi chuyển Login
      Timer(const Duration(milliseconds: 2500), () {
        if (mounted) context.go('/login');
      });

    } else if (status == 'valid') {
      // === TRƯỜNG HỢP 2: CÒN HẠN ĐĂNG NHẬP ===
      // Chuyển thẳng Dashboard (Không hiện animation)
      final role = session['role'];
      if (role == UserRole.doctor) {
        context.go('/doctor/dashboard');
      } else {
        context.go('/dashboard');
      }

    } else if (status == 'expired') {
      // === TRƯỜNG HỢP 3: HẾT HẠN (7 NGÀY) ===
      // Chuyển về Login + Gửi kèm thông báo lỗi
      context.go('/login', extra: {'error': 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.'});

    } else {
      // === TRƯỜNG HỢP 4: ĐÃ LOGOUT / CHƯA LOGIN ===
      // Chuyển về Login bình thường (Không hiện animation)
      context.go('/login');
    }
  }

  void _setupAnimation() {
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nếu KHÔNG phải lần đầu, return màn hình trắng để chuyển trang ngay lập tức
    // (Tránh hiện animation chớp nháy)
    if (!_showAnimation) {
      return const Scaffold(
        backgroundColor: Colors.white, // Hoặc màu nền app
        body: SizedBox(),
      );
    }

    // Nếu là lần đầu, render UI Animation
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.cyan.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.health_and_safety_outlined, color: Colors.white, size: 96),
                  const SizedBox(height: 24),
                  Text(
                    'HealthFlow',
                    style: (theme.textTheme.displaySmall ?? const TextStyle(fontSize: 45))
                        .copyWith(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: -1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chăm sóc sức khỏe trong tầm tay',
                    style: (theme.textTheme.titleMedium ?? const TextStyle(fontSize: 16))
                        .copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}