// HealthAI_Server/services/mqtt_service.js
// MQTT Service - Chỉ xử lý khi có dữ liệu mới từ HiveMQ

const mqtt = require('mqtt');
const { pool } = require('../config/db');
const mqttConfig = require('../config/mqtt');
const notificationService = require('./notification_service');
const predictService = require('./predict_service');

class MQTTService {
    constructor() {
        this.client = null;
        this.isConnected = false;
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = 10;

        // Track last packet_id to detect new data
        this.lastPacketId = {
            medical: null,
            ecg: null
        };

        // Alert cooldown tracking (prevent spam)
        this.lastAlertSent = {
            // Format: userId_alertType → timestamp
        };
        this.alertCooldownMinutes = 5; // Only send same alert every 5 minutes

        // MQTT Configuration
        this.config = {
            host: mqttConfig.hivemq.host,
            port: mqttConfig.hivemq.port,
            username: mqttConfig.hivemq.username,
            password: mqttConfig.hivemq.password,
            protocol: mqttConfig.hivemq.protocol,
            topics: mqttConfig.hivemq.topics,
            qos: mqttConfig.hivemq.qos
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
     * Lưu sensor warning vào database để người dùng có thể xem lịch sử
     */
    async saveSensorWarning(warningData) {
        try {
            const { user_id, device_id, warning_type, severity, message, details, sensor_data } = warningData;

            const query = `
                INSERT INTO sensor_warnings (
                    user_id, device_id, warning_type, severity, 
                    message, details, sensor_data
                ) VALUES ($1, $2, $3, $4, $5, $6, $7)
                RETURNING id, created_at
            `;

            const result = await pool.query(query, [
                user_id,
                device_id,
                warning_type,
                severity || 'warning',
                message,
                details,
                sensor_data ? JSON.stringify(sensor_data) : null
            ]);

            console.log('✅ [DB] Sensor warning saved:', result.rows[0].id);
            return result.rows[0];
        } catch (error) {
            console.error('❌ [DB] Failed to save sensor warning:', error.message);
            return null;
        }
    }

    /**
     * Subscribe to health sensor topics
     */
    subscribe() {
        if (!this.client || !this.isConnected) {
            console.error('❌ Cannot subscribe: MQTT not connected');
            return;
        }

        // Subscribe to specific device topics
        const topics = [
            { topic: this.config.topics.medicalData, qos: this.config.qos.medicalData },
            { topic: this.config.topics.ecgData, qos: this.config.qos.ecgData },
            { topic: this.config.topics.healthVitals, qos: 1 }  // Legacy support
        ];

        topics.forEach(({ topic, qos }) => {
            this.client.subscribe(topic, { qos }, (error) => {
                if (error) {
                    console.error(`❌ Subscribe error for ${topic}:`, error);
                } else {
                    console.log(`✅ Subscribed to: ${topic} (QoS ${qos})`);
                }
            });
        });
    }

    /**
     * Handle incoming MQTT message
     * CHỈ XỬ LÝ KHI CÓ DỮ LIỆU MỚI
     */
    async handleMessage(topic, messageStr) {
        try {
            // Parse message
            let data;
            try {
                data = JSON.parse(messageStr);
            } catch (parseError) {
                console.warn('⚠️ Message is not JSON, skipping');
                return;
            }

            // Route based on topic
            if (topic === this.config.topics.medicalData) {
                await this.handleMedicalData(data);
            } else if (topic === this.config.topics.ecgData) {
                await this.handleECGData(data);
            } else if (topic.startsWith('health/') && topic.includes('/vitals')) {
                await this.handleLegacyHealthData(topic, data);
            }

        } catch (error) {
            console.error('❌ Error processing MQTT message:', error);
        }
    }

    /**
     * Check if alert can be sent (cooldown check)
     * @param {number} userId - User ID
     * @param {string} alertType - Alert type (mlp_high_risk, ecg_danger, etc.)
     * @returns {boolean} - true if can send, false if in cooldown
     */
    canSendAlert(userId, alertType) {
        const key = `${userId}_${alertType}`;
        const now = Date.now();
        const lastSent = this.lastAlertSent[key];

        if (!lastSent) {
            // First time sending this alert
            this.lastAlertSent[key] = now;
            return true;
        }

        const cooldownMs = this.alertCooldownMinutes * 60 * 1000;
        const timeSinceLastAlert = now - lastSent;

        if (timeSinceLastAlert >= cooldownMs) {
            // Cooldown expired
            this.lastAlertSent[key] = now;
            return true;
        }

        // Still in cooldown
        const remainingMinutes = Math.ceil((cooldownMs - timeSinceLastAlert) / 60000);
        console.log(`⏸️  [COOLDOWN] Alert skipped for user ${userId} (${alertType}). Next alert in ${remainingMinutes} min`);
        return false;
    }

    /**
     * Handle medical data: {temp, spo2, hr}
     * Chỉ xử lý nếu là dữ liệu mới (khác packet_id/timestamp trước đó)
     */
    async handleMedicalData(data) {
        try {
            // Tạo unique identifier (có thể dùng timestamp hoặc hash của data)
            const dataHash = `${data.temp}_${data.spo2}_${data.hr}_${Date.now()}`;

            // Kiểm tra có phải dữ liệu mới không
            if (this.lastPacketId.medical === dataHash) {
                console.log('⏭️ Medical data unchanged, skipping...');
                return; // Không xử lý nếu trùng
            }

            this.lastPacketId.medical = dataHash;

            // Lấy user_id từ payload (hỗ trợ cả userID và user_id)
            let userId = data.userID || data.user_id;

            if (!userId) {
                console.warn('⚠️ [Medical] Không tìm thấy userID trong dữ liệu, bỏ qua');
                return;
            }

            console.log(`🔗 Processing medical data for User ${userId}`);

            const medicalData = {
                temperature: parseFloat(data.temp || 0),
                spo2: parseInt(data.spo2 || 0),
                heart_rate: parseInt(data.hr || 0),
                packet_id: dataHash,
                measured_at: new Date(),
                device_id: data.device_id || 'ESP32',
                user_id: userId
            };

            console.log(`📩 NEW Medical data: HR=${medicalData.heart_rate}, SpO2=${medicalData.spo2}, Temp=${medicalData.temperature}°C, User=${medicalData.user_id}`);

            // Broadcast to apps via Socket.IO (để đồng bộ)
            if (global.io) {
                // Emit data activity để frontend biết có dữ liệu mới (online)
                const activityData = {
                    type: 'medical',
                    timestamp: new Date(),
                    user_id: medicalData.user_id
                };

                global.io.emit('mqtt_data_activity', activityData);
                console.log(`📡 [EMIT] mqtt_data_activity broadcast - Type: medical, User: ${medicalData.user_id || 'null'}`);

                global.io.emit('medical_data_new', {
                    ...medicalData,
                    timestamp: new Date()
                });
            }

            // Lưu vào database
            const recordId = await this.saveMedicalData(medicalData);

            // === AI DIAGNOSIS - MLP Model ===
            if (medicalData.user_id) {
                try {
                    console.log('🤖 [AI] Running MLP diagnosis...');
                    const aiResult = await predictService.processVitals(
                        medicalData.user_id,
                        {
                            heart_rate: medicalData.heart_rate,
                            spo2: medicalData.spo2,
                            temperature: medicalData.temperature,
                            sys_bp: null, // ESP32 chưa gửi
                            dia_bp: null,
                            packet_id: medicalData.packet_id
                        }
                    );

                    // LOG KẾT QUẢ CHẨN ĐOÁN
                    console.log('\n═════════════════════════════════════════');
                    console.log('✅ [AI-MLP] DIAGNOSIS COMPLETED');
                    console.log(`   User ID: ${medicalData.user_id}`);
                    console.log(`   Risk Level: ${aiResult.riskLabel}`);
                    console.log(`   Confidence: ${aiResult.confidence}%`);
                    console.log(`   Severity: ${aiResult.severity}`);
                    console.log(`   Record ID: ${aiResult.recordId}`);
                    console.log('═════════════════════════════════════════\n');

                    // Gửi cảnh báo nếu High Risk
                    if (aiResult.riskLabel === 'High Risk' || aiResult.severity === 'DANGER') {
                        console.log(`🚨 [AI] High risk detected: ${aiResult.riskLabel}`);

                        // Check cooldown before sending alert
                        if (!this.canSendAlert(medicalData.user_id, 'mlp_high_risk')) {
                            return; // Skip if in cooldown
                        }

                        await notificationService.createNotification({
                            userId: medicalData.user_id,
                            title: '⚠️ CẢNH BÁO NGUY HIỂM - Chỉ số sức khỏe bất thường',
                            message: `AI phát hiện nguy cơ ${aiResult.riskLabel}. Độ tin cậy: ${aiResult.confidence}%. Vui lòng kiểm tra sức khỏe ngay.`,
                            type: 'AI_HEALTH_ALERT',
                            relatedId: aiResult.recordId,
                            priority: 'HIGH'
                        });

                        console.log('📱 [NOTIFICATION] Alert sent to user');

                        // Real-time alert
                        if (global.io) {
                            global.io.to(`user_${medicalData.user_id}`).emit('ai_medical_alert', {
                                model: 'MLP',
                                riskLabel: aiResult.riskLabel,
                                confidence: aiResult.confidence,
                                severity: aiResult.severity,
                                recordId: aiResult.recordId,
                                timestamp: new Date()
                            });
                            console.log('📡 [SOCKET.IO] Real-time alert emitted');
                        }
                    } else {
                        console.log('✅ [AI] Normal risk level - No alert needed');
                    }

                } catch (aiError) {
                    // Handle validation errors gracefully
                    if (aiError.message.includes('Invalid') || aiError.message.includes('invalid') || aiError.message.includes('Cannot diagnose')) {
                        console.warn('⚠️ [AI] Skipping diagnosis - invalid input:', aiError.message);

                        // Lưu sensor warning vào database
                        await this.saveSensorWarning({
                            user_id: medicalData.user_id,
                            device_id: medicalData.device_id,
                            warning_type: 'vital_signs',
                            severity: 'warning',
                            message: 'Dữ liệu cảm biến không hợp lệ. Vui lòng kiểm tra thiết bị.',
                            details: aiError.message,
                            sensor_data: {
                                spo2: medicalData.spo2,
                                heart_rate: medicalData.heart_rate,
                                temperature: medicalData.temperature,
                                sys_bp: medicalData.sys_bp,
                                dia_bp: medicalData.dia_bp
                            }
                        });

                        // Gửi cảnh báo đến người dùng về vấn đề cảm biến
                        const io = require('../socket_manager').io;
                        if (io && medicalData.user_id) {
                            io.to(`user_${medicalData.user_id}`).emit('sensor_warning', {
                                type: 'vital_signs',
                                message: 'Dữ liệu cảm biến không hợp lệ. Vui lòng kiểm tra thiết bị.',
                                details: aiError.message,
                                data: {
                                    spo2: medicalData.spo2,
                                    heart_rate: medicalData.heart_rate,
                                    temperature: medicalData.temperature
                                },
                                timestamp: new Date(),
                                severity: 'warning'
                            });
                            console.log('📡 [SOCKET.IO] Sensor warning sent to user:', medicalData.user_id);
                        }

                        // Publish MQTT warning để ESP32 có thể hiển thị LED cảnh báo
                        if (this.client && medicalData.device_id) {
                            this.client.publish(
                                `health/device/${medicalData.device_id}/warning`,
                                JSON.stringify({
                                    type: 'sensor_error',
                                    message: 'Sensor data invalid',
                                    details: aiError.message,
                                    timestamp: new Date()
                                }),
                                { qos: 1 }
                            );
                            console.log('📡 [MQTT] Warning published to device:', medicalData.device_id);
                        }
                    } else {
                        console.error('❌ [AI] MLP diagnosis failed:', aiError.message);
                    }
                }
            } else {
                console.log('⏭️ [AI] Skipping diagnosis - no user_id');
            }

        } catch (error) {
            console.error('❌ Error handling medical data:', error);
        }
    }

    /**
     * Handle ECG data: {device_id, packet_id, dataPoints[]}
     * Chỉ xử lý nếu packet_id mới (chưa xử lý)
     */
    async handleECGData(data) {
        try {
            const packetId = data.packet_id;

            // Kiểm tra packet_id mới
            if (this.lastPacketId.ecg === packetId) {
                console.log(`⏭️ ECG packet ${packetId} already processed, skipping...`);
                return; // Đã xử lý rồi, bỏ qua
            }

            this.lastPacketId.ecg = packetId;

            // Lấy user_id từ payload (hỗ trợ cả userID và user_id) - MAP TRƯỚC
            let userId = data.userID || data.user_id;

            if (!userId) {
                console.warn('⚠️ [ECG] Không tìm thấy userID trong dữ liệu, bỏ qua');
                return;
            }

            console.log(`🔗 Processing ECG data for User ${userId}`);

            // Emit data activity SAU KHI đã có userId
            if (global.io) {
                const activityData = {
                    type: 'ecg',
                    timestamp: new Date(),
                    user_id: userId  // Dùng userId đã map
                };
                global.io.emit('mqtt_data_activity', activityData);
                console.log(`📡 [EMIT] mqtt_data_activity broadcast - Type: ecg, User: ${userId}`);
            }

            const ecgData = {
                device_id: data.device_id || 'ESP32',
                packet_id: packetId,
                dataPoints: data.dataPoints || [],
                measured_at: new Date(),
                user_id: userId
            };

            console.log(`📊 NEW ECG data: Packet ${packetId}, ${ecgData.dataPoints.length} points`);

            // Broadcast to apps via Socket.IO
            if (global.io) {
                global.io.emit('ecg_data_new', {
                    device_id: ecgData.device_id,
                    packet_id: ecgData.packet_id,
                    dataPoints: ecgData.dataPoints,
                    timestamp: ecgData.measured_at
                });
            }

            // Lưu vào database
            const recordId = await this.saveECGData(ecgData);

            // === AI DIAGNOSIS - CNN Model ===
            if (ecgData.user_id && ecgData.dataPoints.length >= 100) {
                try {
                    console.log('🤖 [AI] Running ECG diagnosis...');
                    const aiResult = await predictService.processECG(
                        ecgData.user_id,
                        {
                            dataPoints: ecgData.dataPoints,
                            device_id: ecgData.device_id,
                            packet_id: ecgData.packet_id
                        }
                    );

                    // LOG KẾT QUẢ CHẨN ĐOÁN ECG
                    console.log('\n═════════════════════════════════════════');
                    console.log('✅ [AI-ECG] DIAGNOSIS COMPLETED');
                    console.log(`   User ID: ${ecgData.user_id}`);
                    console.log(`   Classification: ${aiResult.result}`);
                    console.log(`   Confidence: ${aiResult.confidence}%`);
                    console.log(`   Severity: ${aiResult.severity}`);
                    console.log(`   ECG ID: ${aiResult.ecgId}`);
                    console.log(`   Packet ID: ${ecgData.packet_id}`);
                    console.log(`   Data Points: ${ecgData.dataPoints.length}`);
                    console.log('═════════════════════════════════════════\n');

                    // Gửi cảnh báo nếu phát hiện bất thường (DANGER hoặc WARNING)
                    if (aiResult.severity === 'DANGER' || aiResult.severity === 'WARNING') {
                        console.log(`🚨 [AI] ECG abnormality detected: ${aiResult.result}`);

                        // Check cooldown before sending alert (use result type for specificity)
                        const alertType = `ecg_${aiResult.result.toLowerCase().replace(/\s+/g, '_')}`;
                        if (!this.canSendAlert(ecgData.user_id, alertType)) {
                            return; // Skip if in cooldown
                        }

                        await notificationService.createNotification({
                            userId: ecgData.user_id,
                            title: '⚠️ CẢNH BÁO AI - Tín hiệu ECG',
                            message: `AI phát hiện nhịp tim bất thường: ${aiResult.result}. ${aiResult.recommendation}`,
                            type: 'AI_ECG_ALERT',
                            relatedId: aiResult.ecgId,
                            priority: aiResult.severity === 'DANGER' ? 'HIGH' : 'MEDIUM'
                        });

                        console.log('📱 [NOTIFICATION] ECG alert sent to user');

                        // Real-time alert
                        if (global.io) {
                            global.io.to(`user_${ecgData.user_id}`).emit('ai_ecg_alert', {
                                model: 'CNN',
                                result: aiResult.result,
                                confidence: aiResult.confidence,
                                severity: aiResult.severity,
                                recommendation: aiResult.recommendation,
                                ecgId: aiResult.ecgId,
                                timestamp: new Date()
                            });
                            console.log('📡 [SOCKET.IO] Real-time ECG alert emitted');
                        }
                    } else {
                        console.log('✅ [AI] ECG pattern normal - No alert needed');
                    }

                } catch (error) {
                    // Handle validation errors gracefully
                    if (error.message.includes('Invalid') || error.message.includes('invalid') || error.message.includes('saturated')) {
                        console.warn('⚠️ [AI] Skipping ECG diagnosis - invalid signal:', error.message);

                        // Lưu ECG sensor warning vào database
                        await this.saveSensorWarning({
                            user_id: ecgData.user_id,
                            device_id: ecgData.device_id,
                            warning_type: 'ecg_signal',
                            severity: error.message.includes('saturated') ? 'error' : 'warning',
                            message: 'Tín hiệu ECG không hợp lệ. Vui lòng kiểm tra điện cực dán.',
                            details: error.message,
                            sensor_data: {
                                packet_id: ecgData.packet_id,
                                datapoints_count: ecgData.dataPoints?.length || 0,
                                sample_values: ecgData.dataPoints?.slice(0, 10) || [] // First 10 samples for diagnosis
                            }
                        });

                        // Gửi cảnh báo đến người dùng về vấn đề ECG signal
                        const io = require('../socket_manager').io;
                        if (io && ecgData.user_id) {
                            io.to(`user_${ecgData.user_id}`).emit('sensor_warning', {
                                type: 'ecg_signal',
                                message: 'Tín hiệu ECG không hợp lệ. Vui lòng kiểm tra điện cực dán.',
                                details: error.message,
                                data: {
                                    device_id: ecgData.device_id,
                                    packet_id: ecgData.packet_id,
                                    datapoints_count: ecgData.dataPoints?.length || 0
                                },
                                timestamp: new Date(),
                                severity: 'warning'
                            });
                            console.log('📡 [SOCKET.IO] ECG sensor warning sent to user:', ecgData.user_id);
                        }

                        // Publish MQTT warning để ESP32 có thể hiển thị LED cảnh báo
                        if (this.client && ecgData.device_id) {
                            this.client.publish(
                                `health/device/${ecgData.device_id}/warning`,
                                JSON.stringify({
                                    type: 'ecg_sensor_error',
                                    message: 'ECG signal quality poor',
                                    details: error.message,
                                    timestamp: new Date()
                                }),
                                { qos: 1 }
                            );
                            console.log('📡 [MQTT] ECG warning published to device:', ecgData.device_id);
                        }
                    } else {
                        console.error('❌ [AI] ECG diagnosis failed:', error.message);
                    }
                }
            } else {
                console.log(`⏭️ [AI] Skipping ECG diagnosis - ${ecgData.user_id ? 'insufficient data points' : 'no user_id'}`);
            }

        } catch (error) {
            console.error('❌ Error handling ECG data:', error);
        }
    }

    /**
     * Handle legacy health data (backward compatibility)
     */
    async handleLegacyHealthData(topic, data) {
        try {
            const topicParts = topic.split('/');
            const userId = topicParts[1];

            const healthData = {
                user_id: userId,
                heart_rate: data.heart_rate || null,
                spo2: data.spo2 || null,
                temperature: data.temp || null,
                measured_at: new Date()
            };

            console.log(`📥 Legacy data User ${userId}:`, healthData);

            const recordId = await this.saveMedicalData(healthData);
            // Legacy data - no AI analysis (user_id format incompatible)
            console.log('⏭️ Legacy format detected - skipping AI analysis');
        } catch (error) {
            console.error('❌ Error handling legacy health data:', error);
        }
    }

    /**
     * Save medical data to database
     */
    async saveMedicalData(data) {
        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            const query = `
                INSERT INTO health_records (
                    user_id,
                    packet_id,
                    heart_rate,
                    spo2,
                    temperature,
                    measured_at
                ) VALUES ($1, $2, $3, $4, $5, $6)
                RETURNING id
            `;

            const values = [
                data.user_id,
                data.packet_id || null,
                data.heart_rate || null,
                data.spo2 || null,
                data.temperature || null,
                data.measured_at || new Date()
            ];

            const result = await client.query(query, values);
            await client.query('COMMIT');

            console.log(`💾 Medical data saved: Record ID ${result.rows[0].id}`);
            return result.rows[0].id;

        } catch (error) {
            await client.query('ROLLBACK');
            console.error('❌ Database error saving medical data:', error);
            throw error;
        } finally {
            client.release();
        }
    }

    /**
     * Save ECG data to database
     */
    async saveECGData(data) {
        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            const query = `
                INSERT INTO ecg_readings (
                    user_id,
                    device_id,
                    packet_id,
                    data_points,
                    sample_rate,
                    measured_at
                ) VALUES ($1, $2, $3, $4, $5, $6)
                RETURNING id
            `;

            const values = [
                data.user_id,
                data.device_id || 'ESP32',
                data.packet_id,
                JSON.stringify(data.dataPoints),
                250, // Default sample rate
                data.measured_at || new Date()
            ];

            const result = await client.query(query, values);
            await client.query('COMMIT');

            console.log(`💾 ECG data saved: Record ID ${result.rows[0].id}, Packet ${data.packet_id}`);
            return result.rows[0].id;

        } catch (error) {
            await client.query('ROLLBACK');
            console.error('❌ Database error saving ECG data:', error);
        } finally {
            client.release();
        }
    }

    /**
     * Get MQTT connection info for app
     */
    getConnectionInfo() {
        return {
            host: this.config.host,
            port: this.config.port,
            protocol: this.config.protocol,
            username: this.config.username,
            topics: this.config.topics
        };
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
