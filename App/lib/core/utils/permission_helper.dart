import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper class để xử lý permissions cho Video Call (ZegoCloud)
class PermissionHelper {
  /// Request camera và microphone permissions
  /// Trả về true nếu cả 2 permissions được granted
  static Future<bool> requestCallPermissions() async {
    try {
      print('🔐 [Permission] Requesting Video Call permissions...');
      
      // Trên Web, permissions được handle tự động bởi browser
      if (kIsWeb) {
        print('✅ [Permission] Web platform - permissions handled by browser');
        return true;
      }
      
      // Trên Windows: Test thực tế khi dùng ZegoCloud
      if (!kIsWeb && Platform.isWindows) {
        print('💻 [Permission] Windows detected - ZegoCloud will handle permissions...');
        return true;
      }
      
      // macOS/Linux
      if (!kIsWeb && (Platform.isMacOS || Platform.isLinux)) {
        print('✅ [Permission] Desktop platform - permissions handled by OS');
        return true;
      }
      
      // Mobile (Android/iOS) cần request explicit
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      bool cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
      bool micGranted = statuses[Permission.microphone]?.isGranted ?? false;

      print('📷 [Permission] Camera: ${cameraGranted ? "✅ Granted" : "❌ Denied"}');
      print('🎤 [Permission] Microphone: ${micGranted ? "✅ Granted" : "❌ Denied"}');

      return cameraGranted && micGranted;
    } catch (e) {
      print('❌ [Permission] Error requesting permissions: $e');
      // Trên Desktop, exception có thể xảy ra nhưng vẫn work
      // Vì OS tự handle permissions
      if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        return true;
      }
      return false;
    }
  }

  /// Kiểm tra permissions hiện tại (không request)
  static Future<bool> checkCallPermissions() async {
    try {
      // Trên Web và Desktop, assume granted
      if (kIsWeb) return true;
      if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        return true;
      }

      // Mobile: check actual status
      var cameraStatus = await Permission.camera.status;
      var micStatus = await Permission.microphone.status;

      return cameraStatus.isGranted && micStatus.isGranted;
    } catch (e) {
      print('❌ [Permission] Error checking permissions: $e');
      return false;
    }
  }

  /// Lấy hướng dẫn Windows permission instructions
  static String getWindowsPermissionInstructions() {
    return '''
📷 Camera/Microphone không truy cập được trên Windows

Vui lòng kiểm tra:

1️⃣ Settings → Privacy → Camera
   ✓ "Allow apps to access your camera" = ON
   ✓ Tìm "doan2.exe" và enable

2️⃣ Settings → Privacy → Microphone
   ✓ "Allow apps to access your microphone" = ON
   ✓ Tìm "doan2.exe" và enable

3️⃣ Kiểm tra camera không bị dùng bởi app khác:
   • Tắt Zoom, Teams, Skype, Discord
   • Kiểm tra Camera app có hoạt động
   
4️⃣ Restart app sau khi enable permissions
''';
  }

  /// Show dialog để hướng dẫn user enable permissions
  static Future<void> showPermissionDeniedDialog(BuildContext context) async {
    final isWindows = !kIsWeb && Platform.isWindows;
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yêu cầu quyền truy cập'),
        content: SingleChildScrollView(
          child: Text(
            isWindows 
              ? getWindowsPermissionInstructions()
              : 'Ứng dụng cần quyền truy cập Camera và Microphone để thực hiện video call.\n\n'
                'Vui lòng vào Cài đặt > Ứng dụng > Quyền và bật Camera, Microphone.',
            style: TextStyle(fontSize: isWindows ? 13 : 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          if (!isWindows)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // Mở app settings
              },
              child: const Text('Mở cài đặt'),
            ),
          if (isWindows)
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Mở Windows Privacy Settings
                try {
                  await Process.run('cmd', ['/c', 'start', 'ms-settings:privacy-webcam']);
                } catch (e) {
                  print('❌ Failed to open settings: $e');
                }
              },
              child: const Text('Mở Settings'),
            ),
        ],
      ),
    );
  }
}
