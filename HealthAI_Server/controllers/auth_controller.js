// controllers/auth_controller.js
const authService = require('../services/auth_service');
const { pool } = require('../config/db'); // Cần import để dùng trong createDoctor
const { sendDoctorWelcomeEmail } = require('../services/email_service');
const jwt = require('jsonwebtoken');

const register = async (req, res) => {
    try {
        const { email, password, fullName } = req.body;
        if (!email || !password || !fullName) return res.status(400).json({ error: "Thiếu thông tin" });

        const result = await authService.register({ fullName, password, email });
        res.status(201).json(result);
    } catch (error) {
        res.status(error.statusCode || 500).json({ error: error.message });
    }
};

const login = async (req, res) => {
    try {
        const { email, password } = req.body;
        if (!email || !password) return res.status(400).json({ error: "Thiếu thông tin" });

        const data = await authService.login({ email, password });

        res.json({
            message: "Đăng nhập thành công",
            token: data.token,
            role: data.role,
            userId: data.userId,
            userName: data.userName
        });
    } catch (error) {
        res.status(error.statusCode || 500).json({ error: error.message });
    }
};

const handleVerifyEmail = async (req, res) => {
    try {
        const token = req.query.token;
        if (!token) {
            return res.status(400).send(`
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Lỗi xác thực</title>
                    <style>
                        body { font-family: 'Segoe UI', sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); margin: 0; padding: 40px; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
                        .card { background: white; padding: 50px; border-radius: 16px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); text-align: center; max-width: 500px; }
                        .icon { font-size: 72px; margin-bottom: 20px; }
                        h1 { color: #e53e3e; margin: 20px 0; font-size: 28px; }
                        p { color: #4a5568; font-size: 16px; line-height: 1.6; }
                    </style>
                </head>
                <body>
                    <div class="card">
                        <div class="icon">❌</div>
                        <h1>Lỗi xác thực</h1>
                        <p>Không tìm thấy token xác thực. Vui lòng kiểm tra lại đường link trong email.</p>
                    </div>
                </body>
                </html>
            `);
        }

        const result = await authService.verifyUser(token);

        res.send(`
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Xác thực thành công</title>
                <style>
                    body { 
                        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                        margin: 0; 
                        padding: 40px; 
                        display: flex; 
                        justify-content: center; 
                        align-items: center; 
                        min-height: 100vh; 
                    }
                    .card { 
                        background: white; 
                        padding: 50px; 
                        border-radius: 16px; 
                        box-shadow: 0 20px 60px rgba(0,0,0,0.3); 
                        text-align: center; 
                        max-width: 500px;
                        animation: slideUp 0.5s ease-out;
                    }
                    @keyframes slideUp {
                        from { opacity: 0; transform: translateY(30px); }
                        to { opacity: 1; transform: translateY(0); }
                    }
                    .icon { font-size: 72px; margin-bottom: 20px; animation: checkmark 0.8s ease-in-out; }
                    @keyframes checkmark {
                        0% { transform: scale(0); }
                        50% { transform: scale(1.2); }
                        100% { transform: scale(1); }
                    }
                    h1 { color: #38a169; margin: 20px 0; font-size: 32px; font-weight: 600; }
                    p { color: #4a5568; font-size: 16px; line-height: 1.6; margin: 15px 0; }
                    .email { color: #667eea; font-weight: 600; }
                    .info { 
                        background: #f0f4f8; 
                        padding: 20px; 
                        border-radius: 8px; 
                        margin-top: 30px; 
                        border-left: 4px solid #667eea;
                    }
                    .info p { margin: 10px 0; font-size: 14px; text-align: left; }
                    .close-button {
                        margin-top: 30px;
                        padding: 12px 30px;
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        color: white;
                        border: none;
                        border-radius: 8px;
                        font-size: 16px;
                        cursor: pointer;
                        font-weight: 600;
                    }
                </style>
            </head>
            <body>
                <div class="card">
                    <div class="icon">✅</div>
                    <h1>Xác thực thành công!</h1>
                    <p>Tài khoản <span class="email">${result.email}</span> đã được kích hoạt.</p>
                    <div class="info">
                        <p><strong>🎉 Chào mừng đến với HealthAI!</strong></p>
                        <p>✓ Bạn có thể đăng nhập ngay bây giờ</p>
                        <p>✓ Bắt đầu quản lý sức khỏe của bạn</p>
                        <p>✓ Đặt lịch khám với bác sĩ chuyên nghiệp</p>
                    </div>
                    <button class="close-button" onclick="window.close()">Đóng cửa sổ</button>
                </div>
            </body>
            </html>
        `);
    } catch (error) {
        res.status(400).send(`
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Xác thực thất bại</title>
                <style>
                    body { font-family: 'Segoe UI', sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); margin: 0; padding: 40px; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
                    .card { background: white; padding: 50px; border-radius: 16px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); text-align: center; max-width: 500px; }
                    .icon { font-size: 72px; margin-bottom: 20px; }
                    h1 { color: #e53e3e; margin: 20px 0; font-size: 28px; }
                    p { color: #4a5568; font-size: 16px; line-height: 1.6; }
                    .error-details { background: #fff5f5; padding: 15px; border-radius: 8px; margin-top: 20px; border-left: 4px solid #e53e3e; }
                    .error-details p { text-align: left; font-size: 14px; margin: 5px 0; }
                </style>
            </head>
            <body>
                <div class="card">
                    <div class="icon">❌</div>
                    <h1>Xác thực thất bại</h1>
                    <p>Không thể xác thực tài khoản của bạn.</p>
                    <div class="error-details">
                        <p><strong>Lỗi:</strong> ${error.message}</p>
                        <p><strong>Giải pháp:</strong></p>
                        <p>• Link có thể đã được sử dụng</p>
                        <p>• Vui lòng liên hệ hỗ trợ nếu cần trợ giúp</p>
                    </div>
                </div>
            </body>
            </html>
        `);
    }
};

