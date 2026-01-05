# 🏥 HEALTHAI SERVER - TÀI LIỆU BACKEND (PART 2)

> **Tiếp theo từ Part 1: AI/ML Models, Services Layer, Workers**

---

## 📋 MỤC LỤC PART 2

- [9. AI/ML Models](#9-aiml-models)
- [10. Services Layer](#10-services-layer)
- [11. Background Workers](#11-background-workers)
- [12. Configuration](#12-configuration)
- [13. Deployment](#13-deployment)

---

## 9. AI/ML MODELS

### 9.1 Model Overview

#### Model 1: MLP - Heart Disease Prediction
- **Type**: Multi-Layer Perceptron (Dense Neural Network)
- **Framework**: TensorFlow.js (Keras 3.x converted)
- **Accuracy**: 89.3% on test set
- **Input**: 11 features (HR, SpO2, Temp, Age, Gender, BMI, MAP, etc.)
- **Output**: 4 risk classes (Low, Medium, High, Critical)

#### Model 2: CNN - ECG Anomaly Detection
- **Type**: Convolutional Neural Network
- **Framework**: TensorFlow.js
- **Input**: 100-point ECG signal (1D array)
- **Output**: Binary classification (Normal / Anomaly)

### 9.2 Model Loading

```javascript
// config/aiModels.js
const tf = require('@tensorflow/tfjs-node');
const fs = require('fs').promises;
const path = require('path');

const models = {};

/**
 * Load MLP model cho dự đoán bệnh tim
 */
const loadMLP = async () => {
    const modelDir = path.join(__dirname, '../ai_models/heart_disease_mlp');
    const modelJsonPath = path.join(modelDir, 'model.json');
    
    console.log('🤖 [AI] Loading MLP Heart Disease Model...');
    
    // Custom handler để patch Keras 3.x incompatibilities
    const handler = await createManualPatchedHandler(modelJsonPath);
    const model = await tf.loadLayersModel(handler);
    
    // Load scaler params (Standard Scaler)
    const scalerPath = path.join(modelDir, 'scaler_params.json');
    const scalerData = await fs.readFile(scalerPath, 'utf8');
    const scaler = JSON.parse(scalerData);
    
    // Load risk encoder (Label mapping)
    const encoderPath = path.join(modelDir, 'risk_encoder.json');
    const encoderData = await fs.readFile(encoderPath, 'utf8');
    const riskEncoder = JSON.parse(encoderData);
    
    models.model_mlp = model;
    models.scaler_mlp = scaler;
    models.risk_encoder = riskEncoder;
    
    console.log('✅ [AI] MLP Model loaded successfully');
    console.log(`   - Input shape: [null, ${model.inputs[0].shape[1]}]`);
    console.log(`   - Output classes: ${Object.keys(riskEncoder).length}`);
};

/**
 * Load CNN model cho phân tích ECG
 */
const loadCNN = async () => {
    const modelDir = path.join(__dirname, '../ai_models/ecg_anomaly_cnn');
    const modelJsonPath = path.join(modelDir, 'model.json');
    
    console.log('🤖 [AI] Loading CNN ECG Model...');
    
    const handler = await createManualPatchedHandler(modelJsonPath);
    const model = await tf.loadLayersModel(handler);
    
    models.model_cnn = model;
    
    console.log('✅ [AI] CNN Model loaded successfully');
    console.log(`   - Input shape: ${model.inputs[0].shape}`);
};

/**
 * Patch handler cho Keras 3.x models
 */
const createManualPatchedHandler = async (modelJsonPath) => {
    const modelDir = path.dirname(modelJsonPath);
    const jsonText = await fs.readFile(modelJsonPath, 'utf8');
    const originalArtifacts = JSON.parse(jsonText);
    
    const topology = originalArtifacts.modelTopology;
    
    // Patch 1: batch_shape → batchInputShape
    if (topology.model_config?.config?.layers?.[0]?.config?.batch_shape) {
        const inputLayer = topology.model_config.config.layers[0].config;
        inputLayer.batchInputShape = inputLayer.batch_shape;
        delete inputLayer.batch_shape;
    }
    
    // Patch 2: Remove training_config (Keras 3.x)
    if (topology.training_config) {
        delete topology.training_config;
    }
    
    // Load weights
    const manifests = originalArtifacts.weightsManifest;
    const allPaths = manifests.flatMap(m => m.paths);
    
    const weightSpecs = manifests.flatMap(m => m.weights);
    const weightData = await Promise.all(
        allPaths.map(p => fs.readFile(path.join(modelDir, p)))
    );
    
    const concatenated = Buffer.concat(weightData);
    
    return {
        load: async () => ({
            modelTopology: topology,
            weightSpecs: weightSpecs,
            weightData: new Uint8Array(concatenated).buffer,
            format: originalArtifacts.format,
            generatedBy: originalArtifacts.generatedBy,
            convertedBy: originalArtifacts.convertedBy
        })
    };
};

/**
 * Load tất cả models
 */
const loadAllModels = async () => {
    await loadMLP();
    await loadCNN();
};

/**
 * Get loaded models
 */
const getModels = () => models;

module.exports = { loadAllModels, getModels };
```

### 9.3 MLP Heart Disease Prediction Service

```javascript
// services/predict_service.js
const tf = require('@tensorflow/tfjs-node');
const { getModels } = require('../config/aiModels');
const { pool } = require('../config/db');

/**
 * Standard Scaler normalization
 */
const transformData = (inputArray, scaler) => {
    if (!scaler || !scaler.mean || !scaler.scale) return inputArray;
    
    return inputArray.map((val, index) => {
        const mean = scaler.mean[index] || 0;
        const scale = scaler.scale[index] || 1;
        return (val - mean) / scale;
    });
};

/**
 * Dự đoán bệnh tim từ vital signs
 */
const processVitals = async (userId, { heart_rate, spo2, temperature, sys_bp, dia_bp }) => {
    const { model_mlp, scaler_mlp, risk_encoder } = getModels();
    
    if (!model_mlp) {
        throw new Error("Model MLP chưa tải xong.");
    }
    
    const client = await pool.connect();
    
    try {
        // 1. Lấy thông tin nhân khẩu học từ DB
        const userQuery = `
            SELECT 
                p.date_of_birth,
                p.gender,
                phi.weight,
                phi.height
            FROM users u
            LEFT JOIN profiles p ON u.id = p.user_id
            LEFT JOIN patient_health_info phi ON u.id = phi.patient_id
            WHERE u.id = $1
        `;
        
        const userResult = await client.query(userQuery, [userId]);
        
        if (userResult.rows.length === 0) {
            throw new Error("Không tìm thấy thông tin bệnh nhân");
        }
        
        const userProfile = userResult.rows[0];
        
        // 2. Tính toán các features phái sinh
        
        // 2.1. Tuổi (từ date_of_birth)
        let age = 30; // Default
        if (userProfile.date_of_birth) {
            const birthDate = new Date(userProfile.date_of_birth);
            const today = new Date();
            age = today.getFullYear() - birthDate.getFullYear();
            const monthDiff = today.getMonth() - birthDate.getMonth();
            if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
                age--;
            }
        }
        
        // 2.2. BMI = Weight / Height^2
        const height_m = userProfile.height ? userProfile.height / 100 : 1.7;
        const weight_kg = userProfile.weight || 65;
        const derived_bmi = weight_kg / (height_m * height_m);
        
        // 2.3. Gender Encoded (Male=1, Female=0)
        const genderStr = String(userProfile.gender || '').toLowerCase();
        const gender_encoded = (genderStr === 'male' || genderStr === 'nam' || genderStr === '1') ? 1 : 0;
        
        // 2.4. MAP (Mean Arterial Pressure) = (SBP + 2*DBP) / 3
        // Nếu không có BP, dùng giá trị bình thường (115/75 → MAP ~88)
        const sbp = sys_bp || 115;
        const dbp = dia_bp || 75;
        const derived_map = (sbp + 2 * dbp) / 3;
        
        if (!sys_bp || !dia_bp) {
            console.log(`ℹ️ [AI-MLP] Sử dụng huyết áp giả cho user ${userId}: ${sbp}/${dbp} mmHg`);
        }
        
        // 3. Validation: Reject invalid vitals
        const validationErrors = [];
        if (spo2 <= 0 || spo2 > 100) {
            validationErrors.push(`Invalid SpO2: ${spo2}%`);
        }
        if (heart_rate <= 0 || heart_rate > 250) {
            validationErrors.push(`Invalid HR: ${heart_rate} bpm`);
        }
        if (temperature < 35 || temperature > 40) {
            validationErrors.push(`Abnormal Temp: ${temperature}°C`);
        }
        
        if (validationErrors.length > 0) {
            console.warn('⚠️ [AI-MLP] Invalid vital signs:', validationErrors);
            throw new Error(`Cannot diagnose: ${validationErrors.join(', ')}`);
        }
        
        // 4. Tạo input vector (11 features)
        // Order phải khớp với model training:
        // [age, gender, hr, temp, spo2, sbp, dbp, bmi, map, resting_ecg, exercise_angina]
        const inputFeatures = [
            age,                    // 0
            gender_encoded,         // 1
            heart_rate,            // 2
            temperature,           // 3
            spo2,                  // 4
            sbp,                   // 5
            dbp,                   // 6
            derived_bmi,           // 7
            derived_map,           // 8
            0,                     // 9: resting_ecg (default 0)
            0                      // 10: exercise_angina (default 0)
        ];
        
        // 5. Normalize với Standard Scaler
        const normalizedInput = transformData(inputFeatures, scaler_mlp);
        
        // 6. Inference
        const inputTensor = tf.tensor2d([normalizedInput], [1, 11]);
        const prediction = model_mlp.predict(inputTensor);
        const probabilities = await prediction.array();
        
        // Clean up tensors
        inputTensor.dispose();
        prediction.dispose();
        
        // 7. Decode prediction
        const probs = probabilities[0];
        const maxIndex = probs.indexOf(Math.max(...probs));
        const confidence = probs[maxIndex];
        
        // Map index to risk level
        const riskClasses = ['Low Risk', 'Medium Risk', 'High Risk', 'Critical Risk'];
        const predictedClass = riskClasses[maxIndex];
        
        console.log(`\n${'='.repeat(60)}`);
        console.log(`🤖 [AI-MLP] PREDICTION RESULT`);
        console.log(`   User ID: ${userId}`);
        console.log(`   Input Features: ${JSON.stringify(inputFeatures)}`);
        console.log(`   Predicted Class: ${predictedClass}`);
        console.log(`   Confidence: ${(confidence * 100).toFixed(2)}%`);
        console.log(`   Probabilities: ${probs.map(p => (p * 100).toFixed(2) + '%').join(', ')}`);
        console.log(`${'='.repeat(60)}\n`);
        
        // 8. Lưu vào database
        const insertQuery = `
            INSERT INTO ai_predictions (user_id, model_type, input_data, prediction_class, confidence_score, output_probabilities)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id
        `;
        
        const inputDataJson = {
            age,
            gender: genderStr,
            heart_rate,
            spo2,
            temperature,
            sys_bp: sbp,
            dia_bp: dbp,
            bmi: derived_bmi,
            map: derived_map
        };
        
        const outputProbs = {
            low_risk: probs[0],
            medium_risk: probs[1],
            high_risk: probs[2],
            critical_risk: probs[3]
        };
        
        const result = await client.query(insertQuery, [
            userId,
            'MLP_HEART_DISEASE',
            JSON.stringify(inputDataJson),
            predictedClass,
            confidence,
            JSON.stringify(outputProbs)
        ]);
        
        return {
            predictionId: result.rows[0].id,
            riskLevel: predictedClass,
            confidence: confidence,
            probabilities: outputProbs,
            recommendations: generateRecommendations(predictedClass, inputDataJson)
        };
        
    } finally {
        client.release();
    }
};

/**
 * Generate recommendations based on risk level
 */
const generateRecommendations = (riskLevel, data) => {
    const recommendations = [];
    
    if (riskLevel === 'Critical Risk') {
        recommendations.push('🚨 CẦN KHẨN CẤP: Liên hệ bác sĩ ngay lập tức!');
        recommendations.push('Gọi 115 hoặc đến phòng cấp cứu gần nhất.');
    } else if (riskLevel === 'High Risk') {
        recommendations.push('⚠️ Nguy cơ cao: Đặt lịch khám bác sĩ tim mạch trong 24-48 giờ.');
        recommendations.push('Theo dõi chỉ số sức khỏe thường xuyên.');
    } else if (riskLevel === 'Medium Risk') {
        recommendations.push('ℹ️ Nguy cơ trung bình: Nên khám định kỳ với bác sĩ.');
        recommendations.push('Duy trì lối sống lành mạnh, tập thể dục vừa phải.');
    } else {
        recommendations.push('✅ Nguy cơ thấp: Tiếp tục duy trì sức khỏe tốt!');
        recommendations.push('Khám sức khỏe định kỳ mỗi 6 tháng.');
    }
    
    // Specific recommendations based on metrics
    if (data.heart_rate > 100) {
        recommendations.push('💓 Nhịp tim cao: Nghỉ ngơi, tránh căng thẳng.');
    }
    if (data.spo2 < 95) {
        recommendations.push('🫁 SpO2 thấp: Kiểm tra chức năng hô hấp.');
    }
    if (data.bmi > 30) {
        recommendations.push('⚖️ BMI cao: Cân nhắc chế độ ăn giảm cân.');
    }
    
    return recommendations;
};

module.exports = { processVitals };
```

### 9.4 CNN ECG Anomaly Detection

```javascript
// services/predict_service.js (continued)

/**
 * Phân tích ECG signal
 */
const processECG = async (userId, ecgData) => {
    const { model_cnn } = getModels();
    
    if (!model_cnn) {
        throw new Error("Model CNN chưa tải xong.");
    }
    
    // 1. Preprocessing: Normalize to [0, 1]
    const normalized = ecgData.map(val => val / 4095);
    
    // 2. Reshape to [1, 100, 1] (batch, timesteps, channels)
    const inputTensor = tf.tensor3d([normalized.map(v => [v])], [1, 100, 1]);
    
    // 3. Inference
    const prediction = model_cnn.predict(inputTensor);
    const result = await prediction.array();
    
    // Clean up
    inputTensor.dispose();
    prediction.dispose();
    
    // 4. Decode (Binary classification)
    const anomalyScore = result[0][0];  // Probability of anomaly
    const isAnomaly = anomalyScore > 0.5;
    
    console.log(`🤖 [AI-CNN] ECG Analysis: ${isAnomaly ? 'ANOMALY' : 'NORMAL'} (Score: ${anomalyScore.toFixed(4)})`);
    
    // 5. Save to database
    await pool.query(`
        INSERT INTO ai_predictions (user_id, model_type, input_data, prediction_class, confidence_score)
        VALUES ($1, $2, $3, $4, $5)
    `, [
        userId,
        'CNN_ECG_ANOMALY',
        JSON.stringify({ ecg_length: ecgData.length }),
        isAnomaly ? 'Anomaly' : 'Normal',
        anomalyScore
    ]);
    
    return {
        isAnomaly,
        anomalyScore,
        recommendation: isAnomaly ? 'Phát hiện bất thường trong ECG. Vui lòng tham khảo bác sĩ.' : 'ECG bình thường.'
    };
};
```

---

## 10. SERVICES LAYER

### 10.1 Health Analysis Service

```javascript
// services/health_analysis_service.js

/**
 * Phân tích realtime dữ liệu sức khỏe (Rule-based)
 */
const analyzeHealthData = (healthData) => {
    const alerts = [];
    let riskLevel = 'normal'; // normal, warning, danger, critical
    
    const heartRate = parseInt(healthData.heart_rate) || 0;
    const systolic = parseInt(healthData.blood_pressure_systolic) || 0;
    const diastolic = parseInt(healthData.blood_pressure_diastolic) || 0;
    const temperature = parseFloat(healthData.temperature) || 0;
    const spo2 = parseInt(healthData.spo2) || 0;
    
    // 1. NHỊP TIM (Heart Rate)
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
                severity: 'warning'
            });
            riskLevel = riskLevel === 'normal' ? 'warning' : riskLevel;
        } else if (heartRate > 120) {
            alerts.push({
                type: 'HEART_RATE_TOO_HIGH',
                title: '🚨 Nhịp tim quá cao',
                message: `Nhịp tim: ${heartRate} BPM. Có thể bị nhịp tim nhanh (tachycardia).`,
                severity: 'critical'
            });
            riskLevel = 'critical';
        } else if (heartRate > 100) {
            alerts.push({
                type: 'HEART_RATE_HIGH',
                title: '⚠️ Nhịp tim cao',
                message: `Nhịp tim: ${heartRate} BPM. Nghỉ ngơi và theo dõi.`,
                severity: 'warning'
            });
            riskLevel = riskLevel === 'normal' ? 'warning' : riskLevel;
        }
    }
    
    // 2. HUYẾT ÁP (Blood Pressure)
    if (systolic > 0 && diastolic > 0) {
        if (systolic >= 180 || diastolic >= 120) {
            alerts.push({
                type: 'BP_CRITICAL_HIGH',
                title: '🚨 CẤP CỨU: Huyết áp nguy hiểm',
                message: `Huyết áp: ${systolic}/${diastolic} mmHg. CẦN KHẨN CẤP!`,
                severity: 'critical'
            });
            riskLevel = 'critical';
        } else if (systolic >= 140 || diastolic >= 90) {
            alerts.push({
                type: 'BP_HIGH',
                title: '⚠️ Huyết áp cao',
                message: `Huyết áp: ${systolic}/${diastolic} mmHg (bình thường: <120/80).`,
                severity: 'danger'
            });
            riskLevel = riskLevel === 'normal' ? 'danger' : riskLevel;
        } else if (systolic < 90 || diastolic < 60) {
            alerts.push({
                type: 'BP_LOW',
                title: '⚠️ Huyết áp thấp',
                message: `Huyết áp: ${systolic}/${diastolic} mmHg. Có thể bị hạ huyết áp.`,
                severity: 'warning'
            });
            riskLevel = riskLevel === 'normal' ? 'warning' : riskLevel;
        }
    }
    
    // 3. NHIỆT ĐỘ (Temperature)
    if (temperature > 0) {
        if (temperature >= 39) {
            alerts.push({
                type: 'TEMP_HIGH_FEVER',
                title: '🚨 Sốt cao',
                message: `Nhiệt độ: ${temperature}°C. Sốt cao, cần hạ sốt.`,
                severity: 'critical'
            });
            riskLevel = 'critical';
        } else if (temperature >= 37.5) {
            alerts.push({
                type: 'TEMP_FEVER',
                title: '⚠️ Sốt nhẹ',
                message: `Nhiệt độ: ${temperature}°C. Theo dõi thêm.`,
                severity: 'warning'
            });
            riskLevel = riskLevel === 'normal' ? 'warning' : riskLevel;
        } else if (temperature < 35) {
            alerts.push({
                type: 'TEMP_HYPOTHERMIA',
                title: '⚠️ Hạ thân nhiệt',
                message: `Nhiệt độ: ${temperature}°C. Nguy hiểm!`,
                severity: 'critical'
            });
            riskLevel = 'critical';
        }
    }
    
    // 4. SPO2 (Oxygen Saturation)
    if (spo2 > 0) {
        if (spo2 < 85) {
            alerts.push({
                type: 'SPO2_CRITICAL_LOW',
                title: '🚨 SpO2 cực thấp',
                message: `SpO2: ${spo2}% (bình thường: 95-100%). CẦN CẤP CỨU!`,
                severity: 'critical'
            });
            riskLevel = 'critical';
        } else if (spo2 < 90) {
            alerts.push({
                type: 'SPO2_LOW',
                title: '⚠️ SpO2 thấp',
                message: `SpO2: ${spo2}%. Cần hỗ trợ oxy.`,
                severity: 'danger'
            });
            riskLevel = riskLevel === 'normal' ? 'danger' : riskLevel;
        } else if (spo2 < 95) {
            alerts.push({
                type: 'SPO2_BORDERLINE',
                title: 'ℹ️ SpO2 hơi thấp',
                message: `SpO2: ${spo2}%. Theo dõi thêm.`,
                severity: 'warning'
            });
            riskLevel = riskLevel === 'normal' ? 'warning' : riskLevel;
        }
    }
    
    // 5. Recommendations
    const recommendations = [];
    if (riskLevel === 'critical') {
        recommendations.push('🚨 Liên hệ bác sĩ hoặc gọi cấp cứu 115 ngay!');
    } else if (riskLevel === 'danger') {
        recommendations.push('⚠️ Đặt lịch khám bác sĩ trong 24 giờ.');
    } else if (riskLevel === 'warning') {
        recommendations.push('ℹ️ Theo dõi thêm. Nếu triệu chứng kéo dài, liên hệ bác sĩ.');
    } else {
        recommendations.push('✅ Chỉ số bình thường. Tiếp tục duy trì sức khỏe!');
    }
    
    return {
        isDangerous: riskLevel === 'critical' || riskLevel === 'danger',
        alerts,
        riskLevel,
        recommendations
    };
};

module.exports = { analyzeHealthData };
```

### 10.2 Appointment Service

```javascript
// services/appointment_service.js
const { pool } = require('../config/db');
const moment = require('moment');

/**
 * Sinh time slots (30 phút mỗi slot)
 */
const generateSlots = (startStr, endStr) => {
    const slots = [];
    let current = moment(startStr, 'HH:mm:ss');
    let end = moment(endStr, 'HH:mm:ss');
    
    if (end.isSameOrBefore(current)) end.add(1, 'day');
    
    while (current.isBefore(end)) {
        slots.push(current.format('HH:mm'));
        current.add(30, 'minutes');
    }
    
    return slots;
};

/**
 * Lấy lịch trống 7 ngày tới
 */
const get7DayAvailability = async (doctorId) => {
    const today = moment().format('YYYY-MM-DD');
    const endDay = moment().add(8, 'days').format('YYYY-MM-DD');
    
    // Parallel queries
    const [scheduleRes, timeOffRes, bookedRes] = await Promise.all([
        pool.query('SELECT day_of_week, start_time, end_time FROM doctor_schedules WHERE user_id = $1 AND is_active = TRUE', [doctorId]),
        pool.query('SELECT start_date, end_date, reason FROM doctor_time_off WHERE doctor_id = $1 AND (start_date, end_date) OVERLAPS ($2::DATE, $3::DATE)', [doctorId, today, endDay]),
        pool.query(`SELECT to_char(appointment_date::timestamp, 'YYYY-MM-DD HH24:MI') as time FROM appointments WHERE doctor_id = $1 AND appointment_date >= $2 AND status != 'cancelled'`, [doctorId, today])
    ]);
    
    const schedules = scheduleRes.rows;
    const bookedSet = new Set(bookedRes.rows.map(r => r.time));
    const result = [];
    
    for (let i = 0; i < 7; i++) {
        const date = moment().add(i, 'days');
        const dateStr = date.format('YYYY-MM-DD');
        const dayOfWeek = date.day(); // 0=Sun, 6=Sat
        
        // Check nghỉ phép
        const dayOff = timeOffRes.rows.find(off => 
            date.isBetween(moment(off.start_date), moment(off.end_date), 'day', '[]')
        );
        
        if (dayOff) {
            result.push({
                date: dateStr,
                dayOfWeek,
                isWorking: false,
                note: dayOff.reason,
                slots: []
            });
            continue;
        }
        
        // Check lịch làm việc
        const schedule = schedules.find(s => 
            s.day_of_week === (dayOfWeek === 0 ? 7 : dayOfWeek)
        );
        
        if (!schedule) {
            result.push({ date: dateStr, dayOfWeek, isWorking: false, slots: [] });
        } else {
            const slots = generateSlots(schedule.start_time, schedule.end_time).map(time => ({
                time,
                isBooked: bookedSet.has(`${dateStr} ${time}`)
            }));
            
            result.push({ date: dateStr, isWorking: true, slots });
        }
    }
    
    return result;
};

/**
 * Đặt lịch hẹn
 */
const createAppointment = async ({ userId, doctorId, date, reason, typeId }) => {
    const client = await pool.connect();
    
    try {
        await client.query('BEGIN');
        
        // Check nghỉ phép
        const off = await client.query(
            'SELECT reason FROM doctor_time_off WHERE doctor_id = $1 AND $2::DATE BETWEEN start_date AND end_date',
            [doctorId, date]
        );
        
        if (off.rows.length) {
            throw new Error(`Bác sĩ nghỉ: ${off.rows[0].reason}`);
        }
        
        // Insert appointment
        const res = await client.query(`
            INSERT INTO appointments (patient_id, doctor_id, appointment_date, notes, type_id, status)
            VALUES ($1, $2, $3, $4, $5, 'pending')
            RETURNING id
        `, [userId, doctorId, date, reason, typeId || null]);
        
        await client.query('COMMIT');
        
        return res.rows[0].id;
    } catch (e) {
        await client.query('ROLLBACK');
        throw e;
    } finally {
        client.release();
    }
};

module.exports = { get7DayAvailability, createAppointment };
```

### 10.3 FCM Push Notification Service

```javascript
// services/fcm_service.js
const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin SDK
const serviceAccount = require(path.join(__dirname, '../config/firebase-admin-sdk.json'));

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

/**
 * Gửi push notification tới 1 thiết bị
 */
const sendNotification = async (fcmToken, { title, body, data }) => {
    if (!fcmToken) {
        console.warn('⚠️ [FCM] No FCM token provided');
        return;
    }
    
    const message = {
        notification: {
            title: title,
            body: body
        },
        data: data || {},
        token: fcmToken
    };
    
    try {
        const response = await admin.messaging().send(message);
        console.log(`✅ [FCM] Notification sent: ${response}`);
        return response;
    } catch (error) {
        console.error('❌ [FCM] Error sending notification:', error);
        throw error;
    }
};

/**
 * Gửi notification tới nhiều thiết bị
 */
const sendMulticast = async (fcmTokens, { title, body, data }) => {
    const message = {
        notification: {
            title: title,
            body: body
        },
        data: data || {},
        tokens: fcmTokens
    };
    
    try {
        const response = await admin.messaging().sendMulticast(message);
        console.log(`✅ [FCM] Sent ${response.successCount} / ${fcmTokens.length} notifications`);
        return response;
    } catch (error) {
        console.error('❌ [FCM] Error sending multicast:', error);
        throw error;
    }
};

module.exports = { sendNotification, sendMulticast };
```

---

## 11. BACKGROUND WORKERS

### 11.1 Scheduler (Cron Jobs)

```javascript
// workers/scheduler.js
const cron = require('node-cron');
const { pool } = require('../config/db');
const fcmService = require('../services/fcm_service');

/**
 * Gửi nhắc nhở uống thuốc
 */
const sendMedicationReminders = async () => {
    console.log('⏰ [Scheduler] Checking medication reminders...');
    
    const now = new Date();
    const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
    
    // Lấy các reminder cần gửi
    const query = `
        SELECT 
            mr.id,
            mr.user_id,
            mr.medication_name,
            mr.instruction,
            u.fcm_token
        FROM medication_reminders mr
        JOIN users u ON mr.user_id = u.id
        WHERE mr.is_active = TRUE
          AND $1 = ANY(mr.reminder_times)
          AND u.fcm_token IS NOT NULL
    `;
    
    const result = await pool.query(query, [currentTime]);
    
    for (const reminder of result.rows) {
        try {
            await fcmService.sendNotification(reminder.fcm_token, {
                title: '💊 Nhắc nhở uống thuốc',
                body: `Đã đến giờ uống ${reminder.medication_name}. ${reminder.instruction || ''}`,
                data: {
                    type: 'MEDICATION_REMINDER',
                    reminderId: reminder.id.toString()
                }
            });
            
            console.log(`✅ [Scheduler] Sent reminder to user ${reminder.user_id}`);
        } catch (error) {
            console.error(`❌ [Scheduler] Failed to send reminder:`, error);
        }
    }
};

/**
 * Nhắc lịch hẹn (trước 1 giờ)
 */
const sendAppointmentReminders = async () => {
    console.log('⏰ [Scheduler] Checking appointment reminders...');
    
    const oneHourLater = new Date(Date.now() + 60 * 60 * 1000);
    
    const query = `
        SELECT 
            a.id,
            a.patient_id,
            a.appointment_date,
            u.fcm_token,
            p.full_name as doctor_name
        FROM appointments a
        JOIN users u ON a.patient_id = u.id
        JOIN profiles p ON a.doctor_id = p.user_id
        WHERE a.status = 'pending'
          AND a.appointment_date BETWEEN NOW() AND $1
          AND u.fcm_token IS NOT NULL
    `;
    
    const result = await pool.query(query, [oneHourLater]);
    
    for (const appt of result.rows) {
        try {
            await fcmService.sendNotification(appt.fcm_token, {
                title: '📅 Nhắc lịch hẹn',
                body: `Bạn có lịch hẹn với ${appt.doctor_name} sau 1 giờ.`,
                data: {
                    type: 'APPOINTMENT_REMINDER',
                    appointmentId: appt.id.toString()
                }
            });
        } catch (error) {
            console.error(`❌ [Scheduler] Failed to send appointment reminder:`, error);
        }
    }
};

/**
 * Start scheduler
 */
const startScheduler = () => {
    // Medication reminders: Check mỗi phút
    cron.schedule('* * * * *', sendMedicationReminders);
    
    // Appointment reminders: Check mỗi 5 phút
    cron.schedule('*/5 * * * *', sendAppointmentReminders);
    
    console.log('✅ Scheduler started');
};

module.exports = { startScheduler };
```

---

## 12. CONFIGURATION

### 12.1 Database Connection Pool

```javascript
// config/db.js
const { Pool } = require('pg');

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'health_iot',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD,
    max: 20,                    // Max số connections
    idleTimeoutMillis: 30000,   // Close idle connection sau 30s
    connectionTimeoutMillis: 2000
});

const initializeDatabase = async () => {
    try {
        const client = await pool.connect();
        console.log('✅ PostgreSQL connected successfully');
        
        // Enable TimescaleDB extension
        await client.query('CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;');
        
        client.release();
    } catch (error) {
        console.error('❌ PostgreSQL connection error:', error);
        throw error;
    }
};

module.exports = { pool, initializeDatabase };
```

### 12.2 Application Entry Point

```javascript
// app.js
const http = require('http');
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const cron = require('node-cron');

const { initializeDatabase } = require('./config/db');
const { loadAllModels } = require('./config/aiModels');
const mqttService = require('./services/mqtt_service');
const mqttCleanupWorker = require('./workers/mqtt_cleanup_worker');
const { initSocket } = require('./socket_manager');
const { fetchAndSaveArticles } = require('./services/crawl_service');
const { startScheduler } = require('./workers/scheduler');
const mainRouter = require('./routes');

// Create Express app
const app = express();
const server = http.createServer(app);
const port = process.env.PORT || 5000;

// Middleware
const corsOptions = {
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    allowedHeaders: 'Content-Type,Authorization'
};

app.use(cors(corsOptions));
app.use(express.json());

// Initialize Socket.IO
initSocket(server);

// Crawl health articles every 3 hours
fetchAndSaveArticles();
cron.schedule('0 */3 * * *', () => {
    fetchAndSaveArticles();
});

// Start background scheduler
startScheduler();

// Routes
app.use('/api', mainRouter);
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.get('/', (req, res) => {
    res.send('Health AI Server (MVC-S Structure) đang chạy!');
});

// Start server
const startServer = async () => {
    try {
        console.log('🚀 Starting HealthAI Server...');
        
        // 1. Connect database
        console.log('📊 Connecting to PostgreSQL database...');
        await initializeDatabase();
        
        // 2. Connect MQTT
        console.log('🌐 Connecting to MQTT HiveMQ Cloud...');
        await mqttService.connect();
        console.log('✅ MQTT service connected');
        
        // 3. Start cleanup worker
        console.log('🧹 Starting MQTT cleanup worker...');
        mqttCleanupWorker.start();
        console.log('✅ Cleanup worker started');
        
        // 4. Load AI models
        console.log('🤖 Loading AI models...');
        await loadAllModels();
        console.log('✅ AI models loaded successfully');
        
        // 5. Listen
        server.listen(port, '0.0.0.0', () => {
            console.log('\n╔══════════════════════════════════════════╗');
            console.log('║   🏥 HEALTHAI SERVER READY              ║');
            console.log('╚══════════════════════════════════════════╝');
            console.log(`🌐 HTTP Server: http://localhost:${port}`);
            console.log(`📡 MQTT Status: ${mqttService.isConnected ? '✅ Connected' : '❌ Disconnected'}`);
            console.log(`🧹 Cleanup Worker: ✅ Running`);
            console.log('\nPress CTRL+C to stop server\n');
        });
    } catch (error) {
        console.error("❌ SERVER STARTUP ERROR:", error.message);
        console.error(error.stack);
        process.exit(1);
    }
};

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n⏹️ Shutting down gracefully...');
    mqttService.disconnect();
    mqttCleanupWorker.stop();
    process.exit(0);
});

