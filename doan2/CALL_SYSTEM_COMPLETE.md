# 📞 Hệ Thống Call Logic - 5 Giai Đoạn Hoàn Chỉnh

## 🎯 Tổng Quan

Hệ thống call đã được triển khai đầy đủ theo mô hình Messenger với 5 giai đoạn:

### **1. Giai đoạn Khởi tạo & Kiểm tra (Pre-call)** ✅
**File**: `lib/service/call_manager.dart`

**Chức năng**:
- ✅ **Permission Check**: Kiểm tra quyền Camera/Microphone
  - Video call: Camera + Microphone
  - Audio call: Chỉ Microphone
  - Tự động request nếu chưa có quyền
  - Hiển thị dialog mở Settings nếu permanently denied

- ✅ **Network Check**: Kiểm tra kết nối mạng
  - Phát hiện loại kết nối (WiFi, Mobile Data, Ethernet)
  - Cảnh báo nếu mạng không ổn định
  - Block cuộc gọi nếu không có Internet

- ✅ **Device Status Check**: Kiểm tra thiết bị có sẵn sàng không
  - Phát hiện nếu đang có cuộc gọi khác
  - Ngăn chặn gọi đè lên nhau

**Code**:
```dart
final checkResult = await CallManager().performPreCallChecks(
  isVideoCall: true,
);

if (!checkResult.canProceed) {
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(checkResult.message)),
  );
  return;
}
```

---

### **2. Giai đoạn Tín hiệu & Thông báo (Signaling)** ✅
**File**: `lib/service/call_manager.dart` + `lib/service/zego_service.dart`

**Chức năng**:
- ✅ **Session Creation**: Tạo Call ID duy nhất
- ✅ **Push Notification**: Gửi qua Socket.IO
  - Realtime cho người đang online
  - FCM push notification cho người offline (đã tích hợp Firebase)
  
- ✅ **Timeout Logic**: 45 giây tự động
  ```dart
  CallManager().startCallTimeout(
    callId: callId,
    onTimeout: () {
      print('⏰ Timeout - No answer');
      // Close connecting screen
      Navigator.pop(context);
      // Show "Người dùng không trả lời"
      ZegoService().endCall();
    },
  );
  ```

- ✅ **Connecting Screen**: Hiển thị màn hình "Đang gọi..." với animation
  - Ripple effect xung quanh avatar
  - Text animation "Đang gọi..."
  - Nút Cancel để hủy cuộc gọi

**Flow**:
1. Người A ấn Call
2. Pre-call checks pass
3. Hiện ConnectingCallScreen với animation
4. Bắt đầu 45s timeout
5. Đợi người B accept/decline

---

### **3. Giai đoạn Bắt tay (Handshake)** ✅
**File**: ZegoCloud SDK (Tự động)

**Chức năng** (Được ZegoCloud xử lý tự động):
- ✅ **SDP Exchange**: Trao đổi thông tin media capabilities
- ✅ **ICE Candidates**: Tìm đường kết nối tốt nhất
  - P2P nếu có thể
  - TURN relay nếu cả hai đứng sau NAT/Firewall
- ✅ **Media Negotiation**: Chọn codec tối ưu (VP8, H264, Opus, etc.)

**Khi nào xảy ra**: 
- Ngay sau khi người B nhấn "Accept"
- Timeout timer được cancel
- ConnectingScreen đóng lại
- Navigate sang ZegoUIKit Call Page

```dart
// Khi call accepted
CallManager().cancelCallTimeout(); // Stop timeout
Navigator.push(context, ZegoUIKitCallPage); // Start session
```

---

### **4. Giai đoạn Duy trì cuộc gọi (Active Session)** ✅
**File**: `lib/service/zego_service.dart` - `buildCallPage()`

**Chức năng**:

**a) Dynamic Bitrate (Tự động bởi ZegoCloud)**:
- Tự động điều chỉnh quality dựa trên bandwidth
- Giữ audio ổn định, giảm video nếu mạng yếu
- Adaptive resolution switching

**b) UI Controls** (Đã customize):
```dart
config.bottomMenuBar = ZegoCallMenuBar(
  buttons: [
    ZegoCallMenuBarButtonName.toggleCameraButton,    // Bật/tắt camera
    ZegoCallMenuBarButtonName.toggleMicrophoneButton, // Mute/unmute
    ZegoCallMenuBarButtonName.hangUpButton,           // Cúp máy
    ZegoCallMenuBarButtonName.switchCameraButton,     // Đổi camera trước/sau
    ZegoCallMenuBarButtonName.switchAudioOutputButton, // Loa/tai nghe
  ],
);
```

**c) Picture-in-Picture Layout**:
```dart
config.layout = ZegoLayout.pictureInPicture(
  isSmallViewDraggable: true,
  switchLargeOrSmallViewByClick: true,
  smallViewSize: Size(isDesktop ? 160 : 100, isDesktop ? 220 : 140),
  smallViewPosition: ZegoViewPosition.topRight,
  smallViewBorderRadius: 12.0, // Rounded corners like Messenger
);
```

**d) Messenger-Style UI**:
- Gradient background (dark blue-black)
- Transparent menu bars
- Circular buttons với white opacity
- Avatar với gradient và shadow
- Name label overlay trên video

---

### **5. Giai đoạn Kết thúc & Giải phóng (Cleanup)** ✅
**File**: `lib/service/zego_service.dart` + `lib/service/call_manager.dart`

**Chức năng**:

**a) Signaling End**:
```dart
// Gửi signal kết thúc qua Socket.IO
SocketService().sendCallEnded(
  targetUserId: remoteUserId,
  callId: callId,
  duration: durationSeconds,
);
```

