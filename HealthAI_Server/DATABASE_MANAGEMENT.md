# 🗂️ Database & Scripts Management Guide

## 📁 Folder Structure (Cleaned & Organized)

```
HealthAI_Server/
├── database/
│   ├── migrations.sql          # Schema migrations (33 tables)
│   ├── seed_data.sql          # Initial data (admin, doctors, medications)
│   └── README.md              # Database usage guide
│
├── scripts/
│   ├── create_admin.js        # Create admin user
│   ├── reset_database.js      # Reset & rebuild database
│   └── seed_all_data.js       # Advanced data seeding
│
├── check_db_structure.js      # Inspect database structure
├── DATABASE_SYNC_REPORT.md    # Sync report
└── SYNC_COMPLETE.md           # Complete documentation
```

## 🚀 NPM Scripts (Quick Commands)

### Database Management

```bash
# 1. Check database structure
npm run db:check
# → Runs: node check_db_structure.js
# → Shows all tables and columns

# 2. Initialize database (Fresh install)
npm run db:init
# → Runs migrations + seeds data
# → Creates all tables + inserts initial data

# 3. Run migrations only
npm run db:migrate
# → Runs: psql -U postgres -d health_db -f database/migrations.sql
# → Creates/updates schema

# 4. Seed data only
npm run db:seed-data
# → Runs: psql -U postgres -d health_db -f database/seed_data.sql
# → Inserts initial data

# 5. Reset entire database
npm run db:reset
# → Runs: node scripts/reset_database.js
# → Drops all tables, runs migrations, seeds data

# 6. Seed additional data
npm run db:seed
# → Runs: node scripts/seed_all_data.js
# → Advanced seeding script

# 7. Create admin user
npm run db:admin
# → Runs: node scripts/create_admin.js
# → Interactive admin creation
```

### Development

```bash
# Start server
npm start              # Production mode
npm run dev            # Development mode (nodemon)

# Testing
npm test               # Run all tests with coverage
npm run test:watch     # Watch mode
npm run test:unit      # Unit tests only
```

## 📋 Database Files

### 1. migrations.sql
**Purpose:** Define database schema  
**Contains:**
- 33 tables (users, profiles, medications, appointments, etc.)
- All constraints and relationships
- Indexes for performance

**Usage:**
```bash
psql -U postgres -d health_db -f database/migrations.sql
# or
npm run db:migrate
```

### 2. seed_data.sql
**Purpose:** Insert initial data  
**Contains:**
- Admin account: than.95.cvan@gmail.com / admin123
- 7 doctors with profiles
- 1 patient account
- 50 medications with stock
- 13 medication categories
- 18 manufacturers

**Usage:**
```bash
psql -U postgres -d health_db -f database/seed_data.sql
# or
npm run db:seed-data
```

### 3. README.md (in database/)
**Purpose:** Documentation  
**Contains:**
- Usage instructions
- Schema modification guide
- Seed data update guide
- Best practices

## 🔧 Scripts

### 1. check_db_structure.js (Root)
**Purpose:** Inspect database  
**Output:** All tables with columns, types, constraints

```bash
node check_db_structure.js
# or
npm run db:check
```

**Example Output:**
```
=== TABLES IN DATABASE ===

📋 Table: users
   - id: integer NOT NULL DEFAULT nextval(...)
   - email: character varying(100) NOT NULL
   - role: character varying(20) DEFAULT 'patient'
   ...

📋 Table: medications
   - id: integer NOT NULL
   - name: character varying(255) NOT NULL
   - stock: integer DEFAULT 0
   - min_stock: integer DEFAULT 10
   ...
```

### 2. reset_database.js (scripts/)
**Purpose:** Complete database reset  
**Actions:**
1. Drops all tables
2. Runs migrations.sql
3. Runs seed_data.sql

```bash
node scripts/reset_database.js
# or
npm run db:reset
```

**Warning:** ⚠️ This deletes ALL data!

### 3. seed_all_data.js (scripts/)
**Purpose:** Advanced data seeding  
**Actions:**
- Seeds comprehensive test data
- Creates sample appointments
- Generates health records
- Useful for development/testing

```bash
node scripts/seed_all_data.js
# or
npm run db:seed
```

### 4. create_admin.js (scripts/)
**Purpose:** Create new admin user  
**Interactive:** Prompts for email/password

```bash
node scripts/create_admin.js
# or
npm run db:admin
```

## 📊 Common Workflows

### First Time Setup

```bash
# 1. Configure environment
cp .env.example .env
# Edit DB credentials

# 2. Initialize database
npm run db:init

# 3. Verify
npm run db:check

# 4. Start server
npm run dev
```

### Development Reset

```bash
# Quick reset with fresh data
npm run db:reset

# Or manual steps:
npm run db:migrate
npm run db:seed-data
```

### Production Deployment

```bash
# 1. Backup first!
pg_dump health_db > backup_$(date +%Y%m%d).sql

# 2. Run migrations
npm run db:migrate

# 3. Seed data (if needed)
npm run db:seed-data
```

### Add New Admin

```bash
npm run db:admin
# Follow prompts
```

### Check Structure After Changes

```bash
npm run db:check
```

## 🔍 Database Inspection Commands

### Using NPM Script
```bash
npm run db:check
```

### Direct PostgreSQL
```bash
# Connect to database
psql -U postgres -d health_db

# List all tables
\dt

# Describe table
\d medications

# List all columns in a table
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'medications';
```

## ⚠️ Important Notes

### 1. Environment Variables
Ensure `.env` file has correct values:
```env
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=123456
DB_PORT=5432
DB_NAME=health_db
```

### 2. PostgreSQL Service
Database must be running:
```bash
# Check status
pg_isready

# Start service (if needed)
# Windows: services.msc → PostgreSQL
# Linux: sudo systemctl start postgresql
```

### 3. Data Safety
- Always backup before `db:reset`
- Use `db:check` to verify structure
- Test migrations on dev first

### 4. Admin Credentials
Default admin (from seed_data.sql):
- Email: `than.95.cvan@gmail.com`
- Password: `admin123`

⚠️ Change this in production!

## 🎯 Quick Reference

| Task | Command |
|------|---------|
| Check DB | `npm run db:check` |
| Init DB | `npm run db:init` |
| Reset DB | `npm run db:reset` |
| Migrate | `npm run db:migrate` |
| Seed | `npm run db:seed-data` |
| New Admin | `npm run db:admin` |
| Dev Server | `npm run dev` |

## 📝 Changelog

### v1.0.0 (Current)
- ✅ Consolidated to 2 SQL files
- ✅ Cleaned scripts folder
- ✅ Updated NPM scripts
- ✅ Added comprehensive documentation
- ✅ Synced backend/frontend with database

---

🚀 **Database management is now streamlined and organized!**
