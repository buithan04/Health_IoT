# 🖥️ WEB ADMIN - TÀI LIỆU NEXT.JS DASHBOARD

> **Admin Portal cho hệ thống Health_IoT - Next.js 14 + TypeScript**

---

## 📋 MỤC LỤC

- [1. Tổng Quan](#1-tổng-quan)
- [2. Tech Stack](#2-tech-stack)
- [3. Cấu Trúc Dự Án](#3-cấu-trúc-dự-án)
- [4. App Router Structure](#4-app-router-structure)
- [5. Components](#5-components)
- [6. API Integration](#6-api-integration)
- [7. Features](#7-features)
- [8. Deployment](#8-deployment)

---

## 1. TỔNG QUAN

### 1.1 Giới Thiệu

**Web Admin** là trang quản trị web cho hệ thống Health_IoT, được xây dựng với Next.js 14 App Router và TypeScript.

### 1.2 Thông Tin Dự Án

| Thuộc tính | Giá trị |
|------------|---------|
| **Framework** | Next.js 14.2.15 |
| **Language** | TypeScript 5 |
| **Runtime** | Node.js 20+ |
| **Package Manager** | npm |
| **UI Library** | Radix UI + shadcn/ui |
| **Styling** | Tailwind CSS 3.4 |

### 1.3 Tính Năng Chính

✅ **Dashboard Analytics**: Thống kê người dùng, lịch hẹn, doanh thu  
✅ **User Management**: Quản lý bệnh nhân, bác sĩ, admin  
✅ **Appointment Management**: Giám sát và quản lý lịch hẹn  
✅ **Medication Database**: Cơ sở dữ liệu thuốc toàn diện  
✅ **Prescription Management**: Xem và xuất đơn thuốc  
✅ **Reports & Analytics**: Báo cáo Excel, biểu đồ  
✅ **System Configuration**: Cấu hình MQTT, email, thông báo  

---

## 2. TECH STACK

### 2.1 Core Dependencies

```json
{
  "dependencies": {
    // Framework
    "next": "^14.2.15",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    
    // UI Components (Radix UI)
    "@radix-ui/react-alert-dialog": "^1.1.15",
    "@radix-ui/react-avatar": "^1.1.11",
    "@radix-ui/react-dialog": "^1.1.15",
    "@radix-ui/react-dropdown-menu": "^2.1.16",
    "@radix-ui/react-label": "^2.1.8",
    "@radix-ui/react-select": "^2.2.6",
    "@radix-ui/react-separator": "^1.1.8",
    "@radix-ui/react-slot": "^1.2.4",
    
    // State Management & Data Fetching
    "@tanstack/react-query": "^5.90.16",
    "@tanstack/react-table": "^8.21.3",
    
    // Styling
    "tailwindcss": "^3.4.14",
    "tailwindcss-animate": "^1.0.7",
    "class-variance-authority": "^0.7.1",
    "clsx": "^2.1.1",
    "tailwind-merge": "^3.4.0",
    
    // Icons & Utilities
    "lucide-react": "^0.562.0",
    "react-icons": "^5.5.0",
    "date-fns": "^4.1.0",
    "sonner": "^2.0.7",          // Toast notifications
    "xlsx": "^0.18.5"            // Excel export
  },
  "devDependencies": {
    "@types/node": "^20",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "typescript": "^5",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.4.47",
    "eslint": "^8",
    "eslint-config-next": "^14.2.15"
  }
}
```

### 2.2 Key Technologies

#### Next.js 14 App Router
- **File-based routing**: `app/dashboard/users/page.tsx`
- **Server Components**: RSC by default
- **Server Actions**: Form handling
- **Layouts**: Nested layouts
- **Route Groups**: `(auth)`, `(dashboard)`

#### TypeScript
- **Type Safety**: Compile-time error detection
- **Interfaces**: API response types
- **Generics**: Reusable components
- **Strict Mode**: `strict: true` in `tsconfig.json`

#### Radix UI + shadcn/ui
- **Accessible**: WCAG compliant
- **Unstyled**: Full customization with Tailwind
- **Composable**: Build complex UIs
- **TypeScript**: Built-in types

#### TanStack Query (React Query)
- **Data Fetching**: `useQuery`, `useMutation`
- **Caching**: Automatic cache invalidation
- **Background Updates**: Refetch on focus
- **Error Handling**: Retry logic

#### Tailwind CSS
- **Utility-First**: Rapid development
- **JIT Compiler**: On-demand CSS generation
- **Custom Theme**: Colors, spacing, fonts
- **Responsive**: Mobile-first design

---

## 3. CẤU TRÚC DỰ ÁN

```
Web_admin/
├── src/
│   ├── app/                          # Next.js 14 App Router
│   │   ├── layout.tsx                # Root layout (HTML wrapper)
│   │   ├── page.tsx                  # Home page (redirect)
│   │   ├── globals.css               # Global Tailwind CSS
│   │   ├── providers.tsx             # Context providers
│   │   │
│   │   ├── auth/                     # Authentication
│   │   │   └── login/
│   │   │       └── page.tsx          # Login page
│   │   │
│   │   └── dashboard/                # Dashboard routes
│   │       ├── layout.tsx            # Dashboard layout (Sidebar + Header)
│   │       ├── page.tsx              # Main dashboard (Analytics)
│   │       │
│   │       ├── users/                # User Management
│   │       │   └── page.tsx
│   │       │
│   │       ├── doctors/              # Doctor Management
│   │       │   └── page.tsx
│   │       │
│   │       ├── patients/             # Patient Management
│   │       │   └── page.tsx
│   │       │
│   │       ├── appointments/         # Appointments
│   │       │   └── page.tsx
│   │       │
│   │       ├── prescriptions/        # Prescriptions
│   │       │   └── page.tsx
│   │       │
│   │       ├── medications/          # Medication Database
│   │       │   └── page.tsx
│   │       │
│   │       └── analytics/            # Reports & Analytics
│   │           └── page.tsx
│   │
│   ├── components/                   # React Components
│   │   ├── ui/                       # shadcn/ui primitives
│   │   │   ├── button.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── dropdown-menu.tsx
│   │   │   ├── input.tsx
│   │   │   ├── label.tsx
│   │   │   ├── select.tsx
│   │   │   ├── table.tsx
│   │   │   ├── tabs.tsx
│   │   │   ├── toast.tsx
│   │   │   └── ... (30+ components)
│   │   │
│   │   ├── dashboard/                # Dashboard components
│   │   │   ├── stats-card.tsx
│   │   │   ├── user-table.tsx
│   │   │   ├── appointment-table.tsx
│   │   │   └── revenue-chart.tsx
│   │   │
│   │   ├── modals/                   # Modal dialogs
│   │   │   ├── edit-user-modal.tsx
│   │   │   ├── delete-confirmation.tsx
│   │   │   └── ...
│   │   │
│   │   ├── Sidebar.tsx               # Navigation sidebar
│   │   └── Header.tsx                # Top header bar
│   │
│   ├── lib/                          # Utilities & Helpers
│   │   ├── utils.ts                  # cn() function, formatters
│   │   ├── api.ts                    # API client
│   │   └── constants.ts              # Constants
│   │
│   └── types/                        # TypeScript Types
│       ├── user.ts
│       ├── doctor.ts
│       ├── appointment.ts
│       ├── prescription.ts
│       └── api.ts
│
├── public/                           # Static Files
│   ├── favicon.ico
│   ├── logo.png
│   └── templates/
│       └── prescription-template.xlsx
│
├── .env.local                        # Environment variables (DO NOT COMMIT)
├── components.json                   # shadcn/ui config
├── next.config.mjs                   # Next.js config
├── tailwind.config.ts                # Tailwind config
├── tsconfig.json                     # TypeScript config
├── postcss.config.mjs                # PostCSS config
├── eslint.config.mjs                 # ESLint config
├── package.json                      # Dependencies
└── README.md                         # Documentation
```

---

## 4. APP ROUTER STRUCTURE

### 4.1 Root Layout

```tsx
// app/layout.tsx
import './globals.css';
import { Inter } from 'next/font/google';
import { Providers } from './providers';

const inter = Inter({ subsets: ['latin'] });

export const metadata = {
  title: 'Health IoT Admin',
  description: 'Admin portal for Health IoT system',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

### 4.2 Dashboard Layout

```tsx
// app/dashboard/layout.tsx
import Sidebar from '@/components/Sidebar';
import Header from '@/components/Header';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex h-screen overflow-hidden">
      <Sidebar />
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header />
        <main className="flex-1 overflow-y-auto bg-gray-50 p-6">
          {children}
        </main>
      </div>
    </div>
  );
}
```

### 4.3 Page Examples

#### Main Dashboard
```tsx
// app/dashboard/page.tsx
'use client';

import { useQuery } from '@tanstack/react-query';
import { StatsCard } from '@/components/dashboard/stats-card';
import { RevenueChart } from '@/components/dashboard/revenue-chart';
import { fetchDashboardStats } from '@/lib/api';

export default function DashboardPage() {
  const { data: stats, isLoading } = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: fetchDashboardStats,
  });

  if (isLoading) return <div>Loading...</div>;

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
      
      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatsCard
          title="Total Users"
          value={stats.totalUsers}
          icon="users"
          trend="+12%"
        />
        <StatsCard
          title="Patients"
          value={stats.totalPatients}
          icon="user"
        />
        <StatsCard
          title="Doctors"
          value={stats.totalDoctors}
          icon="stethoscope"
        />
        <StatsCard
          title="Appointments"
          value={stats.totalAppointments}
          icon="calendar"
          trend="+5%"
        />
      </div>

      {/* Revenue Chart */}
      <RevenueChart data={stats.revenueData} />
    </div>
  );
}
```

#### User Management
```tsx
// app/dashboard/users/page.tsx
'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { DataTable } from '@/components/ui/data-table';
import { Button } from '@/components/ui/button';
import { fetchUsers, deleteUser } from '@/lib/api';
import { columns } from './columns';

export default function UsersPage() {
  const queryClient = useQueryClient();
  
  const { data: users, isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
  });

  const deleteMutation = useMutation({
    mutationFn: deleteUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold">User Management</h1>
        <Button>Add User</Button>
      </div>

      <DataTable
        columns={columns}
        data={users || []}
        loading={isLoading}
      />
    </div>
  );
}
```

---

## 5. COMPONENTS

### 5.1 shadcn/ui Components

#### Button Component
```tsx
// components/ui/button.tsx
import * as React from 'react';
import { Slot } from '@radix-ui/react-slot';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-blue-600 text-white hover:bg-blue-700',
        destructive: 'bg-red-600 text-white hover:bg-red-700',
        outline: 'border border-gray-300 bg-white hover:bg-gray-50',
        ghost: 'hover:bg-gray-100',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 px-3',
        lg: 'h-11 px-8',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : 'button';
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    );
  }
);

