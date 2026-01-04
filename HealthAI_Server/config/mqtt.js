// HealthAI_Server/config/mqtt.js
// MQTT Configuration for HiveMQ Cloud

module.exports = {
    // HiveMQ Cloud credentials
    hivemq: {
        host: '7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud',
        port: 8883,
        protocol: 'mqtts',
        username: 'DoAn1',
        password: 'Th123321',

        // Topics
        topics: {
            medicalData: 'device/medical_data',      // {temp, spo2, hr}
            ecgData: 'device/ecg_data',              // {device_id, packet_id, dataPoints[]}
            healthVitals: 'health/+/vitals'          // Legacy topic (nếu còn dùng)
        },

        // Connection options
        clientIdPrefix: 'healthai_server_',
        clean: true,
        reconnectPeriod: 5000,
        connectTimeout: 30000,
        keepalive: 60,
        rejectUnauthorized: true,

        // QoS levels
        qos: {
            medicalData: 1,      // At least once delivery
            ecgData: 1,
            publish: 1
        }
    },

    // Cache settings for data synchronization
    cache: {
        enabled: true,
        maxAge: 30000,           // 30 seconds - Thời gian cache dữ liệu
        cleanupInterval: 60000   // 1 minute - Dọn dẹp cache định kỳ
    },

    // Alert thresholds
    thresholds: {
        temperature: {
            min: 35.0,
            max: 38.5,
            critical_min: 34.0,
            critical_max: 40.0
        },
        heartRate: {
            min: 50,
            max: 100,
            critical_min: 40,
            critical_max: 150
        },
        spo2: {
            min: 90,
            critical_min: 85
        },
        ecg: {
            // Ngưỡng phát hiện bất thường ECG
            maxAmplitude: 2500,
            minAmplitude: 0,
            suspiciousPatternThreshold: 5  // Số điểm bất thường liên tiếp
        }
    }
};
