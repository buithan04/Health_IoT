# Database Setup Guide

## 📁 Cấu trúc file database

Thư mục `database/` chỉ có 3 file:

1. **migrations.sql** - Schema database (33 bảng)
2. **seed_data.sql** - Dữ liệu khởi tạo
3. **README.md** - File hướng dẫn này

## 🚀 Cách sử dụng

### 1. Khởi tạo database lần đầu

```bash
# Sử dụng npm scripts (khuyến nghị)
npm run db:init

# Hoặc chạy từng bước thủ công:
npm run db:migrate    # Tạo schema
npm run db:seed       # Seed dữ liệu
```

### 2. Chỉ chạy migrations (tạo/cập nhật schema)

```bash
npm run db:migrate

# Hoặc trực tiếp:
psql -U postgres -d health_db -f database/migrations.sql
```

### 3. Chỉ seed dữ liệu

```bash
npm run db:seed

# Hoặc trực tiếp:
psql -U postgres -d health_db -f database/seed_data.sql
```

### 4. Kiểm tra cấu trúc database

```bash
npm run db:check
```

## 📝 Thêm/Sửa bảng hoặc cột

Mọi thay đổi về schema (CREATE TABLE, ALTER TABLE, ADD COLUMN...) đều thêm vào:
📄 **database/migrations.sql**

Ví dụ thêm cột mới:
```sql
-- Thêm vào cuối file migrations.sql (trước COMMIT;)
ALTER TABLE medications ADD COLUMN IF NOT EXISTS discount NUMERIC(5,2) DEFAULT 0;
```

## 🔄 Cập nhật seed data

Mọi dữ liệu khởi tạo (users, categories, medications...) đều sửa trong:
📄 **database/seed_data.sql**

Ví dụ thêm thuốc mới:
```sql
-- Thêm vào phần SEED MEDICATIONS
INSERT INTO medications (name, category_id, manufacturer_id, unit, price, stock) VALUES
('Thuốc mới', 1, 1, 'Viên', 5000, 100)
ON CONFLICT DO NOTHING;
```

## 🔧 Reset database hoàn toàn

Nếu cần xóa và tạo lại toàn bộ:

```bash
# 1. Drop schema
psql -U postgres -d health_db -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# 2. Chạy lại init
npm run db:init
```

## 📋 NPM Scripts có sẵn

| Command | Mô tả |
|---------|-------|
| `npm run db:check` | Kiểm tra cấu trúc database |
| `npm run db:migrate` | Chạy migrations (tạo schema) |
| `npm run db:seed` | Seed dữ liệu khởi tạo |
| `npm run db:init` | Khởi tạo hoàn chỉnh (migrate + seed) |

## 🔐 Thông tin đăng nhập mặc định

Sau khi seed data, sẽ có sẵn tài khoản admin:

- **Email:** than.95.cvan@gmail.com
- **Password:** admin123

⚠️ **Quan trọng:** Đổi mật khẩu này ngay sau khi deploy production!

## 📊 Database Schema

### Core Tables
- `users` - Người dùng (admin, doctor, patient)
- `profiles` - Thông tin cá nhân
- `doctors` - Thông tin bác sĩ
- `medications` - Thuốc (có stock, min_stock)
- `medication_categories` - Danh mục thuốc
- `manufacturers` - Nhà sản xuất
- `prescriptions` - Đơn thuốc
- `appointments` - Lịch hẹn
- `conversations` - Cuộc trò chuyện
- `messages` - Tin nhắn
- `notifications` - Thông báo

### Recent Changes
- ✅ Added `stock` and `min_stock` columns to medications table
- ✅ Removed `active_ingredient` column from medications
- ✅ Admin account: than.95.cvan@gmail.com / admin123

## ⚠️ Lưu ý

✅ **DO:**
- Luôn thêm `IF NOT EXISTS` / `IF EXISTS` để tránh lỗi khi chạy lại
- Thêm migrations mới vào cuối file migrations.sql
- Sử dụng `ON CONFLICT DO NOTHING` cho INSERT trong seed_data.sql
- Backup trước khi thay đổi production database

❌ **DON'T:**
- Không xóa migrations cũ (có thể comment nếu không dùng)
- Không hard-code password thật vào seed_data.sql
- Không chỉnh sửa trực tiếp trên production database

## 🔍 Kiểm tra database connection

```bash
# Test connection
psql -U postgres -d health_db -c "SELECT current_database();"

# List all tables
psql -U postgres -d health_db -c "\dt"
```

## 📞 Connection String

Đảm bảo file `.env` có đúng thông tin:

```env
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=123456
DB_PORT=5432
DB_NAME=health_db
```
