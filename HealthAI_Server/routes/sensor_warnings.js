// HealthAI_Server/routes/sensor_warnings.js
// API routes for sensor warnings

const express = require('express');
const router = express.Router();
const { pool } = require('../config/db');
const { authenticateToken } = require('../middleware/authMiddleware');

/**
 * GET /api/sensor-warnings/test (PUBLIC - for testing only)
 * Lấy sensor warnings mới nhất (không cần auth)
 */
router.get('/test', async (req, res) => {
    try {
        const { limit = 20, user_id } = req.query;

        let query = 'SELECT * FROM sensor_warnings';
        const params = [];

        if (user_id) {
            query += ' WHERE user_id = $1';
            params.push(user_id);
        }

        query += ' ORDER BY created_at DESC LIMIT $' + (params.length + 1);
        params.push(limit);

        const result = await pool.query(query, params);

        res.json({
            success: true,
            count: result.rows.length,
            data: result.rows
        });
    } catch (error) {
        console.error('Error fetching sensor warnings (test):', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * GET /api/sensor-warnings
 * Lấy danh sách sensor warnings của user
 */
router.get('/', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;
        const {
            limit = 50,
            offset = 0,
            warning_type,
            severity,
            resolved,
            device_id
        } = req.query;

        // Build query với filters
        let query = `
            SELECT 
                sw.id,
                sw.user_id,
                sw.device_id,
                sw.warning_type,
                sw.severity,
                sw.message,
                sw.details,
                sw.sensor_data,
                sw.resolved,
                sw.resolved_at,
                sw.created_at
            FROM sensor_warnings sw
            WHERE sw.user_id = $1
        `;

        const params = [userId];
        let paramIndex = 2;

        // Add filters
        if (warning_type) {
            query += ` AND sw.warning_type = $${paramIndex}`;
            params.push(warning_type);
            paramIndex++;
        }

        if (severity) {
            query += ` AND sw.severity = $${paramIndex}`;
            params.push(severity);
            paramIndex++;
        }

        if (resolved !== undefined) {
            query += ` AND sw.resolved = $${paramIndex}`;
            params.push(resolved === 'true');
            paramIndex++;
        }

        if (device_id) {
            query += ` AND sw.device_id = $${paramIndex}`;
            params.push(device_id);
            paramIndex++;
        }

        // Order by most recent first
        query += ` ORDER BY sw.created_at DESC`;

        // Add pagination
        query += ` LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
        params.push(parseInt(limit), parseInt(offset));

        const result = await pool.query(query, params);

        // Get total count
        let countQuery = `
            SELECT COUNT(*) as total
            FROM sensor_warnings sw
            WHERE sw.user_id = $1
        `;
        const countParams = [userId];

        if (warning_type) countParams.push(warning_type);
        if (severity) countParams.push(severity);
        if (resolved !== undefined) countParams.push(resolved === 'true');
        if (device_id) countParams.push(device_id);

        const countResult = await pool.query(countQuery, countParams.slice(0, 1));
        const total = parseInt(countResult.rows[0].total);

        res.json({
            success: true,
            data: {
                warnings: result.rows,
                pagination: {
                    total,
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    has_more: offset + result.rows.length < total
                }
            }
        });

    } catch (error) {
        console.error('❌ Error fetching sensor warnings:', error);
        res.status(500).json({
            success: false,
            message: 'Không thể lấy danh sách cảnh báo cảm biến',
            error: error.message
        });
    }
});

/**
 * GET /api/sensor-warnings/summary
 * Lấy tóm tắt sensor warnings (số lượng theo type, severity)
 */
router.get('/summary', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;
        const { days = 7 } = req.query;

        const query = `
            SELECT 
                warning_type,
                severity,
                COUNT(*) as count,
                COUNT(CASE WHEN resolved = false THEN 1 END) as unresolved_count
            FROM sensor_warnings
            WHERE user_id = $1
                AND created_at >= NOW() - INTERVAL '${parseInt(days)} days'
            GROUP BY warning_type, severity
            ORDER BY warning_type, severity
        `;

        const result = await pool.query(query, [userId]);

        // Get recent unresolved warnings
        const recentQuery = `
            SELECT 
                id, warning_type, severity, message, details, created_at
            FROM sensor_warnings
            WHERE user_id = $1 AND resolved = false
            ORDER BY created_at DESC
            LIMIT 10
        `;

        const recentResult = await pool.query(recentQuery, [userId]);

        res.json({
            success: true,
            data: {
                summary: result.rows,
                recent_unresolved: recentResult.rows,
                period_days: parseInt(days)
            }
        });

    } catch (error) {
        console.error('❌ Error fetching sensor warnings summary:', error);
        res.status(500).json({
            success: false,
            message: 'Không thể lấy tóm tắt cảnh báo cảm biến',
            error: error.message
        });
    }
});

/**
 * PATCH /api/sensor-warnings/:id/resolve
 * Đánh dấu sensor warning đã được xử lý
 */
router.patch('/:id/resolve', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;
        const warningId = req.params.id;

        const query = `
            UPDATE sensor_warnings
            SET resolved = true, resolved_at = NOW()
            WHERE id = $1 AND user_id = $2
            RETURNING *
        `;

        const result = await pool.query(query, [warningId, userId]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Không tìm thấy cảnh báo hoặc bạn không có quyền truy cập'
            });
        }

        res.json({
            success: true,
            message: 'Đã đánh dấu cảnh báo là đã xử lý',
            data: result.rows[0]
        });

    } catch (error) {
        console.error('❌ Error resolving sensor warning:', error);
        res.status(500).json({
            success: false,
            message: 'Không thể cập nhật trạng thái cảnh báo',
            error: error.message
        });
    }
});

/**
 * DELETE /api/sensor-warnings/:id
 * Xóa sensor warning (chỉ admin hoặc owner)
 */
router.delete('/:id', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;
        const warningId = req.params.id;

        const query = `
            DELETE FROM sensor_warnings
            WHERE id = $1 AND user_id = $2
            RETURNING id
        `;

        const result = await pool.query(query, [warningId, userId]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Không tìm thấy cảnh báo hoặc bạn không có quyền xóa'
            });
        }

        res.json({
            success: true,
            message: 'Đã xóa cảnh báo thành công'
        });

    } catch (error) {
        console.error('❌ Error deleting sensor warning:', error);
        res.status(500).json({
            success: false,
            message: 'Không thể xóa cảnh báo',
            error: error.message
        });
    }
});

module.exports = router;
