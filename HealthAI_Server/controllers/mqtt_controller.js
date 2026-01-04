// HealthAI_Server/controllers/mqtt_controller.js
// Controller for MQTT connection info

const mqttService = require('../services/mqtt_service');
const mqttConfig = require('../config/mqtt');
const { pool } = require('../config/db');

/**
 * Get MQTT connection credentials for app
 */
const getMQTTCredentials = async (req, res) => {
    try {
        const userId = req.user.id;

        // Return HiveMQ connection info
        const credentials = {
            host: mqttConfig.hivemq.host,
            port: mqttConfig.hivemq.port,
            protocol: mqttConfig.hivemq.protocol,
            username: mqttConfig.hivemq.username,
            password: mqttConfig.hivemq.password,
            topics: {
                medicalData: mqttConfig.hivemq.topics.medicalData,
                ecgData: mqttConfig.hivemq.topics.ecgData
            },
            qos: mqttConfig.hivemq.qos,
            clientIdPrefix: `app_${userId}_`,
            keepalive: mqttConfig.hivemq.keepalive
        };

        res.json({
            success: true,
            data: credentials,
            message: 'MQTT credentials retrieved successfully'
        });

    } catch (error) {
        console.error('Error getting MQTT credentials:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get MQTT credentials',
            error: error.message
        });
    }
};

/**
 * Get MQTT connection status
 */
const getMQTTStatus = async (req, res) => {
    try {
        const status = {
            isConnected: mqttService.isConnected,
            lastPacketId: mqttService.lastPacketId,
            config: {
                host: mqttConfig.hivemq.host,
                port: mqttConfig.hivemq.port,
                topics: Object.values(mqttConfig.hivemq.topics)
            }
        };

        res.json({
            success: true,
            data: status
        });

    } catch (error) {
        console.error('Error getting MQTT status:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get MQTT status',
            error: error.message
        });
    }
};

/**
 * Get recent health records
 */
const getRecentHealthRecords = async (req, res) => {
    try {
        const userId = req.user.id;
        const limit = parseInt(req.query.limit) || 50;

        const query = `
            SELECT 
                id,
                packet_id,
                heart_rate,
                spo2,
                temperature,
                measured_at
            FROM health_records
            WHERE user_id = $1
            ORDER BY measured_at DESC
            LIMIT $2
        `;

        const result = await pool.query(query, [userId, limit]);

        res.json({
            success: true,
            data: result.rows,
            count: result.rows.length
        });

    } catch (error) {
        console.error('Error getting health records:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get health records',
            error: error.message
        });
    }
};

/**
 * Get recent ECG records
 */
const getRecentECGRecords = async (req, res) => {
    try {
        const userId = req.user.id;
        const limit = parseInt(req.query.limit) || 20;

        const query = `
            SELECT 
                id,
                device_id,
                packet_id,
                data_points,
                sample_rate,
                measured_at
            FROM ecg_readings
            WHERE user_id = $1
            ORDER BY measured_at DESC
            LIMIT $2
        `;

        const result = await pool.query(query, [userId, limit]);

        // Parse data_points
        const records = result.rows.map(row => ({
            ...row,
            data_points: JSON.parse(row.data_points)
        }));

        res.json({
            success: true,
            data: records,
            count: records.length
        });

    } catch (error) {
        console.error('Error getting ECG records:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get ECG records',
            error: error.message
        });
    }
};

/**
 * Get ECG by packet_id
 */
const getECGByPacketId = async (req, res) => {
    try {
        const userId = req.user.id;
        const { packetId } = req.params;

        const query = `
            SELECT 
                id,
                device_id,
                packet_id,
                data_points,
                sample_rate,
                measured_at
            FROM ecg_readings
            WHERE user_id = $1 AND packet_id = $2
            ORDER BY measured_at DESC
            LIMIT 1
        `;

        const result = await pool.query(query, [userId, packetId]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'ECG record not found'
            });
        }

        const record = {
            ...result.rows[0],
            data_points: JSON.parse(result.rows[0].data_points)
        };

        res.json({
            success: true,
            data: record
        });

    } catch (error) {
        console.error('Error getting ECG by packet ID:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get ECG record',
            error: error.message
        });
    }
};

module.exports = {
    getMQTTCredentials,
    getMQTTStatus,
    getRecentHealthRecords,
    getRecentECGRecords,
    getECGByPacketId
};
