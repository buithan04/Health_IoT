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

        // Step 1: Run main migrations.sql (CREATE TABLES)
        console.log('📋 Step 1: Creating tables from migrations.sql...');
        const sqlFile = path.join(__dirname, 'database', 'migrations.sql');
        const sql = fs.readFileSync(sqlFile, 'utf8');
        await client.query(sql);
        console.log('✅ Base tables created\n');

        // Step 2: Run individual migration files (ALTER TABLES, etc.)
        const migrationsDir = path.join(__dirname, 'database', 'migrations');
        if (fs.existsSync(migrationsDir)) {
            const migrationFiles = fs.readdirSync(migrationsDir)
                .filter(file => file.endsWith('.sql'))
                .sort(); // Run in alphabetical order

            if (migrationFiles.length > 0) {
                console.log(`📋 Step 2: Running ${migrationFiles.length} migration file(s)...\n`);

                for (const file of migrationFiles) {
                    const filePath = path.join(migrationsDir, file);
                    const migrationSql = fs.readFileSync(filePath, 'utf8');

                    console.log(`   🔄 Running: ${file}`);
                    await client.query(migrationSql);
                    console.log(`   ✅ Completed: ${file}`);
                }
                console.log('');
            }
        }

        console.log('✅ All migrations completed successfully!\n');

        // Show created tables
        const result = await client.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name;
        `);

        console.log(`📊 Database contains ${result.rows.length} tables:`);
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
