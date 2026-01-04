# 🚀 HealthAI Server - Backend API

<div align="center">

![Node.js](https://img.shields.io/badge/Node.js-16+-green)
![Express](https://img.shields.io/badge/Express-4.19-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-blue)
![TimescaleDB](https://img.shields.io/badge/TimescaleDB-2.0+-FDB515)
![Socket.IO](https://img.shields.io/badge/Socket.IO-4.8-black)
![TensorFlow.js](https://img.shields.io/badge/TensorFlow.js-4.22-orange)

**RESTful API Server with AI/ML, Real-time Communication, and IoT Integration**

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Environment Variables](#-environment-variables)
- [Database Setup](#-database-setup)
- [Running the Server](#-running-the-server)
- [Project Structure](#-project-structure)
- [API Documentation](#-api-documentation)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Overview

**HealthAI Server** is a comprehensive Node.js backend API that powers the Health IoT platform. It provides:

- ✅ **RESTful APIs** - 100+ endpoints for healthcare operations
- ✅ **AI/ML Integration** - TensorFlow.js models for health predictions
- ✅ **Real-time Communication** - Socket.IO for chat and notifications
- ✅ **IoT Support** - MQTT protocol for health monitoring devices
- ✅ **Secure Authentication** - JWT tokens with bcrypt
- ✅ **File Management** - Cloudinary integration
- ✅ **Background Jobs** - Cron jobs and task schedulers
- ✅ **Push Notifications** - Firebase Cloud Messaging

**Architecture**: MVC-S (Model-View-Controller-Service) pattern

---

## ✨ Features

### Core APIs

- **Authentication** - Register, login, email verification, password reset
- **User Management** - Profile management, avatar upload, FCM tokens
- **Doctor Operations** - Professional profiles, schedules, availability
- **Appointments** - Booking, status updates, reviews, rescheduling
- **Prescriptions** - E-prescribing with medication database
- **Chat** - Real-time messaging with Socket.IO
- **Video Calls** - Call history tracking
- **Health Records** - Medical history, attachments, ECG readings
- **Notifications** - Real-time push notifications
- **Articles** - Health news aggregation
- **Reminders** - Medication reminder system
- **Admin** - Analytics, user management, reports

### AI/ML Features

- **Heart Disease Prediction** - MLP model with 11 features (89.3% accuracy)
- **ECG Anomaly Detection** - CNN model for ECG analysis
- **Feature Engineering** - Age, BMI, MAP calculations
- **StandardScaler** - Data normalization
- **Risk Classification** - Low/Medium/High risk levels

### IoT Integration

- **MQTT Protocol** - HiveMQ Cloud broker integration
- **Real-time Monitoring** - Heart rate, SpO2, temperature, blood pressure
- **MQTT Worker** - Background subscriber for IoT data
- **Data Cleanup** - Automatic deletion of old IoT data (30+ days)
- **Threshold Alerts** - Configurable vital sign thresholds

### Background Jobs

- **Article Crawler** - Fetch health articles every 3 hours
- **Appointment Scheduler** - Send reminders 24h before appointments
- **MQTT Cleanup** - Daily cleanup of old IoT data
- **Email Queue** - Asynchronous email sending

---

## 🛠 Tech Stack

### Core Framework

```json
{
  "runtime": "Node.js 20.x",
  "framework": "Express.js 4.18.2",
  "language": "JavaScript ES6+"
}
```

### Database & ORM

```json
{
  "database": "PostgreSQL 16",
  "client": "pg 8.11.3",
  "connection_pooling": "pg-pool"
}
```

### AI/ML

```json
{
  "framework": "TensorFlow.js Node 4.15.0",
  "models": ["MLP (Heart Disease)", "CNN (ECG)"],
  "preprocessing": "StandardScaler"
}
```

### Real-time & IoT

```json
{
  "websocket": "Socket.IO 4.6.1",
  "iot_protocol": "MQTT 5.3.4",
  "broker": "HiveMQ Cloud"
}
```

### Authentication & Security

```json
{
  "authentication": "JWT (jsonwebtoken 9.0.2)",
  "password_hashing": "bcrypt 5.1.1",
  "cors": "cors 2.8.5",
  "helmet": "helmet 7.1.0"
}
```

### File & Cloud Services

```json
{
  "file_upload": "multer 1.4.5",
  "cloud_storage": "cloudinary 1.41.1",
  "email": "nodemailer 6.9.7",
  "push_notifications": "firebase-admin 12.0.0"
}
```

### Task Scheduling

```json
{
  "cron_jobs": "node-cron 3.0.3",
  "http_client": "axios 1.6.5"
}
```

---

## 📦 Prerequisites

Before installation, ensure you have:

- **Node.js** 20.x or higher ([Download](https://nodejs.org/))
- **PostgreSQL** 16.x or higher ([Download](https://www.postgresql.org/download/))
- **Git** ([Download](https://git-scm.com/downloads))
- **npm** or **yarn** package manager

**Verify installations:**

```bash
node --version    # Should show v20.x.x
npm --version     # Should show 10.x.x
psql --version    # Should show 16.x
```

---

## 🚀 Installation

### 1. Clone Repository

```bash
git clone https://github.com/buithan04/Health_IoT.git
cd Health_IoT/HealthAI_Server
```

### 2. Install Dependencies

```bash
npm install
```

This will install all required packages from `package.json`.

### 3. Create Environment File

```bash
# Copy example environment file
cp .env.example .env

# Edit with your credentials
nano .env  # or use your favorite editor
```

---

## 🔐 Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
# =======================
# SERVER CONFIGURATION
# =======================
PORT=5000
NODE_ENV=development

# =======================
# DATABASE CONFIGURATION
# =======================
DB_HOST=localhost
DB_PORT=5432
DB_NAME=health_iot_db
DB_USER=postgres
DB_PASSWORD=your_postgres_password
DB_MAX_POOL=20

# =======================
# JWT AUTHENTICATION
# =======================
JWT_SECRET=your_super_secret_jwt_key_min_32_chars
JWT_EXPIRE=7d

# =======================
# CLOUDINARY (File Storage)
# =======================
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# =======================
# MQTT CONFIGURATION
# =======================
MQTT_BROKER_URL=mqtt://broker.hivemq.com
MQTT_PORT=1883
MQTT_USERNAME=your_mqtt_username
MQTT_PASSWORD=your_mqtt_password
MQTT_CLIENT_ID=healthai_server_${random_id}

# =======================
# EMAIL CONFIGURATION
# =======================
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
EMAIL_FROM=HealthAI <noreply@healthai.com>

# =======================
# FIREBASE ADMIN (FCM)
# =======================
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxx@your-project.iam.gserviceaccount.com

# =======================
# NEWS API (Article Crawler)
# =======================
NEWS_API_KEY=your_newsapi_key
NEWS_API_URL=https://newsapi.org/v2/everything

# =======================
# CORS CONFIGURATION
# =======================
CORS_ORIGIN=http://localhost:3000,http://localhost:5173

# =======================
# UPLOAD LIMITS
# =======================
MAX_FILE_SIZE=10485760  # 10MB in bytes
```

### Important Notes:

- **JWT_SECRET**: Use a strong random string (min 32 characters)
- **DB_PASSWORD**: Your PostgreSQL password
- **CLOUDINARY**: Sign up at [cloudinary.com](https://cloudinary.com)
- **MQTT**: Get credentials from [HiveMQ Cloud](https://www.hivemq.com/cloud/)
- **EMAIL**: For Gmail, use [App Passwords](https://support.google.com/accounts/answer/185833)
- **FIREBASE**: Download service account JSON from Firebase Console
- **NEWS_API**: Get free API key from [newsapi.org](https://newsapi.org)

---

## 🗄️ Database Setup

### 1. Create Database

```bash
# Login to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE health_iot_db;

# Verify
\l

# Exit
\q
```

### 2. Run Migrations

The `database/migrations.sql` file contains the complete schema with 34 tables.

```bash
# Run migrations
psql -U postgres -d health_iot_db -f database/migrations.sql

# Verify tables
psql -U postgres -d health_iot_db -c "\dt"
```

**Expected output**: 34 tables created

```
 Schema |              Name              | Type  |  Owner
--------+--------------------------------+-------+----------
 public | active_ingredients             | table | postgres
 public | ai_diagnoses                   | table | postgres
 public | appointment_types              | table | postgres
 public | appointments                   | table | postgres
 public | articles                       | table | postgres
 public | call_history                   | table | postgres
 public | conversations                  | table | postgres
 public | doctor_notes                   | table | postgres
 ...
```

### 3. (Optional) Seed Sample Data

```bash
# Run seed data
psql -U postgres -d health_iot_db -f database/seed_data.sql
```

### 4. Verify Database Connection

```bash
npm run test:db
```

---

## ▶️ Running the Server

### Development Mode

```bash
# Start with auto-reload (nodemon)
npm run dev
```

Server will start at: `http://localhost:5000`

**Console output:**
```
Server running on port 5000
✓ PostgreSQL connected successfully
✓ Socket.IO initialized
✓ MQTT connected to broker.hivemq.com
✓ Cron jobs started
✓ Article crawler scheduled
```

### Production Mode

```bash
# Start production server
npm start
```

### Using PM2 (Recommended for Production)

```bash
# Install PM2 globally
npm install -g pm2

# Start with PM2
pm2 start app.js --name "healthai-server"

# View logs
pm2 logs healthai-server

# Monitor
pm2 monit

# Stop
pm2 stop healthai-server

# Restart
pm2 restart healthai-server

# Delete
pm2 delete healthai-server

# Save configuration
pm2 save

# Auto-start on boot
pm2 startup
```

---

## 📁 Project Structure

```
HealthAI_Server/
├── app.js                      # ⚡ Entry point - Server initialization
├── socket_manager.js           # 🔌 Socket.IO configuration
├── package.json                # 📦 Dependencies
├── .env                        # 🔐 Environment variables
├── .gitignore                  # 🚫 Git ignore rules
│
├── config/                     # ⚙️ Configuration files
│   ├── db.js                   # Database connection (pg-pool)
│   ├── mqtt.js                 # MQTT broker configuration
│   ├── cloudinary.js           # Cloudinary setup
│   └── firebase.js             # Firebase Admin SDK
│
├── routes/                     # 🛣️ API Routes (14 files)
│   ├── index.js                # Main router (mounts all routes)
│   ├── auth_routes.js          # Authentication APIs
│   ├── user_routes.js          # User management APIs
│   ├── doctor_routes.js        # Doctor operations
│   ├── appointment_routes.js   # Appointment booking
│   ├── prescription_routes.js  # E-prescriptions
│   ├── chat_routes.js          # Chat messaging
│   ├── call_history.js         # Call history
│   ├── mqtt_routes.js          # IoT data APIs
│   ├── notification_routes.js  # Notifications
│   ├── article_routes.js       # Health articles
│   ├── reminder_routes.js      # Medication reminders
│   ├── predict_routes.js       # AI/ML predictions
│   └── admin_routes.js         # Admin operations
│
├── controllers/                # 🎮 Request Handlers (11 files)
│   ├── auth_controller.js      # Authentication logic
│   ├── user_controller.js      # User operations
│   ├── doctor_controller.js    # Doctor operations
│   ├── appointment_controller.js
│   ├── prescription_controller.js
│   ├── chat_controller.js
│   ├── call_controller.js
│   ├── mqtt_controller.js
│   ├── notification_controller.js
│   ├── predict_controller.js
│   └── admin_controller.js
│
├── services/                   # 🏢 Business Logic (17 files)
│   ├── auth_service.js         # Auth operations
│   ├── user_service.js         # User CRUD
│   ├── doctor_service.js       # Doctor operations
│   ├── appointment_service.js  # Appointment logic
│   ├── prescription_service.js # Prescription handling
│   ├── chat_service.js         # Chat operations
│   ├── call_history_service.js # Call tracking
│   ├── mqtt_service.js         # MQTT operations
│   ├── predict_service.js      # ⭐ AI/ML predictions
│   ├── health_analysis_service.js # Health analysis
│   ├── fcm_service.js          # Push notifications
│   ├── email_service.js        # Email sending
│   ├── notification_service.js # Notification management
│   ├── reminder_service.js     # Medication reminders
│   ├── article_service.js      # Article operations
│   ├── crawl_service.js        # News crawling
│   └── admin_service.js        # Admin operations
│
├── middleware/                 # 🛡️ Middleware Functions
│   ├── auth_middleware.js      # JWT verification
│   ├── role_middleware.js      # Role-based access
│   ├── upload_middleware.js    # File upload (multer)
│   └── error_middleware.js     # Error handling
│
├── workers/                    # ⚙️ Background Jobs
│   ├── mqtt_worker.js          # MQTT subscriber worker
│   └── mqtt_cleanup_worker.js  # Cleanup old IoT data
│
├── models/                     # 🤖 AI/ML Models
│   ├── tfjs_mlp_model/         # Heart disease model
│   │   ├── model.json
│   │   └── group1-shard1of1.bin
│   ├── tfjs_ecg_model/         # ECG anomaly model
│   │   ├── model.json
│   │   └── group1-shard1of1.bin
│   ├── scaler_mlp.json         # StandardScaler params
│   ├── scaler_ecg.json         # ECG scaler
│   └── risk_encoder.json       # ["low", "medium", "high"]
│
├── database/                   # 🗄️ Database Files
│   ├── migrations.sql          # Schema (34 tables)
│   └── seed_data.sql           # Sample data
│
├── uploads/                    # 📁 Temporary uploads
└── logs/                       # 📝 Application logs
```

---

## 📚 API Documentation

### Base URL

```
http://localhost:5000/api
```

### Health Check

```bash
GET /api/health

# Response
{
  "status": "ok",
  "timestamp": "2026-01-04T10:30:00.000Z",
  "uptime": 12345,
  "database": "connected",
  "mqtt": "connected"
}
```

### Authentication

All protected routes require JWT token in header:

```bash
Authorization: Bearer <your_jwt_token>
```

### API Endpoints Summary

| Category | Endpoints | Description |
|----------|-----------|-------------|
| **Auth** | 7 | Register, login, email verification, password reset |
| **Users** | 6 | Profile, avatar upload, FCM tokens |
| **Doctors** | 10+ | Professional info, schedules, availability |
| **Appointments** | 5 | Booking, status updates, reviews |
| **Prescriptions** | 4 | Create, view, medication search |
| **Chat** | 4 | Conversations, messages, typing |
| **Call History** | 4 | Call records, duration tracking |
| **MQTT** | 5 | IoT data, latest readings, cleanup |
| **Notifications** | 4 | Push notifications, FCM tokens |
| **Articles** | 1 | Health news |
| **Reminders** | 4 | Medication reminders CRUD |
| **AI/ML** | 2 | Heart disease prediction, ECG analysis |
| **Admin** | 10+ | Analytics, user management, reports |

**Total**: 100+ endpoints

### Full API Documentation

For complete API documentation with request/response examples, see:

👉 **[COMPREHENSIVE_PROJECT_REPORT_PART2.md](../COMPREHENSIVE_PROJECT_REPORT_PART2.md)**

---

## 🧪 Testing

### API Testing with cURL

```bash
# Health check
curl http://localhost:5000/api/health

# Register user
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "full_name": "Test User",
    "phone_number": "0123456789",
    "role": "patient"
  }'

# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Get profile (with token)
curl http://localhost:5000/api/user/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Using PowerShell Script

```powershell
# Run test script
.\test_admin_apis.ps1
```

### Using Postman

1. Import Postman collection (if available)
2. Set environment variables:
   - `BASE_URL`: `http://localhost:5000/api`
   - `TOKEN`: `<your_jwt_token>`

---

## 🚢 Deployment

### Production Checklist

- [ ] Change `NODE_ENV=production`
- [ ] Use strong `JWT_SECRET` (32+ characters)
- [ ] Enable HTTPS/SSL certificate
- [ ] Configure CORS whitelist (remove `*`)
- [ ] Setup rate limiting (express-rate-limit)
- [ ] Enable logging (Winston/Sentry)
- [ ] Setup database backups
- [ ] Configure firewall rules
- [ ] Use environment-specific `.env` files
- [ ] Enable PM2 or Docker
- [ ] Setup monitoring (New Relic, Datadog)

### Deploy to Heroku

```bash
# Login to Heroku
heroku login

# Create app
heroku create healthai-server

# Add PostgreSQL addon
heroku addons:create heroku-postgresql:hobby-dev

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=your_secret
heroku config:set CLOUDINARY_CLOUD_NAME=your_name
# ... (set all env vars)

# Deploy
git push heroku master

# View logs
heroku logs --tail
```

### Deploy to AWS EC2

```bash
# SSH to EC2 instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PostgreSQL 16
sudo apt-get install postgresql-16

# Clone repository
git clone https://github.com/buithan04/Health_IoT.git
cd Health_IoT/HealthAI_Server

# Install dependencies
npm install --production

# Setup .env file
nano .env

# Install PM2
sudo npm install -g pm2

# Start server
pm2 start app.js --name healthai-server

# Setup nginx reverse proxy
sudo apt-get install nginx
sudo nano /etc/nginx/sites-available/healthai
```

**Nginx config:**

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Docker Deployment

```dockerfile
# Dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 5000

CMD ["node", "app.js"]
```

```bash
# Build image
docker build -t healthai-server .

# Run container
docker run -d -p 5000:5000 --env-file .env healthai-server
```

**Full deployment guide**: [COMPREHENSIVE_PROJECT_REPORT_PART4_FINAL.md](../COMPREHENSIVE_PROJECT_REPORT_PART4_FINAL.md)

---

## 🔧 Troubleshooting

### Database Connection Error

```
Error: connect ECONNREFUSED 127.0.0.1:5432
```

**Solution:**
- Verify PostgreSQL is running: `sudo systemctl status postgresql`
- Check `.env` credentials match PostgreSQL user
- Verify database exists: `psql -U postgres -l`

### MQTT Connection Failed

```
Error: connect ECONNREFUSED broker.hivemq.com:1883
```

**Solution:**
- Check MQTT broker URL and credentials
- Verify firewall allows port 1883
- Test connection: `npm run test:mqtt`

### JWT Token Invalid

```
Error: jwt malformed
```

**Solution:**
- Verify `JWT_SECRET` is set in `.env`
- Check token format in request header
- Ensure token hasn't expired (default 7 days)

### File Upload Error

```
Error: Cloudinary upload failed
```

**Solution:**
- Verify Cloudinary credentials in `.env`
- Check file size limit (`MAX_FILE_SIZE`)
- Ensure uploads/ directory exists

### Port Already in Use

```
Error: listen EADDRINUSE :::5000
```

**Solution:**
```bash
# Find process using port 5000
lsof -i :5000  # macOS/Linux
netstat -ano | findstr :5000  # Windows

# Kill process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows
```

### AI Model Not Found

```
Error: Model not found at models/tfjs_mlp_model
```

**Solution:**
- Verify models/ directory exists
- Check model files are not in .gitignore
- Re-train models if necessary

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

[⬆ Back to top](#-healthai-server---backend-api)

</div>
