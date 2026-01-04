// services/admin_service.js
const { pool } = require('../config/db');

/**
 * Lấy thống kê tổng quan cho dashboard
 */
const getDashboardStats = async () => {
    try {
        // Tổng số người dùng
        const totalUsersResult = await pool.query('SELECT COUNT(*) FROM users');
        const totalUsers = parseInt(totalUsersResult.rows[0].count);

        // Số bác sĩ hoạt động (đã xác thực)
        const activeDoctorsResult = await pool.query(
            "SELECT COUNT(*) FROM users WHERE role = 'doctor' AND is_verified = true"
        );
        const activeDoctors = parseInt(activeDoctorsResult.rows[0].count);

        // Lịch hẹn hôm nay
        const todayAppointmentsResult = await pool.query(
            "SELECT COUNT(*) FROM appointments WHERE DATE(appointment_date) = CURRENT_DATE"
        );
        const todayAppointments = parseInt(todayAppointmentsResult.rows[0].count);

        // Đơn thuốc tháng này
        const monthPrescriptionsResult = await pool.query(
            "SELECT COUNT(*) FROM prescriptions WHERE EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM CURRENT_DATE)"
        );
        const monthPrescriptions = parseInt(monthPrescriptionsResult.rows[0].count);

        // Lịch hẹn chờ duyệt
        const pendingAppointmentsResult = await pool.query(
            "SELECT COUNT(*) FROM appointments WHERE status = 'pending'"
        );
        const pendingAppointments = parseInt(pendingAppointmentsResult.rows[0].count);

        return {
            totalUsers,
            activeDoctors,
            todayAppointments,
            monthPrescriptions,
            pendingAppointments
        };
    } catch (error) {
        console.error('Error getting dashboard stats:', error);
        throw error;
    }
};

/**
 * Lấy danh sách hoạt động gần đây
 */
const getRecentActivities = async (limit = 20) => {
    try {
        const query = `
            SELECT 
                a.id,
                u.id as user_id,
                p.full_name as user_name,
                u.email as user_email,
                'appointment' as type,
                'Đặt lịch khám' as action,
                a.status,
                a.created_at as timestamp
            FROM appointments a
            JOIN users u ON a.patient_id = u.id
            JOIN profiles p ON u.id = p.user_id
            ORDER BY a.created_at DESC
            LIMIT $1
        `;

        const result = await pool.query(query, [limit]);
        return result.rows;
    } catch (error) {
        console.error('Error getting recent activities:', error);
        throw error;
    }
};

/**
 * Lấy danh sách tất cả người dùng
 */
const getAllUsers = async (filters = {}) => {
    try {
        let query = `
            SELECT 
                u.id,
                u.email,
                u.role,
                u.is_verified,
                u.created_at,
                u.avatar_url,
                p.full_name,
                p.phone_number,
                p.date_of_birth,
                p.gender,
                p.address
            FROM users u
            LEFT JOIN profiles p ON u.id = p.user_id
            WHERE 1=1
        `;

        const values = [];
        let paramCount = 1;

        // Apply filters
        if (filters.role) {
            query += ` AND u.role = $${paramCount}`;
            values.push(filters.role);
            paramCount++;
        }

        if (filters.isVerified !== undefined) {
            query += ` AND u.is_verified = $${paramCount}`;
            values.push(filters.isVerified);
            paramCount++;
        }

        if (filters.search) {
            query += ` AND (p.full_name ILIKE $${paramCount} OR u.email ILIKE $${paramCount})`;
            values.push(`%${filters.search}%`);
            paramCount++;
        }

        query += ' ORDER BY u.created_at DESC';

        const result = await pool.query(query, values);

        return result.rows.map(row => ({
            id: row.id,
            full_name: row.full_name,
            email: row.email,
            role: row.role,
            is_verified: row.is_verified,
            created_at: row.created_at,
            avatar_url: row.avatar_url,
            phone_number: row.phone_number,
            date_of_birth: row.date_of_birth,
            gender: row.gender,
            address: row.address
        }));
    } catch (error) {
        console.error('Error getting all users:', error);
        throw error;
    }
};

/**
 * Lấy danh sách bác sĩ
 */
const getAllDoctors = async () => {
    try {
        const query = `
            SELECT 
                u.id,
                u.email,
                u.avatar_url,
                u.created_at,
                u.is_verified,
                p.full_name,
                p.phone_number,
                p.date_of_birth,
                p.gender,
                p.address,
                d.specialty,
                d.hospital_name,
                d.years_of_experience,
                d.consultation_fee,
                d.bio,
                d.license_number,
                d.education,
                COALESCE(appt_count.total, 0) as total_appointments,
                COALESCE(patient_count.total, 0) as total_patients,
                COALESCE(review_avg.avg_rating, 0) as rating
            FROM users u
            JOIN profiles p ON u.id = p.user_id
            LEFT JOIN doctor_professional_info d ON u.id = d.doctor_id
            LEFT JOIN (
                SELECT doctor_id, COUNT(*) as total 
                FROM appointments 
                WHERE status IN ('scheduled', 'completed')
                GROUP BY doctor_id
            ) appt_count ON u.id = appt_count.doctor_id
            LEFT JOIN (
                SELECT doctor_id, COUNT(DISTINCT patient_id) as total 
                FROM appointments 
                GROUP BY doctor_id
            ) patient_count ON u.id = patient_count.doctor_id
            LEFT JOIN (
                SELECT doctor_id, AVG(rating) as avg_rating 
                FROM doctor_reviews 
                GROUP BY doctor_id
            ) review_avg ON u.id = review_avg.doctor_id
            WHERE u.role = 'doctor'
            ORDER BY u.created_at DESC
        `;

        const result = await pool.query(query);

        return result.rows.map(row => ({
            user_id: row.id,
            id: row.id,
            full_name: row.full_name,
            email: row.email,
            avatar_url: row.avatar_url,
            phone_number: row.phone_number,
            date_of_birth: row.date_of_birth,
            gender: row.gender,
            address: row.address,
            specialty_name: row.specialty || 'Chưa cập nhật',
            hospital_name: row.hospital_name,
            experience_years: row.years_of_experience || 0,
            consultation_fee: row.consultation_fee || 0,
            bio: row.bio || '',
            license_number: row.license_number,
            education: row.education,
            is_verified: row.is_verified,
            rating: parseFloat(row.rating) || 0,
            total_appointments: parseInt(row.total_appointments) || 0,
            total_patients: parseInt(row.total_patients) || 0,
            created_at: row.created_at
        }));
    } catch (error) {
        console.error('Error getting doctors:', error);
        throw error;
    }
};

/**
 * Tạo người dùng mới
 */
