const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notification_controller');
const { authenticateToken } = require('../middleware/authMiddleware');

// Bắt buộc đăng nhập mới xem được thông báo
router.use(authenticateToken);

// GET /api/notifications -> Lấy danh sách
router.get('/', notificationController.getMyNotifications);

// PUT /api/notifications/:id/read -> Đánh dấu đã đọc
router.put('/:id/read', notificationController.markAsRead);

// PUT /api/notifications/read-all -> Đánh dấu tất cả đã đọc
router.put('/read-all', notificationController.markAllAsRead);

// GET /api/notifications/unread-count -> Đếm số chưa đọc
router.get('/unread-count', notificationController.getUnreadCount);

// DELETE /api/notifications/all -> Xóa TẤT CẢ thông báo của user (PHẢI ĐỨNG TRƯỚC /:id)
router.delete('/all', notificationController.deleteAllNotifications);

// DELETE /api/notifications/:id -> Xóa của chính mình
router.delete('/:id', notificationController.deleteNotification);

module.exports = router;