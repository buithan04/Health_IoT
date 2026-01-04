// HealthAI_Server/services/mqtt_service.js
// MQTT Service for receiving and storing health data from HiveMQ Cloud

const mqtt = require('mqtt');
const { pool } = require('../config/db');
const healthAnalysisService = require('./health_analysis_service');
const notificationService = require('./notification_service');

class MQTTService {
    constructor() {
        this.client = null;
        this.isConnected = false;
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = 10;

        // MQTT Configuration from environment
        this.config = {
            host: process.env.MQTT_HOST,
            port: parseInt(process.env.MQTT_PORT || '8883'),
            username: process.env.MQTT_USERNAME,
            password: process.env.MQTT_PASSWORD,
            protocol: process.env.MQTT_PROTOCOL || 'mqtts',
            topic: process.env.MQTT_TOPIC || 'health/sensors/#'
        };
    }

    /**
     * Initialize MQTT connection to HiveMQ Cloud
     */
    async connect() {
        return new Promise((resolve, reject) => {
            try {
                console.log('🔌 Connecting to MQTT HiveMQ Cloud...');
                console.log(`📡 Host: ${this.config.host}:${this.config.port}`);

                const options = {
                    host: this.config.host,
                    port: this.config.port,
                    protocol: this.config.protocol,
                    username: this.config.username,
                    password: this.config.password,
                    clientId: `healthai_server_${Math.random().toString(16).slice(3)}`,
                    clean: true,
                    reconnectPeriod: 5000,
                    connectTimeout: 30000,
                    rejectUnauthorized: true
                };

                this.client = mqtt.connect(options);

                // Connection successful
                this.client.on('connect', () => {
                    this.isConnected = true;
                    this.reconnectAttempts = 0;
                    console.log('✅ MQTT Connected successfully to HiveMQ Cloud');

                    // Subscribe to health sensor topics
                    this.subscribe();
                    resolve();
                });

                // Handle incoming messages
                this.client.on('message', async (topic, message) => {
                    try {
                        await this.handleMessage(topic, message.toString());
                    } catch (error) {
                        console.error('❌ Error handling MQTT message:', error);
                    }
                });

                // Handle errors
                this.client.on('error', (error) => {
                    console.error('❌ MQTT Connection Error:', error.message);
                    this.isConnected = false;
                    if (!this.client.connected) {
                        reject(error);
                    }
                });

                // Handle disconnection
                this.client.on('close', () => {
                    this.isConnected = false;
                    console.log('⚠️ MQTT Connection closed');
                });

                // Handle reconnection
                this.client.on('reconnect', () => {
                    this.reconnectAttempts++;
                    console.log(`🔄 MQTT Reconnecting... (Attempt ${this.reconnectAttempts}/${this.maxReconnectAttempts})`);

                    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
                        console.error('❌ Max reconnection attempts reached. Stopping reconnection.');
                        this.client.end(true);
                    }
                });

                // Timeout fallback
                setTimeout(() => {
                    if (!this.isConnected) {
                        reject(new Error('MQTT connection timeout'));
                    }
                }, 35000);

            } catch (error) {
                console.error('❌ Failed to connect to MQTT:', error);
                reject(error);
            }
        });
    }

    /**
     * Subscribe to health sensor topics
     */
    subscribe() {
        if (!this.client || !this.isConnected) {
            console.error('❌ Cannot subscribe: MQTT not connected');
            return;
        }

        const topics = [
            this.config.topic,
            'health/sensors/heartrate',
            'health/sensors/bloodpressure',
            'health/sensors/temperature',
            'health/sensors/spo2',
            'health/sensors/activity',
            'health/sensors/sleep'
        ];

        topics.forEach(topic => {
            this.client.subscribe(topic, { qos: 1 }, (error) => {
                if (error) {
                    console.error(`❌ Subscribe error for ${topic}:`, error);
                } else {
                    console.log(`✅ Subscribed to: ${topic}`);
                }
            });
        });
    }

    /**
     * Handle incoming MQTT message
     */
    async handleMessage(topic, messageStr) {
        try {
            console.log(`📩 Received MQTT message on ${topic}`);

            // Parse message (expecting JSON)
            let data;
            try {
                data = JSON.parse(messageStr);
            } catch (parseError) {
                console.warn('⚠️ Message is not JSON, treating as raw string');
                data = { raw: messageStr };
            }

            // Extract health metrics with default value 0
            const healthData = {
                user_id: data.user_id || data.userId || null,
                topic_name: topic,
                heart_rate: parseInt(data.heart_rate || data.heartRate || 0),
                blood_pressure_systolic: parseInt(data.bp_systolic || data.systolic || 0),
                blood_pressure_diastolic: parseInt(data.bp_diastolic || data.diastolic || 0),
                temperature: parseFloat(data.temperature || data.temp || 0.0),
                spo2: parseInt(data.spo2 || data.oxygen || 0),
                steps: parseInt(data.steps || 0),
                calories: parseInt(data.calories || 0),
                sleep_hours: parseFloat(data.sleep_hours || data.sleep || 0.0),
                device_id: data.device_id || data.deviceId || 'unknown',
                raw_data: data
            };

            // Save to database
            const savedId = await this.saveHealthData(healthData);

            console.log(`✅ Health data saved: HR=${healthData.heart_rate}, BP=${healthData.blood_pressure_systolic}/${healthData.blood_pressure_diastolic}, SpO2=${healthData.spo2}`);

            // --- PHÂN TÍCH SỨC KHỎE VÀ CẢNH BÁO ---
            if (healthData.user_id) {
                await this.analyzeAndNotify(healthData, savedId);
            }

        } catch (error) {
            console.error('❌ Error processing MQTT message:', error);
        }
    }

    /**
     * Save health data to database
     */
    async saveHealthData(data) {
        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            const query = `
                INSERT INTO mqtt_health_data (
                    user_id,
                    topic_name,
                    heart_rate,
                    blood_pressure_systolic,
                    blood_pressure_diastolic,
                    temperature,
                    spo2,
                    steps,
                    calories,
                    sleep_hours,
                    device_id,
                    raw_data,
                    received_at
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, CURRENT_TIMESTAMP)
                RETURNING id
            `;

            const values = [
                data.user_id,
                data.topic_name,
                data.heart_rate || 0,
                data.blood_pressure_systolic || 0,
                data.blood_pressure_diastolic || 0,
                data.temperature || 0.0,
                data.spo2 || 0,
                data.steps || 0,
                data.calories || 0,
                data.sleep_hours || 0.0,
                data.device_id,
                JSON.stringify(data.raw_data)
            ];

            const result = await client.query(query, values);

            await client.query('COMMIT');

            return result.rows[0].id;

        } catch (error) {
            await client.query('ROLLBACK');
            console.error('❌ Database error saving MQTT data:', error);
            throw error;
        } finally {
            client.release();
        }
    }

    /**
     * Get health data for a user (last 1 month)
     */
    async getHealthData(userId, limit = 100) {
        try {
            const query = `
                SELECT 
                    id,
                    topic_name,
                    heart_rate,
                    blood_pressure_systolic,
                    blood_pressure_diastolic,
                    temperature,
                    spo2,
                    steps,
                    calories,
                    sleep_hours,
                    device_id,
                    received_at,
                    created_at
                FROM mqtt_health_data
                WHERE user_id = $1
                    AND created_at >= (CURRENT_TIMESTAMP - INTERVAL '1 month')
                ORDER BY created_at DESC
                LIMIT $2
            `;

            const result = await pool.query(query, [userId, limit]);
            return result.rows;

        } catch (error) {
            console.error('❌ Error fetching health data:', error);
            throw error;
        }
    }

    /**
     * Get latest health reading for a user
     */
    async getLatestReading(userId) {
        try {
            const query = `
                SELECT 
                    heart_rate,
                    blood_pressure_systolic,
                    blood_pressure_diastolic,
                    temperature,
                    spo2,
                    steps,
                    calories,
                    sleep_hours,
                    received_at
                FROM mqtt_health_data
                WHERE user_id = $1
                ORDER BY created_at DESC
                LIMIT 1
            `;

            const result = await pool.query(query, [userId]);
            return result.rows[0] || null;

        } catch (error) {
            console.error('❌ Error fetching latest reading:', error);
            throw error;
        }
    }

    /**
     * Cleanup data older than 1 month (called by worker)
     */
    async cleanupOldData() {
        try {
            console.log('🧹 Running MQTT data cleanup...');

            const result = await pool.query('SELECT cleanup_old_mqtt_data()');
            const deletedCount = result.rows[0].cleanup_old_mqtt_data;

            console.log(`✅ Cleanup completed: ${deletedCount} old records deleted`);
            return deletedCount;

        } catch (error) {
            console.error('❌ Error during cleanup:', error);
            throw error;
        }
    }

    /**
     * Publish test data (for testing)
     */
    async publishTestData(topic, data) {
        if (!this.client || !this.isConnected) {
            throw new Error('MQTT not connected');
        }

        return new Promise((resolve, reject) => {
            this.client.publish(topic, JSON.stringify(data), { qos: 1 }, (error) => {
                if (error) {
                    reject(error);
                } else {
                    resolve();
                }
            });
        });
    }

    /**
     * Analyze health data and send notification if dangerous
     */
    async analyzeAndNotify(healthData, dataId) {
        try {
            // 1. Phân tích dữ liệu sức khỏe
            const analysis = healthAnalysisService.analyzeHealthData(healthData);

            console.log(`🔍 Health Analysis - User ${healthData.user_id}: Risk Level = ${analysis.riskLevel}`);

            // 2. Nếu nguy hiểm → Gửi thông báo
            if (analysis.isDangerous && analysis.alerts.length > 0) {
                // Get highest severity alert
                const criticalAlerts = analysis.alerts.filter(a => a.severity === 'critical');
                const dangerAlerts = analysis.alerts.filter(a => a.severity === 'danger');
                const warningAlerts = analysis.alerts.filter(a => a.severity === 'warning');

                const mainAlert = criticalAlerts[0] || dangerAlerts[0] || warningAlerts[0];

                // Format notification title
                let notifTitle = '⚠️ Cảnh báo sức khỏe';
                if (analysis.riskLevel === 'critical') {
                    notifTitle = '🚨 CẤP CỨU - Khẩn cấp';
                } else if (analysis.riskLevel === 'danger') {
                    notifTitle = '⚠️ Cảnh báo nghiêm trọng';
                }

                // Format notification message
                const notifMessage = healthAnalysisService.formatAlertMessage(analysis.alerts, analysis.metrics);

                // Create detailed content
                const alertDetails = analysis.alerts.map(alert =>
                    `${alert.title}: ${alert.message}`
                ).join('\n');

                const fullMessage = `${notifMessage}\n\n${alertDetails}\n\nKhuyến nghị:\n${analysis.recommendations.join('\n')}`;

                // 3. Gửi thông báo (DB + Socket + FCM)
                const notification = await notificationService.createNotification({
                    userId: healthData.user_id,
                    title: notifTitle,
                    message: fullMessage,
                    type: 'HEALTH_ALERT',
                    relatedId: dataId
                });

                console.log(`🔔 Notification sent to User ${healthData.user_id}: ${notifTitle}`);

                // 4. Emit real-time health alert qua Socket (riêng biệt với notification)
                if (global.io) {
                    global.io.to(healthData.user_id.toString()).emit('HEALTH_ALERT', {
                        alert: mainAlert,
                        riskLevel: analysis.riskLevel,
                        metrics: analysis.metrics,
                        recommendations: analysis.recommendations,
                        timestamp: new Date()
                    });
                }

                return notification;
            } else {
                console.log(`✅ Health data normal - User ${healthData.user_id}`);
                return null;
            }
        } catch (error) {
            console.error('❌ Error in analyzeAndNotify:', error);
            return null;
        }
    }

    /**
     * Disconnect from MQTT
     */
    disconnect() {
        if (this.client) {
            console.log('🔌 Disconnecting from MQTT...');
            this.client.end(false);
            this.isConnected = false;
            console.log('✅ MQTT disconnected');
        }
    }

    /**
     * Get connection status
     */
    getStatus() {
        return {
            isConnected: this.isConnected,
            reconnectAttempts: this.reconnectAttempts,
            config: {
                host: this.config.host,
                port: this.config.port,
                topic: this.config.topic
            }
        };
    }
}

// Create singleton instance
const mqttService = new MQTTService();

module.exports = mqttService;
