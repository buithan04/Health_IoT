# HƯỚNG DẪN DỌN DẸP DỰ ÁN - PROJECT CLEANUP GUIDE

## ⚠️ LƯU Ý: PowerShell Terminal Bị Lỗi Encoding

Do PowerShell terminal hiện tại bị lỗi Unicode (không thể xử lý emoji characters trong history), bạn cần:

1. **Đóng VS Code hoàn toàn**
2. **Mở lại VS Code mới**
3. **Chạy các lệnh cleanup bên dưới**

---

## 📋 DANH SÁCH FILE CẦN XÓA

### Backend (HealthAI_Server)

```
❌ coverage/                    # Test coverage reports
❌ tests/                       # Test files (4 files)
   ├── socket.test.js
   ├── mqtt.test.js
   ├── chat_service.test.js
   └── api.test.js
❌ check_db_structure.js        # Debug script
❌ test_admin_apis.ps1          # Test script
```

### Frontend (doan2)

```
❌ coverage/                    # Test coverage (lcov.info)
❌ exportToHTML/                # HTML exports (10 files)
❌ flutter_01.png               # Screenshot
```

---

## 🧹 LỆNH CLEANUP

### Option 1: Chạy Script Tự Động (Khuyên dùng)

Đã tạo sẵn file `e:\Fluter\cleanup.ps1`. Mở **PowerShell mới** và chạy:

```powershell
cd e:\Fluter
.\cleanup.ps1
```

### Option 2: Manual Commands

Nếu script không chạy được, copy từng lệnh này:

```powershell
# Navigate to Backend
cd e:\Fluter\HealthAI_Server

# Delete test & coverage files
Remove-Item -Recurse -Force coverage
Remove-Item -Recurse -Force tests
Remove-Item -Force check_db_structure.js
Remove-Item -Force test_admin_apis.ps1

# Navigate to Frontend
cd e:\Fluter\doan2

# Delete coverage & exports
Remove-Item -Recurse -Force coverage
Remove-Item -Recurse -Force exportToHTML
Remove-Item -Force flutter_01.png
```

---

## 📝 GIT COMMIT & PUSH

Sau khi cleanup xong, commit changes:

```bash
cd e:\Fluter

# Check git status
git status

# Stage all changes
git add -A

# Commit with message
git commit -m "Clean: Remove test files, coverage, and debug scripts

- Backend: Removed tests/, coverage/, check_db_structure.js, test_admin_apis.ps1
- Frontend: Removed coverage/, exportToHTML/, flutter_01.png
- Keep: All production code, AI models, and documentation"

# Push to GitHub
git push origin main
```

---

## ✅ FILES ĐƯỢC GIỮ LẠI (KHÔNG XÓA)

### Backend - Production Files ✅
```
✅ app.js                       # Server entry point
✅ config/                      # Configuration (aiModels.js, db.js, mqtt.js)
✅ controllers/                 # API controllers
✅ database/                    # Database migrations & seeds
✅ middleware/                  # Auth, validation middleware
✅ models/                      # AI models (tfjs_mlp_model, tfjs_ecg_model)
✅ routes/                      # API routes
✅ services/                    # Business logic (mqtt_service.js, predict_service.js)
✅ workers/                     # Background workers
✅ package.json                 # Dependencies
✅ .env                         # Environment variables
✅ README.md                    # Documentation
✅ DATABASE_*.md                # Database docs
✅ MQTT_*.md                    # MQTT docs
```

### Frontend - Production Files ✅
```
✅ lib/                         # Flutter source code
   ├── models/                  # Data models
   ├── presentation/            # UI screens
   ├── service/                 # Services (socket, mqtt)
   └── utils/                   # Utilities
✅ assets/                      # Images, fonts
✅ android/                     # Android config
✅ ios/                         # iOS config
✅ web/                         # Web config
✅ windows/                     # Windows config
✅ pubspec.yaml                 # Dependencies
✅ README.md                    # Documentation
✅ ZEGOCLOUD_SETUP.md           # Video call setup
```

---

## 📊 EXPECTED RESULTS

Sau khi cleanup:

### Backend Size Reduction
```
Before: ~XXX MB (with tests & coverage)
After:  ~YYY MB (production only)
Saved:  ~ZZZ MB
```

### Frontend Size Reduction
```
Before: ~AAA MB (with coverage & exports)
After:  ~BBB MB (production only)
Saved:  ~CCC MB
```

### Git Changes
```
git status sẽ hiển thị:
deleted:    HealthAI_Server/coverage/...
deleted:    HealthAI_Server/tests/...
deleted:    HealthAI_Server/check_db_structure.js
deleted:    HealthAI_Server/test_admin_apis.ps1
deleted:    doan2/coverage/...
deleted:    doan2/exportToHTML/...
deleted:    doan2/flutter_01.png
```

---

## 🎯 VERIFICATION CHECKLIST

Sau khi cleanup và push lên Git:

- [ ] Backend vẫn chạy được: `cd HealthAI_Server && node app.js`
- [ ] AI models vẫn load: Check log "AI models loaded successfully"
- [ ] Frontend vẫn build được: `cd doan2 && flutter build apk`
- [ ] Socket.IO kết nối được
- [ ] MQTT nhận data từ ESP32
- [ ] AI diagnosis hoạt động bình thường
- [ ] Git push thành công lên GitHub

---

## 🚨 TROUBLESHOOTING

### Nếu PowerShell vẫn lỗi:

1. Xóa PowerShell history:
```powershell
Remove-Item (Get-PSReadlineOption).HistorySavePath
```

2. Restart VS Code

3. Hoặc dùng Command Prompt thay vì PowerShell:
```cmd
cd e:\Fluter\HealthAI_Server
rmdir /s /q coverage tests
del check_db_structure.js test_admin_apis.ps1

cd e:\Fluter\doan2
rmdir /s /q coverage exportToHTML
del flutter_01.png
```

### Nếu không muốn xóa tests:

Có thể giữ lại `tests/` folder nếu cần, chỉ xóa `coverage/` và các debug scripts.

---

## 📌 NOTES

- **Không ảnh hưởng** đến code production
- **Giữ lại** tất cả documentation (.md files)
- **Giữ lại** AI models (models/ folder)
- **Giữ lại** .gitignore, package.json, pubspec.yaml
- **An toàn** để commit và push

---

*Created: January 4, 2026*  
*Purpose: Clean project before Git push*  
*Status: Ready to execute*
