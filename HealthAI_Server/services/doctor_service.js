// services/doctor_service.js
const { pool } = require('../config/db');

// --- CÁC HÀM CƠ BẢN ---

// 1. getAllDoctors
// 1. getAllDoctors (SỬA: Dùng LEFT JOIN để không bị mất bác sĩ chưa có info)
const getAllDoctors = async (search) => {
    let sql = `
        SELECT 
            u.id as doctor_id,           -- ID gốc từ bảng Users
            u.avatar_url, 
            u.email,
            
            -- Thông tin từ Profiles (Có thể null)
            p.full_name, 
            p.phone_number, 
            p.address, 
            p.gender, 
            p.date_of_birth,

            -- Thông tin chuyên môn (Có thể null nếu chưa cập nhật)
            d.specialty,
            d.bio,
            d.hospital_name,
            d.years_of_experience,
            d.consultation_fee,
            d.rating_average,
            d.review_count,
            d.license_number,
            d.education,
            d.languages

        FROM users u
        LEFT JOIN profiles p ON u.id = p.user_id
        LEFT JOIN doctor_professional_info d ON u.id = d.doctor_id
        WHERE u.role = 'doctor'
    `;

    // Tìm kiếm (Lưu ý xử lý null khi tìm kiếm)
    if (search) {
        sql += ` AND (p.full_name ILIKE '%${search}%' OR d.specialty ILIKE '%${search}%')`;
    }

    const res = await pool.query(sql);
    return res.rows;
};

const getDoctorById = async (id) => {
    const res = await pool.query(`
        SELECT 
            u.id, u.avatar_url, u.email,
            p.full_name, p.phone_number, p.address, p.gender, p.date_of_birth,
            d.specialty, d.bio, d.hospital_name, d.years_of_experience,
            d.consultation_fee, d.rating_average, d.review_count,
            d.license_number, d.education, d.languages,
            d.clinic_address -- <--- [MỚI] Lấy thêm cột này
        FROM users u
        LEFT JOIN profiles p ON u.id = p.user_id 
        LEFT JOIN doctor_professional_info d ON u.id = d.doctor_id
        WHERE u.id = $1 AND u.role = 'doctor'
    `, [id]);

    if (!res.rows.length) return null;
    const data = res.rows[0];
    return {
        ...data,
        rating_average: Number(data.rating_average || 0),
        review_count: Number(data.review_count || 0),
        years_of_experience: Number(data.years_of_experience || 0)
    };
};

// --- DASHBOARD ---
const getDashboardStats = async (userId) => {
    const res = await pool.query(`
        SELECT 
            (SELECT COUNT(*) FROM appointments WHERE doctor_id = $1 AND status = 'pending') as pending_requests,
            (SELECT COUNT(*) FROM appointments WHERE doctor_id = $1 AND appointment_date::DATE = CURRENT_DATE AND status = 'confirmed') as today_appointments
    `, [userId]);
    return res.rows[0];
};

const getDoctorAppointments = async (userId, { status, date }) => {
    let sql = `
        SELECT 
            a.id, a.appointment_date, a.status, a.notes, a.patient_id,
            COALESCE(NULLIF(p.full_name, ''), NULLIF(u.email, ''), 'Bệnh nhân #' || u.id) as "patientName",
            u.avatar_url as "patientAvatar", 
            COALESCE(p.phone_number, '') as "patientPhone",
            COALESCE(t.name, 'Khám thường') as service_name,
            COALESCE(t.price, 0) as price,
            COALESCE(t.duration_minutes, 30) as duration
        FROM appointments a
        JOIN users u ON a.patient_id = u.id
        LEFT JOIN profiles p ON u.id = p.user_id
        LEFT JOIN appointment_types t ON a.type_id = t.id
        WHERE a.doctor_id = $1
    `;
    const params = [userId];

    if (status) { sql += ` AND a.status = $${params.length + 1}`; params.push(status); }
    if (date === 'today') sql += ` AND a.appointment_date::DATE = CURRENT_DATE`;
    else if (date) { sql += ` AND a.appointment_date::DATE = $${params.length + 1}`; params.push(date); }

    sql += ' ORDER BY a.appointment_date ASC';

    const res = await pool.query(sql, params);
    return res.rows.map(row => ({
        ...row,
        fullDateTimeStr: row.appointment_date,
        price: Number(row.price),
        duration: Number(row.duration)
    }));
};

