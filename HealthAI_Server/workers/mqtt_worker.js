const mqtt = require('mqtt');
const { pool } = require('../config/db');
const notifService = require('../services/notification_service');
const fcmService = require('../services/fcm_service');

// Cấu hình HiveMQ Cloud (Giữ nguyên thông số của bạn)
const HOST = '7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud';
const PORT = 8883;
const USER = 'DoAn1';
const PASS = 'Th123321';

// Topic: health/+/vitals
const TOPIC_PATTERN = 'health/+/vitals';

const connectMQTT = () => {
    const client = mqtt.connect(`mqtts://${HOST}:${PORT}`, {
        username: USER,
        password: PASS,
        rejectUnauthorized: true,
    });

    client.on('connect', () => {
        console.log('✅ [Worker] Backend đã kết nối HiveMQ Cluster');
        client.subscribe(TOPIC_PATTERN, (err) => {
            if (!err) console.log(`📡 [Worker] Đang hứng dữ liệu từ: ${TOPIC_PATTERN}`);
        });
    });

    client.on('message', async (topic, message) => {
        try {
            // Parse topic: health/15/vitals -> Lấy userID = 15
            const topicParts = topic.split('/');
            const userId = topicParts[1];

            const payload = JSON.parse(message.toString());
            // Payload mẫu: { "heart_rate": 110, "spo2": 96, "temp": 37.5 }

            console.log(`📥 [Worker] Nhận data User ${userId}:`, payload);

            const clientDb = await pool.connect();
            let healthRecordId = null; // Biến lưu ID bản ghi mới tạo

            try {
                await clientDb.query('BEGIN');

                // 1. Lưu vào bảng health_records (Bảng mới chuẩn hóa)
                const insertQuery = `
                    INSERT INTO health_records (user_id, heart_rate, spo2, temperature)
                    VALUES ($1, $2, $3, $4)
                    RETURNING id
                `;

                // Xử lý dữ liệu null nếu cảm biến không gửi đủ
                const hr = payload.heart_rate || null;
                const spo2 = payload.spo2 || null;
                const temp = payload.temp || null;

                const res = await clientDb.query(insertQuery, [userId, hr, spo2, temp]);
                healthRecordId = res.rows[0].id;

                await clientDb.query('COMMIT');
            } catch (e) {
                await clientDb.query('ROLLBACK');
                console.error("Lỗi ghi DB:", e);
                return; // Nếu lỗi lưu DB thì dừng, không cảnh báo
            } finally {
                clientDb.release();
            }

            // 2. LOGIC CẢNH BÁO (REALTIME RULE-BASED)
            // Kiểm tra đơn giản: Tim > 100 hoặc SpO2 < 90
            const hrVal = payload.heart_rate || 0;
            const spo2Val = payload.spo2 || 100;

            if (hrVal > 100 || (spo2Val < 90 && spo2Val > 0)) {
                console.log(`🚨 Phát hiện bất thường User ${userId}: HR=${hrVal}, SpO2=${spo2Val}`);

                await notifService.createNotification({
                    userId: userId,
                    title: 'CẢNH BÁO SỨC KHỎE ⚠️',
                    message: `Chỉ số bất thường: Nhịp tim ${hrVal} BPM, SpO2 ${spo2Val}%.`,
                    type: 'HEALTH_ALERT', // Loại thông báo để App biết đường dẫn
                    relatedId: healthRecordId // ID bản ghi vừa lưu để xem chi tiết
                });
            }

        } catch (error) {
            console.error("❌ Lỗi xử lý tin nhắn MQTT:", error.message);
        }
    });
};

module.exports = { connectMQTT };