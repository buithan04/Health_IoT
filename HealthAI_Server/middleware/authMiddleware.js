// middleware/authMiddleware.js
const jwt = require('jsonwebtoken');
require('dotenv').config(); // Đảm bảo load biến môi trường

const authenticateToken = (req, res, next) => {
    // 1. Lấy token từ header: 'Authorization: Bearer <token>'
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    // 2. Nếu không có token -> Trả về 401 (Unauthorized)
    if (token == null) {
        return res.status(401).json({ error: "Chưa cung cấp token xác thực" });
    }

    // 3. Kiểm tra JWT Secret
    if (!process.env.JWT_SECRET) {
        console.error("LỖI: Chưa cấu hình JWT_SECRET trong file .env");
        return res.status(500).json({ error: "Lỗi cấu hình server" });
    }

    // 4. Xác thực token
    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            // Token sai hoặc hết hạn -> Trả về 403 (Forbidden)
            return res.status(403).json({ error: "Token không hợp lệ hoặc đã hết hạn" });
        }

        // 5. Token đúng -> Lưu thông tin user vào request để dùng ở Controller
        req.user = user;
        next(); // Đi tiếp
    });
};

// Xuất dưới dạng Object để bên router dùng destructuring { authenticateToken }
module.exports = {
    authenticateToken
};