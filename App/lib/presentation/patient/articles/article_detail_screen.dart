import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Để mở trình duyệt ngoài

class ArticleDetailScreen extends StatefulWidget {
  final String url;
  final String title;

  const ArticleDetailScreen({super.key, required this.url, required this.title});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  WebViewController? _controller; // Nullable for Windows
  int _progress = 0; // Tiến độ tải (0-100)
  bool _hasError = false; // Trạng thái lỗi
  final bool _isWebViewSupported = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();

    // Only initialize WebView on supported platforms
    if (_isWebViewSupported) {
      _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageStarted: (String url) {
            if (mounted) setState(() => _hasError = false);
          },
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            // Chỉ hiện lỗi nếu là lỗi chính, bỏ qua các lỗi resource nhỏ (ảnh, quảng cáo)
            if (error.errorType == WebResourceErrorType.connect ||
                error.errorType == WebResourceErrorType.hostLookup) {
              if (mounted) setState(() => _hasError = true);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    }
  }

  // Hàm mở trình duyệt ngoài
  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // Đổ bóng nhẹ
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              "Tin tức sức khỏe",
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              widget.title,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        actions: [
          // Nút mở trình duyệt ngoài
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.teal),
            tooltip: "Mở bằng trình duyệt",
            onPressed: _openInBrowser,
          ),
          // Nút Refresh - only show if WebView is supported
          if (_isWebViewSupported)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: () => _controller?.reload(),
            ),
        ],
      ),
      body: _isWebViewSupported ? Stack(
        children: [
          // 1. Nội dung Web
          if (!_hasError && _controller != null) 
            WebViewWidget(controller: _controller!),

          // 2. Màn hình lỗi (nếu mất mạng)
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Không thể tải trang",
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Vui lòng kiểm tra kết nối internet",
                    style: GoogleFonts.inter(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _controller?.reload(),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Thử lại"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  )
                ],
              ),
            ),

          // 3. Thanh tiến độ (Chạy ngang phía trên)
          if (_progress < 100)
            LinearProgressIndicator(
              value: _progress / 100.0,
              backgroundColor: Colors.transparent,
              color: Colors.teal, // Màu xanh y tế
              minHeight: 3,
            ),
        ],
      ) : Center(
        // Fallback for Windows/Web - show message to open in browser
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.web, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "WebView không khả dụng trên nền tảng này",
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              "Vui lòng mở bằng trình duyệt",
              style: GoogleFonts.inter(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_browser),
              label: const Text("Mở trong trình duyệt"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),

      // Thanh điều hướng Web dưới cùng (Tùy chọn - Giống Safari)
      bottomNavigationBar: _hasError ? null : Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              color: Colors.grey[700],
              onPressed: _controller == null ? null : () async {
                if (await _controller!.canGoBack()) {
                  _controller!.goBack();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 20),
              color: Colors.grey[700],
              onPressed: _controller == null ? null : () async {
                if (await _controller!.canGoForward()) {
                  _controller!.goForward();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}