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
    // Giả sử bảng users có các cột: birth_year (hoặc age), gender ('Male'/'Female'), weight (kg), height (cm hoặc m)
    const query = `SELECT gender, birth_year, weight, height FROM users WHERE id = $1`;
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
        // 2.1. Tuổi
        const currentYear = new Date().getFullYear();
        const age = userProfile.birth_year ? (currentYear - userProfile.birth_year) : 30; // Mặc định 30 nếu thiếu

        // 2.2. Chiều cao (m) & Cân nặng (kg)
        const height_m = userProfile.height ? userProfile.height / 100 : 1.7; // Chuyển cm sang m
        const weight_kg = userProfile.weight || 65;

        // 2.3. BMI = Weight / Height^2
        const derived_bmi = weight_kg / (height_m * height_m);

        // 2.4. Gender Encoded (Notebook: Female=0, Male=1)
        const gender_encoded = (userProfile.gender === 'Male' || userProfile.gender === 1) ? 1 : 0;

        // 2.5. MAP (Mean Arterial Pressure) = (SBP + 2*DBP) / 3
        // Nếu thiết bị không gửi huyết áp, dùng giá trị trung bình mặc định (120/80 -> MAP ~93)
        const sbp = sys_bp || 120;
        const dbp = dia_bp || 80;
        const derived_map = (sbp + 2 * dbp) / 3;

        // --- BƯỚC 3: SẮP XẾP INPUT CHO AI ---
        // Thứ tự BẮT BUỘC KHỚP NOTEBOOK:
        // ['Oxygen Saturation', 'Body Temperature', 'Heart Rate', 'Derived_MAP', 'Age', 'Weight (kg)', 'Height (m)', 'Derived_BMI', 'Gender_encoded']
        const inputRaw = [
            spo2,           // Oxygen Saturation
            temperature,    // Body Temperature
            heart_rate,     // Heart Rate
            derived_map,    // Derived_MAP
            age,            // Age
            weight_kg,      // Weight
            height_m,       // Height
            derived_bmi,    // Derived_BMI
            gender_encoded  // Gender_encoded
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
            INSERT INTO health_records (user_id, packet_id, heart_rate, spo2, temperature, sys_bp, dia_bp, measured_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
            RETURNING id
        `;
        // Cần thêm cột sys_bp, dia_bp vào bảng health_records nếu chưa có
        const recordRes = await client.query(insertRecord, [userId, packet_id || null, heart_rate, spo2, temperature, sbp, dbp]);
        const recordId = recordRes.rows[0].id;

        const insertDiag = `
            INSERT INTO ai_diagnoses (user_id, health_record_id, model_type, diagnosis_result, confidence_score, severity_level, is_alert_sent)
            VALUES ($1, $2, 'VITAL_MODEL', $3, $4, $5, $6)
        `;
        const confidence = (Math.max(prob, 1 - prob) * 100).toFixed(2);
        await client.query(insertDiag, [userId, recordId, aiLabel, confidence, severity, severity !== 'NORMAL']);

        await client.query('COMMIT');

        return { model: "MLP", result: aiLabel, confidence, severity, recordId };

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

        // Tạo Tensor: Shape [1, 100, 1]
        const inputTensor = tf.tensor3d([inputProcessed], [1, REQUIRED_LENGTH, 1]);

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
            INSERT INTO ai_diagnoses (user_id, ecg_reading_id, model_type, diagnosis_result, confidence_score, severity_level, is_alert_sent)
            VALUES ($1, $2, 'ECG_MODEL', $3, $4, $5, $6)
        `;
        await client.query(insertDiag, [userId, ecgId, aiLabel, confidence, severity, severity !== 'NORMAL']);
        await client.query('COMMIT');

        return { model: "ECG", result: aiLabel, confidence, severity, ecgId };

    } catch (error) {
        await client.query('ROLLBACK');
        console.error("Lỗi xử lý ECG:", error);
        throw error;
    } finally {
        client.release();
    }
};

module.exports = { processVitals, processECG };