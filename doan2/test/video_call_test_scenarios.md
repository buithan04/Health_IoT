# Video Call Test Scenarios & Messenger Comparison

## 📋 Test Date: January 3, 2026
## 🎯 Objective: Test video call between Mobile App and Windows, identify issues, improve to Messenger-like quality

---

## 1. TEST SETUP

### Equipment Needed
- **Device A**: Android/iOS mobile device (Caller)
- **Device B**: Windows PC (Receiver)
- **Network**: Both devices on same WiFi OR connected via internet
- **Accounts**: 2 different user accounts logged in

### Pre-Test Checklist
- [ ] Both devices have camera/microphone permissions enabled
- [ ] Both devices logged in with different accounts
- [ ] Internet connection stable (>2 Mbps recommended)
- [ ] App version same on both devices
- [ ] Socket.IO server running and reachable
- [ ] TURN/STUN servers configured properly

---

## 2. TEST SCENARIOS

### 📞 Scenario 1: Basic Call Flow (Mobile → Windows)
**Steps:**
1. **Mobile (Caller)**: Open chat with Windows user
2. **Mobile**: Tap video call button
3. **Windows (Receiver)**: Incoming call dialog appears
4. **Windows**: Accept call
5. **Both**: Video/audio should connect
6. **Mobile**: End call

**Expected Results:**
- ✅ Call connects within 3-5 seconds
- ✅ Video displays with correct aspect ratio (1280x720, 16:9)
- ✅ Audio clear with no echo
- ✅ Both users can see each other
- ✅ PiP local video shows on both devices
- ✅ Call ends cleanly on both sides

**Test Results:** ⬜ PASS  ⬜ FAIL

**Issues Found:**
```
[Write any issues here during testing]
```

---

### 📞 Scenario 2: Call Flow Reverse (Windows → Mobile)
**Steps:**
1. **Windows (Caller)**: Open chat with mobile user
2. **Windows**: Initiate video call
3. **Mobile (Receiver)**: Incoming call notification appears
4. **Mobile**: Accept call
5. **Both**: Video/audio connects
6. **Windows**: End call

**Expected Results:** (Same as Scenario 1)

**Test Results:** ⬜ PASS  ⬜ FAIL

**Issues Found:**
```
[Write any issues here]
```

---

### 🚫 Scenario 3: Call Rejection
**Steps:**
1. **Mobile**: Call Windows user
2. **Windows**: Reject incoming call
3. **Mobile**: Should receive rejection notification

**Expected Results:**
- ✅ Rejection happens instantly
- ✅ Caller receives clear feedback
- ✅ No hanging connections
- ✅ Both devices return to normal state

**Test Results:** ⬜ PASS  ⬜ FAIL

---

### ⏱️ Scenario 4: Call Timeout (No Answer)
**Steps:**
1. **Mobile**: Call Windows user
2. **Windows**: Do NOT answer (wait 30 seconds)
3. **Mobile**: Call should auto-cancel

**Expected Results:**
- ✅ Call auto-cancels after 30 seconds
- ✅ Both sides clean up properly
- ✅ Caller sees "No answer" message

**Test Results:** ⬜ PASS  ⬜ FAIL

---

### 🔄 Scenario 5: Network Interruption
**Steps:**
1. **Both**: Start a call successfully
2. **Mobile**: Turn WiFi off for 5 seconds
3. **Mobile**: Turn WiFi back on
4. **Both**: Check if call reconnects

**Expected Results:**
- ✅ Connection quality indicator shows poor
- ⚠️ Call may drop (acceptable)
- ✅ Clean disconnect notification
- ✅ No app crash

**Test Results:** ⬜ PASS  ⬜ FAIL

---

### 🎥 Scenario 6: Camera Toggle During Call
**Steps:**
1. **Both**: Start a call
2. **Mobile**: Tap camera off button
3. **Windows**: Should see "Camera off" state
4. **Mobile**: Tap camera on again
5. **Windows**: Video resumes

**Expected Results:**
- ✅ Camera toggles smoothly
- ✅ Remote user sees black screen with icon
- ✅ Video resumes without reconnection
- ✅ No audio interruption

**Test Results:** ⬜ PASS  ⬜ FAIL

---

### 🔇 Scenario 7: Microphone Mute During Call
**Steps:**
1. **Both**: Start a call
2. **Windows**: Mute microphone
3. **Mobile**: Should not hear Windows user
4. **Windows**: Unmute
5. **Mobile**: Audio resumes

**Expected Results:**
- ✅ Mute works instantly
- ✅ Clear UI indication of mute state
- ✅ Audio resumes smoothly
- ✅ No video interruption

**Test Results:** ⬜ PASS  ⬜ FAIL

---

