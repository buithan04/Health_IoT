// HealthAI_Server/routes/mqtt.js
// Routes for MQTT and health data

const express = require('express');
const router = express.Router();
const mqttController = require('../controllers/mqtt_controller');
const { authenticateToken } = require('../middleware/authMiddleware');

// Get MQTT credentials for app
router.get('/credentials', authenticateToken, mqttController.getMQTTCredentials);

// Get MQTT connection status
router.get('/status', authenticateToken, mqttController.getMQTTStatus);

// Get recent health records
router.get('/health-records', authenticateToken, mqttController.getRecentHealthRecords);

// Get recent ECG records
router.get('/ecg-records', authenticateToken, mqttController.getRecentECGRecords);

// Get ECG by packet_id
router.get('/ecg/:packetId', authenticateToken, mqttController.getECGByPacketId);

module.exports = router;
