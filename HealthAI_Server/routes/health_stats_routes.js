// routes/health_stats_routes.js
// Routes cho API thống kê sức khỏe

const express = require('express');
const router = express.Router();
const {
    getHealthStats,
    getLatestHealthData,
    getHealthTrends
} = require('../controllers/health_stats_controller');
const { authenticateToken } = require('../middleware/authMiddleware');

// Tất cả routes cần authentication
router.use(authenticateToken);

/**
 * GET /api/health-stats/:userId
 * Query params: period (day|week|month), type (heartRate|spo2|temperature|all)
 * Example: /api/health-stats/10?period=week&type=heartRate
 */
router.get('/:userId', getHealthStats);

/**
 * GET /api/health-stats/:userId/latest
 * Lấy dữ liệu sức khỏe mới nhất
 */
router.get('/:userId/latest', getLatestHealthData);

/**
 * GET /api/health-stats/:userId/trends
 * Query params: days (default: 7)
 * Example: /api/health-stats/10/trends?days=14
 */
router.get('/:userId/trends', getHealthTrends);

module.exports = router;
