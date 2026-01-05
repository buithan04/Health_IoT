# 📞 Hướng dẫn sử dụng ZegoCloud Call (UI có sẵn)

## 🎯 Tại sao sử dụng UI có sẵn của ZegoCloud?

✅ **Ưu điểm:**
- UI đẹp, chuẩn giống Messenger
- Tự động handle incoming call notification (foreground + background + terminated)
- Tự động ringtone, vibration, timeout
- Code ít hơn 90%, ít bug hơn
- Official support từ ZegoCloud
- CallKit support cho iOS (native incoming call)

❌ **Custom UI có vấn đề:**
- Phức tạp, dễ lỗi overflow
- Phải tự handle nhiều edge cases
- Khó maintain

---

## 🛠️ Setup (3 bước đơn giản)

### **Bước 1: Update pubspec.yaml**

```yaml
dependencies:
  # ZegoCloud Call với UI có sẵn
  zego_uikit_prebuilt_call: ^4.22.2
  zego_uikit_signaling_plugin: ^2.8.6  # ⭐ CẦN THÊM
  
  # Không cần:
  # - vibration (ZegoCloud tự handle)
  # - flutter_ringtone_player (ZegoCloud tự handle)
  # - socket.io (ZegoCloud có signaling riêng)
```

Chạy:
```bash
flutter pub get
```

---

### **Bước 2: Update main.dart**

**Thay đổi từ:**
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return GlobalCallHandler(  // ❌ XÓA
          child: child!,
        );
      },
    );
  }
}
```

**Thành:**
```dart
import 'presentation/shared/zego_call_wrapper.dart';  // ⭐ THÊM

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Giữ lại
      builder: (context, child) {
        return ZegoCallWrapper(  // ✅ THAY THẾ
          child: child!,
        );
      },
    );
  }
}
```

---

### **Bước 3: Sử dụng trong app**

#### **3.1. Khởi tạo khi user login**

```dart
// Sau khi login thành công
import 'package:health_iot/service/zego_call_service.dart';

await ZegoCallService().initialize(
  userId: currentUser.id,
  userName: currentUser.name,
  userAvatar: currentUser.avatar, // Optional
);
```

#### **3.2. Gọi video call**

```dart
// Button gọi video
ElevatedButton(
  onPressed: () async {
    await ZegoCallService().startVideoCall(
      context: context,
      targetUserId: doctorId,
      targetUserName: doctorName,
    );
  },
  child: Text('📹 Video Call'),
)
```

#### **3.3. Gọi voice call**

```dart
// Button gọi thoại
ElevatedButton(
  onPressed: () async {
    await ZegoCallService().startVoiceCall(
      context: context,
      targetUserId: doctorId,
      targetUserName: doctorName,
    );
  },
  child: Text('📞 Voice Call'),
)
```

#### **3.4. Uninitialize khi logout**

```dart
// Khi user logout
await ZegoCallService().uninitialize();
```

---

## 🎨 Customize UI (Optional)

Nếu muốn thay đổi màu sắc, icons:

**Trong zego_call_service.dart:**
```dart
requireConfig: (ZegoCallInvitationData data) {
  final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();
  
  // Customize
  config
    // Màu nền
    ..audioVideoView.backgroundColor = Colors.black
    
    // Nút bấm
    ..bottomMenuBar.buttons = [
      ZegoCallMenuBarButtonName.toggleCameraButton,
      ZegoCallMenuBarButtonName.toggleMicrophoneButton,
      ZegoCallMenuBarButtonName.hangUpButton,
      ZegoCallMenuBarButtonName.switchCameraButton,
    ]
    
    // Âm thanh
    ..turnOnCameraWhenJoining = true
    ..turnOnMicrophoneWhenJoining = true
    ..useSpeakerWhenJoining = true;
  
  return config;
},
```

---

## 📱 Testing

### **Test Case 1: Foreground Call**
1. Mở app trên 2 devices
2. Login 2 users khác nhau
3. Device A: Tap button "📹 Video Call"
4. Device B: **Tự động hiển thị incoming call screen**
5. Tap Accept → Vào call

### **Test Case 2: Background Call**
1. Device A: Mở app
2. Device B: Minimize app (home button)
3. Device A: Gọi video
4. Device B: **Notification hiển thị + ringtone + vibrate**
5. Tap notification → Accept → Vào call

### **Test Case 3: App Terminated**
1. Device A: Mở app
2. Device B: Kill app (swipe away)
3. Device A: Gọi video
4. Device B: **Push notification hiển thị**
5. Tap notification → App mở → Incoming call → Accept

---

## 🔥 So sánh: Custom UI vs ZegoCloud UI

| Feature | Custom UI | ZegoCloud UI |
|---------|-----------|--------------|
| Code cần viết | ~800 lines | ~50 lines |
| Bugs | Nhiều (overflow, state, timing) | Ít (tested by ZegoCloud) |
| Incoming call | Phải tự handle socket + FCM | Tự động |
| Ringtone/Vibrate | Phải tự code | Tự động |
| Timeout | Phải tự code timer | Tự động (45s) |
| Background call | Phải setup FCM phức tạp | Tự động |
| iOS CallKit | Phải tích hợp riêng | Tự động |
| UI/UX | Phải design | Chuẩn Messenger |
| Maintenance | Cao | Thấp |

---

## ⚠️ Lưu ý quan trọng

### 1. **Không cần Socket.IO cho signaling nữa**
ZegoCloud có signaling server riêng. Bạn chỉ cần Socket.IO cho chat/realtime data khác.

### 2. **Không cần FCM push riêng cho call**
ZegoCloud tự động gửi push notification qua hệ thống của họ.

### 3. **Signaling Plugin bắt buộc**
Phải thêm `zego_uikit_signaling_plugin` vào dependencies.

### 4. **Initialize khi login, Uninitialize khi logout**
Quan trọng để tránh nhận call của user cũ.

---

## 🗑️ Có thể xóa (không cần nữa)

- ❌ `lib/service/zego_service.dart` (custom code cũ)
- ❌ `lib/presentation/shared/global_call_handler.dart`
- ❌ `lib/presentation/shared/incoming_call_handler.dart`
- ❌ `lib/presentation/shared/widgets/incoming_call_screen.dart` (UI custom)
- ❌ `lib/presentation/shared/widgets/connecting_call_screen.dart`
- ❌ Dependencies: `vibration`, `flutter_ringtone_player` (nếu chỉ dùng cho call)

---

## 📚 Documentation

- [ZegoCloud Call Documentation](https://docs.zegocloud.com/article/14826)
- [API Reference](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/)
- [Sample Code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_call_flutter)

---

## 🎯 Migration Checklist

- [ ] Thêm `zego_uikit_signaling_plugin` vào pubspec.yaml
- [ ] Tạo file `zego_call_service.dart` (đã có sẵn)
- [ ] Tạo file `zego_call_wrapper.dart` (đã có sẵn)
- [ ] Update `main.dart` - Thay `GlobalCallHandler` → `ZegoCallWrapper`
- [ ] Update login flow - Gọi `ZegoCallService().initialize()`
- [ ] Update logout flow - Gọi `ZegoCallService().uninitialize()`
- [ ] Update call buttons - Dùng `ZegoCallService().startVideoCall()`
- [ ] Test 3 scenarios: Foreground, Background, Terminated
- [ ] Xóa các file cũ không dùng nữa

---

**✅ Kết quả:** Code giảm 90%, ổn định hơn, UI đẹp hơn, ít bug hơn! 🚀
