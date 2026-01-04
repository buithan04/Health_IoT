const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '123456',
    database: process.env.DB_NAME || 'health_db',
    port: process.env.DB_PORT || 5432,
});

async function runMigrations() {
    const client = await pool.connect();

    try {
        console.log('\n🚀 Running database migrations...\n');

        const sqlFile = path.join(__dirname, 'database', 'migrations.sql');
        const sql = fs.readFileSync(sqlFile, 'utf8');

        // Execute the SQL
        await client.query(sql);

        console.log('✅ Migrations completed successfully!\n');

        // Show created tables
        const result = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name;
    `);

        console.log(`📊 Created ${result.rows.length} tables:`);
        result.rows.forEach(row => {
            console.log(`  • ${row.table_name}`);
        });
        console.log('');

    } catch (error) {
        console.error('❌ Migration failed:', error.message);
        console.error('\nDetails:', error);
        process.exit(1);
    } finally {
        client.release();
        await pool.end();
    }
}

runMigrations();
