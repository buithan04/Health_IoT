// File: config/db.js
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// 1. SỬA ĐƯỜNG DẪN DOTENV TUYỆT ĐỐI
// Lùi lại 1 cấp (..) từ thư mục config để ra thư mục gốc chứa .env
require('dotenv').config({ path: path.join(__dirname, '../.env') });

// Kiểm tra xem đã đọc được tên DB chưa
console.log("🛠️ CHECK ENV - DB_NAME:", process.env.DB_NAME);

// Cấu hình kết nối
const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME, // Biến này phải khớp với file .env
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
});

const initializeDatabase = async () => {
    let client;
    try {
        client = await pool.connect();

        // 2. KIỂM TRA CHÍNH XÁC ĐANG KẾT NỐI VÀO ĐÂU
        const res = await client.query('SELECT current_database()');
        const currentDb = res.rows[0].current_database;
        console.log(`🎯 SERVER ĐANG KẾT NỐI VÀO DB: >>> ${currentDb} <<<`);

        // Nếu sai DB thì báo lỗi ngay để bạn biết
        if (currentDb !== 'health_db') {
            throw new Error(`Đang kết nối sai Database! Mong đợi 'health_db' nhưng lại vào '${currentDb}'. Kiểm tra lại file .env`);
        }

        console.log("⏳ Kiểm tra cấu trúc Database...");

        // 3. KIỂM TRA XEM ĐÃ CÓ BẢNG USERS CHƯA (Bảng cơ bản nhất)
        const tableCheck = await client.query(`
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'users'
            );
        `);

        const tablesExist = tableCheck.rows[0].exists;

        if (!tablesExist) {
            console.log("🏗️ Database chưa có cấu trúc, đang khởi tạo lần đầu...");

            // Đọc file SQL SCHEMA ONLY (không chứa data)
            const sqlPath = path.join(__dirname, '..', 'database', 'init_schema_only.sql');
            const sqlContent = fs.readFileSync(sqlPath, 'utf8');

            console.log("🚀 Đang thực thi script SQL...");
            await client.query(sqlContent);

            console.log("✅ KHỞI TẠO DATABASE SCHEMA HOÀN TẤT!");
            console.log("💡 Để seed dữ liệu mẫu, chạy: npm run db:seed-all");
        } else {
            console.log("✅ Database đã có sẵn cấu trúc, bỏ qua khởi tạo!");
            console.log("💡 TIP: Nếu muốn reset database, chạy: npm run db:reset");
        }

    } catch (err) {
        console.error("❌ LỖI KHỞI TẠO DATABASE:", err.message);
    } finally {
        if (client) client.release();
    }
};

module.exports = {
    pool,
    initializeDatabase
};