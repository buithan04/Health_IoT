// ============================================
// APP INFORMATION - CENTRAL CONFIG FILE
// ============================================
// Khi cần đổi tên app, SỬA FILE NÀY và các file sau:
// 1. android/app/src/main/AndroidManifest.xml (line ~39: android:label)
// 2. ios/Runner/Info.plist (line ~8, ~16: CFBundleDisplayName, CFBundleName)
// 3. web/index.html (line ~26, ~32: title)
// 4. web/manifest.json (line ~2-3: name, short_name)
// 5. windows/runner/main.cpp (line ~30: window.Create)
// ============================================

class AppInfo {
  // ========== TÊN APP ==========
  static const String appName = 'Health IoT';
  static const String appNameShort = 'Health IoT';
  static const String appNameNoSpace = 'HealthIoT';
  
  // ========== PACKAGE INFO ==========
  static const String packageName = 'health_iot';
  static const String bundleId = 'com.healthiot.app';
  static const String companyName = 'Health IoT Team';
  
  // ========== DESCRIPTION ==========
  static const String appDescription = 
      'Health IoT - Telemedicine & Remote Patient Monitoring System';
  
  // ========== VERSION ==========
  static const String version = '1.0.0';
  static const int buildNumber = 1;
  
  // ========== APP INFO ==========
  static const String supportEmail = 'support@healthiot.com';
  static const String website = 'https://healthiot.com';
}
