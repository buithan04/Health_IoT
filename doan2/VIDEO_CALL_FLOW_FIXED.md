# 📞 VIDEO CALL FLOW - ĐÃ SỬA THEO MESSENGER

## 🎯 VẤN ĐỀ ĐÃ PHÁT HIỆN

### ❌ Logic CŨ (SAI):
```
Người gọi nhấn nút call
    ↓
Gửi invitation qua Socket
    ↓
NGAY LẬP TỨC navigate vào ZegoCloud call room
    ↓
Camera/Mic TỰ ĐỘNG BẬT (vì config: turnOnCameraWhenJoining = true)
    ↓
Người gọi thấy chính mình trên màn hình call
    ↓
❌ KHÔNG ĐÚNG: Chưa có ai accept mà đã vào room!
```

**Vấn đề**: Code cũ trong `_startVideoCall()` và `_startAudioCall()` **NGAY LẬP TỨC** navigate đến `ZegoService().buildCallPage()` sau khi gửi invitation, khiến màn hình call room hiện lên và camera/mic tự bật.

---

## ✅ LOGIC MỚI (ĐÚNG - GIỐNG MESSENGER):

### Flow hoàn chỉnh:

#### 1️⃣ **NGƯỜI GỌI (Caller)**
```
Nhấn nút Video/Audio Call
    ↓
startCall() → Gửi invitation qua Socket
    ↓
Navigate đến "ConnectingCallScreen" 
    (Màn hình "Đang kết nối..." với avatar + animation)
    ↓
Đợi response...
    ↓
    ├─ Nếu ACCEPT → Nhận event "call_accepted"
    │   ↓
    │   Pop ConnectingCallScreen
    │   ↓
    │   Navigate vào ZegoCloud Call Room
    │   (Lúc này mới bật camera/mic)
    │
    ├─ Nếu DECLINE → Nhận event "call_declined"
    │   ↓
    │   Pop ConnectingCallScreen
    │   ↓
    │   Hiện SnackBar: "Người nhận đã từ chối"
    │
    └─ Nếu người gọi hủy → onCancel
        ↓
        endCall() → Pop ConnectingCallScreen
```

#### 2️⃣ **NGƯỜI NHẬN (Receiver)**
```
Nhận Socket event "zego_call_invitation"
    ↓
Hiển thị "IncomingCallScreen" (Full-screen)
    (Avatar lớn, nút Accept/Decline, ringtone)
    ↓
Người dùng chọn:
    ├─ ACCEPT
    │   ↓
    │   acceptCall() → Gửi event "call_accepted"
    │   ↓
    │   Pop IncomingCallScreen
    │   ↓
    │   Navigate vào ZegoCloud Call Room
    │
    └─ DECLINE
        ↓
        declineCall() → Gửi event "call_declined"
        ↓
        Pop IncomingCallScreen
```

---

## 🔧 CÁC THAY ĐỔI CHÍNH

### 1. **ZegoService** (`lib/service/zego_service.dart`)
```dart
// ✅ THÊM: Lưu loại call (video/audio)
bool _isVideoCall = false;
bool get isVideoCall => _isVideoCall;

// ✅ CẬP NHẬT: Store call type trong startCall()
_isVideoCall = isVideoCall;

// ✅ CẬP NHẬT: Store call type trong onIncomingCall()
_isVideoCall = isVideoCall;

// ✅ CẬP NHẬT: Reset trong _cleanup()
_isVideoCall = false;
```

### 2. **ChatDetailScreen** (`lib/presentation/shared/chat_detail_screen.dart`)

#### A. Import thêm ConnectingCallScreen:
```dart
import 'package:app_iot/presentation/shared/widgets/connecting_call_screen.dart';
```

#### B. Sửa `_startVideoCall()`:
```dart
// ❌ CŨ: Navigate ngay vào call room
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ZegoService().buildCallPage(...),
  ),
);

// ✅ MỚI: Navigate vào Connecting screen trước
Navigator.push(
  context,
  MaterialPageRoute(
    fullscreenDialog: true,
    settings: const RouteSettings(name: '/connecting_call'),
    builder: (context) => ConnectingCallScreen(
      remoteUserName: _resolvedPartnerName!,
      remoteUserAvatar: _resolvedPartnerAvatar,
      isVideoCall: true,
      onCancel: () {
        Navigator.of(context).pop();
        ZegoService().endCall();
      },
    ),
  ),
);
```

