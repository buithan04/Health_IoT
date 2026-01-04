const { pool } = require('../config/db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { sendVerificationEmail, sendResetPasswordEmail } = require('../services/email_service');

// --- HÀM 1: ĐĂNG KÝ ---
const register = async (user) => {
    const { fullName, password, email } = user;
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        // Kiểm tra user tồn tại
        const checkEmailQuery = 'SELECT * FROM users WHERE email = $1';
        const emailCheckResult = await client.query(checkEmailQuery, [email]);
        const existingUser = emailCheckResult.rows[0];

        let userId;
        if (existingUser) {
            if (existingUser.is_verified) throw { statusCode: 409, message: 'Email đã tồn tại.' };

            // Update user cũ chưa verify
            const updateUser = await client.query(
                'UPDATE users SET password = $1, created_at = NOW() WHERE email = $2 RETURNING id',
                [hashedPassword, email]
            );
            userId = updateUser.rows[0].id;

            // Upsert profile
            await client.query(`
                INSERT INTO profiles (user_id, full_name) VALUES ($1, $2)
                ON CONFLICT (user_id) DO UPDATE SET full_name = $2
            `, [userId, fullName]);
        } else {
            // Insert mới
            const insertUser = await client.query(
                'INSERT INTO users (email, password) VALUES ($1, $2) RETURNING id',
                [email, hashedPassword]
            );
            userId = insertUser.rows[0].id;
            await client.query('INSERT INTO profiles (user_id, full_name) VALUES ($1, $2)', [userId, fullName]);
        }

        await client.query('COMMIT');

        // Gửi mail (Non-blocking)
        try {
            const token = jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '15m' });
            sendVerificationEmail(email, token).catch(console.error);
        } catch (e) { console.error(e); }

        return { message: "Đăng ký thành công. Vui lòng kiểm tra email.", userId };
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
};

// --- HÀM 2: ĐĂNG NHẬP ---
const login = async ({ email, password }) => {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    const user = result.rows[0];

    if (!user) throw { statusCode: 404, message: 'Người dùng không tồn tại' };
    if (!user.is_verified) throw { statusCode: 403, message: 'Tài khoản chưa xác thực' };

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) throw { statusCode: 401, message: 'Mật khẩu sai' };

    const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, process.env.JWT_SECRET, { expiresIn: '30d' });
    return { 
        token, 
        role: user.role,
        userId: user.id.toString(),
        userName: user.full_name || user.email
    };
};

// --- HÀM 3: XÁC THỰC EMAIL ---
const verifyUser = async (token) => {
    try {
        // Kiểm tra JWT token trước (verify expiry)
        let decoded;
        try {
            decoded = jwt.verify(token, process.env.JWT_SECRET);
        } catch (jwtError) {
            if (jwtError.name === 'TokenExpiredError') {
                throw { statusCode: 400, message: 'Link xác thực đã hết hạn. Vui lòng đăng ký lại.' };
            }
            throw { statusCode: 400, message: 'Token không hợp lệ' };
        }

        // Find user by userId from token
        const result = await pool.query(
            'SELECT id, email FROM users WHERE id = $1 AND is_verified = FALSE',
            [decoded.userId]
        );

        if (result.rows.length === 0) {
            throw { statusCode: 400, message: 'Token không hợp lệ hoặc tài khoản đã được xác thực' };
        }

        const user = result.rows[0];

        // Update user as verified (không cần clear verification_token vì không dùng nữa)
        await pool.query(
            'UPDATE users SET is_verified = TRUE WHERE id = $1',
            [user.id]
        );

        return { message: 'Xác thực thành công', email: user.email };
    } catch (error) {
        if (error.statusCode) throw error;
        throw { statusCode: 400, message: 'Token không hợp lệ hoặc hết hạn' };
    }
};

// --- HÀM 4: QUÊN MẬT KHẨU ---
const forgotPassword = async (email) => {
    const user = (await pool.query('SELECT * FROM users WHERE email = $1', [email])).rows[0];
    if (!user) throw { statusCode: 404, message: 'Email không tồn tại' };

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiry = new Date(Date.now() + 15 * 60000); // 15 phút

    await pool.query('UPDATE users SET reset_password_token = $1, reset_password_expires = $2 WHERE email = $3', [otp, expiry, email]);

    sendResetPasswordEmail(email, otp).catch(console.error);
    return { message: "OTP đã được gửi" };
};

// --- HÀM 5: VERIFY OTP ---
const verifyResetToken = async (email, otp) => {
    const user = (await pool.query('SELECT * FROM users WHERE email = $1', [email])).rows[0];
    if (!user) throw { statusCode: 404, message: 'Email sai' };
    if (user.reset_password_token !== otp) throw { statusCode: 400, message: 'OTP sai' };
    if (new Date() > new Date(user.reset_password_expires)) throw { statusCode: 400, message: 'OTP hết hạn' };
    return { message: "Hợp lệ", isValid: true };
};

// --- HÀM 6: RESET PASSWORD ---
const resetPassword = async (email, newPassword, otp) => {
    // Tận dụng hàm verify để check lại
    await verifyResetToken(email, otp);

    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(newPassword, salt);

    await pool.query(
        'UPDATE users SET password = $1, reset_password_token = NULL, reset_password_expires = NULL WHERE email = $2',
        [hash, email]
    );
    return { message: "Đổi mật khẩu thành công" };
};

/**
 * Đổi mật khẩu
 */
const changeUserPassword = async (userId, oldPassword, newPassword) => {
    // 1. Lấy mật khẩu hiện tại (SỬA LỖI: đổi password_hash -> password)
    const userRes = await pool.query('SELECT password FROM users WHERE id = $1', [userId]);

    if (userRes.rows.length === 0) throw new Error("Người dùng không tồn tại");

    // Lấy field 'password' từ kết quả query
    const currentHash = userRes.rows[0].password;

    // 2. So sánh mật khẩu cũ
    const isMatch = await bcrypt.compare(oldPassword, currentHash);
    if (!isMatch) {
        throw new Error("Mật khẩu cũ không chính xác");
    }

    // 3. Mã hóa mật khẩu mới
    const salt = await bcrypt.genSalt(10);
    const newHash = await bcrypt.hash(newPassword, salt);

    // 4. Cập nhật vào DB (SỬA LỖI: đổi password_hash -> password)
    await pool.query('UPDATE users SET password = $1 WHERE id = $2', [newHash, userId]);

    return true;
};
const logout = async (userId) => {
    // Xóa fcm_token để không bắn thông báo vào máy này nữa
    await pool.query('UPDATE users SET fcm_token = NULL WHERE id = $1', [userId]);
    return true;
};
module.exports = { register, login, verifyUser, forgotPassword, verifyResetToken, resetPassword, changeUserPassword, logout };