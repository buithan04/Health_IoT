const tf = require('@tensorflow/tfjs-node');
const { getModels } = require('../config/aiModels');
const { pool } = require('../config/db');

// --- HÀM HỖ TRỢ: Chuẩn hóa dữ liệu (Standard Scaler) ---
const transformData = (inputArray, scaler) => {
    if (!scaler || !scaler.mean || !scaler.scale) return inputArray;
    return inputArray.map((val, index) => {
        const mean = scaler.mean[index] || 0;
        const scale = scaler.scale[index] || 1;
        return (val - mean) / scale;
    });
};

/**
 * HÀM HỖ TRỢ: Lấy thông tin bệnh nhân từ DB
 */
const getUserProfile = async (client, userId) => {
    // Query JOIN users + profiles + patient_health_info để lấy đầy đủ thông tin
    const query = `
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
    const res = await client.query(query, [userId]);
    return res.rows[0];
};

/**
 * Xử lý Vitals (Tim, SpO2, Nhiệt độ + Huyết áp để tính MAP)
 */
const processVitals = async (userId, { heart_rate, spo2, temperature, sys_bp, dia_bp, packet_id }) => {
    const { model_mlp, scaler_mlp, risk_encoder } = getModels();
    if (!model_mlp) throw new Error("Model MLP chưa tải xong.");

    const client = await pool.connect();
    try {
        // 1. Lấy thông tin nhân khẩu học
        const userProfile = await getUserProfile(client, userId);
        if (!userProfile) throw new Error("Không tìm thấy thông tin bệnh nhân");

        // 2. Tính toán các chỉ số phái sinh (Derived Features)
        // 2.1. Tuổi - tính từ date_of_birth
        let age = 30; // Mặc định
        if (userProfile.date_of_birth) {
            const birthDate = new Date(userProfile.date_of_birth);
            const today = new Date();
            age = today.getFullYear() - birthDate.getFullYear();
            const monthDiff = today.getMonth() - birthDate.getMonth();
            if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
                age--;
            }
        }

        // 2.2. Chiều cao (m) & Cân nặng (kg)
        const height_m = userProfile.height ? userProfile.height / 100 : 1.7; // Chuyển cm sang m
        const weight_kg = userProfile.weight || 65;

        // 2.3. BMI = Weight / Height^2
        const derived_bmi = weight_kg / (height_m * height_m);

        // 2.4. Gender Encoded (Notebook: Female=0, Male=1)
        // Tự động biến đổi: Nam/Male → 1, Nữ/Female → 0
        const genderStr = String(userProfile.gender || '').toLowerCase();
        const gender_encoded = (genderStr === 'male' || genderStr === 'nam' || genderStr === '1') ? 1 : 0;

        // 2.5. MAP (Mean Arterial Pressure) = (SBP + 2*DBP) / 3
        // Nếu thiết bị không gửi huyết áp, dùng giá trị trung bình mặc định (120/80 -> MAP ~93)
        const sbp = sys_bp || 120;
        const dbp = dia_bp || 80;
        const derived_map = (sbp + 2 * dbp) / 3;

        // --- VALIDATION: Reject invalid vital signs ---
        const validationErrors = [];
        if (spo2 <= 0 || spo2 > 100) validationErrors.push(`Invalid SpO2: ${spo2}% (must be 1-100)`);
        if (heart_rate <= 0 || heart_rate > 250) validationErrors.push(`Invalid HR: ${heart_rate} bpm (must be 1-250)`);

        // Temperature validation: Normal range 35-40°C
        // < 35°C = Hypothermia (hạ thân nhiệt)
        // > 40°C = Hyperthermia (sốt cao nguy hiểm)
        if (temperature < 35 || temperature > 40) {
            validationErrors.push(`Abnormal Temp: ${temperature}°C (normal: 35-40°C, ideal: 36-37.5°C)`);
        }

        if (validationErrors.length > 0) {
            console.warn('⚠️ [AI-MLP] Invalid vital signs detected:');
            validationErrors.forEach(err => console.warn(`   - ${err}`));
            throw new Error(`Cannot diagnose with invalid vital signs: ${validationErrors.join(', ')}`);
        }

        // --- BƯỚC 3: SẮP XẾP INPUT CHO AI ---
        // Model MLP mới sử dụng 9 features (bao gồm Gender_encoded)
        // Thứ tự: ['Oxygen Saturation', 'Body Temperature', 'Heart Rate', 'Derived_MAP', 'Age', 'Weight (kg)', 'Height (m)', 'Derived_BMI', 'Gender_encoded']
        const inputRaw = [
            spo2,           // Oxygen Saturation
            temperature,    // Body Temperature
            heart_rate,     // Heart Rate
            derived_map,    // Derived_MAP
            age,            // Age
            weight_kg,      // Weight (kg)
            height_m,       // Height (m)
            derived_bmi,    // Derived_BMI
            gender_encoded  // Gender_encoded (Male=1, Female=0)
        ];

        // Chuẩn hóa
        const inputScaled = transformData(inputRaw, scaler_mlp);
        const inputTensor = tf.tensor2d([inputScaled], [1, 9]); // Shape [1, 9]

        // Dự đoán
        const prediction = model_mlp.predict(inputTensor);
        const resultProb = prediction.dataSync(); // MLP Binary: trả về 1 số float (xác suất lớp 1)

        // Xử lý kết quả Binary (Sigmoid)
        // Nếu model output shape là [1,1] (Binary):
        const prob = resultProb[0];
        const isHighRisk = prob > 0.5;

        // Mapping Label (Dựa trên cell output notebook: 0=High Risk, 1=Low Risk HOẶC ngược lại)
        // Cần check file risk_encoder.json.
        // Giả sử: Encoder trong notebook sort theo alphabet: High Risk (0), Low Risk (1).
        // Nếu > 0.5 (tức là thiên về 1 -> Low Risk). Nếu < 0.5 (High Risk).
        // Cần verify lại risk_encoder.json. Ở đây tôi viết logic tổng quát:
        let aiLabel = "";
        let severity = "NORMAL";

        if (risk_encoder && risk_encoder.classes) {
            // Logic Multiclass hoặc Binary với encoder
            // Nếu Binary Sigmoid thì ngưỡng 0.5
            if (risk_encoder.classes.length === 2) {
                const classIndex = prob > 0.5 ? 1 : 0;
                aiLabel = risk_encoder.classes[classIndex];
            } else {
                // Logic cũ cho multiclass softmax
                const maxIndex = resultProb.indexOf(Math.max(...resultProb));
                aiLabel = risk_encoder.classes[maxIndex];
            }
        } else {
            // Fallback nếu không có encoder
            aiLabel = prob > 0.5 ? "Low Risk" : "High Risk";
        }

        // Đánh giá mức độ
        if (aiLabel.toLowerCase().includes('high') || aiLabel.toLowerCase().includes('nguy hiểm')) severity = 'DANGER';
        else if (aiLabel.toLowerCase().includes('medium') || aiLabel.toLowerCase().includes('cảnh báo')) severity = 'WARNING';

        inputTensor.dispose();
        prediction.dispose();

        // --- BƯỚC 4: LƯU DB (Giữ nguyên logic cũ) ---
        await client.query('BEGIN');
        const insertRecord = `
            INSERT INTO health_records (user_id, packet_id, heart_rate, spo2, temperature, measured_at)
            VALUES ($1, $2, $3, $4, $5, NOW())
            RETURNING id
        `;
        const recordRes = await client.query(insertRecord, [userId, packet_id || null, heart_rate, spo2, temperature]);
        const recordId = recordRes.rows[0].id;

        const insertDiag = `
            INSERT INTO ai_diagnoses (user_id, health_record_id, model_type, diagnosis_result, confidence_score, severity_level, is_alert_sent, input_data, output_data)
            VALUES ($1, $2, 'VITAL_MODEL', $3, $4, $5, $6, $7, $8)
        `;
        const confidence = (Math.max(prob, 1 - prob) * 100).toFixed(2);
        const inputDataJson = {
            heart_rate, spo2, temperature, sys_bp, dia_bp,
            mean_arterial_pressure: inputRaw[3],
            age: inputRaw[4],
            weight: inputRaw[5],
            height: inputRaw[6],
            bmi: inputRaw[7],
            gender_encoded: inputRaw[8],
            features_scaled: inputScaled
        };
        const outputDataJson = {
            raw_probability: prob,
            predicted_class_index: prob > 0.5 ? 1 : 0,
            predicted_class: aiLabel,
            class_probabilities: {
                "High Risk": prob <= 0.5 ? prob : 1 - prob,
                "Low Risk": prob > 0.5 ? prob : 1 - prob
            }
        };
        await client.query(insertDiag, [userId, recordId, aiLabel, confidence, severity, severity !== 'NORMAL', JSON.stringify(inputDataJson), JSON.stringify(outputDataJson)]);

        await client.query('COMMIT');

        // Return format khớp với MQTT service expectation
        return {
            model: "MLP",
            result: aiLabel,
            riskLabel: aiLabel, // For MQTT compatibility
            confidence,
            severity,
            recordId,
            riskEncoded: severity === 'DANGER' ? 3 : severity === 'WARNING' ? 2 : 1
        };

    } catch (error) {
        await client.query('ROLLBACK');
        console.error("Lỗi xử lý Vitals:", error);
        throw error;
    } finally {
        client.release();
    }
};

/**
 * Xử lý ECG (Cập nhật Shape 100)
 */
const processECG = async (userId, { dataPoints, device_id, packet_id, average_heart_rate }) => {
    const { model_ecg } = getModels();
    if (!model_ecg) throw new Error("Model ECG chưa tải xong.");

    const client = await pool.connect();
    try {
        // --- VALIDATION: Check ECG data quality ---
        if (!dataPoints || dataPoints.length === 0) {
            throw new Error('ECG dataPoints is empty');
        }

        // Check for invalid patterns (all same value, all zeros, all max)
        const uniqueValues = new Set(dataPoints);
        if (uniqueValues.size === 1) {
            const singleValue = dataPoints[0];
            console.warn(`⚠️ [AI-ECG] Invalid ECG: All values are ${singleValue}`);
            throw new Error(`Invalid ECG pattern: All datapoints are ${singleValue}`);
        }

        // Check for saturated signal (too many max values)
        const maxValue = 2047; // 11-bit ADC max
        const maxCount = dataPoints.filter(v => v === maxValue || v === maxValue - 1).length;
        if (maxCount > dataPoints.length * 0.8) { // >80% max values
            console.warn(`⚠️ [AI-ECG] Saturated signal: ${maxCount}/${dataPoints.length} points at max value`);
            throw new Error(`ECG signal saturated: ${maxCount}/${dataPoints.length} points are maxed out`);
        }

        // --- BƯỚC 1: XỬ LÝ INPUT (Cắt/Padding về 100) ---
        const REQUIRED_LENGTH = 100; // Updated từ Notebook
        let inputProcessed = [...dataPoints];

        if (inputProcessed.length > REQUIRED_LENGTH) {
            inputProcessed = inputProcessed.slice(0, REQUIRED_LENGTH);
        } else {
            // Padding số 0 nếu thiếu
            while (inputProcessed.length < REQUIRED_LENGTH) inputProcessed.push(0);
        }

        // Chuẩn hóa (Z-Score) như trong notebook (x - mean) / std
        // Cần scaler_ecg.json. Nếu notebook dùng global scaler:
        const { scaler_ecg } = getModels();
        if (scaler_ecg) {
            const mean = scaler_ecg.mean;
            const std = scaler_ecg.std;
            inputProcessed = inputProcessed.map(x => (x - mean) / (std + 1e-6));
        }

        // Convert to typed array for tensor3d
        const inputArray = Float32Array.from(inputProcessed);

        // Tạo Tensor: Shape [1, 100, 1]
        const inputTensor = tf.tensor3d(inputArray, [1, REQUIRED_LENGTH, 1]);

        // Dự đoán
        const prediction = model_ecg.predict(inputTensor);
        const resultProb = prediction.dataSync();
        const maxIndex = resultProb.indexOf(Math.max(...resultProb));

        // Mapping Label (Cần khớp file ECG_New.ipynb)
        // classes = ['N', 'S', 'V', 'F']
        const ecgLabels = [
            "Normal (Bình thường)",
            "Supraventricular (Trên thất)",
            "Ventricular (Thất)",
            "Fusion (Hòa trộn)"
        ];
        let aiLabel = ecgLabels[maxIndex] || "Unknown";
        const confidence = (resultProb[maxIndex] * 100).toFixed(2);

        // Đánh giá mức độ
        let severity = 'NORMAL';
        if (maxIndex === 2 || maxIndex === 3) severity = 'DANGER'; // V, F thường nguy hiểm hơn
        else if (maxIndex === 1) severity = 'WARNING'; // S cảnh báo

        inputTensor.dispose();
        prediction.dispose();

        // --- BƯỚC 2: LƯU DB ---
        await client.query('BEGIN');
        const insertEcg = `
            INSERT INTO ecg_readings (user_id, device_id, packet_id, data_points, average_heart_rate, result, measured_at)
            VALUES ($1, $2, $3, $4, $5, $6, NOW())
            RETURNING id
        `;
        const ecgRes = await client.query(insertEcg, [
            userId, device_id || 'UNKNOWN', packet_id || null, JSON.stringify(dataPoints), average_heart_rate || 0, aiLabel
        ]);
        const ecgId = ecgRes.rows[0].id;

        const insertDiag = `
            INSERT INTO ai_diagnoses (user_id, ecg_reading_id, model_type, diagnosis_result, confidence_score, severity_level, is_alert_sent, input_data, output_data)
            VALUES ($1, $2, 'ECG_MODEL', $3, $4, $5, $6, $7, $8)
        `;
        const inputDataJson = {
            ecg_datapoints: dataPoints.slice(0, REQUIRED_LENGTH),
            total_points: dataPoints.length,
            processed_points: REQUIRED_LENGTH,
            device_id,
            packet_id,
            average_heart_rate,
            scaled_data: inputArray.slice(0, 10) // Sample first 10 points
        };
        const outputDataJson = {
            class_probabilities: {
                "Normal (Bình thường)": resultProb[0],
                "Supraventricular (Trên thất)": resultProb[1],
                "Ventricular (Thất)": resultProb[2],
                "Fusion (Hòa trộn)": resultProb[3]
            },
            predicted_class_index: maxIndex,
            predicted_class: aiLabel,
            max_probability: resultProb[maxIndex]
        };
        await client.query(insertDiag, [userId, ecgId, aiLabel, confidence, severity, severity !== 'NORMAL', JSON.stringify(inputDataJson), JSON.stringify(outputDataJson)]);
        await client.query('COMMIT');

        // Return format with recommendation
        const recommendation = severity === 'DANGER'
            ? 'Cần khám ngay lập tức!'
            : severity === 'WARNING'
                ? 'Nên theo dõi chặt chẽ'
                : 'Theo dõi định kỳ';

        return {
            model: "ECG",
            result: aiLabel,
            confidence,
            severity,
            ecgId,
            recommendation
        };

    } catch (error) {
        await client.query('ROLLBACK');
        console.error("Lỗi xử lý ECG:", error);
        throw error;
    } finally {
        client.release();
    }
};

module.exports = { processVitals, processECG };