### 📱 Scenario 8: App Backgrounding (Mobile)
**Steps:**
1. **Both**: Start a call
2. **Mobile**: Press home button (app to background)
3. **Wait 5 seconds**
4. **Mobile**: Return to app

**Expected Results:**
- ✅ Call continues in background (audio only OK)
- ✅ Notification shows "Call in progress"
- ✅ Video resumes when app returns
- OR
- ✅ Call ends gracefully with notification

**Test Results:** ⬜ PASS  ⬜ FAIL

---

### 💬 Scenario 9: Simultaneous Call Attempt
**Steps:**
1. **Mobile**: Call Windows user
2. **Windows**: (While ringing) Call Mobile user back
3. **Observe behavior**

**Expected Results:**
- ✅ Second call blocked with "User busy" message
- ✅ First call continues normally
- ✅ No crash or double-call state

**Test Results:** ⬜ PASS  ⬜ FAIL

---

### 🖼️ Scenario 10: PiP Local Video
**Steps:**
1. **Both**: Start a call
2. **Check local PiP video on both devices**
3. **Tap PiP to check interactions**

**Expected Results:**
- ✅ PiP shows in top-right corner
- ✅ Size is 120x68 with clear borders
- ✅ Shows "Bạn" label
- ✅ Video is clear and not distorted
- ✅ Can see own video feed

**Test Results:** ⬜ PASS  ⬜ FAIL

---

## 3. PERFORMANCE METRICS

### Connection Time
- **Target**: < 3 seconds from answer to video visible
- **Measured**: ___ seconds
- **Result**: ⬜ PASS  ⬜ FAIL

### Video Quality
- **Resolution**: Should be 1280x720 (16:9)
- **FPS**: Should be 24-30 fps (smooth)
- **Measured Resolution**: ___________
- **Measured FPS**: ___________
- **Result**: ⬜ PASS  ⬜ FAIL

### Audio Quality
- **Latency**: < 200ms
- **Echo**: None
- **Clarity**: Clear speech
- **Result**: ⬜ PASS  ⬜ FAIL

### UI Responsiveness
- **Controls Auto-hide**: 3 seconds after tap
- **Animation Smoothness**: No stuttering
- **Result**: ⬜ PASS  ⬜ FAIL

---

## 4. MESSENGER COMPARISON & ANALYSIS

### 🎯 Messenger's Call Flow (Reference)

#### Caller Side (Messenger):
```
1. Tap call button → Immediate UI response (< 100ms)
2. Show "Calling..." screen with ringing animation
3. If answered:
   - Video appears within 1-2 seconds
   - Smooth fade-in transition
   - Connection indicator (top bar)
4. If no answer after 60 seconds:
   - Auto-cancel with "No answer" message
   - Option to "Call Again" or "Send Message"
```

#### Receiver Side (Messenger):
```
1. Incoming call → Full-screen overlay immediately
2. Shows caller photo, name, "Video Calling..."
3. Ring sound + vibration
4. Large Accept/Decline buttons
5. If accepted:
   - Video connects within 2 seconds
   - Smooth transition from incoming screen to call screen
```

#### During Call (Messenger):
```
- Controls auto-hide after 3 seconds
- Tap screen → Controls slide up from bottom
- PiP video:
  * Can drag to any corner
  * Tap to switch cameras (mobile)
  * Rounded corners with subtle shadow
- Connection quality:
  * Top bar shows signal strength
  * Auto adjusts quality on poor connection
  * Shows "Poor connection" warning
- End call:
  * Red button, center bottom
  * Confirmation not needed
  * Clean disconnect
```

---

## 5. CURRENT IMPLEMENTATION vs MESSENGER

### ✅ What We Have (Good):
1. **Auto-hide controls** - 3 seconds ✅
2. **PiP local video** - Top-right corner ✅
3. **Connection indicator** - Color-coded badge ✅
4. **Pulse animations** - Avatar during connecting ✅
5. **Smooth transitions** - AnimatedOpacity, AnimatedPositioned ✅
6. **Standard resolution** - 1280x720 (16:9) ✅
7. **Ripple button effects** - Material InkWell ✅

### ⚠️ What Needs Improvement:

#### 1. **Call Timeout Logic** 🔴 CRITICAL
- **Issue**: No automatic timeout for unanswered calls
- **Messenger**: Auto-cancels after 60 seconds
- **Fix Needed**: Add timer in `makeCall()`, cancel if no answer

#### 2. **Busy State Handling** 🔴 CRITICAL
- **Issue**: Doesn't handle "user already in call" scenario
- **Messenger**: Shows "User is busy" and blocks second call
- **Fix Needed**: Add `isBusy` state check before allowing call

