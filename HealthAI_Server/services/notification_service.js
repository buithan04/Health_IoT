const { pool } = require('../config/db');
const fcmService = require('./fcm_service');

// 1. Tạo thông báo (Database + Socket + FCM)
const createNotification = async ({ userId, title, message, type, relatedId, additionalData = {} }) => {
    const query = `
        INSERT INTO notifications (user_id, title, message, type, related_id)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING *
    `;
    const values = [userId, title, message, type, relatedId];

    try {
        const result = await pool.query(query, values);
        const notif = result.rows[0];

        // Gửi Socket (Sự kiện 'NEW_NOTIFICATION' - UPPERCASE)
        if (global.io) {
            global.io.to(userId.toString()).emit('NEW_NOTIFICATION', notif);
        }

        // Gửi FCM với additionalData cho navigation
        if (fcmService) {
            const fcmData = {
                type: type,
                relatedId: relatedId ? String(relatedId) : '',
                ...additionalData // Thêm thông tin cho navigation
            };
            await fcmService.sendPushNotification(userId, title, message, fcmData);
        }
        return notif;
    } catch (error) {
        console.error("Lỗi tạo thông báo:", error);
    }
};

// 2. Lấy danh sách
const getMyNotifications = async (userId) => {
    const result = await pool.query('SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC', [userId]);
    return result.rows;
};

// 3. Đánh dấu đã đọc (kèm bảo vệ chủ sở hữu)
const markRead = async (id, userId) => {
    const res = await pool.query(
        'UPDATE notifications SET is_read = TRUE WHERE id = $1 AND user_id = $2 RETURNING id',
        [id, userId]
    );
    return res.rowCount > 0;
};

// 4. Đánh dấu tất cả thông báo của tôi là đã đọc
const markAllRead = async (userId) => {
    await pool.query('UPDATE notifications SET is_read = TRUE WHERE user_id = $1 AND is_read = FALSE', [userId]);
};

// 5. [MỚI] Xóa thông báo
const deleteNotification = async (id, userId) => {
    const result = await pool.query(
        'DELETE FROM notifications WHERE id = $1 AND user_id = $2 RETURNING id',
        [id, userId]
    );
    return result.rowCount > 0;
};

// 6. Đếm số thông báo chưa đọc của tôi
const countUnread = async (userId) => {
    const res = await pool.query('SELECT COUNT(*) AS unread FROM notifications WHERE user_id = $1 AND is_read = FALSE', [userId]);
    return parseInt(res.rows[0]?.unread || 0, 10);
};

module.exports = { createNotification, getMyNotifications, markRead, markAllRead, deleteNotification, countUnread };