// Chi tiết (View của Bác sĩ)
const getAppointmentDetail = async (docId, appId) => {
    const res = await pool.query(`
        SELECT 
            a.id, a.appointment_date as "fullDateTimeStr", a.status, a.notes, a.cancellation_reason, a.patient_id,
            p.full_name as "patientName", u.avatar_url as "patientAvatar", p.phone_number, p.gender, p.date_of_birth,
            COALESCE(t.name, 'Dịch vụ đã xóa') as service_name,
            COALESCE(t.price, 0) as price,
            COALESCE(t.duration_minutes, 0) as duration
        FROM appointments a
        JOIN users u ON a.patient_id = u.id
        LEFT JOIN profiles p ON u.id = p.user_id
        LEFT JOIN appointment_types t ON a.type_id = t.id
        WHERE a.doctor_id = $1 AND a.id = $2
    `, [docId, appId]);

    if (!res.rows.length) return null;
    return { ...res.rows[0], price: Number(res.rows[0].price) };
};

// Xử lý Duyệt/Hủy
const respondToAppointment = async (docId, appId, status, reason) => {
    const sql = status === 'cancelled'
        ? 'UPDATE appointments SET status = $1, cancellation_reason = $2 WHERE id = $3 AND doctor_id = $4'
        : 'UPDATE appointments SET status = $1 WHERE id = $2 AND doctor_id = $3';

    const params = status === 'cancelled' ? [status, reason, appId, docId] : [status, appId, docId];
    const res = await pool.query(sql, params);
    return res.rowCount > 0;
};

// --- LOGIC AVAILABILITY (GIỮ NGUYÊN) ---
const generateTimeSlots = (startStr, endStr) => {
    const slots = [];
    let [startH, startM] = startStr.split(':').map(Number);
    let [endH, endM] = endStr.split(':').map(Number);
    let current = new Date(); current.setHours(startH, startM, 0, 0);
    let end = new Date(); end.setHours(endH, endM, 0, 0);
    if (end <= current) end.setDate(end.getDate() + 1);
    while (current < end) {
        let timeString = current.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
        if (timeString === '0:00') timeString = '00:00';
        slots.push(timeString);
        current.setMinutes(current.getMinutes() + 30);
    }
    return slots;
};

const getDoctorAvailability = async (userId, dateStr) => {
    const date = new Date(dateStr);
    let dayOfWeek = date.getDay();
    if (dayOfWeek === 0) dayOfWeek = 7;

    const scheduleRes = await pool.query(`
        SELECT start_time, end_time FROM doctor_schedules 
        WHERE user_id = $1 AND day_of_week = $2 AND is_active = TRUE
    `, [userId, dayOfWeek]);

    if (scheduleRes.rows.length === 0) return { slots: [] };

    const { start_time, end_time } = scheduleRes.rows[0];
    let allSlots = generateTimeSlots(start_time, end_time);

    const bookedRes = await pool.query(`
        SELECT TO_CHAR(appointment_date, 'HH24:MI') as time 
        FROM appointments 
        WHERE doctor_id = $1 AND appointment_date::DATE = $2::DATE AND status IN ('pending', 'confirmed')
    `, [userId, dateStr]);
    const bookedSlots = bookedRes.rows.map(row => row.time);

    return { slots: allSlots.filter(slot => !bookedSlots.includes(slot)) };
};

