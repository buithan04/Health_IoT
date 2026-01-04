const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '123456',
    database: process.env.DB_NAME || 'health_db',
    port: process.env.DB_PORT || 5432,
});

async function checkDatabaseStructure() {
    const client = await pool.connect();

    try {
        console.log('\n🔍 Checking Database Structure...\n');

        // Get all tables
        const tablesResult = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name;
    `);

        console.log(`📊 Found ${tablesResult.rows.length} tables:\n`);

        for (const table of tablesResult.rows) {
            const tableName = table.table_name;
            console.log(`\n📋 Table: ${tableName}`);
            console.log('─'.repeat(50));

            // Get columns
            const columnsResult = await client.query(`
        SELECT 
          column_name, 
          data_type, 
          character_maximum_length,
          is_nullable,
          column_default
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = $1
        ORDER BY ordinal_position;
      `, [tableName]);

            columnsResult.rows.forEach(col => {
                const type = col.character_maximum_length
                    ? `${col.data_type}(${col.character_maximum_length})`
                    : col.data_type;
                const nullable = col.is_nullable === 'YES' ? 'NULL' : 'NOT NULL';
                const defaultVal = col.column_default ? ` DEFAULT ${col.column_default}` : '';

                console.log(`  • ${col.column_name.padEnd(30)} ${type.padEnd(20)} ${nullable}${defaultVal}`);
            });

            // Get constraints
            const constraintsResult = await client.query(`
        SELECT 
          conname as constraint_name,
          contype as constraint_type
        FROM pg_constraint 
        WHERE conrelid = $1::regclass
        AND contype IN ('p', 'f', 'u')
        ORDER BY contype, conname;
      `, [tableName]);

            if (constraintsResult.rows.length > 0) {
                console.log('\n  Constraints:');
                constraintsResult.rows.forEach(con => {
                    const typeMap = {
                        'p': 'PRIMARY KEY',
                        'f': 'FOREIGN KEY',
                        'u': 'UNIQUE'
                    };
                    console.log(`    ○ ${con.constraint_name} (${typeMap[con.constraint_type]})`);
                });
            }
        }

        console.log('\n' + '═'.repeat(50));
        console.log('✅ Database structure check completed!');
        console.log('═'.repeat(50) + '\n');

    } catch (error) {
        console.error('❌ Error checking database:', error.message);
        process.exit(1);
    } finally {
        client.release();
        await pool.end();
    }
}

checkDatabaseStructure();