#### 3. **Reconnection Logic** 🟠 HIGH
- **Issue**: No automatic reconnection on network hiccup
- **Messenger**: Attempts to reconnect for 10-15 seconds
- **Fix Needed**: Add ICE reconnection logic

#### 4. **Incoming Call Sound** 🟠 HIGH
- **Issue**: Silent incoming calls (users might miss)
- **Messenger**: Plays ringtone + vibration
- **Fix Needed**: Add ringtone asset and play on incoming call

#### 5. **Background Call Handling** 🟠 HIGH
- **Issue**: App might crash or end call when backgrounded
- **Messenger**: Continues call in background (audio only)
- **Fix Needed**: Add lifecycle handling for background state

#### 6. **Draggable PiP** 🟡 MEDIUM
- **Issue**: PiP is fixed at top-right
- **Messenger**: PiP can be dragged to any corner
- **Fix Needed**: Add GestureDetector for drag functionality

#### 7. **Camera Switch** 🟡 MEDIUM
- **Issue**: No front/back camera toggle on mobile
- **Messenger**: Tap PiP to switch cameras
- **Fix Needed**: Add camera switch button/gesture

#### 8. **Call History/Logs** 🟢 LOW
- **Issue**: No record of missed/completed calls
- **Messenger**: Shows call history in chat
- **Fix Needed**: Save call logs to database

#### 9. **Video Quality Auto-Adjust** 🟢 LOW
- **Issue**: Fixed quality, may lag on poor connection
- **Messenger**: Auto reduces quality on poor network
- **Fix Needed**: Implement adaptive bitrate

---

## 6. RECOMMENDED FIXES (Priority Order)

### 🔴 CRITICAL (Do First):

#### Fix 1: Call Timeout Logic
**File**: `webrtc_service.dart`
**Add to `startCall()` method:**
```dart
// Add timeout timer
Timer? _callTimeoutTimer;

// In startCall():
_callTimeoutTimer = Timer(Duration(seconds: 60), () {
  if (_callStateController.value != CallState.connected) {
    print('⏱️ [WebRTC] Call timeout - no answer after 60 seconds');
    endCall();
    // Show UI notification
    _callStateController.add(CallState.timeout);
  }
});

// Cancel timer on answer in handleAnswer():
_callTimeoutTimer?.cancel();
```

#### Fix 2: Busy State Check
**File**: `webrtc_service.dart`
**Add to beginning of `startCall()` and `acceptCall()`:**
```dart
// Check if remote user is busy
Future<bool> _isUserBusy(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('${_apiClient.baseUrl}/call/status/$userId')
    );
    return json.decode(response.body)['isBusy'] ?? false;
  } catch (e) {
    return false; // Assume not busy on error
  }
}

// In startCall():
bool remoteBusy = await _isUserBusy(remoteUserId);
if (remoteBusy) {
  print('⚠️ [WebRTC] User is busy');
  _callStateController.add(CallState.busy);
  return false;
}
```

**Backend needed**: Add endpoint `GET /call/status/:userId`

#### Fix 3: Incoming Call Ringtone
**File**: `global_call_listener.dart`
**Add to `_showGlobalIncomingCallDialog()`:**
```dart
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

final AudioPlayer _ringtonePlayer = AudioPlayer();

void _playIncomingCallRingtone() async {
  await _ringtonePlayer.setSource(AssetSource('audio/incoming_call.mp3'));
  await _ringtonePlayer.setReleaseMode(ReleaseMode.loop);
  await _ringtonePlayer.resume();
  
  // Vibrate pattern
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(pattern: [0, 500, 200, 500], repeat: 0);
  }
}

void _stopIncomingCallRingtone() {
  _ringtonePlayer.stop();
  Vibration.cancel();
}

// Call _playIncomingCallRingtone() when showing dialog
// Call _stopIncomingCallRingtone() on accept/reject
```

**Dependencies needed**: 
```yaml
audioplayers: ^5.2.1
vibration: ^1.8.4
```

---

### 🟠 HIGH PRIORITY:

#### Fix 4: ICE Reconnection
**File**: `webrtc_service.dart`
**Add to `_createPeerConnection()`:**
```dart
_peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
  print('🧊 ICE Connection State: $state');
  
  if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
    print('⚠️ [WebRTC] Connection lost, attempting to reconnect...');
    _callStateController.add(CallState.reconnecting);
    
    // Try to restart ICE
    _peerConnection!.restartIce();
    
    // Timeout after 15 seconds
    Future.delayed(Duration(seconds: 15), () {
      if (_callStateController.value == CallState.reconnecting) {
        print('❌ [WebRTC] Reconnection failed');
        endCall();
      }
    });
  } else if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
    print('✅ [WebRTC] Connection restored');
    _callStateController.add(CallState.connected);
  }
};
```

