const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chat_controller');
const { authenticateToken } = require('../middleware/authMiddleware');

// --- 1. KHAI BÁO MULTER (SỬA LỖI TẠI ĐÂY) ---
const multer = require('multer');

// Cấu hình lưu vào RAM (MemoryStorage) để đẩy lên Cloudinary
const storage = multer.memoryStorage();
const upload = multer({
    storage: storage,
    limits: { fileSize: 10 * 1024 * 1024 } // Giới hạn 10MB (tùy chọn)
});
// -------------------------------------------

// Middleware xác thực cho tất cả các route bên dưới
router.use(authenticateToken);

// 1. Bắt đầu chat
router.post('/start', chatController.startChat);

// 2. Lấy danh sách hội thoại
router.get('/conversations', chatController.getConversations);

// 3. Lấy lịch sử tin nhắn
router.get('/conversations/:id/messages', chatController.getMessages);

// 4. Upload ảnh/file chat (Đã có biến 'upload' để dùng)
router.post('/upload', upload.single('file'), chatController.uploadAttachment);

module.exports = router;