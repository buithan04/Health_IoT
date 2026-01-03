// lib/presentation/widgets/custom_avatar.dart
import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackText;
  final Color? backgroundColor;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.fallbackText,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu có URL hợp lệ
    if (imageUrl != null && imageUrl!.isNotEmpty && imageUrl != 'null') {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey.shade300,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // Nếu load ảnh lỗi, sẽ hiển thị child bên dưới
        },
        child: _buildFallback(),
      );
    }

    // Nếu không có URL hoặc URL không hợp lệ - Dùng avatar mặc định
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      backgroundImage: AssetImage('assets/images/default_avatar.png'),
    );
  }

  Widget _buildFallback() {
    if (fallbackText != null && fallbackText!.isNotEmpty) {
      return Text(
        fallbackText!.substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Icon(
      Icons.person,
      size: radius * 1.2,
      color: Colors.white,
    );
  }
}