**Add CallState.reconnecting to enum:**
```dart
enum CallState {
  idle,
  connecting,
  ringing,
  connected,
  reconnecting, // NEW
  timeout,      // NEW
  busy,         // NEW
  ended,
}
```

#### Fix 5: Background Call Handling
**File**: `main.dart`
**Add lifecycle observer:**
```dart
import 'package:flutter/services.dart';

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App going to background
      print('📱 [App] Going to background during call');
      // Keep audio, pause video
      if (WebRTCService().isCallActive) {
        WebRTCService().localStream?.getVideoTracks().forEach((track) {
          track.enabled = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      // App returning to foreground
      print('📱 [App] Returning to foreground');
      if (WebRTCService().isCallActive) {
        WebRTCService().localStream?.getVideoTracks().forEach((track) {
          track.enabled = true;
        });
      }
    }
  }
}
```

---

### 🟡 MEDIUM PRIORITY:

#### Fix 6: Draggable PiP
**File**: `webrtc_call_screen.dart`
**Replace fixed PiP with draggable:**
```dart
Offset _pipPosition = Offset(16, 16); // Default top-right

Widget _buildLocalVideo() {
  return Positioned(
    left: _pipPosition.dx,
    top: _pipPosition.dy,
    child: GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _pipPosition += details.delta;
          // Clamp to screen bounds
          _pipPosition = Offset(
            _pipPosition.dx.clamp(0, MediaQuery.of(context).size.width - 120),
            _pipPosition.dy.clamp(0, MediaQuery.of(context).size.height - 180),
          );
        });
      },
      child: Container(
        width: 120,
        height: 160,
        // ... rest of PiP UI
      ),
    ),
  );
}
```

#### Fix 7: Camera Switch
**File**: `webrtc_call_screen.dart`
**Add button:**
```dart
IconButton(
  icon: Icon(Icons.flip_camera_ios, color: Colors.white),
  onPressed: () async {
    // Get current video track
    final videoTrack = _webrtcService.localStream
        ?.getVideoTracks()
        .firstOrNull;
    
    if (videoTrack != null) {
      // Switch camera
      await Helper.switchCamera(videoTrack);
      setState(() {});
    }
  },
)
```

---

## 7. TESTING CHECKLIST AFTER FIXES

After implementing fixes, re-test:

- [ ] Call timeout works (60 seconds)
- [ ] Busy state blocking works
- [ ] Ringtone plays on incoming call
- [ ] ICE reconnection works on network drop
- [ ] App backgrounding handled gracefully
- [ ] PiP can be dragged (if implemented)
- [ ] Camera switch works (if implemented)
- [ ] All original scenarios still pass

---

## 8. AUTOMATED TEST SCRIPT

```dart
// File: test/integration_test/video_call_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_iot/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Video Call E2E Tests', () {
    testWidgets('Should connect call successfully', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(Key('email_field')), 'user1@test.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Navigate to chat
      await tester.tap(find.text('Test User 2'));
      await tester.pumpAndSettle();

      // Start call
      await tester.tap(find.byIcon(Icons.videocam));
      await tester.pumpAndSettle();

      // Wait for connection
      await tester.pump(Duration(seconds: 5));

      // Verify call screen is shown
      expect(find.text('Đang kết nối...'), findsOneWidget);

      // End call
      await tester.tap(find.byIcon(Icons.call_end));
      await tester.pumpAndSettle();

      // Verify returned to chat
      expect(find.byKey(Key('chat_input')), findsOneWidget);
    });

    testWidgets('Should handle call rejection', (tester) async {
      // ... similar test for rejection
    });

    testWidgets('Should timeout after 60 seconds', (tester) async {
      // ... test timeout
    });
  });
}
```

**Run with:**
```bash
flutter test integration_test/video_call_integration_test.dart
```

---

## 9. CONCLUSION

### Summary of Issues:
- **Found**: 9 areas needing improvement
- **Critical**: 3 (timeout, busy check, ringtone)
- **High**: 2 (reconnection, background handling)
- **Medium**: 2 (draggable PiP, camera switch)
- **Low**: 2 (call logs, adaptive quality)

### Estimated Time:
- Critical fixes: 4-6 hours
- High priority: 3-4 hours
- Medium priority: 2-3 hours
- **Total**: ~10-13 hours

### Next Steps:
1. Run manual tests on real devices (fill out scenarios above)
2. Implement critical fixes first
3. Re-test after each fix
4. Move to high/medium priority based on user feedback
5. Consider automated E2E tests for regression prevention

---

**Tester Name**: ___________________  
**Test Date**: ___________________  
**Overall Result**: ⬜ PASS  ⬜ FAIL  ⬜ NEEDS WORK  

**Notes**:
```



```