const saveDoctorAvailability = async (userId, dateStr, slots) => {
    if (!slots || slots.length === 0) return false;
    slots.sort();
    const startTime = slots[0];
    let endTimeObj = new Date();
    let [lastH, lastM] = slots[slots.length - 1].split(':').map(Number);
    endTimeObj.setHours(lastH, lastM + 30, 0, 0);
    const endTime = endTimeObj.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });

    const date = new Date(dateStr);
    let dayOfWeek = date.getDay();
    if (dayOfWeek === 0) dayOfWeek = 7;

    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        const query = `
            INSERT INTO doctor_schedules (user_id, day_of_week, start_time, end_time, is_active)
            VALUES ($1, $2, $3, $4, TRUE)
            ON CONFLICT (user_id, day_of_week) 
            DO UPDATE SET start_time = $3, end_time = $4, is_active = TRUE
        `;
        await client.query(query, [userId, dayOfWeek, startTime, endTime]);
        await client.query('COMMIT');
        return true;
    } catch (e) {
        await client.query('ROLLBACK');
        return false;
    } finally {
        client.release();
    }
};

// --- REVIEW (ĐÃ SỬA LỖI UPDATE DOCTORS) ---
const createReview = async (userId, data) => {
    const { doctorId, appointmentId, rating, comment } = data;
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        const checkQuery = `SELECT id FROM appointments WHERE id = $1 AND patient_id = $2 AND status = 'completed' AND is_reviewed = FALSE`;
        const checkRes = await client.query(checkQuery, [appointmentId, userId]);
        if (checkRes.rows.length === 0) throw new Error("Không thể đánh giá");

        await client.query(`INSERT INTO doctor_reviews (doctor_id, patient_id, appointment_id, rating, comment) VALUES ($1, $2, $3, $4, $5)`, [doctorId, userId, appointmentId, rating, comment]);
        await client.query('UPDATE appointments SET is_reviewed = TRUE WHERE id = $1', [appointmentId]);

        // [SỬA LỖI]: Update vào bảng doctor_professional_info thay vì doctors
        await client.query(`
            UPDATE doctor_professional_info 
            SET rating_average = (SELECT AVG(rating) FROM doctor_reviews WHERE doctor_id = $1), 
                review_count = (SELECT COUNT(*) FROM doctor_reviews WHERE doctor_id = $1) 
            WHERE doctor_id = $1
        `, [doctorId]);

        await client.query('COMMIT');
        return { message: "Đánh giá thành công" };
    } catch (e) {
        await client.query('ROLLBACK');
        throw e;
    } finally {
        client.release();
    }
};

const getReviewsByDoctorId = async (doctorId) => {
    const query = `
        SELECT r.id, r.rating, r.comment, r.created_at, p.full_name as patient_name, u.avatar_url as patient_avatar
        FROM doctor_reviews r
        JOIN users u ON r.patient_id = u.id
        JOIN profiles p ON u.id = p.user_id
        WHERE r.doctor_id = $1 ORDER BY r.created_at DESC
    `;
    const result = await pool.query(query, [doctorId]);
    return result.rows.map(row => ({
        id: row.id, rating: row.rating, comment: row.comment, date: row.created_at,
        patientName: row.patient_name || 'Người dùng ẩn danh', patientAvatar: row.patient_avatar || ''
    }));
};

// --- PATIENT RECORD (ĐÃ SỬA LỖI JOIN DOCTORS) ---
// [SỬA] services/doctor_service.js

