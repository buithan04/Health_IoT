# ============================================
# SCRIPT ĐẨY CODE LÊN GITHUB - HEALTH IOT
# ============================================
# Script này sẽ:
# 1. Kiểm tra cấu hình Git
# 2. Khởi tạo Git repository
# 3. Thêm remote
# 4. Commit và push code
# ============================================

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  HEALTH IOT - GIT PUSH SCRIPT" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra Git đã cài đặt chưa
Write-Host "[1/8] Checking Git installation..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "✓ Git found: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Git is not installed!" -ForegroundColor Red
    Write-Host "  Please install Git from: https://git-scm.com/" -ForegroundColor Red
    exit 1
}

# Kiểm tra Git config
Write-Host ""
Write-Host "[2/8] Checking Git configuration..." -ForegroundColor Yellow
$userName = git config --global user.name
$userEmail = git config --global user.email

if ([string]::IsNullOrEmpty($userName) -or [string]::IsNullOrEmpty($userEmail)) {
    Write-Host "✗ Git user not configured!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please configure Git with your information:" -ForegroundColor Yellow
    Write-Host "  git config --global user.name `"Your Name`"" -ForegroundColor White
    Write-Host "  git config --global user.email `"your.email@example.com`"" -ForegroundColor White
    Write-Host ""
    
    $configure = Read-Host "Do you want to configure now? (y/n)"
    if ($configure -eq "y") {
        $name = Read-Host "Enter your name"
        $email = Read-Host "Enter your email"
        git config --global user.name $name
        git config --global user.email $email
        Write-Host "✓ Git configured successfully!" -ForegroundColor Green
    } else {
        exit 1
    }
} else {
    Write-Host "✓ Git user: $userName <$userEmail>" -ForegroundColor Green
}

# Khởi tạo Git repository
Write-Host ""
Write-Host "[3/8] Initializing Git repository..." -ForegroundColor Yellow
if (Test-Path ".git") {
    Write-Host "✓ Git repository already exists" -ForegroundColor Green
} else {
    git init
    Write-Host "✓ Git repository initialized" -ForegroundColor Green
}

# Kiểm tra remote
Write-Host ""
Write-Host "[4/8] Checking remote repository..." -ForegroundColor Yellow
$remoteUrl = "git@github.com:buithan04/Health_IoT.git"

try {
    $existingRemote = git remote get-url origin 2>$null
    if ($existingRemote -eq $remoteUrl) {
        Write-Host "✓ Remote 'origin' already configured: $remoteUrl" -ForegroundColor Green
    } else {
        Write-Host "! Remote 'origin' exists with different URL: $existingRemote" -ForegroundColor Yellow
        $updateRemote = Read-Host "Update remote URL? (y/n)"
        if ($updateRemote -eq "y") {
            git remote set-url origin $remoteUrl
            Write-Host "✓ Remote URL updated" -ForegroundColor Green
        }
    }
} catch {
    git remote add origin $remoteUrl
    Write-Host "✓ Remote 'origin' added: $remoteUrl" -ForegroundColor Green
}

# Kiểm tra các file sẽ được commit
Write-Host ""
Write-Host "[5/8] Checking files to commit..." -ForegroundColor Yellow
Write-Host ""

# Kiểm tra xem có file nào sẽ bị commit không
git add -n .
Write-Host ""

$confirm = Read-Host "Do you want to see all files that will be committed? (y/n)"
if ($confirm -eq "y") {
    Write-Host ""
    git status
    Write-Host ""
}

# Xác nhận commit
Write-Host ""
Write-Host "[6/8] Ready to commit..." -ForegroundColor Yellow
$proceed = Read-Host "Proceed with commit? (y/n)"

if ($proceed -ne "y") {
    Write-Host "✗ Operation cancelled" -ForegroundColor Red
    exit 0
}

# Add files
Write-Host ""
Write-Host "Adding files..." -ForegroundColor Yellow
git add .

# Tạo commit message
Write-Host ""
Write-Host "Enter commit message (or press Enter for default):" -ForegroundColor Yellow
$commitMessage = Read-Host "Commit message"

if ([string]::IsNullOrEmpty($commitMessage)) {
    $commitMessage = "feat: initial commit with Flutter app, Node.js backend, and Admin portal

- Add Flutter mobile app with patient and doctor features
- Add Node.js backend API with Socket.IO and MQTT
- Add Next.js admin portal
- Configure video/audio calls with ZegoCloud
- Implement real-time chat functionality
- Add comprehensive documentation and setup guides"
}

# Commit
Write-Host ""
Write-Host "[7/8] Creating commit..." -ForegroundColor Yellow
git commit -m $commitMessage
Write-Host "✓ Commit created successfully" -ForegroundColor Green

# Push to GitHub
Write-Host ""
Write-Host "[8/8] Pushing to GitHub..." -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  IMPORTANT: Make sure you have:" -ForegroundColor Yellow
Write-Host "   1. Created the repository on GitHub: https://github.com/buithan04/Health_IoT" -ForegroundColor White
Write-Host "   2. Set up SSH key or GitHub credentials" -ForegroundColor White
Write-Host ""

$pushConfirm = Read-Host "Push to GitHub now? (y/n)"

if ($pushConfirm -eq "y") {
    try {
        # Kiểm tra xem branch main đã tồn tại chưa
        $currentBranch = git branch --show-current
        
        if ($currentBranch -ne "main") {
            # Đổi tên branch hiện tại thành main
            git branch -M main
        }
        
        # Push với -u để set upstream
        git push -u origin main
        
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Green
        Write-Host "  ✓ SUCCESS!" -ForegroundColor Green
        Write-Host "============================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Your code has been pushed to GitHub!" -ForegroundColor Green
        Write-Host "Repository: https://github.com/buithan04/Health_IoT" -ForegroundColor Cyan
        Write-Host ""
        
    } catch {
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Red
        Write-Host "  ✗ PUSH FAILED" -ForegroundColor Red
        Write-Host "============================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Error: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Common solutions:" -ForegroundColor Yellow
        Write-Host "1. Make sure the repository exists on GitHub" -ForegroundColor White
        Write-Host "2. Check your SSH key: ssh -T git@github.com" -ForegroundColor White
        Write-Host "3. Or use HTTPS instead:" -ForegroundColor White
        Write-Host "   git remote set-url origin https://github.com/buithan04/Health_IoT.git" -ForegroundColor White
        Write-Host ""
        exit 1
    }
} else {
    Write-Host ""
    Write-Host "✓ Commit created but not pushed" -ForegroundColor Yellow
    Write-Host "You can push later with: git push -u origin main" -ForegroundColor White
    Write-Host ""
}

Write-Host "Done! 🎉" -ForegroundColor Green