const createUser = async (userData) => {
    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        const {
            full_name,
            fullName,
            email,
            password,
            role,
            phone_number,
            phone,
            date_of_birth,
            dateOfBirth,
            gender,
            address,
            is_verified,
            isVerified
        } = userData;

        // Support both snake_case and camelCase field names
        const userFullName = full_name || fullName;
        const userPhone = phone_number || phone;
        const userDateOfBirth = date_of_birth || dateOfBirth;
        const userIsVerified = is_verified !== undefined ? is_verified : (isVerified || false);

        // Check if email exists
        const emailCheck = await client.query(
            'SELECT id FROM users WHERE email = $1',
            [email]
        );

        if (emailCheck.rows.length > 0) {
            throw new Error('Email đã tồn tại trong hệ thống');
        }

        // Hash password
        const bcrypt = require('bcrypt');
        const hashedPassword = await bcrypt.hash(password, 10);

        // [FIX] Always create user with is_verified = false and send verification email
        const jwt = require('jsonwebtoken');

        // Create user (always NOT verified when created by admin)
        const userResult = await client.query(
            `INSERT INTO users (email, password, role, is_verified, created_at) 
             VALUES ($1, $2, $3, FALSE, NOW()) 
             RETURNING id`,
            [email, hashedPassword, role || 'patient']
        );

        const userId = userResult.rows[0].id;

        // Create profile
        await client.query(
            `INSERT INTO profiles (user_id, full_name, phone_number, date_of_birth, gender, address) 
             VALUES ($1, $2, $3, $4, $5, $6)`,
            [userId, userFullName, userPhone, userDateOfBirth, gender, address]
        );

        await client.query('COMMIT');

        // [FIX] Always send verification email when admin creates user
        const emailService = require('./email_service');
        try {
            // Generate JWT token for verification (15 minutes expiry)
            const verificationToken = jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '15m' });
            await emailService.sendVerificationEmail(email, verificationToken);
            console.log(`📧 Email xác thực đã được gửi tới: ${email}`);
        } catch (emailError) {
            console.error('⚠️  Không thể gửi email xác thực:', emailError.message);
            // Don't fail the user creation if email fails
        }

        return {
            id: userId,
            full_name: userFullName,
            email,
            role: role || 'patient',
            is_verified: false,
            message: 'Tài khoản đã được tạo thành công. Email xác thực đã được gửi đến người dùng.'
        };
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error creating user:', error);
        throw error;
    } finally {
        client.release();
    }
};

/**
 * Cập nhật thông tin người dùng
 */
const updateUser = async (userId, userData) => {
    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        // Update users table
        const updateFields = [];
        const updateValues = [];
        let paramIndex = 1;

        if (userData.email !== undefined) {
            updateFields.push(`email = $${paramIndex++}`);
            updateValues.push(userData.email);
        }
        if (userData.role !== undefined) {
            updateFields.push(`role = $${paramIndex++}`);
            updateValues.push(userData.role);
        }
        // [FIX] Không cho phép admin thay đổi is_verified trực tiếp
        // User phải xác thực qua email
        // if (userData.is_verified !== undefined) {
        //     updateFields.push(`is_verified = $${paramIndex++}`);
        //     updateValues.push(userData.is_verified);
        // }

        if (updateFields.length > 0) {
            updateValues.push(userId);
            const updateUserQuery = `
                UPDATE users 
                SET ${updateFields.join(', ')}
                WHERE id = $${paramIndex}
            `;
            await client.query(updateUserQuery, updateValues);
        }

        // Update profiles table
        const profileFields = [];
        const profileValues = [];
        let profileParamIndex = 1;

        if (userData.full_name !== undefined) {
            profileFields.push(`full_name = $${profileParamIndex++}`);
            profileValues.push(userData.full_name);
        }
        if (userData.phone_number !== undefined) {
            profileFields.push(`phone_number = $${profileParamIndex++}`);
            profileValues.push(userData.phone_number);
        }
        if (userData.date_of_birth !== undefined) {
            profileFields.push(`date_of_birth = $${profileParamIndex++}`);
            profileValues.push(userData.date_of_birth);
        }
        if (userData.gender !== undefined) {
            profileFields.push(`gender = $${profileParamIndex++}`);
            profileValues.push(userData.gender);
        }
        if (userData.address !== undefined) {
            profileFields.push(`address = $${profileParamIndex++}`);
            profileValues.push(userData.address);
        }

        if (profileFields.length > 0) {
            profileValues.push(userId);
            const updateProfileQuery = `
                UPDATE profiles 
                SET ${profileFields.join(', ')}
                WHERE user_id = $${profileParamIndex}
            `;
            await client.query(updateProfileQuery, profileValues);
        }

        await client.query('COMMIT');
        return { message: 'Cập nhật thành công' };
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error updating user:', error);
        throw error;
    } finally {
        client.release();
    }
};

/**
 * Xóa người dùng
 */
const deleteUser = async (userId) => {
    try {
        // Check if user exists first
        const userResult = await pool.query(
            "SELECT role, email FROM users WHERE id = $1",
            [userId]
        );

        if (userResult.rows.length === 0) {
            throw { statusCode: 404, message: 'Người dùng không tồn tại' };
        }

        const user = userResult.rows[0];

        // Kiểm tra không cho xóa admin cuối cùng
        if (user.role === 'admin') {
            const adminCountResult = await pool.query(
                "SELECT COUNT(*) FROM users WHERE role = 'admin'"
            );
            const adminCount = parseInt(adminCountResult.rows[0].count);

            if (adminCount <= 1) {
                throw { statusCode: 400, message: 'Không thể xóa admin cuối cùng' };
            }
        }

        // Check for related data that would prevent deletion
        const relatedData = [];

        // Check appointments
        const appointmentsCheck = await pool.query(
            'SELECT COUNT(*) FROM appointments WHERE patient_id = $1 OR doctor_id = $1',
            [userId]
        );
        if (parseInt(appointmentsCheck.rows[0].count) > 0) {
            relatedData.push(`${appointmentsCheck.rows[0].count} lịch hẹn`);
        }

        // Check prescriptions (if user is a doctor)
        if (user.role === 'doctor') {
            const prescriptionsCheck = await pool.query(
                'SELECT COUNT(*) FROM prescriptions WHERE doctor_id = $1',
                [userId]
            );
            if (parseInt(prescriptionsCheck.rows[0].count) > 0) {
                relatedData.push(`${prescriptionsCheck.rows[0].count} đơn thuốc`);
            }
        }

        // Check health records
        const healthRecordsCheck = await pool.query(
            'SELECT COUNT(*) FROM health_records WHERE user_id = $1',
            [userId]
        );
        if (parseInt(healthRecordsCheck.rows[0].count) > 0) {
            relatedData.push(`${healthRecordsCheck.rows[0].count} bản ghi sức khỏe`);
        }

        // If there's related data, return detailed error
        if (relatedData.length > 0) {
            throw {
                statusCode: 400,
                message: `Không thể xóa người dùng vì còn dữ liệu liên quan: ${relatedData.join(', ')}. Vui lòng xóa dữ liệu liên quan trước.`
            };
        }

        // Xóa user (cascade sẽ xóa profiles và các bảng liên quan)
        await pool.query('DELETE FROM users WHERE id = $1', [userId]);

        return { message: 'Xóa người dùng thành công' };
    } catch (error) {
        console.error('Error deleting user:', error);

        // Handle foreign key constraint errors
        if (error.code === '23503') {
            throw {
                statusCode: 400,
                message: 'Không thể xóa người dùng vì còn dữ liệu liên quan trong hệ thống. Vui lòng xóa dữ liệu liên quan trước.'
            };
        }

        throw error;
    }
};