const verifyOTP = async (req, res) => {
    try {
        await authService.verifyResetToken(req.body.email, req.body.otp);
        res.json({ message: "OTP hợp lệ" });
    } catch (e) { res.status(e.statusCode || 400).json({ error: e.message }); }
};

const forgotPassword = async (req, res) => {
    try {
        await authService.forgotPassword(req.body.email);
        res.json({ message: "OTP đã được gửi" });
    } catch (e) { res.status(e.statusCode || 400).json({ error: e.message }); }
};

const resetPassword = async (req, res) => {
    try {
        await authService.resetPassword(req.body.email, req.body.newPassword, req.body.otp);
        res.json({ message: "Đổi mật khẩu thành công" });
    } catch (e) { res.status(e.statusCode || 400).json({ error: e.message }); }
};

// --- [ĐÃ SỬA LỖI QUERY BẢNG CŨ] ---
const createDoctor = async (req, res) => {
    const { fullName, email, password, adminSecret } = req.body;

    // Check mã bảo mật
    if (adminSecret !== process.env.ADMIN_KEY && adminSecret !== 'admin123') {
        return res.status(403).json({ error: "Bạn không có quyền thực hiện thao tác này" });
    }

    try {
        // 1. Tạo user (Role mặc định là patient)
        const result = await authService.register({ fullName, email, password });

        // 2. Update role lên doctor
        await pool.query("UPDATE users SET role = 'doctor' WHERE id = $1", [result.userId]);

        // 3. Insert vào bảng doctor_professional_info (Thay vì bảng doctors cũ)
        await pool.query(
            `INSERT INTO doctor_professional_info (doctor_id, specialty, hospital_name, years_of_experience, consultation_fee) 
             VALUES ($1, 'Đa khoa', 'Bệnh viện HealthAI', 1, 200000)
             ON CONFLICT (doctor_id) DO NOTHING`,
            [result.userId]
        );

        // 4. Gửi email chào mừng bác sĩ với template đẹp
        try {
            const token = jwt.sign({ userId: result.userId }, process.env.JWT_SECRET, { expiresIn: '1h' });
            sendDoctorWelcomeEmail(email, fullName, token).catch(console.error);
        } catch (e) {
            console.error('Lỗi tạo token cho email bác sĩ:', e);
        }

        res.status(201).json({
            message: "Đã tạo tài khoản Bác sĩ thành công! Email xác thực đã được gửi.",
            userId: result.userId
        });
    } catch (error) {
        // Nếu lỗi 'Email đã tồn tại' từ register
        if (error.statusCode === 409) {
            return res.status(409).json({ error: "Email này đã được sử dụng." });
        }
        res.status(500).json({ error: error.message });
    }
};

const changePassword = async (req, res) => {
    try {
        const userId = req.user.id;
        const { oldPassword, newPassword } = req.body;

        if (!oldPassword || !newPassword) return res.status(400).json({ error: "Thiếu thông tin" });
        if (newPassword.length < 6) return res.status(400).json({ error: "Mật khẩu mới quá ngắn" });

        await authService.changeUserPassword(userId, oldPassword, newPassword);

        res.json({ message: "Đổi mật khẩu thành công" });
    } catch (error) {
        if (error.message === "Mật khẩu cũ không chính xác") {
            return res.status(400).json({ error: error.message });
        }
        res.status(500).json({ error: "Lỗi server" });
    }
};
const logout = async (req, res) => {
    try {
        await authService.logout(req.user.id); // Gọi hàm service vừa thêm
        res.json({ message: "Đăng xuất thành công" });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
};

module.exports = { register, login, handleVerifyEmail, forgotPassword, verifyOTP, resetPassword, createDoctor, changePassword, logout };    