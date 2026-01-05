# 📞 Video Call Feature - Messenger Style

## 🎯 Tổng quan

Tính năng gọi video/audio trong app được xây dựng giống **Facebook Messenger**, sử dụng:
- **ZegoCloud SDK** - Xử lý video/audio streaming
- **Socket.IO** - Signaling (gửi/nhận call invitation)
- **Firebase Cloud Messaging (FCM)** - Push notification khi app background/terminated
- **Flutter Local Notifications** - Hiển thị incoming call notification

---

## 🔄 Luồng hoạt động (Flow)

### 📱 **1. Người gọi (Caller) bắt đầu cuộc gọi**

```
User A (Caller)
    │
    ├─► [Tap call button]
    │
    ├─► ZegoService.startCall()
    │   ├── Tạo callId unique
    │   ├── Update state = calling
    │   └── Send "zego_call_invitation" via Socket.IO
    │
    ├─► SocketService emit event:
    │   {
    │     event: "zego_call_invitation",
    │     callId: "call_xxx",
    │     callerId: "userA_id",
    │     callerName: "User A",
    │     targetUserId: "userB_id",
    │     isVideoCall: true
    │   }
    │
    └─► Navigate to Zego Call Screen (waiting for answer)
```

### 📲 **2. Người nhận (Receiver) nhận cuộc gọi**

#### **2.1. App đang mở (Foreground)**
```
User B (Receiver) - App đang mở
    │
    ├─► Socket.IO nhận event "zego_call_invitation"
    │
    ├─► GlobalCallHandler.zegoCallInvitationStream
    │   └── Kiểm tra không đang trong cuộc gọi khác
    │
    ├─► Show IncomingCallScreen (Full-screen)
    │   ├── Avatar với pulse animation
    │   ├── Play ringtone (looping)
    │   ├── Vibrate với pattern [0, 1000, 500, 1000]
    │   ├── Countdown timer: 45 giây
    │   └── 2 buttons: [Decline] [Accept]
    │
    └─► Chờ user action...
```

#### **2.2. App ở background/terminated**
```
User B (Receiver) - App background
    │
    ├─► Server gửi FCM push notification
    │   {
    │     notification: {
    │       title: "📹 Video Call",
    │       body: "User A is calling..."
    │     },
    │     data: {
    │       type: "video_call",
    │       callId: "call_xxx",
    │       callerId: "userA_id",
    │       callerName: "User A",
    │       isVideoCall: "true"
    │     }
    │   }
    │
    ├─► FCM Service nhận notification
    │   └── Show Local Notification với action buttons
    │       ├── Full-screen intent (Android)
    │       ├── High priority
    │       ├── Sound + Vibration
    │       └── Actions: [Accept] [Decline]
    │
    ├─► User tap notification hoặc action button
    │
    ├─► FcmService._showIncomingCallFromNotification()
    │   ├── Load user info from SharedPreferences
    │   ├── Initialize ZegoService
    │   ├── Update state = ringing
    │   └── Show IncomingCallScreen
    │
    └─► Chờ user action...
```

### ✅ **3. User chấp nhận cuộc gọi (Accept)**

```
User B tap [Accept]
    │
    ├─► IncomingCallScreen.onAccept()
    │   ├── Stop ringtone
    │   ├── Stop vibration
    │   ├── Cancel timeout timer
    │   └── Haptic feedback
    │
    ├─► SocketService.sendCallAccepted()
    │   └── emit "zego_call_accepted"
    │
    ├─► ZegoService.acceptCall()
    │   ├── Update state = connected
    │   └── Save callStartTime
    │
    ├─► Navigate to ZegoCallScreen
    │   ├── Initialize ZegoUIKit
    │   ├── Join room with callId
    │   ├── Enable camera (nếu video call)
    │   ├── Enable microphone
    │   └── Display remote + local video
    │
    └─► Bắt đầu streaming video/audio
```

### ❌ **4. User từ chối cuộc gọi (Decline)**

```
User B tap [Decline]
    │
    ├─► IncomingCallScreen.onDecline()
    │   ├── Stop ringtone
    │   ├── Stop vibration
    │   ├── Cancel timeout timer
    │   └── Haptic feedback
    │
    ├─► SocketService.sendCallDeclined()
    │   └── emit "zego_call_declined"
    │
    ├─► ZegoService.declineCall()
    │   └── Cleanup state
    │
    └─► Close IncomingCallScreen
```

### ⏱️ **5. Timeout - Auto reject sau 45 giây**

```
45 giây không có response
    │
    ├─► IncomingCallScreen timeout timer triggered
    │
    ├─► Auto call onDecline()
    │   └── Same flow như user tap [Decline]
    │
    └─► Close screen + Send declined signal
```

