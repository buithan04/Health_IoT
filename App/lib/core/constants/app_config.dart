// lib/core/constants/app_config.dart

class AppConfig {
  // --- CHỈ CẦN SỬA ĐÚNG DÒNG NÀY KHI ĐỔI MẠNG ---
  // static const String ipAddress = "10.0.2.2:3000"; // Dùng cho máy ảo
  static const String ipAddress = "192.168.65.47:5000"; // Dùng cho điện thoại thật (IP LAN)
  // static const String ipAddress = "healthflow-api.onrender.com"; // Dùng cho Server thật (Ví dụ)

  // --- Các biến bên dưới sẽ tự động cập nhật theo ---
  static const String baseUrl = "http://$ipAddress";
  static const String apiUrl = "$baseUrl/api";
  static const String socketUrl = baseUrl;

  // Hàm tiện ích để xử lý ảnh (Dùng chung cho cả app)
  static String formatUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') {
      return ''; // Hoặc trả về ảnh mặc định
    }
    if (url.startsWith('http')) return url;

    // Xử lý trường hợp url bắt đầu bằng / hoặc không
    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }
    return '$baseUrl/$url';
  }
}