// routes/index.js (Router chính)
const express = require('express');
const router = express.Router();

const authRoutes = require('./auth_routes');
const predictRoutes = require('./predict_routes');
const userRoutes = require('./user_routes')
const doctorRoutes = require('./doctor_routes');
const appointmentRoutes = require('./appointment_routes');
const prescriptionRoutes = require('./prescription_routes');
const chatRoutes = require('./chat_routes');
const reminderRoutes = require('./reminder_routes');
const articleRoutes = require('./article_routes');
const notificationRoutes = require('./notification_routes');
const mqttRoutes = require('./mqtt_routes');
const mqttApiRoutes = require('./mqtt');  // New MQTT API routes
const adminRoutes = require('./admin_routes');
const callHistoryRoutes = require('./call_history');
const healthStatsRoutes = require('./health_stats_routes'); // Health statistics API
const sensorWarningsRoutes = require('./sensor_warnings'); // Sensor warnings API

// Admin routes (protected with admin middleware)
router.use('/admin', adminRoutes);

// Call history routes
router.use('/call-history', callHistoryRoutes);

// Thêm router MQTT (legacy)
router.use('/mqtt', mqttRoutes);

// Thêm router MQTT API (new - for app connection)
router.use('/mqtt-api', mqttApiRoutes);

// Thêm router thông báo
router.use('/notifications', notificationRoutes);

// Thêm router bài viết
router.use('/articles', articleRoutes);

// Thêm router nhắc nhở
router.use('/reminders', reminderRoutes);

// Thêm router chat
router.use('/chat', chatRoutes);

// Thêm router đơn thuốc
router.use('/prescriptions', prescriptionRoutes);

// Thêm router lịch hẹn
router.use('/appointments', appointmentRoutes);

// Thêm router bác sĩ
router.use('/doctors', doctorRoutes);

// Thêm router thống kê sức khỏe
router.use('/health-stats', healthStatsRoutes);

// Thêm router sensor warnings
router.use('/sensor-warnings', sensorWarningsRoutes);

// Định tuyến
router.use('/auth', authRoutes);
router.use('/predict', predictRoutes);
router.use('/user', userRoutes);
module.exports = router;






