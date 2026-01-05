# Flutter Test Suite - HealthAI

## Test Structure

### Unit Tests (`test/unit/`)
- `platform_helper_test.dart` - Platform detection and responsive breakpoints
- `chat_model_test.dart` - Chat message and conversation models
- `zego_service_test.dart` - Video call service singleton and state management

### Integration Tests (`test/integration/`)
- `video_call_integration_test.dart` - End-to-end video call functionality

### Widget Tests
- `widget_test.dart` - Basic widget smoke tests

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/platform_helper_test.dart

# Run integration tests
flutter test integration_test/

# Run tests in watch mode (requires flutter_test package)
flutter test --watch
```

## Test Coverage Areas

### ✅ Platform Detection
- Mobile/Tablet/Desktop breakpoint detection
- Responsive padding calculation
- Grid column calculation
- Max content width for large screens

### ✅ Chat Functionality
- Message model serialization/deserialization
- Message type handling (text, image, file)
- Message status tracking
- Conversation management

### ✅ Video Call
- Zego service singleton pattern
- Service initialization state
- Avatar management
- Platform-specific configurations

### ✅ Responsive Design
- Layout builder functionality
- Platform-specific UI adaptations
- Responsive padding and spacing

## Expected Test Results

All unit tests should pass with 100% coverage on:
- Platform detection logic
- Model serialization
- Service state management

Integration tests verify:
- App initialization
- Service accessibility
- Navigation flow
- Video call flow (requires manual testing with real devices)

## CI/CD Integration

Add to your GitHub Actions workflow:
```yaml
name: Flutter Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2
        with:
          files: ./coverage/lcov.info
```

## Manual Testing Checklist

### Mobile (Android)
- [ ] Video call connects successfully
- [ ] Camera/microphone permissions work
- [ ] UI is responsive and touch-friendly
- [ ] Notifications work properly

### Desktop (Windows/Mac/Linux)
- [ ] Video call works with desktop camera/mic
- [ ] Window resizing adapts UI correctly
- [ ] Keyboard shortcuts work
- [ ] Desktop notifications function

### Web
- [ ] Browser camera/mic permissions
- [ ] Responsive layout on different screen sizes
- [ ] WebRTC connection established
- [ ] Performance is acceptable

## Known Limitations

1. Integration tests for video calls require:
   - Valid Zego credentials
   - Network connectivity
   - Camera/microphone hardware
   - Two devices for full e2e testing

2. Some platform-specific features require manual testing:
   - Native notifications
   - Background call handling
   - Hardware permission flows

## Troubleshooting

### Tests fail with "No Firebase App"
Add to test setup:
```dart
TestWidgetsFlutterBinding.ensureInitialized();
setupFirebaseAuthMocks();
```

### Integration tests don't run
Make sure you have:
```yaml
# pubspec.yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

### Video call tests timeout
Increase timeout in test:
```dart
testWidgets('test name', (tester) async {
  // ...
}, timeout: Timeout(Duration(seconds: 60)));
```
