// HealthAI_Server/services/health_analysis_service.js
// Service phân tích dữ liệu sức khỏe và phát hiện nguy hiểm

/**
 * Phân tích dữ liệu sức khỏe và detect anomaly
 * @param {Object} healthData - Dữ liệu sức khỏe từ MQTT
 * @returns {Object} { isDangerous, alerts, riskLevel, recommendations }
 */
const analyzeHealthData = (healthData) => {
    const alerts = [];
    let riskLevel = 'normal'; // normal, warning, danger, critical

    // Extract metrics
    const heartRate = parseInt(healthData.heart_rate) || 0;
    const systolic = parseInt(healthData.blood_pressure_systolic) || 0;
    const diastolic = parseInt(healthData.blood_pressure_diastolic) || 0;
    const temperature = parseFloat(healthData.temperature) || 0;
    const spo2 = parseInt(healthData.spo2) || 0;

    // --- 1. PHÂN TÍCH NHỊP TIM (Heart Rate) ---
    if (heartRate > 0) {
        if (heartRate < 40) {
            alerts.push({
                type: 'HEART_RATE_TOO_LOW',
                title: '⚠️ Nhịp tim quá thấp',
                message: `Nhịp tim: ${heartRate} BPM (bình thường: 60-100). Có thể bị nhịp tim chậm (bradycardia).`,
                severity: 'critical',
                value: heartRate,
                unit: 'BPM'
            });
            riskLevel = 'critical';
        } else if (heartRate >= 40 && heartRate < 60) {
            alerts.push({
                type: 'HEART_RATE_LOW',
                title: '⚠️ Nhịp tim thấp',
                message: `Nhịp tim: ${heartRate} BPM. Theo dõi thêm nếu có triệu chứng.`,
                severity: 'warning',
                value: heartRate,
                unit: 'BPM'
            });
            riskLevel = riskLevel === 'normal' ? 'warning' : riskLevel;
        } else if (heartRate > 120) {
            alerts.push({
                type: 'HEART_RATE_TOO_HIGH',
                title: '🚨 Nhịp tim quá cao',
                message: `Nhịp tim: ${heartRate} BPM (bình thường: 60-100). Có thể bị nhịp tim nhanh (tachycardia).`,
                severity: 'critical',
                value: heartRate,
                unit: 'BPM'
            });
            riskLevel = 'critical';
        } else if (heartRate > 100) {
            alerts.push({
                type: 'HEART_RATE_HIGH',
                title: '⚠️ Nhịp tim cao',
                message: `Nhịp tim: ${heartRate} BPM. Nghỉ ngơi và theo dõi.`,
                severity: 'warning',
                value: heartRate,
                unit: 'BPM'
            });
            riskLevel = riskLevel === 'normal' ? 'warning' : riskLevel;
        }
    }

    // --- 2. PHÂN TÍCH HUYẾT ÁP (Blood Pressure) ---
    if (systolic > 0 && diastolic > 0) {
        // Huyết áp quá cao (Hypertensive Crisis)
        if (systolic >= 180 || diastolic >= 120) {
            alerts.push({
                type: 'BP_CRITICAL_HIGH',
                title: '🚨 CẤP CỨU: Huyết áp nguy hiểm',
                message: `Huyết áp: ${systolic}/${diastolic} mmHg. CẦN KHẨN CẤP! Liên hệ bác sĩ ngay.`,
                severity: 'critical',
                value: `${systolic}/${diastolic}`,
                unit: 'mmHg'
            });
            riskLevel = 'critical';
        }
        // Huyết áp cao (Stage 2 Hypertension)
        else if (systolic >= 140 || diastolic >= 90) {
            alerts.push({
                type: 'BP_HIGH',
                title: '⚠️ Huyết áp cao',
                message: `Huyết áp: ${systolic}/${diastolic} mmHg (bình thường: <120/80). Cần điều trị.`,
                severity: 'danger',
                value: `${systolic}/${diastolic}`,
                unit: 'mmHg'
            });
            riskLevel = riskLevel === 'normal' ? 'danger' : riskLevel;
        }
        // Huyết áp hơi cao
        else if (systolic >= 130 || diastolic >= 85) {
            alerts.push({
                type: 'BP_ELEVATED',
                title: '⚠️ Huyết áp hơi cao',
                message: `Huyết áp: ${systolic}/${diastolic} mmHg. Theo dõi thường xuyên.`,
                severity: 'warning',
                value: `${systolic}/${diastolic}`,
                unit: 'mmHg'
            });
            riskLevel = riskLevel === 'normal' ? 'warning' : riskLevel;
        }
        // Huyết áp quá thấp
        else if (systolic < 90 || diastolic < 60) {
            alerts.push({
                type: 'BP_TOO_LOW',
                title: '⚠️ Huyết áp thấp',
                message: `Huyết áp: ${systolic}/${diastolic} mmHg. Có thể gây chóng mặt.`,
                severity: 'warning',
                value: `${systolic}/${diastolic}`,
                unit: 'mmHg'
            });
            riskLevel = riskLevel === 'normal' ? 'warning' : riskLevel;
        }
    }

    // --- 3. PHÂN TÍCH NHIỆT ĐỘ (Temperature) ---
    if (temperature > 0) {
        if (temperature >= 39.0) {
            alerts.push({
                type: 'TEMPERATURE_HIGH_FEVER',
                title: '🚨 Sốt cao',
                message: `Nhiệt độ: ${temperature}°C (bình thường: 36.5-37.5). Sốt cao, cần hạ sốt.`,
                severity: 'danger',
                value: temperature,
                unit: '°C'
            });
            riskLevel = riskLevel === 'normal' ? 'danger' : riskLevel;
        } else if (temperature >= 37.5) {
            alerts.push({
                type: 'TEMPERATURE_FEVER',
                title: '⚠️ Sốt nhẹ',
                message: `Nhiệt độ: ${temperature}°C. Theo dõi và uống nhiều nước.`,
                severity: 'warning',
                value: temperature,
                unit: '°C'
            });
            riskLevel = riskLevel === 'normal' ? 'warning' : riskLevel;
        } else if (temperature < 35.0) {
            alerts.push({
                type: 'TEMPERATURE_HYPOTHERMIA',
                title: '⚠️ Thân nhiệt thấp',
                message: `Nhiệt độ: ${temperature}°C. Giữ ấm cơ thể.`,
                severity: 'warning',
                value: temperature,
                unit: '°C'
            });
            riskLevel = riskLevel === 'normal' ? 'warning' : riskLevel;
        }
    }

    // --- 4. PHÂN TÍCH SPO2 (Oxygen Saturation) ---
    if (spo2 > 0) {
        if (spo2 < 90) {
            alerts.push({
                type: 'SPO2_CRITICAL_LOW',
                title: '🚨 CẤP CỨU: Oxy máu thấp nguy hiểm',
                message: `SpO2: ${spo2}% (bình thường: >95%). CẦN KHẨN CẤP! Thiếu oxy nghiêm trọng.`,
                severity: 'critical',
                value: spo2,
                unit: '%'
            });
            riskLevel = 'critical';
        } else if (spo2 < 95) {
            alerts.push({
                type: 'SPO2_LOW',
                title: '⚠️ Oxy máu thấp',
                message: `SpO2: ${spo2}% (bình thường: >95%). Cần theo dõi chặt chẽ.`,
                severity: 'danger',
                value: spo2,
                unit: '%'
            });
            riskLevel = riskLevel === 'normal' ? 'danger' : riskLevel;
        }
    }

    // --- 5. KẾT QUẢ PHÂN TÍCH ---
    const isDangerous = riskLevel !== 'normal';

    const recommendations = [];
    if (riskLevel === 'critical') {
        recommendations.push('🚨 KHẨN CẤP: Liên hệ bác sĩ hoặc gọi cấp cứu ngay lập tức');
        recommendations.push('Không tự ý dùng thuốc, cần can thiệp y tế chuyên nghiệp');
    } else if (riskLevel === 'danger') {
        recommendations.push('⚠️ Cần liên hệ bác sĩ trong vòng 24 giờ');
        recommendations.push('Theo dõi chặt chẽ các chỉ số sức khỏe');
        recommendations.push('Nghỉ ngơi và tránh vận động mạnh');
    } else if (riskLevel === 'warning') {
        recommendations.push('Theo dõi thường xuyên các chỉ số');
        recommendations.push('Duy trì lối sống lành mạnh');
        recommendations.push('Liên hệ bác sĩ nếu triệu chứng kéo dài');
    } else {
        recommendations.push('✅ Các chỉ số sức khỏe trong giới hạn bình thường');
        recommendations.push('Tiếp tục duy trì lối sống lành mạnh');
    }

    return {
        isDangerous,
        alerts,
        riskLevel,
        recommendations,
        metrics: {
            heartRate,
            systolic,
            diastolic,
            temperature,
            spo2
        }
    };
};

/**
 * Format alert message cho notification
 */
const formatAlertMessage = (alerts, metrics) => {
    if (alerts.length === 0) return 'Các chỉ số sức khỏe bình thường';

    const criticalAlerts = alerts.filter(a => a.severity === 'critical');
    const dangerAlerts = alerts.filter(a => a.severity === 'danger');

    if (criticalAlerts.length > 0) {
        return `🚨 CẤP CỨU: ${criticalAlerts.map(a => a.title).join(', ')}`;
    } else if (dangerAlerts.length > 0) {
        return `⚠️ Cảnh báo: ${dangerAlerts.map(a => a.title).join(', ')}`;
    } else {
        return `⚠️ Chú ý: ${alerts[0].title}`;
    }
};

module.exports = {
    analyzeHealthData,
    formatAlertMessage
};
