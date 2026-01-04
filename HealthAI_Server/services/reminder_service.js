const { pool } = require('../config/db');

// Lấy danh sách
const getReminders = async (userId) => {
    const result = await pool.query(
        'SELECT * FROM medication_reminders WHERE user_id = $1 ORDER BY reminder_time ASC',
        [userId]
    );
    return result.rows;
};

// Thêm mới
const createReminder = async (userId, data) => {
    const { name, instruction, time } = data;
    const result = await pool.query(
        'INSERT INTO medication_reminders (user_id, medication_name, instruction, reminder_time) VALUES ($1, $2, $3, $4) RETURNING *',
        [userId, name, instruction, time]
    );
    return result.rows[0];
};

// Cập nhật (Sửa nội dung hoặc Bật/Tắt)
const updateReminder = async (id, userId, data) => {
    // Xây dựng câu query động (chỉ update trường nào được gửi lên)
    const fields = [];
    const values = [];
    let idx = 1;

    if (data.name) { fields.push(`medication_name = $${idx++}`); values.push(data.name); }
    if (data.instruction) { fields.push(`instruction = $${idx++}`); values.push(data.instruction); }
    if (data.time) { fields.push(`reminder_time = $${idx++}`); values.push(data.time); }
    if (data.isActive !== undefined) { fields.push(`is_active = $${idx++}`); values.push(data.isActive); }

    if (fields.length === 0) return null;

    values.push(id);
    values.push(userId);

    const query = `UPDATE medication_reminders SET ${fields.join(', ')} WHERE id = $${idx++} AND user_id = $${idx++} RETURNING *`;
    const result = await pool.query(query, values);
    return result.rows[0];
};

// Xóa
const deleteReminder = async (id, userId) => {
    const result = await pool.query('DELETE FROM medication_reminders WHERE id = $1 AND user_id = $2 RETURNING id', [id, userId]);
    return result.rowCount > 0;
};

module.exports = { getReminders, createReminder, updateReminder, deleteReminder };