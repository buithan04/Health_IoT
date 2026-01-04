// Database Configuration - PostgreSQL/TimescaleDB
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

require('dotenv').config({ path: path.join(__dirname, '../.env') });

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
});

const initializeDatabase = async () => {
    let client;
    try {
        client = await pool.connect();

        const res = await client.query('SELECT current_database()');
        const currentDb = res.rows[0].current_database;
        console.log(`✅ Connected to database: ${currentDb}`);

        if (currentDb !== process.env.DB_NAME) {
            throw new Error(`Database connection error! Expected '${process.env.DB_NAME}' but connected to '${currentDb}'. Check your .env file.`);
        }

        console.log("⏳ Checking database structure...");

        const tableCheck = await client.query(`
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'users'
            );
        `);

        const tablesExist = tableCheck.rows[0].exists;

        if (!tablesExist) {
            console.log("🏗️ Initializing database schema...");

            const sqlPath = path.join(__dirname, '..', 'database', 'init_schema_only.sql');
            const sqlContent = fs.readFileSync(sqlPath, 'utf8');

            console.log("🚀 Executing SQL script...");
            await client.query(sqlContent);

            console.log("✅ Database schema initialized successfully!");
            console.log("💡 To seed sample data, run: npm run db:seed");
        } else {
            console.log("✅ Database structure already exists");
        }

    } catch (err) {
        console.error("❌ Database initialization error:", err.message);
    } finally {
        if (client) client.release();
    }
};

module.exports = {
    pool,
    initializeDatabase
};