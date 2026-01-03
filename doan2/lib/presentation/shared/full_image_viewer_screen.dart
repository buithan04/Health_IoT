import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:go_router/go_router.dart';

class FullImageViewerScreen extends StatelessWidget {
  final String imageUrl;

  const FullImageViewerScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Nền đen cho trải nghiệm xem ảnh tốt nhất
      body: Stack(
        children: [
          // PhotoView xử lý toàn bộ logic zoom, kéo, thả
          PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3.0, // Cho phép zoom gấp 3 lần
            initialScale: PhotoViewComputedScale.contained,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            loadingBuilder: (context, event) => const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
          // Nút Đóng (Close Button)
          Positioned(
            top: 40,
            left: 10,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}