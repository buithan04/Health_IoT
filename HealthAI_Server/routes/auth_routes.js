// routes/auth_routes.js
const express = require('express');
const router = express.Router();

// SỬA Ở ĐÂY: Dùng {} để "lấy ra" (destructure) các hàm
const { register, login, handleVerifyEmail, forgotPassword, verifyOTP, resetPassword, createDoctor, changePassword, logout } = require('../controllers/auth_controller');
const { authenticateToken } = require('../middleware/authMiddleware');

// Bây giờ "register" và "login" là các HÀM (function)
router.post('/register', register);
router.post('/login', login);
router.get('/verify', handleVerifyEmail); // Thêm route xác thực email
router.post('/forgot-password', forgotPassword);
router.post('/verify-otp', verifyOTP);
router.post('/reset-password', resetPassword);
// routes/auth_routes.js
router.post('/create-doctor', createDoctor); // Thêm route này
// --- SỬA DÒNG NÀY: THÊM authenticateToken VÀO GIỮA ---
router.post('/change-password', authenticateToken, changePassword);
router.post('/logout', authenticateToken, logout); // Thêm route đăng xuất

module.exports = router;