/**
 * Lấy danh sách lịch hẹn
 */
const getAllAppointments = async (filters = {}) => {
    try {
        let query = `
            SELECT 
                a.*,
                p_patient.full_name as patient_name,
                p_doctor.full_name as doctor_name,
                u_patient.email as patient_email,
                u_doctor.email as doctor_email
            FROM appointments a
            JOIN users u_patient ON a.patient_id = u_patient.id
            JOIN users u_doctor ON a.doctor_id = u_doctor.id
            JOIN profiles p_patient ON u_patient.id = p_patient.user_id
            JOIN profiles p_doctor ON u_doctor.id = p_doctor.user_id
            WHERE 1=1
        `;

        const values = [];
        let paramCount = 1;

        if (filters.status) {
            query += ` AND a.status = $${paramCount}`;
            values.push(filters.status);
            paramCount++;
        }

        if (filters.date) {
            query += ` AND DATE(a.appointment_date) = $${paramCount}`;
            values.push(filters.date);
            paramCount++;
        }

        query += ' ORDER BY a.appointment_date DESC LIMIT 100';

        const result = await pool.query(query, values);
        return result.rows;
    } catch (error) {
        console.error('Error getting appointments:', error);
        throw error;
    }
};

/**
 * Lấy danh sách đơn thuốc
 */
const getAllPrescriptions = async () => {
    try {
        const query = `
            SELECT 
                pr.*,
                p_patient.full_name as patient_name,
                u_patient.email as patient_email,
                p_patient.phone_number as patient_phone,
                p_doctor.full_name as doctor_name,
                u_doctor.email as doctor_email,
                p_doctor.phone_number as doctor_phone,
                (
                    SELECT json_agg(
                        json_build_object(
                            'id', pi.id,
                            'medication_id', pi.medication_id,
                            'medication_name', pi.medication_name_snapshot,
                            'quantity', pi.quantity,
                            'dosage_instruction', pi.dosage_instruction
                        )
                    )
                    FROM prescription_items pi
                    WHERE pi.prescription_id = pr.id
                ) as items
            FROM prescriptions pr
            JOIN users u_patient ON pr.patient_id = u_patient.id
            JOIN users u_doctor ON pr.doctor_id = u_doctor.id
            JOIN profiles p_patient ON u_patient.id = p_patient.user_id
            JOIN profiles p_doctor ON u_doctor.id = p_doctor.user_id
            ORDER BY pr.created_at DESC
            LIMIT 100
        `;

        const result = await pool.query(query);

        // Add medication_count to each prescription
        const prescriptions = result.rows.map(row => ({
            ...row,
            medication_count: row.items ? row.items.length : 0
        }));

        return prescriptions;
    } catch (error) {
        console.error('Error getting prescriptions:', error);
        throw error;
    }
};

/**
 * ===== MEDICATION MANAGEMENT =====
 */

/**
 * Lấy danh sách tất cả thuốc
 */
const getAllMedications = async (filters = {}) => {
    try {
        let query = `
            SELECT 
                m.id,
                m.name,
                mc.name as category,
                m.registration_number,
                man.name as manufacturer,
                m.unit,
                m.packing_specification,
                m.usage_route,
                m.usage_instruction,
                m.price,
                m.stock,
                m.min_stock,
                m.is_active,
                m.created_at
            FROM medications m
            LEFT JOIN medication_categories mc ON m.category_id = mc.id
            LEFT JOIN manufacturers man ON m.manufacturer_id = man.id
            WHERE 1=1
        `;

        const params = [];
        let paramIndex = 1;

        if (filters.category) {
            query += ` AND mc.name ILIKE $${paramIndex}`;
            params.push(`%${filters.category}%`);
            paramIndex++;
        }

        if (filters.search) {
            query += ` AND (m.name ILIKE $${paramIndex} OR m.registration_number ILIKE $${paramIndex})`;
            params.push(`%${filters.search}%`);
            paramIndex++;
        }

        query += ' ORDER BY m.name ASC';

        const result = await pool.query(query, params);

        // Transform data to match frontend expectations
        return result.rows.map(row => ({
            id: row.id,
            name: row.name,
            category: row.category || 'Chưa phân loại',
            manufacturer: row.manufacturer || '',
            registration_number: row.registration_number || '',
            unit: row.unit || '',
            packing_specification: row.packing_specification || '',
            usage_route: row.usage_route || '',
            usage_instruction: row.usage_instruction || '',
            price: parseFloat(row.price) || 0,
            stock: parseInt(row.stock) || 0,
            min_stock: parseInt(row.min_stock) || 10,
            is_active: row.is_active,
            dosage: row.packing_specification || '',
            description: row.usage_instruction || '',
            created_at: row.created_at
        }));
    } catch (error) {
        console.error('Error getting medications:', error);
        throw error;
    }
};

/**
 * Lấy thông tin thuốc theo ID
 */
const getMedicationById = async (id) => {
    try {
        const result = await pool.query(
            `SELECT 
                m.id,
                m.name,
                mc.name as category,
                m.registration_number,
                man.name as manufacturer,
                m.unit,
                m.packing_specification,
                m.usage_route,
                m.usage_instruction,
                m.price,
                m.stock,
                m.min_stock,
                m.is_active,
                m.created_at
            FROM medications m
            LEFT JOIN medication_categories mc ON m.category_id = mc.id
            LEFT JOIN manufacturers man ON m.manufacturer_id = man.id
            WHERE m.id = $1`,
            [id]
        );

        if (result.rows.length === 0) {
            throw new Error('Medication not found');
        }

        const row = result.rows[0];
        return {
            id: row.id,
            name: row.name,
            category: row.category || 'Chưa phân loại',
            manufacturer: row.manufacturer || '',
            registration_number: row.registration_number || '',
            unit: row.unit || '',
            packing_specification: row.packing_specification || '',
            usage_route: row.usage_route || '',
            usage_instruction: row.usage_instruction || '',
            price: parseFloat(row.price) || 0,
            stock: parseInt(row.stock) || 0,
            min_stock: parseInt(row.min_stock) || 10,
            is_active: row.is_active,
            description: row.packing_specification || '',
            usage_instructions: row.usage_instruction || ''
        };
    } catch (error) {
        console.error('Error getting medication:', error);
        throw error;
    }
};

/**
 * Tạo thuốc mới
 */
