# 🚀 QUICK START GUIDE

## ⚡ Chạy Project (3 bước)

```bash
# 1. Install
cd admin-portal
npm install

# 2. Run
npm run dev

# 3. Open browser
# http://localhost:3000
```

---

## 🎯 Điểm Nổi bật

### ✨ Dashboard Mới
- **4 stats cards** với màu sắc đẹp, animations, và real data
- **Activity feed** với status icons (🟢🟡🔴) và timestamps
- **Quick stats** sidebar với metrics bổ sung
- **Auto-refresh** every 30 seconds
- **Manual refresh** button

### 📊 Data từ Backend
```
GET /api/admin/dashboard/stats        → Stats cards
GET /api/admin/dashboard/activities   → Activity feed
GET /api/admin/users                  → Users list
GET /api/admin/appointments           → Appointments
```

### 🎨 Giao diện
- **Gradient headers** (blue → purple)
- **Colored borders** theo function
- **Hover effects** (scale, shadow)
- **Status badges** với màu sắc
- **Responsive** cho mọi màn hình

---

## 📁 Files Quan trọng

```
src/
├── app/(dashboard)/
│   ├── page.tsx              ← ✨ DASHBOARD MỚI
│   └── users/page.tsx        ← ✨ USERS MỚI
│
├── components/
│   ├── dashboard/            ← ✨ COMPONENTS MỚI
│   │   ├── StatsCard.tsx
│   │   ├── ActivityItem.tsx
│   │   └── QuickStatCard.tsx
│   ├── ui/badge.tsx          ← ✨ MỚI
│   ├── Header.tsx            ← ✨ CẬP NHẬT
│   └── Sidebar.tsx           ← ✨ CẬP NHẬT
│
└── utils/api.ts              ← API helper
```

---

## 🔧 Fix TypeScript Errors

Nếu thấy errors về Badge component:

**Option 1: Restart TS Server**
```
Ctrl/Cmd + Shift + P
→ "TypeScript: Restart TS Server"
```

**Option 2: Reload VS Code**
```
Ctrl/Cmd + Shift + P
→ "Developer: Reload Window"
```

**Option 3: Clear cache**
```bash
rm -rf .next
npm run dev
```

---

## 🎨 Color Guide

```typescript
// Stats Cards
Blue:    users, default       #2563eb
Emerald: doctors, success     #10b981
Purple:  appointments          #8b5cf6
Amber:   prescriptions        #f59e0b

// Status Colors
Green:   success, completed   #22c55e
Yellow:  pending, warning     #eab308
Red:     failed, cancelled    #ef4444
```

---

## 📊 Component Examples

### StatsCard
```tsx
<StatsCard
  title="Tổng Người dùng"
  value={120}
  icon={Users}
  color="text-blue-600"
  bg="bg-blue-50"
  border="border-blue-200"
  change="+12%"
  changeType="increase"
  description="Tổng số người dùng hệ thống"
  link="/users"
/>
```

### ActivityItem
```tsx
<ActivityItem
  activity={{
    user_name: "Nguyễn Văn A",
    action: "Đặt lịch khám",
    user_email: "user@mail.com",
    status: "success",
    timestamp: "2026-01-02T10:30:00Z"
  }}
/>
```

---

## 🔐 Authentication

```typescript
// Login saves token
localStorage.setItem('adminToken', token);

// API calls use token
headers: {
  'Authorization': `Bearer ${token}`
}

// Logout clears token
localStorage.removeItem('adminToken');
window.location.href = '/login';
```

---

## 📱 Responsive Breakpoints

```css
sm: 640px   /* Mobile */
md: 768px   /* Tablet */
lg: 1024px  /* Desktop */
xl: 1280px  /* Large Desktop */
```

---

## 🐛 Common Issues

### ❌ "Cannot find module '@/components/ui/badge'"
✅ File exists, just restart TS server

### ❌ "Network error"
✅ Check backend running at http://192.168.5.47:5000

### ❌ "Unauthorized"
✅ Login again, token might be expired

### ❌ "No data showing"
✅ Check API responses in Network tab (F12)

---

## 📚 Documentation

- [CHANGELOG.md](./CHANGELOG.md) - Chi tiết tất cả changes
- [README_SETUP.md](./README_SETUP.md) - Hướng dẫn setup đầy đủ
- [SUMMARY.md](./SUMMARY.md) - Visual summary
- [ADMIN_IMPROVEMENTS.md](./ADMIN_IMPROVEMENTS.md) - Technical details

---

## ✅ Testing Checklist

```
□ npm run dev chạy thành công
□ http://localhost:3000 mở được
□ Login thành công
□ Dashboard hiển thị stats cards
□ Activity feed có data
□ Auto-refresh hoạt động (30s)
□ Manual refresh button works
□ Users page có data
□ Search/filters hoạt động
□ Sidebar navigation works
□ Notifications dropdown shows
□ User menu works
□ Logout redirects to login
```

---

## 🎉 That's it!

Admin Portal đã sẵn sàng. Happy coding! 🚀

**Có vấn đề?** Check [CHANGELOG.md](./CHANGELOG.md) hoặc console logs (F12)
