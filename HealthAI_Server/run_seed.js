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

async function runSeed() {
    const client = await pool.connect();

    try {
        console.log('\n🌱 Seeding database...\n');

        const sqlFile = path.join(__dirname, 'database', 'seed_data.sql');
        const sql = fs.readFileSync(sqlFile, 'utf8');

        // Execute the SQL
        await client.query(sql);

        console.log('✅ Seed data inserted successfully!\n');

        // Show what was seeded
        const counts = await Promise.all([
            client.query('SELECT COUNT(*) FROM users'),
            client.query('SELECT COUNT(*) FROM doctor_professional_info'),
            client.query('SELECT COUNT(*) FROM medications'),
            client.query('SELECT COUNT(*) FROM medication_categories'),
        ]);

        console.log('📊 Seeded data:');
        console.log(`  • Users: ${counts[0].rows[0].count}`);
        console.log(`  • Doctors: ${counts[1].rows[0].count}`);
        console.log(`  • Medications: ${counts[2].rows[0].count}`);
        console.log(`  • Categories: ${counts[3].rows[0].count}`);

        // Show admin credentials
        const admin = await client.query(`
      SELECT email FROM users WHERE role = 'admin' LIMIT 1
    `);

        if (admin.rows.length > 0) {
            console.log('\n🔑 Admin credentials:');
            console.log(`  Email: ${admin.rows[0].email}`);
            console.log('  Password: admin123');
        }

        console.log('');

    } catch (error) {
        console.error('❌ Seed failed:', error.message);
        console.error('\nDetails:', error);
        process.exit(1);
    } finally {
        client.release();
        await pool.end();
    }
}

runSeed();