const createMedication = async (medicationData) => {
    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        const {
            name,
            registration_number,
            category,
            manufacturer,
            unit,
            usage_route,
            packing_specification,
            price,
            usage_instruction,
            stock,
            min_stock,
            is_active
        } = medicationData;

        // Get or create category
        let categoryId = null;
        if (category) {
            let catResult = await client.query(
                'SELECT id FROM medication_categories WHERE name = $1',
                [category]
            );

            if (catResult.rows.length === 0) {
                catResult = await client.query(
                    'INSERT INTO medication_categories (name) VALUES ($1) RETURNING id',
                    [category]
                );
            }
            categoryId = catResult.rows[0].id;
        }

        // Get or create manufacturer
        let manufacturerId = null;
        if (manufacturer) {
            let manResult = await client.query(
                'SELECT id FROM manufacturers WHERE name = $1',
                [manufacturer]
            );

            if (manResult.rows.length === 0) {
                manResult = await client.query(
                    'INSERT INTO manufacturers (name) VALUES ($1) RETURNING id',
                    [manufacturer]
                );
            }
            manufacturerId = manResult.rows[0].id;
        }

        // Handle active_ingredient - store as simple text for now
        // In production, you might want to parse and create ingredient records

        // Create medication
        const result = await client.query(
            `INSERT INTO medications (
                name, registration_number, category_id, manufacturer_id, unit, 
                usage_route, packing_specification, usage_instruction, price, stock, min_stock, is_active
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
            RETURNING *`,
            [name, registration_number, categoryId, manufacturerId, unit, usage_route, packing_specification, usage_instruction, price, stock || 0, min_stock || 10, is_active]
        );

        // Store active ingredient as text in usage_instruction or packing_specification for now
        // TODO: Implement proper active_ingredients table relationship
        const medicationId = result.rows[0].id;

        // If active_ingredient provided, we need to handle it
        // For now, we'll add it to a note field or create a simple mapping

        await client.query('COMMIT');

        return {
            id: result.rows[0].id,
            name: result.rows[0].name,
            category,
            manufacturer,
            registration_number: result.rows[0].registration_number,
            unit: result.rows[0].unit,
            usage_route: result.rows[0].usage_route,
            packing_specification: result.rows[0].packing_specification,
            price: parseFloat(result.rows[0].price),
            usage_instruction: result.rows[0].usage_instruction,
            is_active: result.rows[0].is_active,
            stock: 0,
            min_stock: 10
        };
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error creating medication:', error);
        throw error;
    } finally {
        client.release();
    }
};

/**
 * Cập nhật thông tin thuốc
 */
const updateMedication = async (id, medicationData) => {
    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        const {
            name,
            registration_number,
            category,
            manufacturer,
            unit,
            usage_route,
            packing_specification,
            price,
            usage_instruction,
            stock,
            min_stock,
            is_active
        } = medicationData;

        // Get or create category
        let categoryId = null;
        if (category) {
            let catResult = await client.query(
                'SELECT id FROM medication_categories WHERE name = $1',
                [category]
            );

            if (catResult.rows.length === 0) {
                catResult = await client.query(
                    'INSERT INTO medication_categories (name) VALUES ($1) RETURNING id',
                    [category]
                );
            }
            categoryId = catResult.rows[0].id;
        }

        // Get or create manufacturer
        let manufacturerId = null;
        if (manufacturer) {
            let manResult = await client.query(
                'SELECT id FROM manufacturers WHERE name = $1',
                [manufacturer]
            );

            if (manResult.rows.length === 0) {
                manResult = await client.query(
                    'INSERT INTO manufacturers (name) VALUES ($1) RETURNING id',
                    [manufacturer]
                );
            }
            manufacturerId = manResult.rows[0].id;
        }

        // Update medication
        const updateFields = [];
        const values = [];
        let paramIndex = 1;

        if (name !== undefined) {
            updateFields.push(`name = $${paramIndex++}`);
            values.push(name);
        }
        if (registration_number !== undefined) {
            updateFields.push(`registration_number = $${paramIndex++}`);
            values.push(registration_number);
        }
        if (categoryId !== null && categoryId !== undefined) {
            updateFields.push(`category_id = $${paramIndex++}`);
            values.push(categoryId);
        }
        if (manufacturerId !== null && manufacturerId !== undefined) {
            updateFields.push(`manufacturer_id = $${paramIndex++}`);
            values.push(manufacturerId);
        }
        if (unit !== undefined) {
            updateFields.push(`unit = $${paramIndex++}`);
            values.push(unit);
        }
        if (usage_route !== undefined) {
            updateFields.push(`usage_route = $${paramIndex++}`);
            values.push(usage_route);
        }
        if (packing_specification !== undefined) {
            updateFields.push(`packing_specification = $${paramIndex++}`);
            values.push(packing_specification);
        }
        if (usage_instruction !== undefined) {
            updateFields.push(`usage_instruction = $${paramIndex++}`);
            values.push(usage_instruction);
        }
        if (price !== undefined) {
            updateFields.push(`price = $${paramIndex++}`);
            values.push(price);
        }
        if (stock !== undefined) {
            updateFields.push(`stock = $${paramIndex++}`);
            values.push(stock);
        }
        if (min_stock !== undefined) {
            updateFields.push(`min_stock = $${paramIndex++}`);
            values.push(min_stock);
        }
        if (is_active !== undefined) {
            updateFields.push(`is_active = $${paramIndex++}`);
            values.push(is_active);
        }

        values.push(id);

        const updateResult = await client.query(
            `UPDATE medications SET ${updateFields.join(', ')}
            WHERE id = $${paramIndex}
            RETURNING *`,
            values
        );

        if (updateResult.rows.length === 0) {
            throw new Error('Medication not found');
        }

        await client.query('COMMIT');

        // Get full medication details after update
        const result = await client.query(`
            SELECT 
                m.*,
                mc.name as category_name,
                mf.name as manufacturer_name
            FROM medications m
            LEFT JOIN medication_categories mc ON m.category_id = mc.id
            LEFT JOIN manufacturers mf ON m.manufacturer_id = mf.id
            WHERE m.id = $1
        `, [id]);

        if (result.rows.length === 0) {
            throw new Error('Medication not found after update');
        }

        const med = result.rows[0];
        return {
            id: med.id,
            name: med.name,
            registration_number: med.registration_number,
            category: med.category_name,
            manufacturer: med.manufacturer_name,
            unit: med.unit,
            usage_route: med.usage_route,
            packing_specification: med.packing_specification,
            price: parseFloat(med.price),
            usage_instruction: med.usage_instruction,
            stock: parseInt(med.stock) || 0,
            min_stock: parseInt(med.min_stock) || 10,
            is_active: med.is_active
        };
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error updating medication:', error);
        throw error;
    } finally {
        client.release();
    }
};

/**
 * Xóa thuốc
 */
const deleteMedication = async (id) => {
    try {
        // Check if medication is being used in prescription_items
        const usageCheck = await pool.query(
            'SELECT COUNT(*) as count FROM prescription_items WHERE medication_id = $1',
            [id]
        );

        if (parseInt(usageCheck.rows[0].count) > 0) {
            throw new Error(
                `Không thể xóa thuốc này vì đang được sử dụng trong ${usageCheck.rows[0].count} đơn thuốc. ` +
                'Vui lòng vô hiệu hóa thuốc thay vì xóa.'
            );
        }

        const result = await pool.query(
            'DELETE FROM medications WHERE id = $1 RETURNING id',
            [id]
        );

        if (result.rows.length === 0) {
            throw new Error('Medication not found');
        }

        return { success: true };
    } catch (error) {
        console.error('Error deleting medication:', error);
        throw error;
    }
};

/**
 * Import thuốc từ Excel
 */
