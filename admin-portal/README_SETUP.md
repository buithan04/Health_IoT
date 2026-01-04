# 🚀 HƯỚNG DẪN CHẠY ADMIN PORTAL

## 📋 Yêu cầu Hệ thống

- Node.js 18+ 
- npm hoặc yarn
- Backend server đang chạy tại `http://192.168.5.47:5000`

---

## 🔧 Cài đặt

### 1. Cài đặt dependencies

```bash
cd admin-portal
npm install
```

### 2. Cấu hình API URL

Kiểm tra file `src/utils/api.ts`:

```typescript
export const API_BASE_URL = 'http://192.168.5.47:5000/api';
```

Nếu backend của bạn chạy ở địa chỉ khác, hãy update URL này.

### 3. Chạy Development Server

```bash
npm run dev
```

Server sẽ chạy tại: **http://localhost:3000**

---

## 🔐 Đăng nhập

### Trang login: `http://localhost:3000/login`

**Thông tin đăng nhập admin:**
- Email: `admin@healthai.com`
- Password: `admin123` (hoặc theo database của bạn)

Sau khi đăng nhập thành công:
- Token sẽ được lưu vào `localStorage` với key `adminToken`
- Tự động redirect về Dashboard

---

## 📁 Cấu trúc Project

```
admin-portal/
├── src/
│   ├── app/
│   │   ├── (dashboard)/           # Dashboard layout group
│   │   │   ├── page.tsx           # ✨ Dashboard chính
│   │   │   ├── users/
│   │   │   │   └── page.tsx       # ✨ Quản lý Users
│   │   │   ├── doctors/
│   │   │   │   └── page.tsx       # Quản lý Bác sĩ
│   │   │   ├── patients/
│   │   │   ├── appointments/
│   │   │   ├── prescriptions/
│   │   │   ├── medications/
│   │   │   └── settings/
│   │   └── login/
│   │       └── page.tsx           # Trang login
│   │
│   ├── components/
│   │   ├── dashboard/             # ✨ Dashboard components
│   │   │   ├── StatsCard.tsx
│   │   │   ├── ActivityItem.tsx
│   │   │   └── QuickStatCard.tsx
│   │   ├── ui/                    # Radix UI components
│   │   │   ├── badge.tsx          # ✨ NEW
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   ├── input.tsx
│   │   │   └── ...
│   │   ├── Header.tsx             # ✨ Updated
│   │   └── Sidebar.tsx            # ✨ Updated
│   │
│   ├── utils/
│   │   └── api.ts                 # API helper functions
│   │
│   └── lib/
│       └── utils.ts               # Utility functions
│
├── public/                        # Static assets
├── CHANGELOG.md                   # ✨ Tài liệu các cải tiến
├── ADMIN_IMPROVEMENTS.md          # ✨ Chi tiết improvements
├── package.json
└── tailwind.config.ts
```

---

## 🎨 Các Trang Đã Nâng cấp

### 1. ✨ Dashboard (`/`)
- Stats cards với real-time data
- Activity feed với status icons
- Quick stats sidebar
- Auto-refresh every 30s
- Manual refresh button

**APIs sử dụng:**
- `GET /api/admin/dashboard/stats`
- `GET /api/admin/dashboard/activities`
- `GET /api/admin/users`
- `GET /api/admin/appointments`

### 2. ✨ Users Management (`/users`)
- Danh sách users với filters
- Search functionality
- Role & status filters
- Stats cards

**APIs sử dụng:**
- `GET /api/admin/users?role={role}&isVerified={bool}&search={query}`

### 3. 🔄 Doctors (đang có sẵn)
- Trang quản lý bác sĩ đã tồn tại
- Có thể nâng cấp tương tự users page

### 4. 🔄 Các trang khác
- Appointments
- Prescriptions
- Medications
- Settings

---

## 🛠️ Các Scripts

