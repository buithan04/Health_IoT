// app.js (File chính, thay thế cho index.js)
const http = require('http');
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const cron = require('node-cron'); // Import cron
const path = require('path'); // Move require path to top

const { initializeDatabase } = require('./config/db');
const { loadAllModels } = require('./config/aiModels');
const { connectMQTT } = require('./workers/mqtt_worker');
const mqttService = require('./services/mqtt_service');
const mqttCleanupWorker = require('./workers/mqtt_cleanup_worker');
const { initSocket } = require('./socket_manager');
const { fetchAndSaveArticles } = require('./services/crawl_service'); // Import service crawl
const { startScheduler } = require('./workers/scheduler');
const mainRouter = require('./routes');
// --- 1. KHỞI TẠO APP ---
const app = express();
const server = http.createServer(app); // Server này chứa cả Express + Socket
const port = process.env.PORT || 5000;

// --- 2. MIDDLEWARE ---    
const corsOptions = {
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    allowedHeaders: 'Content-Type,Authorization'
};

app.use(cors(corsOptions));
app.use(express.json());

// Khởi tạo Socket.IO (Gắn vào server HTTP)
initSocket(server);

fetchAndSaveArticles();

// Đặt lịch: Chạy mỗi 3 tiếng ('0 */3 * * *')
cron.schedule('0 */3 * * *', () => {
    fetchAndSaveArticles();
});

// --- GỌI HÀM NÀY TRƯỚC KHI SERVER LISTEN ---
startScheduler();

// --- 3. ROUTING ---
app.use('/api', mainRouter);
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));



// Endpoint gốc
app.get('/', (req, res) => {
    res.send('Health AI Server (MVC-S Structure) đang chạy!');
});

// --- 4. KHỞI ĐỘNG SERVER ---
const startServer = async () => {
    try {
        console.log('🚀 Starting HealthAI Server...');

        // 1. Kết nối CSDL
        console.log('📊 Connecting to PostgreSQL database...');
        await initializeDatabase();

        // 2. Connect to MQTT HiveMQ Cloud
        console.log('🌐 Connecting to MQTT HiveMQ Cloud...');
        await mqttService.connect();
        console.log('✅ MQTT service connected');

        // 3. Start MQTT cleanup worker
        console.log('🧹 Starting MQTT cleanup worker...');
        mqttCleanupWorker.start();
        console.log('✅ Cleanup worker started');

        // 4. Load AI Models (MLP + CNN)
        console.log('🤖 Loading AI models...');
        await loadAllModels();
        console.log('✅ AI models loaded successfully');

        // 5. Bắt đầu lắng nghe
        server.listen(port, '0.0.0.0', () => {
            console.log('\n╔══════════════════════════════════════════╗');
            console.log('║   🏥 HEALTHAI SERVER READY              ║');
            console.log('╚══════════════════════════════════════════╝');
            console.log(`🌐 HTTP Server: http://localhost:${port}`);
            console.log(`📡 MQTT Status: ${mqttService.isConnected ? '✅ Connected' : '❌ Disconnected'}`);
            console.log(`🧹 Cleanup Worker: ✅ Running`);
            console.log('\nPress CTRL+C to stop server\n');
        });
    } catch (error) {
        console.error("❌ SERVER STARTUP ERROR:", error.message);
        console.error(error.stack);
        process.exit(1);
    }
};

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n⏹️ Shutting down gracefully...');
    mqttService.disconnect();
    mqttCleanupWorker.stop();
    process.exit(0);
});

startServer();