Button.displayName = 'Button';

export { Button, buttonVariants };
```

**Usage**:
```tsx
<Button variant="default">Save</Button>
<Button variant="destructive">Delete</Button>
<Button variant="outline">Cancel</Button>
<Button variant="ghost" size="icon">
  <Icon />
</Button>
```

#### Dialog Component
```tsx
// components/ui/dialog.tsx
import * as React from 'react';
import * as DialogPrimitive from '@radix-ui/react-dialog';
import { X } from 'lucide-react';
import { cn } from '@/lib/utils';

const Dialog = DialogPrimitive.Root;
const DialogTrigger = DialogPrimitive.Trigger;

const DialogContent = React.forwardRef<
  React.ElementRef<typeof DialogPrimitive.Content>,
  React.ComponentPropsWithoutRef<typeof DialogPrimitive.Content>
>(({ className, children, ...props }, ref) => (
  <DialogPrimitive.Portal>
    <DialogPrimitive.Overlay className="fixed inset-0 bg-black/50" />
    <DialogPrimitive.Content
      ref={ref}
      className={cn(
        'fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4 bg-white p-6 shadow-lg rounded-lg',
        className
      )}
      {...props}
    >
      {children}
      <DialogPrimitive.Close className="absolute right-4 top-4 rounded-sm opacity-70 hover:opacity-100">
        <X className="h-4 w-4" />
      </DialogPrimitive.Close>
    </DialogPrimitive.Content>
  </DialogPrimitive.Portal>
));

