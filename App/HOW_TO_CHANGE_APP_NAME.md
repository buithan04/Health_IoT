# 📝 Hướng Dẫn Đổi Tên App

## ⚡ Cách Đổi Tên Nhanh

### Bước 1: Sửa file config chính
Mở file **`lib/config/app_info.dart`** và sửa:

```dart
static const String appName = 'TÊN MỚI CỦA BẠN';
```

### Bước 2: Đồng bộ các file sau
Các file này cần sửa **CÙNG TÊN** với file config:

#### 1️⃣ Android
**File:** `android/app/src/main/AndroidManifest.xml`  
**Dòng ~40:**
```xml
android:label="TÊN MỚI CỦA BẠN"
```

#### 2️⃣ iOS
**File:** `ios/Runner/Info.plist`  
**Dòng ~9 và ~17:**
```xml
<key>CFBundleDisplayName</key>
<string>TÊN MỚI CỦA BẠN</string>
...
<key>CFBundleName</key>
<string>TÊN MỚI CỦA BẠN</string>
```

#### 3️⃣ Web
**File:** `web/index.html`  
**Dòng ~32:**
```html
<title>TÊN MỚI CỦA BẠN</title>
```

**File:** `web/manifest.json`  
**Dòng ~2-3:**
```json
"name": "TÊN MỚI CỦA BẠN",
"short_name": "TÊN MỚI CỦA BẠN",
```

#### 4️⃣ Windows (nếu build Windows)
**File:** `windows/runner/main.cpp`  
**Dòng ~30:**
```cpp
window.Create(L"TÊN MỚI CỦA BẠN", origin, size)
```

### Bước 3: Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📍 Các File Cần Nhớ

| Platform | File | Dòng | Nội dung |
|----------|------|------|----------|
| **Dart** | `lib/config/app_info.dart` | 12 | `appName` |
| **Android** | `android/app/src/main/AndroidManifest.xml` | 40 | `android:label` |
| **iOS** | `ios/Runner/Info.plist` | 9, 17 | `CFBundleDisplayName`, `CFBundleName` |
| **Web** | `web/index.html` | 32 | `<title>` |
| **Web** | `web/manifest.json` | 2-3 | `name`, `short_name` |
| **Windows** | `windows/runner/main.cpp` | 30 | `window.Create(L"...")` |

---

## 💡 Lưu Ý

- Mọi file đều đã có comment `⚠️ KHI ĐỔI TÊN APP` để dễ tìm
- Tên trong `lib/config/app_info.dart` được dùng trong app (MaterialApp title)
- Tên trong các file native config (Android/iOS) được hiển thị ở launcher/home screen
- **Quan trọng:** Sau khi đổi phải `flutter clean` để áp dụng thay đổi