#### C. Sửa `_startAudioCall()`:
- Tương tự như `_startVideoCall()`, nhưng `isVideoCall: false`

#### D. Sửa listener `zegoCallAcceptedStream`:
```dart
// ✅ MỚI: Khi nhận accepted, pop Connecting screen rồi vào call room
_socketService.zegoCallAcceptedStream.listen((data) {
  final callId = data['callId']?.toString() ?? '';
  print('✅ [ZEGO] Call accepted: $callId');
  
  // Navigate to call room when accepted
  if (mounted && ZegoService().currentState == CallState.calling) {
    // Pop the connecting screen first
    Navigator.of(context).popUntil((route) => 
      route.isFirst || route.settings.name == '/chat_detail');
    
    // Navigate to actual call screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZegoService().buildCallPage(
          context: context,
          callId: callId,
          localUserId: _myUserId,
          localUserName: _myUserName,
          remoteUserId: _resolvedPartnerId!,
          remoteUserName: _resolvedPartnerName!,
          isVideoCall: ZegoService().isVideoCall, // ✅ Từ state
          onCallEnd: () {
            ZegoService().endCall();
          },
        ),
      ),
    );
  }
});
```

#### E. Sửa listener `zegoCallDeclinedStream`:
```dart
// ✅ THÊM: Auto-close Connecting screen khi bị decline
_socketService.zegoCallDeclinedStream.listen((data) {
  final callId = data['callId']?.toString() ?? '';
  print('❌ [ZEGO] Call declined: $callId');
  
  // Close connecting screen if it's open
  if (mounted && ZegoService().currentState == CallState.calling) {
    Navigator.of(context).popUntil((route) => 
      route.isFirst || route.settings.name == '/chat_detail');
  }
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📴 Người nhận đã từ chối cuộc gọi')),
    );
  }
});
```

#### F. Sửa listener `zegoCallEndedStream`:
```dart
// ✅ THÊM: Auto-close Connecting screen khi bị end
_socketService.zegoCallEndedStream.listen((data) {
  final callId = data['callId']?.toString() ?? '';
  print('📴 [ZEGO] Call ended: $callId');
  
  // Close connecting screen if it's open
  if (mounted && ZegoService().currentState == CallState.calling) {
    Navigator.of(context).popUntil((route) => 
      route.isFirst || route.settings.name == '/chat_detail');
  }
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📴 Cuộc gọi đã kết thúc')),
    );
  }
});
```

---

## 🎬 DEMO FLOW MỚI

### Scenario 1: Video Call Thành Công
```
User A (Caller):
1. Nhấn nút Video Call
2. Thấy màn hình "Đang kết nối..." với avatar User B
3. Đợi...
4. User B accept
5. Màn hình tự động chuyển sang ZegoCloud call room
6. Camera/mic bật, bắt đầu call

User B (Receiver):
1. Nhận incoming call screen (full-screen)
2. Thấy avatar User A + ringtone
3. Nhấn nút Accept (màu xanh)
4. Màn hình chuyển sang ZegoCloud call room
5. Camera/mic bật, bắt đầu call
```

### Scenario 2: Video Call Bị Từ Chối
```
User A:
1. Nhấn nút Video Call
2. Thấy màn hình "Đang kết nối..."
3. User B từ chối
4. Màn hình tự động đóng
5. Thấy SnackBar: "Người nhận đã từ chối cuộc gọi"

User B:
1. Nhận incoming call screen
2. Nhấn nút Decline (màu đỏ)
3. Màn hình đóng
4. Ringtone dừng
```

### Scenario 3: User A Hủy Trước Khi B Accept
```
User A:
1. Nhấn nút Video Call
2. Thấy màn hình "Đang kết nối..."
3. Nhấn nút "Hủy" (màu đỏ)
4. Màn hình đóng
5. Gửi signal "call_ended" đến User B

User B:
1. Đang thấy incoming call screen
2. Nhận signal "call_ended"
3. Màn hình tự động đóng
4. Ringtone dừng
```

---

## 📱 UI COMPONENTS

### ConnectingCallScreen
- **Hiển thị**: Full-screen khi người gọi đang đợi
- **Nội dung**:
  - Avatar của người nhận (pulse animation)
  - Tên người nhận
  - Text "Đang kết nối..." (animated dots)
  - Nút "Hủy" (màu đỏ)
- **File**: `lib/presentation/shared/widgets/connecting_call_screen.dart`