export { Dialog, DialogTrigger, DialogContent };
```

**Usage**:
```tsx
<Dialog>
  <DialogTrigger asChild>
    <Button>Open Dialog</Button>
  </DialogTrigger>
  <DialogContent>
    <h2>Dialog Title</h2>
    <p>Dialog content goes here...</p>
  </DialogContent>
</Dialog>
```

### 5.2 Custom Components

#### Sidebar
```tsx
// components/Sidebar.tsx
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import {
  LayoutDashboard,
  Users,
  Calendar,
  FileText,
  Pill,
  BarChart,
} from 'lucide-react';

const menuItems = [
  { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/dashboard/users', label: 'Users', icon: Users },
  { href: '/dashboard/appointments', label: 'Appointments', icon: Calendar },
  { href: '/dashboard/prescriptions', label: 'Prescriptions', icon: FileText },
  { href: '/dashboard/medications', label: 'Medications', icon: Pill },
  { href: '/dashboard/analytics', label: 'Analytics', icon: BarChart },
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-64 bg-gray-900 text-white flex flex-col">
      <div className="p-6">
        <h1 className="text-2xl font-bold">Health IoT Admin</h1>
      </div>
      
      <nav className="flex-1 px-4">
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isActive = pathname === item.href;
          
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'flex items-center gap-3 px-4 py-3 rounded-lg mb-1 transition-colors',
                isActive
                  ? 'bg-blue-600 text-white'
                  : 'text-gray-300 hover:bg-gray-800'
              )}
            >
              <Icon className="h-5 w-5" />
              <span>{item.label}</span>
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
```

#### Stats Card
```tsx
// components/dashboard/stats-card.tsx
import { LucideIcon } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

