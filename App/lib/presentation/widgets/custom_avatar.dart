// lib/presentation/widgets/custom_avatar.dart
import 'package:flutter/material.dart';
import 'package:health_iot/core/constants/app_config.dart';

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
        child: ClipOval(
          child: Image.network(
            '${AppConfig.baseUrl}$imageUrl',
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to default avatar on error
              return Image.asset(
                'assets/images/default_avatar.png',
                fit: BoxFit.cover,
                width: radius * 2,
                height: radius * 2,
              );
            },
          ),
        ),
      );
    }

    // Nếu không có URL hoặc URL không hợp lệ - Dùng avatar mặc định
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: Image.asset(
          'assets/images/default_avatar.png',
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
        ),
      ),
    );
  }

}