startServer();
```

---

## 13. DEPLOYMENT

### 13.1 Production Environment Variables

```env
# Production .env
NODE_ENV=production
PORT=5000

# Database
DB_HOST=your_postgres_host
DB_PORT=5432
DB_NAME=health_iot_prod
DB_USER=postgres
DB_PASSWORD=strong_password_here

# JWT
JWT_SECRET=your_super_secret_jwt_key_change_in_production

# MQTT HiveMQ
MQTT_BROKER=7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud
MQTT_PORT=8883
MQTT_USER=DoAn1
MQTT_PASSWORD=Th123321

# Firebase
FCM_PROJECT_ID=your_project_id

# Email
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_app_password
```

### 13.2 Build & Run

```bash
# Install dependencies
npm install

# Run migrations
node run_migrations.js

# Seed data (optional)
node run_seed.js

# Start server (Development)
npm run dev

# Start server (Production)
npm start
```

### 13.3 PM2 Deployment

```bash
# Install PM2
npm install -g pm2

# Start with PM2
pm2 start app.js --name healthai-server

# Auto restart on crash
pm2 startup
pm2 save

# Monitor
pm2 monit

# Logs
pm2 logs healthai-server
```

### 13.4 Docker Deployment

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 5000

CMD ["node", "app.js"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: timescale/timescaledb:latest-pg14
    environment:
      POSTGRES_DB: health_iot
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password123
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
  
  healthai-server:
    build: .
    ports:
      - "5000:5000"
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: health_iot
      DB_USER: postgres
      DB_PASSWORD: password123
    depends_on:
      - postgres
    volumes:
      - ./uploads:/app/uploads

volumes:
  pgdata:
```

---

**✅ HOÀN THÀNH TÀI LIỆU HEALTHAI SERVER!**

📄 **Tổng kết**:
- Part 1: Architecture, Database, API, Authentication, MQTT, Socket.IO
- Part 2: AI Models, Services, Workers, Configuration, Deployment
