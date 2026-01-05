# Hướng dẫn đổi tên và icon ứng dụng

## 📝 Tóm tắt các thay đổi đã thực hiện

### 1. Đổi tên ứng dụng thành "Health IoT"

#### File cần chỉnh sửa:
- ✅ `lib/config/app_info.dart` - Tên app chung (AppInfo.appName)
- ✅ `pubspec.yaml` - Package name: health_iot
- ✅ `android/app/src/main/AndroidManifest.xml` - android:label="Health IoT"
- ✅ `ios/Runner/Info.plist` - CFBundleDisplayName và CFBundleName
- ✅ `web/index.html` - Title và meta tags
- ✅ `web/manifest.json` - name và short_name
- ✅ `windows/runner/Runner.rc` - ProductName, FileDescription, etc.
- ✅ `windows/runner/main.cpp` - Window title L"Health IoT"

### 2. Tạo icon ứng dụng tròn

#### Các bước đã thực hiện:

1. **Tạo file icon nguồn:**
   - Copy từ `web/icons/Icon-512.png` → `assets/images/app_icon.png`

2. **Cấu hình trong pubspec.yaml:**
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/images/app_icon.png"
     remove_alpha_ios: true
     
     # Android - Icon tròn với nền trắng
     adaptive_icon_background: "#FFFFFF"
     adaptive_icon_foreground: "assets/images/app_icon.png"
     
     # Windows - Generate ICO file
     windows:
       generate: true
       image_path: "assets/images/app_icon.png"
       icon_size: 256
   ```

3. **Chạy lệnh tạo icon:**
   ```bash
   dart run flutter_launcher_icons
   ```

4. **Tạo icon Windows (ICO) thủ công:**
   ```bash
   python -c "from PIL import Image; img = Image.open('assets/images/app_icon.png'); img.save('windows/runner/resources/app_icon.ico', format='ICO', sizes=[(16,16), (32,32), (48,48), (64,64), (128,128), (256,256)])"
   ```

### 3. Build lại ứng dụng

```bash
# Clean build cũ
flutter clean

# Build cho Windows
flutter build windows

# Hoặc chạy trực tiếp
flutter run -d windows
```

## 🔧 Nếu cần đổi tên app trong tương lai

1. Sửa `lib/config/app_info.dart`:
   ```dart
   class AppInfo {
     static const String appName = 'Tên mới';
     // ...
   }
   ```

2. Sửa các file native platform như hướng dẫn ở trên

3. Đảm bảo đồng bộ package name trong tất cả imports:
   - Tìm kiếm: `package:app_iot/`
   - Thay bằng: `package:health_iot/`

## 📌 Lưu ý quan trọng

- **Android**: Adaptive icons tự động tròn trên các launcher hỗ trợ
- **iOS**: Tự động bo tròn bởi iOS
- **Windows**: Cần file `.ico` (không phải `.png`)
- **Web**: Sử dụng manifest.json cho PWA

## 🔍 Kiểm tra sau khi thay đổi

- [ ] Tên app hiển thị đúng trên title bar (Windows)
- [ ] Tên app hiển thị đúng trong taskbar
- [ ] Icon hiển thị tròn/đúng format trên từng platform
- [ ] Không có lỗi build
- [ ] App chạy bình thường

## 📦 Files quan trọng

- `lib/config/app_info.dart` - Config chung cho app
- `lib/core/constants/app_config.dart` - Config network (IP, API URL)
- `windows/runner/Runner.rc` - Metadata Windows
- `windows/runner/main.cpp` - Window title
- `windows/runner/resources/app_icon.ico` - Icon Windows
