# Test Admin Dashboard APIs

Write-Host "🧪 Testing Admin Dashboard APIs..." -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://192.168.5.47:5000/api/admin"
$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NywiZW1haWwiOiJ0aGFuLjk1LmN2YW5AZ21haWwuY29tIiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzM1ODE1Mjg5LCJleHAiOjE3Mzg0MDcyODl9.VD5i3A3GXDlUWKZ8Yr1RDQUfUu-NmF7J9WYLn4Y2KZU"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Test 1: Dashboard Stats
Write-Host "📊 Test 1: GET /dashboard/stats" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/dashboard/stats" -Headers $headers -Method Get
    Write-Host "✅ Success!" -ForegroundColor Green
    Write-Host "Stats:" -ForegroundColor White
    $response | ConvertTo-Json -Depth 3
    Write-Host ""
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test 2: Recent Activities
Write-Host "📋 Test 2: GET /dashboard/activities" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/dashboard/activities" -Headers $headers -Method Get
    Write-Host "✅ Success!" -ForegroundColor Green
    Write-Host "Activities count: $($response.activities.Count)" -ForegroundColor White
    if ($response.activities.Count -gt 0) {
        Write-Host "First activity:" -ForegroundColor White
        $response.activities[0] | ConvertTo-Json -Depth 2
    }
    Write-Host ""
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test 3: Get All Users
Write-Host "👥 Test 3: GET /users" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/users" -Headers $headers -Method Get
    Write-Host "✅ Success!" -ForegroundColor Green
    Write-Host "Total users: $($response.users.Count)" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test 4: Get All Doctors
Write-Host "👨‍⚕️ Test 4: GET /doctors" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/doctors" -Headers $headers -Method Get
    Write-Host "✅ Success!" -ForegroundColor Green
    Write-Host "Total doctors: $($response.doctors.Count)" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

Write-Host "✨ Testing completed!" -ForegroundColor Cyan