const getPatientRecord = async (patientId) => {
    // 1. Lấy thông tin Profile (Giữ nguyên logic cũ)
    const profileQuery = `
        SELECT u.id, u.email, u.avatar_url, p.full_name, p.gender, p.date_of_birth, p.phone_number, p.address,
            h.height, h.weight, h.blood_type, h.medical_history, h.allergies, h.insurance_number, h.occupation, h.emergency_contact_name, h.emergency_contact_phone
        FROM users u
        LEFT JOIN profiles p ON u.id = p.user_id 
        LEFT JOIN patient_health_info h ON u.id = h.patient_id
        WHERE u.id = $1
    `;
    if (!patientId || isNaN(patientId)) return null;
    const profileRes = await pool.query(profileQuery, [patientId]);
    if (profileRes.rows.length === 0) return null;
    let raw = profileRes.rows[0];

    // Xử lý tên hiển thị
    let finalName = raw.full_name;
    if (!finalName || finalName.trim() === '') {
        finalName = raw.email ? raw.email.split('@')[0] : `Bệnh nhân #${raw.id}`;
    }

    // Mapping dữ liệu an toàn
    const safeProfile = {
        id: raw.id, fullName: finalName, avatarUrl: raw.avatar_url || '',
        gender: raw.gender || 'Chưa cập nhật', address: raw.address || 'Chưa cập nhật',
        phone: raw.phone_number || '', occupation: raw.occupation || 'Chưa cập nhật',
        height: Number(raw.height) || 0, weight: Number(raw.weight) || 0,
        bloodType: raw.blood_type || '?', allergies: raw.allergies || 'Không',
        chronicConditions: raw.medical_history || 'Không',
        emergencyName: raw.emergency_contact_name || '', emergencyPhone: raw.emergency_contact_phone || '',
    };
    if (raw.date_of_birth) safeProfile.age = new Date().getFullYear() - new Date(raw.date_of_birth).getFullYear();

    // 2. [CẬP NHẬT QUAN TRỌNG] Lấy lịch sử khám có thêm Status và Tên Bác sĩ
    const historyQuery = `
        SELECT 
            a.id, 
            to_char(a.appointment_date::timestamp, 'DD/MM/YYYY') as appointment_date, 
            COALESCE(a.notes, 'Khám bệnh') as notes, 
            a.status, -- [MỚI] Để frontend lọc 'completed'
            
            -- Lấy tên bác sĩ khám
            COALESCE(doc_prof.full_name, 'Bác sĩ') as doctor_name, 
            
            -- Lấy nơi khám
            COALESCE(d.hospital_name, 'Phòng khám') as hospital_name
            
        FROM appointments a
        LEFT JOIN doctor_professional_info d ON a.doctor_id = d.doctor_id 
        LEFT JOIN profiles doc_prof ON a.doctor_id = doc_prof.user_id -- [MỚI] Join để lấy tên bác sĩ
        WHERE a.patient_id = $1 
        -- Có thể bỏ điều kiện status='completed' ở đây nếu muốn trả về hết để Frontend tự lọc
        -- Nhưng tốt nhất lọc luôn cho nhẹ
        AND a.status IN ('completed', 'done', 'finished')
        ORDER BY a.appointment_date DESC LIMIT 10
    `;

    let historyRows = [];
    try { historyRows = (await pool.query(historyQuery, [patientId])).rows; } catch (e) { console.error(e); }

    // 3. [CẬP NHẬT] Lấy danh sách đơn thuốc (Nếu cần hiển thị trong hồ sơ)
    // Code cũ của bạn đang để prescriptions: [], ta nên lấy dữ liệu thật
    const presQuery = `
        SELECT 
            p.id, 
            to_char(p.created_at, 'DD/MM/YYYY') as date,
            p.diagnosis,
            doc_prof.full_name as doctor_name
        FROM prescriptions p
        JOIN profiles doc_prof ON p.doctor_id = doc_prof.user_id
        WHERE p.patient_id = $1
        ORDER BY p.created_at DESC LIMIT 5
    `;
    let presRows = [];
    try { presRows = (await pool.query(presQuery, [patientId])).rows; } catch (e) { console.error(e); }

    return {
        ...safeProfile,
        // Map đúng key mà Model Flutter đang đợi
        history: historyRows.map(h => ({
            id: h.id,
            date: h.appointment_date,
            hospital: h.hospital_name,
            notes: h.notes,
            status: h.status,
            doctorName: h.doctor_name
        })),
        prescriptions: presRows.map(p => ({
            id: p.id,
            date: p.date,
            diagnosis: p.diagnosis,
            doctorName: p.doctor_name
        }))
    };
};

// --- CÁC HÀM CRUD DỊCH VỤ & TIME OFF (GIỮ NGUYÊN) ---
const addTimeOff = async (doctorId, startDate, endDate, reason) => {
    return (await pool.query('INSERT INTO doctor_time_off (doctor_id, start_date, end_date, reason) VALUES ($1, $2, $3, $4) RETURNING id', [doctorId, startDate, endDate, reason])).rows[0];
};

