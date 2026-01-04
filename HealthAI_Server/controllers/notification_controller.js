const notificationService = require('../services/notification_service');

// 1. Lấy danh sách thông báo của tôi
const getMyNotifications = async (req, res) => {
    try {
        const userId = req.user.id; // Lấy ID từ token đăng nhập
        const list = await notificationService.getMyNotifications(userId);
        res.json(list);
    } catch (error) {
        console.error("Lỗi lấy thông báo:", error);
        res.status(500).json({ error: "Lỗi server" });
    }
};

// 2. Đánh dấu thông báo là "Đã đọc"
const markAsRead = async (req, res) => {
    try {
        const { id } = req.params; // Lấy ID thông báo từ URL
        const userId = req.user.id;

        const updated = await notificationService.markRead(id, userId);
        if (!updated) {
            return res.status(404).json({ error: "Không tìm thấy thông báo của bạn" });
        }

        res.json({ message: "Đã đánh dấu đã đọc" });
    } catch (error) {
        console.error("Lỗi markAsRead:", error);
        res.status(500).json({ error: "Lỗi server" });
    }
};

// Đánh dấu tất cả thông báo của tôi đã đọc
const markAllAsRead = async (req, res) => {
    try {
        const userId = req.user.id;
        await notificationService.markAllRead(userId);
        res.json({ message: "Đã đánh dấu tất cả thông báo là đã đọc" });
    } catch (error) {
        console.error("Lỗi markAllAsRead:", error);
        res.status(500).json({ error: "Lỗi server" });
    }
};

// HÀM MỚI: Xử lý xóa
const deleteNotification = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id; // Bảo mật: chỉ xóa được của chính mình

        const success = await notificationService.deleteNotification(id, userId);

        if (!success) {
            return res.status(404).json({ error: "Không tìm thấy thông báo" });
        }

        res.json({ message: "Đã xóa thông báo" });
    } catch (error) {
        console.error("Lỗi xóa thông báo:", error);
        res.status(500).json({ error: "Lỗi server" });
    }
};

// Đếm số thông báo chưa đọc
const getUnreadCount = async (req, res) => {
    try {
        const userId = req.user.id;
        const unread = await notificationService.countUnread(userId);
        res.json({ unread });
    } catch (error) {
        console.error("Lỗi getUnreadCount:", error);
        res.status(500).json({ error: "Lỗi server" });
    }
};

// Xóa TẤT CẢ thông báo của user
const deleteAllNotifications = async (req, res) => {
    try {
        const userId = req.user.id;
        const deletedCount = await notificationService.deleteAllNotifications(userId);

        res.json({
            message: `Đã xóa ${deletedCount} thông báo`,
            deletedCount
        });
    } catch (error) {
        console.error("Lỗi deleteAllNotifications:", error);
        res.status(500).json({ error: "Lỗi server" });
    }
};

module.exports = {
    getMyNotifications,
    markAsRead,
    markAllAsRead,
    deleteNotification,
    deleteAllNotifications,
    getUnreadCount
};