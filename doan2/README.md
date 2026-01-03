# 📱 Health IoT - Flutter Mobile App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9-0175C2?logo=dart)
![Android](https://img.shields.io/badge/Android-6.0+-3DDC84?logo=android)
![iOS](https://img.shields.io/badge/iOS-13.0+-000000?logo=apple)
![Windows](https://img.shields.io/badge/Windows-10+-0078D6?logo=windows)

**Cross-platform healthcare mobile app with AI-powered diagnosis, video calling, and IoT monitoring**

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Building](#-building)
- [Project Structure](#-project-structure)
- [Key Dependencies](#-key-dependencies)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Overview

**Health IoT Mobile App** (`app_iot`) is a comprehensive Flutter application that provides:

- 📊 **Real-time Health Monitoring** - IoT devices via MQTT protocol
- 🤖 **AI Health Predictions** - Heart disease risk (89.3% accuracy)
- 📞 **Video Consultations** - HD calls with ZegoCloud SDK 4.22.2
- 💬 **Real-time Chat** - Socket.IO instant messaging
- 📅 **Appointment Management** - Book, reschedule, review doctors
- 💊 **E-Prescriptions** - Digital prescriptions with medication database
- 🔔 **Smart Reminders** - Medication notification system
- 📰 **Health Articles** - Curated health news

**Platforms**: Android (API 23+), iOS (13.0+), Windows (10 1809+)

---

## ✨ Features

### For Patients 🧑‍⚕️

✅ Electronic health records  
✅ Real-time vital monitoring (heart rate, SpO2, temperature, BP)  
✅ AI health risk assessment  
✅ Doctor search and booking  
✅ Video consultations  
✅ Instant messaging with doctors  
✅ Digital prescriptions  
✅ Medication reminders  
✅ Health trend charts  

### For Doctors 👨‍⚕️

✅ Patient management dashboard  
✅ Appointment scheduling  
✅ E-prescribing system  
✅ Video consultations  
✅ Real-time patient vitals  
✅ Doctor notes  
✅ Schedule management  

---

## 🛠 Tech Stack

### Framework

```yaml
name: app_iot
sdk: ">=3.9.2 <4.0.0"
flutter: ">=3.24.0"
```

### Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| **go_router** | ^17.0.1 | Navigation |
| **provider** | ^6.1.5+1 | State management |
| **http** | ^1.2.1 | REST API |
| **socket_io_client** | ^3.1.2 | Real-time chat |
| **mqtt_client** | ^10.3.1 | IoT protocol |
| **zego_uikit_prebuilt_call** | 4.22.2 | Video calling |
| **firebase_messaging** | ^16.1.0 | Push notifications |
| **fl_chart** | ^1.1.1 | Data visualization |
| **image_picker** | ^1.0.7 | Photo selection |
| **shared_preferences** | ^2.2.2 | Local storage |
| **permission_handler** | ^12.0.1 | Permissions |

---

## 📦 Prerequisites

### Flutter SDK

```bash
flutter --version
# Flutter 3.24.0 • Dart 3.9.2

flutter doctor
```

### Platform Requirements

**Android:**
- Android Studio
- Android SDK 23+ (Android 6.0)
- Java JDK 11+

**iOS:**
- Xcode 15+
- CocoaPods
- iOS 13.0+
- Apple Developer account

**Windows:**
- Visual Studio 2022
- Desktop development with C++
- Windows 10 SDK 17763+

---

## 🚀 Installation

### 1. Clone & Navigate

```bash
git clone https://github.com/buithan04/Health_IoT.git
cd Health_IoT/doan2
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

**Android**: Place `google-services.json` in `android/app/`  
**iOS**: Place `GoogleService-Info.plist` in `ios/Runner/`

Download from Firebase Console → Project Settings → General

---

## ⚙️ Configuration

### API Endpoints

Edit `lib/config/app_config.dart`:

```dart
class AppConfig {
  // Development
  static const String apiBaseUrl = 'http://localhost:5000/api';
  static const String socketUrl = 'http://localhost:5000';
  
  // For Android Emulator, use: 'http://10.0.2.2:5000/api'
  
  // Production
  // static const String apiBaseUrl = 'https://your-api.com/api';
  // static const String socketUrl = 'https://your-api.com';
}
```

### ZegoCloud Video Calling

Edit `lib/config/zego_config.dart`:

```dart
class ZegoConfig {
  static const int appID = YOUR_APP_ID; // From ZegoCloud Console
  static const String appSign = 'YOUR_APP_SIGN';
}
```

Get credentials: [ZegoCloud Console](https://console.zegocloud.com/)

### MQTT (Optional)

Edit `lib/config/mqtt_config.dart`:

```dart
class MqttConfig {
  static const String broker = 'broker.hivemq.com';
  static const int port = 1883;
  static const String username = 'your_username';
  static const String password = 'your_password';
}
```

---

## 🏗️ Building

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# App Bundle (Google Play)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# Install on device
flutter install
```

### iOS

```bash
# Open in Xcode
open ios/Runner.xcworkspace

# Build from CLI
flutter build ios --release

# Or in Xcode: Product → Archive → Distribute App
```

### Windows

```bash
# Build executable
flutter build windows --release
# Output: build/windows/x64/runner/Release/

# Create MSIX installer
flutter pub run msix:create
```

---

## 📁 Project Structure

```
doan2/
├── lib/
│   ├── main.dart               # Entry point
│   ├── config/                 # Configuration
│   │   ├── app_config.dart
│   │   ├── zego_config.dart
│   │   └── mqtt_config.dart
│   ├── core/                   # Core utilities
│   │   ├── api_client.dart
│   │   └── constants.dart
│   ├── models/                 # Data models
│   ├── service/                # API services (14 files)
│   │   ├── auth_service.dart
│   │   ├── mqtt_service.dart
│   │   ├── socket_service.dart
│   │   ├── zego_service.dart
│   │   └── ...
│   ├── presentation/           # UI screens
│   │   ├── auth/
│   │   ├── patient/
│   │   ├── doctor/
│   │   ├── shared/
│   │   └── widgets/
│   └── providers/              # State management
├── assets/images/              # App images
├── android/                    # Android config
├── ios/                        # iOS config
├── windows/                    # Windows config
└── pubspec.yaml
```

---

## 🔧 Troubleshooting

### Build Errors

**Gradle build failed:**
```bash
flutter clean
flutter pub get
flutter build apk
```

**CocoaPods not installed:**
```bash
sudo gem install cocoapods
cd ios && pod install && cd ..
```

### Runtime Errors

**Connection refused:**
- Check API URL in `app_config.dart`
- Use `10.0.2.2` for Android emulator
- Verify backend is running

**Missing plugin:**
```bash
flutter clean
flutter pub get
flutter run
```

**Permission denied:**
- Add permissions to `AndroidManifest.xml` (Android)
- Add usage descriptions to `Info.plist` (iOS)

### Video Call Issues

**ZegoCloud failed:**
- Verify `appID` and `appSign`
- Check camera/microphone permissions
- Test on real device (not emulator)

### MQTT Connection

**Connection refused:**
- Verify broker URL and credentials
- Test with MQTT.fx desktop client

### Push Notifications

**FCM token null:**
- Verify Firebase config files
- Request notification permission
- Check Firebase console setup

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/buithan04/Health_IoT/issues)
- **Email**: buithan04@example.com
- **Docs**: [Full Documentation](../COMPREHENSIVE_PROJECT_REPORT.md)

---

## 📄 License

MIT License - see [LICENSE](../LICENSE)

---

<div align="center">

**Made with ❤️ by [Bùi Duy Thân](https://github.com/buithan04)**

[⬆ Back to top](#-health-iot---flutter-mobile-app)

</div>