const getAppointmentTypes = async (docId) => (await pool.query('SELECT * FROM appointment_types WHERE (doctor_id IS NULL OR doctor_id = $1) AND is_active = TRUE', [docId])).rows;
const createService = async (docId, data) => (await pool.query('INSERT INTO appointment_types (doctor_id, name, price, duration_minutes, description) VALUES ($1, $2, $3, $4, $5) RETURNING *', [docId, data.name, data.price, data.duration, data.description])).rows[0];
const updateService = async (docId, id, data) => (await pool.query('UPDATE appointment_types SET name=$1, price=$2, duration_minutes=$3, description=$4 WHERE id=$5 AND doctor_id=$6 RETURNING *', [data.name, data.price, data.duration, data.description, id, docId])).rows[0];
const deleteService = async (docId, id) => (await pool.query('UPDATE appointment_types SET is_active=FALSE WHERE id=$1 AND doctor_id=$2', [id, docId])).rowCount > 0;

const getMyPatients = async (docId) => {
    const res = await pool.query(`
        SELECT DISTINCT ON (u.id) u.id as patient_id, 
            COALESCE(NULLIF(p.full_name, ''), NULLIF(u.email, ''), 'Bệnh nhân #' || u.id) as patient_name,
            u.avatar_url, COALESCE(p.phone_number, 'Chưa có SĐT') as phone_number, MAX(a.appointment_date) as last_visit
        FROM appointments a JOIN users u ON a.patient_id = u.id LEFT JOIN profiles p ON u.id = p.user_id 
        WHERE a.doctor_id = $1 GROUP BY u.id, p.full_name, u.email, u.avatar_url, p.phone_number
    `, [docId]);
    return res.rows;
};

const getPatientHealthStats = async (patientId) => {
    if (!patientId || patientId === 'null' || isNaN(Number(patientId))) return null;
    try {
        const result = await pool.query(`SELECT heart_rate, spo2, temperature, to_char(measured_at, 'DD/MM HH24:MI') as time_display, measured_at FROM health_records WHERE user_id = $1 ORDER BY measured_at DESC LIMIT 7`, [patientId]);
        return result.rows.reverse();
    } catch (error) { return []; }
};

// NOTES
const getNotes = async (doctorId) => (await pool.query('SELECT * FROM doctor_notes WHERE doctor_id = $1 ORDER BY created_at DESC', [doctorId])).rows;
const createNote = async (doctorId, content) => (await pool.query('INSERT INTO doctor_notes (doctor_id, content) VALUES ($1, $2) RETURNING *', [doctorId, content])).rows[0];
const updateNote = async (doctorId, noteId, content) => (await pool.query('UPDATE doctor_notes SET content = $1, updated_at = NOW() WHERE id = $2 AND doctor_id = $3 RETURNING *', [content, noteId, doctorId])).rows[0];
const deleteNote = async (doctorId, noteId) => (await pool.query('DELETE FROM doctor_notes WHERE id = $1 AND doctor_id = $2', [noteId, doctorId])).rowCount > 0;