const importMedications = async (medicationsData) => {
    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        let imported = 0;
        const errors = [];

        for (const med of medicationsData) {
            try {
                // Get or create category
                let categoryId = null;
                if (med.category) {
                    let catResult = await client.query(
                        'SELECT id FROM medication_categories WHERE name = $1',
                        [med.category]
                    );

                    if (catResult.rows.length === 0) {
                        catResult = await client.query(
                            'INSERT INTO medication_categories (name) VALUES ($1) RETURNING id',
                            [med.category]
                        );
                    }
                    categoryId = catResult.rows[0].id;
                }

                // Get or create manufacturer
                let manufacturerId = null;
                if (med.manufacturer) {
                    let manResult = await client.query(
                        'SELECT id FROM manufacturers WHERE name = $1',
                        [med.manufacturer]
                    );

                    if (manResult.rows.length === 0) {
                        manResult = await client.query(
                            'INSERT INTO manufacturers (name) VALUES ($1) RETURNING id',
                            [med.manufacturer]
                        );
                    }
                    manufacturerId = manResult.rows[0].id;
                }

                await client.query(
                    `INSERT INTO medications (
                        name, registration_number, category_id, manufacturer_id, unit,
                        usage_route, packing_specification, usage_instruction, price, is_active
                    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
                    [
                        med.name,
                        med.registration_number || '',
                        categoryId,
                        manufacturerId,
                        med.unit,
                        med.usage_route || 'Uống',
                        med.packing_specification || med.description || '',
                        med.usage_instruction || med.usage_instructions || '',
                        med.price,
                        med.is_active !== undefined ? med.is_active : true
                    ]
                );
                imported++;
            } catch (err) {
                errors.push({ name: med.name, error: err.message });
            }
        }

        await client.query('COMMIT');

        return {
            imported,
            total: medicationsData.length,
            errors
        };
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error importing medications:', error);
        throw error;
    } finally {
        client.release();
    }
};

/**
 * Lấy danh sách danh mục thuốc
 */
const getMedicationCategories = async () => {
    try {
        const result = await pool.query(
            'SELECT id, name FROM medication_categories ORDER BY name'
        );
        return result.rows;
    } catch (error) {
        console.error('Error getting medication categories:', error);
        throw error;
    }
};

/**
 * Lấy danh sách nhà sản xuất
 */
const getManufacturers = async () => {
    try {
        const result = await pool.query(
            'SELECT id, name, country FROM manufacturers ORDER BY name'
        );
        return result.rows;
    } catch (error) {
        console.error('Error getting manufacturers:', error);
        throw error;
    }
};

/**
 * Lấy danh sách hoạt chất
 */
const getActiveIngredients = async () => {
    try {
        const result = await pool.query(
            'SELECT id, name, description FROM active_ingredients ORDER BY name'
        );
        return result.rows;
    } catch (error) {
        console.error('Error getting active ingredients:', error);
        throw error;
    }
};

/**
 * Lấy thông tin bác sĩ theo ID
 */
const getDoctorById = async (doctorId) => {
    try {
        const query = `
            SELECT 
                u.id as user_id,
                u.email,
                u.created_at,
                u.is_verified,
                u.avatar_url,
                p.full_name,
                p.phone_number,
                p.date_of_birth,
                p.gender,
                p.address,
                d.specialty,
                d.hospital_name,
                d.years_of_experience,
                d.consultation_fee,
                d.bio,
                d.license_number,
                d.education,
                d.rating_average,
                d.review_count,
                COALESCE(appt_count.total, 0) as total_appointments,
                COALESCE(patient_count.total, 0) as total_patients
            FROM users u
            JOIN profiles p ON u.id = p.user_id
            LEFT JOIN doctor_professional_info d ON u.id = d.doctor_id
            LEFT JOIN (
                SELECT doctor_id, COUNT(*) as total 
                FROM appointments 
                WHERE status IN ('scheduled', 'completed')
                GROUP BY doctor_id
            ) appt_count ON u.id = appt_count.doctor_id
            LEFT JOIN (
                SELECT doctor_id, COUNT(DISTINCT patient_id) as total 
                FROM appointments 
                GROUP BY doctor_id
            ) patient_count ON u.id = patient_count.doctor_id
            WHERE u.role = 'doctor' AND u.id = $1
        `;

        const result = await pool.query(query, [doctorId]);
        if (result.rows.length === 0) return null;

        const doctor = result.rows[0];
        return {
            user_id: doctor.user_id,
            email: doctor.email,
            full_name: doctor.full_name,
            phone_number: doctor.phone_number,
            date_of_birth: doctor.date_of_birth,
            gender: doctor.gender,
            address: doctor.address,
            avatar_url: doctor.avatar_url,
            is_verified: doctor.is_verified,
            specialty_name: doctor.specialty || 'Chưa cập nhật',
            hospital_name: doctor.hospital_name,
            experience_years: doctor.years_of_experience || 0,
            consultation_fee: doctor.consultation_fee || 0,
            bio: doctor.bio || '',
            license_number: doctor.license_number,
            education: doctor.education,
            rating: parseFloat(doctor.rating_average) || 0,
            review_count: doctor.review_count || 0,
            total_appointments: doctor.total_appointments || 0,
            total_patients: doctor.total_patients || 0,
            created_at: doctor.created_at
        };
    } catch (error) {
        console.error('Error getting doctor by ID:', error);
        throw error;
    }
};

/**
 * Cập nhật thông tin bác sĩ
 */
const updateDoctor = async (doctorId, doctorData) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // ============= VALIDATION =============
        // 1. Không cho phép cập nhật email
        if (doctorData.email !== undefined) {
            throw {
                statusCode: 400,
                message: 'Không được phép thay đổi địa chỉ email. Email là định danh duy nhất của tài khoản.'
            };
        }

        // 2. Kiểm tra số âm cho các trường số
        if (doctorData.experience_years !== undefined && doctorData.experience_years !== null) {
            const years = parseInt(doctorData.experience_years);
            if (isNaN(years) || years < 0) {
                throw {
                    statusCode: 400,
                    message: 'Số năm kinh nghiệm không hợp lệ. Phải là số không âm.'
                };
            }
            if (years > 100) {
                throw {
                    statusCode: 400,
                    message: 'Số năm kinh nghiệm không hợp lệ. Không thể vượt quá 100 năm.'
                };
            }
        }

        if (doctorData.consultation_fee !== undefined && doctorData.consultation_fee !== null) {
            const fee = parseFloat(doctorData.consultation_fee);
            if (isNaN(fee) || fee < 0) {
                throw {
                    statusCode: 400,
                    message: 'Phí khám không hợp lệ. Phải là số không âm.'
                };
            }
            if (fee > 100000000) {
                throw {
                    statusCode: 400,
                    message: 'Phí khám không hợp lệ. Giá trị quá lớn.'
                };
            }
        }

        // 3. Validate phone number format (optional)
        if (doctorData.phone_number && doctorData.phone_number.trim() !== '') {
            const phoneRegex = /^[0-9+\-\s()]{9,15}$/;
            if (!phoneRegex.test(doctorData.phone_number.trim())) {
                throw {
                    statusCode: 400,
                    message: 'Số điện thoại không hợp lệ. Chỉ chứa số, dấu +, -, (), khoảng trắng và có độ dài 9-15 ký tự.'
                };
            }
        }

        // ============= UPDATE DATA =============
        // Convert empty strings to null for date fields
        const dateOfBirth = doctorData.date_of_birth && doctorData.date_of_birth.trim() !== ''
            ? doctorData.date_of_birth
            : null;

        // Update profile
        if (doctorData.full_name || doctorData.phone_number || dateOfBirth ||
            doctorData.gender || doctorData.address) {
            await client.query(
                `UPDATE profiles SET 
                    full_name = COALESCE($1, full_name),
                    phone_number = COALESCE($2, phone_number),
                    date_of_birth = COALESCE($3, date_of_birth),
                    gender = COALESCE($4, gender),
                    address = COALESCE($5, address),
                    updated_at = NOW()
                WHERE user_id = $6`,
                [
                    doctorData.full_name || null,
                    doctorData.phone_number || null,
                    dateOfBirth,
                    doctorData.gender || null,
                    doctorData.address || null,
                    doctorId
                ]
            );
        }

        // Update doctor_professional_info
        if (doctorData.specialty !== undefined || doctorData.bio !== undefined ||
            doctorData.experience_years !== undefined || doctorData.hospital_name !== undefined ||
            doctorData.consultation_fee !== undefined || doctorData.license_number !== undefined ||
            doctorData.education !== undefined) {

            // Check if record exists
            const checkResult = await client.query(
                'SELECT doctor_id FROM doctor_professional_info WHERE doctor_id = $1',
                [doctorId]
            );

            // Prepare update values
            const updateFields = [];
            const updateValues = [];
            let paramIndex = 1;

            if (doctorData.specialty !== undefined) {
                updateFields.push(`specialty = $${paramIndex++}`);
                updateValues.push(doctorData.specialty || null);
            }
            if (doctorData.bio !== undefined) {
                updateFields.push(`bio = $${paramIndex++}`);
                updateValues.push(doctorData.bio || null);
            }
            if (doctorData.experience_years !== undefined) {
                updateFields.push(`years_of_experience = $${paramIndex++}`);
                updateValues.push(doctorData.experience_years ? parseInt(doctorData.experience_years) : null);
            }
            if (doctorData.hospital_name !== undefined) {
                updateFields.push(`hospital_name = $${paramIndex++}`);
                updateValues.push(doctorData.hospital_name || null);
            }
            if (doctorData.consultation_fee !== undefined) {
                updateFields.push(`consultation_fee = $${paramIndex++}`);
                updateValues.push(doctorData.consultation_fee ? parseFloat(doctorData.consultation_fee) : null);
            }
            if (doctorData.license_number !== undefined) {
                updateFields.push(`license_number = $${paramIndex++}`);
                updateValues.push(doctorData.license_number || null);
            }
            if (doctorData.education !== undefined) {
                updateFields.push(`education = $${paramIndex++}`);
                updateValues.push(doctorData.education || null);
            }

            if (updateFields.length > 0) {
                if (checkResult.rows.length > 0) {
                    // Update existing record
                    updateValues.push(doctorId);
                    await client.query(
                        `UPDATE doctor_professional_info SET ${updateFields.join(', ')} WHERE doctor_id = $${paramIndex}`,
                        updateValues
                    );
                } else {
                    // Insert new record with all fields
                    await client.query(
                        `INSERT INTO doctor_professional_info (
                            doctor_id, specialty, bio, years_of_experience, 
                            hospital_name, consultation_fee, license_number, education
                        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
                        [
                            doctorId,
                            doctorData.specialty || null,
                            doctorData.bio || null,
                            doctorData.experience_years ? parseInt(doctorData.experience_years) : null,
                            doctorData.hospital_name || null,
                            doctorData.consultation_fee ? parseFloat(doctorData.consultation_fee) : null,
                            doctorData.license_number || null,
                            doctorData.education || null
                        ]
                    );
                }
            }
        }

        await client.query('COMMIT');
        return await getDoctorById(doctorId);
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error updating doctor:', error);
        throw error;
    } finally {
        client.release();
    }
};

