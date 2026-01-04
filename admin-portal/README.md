# 🖥️ Health IoT - Admin Portal

<div align="center">

![Next.js](https://img.shields.io/badge/Next.js-14-black?logo=next.js)
![TypeScript](https://img.shields.io/badge/TypeScript-5-blue?logo=typescript)
![React](https://img.shields.io/badge/React-18-61DAFB?logo=react)
![Tailwind](https://img.shields.io/badge/Tailwind-3.4-38B2AC?logo=tailwind-css)

**Modern admin dashboard for healthcare management with analytics, user management, and reporting**

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Development](#-development)
- [Building](#-building)
- [Deployment](#-deployment)
- [Project Structure](#-project-structure)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Overview

**Health IoT Admin Portal** is a comprehensive Next.js 14 web application for healthcare administrators featuring:

- 📊 **Analytics Dashboard** - Real-time statistics and insights
- 👥 **User Management** - Patients, doctors, and admins
- 📅 **Appointment Oversight** - Monitor all appointments
- 💊 **Medication Database** - Comprehensive drug catalog
- 💳 **Prescription Management** - View and export prescriptions
- 📈 **Reports & Analytics** - Excel exports, revenue tracking
- ⚙️ **System Configuration** - MQTT, email, notification settings
- 🎨 **Modern UI** - Radix UI components with Tailwind CSS

Built with **Next.js 14 App Router**, **TypeScript**, and **shadcn/ui** design system.

---

## ✨ Features

### Dashboard & Analytics 📊

✅ User statistics (patients, doctors, admins)  
✅ Appointment metrics (pending, confirmed, completed, cancelled)  
✅ Revenue tracking and trends  
✅ System health monitoring  
✅ Real-time data with TanStack Query  
✅ Interactive charts and graphs  

### User Management 👥

✅ Patient management (view, edit, delete)  
✅ Doctor management (credentials, specialties, schedules)  
✅ Admin user management  
✅ Role-based access control  
✅ User activity logs  
✅ Export to Excel  

### Appointment Management 📅

✅ View all appointments  
✅ Filter by status, date, doctor  
✅ Update appointment status  
✅ View appointment details  
✅ Export appointment reports  

### Medication Database 💊

✅ Comprehensive drug catalog  
✅ Medication categories  
✅ Manufacturers database  
✅ Active ingredients  
✅ Search and filter  
✅ CRUD operations  

### Prescription Management 💳

✅ View all prescriptions  
✅ Filter by patient, doctor, date  
✅ Prescription details  
✅ Export to Excel  
✅ Prescription analytics  

### Reports & Analytics 📈

✅ Custom date range reports  
✅ Excel export functionality  
✅ Revenue analytics  
✅ Appointment statistics  
✅ User growth charts  
✅ Performance metrics  

---

## 🛠 Tech Stack

### Framework & Language

```json
{
  "framework": "Next.js 14.2.15",
  "language": "TypeScript 5",
  "runtime": "Node.js 20+",
  "package_manager": "npm"
}
```

### Core Libraries

| Package | Version | Purpose |
|---------|---------|---------|
| **next** | ^14.2.15 | React framework |
| **react** | ^18.3.1 | UI library |
| **typescript** | ^5 | Type safety |
| **tailwindcss** | ^3.4.14 | Utility-first CSS |

### UI Components (Radix UI / shadcn/ui)

```json
{
  "@radix-ui/react-dialog": "^1.1.5",
  "@radix-ui/react-dropdown-menu": "^2.1.12",
  "@radix-ui/react-label": "^2.1.2",
  "@radix-ui/react-select": "^2.1.18",
  "@radix-ui/react-slot": "^1.1.2",
  "@radix-ui/react-tabs": "^1.1.3",
  "@radix-ui/react-toast": "^1.2.5"
}
```

### State & Data Management

```json
{
  "@tanstack/react-query": "^5.90.16",
  "@tanstack/react-table": "^8.21.3"
}
```

### Icons & Utilities

```json
{
  "lucide-react": "^0.562.0",
  "xlsx": "^0.18.5",
  "class-variance-authority": "^0.7.1",
  "clsx": "^2.1.1",
  "tailwind-merge": "^2.5.5"
}
```

---

## 📦 Prerequisites

### Required Software

- **Node.js** 20.x or higher ([Download](https://nodejs.org/))
- **npm** 10.x or higher (comes with Node.js)
- **Git** ([Download](https://git-scm.com/))

### Verify Installations

```bash
node --version    # v20.x.x
npm --version     # 10.x.x
git --version     # 2.x.x
```

---

## 🚀 Installation

### 1. Clone Repository

```bash
git clone https://github.com/buithan04/Health_IoT.git
cd Health_IoT/admin-portal
```

### 2. Install Dependencies

```bash
npm install
```

This installs all packages from `package.json`.

### 3. Create Environment File

```bash
# Copy example (if exists)
cp .env.example .env.local

# Or create manually
touch .env.local
```

---

## ⚙️ Configuration

### Environment Variables

Create `.env.local` file in root:

```env
# ========================
# API CONFIGURATION
# ========================
NEXT_PUBLIC_API_URL=http://localhost:5000/api
NEXT_PUBLIC_API_TIMEOUT=10000

# ========================
# AUTHENTICATION
# ========================
NEXT_PUBLIC_JWT_SECRET=your_jwt_secret

# ========================
# APP CONFIGURATION
# ========================
NEXT_PUBLIC_APP_NAME="Health IoT Admin"
NEXT_PUBLIC_APP_VERSION=1.0.0

# ========================
# FEATURES FLAGS
# ========================
NEXT_PUBLIC_ENABLE_ANALYTICS=true
NEXT_PUBLIC_ENABLE_NOTIFICATIONS=true

# ========================
# DEVELOPMENT
# ========================
NEXT_PUBLIC_DEBUG=false
```

**Important Notes:**
- `NEXT_PUBLIC_*` prefix makes variables accessible in browser
- Never commit `.env.local` to Git
- Use different values for production

### API Client Configuration

Edit `src/lib/api.ts`:

```typescript
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api';

export const apiClient = {
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
};
```

---

## 💻 Development

### Start Development Server

```bash
npm run dev
```

**Console output:**
```
▲ Next.js 14.2.15
- Local:        http://localhost:3000
- Network:      http://192.168.1.x:3000

✓ Ready in 2.5s
```

Open [http://localhost:3000](http://localhost:3000) in browser.

### Development Features

- **Fast Refresh** - Changes reflect immediately
- **TypeScript** - Type checking in real-time
- **ESLint** - Code quality checks
- **Tailwind CSS** - JIT compiler

### Available Scripts

```json
{
  "dev": "next dev",           // Development server
  "build": "next build",       // Production build
  "start": "next start",       // Production server
  "lint": "next lint"          // Lint code
}
```

---

## 🏗️ Building

### Production Build

```bash
npm run build
```

**Output:**
```
Route (app)                              Size     First Load JS
┌ ○ /                                    1.2 kB        85.3 kB
├ ○ /auth/login                          2.5 kB        89.6 kB
├ ○ /dashboard                           5.8 kB       112.5 kB
├ ○ /dashboard/users                     8.2 kB       125.8 kB
└ ○ /dashboard/analytics                 6.5 kB       118.9 kB

○  (Static)  automatically rendered as static HTML
```

### Preview Production Build

```bash
npm run build
npm start
```

Server runs at: `http://localhost:3000`

### Build Optimization

Next.js automatically:
- ✅ Minifies JavaScript and CSS
- ✅ Optimizes images
- ✅ Generates static pages
- ✅ Code splitting
- ✅ Tree shaking

---

## 🚢 Deployment

### Deploy to Vercel (Recommended)

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy
vercel

# Production deployment
vercel --prod
```

**Or use Vercel Dashboard:**
1. Import GitHub repository
2. Configure environment variables
3. Click "Deploy"

### Deploy to Netlify

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Build
npm run build

# Deploy
netlify deploy --prod --dir=.next
```

### Self-Hosted (PM2)

```bash
# Build
npm run build

# Install PM2
npm install -g pm2

# Start
pm2 start npm --name "admin-portal" -- start

# Monitor
pm2 monit

# Logs
pm2 logs admin-portal

# Stop
pm2 stop admin-portal
```

### Docker Deployment

Create `Dockerfile`:

```dockerfile
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

CMD ["npm", "start"]
```

```bash
# Build image
docker build -t healthai-admin .

# Run container
docker run -p 3000:3000 healthai-admin
```

---

## 📁 Project Structure

```
admin-portal/
├── src/
│   ├── app/                        # Next.js 14 App Router
│   │   ├── layout.tsx              # Root layout
│   │   ├── page.tsx                # Home page (redirect to dashboard)
│   │   ├── globals.css             # Global styles
│   │   │
│   │   ├── auth/                   # Authentication
│   │   │   └── login/
│   │   │       └── page.tsx        # Login page
│   │   │
│   │   └── dashboard/              # Dashboard pages
│   │       ├── page.tsx            # Main dashboard
│   │       ├── layout.tsx          # Dashboard layout
│   │       │
│   │       ├── users/              # User Management
│   │       │   └── page.tsx
│   │       │
│   │       ├── doctors/            # Doctor Management
│   │       │   └── page.tsx
│   │       │
│   │       ├── patients/           # Patient Management
│   │       │   └── page.tsx
│   │       │
│   │       ├── appointments/       # Appointments
│   │       │   └── page.tsx
│   │       │
│   │       ├── prescriptions/      # Prescriptions
│   │       │   └── page.tsx
│   │       │
│   │       ├── medications/        # Medication Database
│   │       │   └── page.tsx
│   │       │
│   │       └── analytics/          # Reports & Analytics
│   │           └── page.tsx
│   │
│   ├── components/                 # React Components
│   │   ├── ui/                     # shadcn/ui components
│   │   │   ├── button.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── dropdown-menu.tsx
│   │   │   ├── input.tsx
│   │   │   ├── label.tsx
│   │   │   ├── select.tsx
│   │   │   ├── table.tsx
│   │   │   ├── tabs.tsx
│   │   │   └── toast.tsx
│   │   │
│   │   └── custom/                 # Custom components
│   │       ├── sidebar.tsx
│   │       ├── header.tsx
│   │       ├── user-table.tsx
│   │       └── stats-card.tsx
│   │
│   ├── lib/                        # Utilities
│   │   ├── utils.ts                # Helper functions
│   │   ├── api.ts                  # API client
│   │   └── constants.ts            # Constants
│   │
│   └── types/                      # TypeScript Types
│       ├── user.ts
│       ├── doctor.ts
│       ├── appointment.ts
│       └── prescription.ts
│
├── public/                         # Static Assets
│   ├── logo.png
│   └── templates/                  # Report templates
│
├── components.json                 # shadcn/ui config
├── next.config.mjs                 # Next.js config
├── tailwind.config.ts              # Tailwind config
├── tsconfig.json                   # TypeScript config
├── postcss.config.mjs              # PostCSS config
├── eslint.config.mjs               # ESLint config
├── package.json                    # Dependencies
└── README.md                       # This file
```

---

## 🎨 UI Components

### shadcn/ui Components

All UI components are from [shadcn/ui](https://ui.shadcn.com/):

```bash
# Add components
npx shadcn@latest add button
npx shadcn@latest add dialog
npx shadcn@latest add dropdown-menu
npx shadcn@latest add input
npx shadcn@latest add table
```

### Usage Example

```tsx
import { Button } from '@/components/ui/button';
import { Dialog } from '@/components/ui/dialog';

export default function Page() {
  return (
    <div>
      <Button variant="default">Click me</Button>
      <Dialog>...</Dialog>
    </div>
  );
}
```

### Tailwind CSS

```tsx
<div className="flex items-center justify-between p-4 bg-white rounded-lg shadow">
  <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
  <Button className="bg-blue-500 hover:bg-blue-600">Action</Button>
</div>
```

---

## 🔧 Troubleshooting

### Build Errors

**Error**: `Module not found`
```bash
# Clear cache
rm -rf .next node_modules
npm install
npm run build
```

**Error**: `Type error`
- Check `tsconfig.json`
- Verify TypeScript version
- Run `npm run lint`

### Development Server Issues

**Error**: `Port 3000 already in use`
```bash
# Kill process using port 3000
lsof -ti:3000 | xargs kill  # macOS/Linux
npx kill-port 3000          # Cross-platform
```

**Error**: `Failed to load environment variables`
- Verify `.env.local` exists
- Check variable names (must start with `NEXT_PUBLIC_`)
- Restart dev server

### API Connection Issues

**Error**: `Network request failed`
- Check `NEXT_PUBLIC_API_URL` in `.env.local`
- Verify backend is running
- Check CORS settings on backend
- Inspect browser console for errors

### Deployment Issues

**Vercel Build Failed:**
- Check Node.js version (must be 20+)
- Verify environment variables in Vercel dashboard
- Check build logs

**Images Not Loading:**
- Configure `next.config.mjs` with image domains
- Use Next.js `<Image>` component

---

## 📞 Support

For issues, questions, or contributions:

- **GitHub Issues**: [Create an issue](https://github.com/buithan04/Health_IoT/issues)
- **Email**: buithan04@example.com
- **Documentation**: [Full Docs](../COMPREHENSIVE_PROJECT_REPORT.md)

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](../LICENSE) file.

---

<div align="center">

**Made with ❤️ by [Bùi Duy Thân](https://github.com/buithan04)**

[⬆ Back to top](#-health-iot---admin-portal)

</div>

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