```bash
# Development
npm run dev          # Chạy dev server với hot-reload

# Production
npm run build        # Build production
npm start            # Chạy production server

# Linting
npm run lint         # Kiểm tra code với ESLint
```

---

## 🔄 Data Flow

### Fetch Data Flow:
```
Component
  ↓
useQuery (React Query)
  ↓
apiCall() function
  ↓
fetch() với Authorization header
  ↓
Backend API
  ↓
Response
  ↓
React Query Cache
  ↓
Component re-render
```

### Authentication Flow:
```
Login Page
  ↓
POST /api/auth/login
  ↓
Receive token
  ↓
Save to localStorage
  ↓
Redirect to Dashboard
  ↓
All API calls include token
  ↓
If 401/403 → Redirect to Login
```

---

## 🎯 Features Chính

### ✅ Đã Hoàn thành:
- [x] Modern UI với Tailwind CSS
- [x] React Query integration
- [x] Auto-refresh data
- [x] Loading states
- [x] Error handling
- [x] Responsive design
- [x] Authentication flow
- [x] Stats cards với animations
- [x] Activity feed với status icons
- [x] Search & filters
- [x] Notifications dropdown
- [x] User menu
- [x] Reusable components

### 🚧 Có thể Phát triển:
- [ ] Charts/Graphs
- [ ] Real-time WebSocket
- [ ] Export reports
- [ ] Image upload
- [ ] Dark mode
- [ ] Advanced filters
- [ ] Pagination
- [ ] Bulk actions

---

## 🐛 Troubleshooting

### 1. **TypeScript errors về Badge component**

**Giải pháp:**
```bash
# Restart TypeScript server trong VS Code
Ctrl/Cmd + Shift + P → "TypeScript: Restart TS Server"
```

### 2. **API connection errors**

**Kiểm tra:**
- Backend server đang chạy?
- URL trong `src/utils/api.ts` đúng chưa?
- CORS đã được config ở backend?

**Backend CORS config:**
```javascript
// Backend app.js hoặc server.js
app.use(cors({
  origin: 'http://localhost:3000',
  credentials: true
}));
```

### 3. **Auto-refresh không hoạt động**

**Kiểm tra:**
- React Query đã được setup trong app?
- QueryClient đã wrap App component?

```typescript
// src/app/layout.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const queryClient = new QueryClient();

export default function RootLayout({ children }) {
  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}
```

### 4. **Login redirect loop**

**Giải pháp:**
- Clear localStorage: `localStorage.clear()`
- Clear browser cookies
- Kiểm tra token validation ở backend

### 5. **Styles không hiển thị đúng**

**Giải pháp:**
```bash
# Clear Next.js cache
rm -rf .next
npm run dev
```

---

## 📚 Resources

### Documentation:
- [Next.js Docs](https://nextjs.org/docs)
- [React Query Docs](https://tanstack.com/query/latest)
- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [Lucide Icons](https://lucide.dev)
- [Radix UI](https://www.radix-ui.com)

### Project Docs:
- [CHANGELOG.md](./CHANGELOG.md) - Chi tiết tất cả cải tiến
- [ADMIN_IMPROVEMENTS.md](./ADMIN_IMPROVEMENTS.md) - Tài liệu improvements

---

## 🤝 Contributing

### Code Style:
- TypeScript strict mode
- Tailwind CSS cho styling
- Components theo atomic design
- React hooks best practices

### Git Workflow:
```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Commit changes
git commit -m "feat: add your feature"

# Push to remote
git push origin feature/your-feature-name
```

---

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra [Troubleshooting](#-troubleshooting)
2. Xem [CHANGELOG.md](./CHANGELOG.md)
3. Check console logs (F12)
4. Verify backend API responses

---

## 🎉 Happy Coding!

Admin Portal đã sẵn sàng để sử dụng! 🚀

Để xem chi tiết các cải tiến, đọc file [CHANGELOG.md](./CHANGELOG.md)