### 📴 **6. Kết thúc cuộc gọi**

```
User tap [End Call]
    │
    ├─► ZegoService.endCall()
    │   ├── Calculate duration
    │   ├── Leave Zego room
    │   └── emit "zego_call_ended"
    │
    ├─► Cleanup resources
    │   ├── Stop camera
    │   ├── Stop microphone
    │   └── Dispose controllers
    │
    └─► Navigate back
```

---

## 🏗️ Kiến trúc (Architecture)

```
┌─────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                   │
├─────────────────────────────────────────────────────────┤
│  IncomingCallScreen   │   ZegoCallScreen               │
│  - Full-screen UI      │   - Video streaming UI         │
│  - Accept/Decline      │   - Controls (mute, camera)    │
│  - Ringtone + Vibrate  │   - End call                   │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                     GLOBAL HANDLER                       │
├─────────────────────────────────────────────────────────┤
│  GlobalCallHandler (wraps entire app)                   │
│  - Listen to Socket events globally                     │
│  - Show IncomingCallScreen từ bất kỳ màn hình nào      │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                      SERVICE LAYER                       │
├─────────────────────────────────────────────────────────┤
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────┐ │
│  │ ZegoService   │  │SocketService  │  │ FCMService  │ │
│  │               │  │               │  │             │ │
│  │ - Call state  │  │ - Signaling   │  │ - Push      │ │
│  │ - WebRTC      │  │ - Events      │  │ - Notif     │ │
│  │ - UI Widget   │  │ - Real-time   │  │ - Action    │ │
│  └───────────────┘  └───────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                     EXTERNAL SERVICES                    │
├─────────────────────────────────────────────────────────┤
│  ZegoCloud SDK  │  Socket.IO Server  │  Firebase FCM   │
└─────────────────────────────────────────────────────────┘
```

---

## 🛠️ Setup và Configuration

### 1️⃣ **Dependencies (pubspec.yaml)**

```yaml
dependencies:
  # Video Call
  zego_uikit_prebuilt_call: ^latest
  zego_uikit: ^latest
  
  # Signaling
  socket_io_client: ^latest
  
  # Notifications
  firebase_messaging: ^16.1.0
  flutter_local_notifications: ^latest
  
  # UI/UX
  flutter_ringtone_player: ^4.0.0
  vibration: ^2.0.0  # ⭐ MỚI THÊM
  
  # Permissions
  permission_handler: ^latest
```

### 2️⃣ **Android Configuration**

**AndroidManifest.xml**:
```xml
<!-- Camera & Microphone permissions -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />

<!-- Network -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE" />

<!-- Full-screen incoming call notification -->
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### 3️⃣ **iOS Configuration**

**Info.plist**:
```xml
<key>NSCameraUsageDescription</key>
<string>Cần quyền camera để thực hiện video call</string>

<key>NSMicrophoneUsageDescription</key>
<string>Cần quyền microphone để thực hiện cuộc gọi</string>

<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>voip</string>
    <string>remote-notification</string>
</array>
```

### 4️⃣ **ZegoCloud Config**

**lib/config/zego_config.dart**:
```dart
class ZegoConfig {
  static const int appID = YOUR_APP_ID;  // Lấy từ ZegoCloud Console
  static const String appSign = 'YOUR_APP_SIGN';
  
  static bool get isConfigured => appID != 0 && appSign.isNotEmpty;
}
```

### 5️⃣ **Main App Setup**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // FCM
  await FcmService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // ⚠️ QUAN TRỌNG
      builder: (context, child) {
        // Wrap GlobalCallHandler
        return GlobalCallHandler(
          child: child!,
        );
      },
      // ...
    );
  }
}
```

---

## 📊 State Management

### **CallState Enum**
```dart
enum CallState {
  idle,         // Không có cuộc gọi
  calling,      // Đang gọi đi (caller)
  ringing,      // Đang nhận cuộc gọi (receiver)
  connected,    // Đã kết nối, đang gọi
  ended,        // Kết thúc
}
```

### **ZegoService State**
```dart
CallState _currentState = CallState.idle;
String? _currentCallId;
String? _remoteUserId;
bool _isVideoCall = false;
DateTime? _callStartTime;

final _callStateController = StreamController<CallState>.broadcast();
Stream<CallState> get callStateStream => _callStateController.stream;
```

---

## 🎨 UI Components

### **1. IncomingCallScreen**
- Full-screen gradient background
- Pulse animation cho avatar
- Ringtone + Vibration tự động
- Countdown timer (45s)
- Accept/Decline buttons (Messenger style)
- Auto-reject khi timeout