// --- [SỬA LỖI] API THỐNG KÊ (ANALYTICS) ---
const getAnalytics = async (userId, period) => {
    let dateFilter = '', groupBy = '', selectLabel = '';
    if (period === 'week') {
        dateFilter = `appointment_date >= CURRENT_DATE - INTERVAL '6 days'`;
        selectLabel = `to_char(appointment_date, 'Dy')`;
    } else if (period === 'month') {
        dateFilter = `appointment_date >= CURRENT_DATE - INTERVAL '28 days'`;
        selectLabel = `'Tuần ' || to_char(appointment_date, 'W')`;
    } else {
        dateFilter = `appointment_date >= CURRENT_DATE - INTERVAL '11 months'`;
        selectLabel = `to_char(appointment_date, 'Mon')`;
    }

    // [FIX]: JOIN doctor_professional_info thay vì doctors
    const summaryQuery = `
        SELECT COUNT(DISTINCT patient_id) as total_patients, COUNT(*) as total_appointments, COALESCE(AVG(d.rating_average), 0) as avg_rating
        FROM appointments a JOIN doctor_professional_info d ON a.doctor_id = d.doctor_id
        WHERE d.doctor_id = $1 AND ${dateFilter}
    `;

    const lineChartQuery = `
        SELECT ${selectLabel} as label, COUNT(*) as value
        FROM appointments a JOIN doctor_professional_info d ON a.doctor_id = d.doctor_id
        WHERE d.doctor_id = $1 AND ${dateFilter} GROUP BY label
    `;

    const pieChartQuery = `
        SELECT t.name as label, COUNT(*) as value
        FROM appointments a JOIN doctor_professional_info d ON a.doctor_id = d.doctor_id
        LEFT JOIN appointment_types t ON a.type_id = t.id
        WHERE d.doctor_id = $1 AND ${dateFilter} GROUP BY t.name LIMIT 5
    `;

    const demoQuery = `
        SELECT 
            CASE 
                WHEN EXTRACT(YEAR FROM age(p.date_of_birth)) < 18 THEN 0
                WHEN EXTRACT(YEAR FROM age(p.date_of_birth)) BETWEEN 18 AND 35 THEN 1
                WHEN EXTRACT(YEAR FROM age(p.date_of_birth)) BETWEEN 36 AND 55 THEN 2
                ELSE 3
            END as age_group_index, COUNT(DISTINCT a.patient_id) as count
        FROM appointments a
        JOIN doctor_professional_info d ON a.doctor_id = d.doctor_id -- [FIX]
        JOIN users u ON a.patient_id = u.id JOIN profiles p ON u.id = p.user_id
        WHERE d.doctor_id = $1 AND ${dateFilter} GROUP BY age_group_index ORDER BY age_group_index
    `;

    const [summaryRes, lineRes, pieRes, demoRes] = await Promise.all([
        pool.query(summaryQuery, [userId]),
        pool.query(lineChartQuery, [userId]),
        pool.query(pieChartQuery, [userId]),
        pool.query(demoQuery, [userId])
    ]);

    const demographicsData = [0, 0, 0, 0];
    demoRes.rows.forEach(row => { if (row.age_group_index !== null) demographicsData[row.age_group_index] = parseInt(row.count); });

    return {
        totalPatients: summaryRes.rows[0].total_patients,
        appointments: summaryRes.rows[0].total_appointments,
        averageRating: parseFloat(summaryRes.rows[0].avg_rating).toFixed(1),
        chartData: lineRes.rows, pieData: pieRes.rows, demographicsData: demographicsData
    };
};

// [ĐÃ SỬA] Thêm clinic_address vào câu lệnh SQL
const updateProfessionalInfo = async (userId, data) => {
    const {
        specialty, experience, hospital, license,
        fee, education, languages, bio,
        clinicAddress // <--- Nhận thêm tham số này
    } = data;

    let years = 0;
    if (experience) {
        const match = experience.toString().match(/\d+/);
        if (match) years = parseInt(match[0]);
    }

    let feeNum = 0;
    if (fee) feeNum = Number(fee);

    // [FIX] Thêm clinic_address vào câu lệnh INSERT / UPDATE
    const query = `
        INSERT INTO doctor_professional_info (
            doctor_id, specialty, years_of_experience, hospital_name, 
            license_number, consultation_fee, education, languages, bio, clinic_address
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        ON CONFLICT (doctor_id) 
        DO UPDATE SET 
            specialty = $2, 
            years_of_experience = $3,
            hospital_name = $4,
            license_number = $5,
            consultation_fee = $6,
            education = $7,
            languages = $8,
            bio = $9,
            clinic_address = $10
        RETURNING *
    `;

    const result = await pool.query(query, [
        userId, specialty, years, hospital, license,
        feeNum, education, languages, bio, clinicAddress
    ]);
    return result.rows[0];
};

module.exports = {
    getAllDoctors, getDoctorById, createReview, getDashboardStats, getDoctorAppointments,
    getAppointmentDetail, respondToAppointment, getDoctorAvailability, saveDoctorAvailability,
    getReviewsByDoctorId, getPatientRecord, addTimeOff, getAppointmentTypes, createService,
    updateService, deleteService, getMyPatients, getPatientHealthStats, getNotes, createNote,
    updateNote, deleteNote, getAnalytics, updateProfessionalInfo
};