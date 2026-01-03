# 🚀 HƯỚNG DẪN NHANH ĐẨY CODE LÊN GITHUB

## Cách 1: Sử Dụng Script Tự Động (Khuyên Dùng) ⚡

### Trên Windows:

```powershell
# Mở PowerShell trong thư mục E:\Fluter
cd E:\Fluter

# Chạy script (có thể cần cho phép execution policy)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\push-to-github.ps1
```

Script sẽ tự động:
- ✅ Kiểm tra Git configuration
- ✅ Khởi tạo Git repository
- ✅ Thêm remote origin
- ✅ Add và commit files
- ✅ Push lên GitHub

---

## Cách 2: Thực Hiện Thủ Công 📝

### Bước 1: Cấu Hình Git (Lần Đầu)

```bash
# Đặt tên và email
git config --global user.name "Bùi Duy Thân"
git config --global user.email "buithan160904@gmail.com"

# Kiểm tra config
git config --list
```

### Bước 2: Khởi Tạo Repository

```bash
cd E:\Fluter

# Khởi tạo Git
git init

# Thêm remote
git remote add origin git@github.com:buithan04/Health_IoT.git

# Kiểm tra remote
git remote -v
```

### Bước 3: Add và Commit Files

```bash
# Kiểm tra status
git status

# Add tất cả files (đã được filter bởi .gitignore)
git add .

# Xem những gì sẽ được commit
git status

# Commit với message
git commit -m "feat: initial commit with Flutter app, Node.js backend, and Admin portal

- Add Flutter mobile app with patient and doctor features
- Add Node.js backend API with Socket.IO and MQTT
- Add Next.js admin portal
- Configure video/audio calls with ZegoCloud
- Implement real-time chat functionality
- Add comprehensive documentation and setup guides"
```

### Bước 4: Push Lên GitHub

```bash
# Đổi tên branch thành main (nếu cần)
git branch -M main

# Push lên GitHub
git push -u origin main
```

---

## ⚠️ Lưu Ý Quan Trọng

### 1. Kiểm Tra Trước Khi Push

**Files KHÔNG nên commit:**
- ❌ `flutter/` - Flutter SDK (đã loại trừ trong .gitignore)
- ❌ `node_modules/` - Node.js dependencies
- ❌ `.env` files - Environment variables với secrets
- ❌ `build/`, `dist/` - Build artifacts
- ❌ `.dart_tool/`, `.gradle/` - IDE và build tools

**Kiểm tra:**
```bash
# Xem danh sách files sẽ được commit
git add -n .

# Hoặc
git status
```

### 2. Tạo Repository Trên GitHub

Trước khi push, đảm bảo đã tạo repository trên GitHub:
1. Truy cập: https://github.com/new
2. Repository name: `Health_IoT`
3. Description: "🏥 Hệ Thống Quản Lý Sức Khỏe Thông Minh"
4. Chọn **Public** hoặc **Private**
5. **KHÔNG** check "Initialize this repository with a README"
6. Click **Create repository**

### 3. Cấu Hình SSH Key (Khuyên Dùng)

**Nếu dùng SSH (git@github.com):**

```bash
# Kiểm tra SSH key
ssh -T git@github.com

# Nếu chưa có SSH key, tạo mới:
ssh-keygen -t ed25519 -C "buithan160904@gmail.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Thêm vào GitHub:
# Settings > SSH and GPG keys > New SSH key
```

**Hoặc dùng HTTPS:**

```bash
# Nếu gặp lỗi với SSH, đổi sang HTTPS
git remote set-url origin https://github.com/buithan04/Health_IoT.git
```

### 4. Cấu Trúc Thư Mục Sẽ Push

```
Health_IoT/
├── .gitignore              ✅ (Root gitignore)
├── README.md               ✅ (Comprehensive documentation)
├── LICENSE                 ✅ (MIT License)
├── CONTRIBUTING.md         ✅ (Contribution guidelines)
│
├── doan2/                  ✅ (Flutter app - WITHOUT dependencies)
│   ├── lib/               ✅
│   ├── android/           ✅ (config only)
│   ├── ios/               ✅ (config only)
│   ├── windows/           ✅ (config only)
│   ├── pubspec.yaml       ✅
│   ├── .gitignore         ✅
│   └── README.md          ✅
│
├── HealthAI_Server/       ✅ (Node.js backend - WITHOUT node_modules)
│   ├── config/            ✅
│   ├── controllers/       ✅
│   ├── services/          ✅
│   ├── routes/            ✅
│   ├── package.json       ✅
│   ├── .gitignore         ✅
│   ├── .env.example       ✅ (template only)
│   └── README.md          ✅
│
├── admin-portal/          ✅ (Next.js - WITHOUT node_modules)
│   ├── src/               ✅
│   ├── package.json       ✅
│   ├── .gitignore         ✅
│   └── README.md          ✅
│
└── flutter/               ❌ (EXCLUDED - Flutter SDK)
```

---

## 🔧 Xử Lý Lỗi Thường Gặp

### Lỗi 1: "remote origin already exists"

```bash
# Xóa remote cũ và thêm lại
git remote remove origin
git remote add origin git@github.com:buithan04/Health_IoT.git
```

### Lỗi 2: "Permission denied (publickey)"

```bash
# Kiểm tra SSH
ssh -T git@github.com

# Nếu lỗi, dùng HTTPS thay vì:
git remote set-url origin https://github.com/buithan04/Health_IoT.git
```

### Lỗi 3: "Repository not found"

- Đảm bảo đã tạo repository trên GitHub
- Kiểm tra tên repository đúng: `Health_IoT`
- Kiểm tra quyền truy cập

### Lỗi 4: Commit quá lớn

```bash
# Nếu file quá lớn (>100MB):
git filter-branch --tree-filter 'rm -rf path/to/large/file' HEAD

# Hoặc dùng git-lfs cho large files
git lfs install
git lfs track "*.zip"
git add .gitattributes
```

---

## 📊 Kiểm Tra Kích Thước Repository

```bash
# Kiểm tra kích thước các folder
du -sh * | sort -h

# Xem files lớn nhất
find . -type f -size +10M -exec ls -lh {} \;

# Kiểm tra git repository size
git count-objects -vH
```

---

## 🎯 Các Bước Tiếp Theo Sau Khi Push

1. **Truy cập repository:** https://github.com/buithan04/Health_IoT

2. **Cấu hình GitHub:**
   - Thêm description và topics
   - Enable Issues và Discussions
   - Cấu hình Branch protection rules

3. **Setup CI/CD (Optional):**
   - GitHub Actions for automated testing
   - Deploy backend to Heroku/Railway
   - Deploy admin portal to Vercel

4. **Thêm Badges vào README:**
   - Build status
   - Code coverage
   - License badge

5. **Documentation:**
   - Update API documentation
   - Add screenshots/GIFs
   - Create Wiki pages

---

## 💡 Tips

✅ **Commit thường xuyên** với messages rõ ràng  
✅ **Sử dụng branches** cho features mới  
✅ **Review code** trước khi push  
✅ **Backup** code quan trọng  
✅ **Đọc CONTRIBUTING.md** trước khi contribute  

---

## 📞 Cần Trợ Giúp?

- 📧 Email: buithan160904@gmail.com
- 🐛 Issues: https://github.com/buithan04/Health_IoT/issues
- 📖 Docs: https://github.com/buithan04/Health_IoT/wiki

---

**Good luck! 🚀**
