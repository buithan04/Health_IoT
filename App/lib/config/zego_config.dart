/// ZegoCloud Configuration
/// 
/// Để lấy credentials:
/// 1. Đăng ký tại: https://console.zegocloud.com
/// 2. Tạo project mới
/// 3. Copy AppID và AppSign từ console
/// 
/// Free tier: 10,000 phút/tháng (đủ cho development và testing)

class ZegoConfig {
  // ZegoCloud Telehealth Project - Configured
  static const int appID = 121508125;
  static const String appSign = '53f9664a326a71e7df892450ce17bbc757052432ce8f02df9ff2aa1c6fb6f6ae';
  
  // Kiểm tra config có hợp lệ không
  static bool get isConfigured {
    return appID != 0 && appSign != 'YOUR_APP_SIGN_HERE';
  }
  
  // Lấy error message nếu chưa config
  static String get configError {
    if (!isConfigured) {
      return '''
⚠️ ZegoCloud chưa được cấu hình!

Vui lòng:
1. Đăng ký tại: https://console.zegocloud.com
2. Tạo project mới
3. Lấy AppID và AppSign
4. Cập nhật vào file: lib/config/zego_config.dart
''';
    }
    return '';
  }
}
