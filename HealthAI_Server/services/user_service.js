const { pool } = require('../config/db');
const { uploadToCloudinary } = require('../config/cloudinary');
const bcrypt = require('bcrypt'); // Cần import để xử lý đổi mật khẩu

/**
 * Upload Avatar lên Cloudinary và cập nhật URL vào Database
 */
const uploadUserAvatar = async (userId, fileBuffer) => {
    try {
        const result = await uploadToCloudinary(fileBuffer, 'health_ai_avatars');
        const avatarUrl = result.secure_url;
        const query = 'UPDATE users SET avatar_url = $1 WHERE id = $2 RETURNING avatar_url';
        const dbResult = await pool.query(query, [avatarUrl, userId]);
        return dbResult.rows[0].avatar_url;
    } catch (error) {
        console.error("Lỗi Service Upload:", error);
        throw error;
    }
};

// 1. Lấy thông tin Profile
const getUserProfile = async (userId) => {
    const query = `
        SELECT 
            u.id, u.email, u.avatar_url, u.role,
            p.full_name, p.phone_number, p.gender, p.date_of_birth, p.address,
            h.height, h.weight, h.blood_type, h.medical_history, h.allergies,
            h.insurance_number, h.emergency_contact_name, h.emergency_contact_phone, h.occupation, h.lifestyle_info
        FROM users u
        LEFT JOIN profiles p ON u.id = p.user_id
        LEFT JOIN patient_health_info h ON u.id = h.patient_id
        WHERE u.id = $1
    `;
    const result = await pool.query(query, [userId]);
    return result.rows[0];
};

// 2. Cập nhật Profile (Đã sửa lỗi ngày sinh)
const updateUserProfile = async (userId, data) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // [FIX] Hỗ trợ cả snake_case và camelCase
        let full_name = data.full_name || data.fullName;
        let date_of_birth = data.date_of_birth || data.dateOfBirth;
        let phone_number = data.phone_number || data.phoneNumber;
        let gender = data.gender;
        let address = data.address;

        if (date_of_birth === "") {
            date_of_birth = null;
        }

        const queryProfile = `
            INSERT INTO profiles (user_id, full_name, date_of_birth, phone_number, gender, address, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6, NOW())
            ON CONFLICT (user_id) 
            DO UPDATE SET 
                full_name = COALESCE($2, profiles.full_name),
                date_of_birth = COALESCE($3, profiles.date_of_birth),
                phone_number = COALESCE($4, profiles.phone_number),
                gender = COALESCE($5, profiles.gender),
                address = COALESCE($6, profiles.address),
                updated_at = NOW()
        `;
        await client.query(queryProfile, [userId, full_name, date_of_birth, phone_number, gender, address]);

        // Các trường sức khỏe
        let height = data.height;
        let weight = data.weight;
        let medical_history = data.medical_history || data.chronicConditions;
        let allergies = data.allergies;
        let blood_type = data.blood_type || data.bloodType;
        let insurance_number = data.insurance_number || data.insuranceNumber;
        let occupation = data.occupation;
        let emergency_contact_name = data.emergency_contact_name || data.emergencyName;
        let emergency_contact_phone = data.emergency_contact_phone || data.emergencyPhone;

        // [QUAN TRỌNG] Thêm dòng này để định nghĩa biến trước khi dùng
        let lifestyle_info = data.lifestyle_info;

        const queryHealth = `
            INSERT INTO patient_health_info (
                patient_id, height, weight, medical_history, allergies, blood_type,
                insurance_number, emergency_contact_name, emergency_contact_phone, occupation, lifestyle_info, updated_at
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, NOW())
            ON CONFLICT (patient_id) 
            DO UPDATE SET 
                height = COALESCE($2, patient_health_info.height),
                weight = COALESCE($3, patient_health_info.weight),
                medical_history = COALESCE($4, patient_health_info.medical_history),
                allergies = COALESCE($5, patient_health_info.allergies),
                blood_type = COALESCE($6, patient_health_info.blood_type),
                insurance_number = COALESCE($7, patient_health_info.insurance_number),
                emergency_contact_name = COALESCE($8, patient_health_info.emergency_contact_name),
                emergency_contact_phone = COALESCE($9, patient_health_info.emergency_contact_phone),
                occupation = COALESCE($10, patient_health_info.occupation),
                lifestyle_info = COALESCE($11, patient_health_info.lifestyle_info),
                updated_at = NOW()
        `;

        // Bây giờ biến lifestyle_info đã tồn tại để truyền vào đây
        await client.query(queryHealth, [
            userId, height, weight, medical_history, allergies, blood_type,
            insurance_number, emergency_contact_name, emergency_contact_phone, occupation, lifestyle_info
        ]);

        await client.query('COMMIT');
        return await getUserProfile(userId);

    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
};

/**
 * Lấy danh sách đánh giá của người dùng
 */
const getUserReviews = async (userId) => {
    const query = `
        SELECT r.id, r.rating, r.comment, r.created_at,
            d.specialty, p.full_name as doctor_name, u.avatar_url as doctor_avatar
        FROM doctor_reviews r
        JOIN doctor_professional_info d ON r.doctor_id = d.doctor_id
        JOIN profiles p ON d.doctor_id = p.user_id
        JOIN users u ON d.doctor_id = u.id
        WHERE r.patient_id = $1
        ORDER BY r.created_at DESC
    `;
    const result = await pool.query(query, [userId]);
    return result.rows;
};

const updateUserFcmToken = async (userId, token) => {
    const query = 'UPDATE users SET fcm_token = $1 WHERE id = $2';
    await pool.query(query, [token, userId]);
    return true;
};

module.exports = {
    uploadUserAvatar,
    getUserProfile,
    updateUserProfile,
    getUserReviews,
    updateUserFcmToken
};