/**
 * Xóa bác sĩ
 */
const deleteDoctor = async (doctorId) => {
    try {
        // Check if doctor exists first
        const doctorResult = await pool.query(
            "SELECT u.email, u.role, p.full_name FROM users u LEFT JOIN profiles p ON u.id = p.user_id WHERE u.id = $1 AND u.role = 'doctor'",
            [doctorId]
        );

        if (doctorResult.rows.length === 0) {
            throw { statusCode: 404, message: 'Bác sĩ không tồn tại' };
        }

        const doctorInfo = doctorResult.rows[0];

        // Check for related data that would prevent deletion
        const relatedData = [];
        const relatedDetails = [];

        // 1. Check appointments (quan trọng nhất)
        const appointmentsCheck = await pool.query(
            `SELECT 
                COUNT(*) as total,
                COUNT(CASE WHEN status = 'scheduled' THEN 1 END) as scheduled,
                COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed,
                COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending
             FROM appointments WHERE doctor_id = $1`,
            [doctorId]
        );
        const apptCounts = appointmentsCheck.rows[0];
        if (parseInt(apptCounts.total) > 0) {
            relatedData.push(`${apptCounts.total} lịch hẹn`);
            const details = [];
            if (parseInt(apptCounts.scheduled) > 0) details.push(`${apptCounts.scheduled} đã lên lịch`);
            if (parseInt(apptCounts.completed) > 0) details.push(`${apptCounts.completed} đã hoàn thành`);
            if (parseInt(apptCounts.pending) > 0) details.push(`${apptCounts.pending} chờ xác nhận`);
            relatedDetails.push(`Lịch hẹn: ${details.join(', ')}`);
        }

        // 2. Check prescriptions
        const prescriptionsCheck = await pool.query(
            'SELECT COUNT(*) FROM prescriptions WHERE doctor_id = $1',
            [doctorId]
        );
        if (parseInt(prescriptionsCheck.rows[0].count) > 0) {
            relatedData.push(`${prescriptionsCheck.rows[0].count} đơn thuốc`);
            relatedDetails.push(`Đơn thuốc: ${prescriptionsCheck.rows[0].count} đơn đã kê`);
        }

        // 3. Check doctor reviews
        const reviewsCheck = await pool.query(
            'SELECT COUNT(*) as total, AVG(rating) as avg_rating FROM doctor_reviews WHERE doctor_id = $1',
            [doctorId]
        );
        if (parseInt(reviewsCheck.rows[0].total) > 0) {
            relatedData.push(`${reviewsCheck.rows[0].total} đánh giá`);
            const avgRating = parseFloat(reviewsCheck.rows[0].avg_rating).toFixed(1);
            relatedDetails.push(`Đánh giá: ${reviewsCheck.rows[0].total} đánh giá (TB: ${avgRating}/5.0)`);
        }

        // 4. Check doctor schedules
        const schedulesCheck = await pool.query(
            'SELECT COUNT(*) FROM doctor_schedules WHERE user_id = $1',
            [doctorId]
        );
        if (parseInt(schedulesCheck.rows[0].count) > 0) {
            relatedData.push(`${schedulesCheck.rows[0].count} lịch làm việc`);
        }

        // 5. Check appointment types (services)
        const appointmentTypesCheck = await pool.query(
            'SELECT COUNT(*) FROM appointment_types WHERE doctor_id = $1',
            [doctorId]
        );
        if (parseInt(appointmentTypesCheck.rows[0].count) > 0) {
            relatedData.push(`${appointmentTypesCheck.rows[0].count} dịch vụ khám`);
        }

        // 6. Check doctor time off records
        const timeOffCheck = await pool.query(
            'SELECT COUNT(*) FROM doctor_time_off WHERE doctor_id = $1',
            [doctorId]
        );
        if (parseInt(timeOffCheck.rows[0].count) > 0) {
            relatedData.push(`${timeOffCheck.rows[0].count} ngày nghỉ phép`);
        }

        // 7. Check doctor notes
        const notesCheck = await pool.query(
            'SELECT COUNT(*) FROM doctor_notes WHERE doctor_id = $1',
            [doctorId]
        );
        if (parseInt(notesCheck.rows[0].count) > 0) {
            relatedData.push(`${notesCheck.rows[0].count} ghi chú`);
        }

        // If there's related data, return detailed error
        if (relatedData.length > 0) {
            const detailMessage = relatedDetails.length > 0
                ? `\n\nChi tiết:\n${relatedDetails.map(d => `  • ${d}`).join('\n')}`
                : '';

            throw {
                statusCode: 400,
                message: `Không thể xóa bác sĩ "${doctorInfo.full_name || doctorInfo.email}" vì còn dữ liệu liên quan: ${relatedData.join(', ')}.${detailMessage}\n\nVui lòng xóa hoặc chuyển giao dữ liệu liên quan trước.`
            };
        }

        const client = await pool.connect();
        try {
            await client.query('BEGIN');

            // Delete in correct order to respect foreign key constraints
            // 1. Delete doctor_professional_info
            await client.query('DELETE FROM doctor_professional_info WHERE doctor_id = $1', [doctorId]);

            // 2. Delete doctor_schedules (if any remain)
            await client.query('DELETE FROM doctor_schedules WHERE user_id = $1', [doctorId]);

            // 3. Delete appointment_types (if any remain)
            await client.query('DELETE FROM appointment_types WHERE doctor_id = $1', [doctorId]);

            // 4. Delete doctor_time_off (if any remain)
            await client.query('DELETE FROM doctor_time_off WHERE doctor_id = $1', [doctorId]);

            // 5. Delete doctor_notes (if any remain)
            await client.query('DELETE FROM doctor_notes WHERE doctor_id = $1', [doctorId]);

            // 6. Delete profile
            await client.query('DELETE FROM profiles WHERE user_id = $1', [doctorId]);

            // 7. Delete user (this will cascade to remaining related tables if configured)
            await client.query('DELETE FROM users WHERE id = $1', [doctorId]);

            await client.query('COMMIT');
            return {
                message: `Xóa bác sĩ "${doctorInfo.full_name || doctorInfo.email}" thành công`,
                deleted: {
                    email: doctorInfo.email,
                    full_name: doctorInfo.full_name
                }
            };
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    } catch (error) {
        console.error('Error deleting doctor:', error);

        // Handle foreign key constraint errors
        if (error.code === '23503') {
            throw {
                statusCode: 400,
                message: 'Không thể xóa bác sĩ vì còn dữ liệu liên quan trong hệ thống (ràng buộc khóa ngoại). Vui lòng xóa dữ liệu liên quan trước.'
            };
        }

        throw error;
    }
};

/**
 * Lấy danh sách bệnh nhân
 */
const getAllPatients = async () => {
    try {
        const query = `
            SELECT 
                u.id,
                u.email,
                u.created_at,
                u.avatar_url,
                p.full_name,
                p.phone_number,
                p.date_of_birth,
                p.gender,
                p.address,
                phi.blood_type,
                phi.medical_history,
                phi.height,
                phi.weight,
                phi.allergies,
                phi.insurance_number,
                COUNT(DISTINCT a.id) as appointment_count,
                MAX(a.appointment_date) as last_appointment
            FROM users u
            JOIN profiles p ON u.id = p.user_id
            LEFT JOIN patient_health_info phi ON u.id = phi.patient_id
            LEFT JOIN appointments a ON u.id = a.patient_id
            WHERE u.role = 'patient'
            GROUP BY u.id, u.email, u.created_at, u.avatar_url, p.full_name, p.phone_number, 
                     p.date_of_birth, p.gender, p.address, phi.blood_type, phi.medical_history,
                     phi.height, phi.weight, phi.allergies, phi.insurance_number
            ORDER BY u.created_at DESC
        `;

        const result = await pool.query(query);

        return result.rows.map(row => ({
            user_id: row.id,
            id: row.id,
            full_name: row.full_name || 'N/A',
            email: row.email,
            phone_number: row.phone_number || 'N/A',
            date_of_birth: row.date_of_birth,
            gender: row.gender || 'other',
            address: row.address,
            blood_type: row.blood_type,
            medical_history: row.medical_history,
            height: row.height,
            weight: row.weight,
            allergies: row.allergies,
            insurance_number: row.insurance_number,
            avatar_url: row.avatar_url,
            total_appointments: parseInt(row.appointment_count) || 0,
            total_prescriptions: 0, // Can be added later if needed
            last_appointment: row.last_appointment,
            status: 'active',
            created_at: row.created_at
        }));
    } catch (error) {
        console.error('Error getting patients:', error);
        throw error;
    }
};

/**
 * Lấy thông tin bệnh nhân theo ID
 */
const getPatientById = async (patientId) => {
    try {
        const query = `
            SELECT 
                u.id,
                u.email,
                u.created_at,
                p.full_name,
                p.phone_number,
                p.date_of_birth,
                p.gender,
                p.address,
                p.blood_type,
                p.avatar_url,
                COUNT(DISTINCT a.id) as appointment_count
            FROM users u
            JOIN profiles p ON u.id = p.user_id
            LEFT JOIN appointments a ON u.id = a.patient_id
            WHERE u.id = $1 AND u.role = 'patient'
            GROUP BY u.id, u.email, u.created_at, p.full_name, p.phone_number, 
                     p.date_of_birth, p.gender, p.address, p.blood_type, 
                     p.avatar_url
        `;

        const result = await pool.query(query, [patientId]);

        if (result.rows.length === 0) {
            return null;
        }

        const row = result.rows[0];
        return {
            id: row.id,
            fullName: row.full_name,
            email: row.email,
            phone: row.phone_number,
            dateOfBirth: row.date_of_birth,
            gender: row.gender,
            address: row.address,
            bloodType: row.blood_type,
            medicalHistory: null,
            avatar: row.avatar_url,
            appointmentCount: parseInt(row.appointment_count) || 0,
            status: 'active',
            createdAt: row.created_at
        };
    } catch (error) {
        console.error('Error getting patient by id:', error);
        throw error;
    }
};

/**
 * Tạo bệnh nhân mới
 */
const createPatient = async (patientData) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // Create user
        const userResult = await client.query(
            `INSERT INTO users (email, password, role, is_verified) 
             VALUES ($1, $2, 'patient', true) 
             RETURNING id`,
            [patientData.email, 'defaultPassword123'] // Default password, should be changed on first login
        );

        const userId = userResult.rows[0].id;

        // Create profile
        await client.query(
            `INSERT INTO profiles (user_id, full_name, phone_number, date_of_birth, gender, address, blood_type, medical_history) 
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
            [
                userId,
                patientData.fullName,
                patientData.phone,
                patientData.dateOfBirth || null,
                patientData.gender || 'other',
                patientData.address || null,
                patientData.bloodType || null,
                patientData.medicalHistory || null
            ]
        );

        await client.query('COMMIT');

        return {
            id: userId,
            ...patientData,
            status: 'active'
        };
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error creating patient:', error);
        if (error.code === '23505') { // Unique constraint violation
            throw new Error('Email đã tồn tại trong hệ thống');
        }
        throw error;
    } finally {
        client.release();
    }
};

/**
 * Cập nhật thông tin bệnh nhân
 */
const updatePatient = async (patientId, patientData) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // ============= VALIDATION =============
        // 1. Không cho phép cập nhật email
        if (patientData.email !== undefined) {
            throw {
                statusCode: 400,
                message: 'Không được phép thay đổi địa chỉ email. Email là định danh duy nhất của tài khoản.'
            };
        }

        // 2. Validate phone number format (optional)
        if (patientData.phone_number && patientData.phone_number.trim() !== '') {
            const phoneRegex = /^[0-9+\-\s()]{9,15}$/;
            if (!phoneRegex.test(patientData.phone_number.trim())) {
                throw {
                    statusCode: 400,
                    message: 'Số điện thoại không hợp lệ. Chỉ chứa số, dấu +, -, (), khoảng trắng và có độ dài 9-15 ký tự.'
                };
            }
        }

        // Convert empty strings to null for date fields
        const dateOfBirth = patientData.date_of_birth && patientData.date_of_birth.trim() !== ''
            ? patientData.date_of_birth
            : null;

        // ============= UPDATE DATA =============
        // Update profile with all fields including blood_type and medical_history
        await client.query(
            `UPDATE profiles 
             SET full_name = COALESCE($1, full_name),
                 phone_number = COALESCE($2, phone_number),
                 date_of_birth = COALESCE($3, date_of_birth),
                 gender = COALESCE($4, gender),
                 address = COALESCE($5, address),
                 blood_type = COALESCE($6, blood_type),
                 medical_history = COALESCE($7, medical_history),
                 updated_at = NOW()
             WHERE user_id = $8`,
            [
                patientData.full_name || null,
                patientData.phone_number || null,
                dateOfBirth,
                patientData.gender || null,
                patientData.address || null,
                patientData.blood_type || null,
                patientData.medical_history || null,
                patientId
            ]
        );

        await client.query('COMMIT');

        return await getPatientById(patientId);
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error updating patient:', error);
        throw error;
    } finally {
        client.release();
    }
};

/**
 * Xóa bệnh nhân với kiểm tra ràng buộc
 */
const deletePatient = async (patientId) => {
    try {
        // Check if patient exists first
        const patientResult = await pool.query(
            "SELECT u.email, u.role, p.full_name FROM users u LEFT JOIN profiles p ON u.id = p.user_id WHERE u.id = $1 AND u.role = 'patient'",
            [patientId]
        );

        if (patientResult.rows.length === 0) {
            throw { statusCode: 404, message: 'Bệnh nhân không tồn tại' };
        }

        const patientInfo = patientResult.rows[0];

        // Check for related data that would prevent deletion
        const relatedData = [];
        const relatedDetails = [];

        // 1. Check appointments (quan trọng nhất)
        const appointmentsCheck = await pool.query(
            `SELECT 
                COUNT(*) as total,
                COUNT(CASE WHEN status = 'scheduled' THEN 1 END) as scheduled,
                COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed,
                COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending,
                COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled
             FROM appointments WHERE patient_id = $1`,
            [patientId]
        );
        const apptCounts = appointmentsCheck.rows[0];
        if (parseInt(apptCounts.total) > 0) {
            relatedData.push(`${apptCounts.total} lịch hẹn`);
            const details = [];
            if (parseInt(apptCounts.scheduled) > 0) details.push(`${apptCounts.scheduled} đã lên lịch`);
            if (parseInt(apptCounts.completed) > 0) details.push(`${apptCounts.completed} đã hoàn thành`);
            if (parseInt(apptCounts.pending) > 0) details.push(`${apptCounts.pending} chờ xác nhận`);
            if (parseInt(apptCounts.cancelled) > 0) details.push(`${apptCounts.cancelled} đã hủy`);
            relatedDetails.push(`Lịch hẹn: ${details.join(', ')}`);
        }

        // 2. Check prescriptions
        const prescriptionsCheck = await pool.query(
            'SELECT COUNT(*) FROM prescriptions WHERE patient_id = $1',
            [patientId]
        );
        if (parseInt(prescriptionsCheck.rows[0].count) > 0) {
            relatedData.push(`${prescriptionsCheck.rows[0].count} đơn thuốc`);
            relatedDetails.push(`Đơn thuốc: ${prescriptionsCheck.rows[0].count} đơn đã được kê`);
        }

        // 3. Check doctor reviews (as patient)
        const reviewsCheck = await pool.query(
            'SELECT COUNT(*) FROM doctor_reviews WHERE patient_id = $1',
            [patientId]
        );
        if (parseInt(reviewsCheck.rows[0].count) > 0) {
            relatedData.push(`${reviewsCheck.rows[0].count} đánh giá`);
            relatedDetails.push(`Đánh giá: ${reviewsCheck.rows[0].count} đánh giá đã viết`);
        }

        // If there's related data, return detailed error
        if (relatedData.length > 0) {
            const detailMessage = relatedDetails.length > 0
                ? `\n\nChi tiết:\n${relatedDetails.map(d => `  • ${d}`).join('\n')}`
                : '';

            throw {
                statusCode: 409,
                message: `Không thể xóa bệnh nhân "${patientInfo.full_name || patientInfo.email}". Bệnh nhân vẫn còn ${relatedData.join(', ')}.${detailMessage}\n\nVui lòng xử lý các dữ liệu liên quan trước khi xóa bệnh nhân.`
            };
        }

        // If no related data, proceed with deletion in correct order
        const client = await pool.connect();
        try {
            await client.query('BEGIN');

            // Delete in order: patient_health_info -> profiles -> users
            await client.query('DELETE FROM patient_health_info WHERE patient_id = $1', [patientId]);
            await client.query('DELETE FROM profiles WHERE user_id = $1', [patientId]);
            await client.query('DELETE FROM users WHERE id = $1', [patientId]);

            await client.query('COMMIT');
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    } catch (error) {
        console.error('Error deleting patient:', error);
        throw error;
    }
};

module.exports = {
    getDashboardStats,
    getRecentActivities,
    getAllUsers,
    getAllDoctors,
    getDoctorById,
    updateDoctor,
    deleteDoctor,
    createUser,
    updateUser,
    deleteUser,
    // Patient management
    getAllPatients,
    getPatientById,
    createPatient,
    updatePatient,
    deletePatient,
    // Appointments & Prescriptions
    getAllAppointments,
    getAllPrescriptions,
    // Medication management
    getAllMedications,
    getMedicationById,
    createMedication,
    updateMedication,
    deleteMedication,
    importMedications,
    getMedicationCategories,
    getManufacturers,
    getActiveIngredients
};