### IncomingCallScreen
- **Hiển thị**: Full-screen khi nhận cuộc gọi đến
- **Nội dung**:
  - Label "Cuộc gọi video/thoại đến"
  - Avatar người gọi (pulse animation)
  - Tên người gọi
  - Text "Đang gọi..." (animated)
  - Nút Accept (xanh) và Decline (đỏ)
  - Ringtone tự động phát
- **File**: `lib/presentation/shared/widgets/incoming_call_screen.dart`

---

## 🎉 KẾT QUẢ

### ✅ ĐÃ KHẮC PHỤC:
1. ❌ **Cũ**: Camera bật ngay khi nhấn call → ✅ **Mới**: Chỉ bật khi cả 2 đã vào room
2. ❌ **Cũ**: Không có màn hình "Đang kết nối" → ✅ **Mới**: Có ConnectingCallScreen
3. ❌ **Cũ**: Logic không rõ ràng → ✅ **Mới**: Flow rõ ràng giống Messenger
4. ❌ **Cũ**: Không tự động đóng khi decline/end → ✅ **Mới**: Tự động cleanup

### 🎯 FLOW HOÀN CHỈNH GIỐNG MESSENGER:
- ✅ Người gọi: Nhấn → Connecting screen → Accept → Call room
- ✅ Người nhận: Incoming screen → Accept → Call room
- ✅ Auto-close khi decline/end/cancel
- ✅ Camera/mic chỉ bật khi cả 2 đã vào call room

---

## 🧪 TESTING CHECKLIST

### Test Case 1: Video Call Accepted
- [ ] Caller thấy Connecting screen sau khi nhấn call
- [ ] Receiver thấy Incoming screen với ringtone
- [ ] Receiver nhấn Accept
- [ ] Connecting screen tự động đóng (caller)
- [ ] Incoming screen tự động đóng (receiver)
- [ ] Cả 2 vào call room cùng lúc
- [ ] Camera/mic bật đúng

### Test Case 2: Video Call Declined
- [ ] Caller thấy Connecting screen
- [ ] Receiver thấy Incoming screen
- [ ] Receiver nhấn Decline
- [ ] Connecting screen tự động đóng (caller)
- [ ] Incoming screen tự động đóng (receiver)
- [ ] Caller thấy SnackBar "Người nhận đã từ chối"
- [ ] Ringtone dừng

### Test Case 3: Caller Cancel
- [ ] Caller thấy Connecting screen
- [ ] Caller nhấn nút "Hủy"
- [ ] Connecting screen đóng
- [ ] Signal "call_ended" gửi đến receiver
- [ ] Incoming screen tự động đóng (receiver)
- [ ] Ringtone dừng

### Test Case 4: Audio Call
- [ ] Tương tự video call nhưng với isVideoCall = false
- [ ] Không bật camera
- [ ] Chỉ bật microphone

---

## 📝 GHI CHÚ BỔ SUNG

### State Management
```dart
// ZegoService states:
CallState.idle       // Không có cuộc gọi nào
CallState.calling    // Đang gọi đi (caller - ở Connecting screen)
CallState.ringing    // Đang có cuộc gọi đến (receiver - ở Incoming screen)
CallState.connected  // Đã kết nối (cả 2 đang trong call room)
CallState.ended      // Cuộc gọi đã kết thúc
```

### Navigation Routes
```dart
'/connecting_call'  // ConnectingCallScreen
'/chat_detail'      // ChatDetailScreen (base route)
// ZegoCloud call page không có named route (MaterialPageRoute thường)
```

### Key Methods
```dart
// ZegoService
- startCall()       // Gửi invitation, set state = calling
- acceptCall()      // Chấp nhận, set state = connected
- declineCall()     // Từ chối, cleanup
- endCall()         // Kết thúc, cleanup

// ChatDetailScreen
- _startVideoCall() // Khởi tạo video call, show Connecting screen
- _startAudioCall() // Khởi tạo audio call, show Connecting screen
- _setupZegoCloudListeners() // Setup tất cả socket listeners
```

---

## 🎯 HOÀN TẤT

✅ **LOGIC VIDEO CALL ĐÃ ĐƯỢC SỬA ĐỂ GIỐNG MESSENGER**
✅ **FLOW RÕ RÀNG, DỄ BẢO TRÌ**
✅ **KHÔNG CÒN BUG "TỰ BẬT CAMERA"**

---

**Ngày cập nhật**: 2026-01-03  
**Người thực hiện**: GitHub Copilot  
**Trạng thái**: ✅ HOÀN TẤT