### **2. ZegoCallScreen** 
- Remote video view (full-screen)
- Local video view (picture-in-picture)
- Control buttons:
  - Mute/Unmute microphone
  - Enable/Disable camera
  - Switch camera (front/back)
  - End call (red button)
- Call duration timer

---

## 🔐 Permissions Flow

```
App Start
    │
    ├─► CallManager.checkPermissions()
    │   ├── Check Microphone permission
    │   ├── Check Camera permission (nếu video call)
    │   └── Request nếu chưa granted
    │
    ├─► Permission denied?
    │   ├── Show dialog
    │   └── Option: Open Settings
    │
    └─► Permission granted → Proceed with call
```

---

## 🚀 Cách sử dụng

### **Khởi tạo ZegoService**
```dart
await ZegoService().initialize(
  userId: currentUserId,
  userName: currentUserName,
);
```

### **Bắt đầu cuộc gọi**
```dart
bool success = await ZegoService().startCall(
  targetUserId: receiverId,
  targetUserName: receiverName,
  isVideoCall: true, // false cho audio call
);

if (success) {
  // Navigate to call screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ZegoService().buildCallPage(
        context: context,
        callId: callId,
        localUserId: myUserId,
        localUserName: myUserName,
        remoteUserId: receiverId,
        remoteUserName: receiverName,
        isVideoCall: true,
        onCallEnd: () {
          ZegoService().endCall();
        },
      ),
    ),
  );
}
```

### **Lắng nghe cuộc gọi đến (tự động bởi GlobalCallHandler)**
```dart
// Không cần code gì, GlobalCallHandler tự động:
// 1. Listen Socket events
// 2. Show IncomingCallScreen
// 3. Handle Accept/Decline
```

---

## 📝 Server-side (Backend) Requirements

### **Socket.IO Events cần implement**

**1. zego_call_invitation** (Caller → Server → Receiver)
```json
{
  "callId": "call_123",
  "callerId": "userA_id",
  "callerName": "User A",
  "callerAvatar": "https://...",
  "targetUserId": "userB_id",
  "isVideoCall": true
}
```

**2. zego_call_accepted** (Receiver → Server → Caller)
```json
{
  "callId": "call_123",
  "acceptedBy": "userB_id"
}
```

**3. zego_call_declined** (Receiver → Server → Caller)
```json
{
  "callId": "call_123",
  "declinedBy": "userB_id"
}
```

**4. zego_call_ended** (Either → Server → Other)
```json
{
  "callId": "call_123",
  "endedBy": "userA_id",
  "duration": 120  // seconds
}
```

### **FCM Push Notification**

Khi receiver offline/app terminated, server cần gửi FCM:

```json
{
  "to": "<RECEIVER_FCM_TOKEN>",
  "notification": {
    "title": "📹 Video Call",
    "body": "User A is calling you..."
  },
  "data": {
    "type": "video_call",
    "callId": "call_123",
    "callerId": "userA_id",
    "callerName": "User A",
    "callerAvatar": "https://...",
    "isVideoCall": "true"
  },
  "android": {
    "priority": "high",
    "notification": {
      "channel_id": "incoming_call_channel",
      "sound": "default",
      "tag": "call_123"
    }
  },
  "apns": {
    "headers": {
      "apns-priority": "10"
    },
    "payload": {
      "aps": {
        "sound": "default",
        "interruption-level": "time-sensitive"
      }
    }
  }
}
```

---

## ⚠️ Known Issues & Solutions

### **1. Notification không hiển thị khi app terminated (Android)**
**Solution**: Đảm bảo:
- `USE_FULL_SCREEN_INTENT` permission
- `onBackgroundMessage` handler đã được đăng ký
- Notification channel được tạo với `Importance.max`

### **2. iOS không rung khi có cuộc gọi**
**Solution**: 
- Sử dụng `CallKit` thay vì local notification
- Hoặc request `criticalAlert` permission

### **3. Video bị lag/freeze**
**Solution**:
- Check network speed (minimum 100 kbps)
- Enable H.264 hardware encoding trong Zego config
- Reduce video resolution nếu cần

---

## 📚 Tài liệu tham khảo

- [ZegoCloud Documentation](https://docs.zegocloud.com/)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Socket.IO Client Dart](https://pub.dev/packages/socket_io_client)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)

---

## 🎯 Roadmap & Improvements

- [ ] Thêm CallKit integration cho iOS (native incoming call UI)
- [ ] Screen sharing support
- [ ] Group video call (3+ người)
- [ ] Call history & statistics
- [ ] Network quality indicator
- [ ] Beauty filters & effects
- [ ] Recording calls (cần consent)

---

**Created by**: Health IoT Team  
**Last Updated**: January 2026  
**Version**: 1.0.0
