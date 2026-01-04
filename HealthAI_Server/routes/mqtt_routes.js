// HealthAI_Server/routes/mqtt_routes.js
// API routes for MQTT health data

const express = require('express');
const router = express.Router();
const mqttService = require('../services/mqtt_service');
const { authenticateToken } = require('../middleware/authMiddleware');

/**
 * GET /api/mqtt/status
 * Get MQTT connection status
 */
router.get('/status', authenticateToken, async (req, res) => {
    try {
        const status = mqttService.getStatus();

        res.json({
            success: true,
            status
        });
    } catch (error) {
        console.error('Error getting MQTT status:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get MQTT status'
        });
    }
});

/**
 * GET /api/mqtt/health-data
 * Get health data for current user (last 1 month)
 */
router.get('/health-data', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;
        const limit = parseInt(req.query.limit) || 100;

        const data = await mqttService.getHealthData(userId, limit);

        res.json({
            success: true,
            count: data.length,
            data
        });
    } catch (error) {
        console.error('Error fetching health data:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch health data'
        });
    }
});

/**
 * GET /api/mqtt/latest
 * Get latest health reading for current user
 */
router.get('/latest', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;

        const reading = await mqttService.getLatestReading(userId);

        if (!reading) {
            return res.status(404).json({
                success: false,
                message: 'No health data found'
            });
        }

        res.json({
            success: true,
            data: reading
        });
    } catch (error) {
        console.error('Error fetching latest reading:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch latest reading'
        });
    }
});

/**
 * POST /api/mqtt/publish-test
 * Publish test data to MQTT (for testing only)
 */
router.post('/publish-test', authenticateToken, async (req, res) => {
    try {
        const { topic, data } = req.body;

        if (!topic || !data) {
            return res.status(400).json({
                success: false,
                message: 'Topic and data are required'
            });
        }

        await mqttService.publishTestData(topic, data);

        res.json({
            success: true,
            message: 'Test data published successfully'
        });
    } catch (error) {
        console.error('Error publishing test data:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to publish test data'
        });
    }
});

/**
 * POST /api/mqtt/cleanup
 * Manually trigger cleanup of old data (admin only)
 */
router.post('/cleanup', authenticateToken, async (req, res) => {
    try {
        // Check if user is admin
        if (req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Admin access required'
            });
        }

        const deletedCount = await mqttService.cleanupOldData();

        res.json({
            success: true,
            message: 'Cleanup completed successfully',
            deletedCount
        });
    } catch (error) {
        console.error('Error during cleanup:', error);
        res.status(500).json({
            success: false,
            message: 'Cleanup failed'
        });
    }
});

module.exports = router;
