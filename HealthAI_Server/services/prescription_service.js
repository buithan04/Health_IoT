// services/prescription_service.js
const { pool } = require('../config/db');

// 1. Helper: Tìm hoặc tạo thuốc (Lấy từ doctor_service sang)
const _findOrCreateMedication = async (client, medName) => {
    // Thêm check an toàn
    if (!medName) throw new Error("Tên thuốc không được để trống");

    const name = medName.trim();
    // ... phần còn lại giữ nguyên
    const checkRes = await client.query('SELECT id FROM medications WHERE name ILIKE $1', [name]);
    if (checkRes.rows.length > 0) return checkRes.rows[0].id;

    // ... insert code
    const insertRes = await client.query(
        'INSERT INTO medications (name, unit, price) VALUES ($1, $2, $3) RETURNING id',
        [name, 'Viên', 0] // Mặc định đơn vị là Viên nếu tạo mới
    );
    return insertRes.rows[0].id;
};
// 2. Lấy danh sách đơn thuốc của tôi
const getMyPrescriptions = async (userId) => {
    // [FIX]: Join profiles thay vì doctors cũ
    const query = `
        SELECT 
            p.id, p.created_at, p.diagnosis, 
            prof.full_name as doctor_name
        FROM prescriptions p
        JOIN profiles prof ON p.doctor_id = prof.user_id -- Lấy tên bác sĩ từ profiles
        WHERE p.patient_id = $1
        ORDER BY p.created_at DESC
    `;
    const result = await pool.query(query, [userId]);
    return result.rows;
};

// 3. Lấy chi tiết đơn thuốc
const getPrescriptionDetail = async (prescriptionId) => {
    // A. Lấy thông tin chung
    const infoQuery = `
        SELECT 
            p.id, p.created_at, p.diagnosis, p.notes, 
            p.chief_complaint, p.clinical_findings,
            doc_prof.full_name as doctor_name,     -- Tên Bác sĩ
            pat_prof.full_name as patient_name     -- Tên Bệnh nhân
        FROM prescriptions p
        JOIN profiles doc_prof ON p.doctor_id = doc_prof.user_id
        JOIN profiles pat_prof ON p.patient_id = pat_prof.user_id
        WHERE p.id = $1
    `;

    // B. Lấy danh sách thuốc (Giữ nguyên)
    const itemsQuery = `
        SELECT 
            medication_name_snapshot AS name,
            quantity, 
            dosage_instruction AS instruction
        FROM prescription_items 
        WHERE prescription_id = $1
    `;

    const infoRes = await pool.query(infoQuery, [prescriptionId]);
    const itemsRes = await pool.query(itemsQuery, [prescriptionId]);

    if (infoRes.rows.length === 0) return null;

    return {
        ...infoRes.rows[0],
        medications: itemsRes.rows
    };
};

// 4. Tạo đơn thuốc (Logic Transaction an toàn)
const createPrescription = async (data) => {
    const {
        doctorId, patientId, diagnosis, notes,
        chiefComplaint, clinicalFindings, medications
    } = data;

    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // Insert Header
        const headerRes = await client.query(`
            INSERT INTO prescriptions (doctor_id, patient_id, diagnosis, notes, chief_complaint, clinical_findings, created_at)
            VALUES ($1, $2, $3, $4, $5, $6, NOW()) 
            RETURNING id
        `, [doctorId, patientId, diagnosis, notes, chiefComplaint, clinicalFindings]);

        const presId = headerRes.rows[0].id;

        // Insert Items
        if (medications && medications.length > 0) {
            for (const med of medications) {
                // Logic: Tìm ID thuốc hoặc tạo mới
                const medId = await _findOrCreateMedication(client, med.name);

                await client.query(`
                    INSERT INTO prescription_items (prescription_id, medication_id, medication_name_snapshot, quantity, dosage_instruction)
                    VALUES ($1, $2, $3, $4, $5)
                `, [presId, medId, med.name, med.quantity, med.instruction]);
            }
        }

        await client.query('COMMIT');
        return presId;
    } catch (e) {
        await client.query('ROLLBACK');
        throw e;
    } finally {
        client.release();
    }
};

// [MỚI] Tìm kiếm thuốc từ kho
const searchMedications = async (query) => {
    let sql = `SELECT id, name, unit, usage_instruction FROM medications WHERE is_active = TRUE`;
    let params = [];

    if (query) {
        sql += ` AND name ILIKE $1`;
        params.push(`%${query}%`);
    }

    sql += ` ORDER BY name ASC LIMIT 20`; // Giới hạn 20 kết quả để load nhanh

    const result = await pool.query(sql, params);
    return result.rows;
};

module.exports = { getMyPrescriptions, getPrescriptionDetail, createPrescription, searchMedications };