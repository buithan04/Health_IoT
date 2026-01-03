# 🎥 ZegoCloud Setup Guide

## Đã hoàn thành:
✅ Thêm ZegoCloud dependencies vào pubspec.yaml
✅ Tạo ZegoConfig để lưu credentials
✅ Tạo ZegoService để thay thế WebRTCService
✅ Cập nhật SocketService với ZegoCloud signaling

## ⚠️ CẦN LÀM:

### 1. Đăng ký ZegoCloud và lấy credentials

1. Truy cập: https://console.zegocloud.com
2. Đăng ký/Đăng nhập tài khoản
3. Tạo project mới:
   - Project Name: HealthAI (hoặc tên bạn muốn)
   - Platform: Mobile (iOS/Android)
   - Region: Southeast Asia (gần Việt Nam nhất)
4. Lấy credentials:
   - Copy **AppID** (số nguyên, ví dụ: 123456789)
   - Copy **AppSign** (chuỗi dài, ví dụ: abc123def456...)

### 2. Cập nhật ZegoConfig

Mở file: `lib/config/zego_config.dart`

Thay đổi:
```dart
static const int appID = 0; // ⚠️ THAY ĐỔI
static const String appSign = 'YOUR_APP_SIGN_HERE'; // ⚠️ THAY ĐỔI
```

Thành:
```dart
static const int appID = 123456789; // AppID từ ZegoCloud
static const String appSign = 'abc123def...'; // AppSign từ ZegoCloud
```

### 3. Install dependencies

Chạy lệnh:
```bash
flutter pub get
```

### 4. Cập nhật Server (Node.js)

Server cần thêm ZegoCloud signaling handlers vào `socket_manager.js`:

```javascript
// Thêm vào socket_manager.js

// ZegoCloud Call Invitation
socket.on('zego_call_invitation', ({ to, callId, isVideoCall }) => {
  console.log(`[ZEGO] Call invitation: ${socket.userId} → ${to}`);
  
  const targetSocketId = onlineUsers.get(to);
  if (targetSocketId) {
    io.to(targetSocketId).emit('zego_call_invitation', {
      from: socket.userId,
      fromName: socket.userName,
      fromAvatar: socket.userAvatar,
      callId,
      isVideoCall,
    });
  }
});

// ZegoCloud Call Accepted
socket.on('zego_call_accepted', ({ to, callId }) => {
  console.log(`[ZEGO] Call accepted: ${socket.userId} → ${to}`);
  
  const targetSocketId = onlineUsers.get(to);
  if (targetSocketId) {
    io.to(targetSocketId).emit('zego_call_accepted', {
      from: socket.userId,
      callId,
    });
  }
});

// ZegoCloud Call Declined
socket.on('zego_call_declined', ({ to, callId }) => {
  console.log(`[ZEGO] Call declined: ${socket.userId} → ${to}`);
  
  const targetSocketId = onlineUsers.get(to);
  if (targetSocketId) {
    io.to(targetSocketId).emit('zego_call_declined', {
      from: socket.userId,
      callId,
    });
  }
});

// ZegoCloud Call Ended
socket.on('zego_call_ended', ({ to, callId }) => {
  console.log(`[ZEGO] Call ended: ${socket.userId} → ${to}`);
  
  const targetSocketId = onlineUsers.get(to);
  if (targetSocketId) {
    io.to(targetSocketId).emit('zego_call_ended', {
      from: socket.userId,
      callId,
    });
  }
});
```

### 5. Cập nhật UI screens

Cần cập nhật các file sau để dùng ZegoService thay vì WebRTCService:

- [ ] `lib/screens/message_doctor/chat_detail_screen.dart` - Nút gọi video
- [ ] `lib/utils/global_call_listener.dart` - Xử lý incoming call
- [ ] `lib/screens/call/call_screen.dart` - Màn hình call (hoặc tạo mới)

### 6. Test

1. Hot restart app: `R`
2. Test call Windows → App
3. Kiểm tra logs xem ZegoCloud có khởi tạo thành công không

## 📝 Lợi ích của ZegoCloud:

✅ **Không còn ICE connection failures**
- ZegoCloud tự xử lý TURN/STUN servers
- NAT traversal luôn work
- Connection ổn định hơn nhiều

✅ **Code đơn giản hơn**
- Không cần xử lý offer/answer/ICE candidates
- SDK lo hết phần WebRTC phức tạp
- Chỉ cần gọi các method đơn giản

✅ **UI đẹp sẵn**
- ZegoUIKitPrebuiltCall có UI call đẹp sẵn
- Có nút mute/camera/speaker/hang up
- Tự động xử lý responsive

✅ **Free tier hào phóng**
- 10,000 phút/tháng miễn phí
- Đủ cho development và testing
- Sau này scale lên mới trả tiền

## 🔧 Troubleshooting

**Lỗi: "ZegoCloud chưa được cấu hình"**
→ Chưa điền AppID/AppSign vào zego_config.dart

**Lỗi khi build Android**
→ Cần thêm permissions vào AndroidManifest.xml (đã có sẵn từ WebRTC)

**Call không kết nối**
→ Kiểm tra server đã thêm ZegoCloud signaling handlers chưa

## 📱 Sau khi xong:

Bạn sẽ có:
- ✅ Video call ổn định, không fail
- ✅ Audio call clear
- ✅ UI đẹp, professional
- ✅ Code đơn giản, dễ maintain

---

**Khi nào bạn lấy được AppID và AppSign, gửi cho tôi để tôi điền vào config nhé!** 🚀
