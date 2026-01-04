const admin = require("firebase-admin");
const { pool } = require('../config/db');
const path = require('path');
const fs = require('fs');

// Initialize Firebase Admin SDK if serviceAccountKey.json exists
const serviceAccountPath = path.join(__dirname, '../config/serviceAccountKey.json');
let firebaseInitialized = false;

if (fs.existsSync(serviceAccountPath)) {
    try {
        const serviceAccount = require("../config/serviceAccountKey.json");
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        firebaseInitialized = true;
        console.log('✅ Firebase Admin SDK initialized');
    } catch (error) {
        console.warn('⚠️ Firebase initialization error:', error.message);
    }
} else {
    console.warn('⚠️ serviceAccountKey.json not found. Push notifications will be disabled.');
    console.warn('💡 To enable push notifications:');
    console.warn('   1. Download your Firebase service account key');
    console.warn('   2. Save it as: HealthAI_Server/config/serviceAccountKey.json');
}

const sendPushNotification = async (userId, title, body, data = {}) => {
    if (!firebaseInitialized) {
        console.log('⚠️ Push notification skipped: Firebase not initialized');
        return { success: false, reason: 'Firebase not initialized' };
    }

    try {
        // 1. Lấy Token của User từ Database
        const res = await pool.query("SELECT fcm_token FROM users WHERE id = $1", [userId]);
        const fcmToken = res.rows[0]?.fcm_token;

        if (!fcmToken) {
            console.log(`User ${userId} không có FCM Token (chưa cài app?)`);
            return;
        }

        // 2. Chuyển tất cả data sang string cho FCM
        const fcmData = {};
        for (const key in data) {
            fcmData[key] = String(data[key]);
        }

        // 3. Tạo gói tin chuẩn
        const message = {
            token: fcmToken,

            // [QUAN TRỌNG] notification: Để hiển thị khi tắt App
            notification: {
                title: title,
                body: body,
            },

            // data: Để xử lý logic khi bấm vào
            data: {
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                ...fcmData // Chứa conversationId, partnerId, partnerName, partnerAvatar, etc.
            },

            // Cấu hình Android (Để có tiếng và rung)
            android: {
                priority: 'high',
                notification: {
                    channelId: 'health_ai_high_importance', // Trùng với Flutter
                    priority: 'max',
                    defaultSound: true,
                    defaultVibrateTimings: true,
                },
            },
        };

        // 4. Bắn
        await admin.messaging().send(message);
        console.log(`🚀 FCM sent to User ${userId}: ${title}`);

    } catch (error) {
        console.error("Lỗi gửi FCM:", error);
    }
};

module.exports = { sendPushNotification };