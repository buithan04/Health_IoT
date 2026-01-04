const express = require('express');
const router = express.Router();
const multer = require('multer');

// Import Controller
const userController = require('../controllers/user_controller');

// Import Middleware
const { authenticateToken } = require('../middleware/authMiddleware');

// --- CẤU HÌNH MULTER (Giữ nguyên) ---

// 1. Sử dụng memoryStorage để lưu ảnh vào RAM trước khi lên Cloudinary
const storage = multer.memoryStorage();

// 2. Bộ lọc file ảnh
const fileFilter = (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    } else {
        cb(new Error('Chỉ cho phép upload file ảnh!'), false);
    }
};

// 3. Khởi tạo upload
const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
    limits: { fileSize: 5 * 1024 * 1024 } // Giới hạn 5MB
});

// --- ĐỊNH NGHĨA ROUTES ---

// 1. Upload Avatar (POST /api/user/upload-avatar)
router.post('/upload-avatar', authenticateToken, upload.single('avatar'), userController.uploadAvatar);

// 2. Lấy thông tin Profile (GET /api/user/dashboard-info)
router.get('/dashboard-info', authenticateToken, userController.getUserProfile);

// --- CÁC ROUTE MỚI ĐƯỢC THÊM ---

// 3. Cập nhật thông tin cá nhân (PUT /api/user/profile)
router.put('/profile', authenticateToken, userController.updateProfile);

// 5. Lấy danh sách đánh giá của tôi (GET /api/user/my-reviews)
router.get('/my-reviews', authenticateToken, userController.getMyReviews);

// 6. Cập nhật FCM Token (POST /api/user/update-fcm-token)
router.put('/fcm-token', authenticateToken, userController.updateFcmToken);


module.exports = router;