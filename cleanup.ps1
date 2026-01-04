# Project Cleanup Script
Set-Location e:\Fluter

Write-Host "Starting project cleanup..." -ForegroundColor Green

# Backend cleanup
Write-Host "`nCleaning Backend (HealthAI_Server)..." -ForegroundColor Yellow
Set-Location e:\Fluter\HealthAI_Server

# Delete test files and coverage
Remove-Item -Recurse -Force coverage -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force tests -ErrorAction SilentlyContinue
Remove-Item -Force check_db_structure.js -ErrorAction SilentlyContinue
Remove-Item -Force test_admin_apis.ps1 -ErrorAction SilentlyContinue

Write-Host "Backend cleaned!" -ForegroundColor Green

# Frontend cleanup
Write-Host "`nCleaning Frontend (doan2)..." -ForegroundColor Yellow
Set-Location e:\Fluter\doan2

# Delete coverage and exportToHTML
Remove-Item -Recurse -Force coverage -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force exportToHTML -ErrorAction SilentlyContinue
Remove-Item -Force flutter_01.png -ErrorAction SilentlyContinue

Write-Host "Frontend cleaned!" -ForegroundColor Green

# Git operations
Write-Host "`nCommitting changes..." -ForegroundColor Yellow
Set-Location e:\Fluter

git add -A
git status

Write-Host "`nCleanup complete! Ready to commit." -ForegroundColor Green
Write-Host "Run: git commit -m 'Clean: Remove test files, coverage, and unnecessary files' && git push" -ForegroundColor Cyan