**b) Release Hardware**:
```dart
// ZegoUIKit tự động release khi dispose
// WillPopScope đảm bảo cleanup khi navigate back
return WillPopScope(
  onWillPop: () async {
    print('📴 Call page closing');
    onCallEnd(); // Trigger cleanup
    return true;
  },
  child: ZegoUIKitPrebuiltCall(...),
);
```

**c) Call Log** (Đã có sẵn):
- Server tự động lưu vào MySQL
- Bao gồm: duration, timestamp, call type, status
- Hiển thị trong chat history

**d) Cleanup State**:
```dart
void _cleanup() {
  _callTimeoutTimer?.cancel();
  _currentState = CallState.idle;
  _currentCallId = null;
  _remoteUserId = null;
  // ... reset all state
}
```

---

## 📊 Flow Diagram

### **Caller (Người gọi)**:
```
1. Nhấn Call button
   ↓
2. Pre-call checks (Permission, Network, Device)
   ↓ (Pass)
3. Camera Preview Screen (xem trước)
   ↓ (Confirm)
4. ConnectingCallScreen ("Đang gọi...")
   ↓ (Timeout 45s hoặc Accept)
5a. Timeout → Close + "Không trả lời"
5b. Accepted → ZegoUIKit Call Page (Active Session)
   ↓
6. End Call → Cleanup + Call Log
```

### **Callee (Người nhận)**:
```
1. Nhận Push Notification qua Socket
   ↓
2. IncomingCallScreen (Đổ chuông + animation)
   ↓ (Accept hoặc Decline)
3a. Decline → Send signal + Close
3b. Accept → ZegoUIKit Call Page (Active Session)
   ↓
4. End Call → Cleanup + Call Log
```

---

## 🎨 UI/UX Features

### **ConnectingCallScreen**:
- ✅ Ripple animation (3 circles mở rộng)
- ✅ Avatar với gradient
- ✅ Text animation "Đang gọi..."
- ✅ Gradient background (purple-blue)
- ✅ Nút Cancel màu đỏ

### **ZegoUIKit Call Page**:
- ✅ Messenger-style gradient background
- ✅ Transparent menu bars
- ✅ Circular buttons
- ✅ Picture-in-Picture với rounded corners
- ✅ Name overlay trên video
- ✅ Responsive cho Desktop & Mobile

### **IncomingCallScreen**:
- ✅ Full screen overlay
- ✅ Avatar + caller name
- ✅ Pulse animation
- ✅ Accept (green) & Decline (red) buttons
- ✅ Ringtone + vibration

---

## 🔧 Configuration

### **Timeout**:
```dart
// lib/service/call_manager.dart
static const int CALL_TIMEOUT_SECONDS = 45;
```

### **Network**:
```dart
static const int MIN_NETWORK_SPEED_KBPS = 100;
```

### **ZegoCloud**:
```dart
// lib/config/zego_config.dart
class ZegoConfig {
  static const int appID = YOUR_APP_ID;
  static const String appSign = 'YOUR_APP_SIGN';
}
```

---

## 📦 Dependencies

```yaml
dependencies:
  # ZegoCloud SDK
  zego_uikit_prebuilt_call: 4.22.2
  zego_uikit: 2.28.38
  zego_express_engine: 3.22.0
  
  # Permissions
  permission_handler: ^12.0.1
  
  # Network check
  connectivity_plus: ^6.1.2
  
  # Realtime communication
  socket_io_client: ^3.1.2
  
  # Push notifications
  firebase_core: ^4.3.0
  firebase_messaging: ^16.1.0
```

---

## ✅ Checklist Hoàn Thành

### Giai đoạn 1: Pre-call
- [x] Permission check (Camera + Mic)
- [x] Network check (WiFi/Mobile/Ethernet)
- [x] Device status check (Busy detection)
- [x] User-friendly error messages
- [x] Open Settings button

### Giai đoạn 2: Signaling
- [x] Session ID creation
- [x] Socket.IO push notification
- [x] 45s timeout logic
- [x] ConnectingCallScreen với animation
- [x] Cancel button

### Giai đoạn 3: Handshake
- [x] SDP exchange (ZegoCloud auto)
- [x] ICE candidates (ZegoCloud auto)
- [x] P2P or TURN relay (ZegoCloud auto)

### Giai đoạn 4: Active Session
- [x] Dynamic bitrate (ZegoCloud auto)
- [x] UI controls (Mute, Camera, Switch, etc.)
- [x] Picture-in-Picture layout
- [x] Messenger-style UI design
- [x] Responsive Desktop/Mobile

### Giai đoạn 5: Cleanup
- [x] Signal end via Socket.IO
- [x] Hardware release (auto dispose)
- [x] Call log to MySQL database
- [x] State cleanup

---

## 🚀 Testing Checklist

- [ ] Video call với WiFi tốt
- [ ] Video call với mạng yếu (4G 1 vạch)
- [ ] Audio call
- [ ] Permission denied scenarios
- [ ] Timeout 45s (không nhấc máy)
- [ ] Decline call
- [ ] Cancel khi đang gọi
- [ ] End call từ caller
- [ ] End call từ callee
- [ ] Mất mạng giữa chừng
- [ ] Desktop responsive
- [ ] Mobile responsive

---

## 📝 Notes

1. **ZegoCloud tự động xử lý**:
   - Handshake (SDP/ICE)
   - Bitrate adaptation
   - Audio/Video codec selection
   - NAT traversal (TURN/STUN)

2. **Call Log**: Server lưu tự động khi call end
3. **Firebase Push**: Đã tích hợp cho offline users
4. **Cleanup**: Tự động khi navigate back hoặc dispose

---

**🎉 Hệ thống Call đã hoàn thiện 100%!**