interface StatsCardProps {
  title: string;
  value: number;
  icon: LucideIcon;
  trend?: string;
}

export function StatsCard({ title, value, icon: Icon, trend }: StatsCardProps) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-sm font-medium text-gray-600">
          {title}
        </CardTitle>
        <Icon className="h-4 w-4 text-gray-400" />
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{value.toLocaleString()}</div>
        {trend && (
          <p className="text-xs text-green-600 mt-1">
            {trend} from last month
          </p>
        )}
      </CardContent>
    </Card>
  );
}
```

---

## 6. API INTEGRATION

### 6.1 API Client

```typescript
// lib/api.ts
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api';

interface RequestOptions extends RequestInit {
  token?: string;
}

async function apiRequest<T>(
  endpoint: string,
  options: RequestOptions = {}
): Promise<T> {
  const { token, headers, ...restOptions } = options;
  
  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...restOptions,
    headers: {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
      ...headers,
    },
  });
  
  if (!response.ok) {
    throw new Error(`API error: ${response.statusText}`);
  }
  
  return response.json();
}

// GET request
export async function get<T>(endpoint: string, token?: string): Promise<T> {
  return apiRequest<T>(endpoint, { method: 'GET', token });
}

// POST request
export async function post<T>(
  endpoint: string,
  data: any,
  token?: string
): Promise<T> {
  return apiRequest<T>(endpoint, {
    method: 'POST',
    body: JSON.stringify(data),
    token,
  });
}

// PUT request
export async function put<T>(
  endpoint: string,
  data: any,
  token?: string
): Promise<T> {
  return apiRequest<T>(endpoint, {
    method: 'PUT',
    body: JSON.stringify(data),
    token,
  });
}

