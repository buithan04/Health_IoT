// middleware/admin_middleware.js
const jwt = require('jsonwebtoken');
const { pool } = require('../config/db');

/**
 * Middleware kiểm tra user có role admin không
 */
const checkAdminRole = async (req, res, next) => {
    try {
        // Lấy token từ header
        const token = req.headers.authorization?.split(' ')[1];

        if (!token) {
            return res.status(401).json({ error: 'Không tìm thấy token xác thực' });
        }

        // Verify token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // Lấy thông tin user từ database
        const result = await pool.query(
            'SELECT id, email, role FROM users WHERE id = $1',
            [decoded.id]
        );

        const user = result.rows[0];

        if (!user) {
            return res.status(404).json({ error: 'Người dùng không tồn tại' });
        }

        // Kiểm tra role admin
        if (user.role !== 'admin') {
            return res.status(403).json({ error: 'Bạn không có quyền truy cập tính năng này' });
        }

        // Attach user vào request để sử dụng ở controller
        req.user = user;
        next();
    } catch (error) {
        console.error('Admin middleware error:', error);

        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({ error: 'Token không hợp lệ' });
        }

        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({ error: 'Token đã hết hạn' });
        }

        return res.status(500).json({ error: 'Lỗi xác thực' });
    }
};

module.exports = { checkAdminRole };
