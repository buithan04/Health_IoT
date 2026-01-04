const { pool } = require('../config/db');
const moment = require('moment');

// --- Helper: Sinh giờ ---
const generateSlots = (startStr, endStr) => {
    const slots = [];
    let current = moment(startStr, 'HH:mm:ss');
    let end = moment(endStr, 'HH:mm:ss');
    if (end.isSameOrBefore(current)) end.add(1, 'day'); // Fix qua đêm

    while (current.isBefore(end)) {
        slots.push(current.format('HH:mm'));
        current.add(30, 'minutes');
    }
    return slots;
};

// 1. Lấy lịch 7 ngày (Patient View)
const get7DayAvailability = async (doctorId) => {
    const today = moment().format('YYYY-MM-DD');
    const endDay = moment().add(8, 'days').format('YYYY-MM-DD');

    // Lấy lịch chuẩn + Ngày nghỉ + Lịch đã đặt trong 1 query (nếu tối ưu sâu hơn), ở đây giữ logic cũ cho an toàn
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
        const dayOfWeek = date.day(); // 0-6

        // Check nghỉ phép
        const dayOff = timeOffRes.rows.find(off => date.isBetween(moment(off.start_date), moment(off.end_date), 'day', '[]'));

        if (dayOff) {
            result.push({ date: dateStr, dayOfWeek, isWorking: false, note: dayOff.reason, slots: [] });
            continue;
        }

        // Check lịch làm việc (DB: 7=CN nếu dùng quy ước ISO, hoặc khớp logic seed data)
        const schedule = schedules.find(s => s.day_of_week === (dayOfWeek === 0 ? 7 : dayOfWeek));

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

// 2. Đặt lịch (Hỗ trợ typeId)
const createAppointment = async ({ userId, doctorId, date, reason, typeId }) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // Check nghỉ phép
        const off = await client.query('SELECT reason FROM doctor_time_off WHERE doctor_id = $1 AND $2::DATE BETWEEN start_date AND end_date', [doctorId, date]);
        if (off.rows.length) throw new Error(`Bác sĩ nghỉ: ${off.rows[0].reason}`);

        // Insert
        const res = await client.query(`
            INSERT INTO appointments (patient_id, doctor_id, appointment_date, notes, type_id, status)
            VALUES ($1, $2, $3, $4, $5, 'pending') RETURNING id
        `, [userId, doctorId, date, reason, typeId || null]);

        await client.query('COMMIT');
        return res.rows[0].id;
    } catch (e) {
        await client.query('ROLLBACK');
        throw e;
    } finally { client.release(); }
};

// 3. Hủy lịch (Dành cho Patient)
const cancelAppointment = async (appointmentId, userId, reason) => {
    const query = `
        UPDATE appointments 
        SET status = 'cancelled', cancellation_reason = $1
        WHERE id = $2 AND patient_id = $3 -- Check patient_id để bảo mật
        RETURNING id
    `;
    const result = await pool.query(query, [reason || 'Người dùng hủy', appointmentId, userId]);
    return result.rowCount > 0;
};

// 4. [SỬA LỖI] Lấy danh sách lịch hẹn (Dùng LEFT JOIN)
const getMyAppointments = async (userId) => {
    const query = `
        SELECT 
            a.id, 
            to_char(a.appointment_date, 'YYYY-MM-DD HH24:MI:SS') as appointment_date, 
            a.status, a.notes, a.cancellation_reason,
            
            a.doctor_id as doctor_id,        -- Lấy trực tiếp từ bảng appointments
            COALESCE(p.full_name, u.email, 'Bác sĩ') as doctor_name, -- Fallback nếu chưa có profile
            u.avatar_url as doctor_avatar, 
            COALESCE(d.specialty, 'Đa khoa') as specialty,
            
            COALESCE(t.name, 'Khám thường') as service_name, 
            COALESCE(t.price, d.consultation_fee, 0) as price

        FROM appointments a
        JOIN users u ON a.doctor_id = u.id               -- User bác sĩ bắt buộc phải có
        LEFT JOIN profiles p ON a.doctor_id = p.user_id  -- [FIX] LEFT JOIN
        LEFT JOIN doctor_professional_info d ON a.doctor_id = d.doctor_id -- [FIX] LEFT JOIN
        LEFT JOIN appointment_types t ON a.type_id = t.id
        WHERE a.patient_id = $1
        ORDER BY a.appointment_date DESC
    `;
    const result = await pool.query(query, [userId]);
    return result.rows;
};

// 5. [SỬA LỖI] Chi tiết lịch hẹn (Dùng LEFT JOIN)
const getAppointmentDetail = async (id) => {
    const query = `
        SELECT 
            a.id, to_char(a.appointment_date, 'YYYY-MM-DD HH24:MI:SS') as "fullDateTimeStr",
            a.status, a.notes, a.cancellation_reason,
            
            a.doctor_id as "doctorId",
            COALESCE(p.full_name, u.email, 'Bác sĩ') as "doctorName",
            u.avatar_url as "doctorAvatar",
            COALESCE(d.specialty, 'Đa khoa') as specialty, 
            COALESCE(d.hospital_name, 'Phòng khám tư') as "hospitalName", 
            d.clinic_address,
            
            (r.id IS NOT NULL) as "isReviewed", 
            r.rating as "reviewRating", 
            r.comment as "reviewComment",
            
            COALESCE(t.name, d.specialty, 'Dịch vụ') as service_name,
            COALESCE(t.price, d.consultation_fee, 0) as price,
            COALESCE(t.duration_minutes, 30) as duration

        FROM appointments a
        JOIN users u ON a.doctor_id = u.id
        LEFT JOIN profiles p ON a.doctor_id = p.user_id               -- [FIX] LEFT JOIN
        LEFT JOIN doctor_professional_info d ON a.doctor_id = d.doctor_id -- [FIX] LEFT JOIN
        LEFT JOIN doctor_reviews r ON a.id = r.appointment_id
        LEFT JOIN appointment_types t ON a.type_id = t.id
        WHERE a.id = $1
    `;
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
};

// 6. Đổi lịch
const rescheduleAppointment = async (id, date, reason, typeId) => {
    const result = await pool.query(`
        UPDATE appointments 
        SET appointment_date = $1, notes = $2, type_id = $3, status = 'pending'
        WHERE id = $4 RETURNING id
    `, [date, reason, typeId, id]);
    return result.rowCount > 0;
};

module.exports = {
    get7DayAvailability,
    createAppointment,
    cancelAppointment, // Thay thế updateAppointmentStatus
    getMyAppointments,
    getAppointmentDetail,
    rescheduleAppointment
};