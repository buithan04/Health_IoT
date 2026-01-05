import 'package:flutter/material.dart';

/// Professional Avatar Widget với viền gradient, loading, và error handling
/// Sử dụng thống nhất trong toàn bộ app
class ProfessionalAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool showBadge;
  final IconData? badgeIcon;
  final Color? badgeColor;
  final bool isCircle;
  final double borderRadius;
  final List<Color>? gradientColors;
  final double borderWidth;

  const ProfessionalAvatar({
    super.key,
    this.imageUrl,
    required this.size,
    this.showBadge = false,
    this.badgeIcon = Icons.verified,
    this.badgeColor,
    this.isCircle = true,
    this.borderRadius = 12,
    this.gradientColors,
    this.borderWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradient = gradientColors ?? [
      Colors.teal.shade300,
      Colors.teal.shade600,
    ];

    return Stack(
      children: [
        // Viền gradient chuyên nghiệp
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: defaultGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: isCircle 
                ? BorderRadius.circular(size) 
                : BorderRadius.circular(borderRadius + borderWidth),
            boxShadow: [
              BoxShadow(
                color: defaultGradient[1].withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(borderWidth),
            child: ClipRRect(
              borderRadius: isCircle 
                  ? BorderRadius.circular(size) 
                  : BorderRadius.circular(borderRadius),
              child: _buildImageContent(),
            ),
          ),
        ),

        // Badge (nếu có)
        if (showBadge)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(size * 0.06),
              decoration: BoxDecoration(
                color: badgeColor ?? Colors.teal,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                badgeIcon,
                color: Colors.white,
                size: size * 0.15,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageContent() {
    final hasValidUrl = imageUrl != null && 
                        imageUrl!.isNotEmpty && 
                        imageUrl!.startsWith('http');

    if (!hasValidUrl) {
      return Image.asset(
        'assets/images/default_avatar.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return Container(
          color: Colors.grey.shade100,
          child: Center(
            child: SizedBox(
              width: size * 0.3,
              height: size * 0.3,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2.5,
                color: Colors.teal,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Fallback to default avatar
        return Image.asset(
          'assets/images/default_avatar.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder();
          },
        );
      },
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: Colors.grey.shade400,
      ),
    );
  }
}

/// Shimmer Loading Avatar - Dùng cho skeleton loading
class ShimmerAvatar extends StatefulWidget {
  final double size;
  final bool isCircle;
  final double borderRadius;

  const ShimmerAvatar({
    super.key,
    required this.size,
    this.isCircle = true,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerAvatar> createState() => _ShimmerAvatarState();
}

class _ShimmerAvatarState extends State<ShimmerAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: widget.isCircle
                ? BorderRadius.circular(widget.size)
                : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}