// DELETE request
export async function del<T>(endpoint: string, token?: string): Promise<T> {
  return apiRequest<T>(endpoint, { method: 'DELETE', token });
}
```

### 6.2 API Functions

```typescript
// lib/api.ts (continued)
import { User, Doctor, Appointment } from '@/types';

// Dashboard
export const fetchDashboardStats = () => get('/admin/dashboard');

// Users
export const fetchUsers = () => get<User[]>('/admin/users');
export const deleteUser = (id: number) => del(`/admin/users/${id}`);

// Doctors
export const fetchDoctors = () => get<Doctor[]>('/doctors');
export const updateDoctor = (id: number, data: Partial<Doctor>) =>
  put(`/admin/doctors/${id}`, data);

// Appointments
export const fetchAppointments = () => get<Appointment[]>('/admin/appointments');
export const updateAppointmentStatus = (id: number, status: string) =>
  put(`/admin/appointments/${id}/status`, { status });
```

### 6.3 React Query Usage

```tsx
// Example: Fetch and mutate data
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { fetchUsers, deleteUser } from '@/lib/api';
import { toast } from 'sonner';

export function UserList() {
  const queryClient = useQueryClient();

  // Fetch users
  const { data: users, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
    refetchOnWindowFocus: true,
    staleTime: 5 * 60 * 1000, // 5 minutes
  });

  // Delete user mutation
  const deleteMutation = useMutation({
    mutationFn: deleteUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      toast.success('User deleted successfully');
    },
    onError: (error) => {
      toast.error(`Error: ${error.message}`);
    },
  });

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div>
      {users?.map((user) => (
        <div key={user.id}>
          <span>{user.fullName}</span>
          <button onClick={() => deleteMutation.mutate(user.id)}>
            Delete
          </button>
        </div>
      ))}
    </div>
  );
}
```

---

## 7. FEATURES

### 7.1 Dashboard Analytics

**Key Metrics**:
- Total users (patients + doctors + admins)
- Appointments (pending, confirmed, completed, cancelled)
- Revenue trends
- System health

**Components**:
- Stats cards with icons
- Line/bar charts (Chart.js or Recharts)
- Recent activity feed
- Quick actions

### 7.2 User Management

**Features**:
- View all users (paginated table)
- Filter by role (patient, doctor, admin)
- Search by name/email
- Edit user details
- Delete users (with confirmation)
- Export to Excel

**Table Columns**:
- ID, Full Name, Email, Role, Created At, Actions

### 7.3 Appointment Management

**Features**:
- View all appointments
- Filter by status, date, doctor
- Update status (pending → confirmed → completed)
- Cancel appointments
- View appointment details (patient, doctor, notes)
- Export reports

### 7.4 Excel Export

```typescript
// lib/excel-export.ts
import * as XLSX from 'xlsx';

export function exportToExcel(data: any[], filename: string) {
  const worksheet = XLSX.utils.json_to_sheet(data);
  const workbook = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(workbook, worksheet, 'Sheet1');
  
  XLSX.writeFile(workbook, `${filename}.xlsx`);
}

// Usage
exportToExcel(users, 'users_export');
```

---

## 8. DEPLOYMENT

### 8.1 Environment Variables

```env
# .env.local
NEXT_PUBLIC_API_URL=https://api.healthiot.com/api
NEXT_PUBLIC_APP_NAME=Health IoT Admin
NEXT_PUBLIC_DEBUG=false
```

### 8.2 Build & Run

```bash
# Development
npm run dev

# Production build
npm run build

# Production server
npm start
```

### 8.3 Deploy to Vercel

```bash
vercel login
vercel
vercel --prod
```

**Environment Variables in Vercel**:
- Go to Project Settings → Environment Variables
- Add `NEXT_PUBLIC_API_URL`

---

**✅ HOÀN THÀNH TÀI LIỆU WEB ADMIN!**
