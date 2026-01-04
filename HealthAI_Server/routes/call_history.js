// ============================================
// CALL HISTORY ROUTES
// ============================================
const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/authMiddleware');
const callHistoryService = require('../services/call_history_service');

/**
 * GET /api/call-history
 * Lấy lịch sử cuộc gọi của user
 */
router.get('/', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;
        const limit = parseInt(req.query.limit) || 50;

        const history = await callHistoryService.getUserCallHistory(userId, limit);

        res.json({
            success: true,
            data: history
        });
    } catch (error) {
        console.error('Error fetching call history:', error);
        res.status(500).json({
            success: false,
            message: 'Không thể lấy lịch sử cuộc gọi',
            error: error.message
        });
    }
});

/**
 * GET /api/call-history/statistics
 * Lấy thống kê cuộc gọi
 */
router.get('/statistics', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;

        const stats = await callHistoryService.getCallStatistics(userId);

        res.json({
            success: true,
            data: stats
        });
    } catch (error) {
        console.error('Error fetching call statistics:', error);
        res.status(500).json({
            success: false,
            message: 'Không thể lấy thống kê cuộc gọi',
            error: error.message
        });
    }
});

/**
 * POST /api/call-history
 * Lưu lịch sử cuộc gọi mới
 */
router.post('/', authenticateToken, async (req, res) => {
    try {
        const {
            callId,
            receiverId,
            callType,
            status,
            duration,
            startTime,
            endTime
        } = req.body;

        const callerId = req.user.id;

        const history = await callHistoryService.saveCallHistory({
            callId,
            callerId,
            receiverId,
            callType,
            status,
            duration,
            startTime,
            endTime
        });

        res.json({
            success: true,
            message: 'Đã lưu lịch sử cuộc gọi',
            data: history
        });
    } catch (error) {
        console.error('Error saving call history:', error);
        res.status(500).json({
            success: false,
            message: 'Không thể lưu lịch sử cuộc gọi',
            error: error.message
        });
    }
});

/**
 * PATCH /api/call-history/:callId
 * Cập nhật trạng thái cuộc gọi
 */
router.patch('/:callId', authenticateToken, async (req, res) => {
    try {
        const { callId } = req.params;
        const { status, duration, endTime } = req.body;

        const updated = await callHistoryService.updateCallStatus(
            callId,
            status,
            duration,
            endTime
        );

        if (!updated) {
            return res.status(404).json({
                success: false,
                message: 'Không tìm thấy cuộc gọi'
            });
        }

        res.json({
            success: true,
            message: 'Đã cập nhật lịch sử cuộc gọi',
            data: updated
        });
    } catch (error) {
        console.error('Error updating call history:', error);
        res.status(500).json({
            success: false,
            message: 'Không thể cập nhật lịch sử cuộc gọi',
            error: error.message
        });
    }
});

module.exports = router;
