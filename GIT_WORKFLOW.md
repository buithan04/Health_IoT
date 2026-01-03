# 🚀 Git Workflow Guide - Health IoT

Hướng dẫn chi tiết để push project Health IoT lên GitHub một cách chuyên nghiệp và đầy đủ.

---

## 📋 Mục Lục

- [Chuẩn Bị](#-chuẩn-bị)
- [Kiểm Tra Project](#-kiểm-tra-project)
- [Git Workflow](#-git-workflow)
- [Push Lên GitHub](#-push-lên-github)
- [Tạo Release](#-tạo-release)
- [Best Practices](#-best-practices)

---

## 🔍 Chuẩn Bị

### 1. Kiểm Tra Git

```powershell
# Kiểm tra Git đã cài đặt
git --version
# Kết quả: git version 2.x.x

# Cấu hình Git (nếu chưa có)
git config --global user.name "Bùi Duy Thân"
git config --global user.email "buithan04@example.com"

# Kiểm tra cấu hình
git config --global --list
```

### 2. Xác Thực GitHub

```powershell
# Kiểm tra remote repository
git remote -v

# Kết quả mong đợi:
# origin  https://github.com/buithan04/Health_IoT.git (fetch)
# origin  https://github.com/buithan04/Health_IoT.git (push)
```

**Nếu chưa có remote:**

```powershell
git remote add origin https://github.com/buithan04/Health_IoT.git
```

---

## ✅ Kiểm Tra Project

### 1. Kiểm Tra File Nhạy Cảm

**Backend (HealthAI_Server):**

```powershell
# Kiểm tra .env không bị track
git check-ignore HealthAI_Server/.env
# Nếu trả về: HealthAI_Server/.env → ✅ Đã bị ignore

# Kiểm tra node_modules
git check-ignore HealthAI_Server/node_modules
# Nếu trả về: HealthAI_Server/node_modules/ → ✅ Đã bị ignore
```

**Admin Portal:**

```powershell
git check-ignore admin-portal/.env.local
git check-ignore admin-portal/node_modules
git check-ignore admin-portal/.next
```

**Flutter App:**

```powershell
git check-ignore doan2/build
git check-ignore doan2/.dart_tool
```

### 2. Kiểm Tra Files Sẽ Được Commit

```powershell
# Xem status hiện tại
git status

# Xem chi tiết thay đổi
git diff

# Xem files đã staged
git diff --staged
```

### 3. Checklist Trước Khi Push

- [ ] ✅ Đã tạo đầy đủ README files (Root, Backend, Flutter, Admin)
- [ ] ✅ Đã tạo CONTRIBUTING.md
- [ ] ✅ Đã tạo CHANGELOG.md
- [ ] ✅ File .env KHÔNG nằm trong git (check với `git status`)
- [ ] ✅ File .env.local (admin) KHÔNG nằm trong git
- [ ] ✅ Folder node_modules/ KHÔNG nằm trong git
- [ ] ✅ Folder build/ KHÔNG nằm trong git
- [ ] ✅ Đã xóa console.log và debug code không cần thiết
- [ ] ✅ Code đã chạy thành công trên local
- [ ] ✅ Database migrations đã có trong git

---

## 🔄 Git Workflow

### Bước 1: Tạo Branch Mới (Recommended)

```powershell
# Checkout branch main/master hiện tại
git checkout master

# Pull latest changes (nếu có collaborators)
git pull origin master

# Tạo branch mới cho documentation update
git checkout -b docs/comprehensive-documentation
```

**Hoặc làm việc trực tiếp trên master:**

```powershell
git checkout master
```

### Bước 2: Stage Files

**Stage tất cả files:**

```powershell
git add .
```

**Hoặc stage từng nhóm files:**

```powershell
# Documentation files
git add README.md CONTRIBUTING.md CHANGELOG.md GIT_WORKFLOW.md

# Comprehensive reports
git add COMPREHENSIVE_PROJECT_REPORT*.md

# Backend README
git add HealthAI_Server/README.md

# Flutter README
git add doan2/README.md

# Admin README
git add admin-portal/README.md
```

### Bước 3: Kiểm Tra Lại

```powershell
# Xem files đã staged
git status

# Xem nội dung thay đổi
git diff --staged

# Nếu có file không mong muốn:
git reset HEAD <file>
```

### Bước 4: Commit Changes

**Sử dụng Conventional Commits:**

```powershell
# Commit với message chi tiết
git commit -m "docs: Add comprehensive documentation and project cleanup

- Add detailed README.md for root, backend, Flutter app, and admin portal
- Create CONTRIBUTING.md with coding standards and Git workflow
- Create CHANGELOG.md for version 1.0.0
- Add GIT_WORKFLOW.md for deployment guide
- Update all READMEs with accurate project information
- Ensure .gitignore files properly configured
- Clean code: Remove unnecessary console.log and debug comments

Closes #123"
```

**Hoặc commit ngắn gọn:**

```powershell
git commit -m "docs: Add comprehensive documentation for v1.0.0"
```

### Bước 5: Review Commit

```powershell
# Xem commit vừa tạo
git show

# Xem lịch sử commits
git log --oneline -5

# Nếu cần sửa commit message:
git commit --amend -m "docs: Updated commit message"
```

---

## 📤 Push Lên GitHub

### Push Lần Đầu

```powershell
# Push branch mới lên GitHub
git push -u origin docs/comprehensive-documentation

# Hoặc push trực tiếp lên master
git push -u origin master
```

**Console output:**

```
Enumerating objects: 50, done.
Counting objects: 100% (50/50), done.
Delta compression using up to 8 threads
Compressing objects: 100% (30/30), done.
Writing objects: 100% (35/35), 150.25 KiB | 5.75 MiB/s, done.
Total 35 (delta 15), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (15/15), completed with 10 local objects.
To https://github.com/buithan04/Health_IoT.git
 * [new branch]      docs/comprehensive-documentation -> docs/comprehensive-documentation
Branch 'docs/comprehensive-documentation' set up to track remote branch 'docs/comprehensive-documentation' from 'origin'.
```

### Push Sau Này

```powershell
# Push changes
git push

# Hoặc chỉ định branch
git push origin master
```

### Force Push (Cẩn Thận!)

**Chỉ dùng khi:**
- Làm việc một mình
- Cần rewrite history
- Đã backup code

```powershell
# Force push (NGUY HIỂM!)
git push --force origin master

# Safer option: force-with-lease
git push --force-with-lease origin master
```

---

## 🏷️ Tạo Release

### Bước 1: Tag Version

```powershell
# Tạo annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0

## Features
- Complete mobile app (Flutter)
- Backend API with 100+ endpoints
- Admin portal (Next.js 14)
- AI/ML health predictions
- Real-time chat and video calling
- IoT integration (MQTT)

## Documentation
- Comprehensive README files
- API documentation (40,000+ words)
- Contributing guidelines
- Changelog

See CHANGELOG.md for full details."

# Xem tag vừa tạo
git show v1.0.0

# Push tag lên GitHub
git push origin v1.0.0
```

### Bước 2: Tạo Release Trên GitHub

**Cách 1: GitHub Web UI**

1. Vào repository: https://github.com/buithan04/Health_IoT
2. Click **Releases** → **Create a new release**
3. Chọn tag: `v1.0.0`
4. Release title: `Health IoT v1.0.0 - Initial Release`
5. Description: Copy từ CHANGELOG.md
6. Upload files (nếu cần):
   - APK file (Android)
   - Windows installer
   - Documentation PDF
7. Click **Publish release**

**Cách 2: GitHub CLI**

```powershell
# Install GitHub CLI: https://cli.github.com/
gh release create v1.0.0 ^
  --title "Health IoT v1.0.0 - Initial Release" ^
  --notes-file CHANGELOG.md ^
  app-release.apk ^
  healthai-windows-setup.exe
```

### Bước 3: Verify Release

```powershell
# List all tags
git tag -l

# Check tag info
git show v1.0.0

# View releases on GitHub
gh release list
```

---

## 📚 Best Practices

### 1. Commit Messages

**✅ Good:**
```
feat(auth): add email verification flow
fix(mqtt): resolve connection timeout errors
docs(readme): update installation instructions
refactor(services): simplify user service logic
```

**❌ Bad:**
```
update
fix bug
WIP
asdasd
```

### 2. Branch Names

**✅ Good:**
```
feature/user-authentication
bugfix/login-error
docs/comprehensive-documentation
refactor/auth-service
```

**❌ Bad:**
```
new-stuff
fix
branch1
test-branch
```

### 3. Commit Frequency

- **Commit thường xuyên**: Mỗi feature nhỏ hoặc bug fix
- **Không commit quá lớn**: Chia nhỏ thành nhiều commits
- **Mỗi commit là một unit of work**: Có thể revert được

### 4. .gitignore

**Luôn ignore:**
- `.env` files
- `node_modules/`
- `build/` folders
- IDE config (`.vscode/`, `.idea/`)
- Log files
- Temporary files

**Nên commit:**
- `.env.example` (template)
- README files
- Documentation
- Source code
- Database migrations

### 5. Pull Request Flow

```powershell
# 1. Tạo branch
git checkout -b feature/amazing-feature

# 2. Commit changes
git add .
git commit -m "feat: add amazing feature"

# 3. Push branch
git push origin feature/amazing-feature

# 4. Tạo Pull Request trên GitHub
# 5. Review và merge
# 6. Delete branch sau khi merge
git branch -d feature/amazing-feature
git push origin --delete feature/amazing-feature
```

---

## 🔥 Troubleshooting

### Conflict Khi Push

```powershell
# Pull latest changes
git pull origin master

# Resolve conflicts
# Edit conflicted files, then:
git add .
git commit -m "fix: resolve merge conflicts"
git push origin master
```

### Revert Commit

```powershell
# Revert last commit (tạo commit mới)
git revert HEAD

# Reset to previous commit (XÓA lịch sử!)
git reset --hard HEAD~1
```

### Xem Lịch Sử

```powershell
# Xem log đẹp
git log --oneline --graph --decorate --all

# Xem changes của file
git log -p <file>

# Xem who changed what
git blame <file>
```

### Unstage Files

```powershell
# Unstage all
git reset

# Unstage specific file
git reset HEAD <file>

# Discard changes
git checkout -- <file>
```

---

## 📞 Cần Hỗ Trợ?

- **GitHub Issues**: https://github.com/buithan04/Health_IoT/issues
- **Email**: buithan04@example.com
- **Documentation**: [CONTRIBUTING.md](CONTRIBUTING.md)

---

## ✅ Quick Checklist

**Trước khi push:**

- [ ] Code chạy thành công trên local
- [ ] Đã test tất cả features
- [ ] File .env không nằm trong git
- [ ] Đã xóa console.log và debug code
- [ ] Commit message rõ ràng
- [ ] Đã pull latest changes (nếu có collaborators)

**Sau khi push:**

- [ ] Verify trên GitHub web
- [ ] Check Actions/CI (nếu có)
- [ ] Update documentation (nếu cần)
- [ ] Notify team members (nếu có)
- [ ] Create release/tag (cho version mới)

---

<div align="center">

**Happy Coding! 🚀**

Made with ❤️ by [Bùi Duy Thân](https://github.com/buithan04)

[⬆ Back to top](#-git-workflow-guide---health-iot)

</div>
