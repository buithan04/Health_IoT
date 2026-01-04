// emailService.js
const nodemailer = require('nodemailer');
require('dotenv').config();

// 1. Cấu hình "người gửi" (dùng Gmail làm ví dụ)
// Sử dụng biến môi trường để bảo mật
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER || 'your-email@gmail.com',
        pass: process.env.EMAIL_APP_PASSWORD || 'your-app-password'
    }
});

// Disable email nếu chưa cấu hình
const EMAIL_ENABLED = !!(process.env.EMAIL_USER && process.env.EMAIL_APP_PASSWORD);

/**
 * Gửi email xác thực
 * @param {string} userEmail - Email của người nhận
 * @param {string} token - Token xác thực
 */
const sendVerificationEmail = async (userEmail, token) => {
    const verificationLink = `http://192.168.1.5:5000/api/auth/verify?token=${token}`;

    const mailOptions = {
        from: '"HealthAI - Nền tảng Chăm sóc Sức khỏe" <than.65.cvan@gmail.com>',
        to: userEmail,
        subject: '🏥 Xác thực tài khoản HealthAI của bạn',
        html: `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body { margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f0f4f8; }
                    .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; }
                    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 20px; text-align: center; }
                    .header h1 { color: #ffffff; margin: 0; font-size: 28px; font-weight: 600; }
                    .header p { color: #f0f4f8; margin: 10px 0 0 0; font-size: 14px; }
                    .content { padding: 40px 30px; }
                    .welcome { font-size: 24px; color: #2d3748; margin-bottom: 20px; font-weight: 600; }
                    .message { color: #4a5568; line-height: 1.6; font-size: 16px; margin-bottom: 30px; }
                    .button-container { text-align: center; margin: 35px 0; }
                    .verify-button { 
                        display: inline-block;
                        padding: 16px 40px;
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        color: #ffffff;
                        text-decoration: none;
                        border-radius: 8px;
                        font-weight: 600;
                        font-size: 16px;
                        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
                        transition: transform 0.2s;
                    }
                    .verify-button:hover { transform: translateY(-2px); }
                    .info-box { 
                        background-color: #edf2f7; 
                        border-left: 4px solid #667eea; 
                        padding: 15px 20px; 
                        margin: 25px 0; 
                        border-radius: 4px;
                    }
                    .info-box p { margin: 5px 0; color: #2d3748; font-size: 14px; }
                    .footer { 
                        background-color: #f7fafc; 
                        padding: 30px; 
                        text-align: center; 
                        border-top: 1px solid #e2e8f0;
                    }
                    .footer p { color: #718096; font-size: 13px; margin: 5px 0; }
                    .icon { font-size: 48px; margin-bottom: 20px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <div class="icon">🏥</div>
                        <h1>HealthAI Platform</h1>
                        <p>Nền tảng Chăm sóc Sức khỏe Thông minh</p>
                    </div>
                    
                    <div class="content">
                        <div class="welcome">Chào mừng bạn đến với HealthAI! 👋</div>
                        
                        <div class="message">
                            <p>Cảm ơn bạn đã đăng ký tài khoản HealthAI. Chúng tôi rất vui mừng có bạn tham gia cộng đồng chăm sóc sức khỏe của chúng tôi.</p>
                            <p>Để bắt đầu sử dụng các tính năng của nền tảng, vui lòng xác thực địa chỉ email của bạn bằng cách nhấp vào nút bên dưới:</p>
                        </div>

                        <div class="button-container">
                            <a href="${verificationLink}" class="verify-button">✓ Xác thực tài khoản</a>
                        </div>

                        <div class="info-box">
                            <p><strong>📌 Lưu ý:</strong></p>
                            <p>• Link xác thực có hiệu lực trong 15 phút</p>
                            <p>• Link chỉ sử dụng được một lần</p>
                            <p>• Nếu bạn không thực hiện đăng ký này, vui lòng bỏ qua email này</p>
                            <p>• Nếu nút không hoạt động, copy link sau vào trình duyệt:</p>
                            <p style="word-break: break-all; color: #667eea; font-size: 12px;">${verificationLink}</p>
                        </div>

                        <div class="message">
                            <p><strong>Sau khi xác thực, bạn có thể:</strong></p>
                            <p>✅ Đặt lịch khám bệnh với bác sĩ</p>
                            <p>✅ Theo dõi sức khỏe hàng ngày</p>
                            <p>✅ Quản lý hồ sơ bệnh án điện tử</p>
                            <p>✅ Nhận tư vấn y tế trực tuyến</p>
                        </div>
                    </div>

                    <div class="footer">
                        <p><strong>HealthAI Platform</strong></p>
                        <p>🏥 Chăm sóc sức khỏe thông minh, tiện lợi, hiện đại</p>
                        <p style="margin-top: 15px;">📧 Hỗ trợ: than.65.cvan@gmail.com</p>
                        <p style="color: #a0aec0; font-size: 11px; margin-top: 15px;">© 2026 HealthAI. All rights reserved.</p>
                    </div>
                </div>
            </body>
            </html>
        `
    };

    // 4. Gửi mail
    try {
        if (!EMAIL_ENABLED) {
            console.log(`⚠️  Email service disabled. Would send verification to: ${userEmail}`);
            console.log(`📧 Verification link: ${verificationLink}`);
            return true; // Return success để không block flow
        }
        await transporter.sendMail(mailOptions);
        console.log(`✅ Email xác thực đã gửi tới: ${userEmail}`);
        return true;
    } catch (error) {
        console.error('❌ Lỗi khi gửi email:', error.message);
        // Không throw error để tránh crash app
        return false;
    }
};
const sendResetPasswordEmail = async (userEmail, otp) => {
    const mailOptions = {
        from: '"Ứng dụng Sức khỏe" <than.65.cvan@gmail.com>',
        to: userEmail,
        subject: 'Mã OTP Khôi phục mật khẩu',
        html: `
            <h3>Yêu cầu khôi phục mật khẩu</h3>
            <p>Mã OTP của bạn là: <b style="font-size: 24px; color: blue;">${otp}</b></p>
            <p>Mã này sẽ hết hạn sau 15 phút.</p>
            <p>Nếu bạn không yêu cầu, vui lòng bỏ qua email này.</p>
        `
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log(`OTP đã gửi tới: ${userEmail}`);
    } catch (error) {
        console.error('Lỗi gửi mail OTP:', error);
        throw error; // Ném lỗi để service biết
    }
};

/**
 * Gửi email chào mừng bác sĩ với template chuyên nghiệp
 * @param {string} doctorEmail - Email của bác sĩ
 * @param {string} doctorName - Tên bác sĩ
 * @param {string} token - Token xác thực
 */
const sendDoctorWelcomeEmail = async (doctorEmail, doctorName, token) => {
    const verificationLink = `http://192.168.5.47:5000/api/auth/verify?token=${token}`;

    const mailOptions = {
        from: '"HealthAI Platform" <than.65.cvan@gmail.com>',
        to: doctorEmail,
        subject: '🩺 Chào mừng bác sĩ gia nhập HealthAI',
        html: `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f4f7fa; }
                    .container { max-width: 600px; margin: 40px auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
                    .header { background: linear-gradient(135deg, #0d9488 0%, #14b8a6 100%); padding: 40px 30px; text-align: center; }
                    .header h1 { color: white; margin: 0; font-size: 28px; font-weight: 600; }
                    .header p { color: rgba(255,255,255,0.9); margin: 10px 0 0; font-size: 16px; }
                    .content { padding: 40px 30px; }
                    .greeting { font-size: 18px; color: #1f2937; margin-bottom: 20px; font-weight: 500; }
                    .message { color: #4b5563; line-height: 1.8; font-size: 15px; margin-bottom: 30px; }
                    .button-container { text-align: center; margin: 35px 0; }
                    .verify-button { 
                        display: inline-block; 
                        background: linear-gradient(135deg, #0d9488 0%, #14b8a6 100%); 
                        color: white; 
                        padding: 16px 40px; 
                        text-decoration: none; 
                        border-radius: 8px; 
                        font-weight: 600; 
                        font-size: 16px;
                        box-shadow: 0 4px 12px rgba(13, 148, 136, 0.3);
                        transition: transform 0.2s;
                    }
                    .verify-button:hover { transform: translateY(-2px); }
                    .features { background: #f9fafb; border-radius: 8px; padding: 25px; margin: 30px 0; }
                    .features h3 { color: #0d9488; margin: 0 0 15px; font-size: 18px; }
                    .feature-list { list-style: none; padding: 0; margin: 0; }
                    .feature-list li { 
                        color: #4b5563; 
                        padding: 10px 0; 
                        padding-left: 30px; 
                        position: relative;
                        font-size: 14px;
                    }
                    .feature-list li:before { 
                        content: "✓"; 
                        position: absolute; 
                        left: 0; 
                        color: #14b8a6; 
                        font-weight: bold; 
                        font-size: 18px;
                    }
                    .footer { background: #f9fafb; padding: 25px 30px; text-align: center; color: #6b7280; font-size: 13px; border-top: 1px solid #e5e7eb; }
                    .footer a { color: #0d9488; text-decoration: none; }
                    .divider { border-top: 2px solid #e5e7eb; margin: 30px 0; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🩺 HealthAI Platform</h1>
                        <p>Nền tảng chăm sóc sức khỏe thông minh</p>
                    </div>
                    
                    <div class="content">
                        <div class="greeting">Kính chào Bác sĩ ${doctorName},</div>
                        
                        <div class="message">
                            <p>Chào mừng Bác sĩ đến với <strong>HealthAI Platform</strong> - nền tảng kết nối bác sĩ và bệnh nhân hàng đầu!</p>
                            
                            <p>Tài khoản bác sĩ của Quý vị đã được tạo thành công bởi quản trị viên. Để bắt đầu sử dụng nền tảng, vui lòng xác thực địa chỉ email bằng cách nhấn vào nút bên dưới:</p>
                        </div>
                        
                        <div class="button-container">
                            <a href="${verificationLink}" class="verify-button">
                                🔐 Xác thực tài khoản ngay
                            </a>
                        </div>
                        
                        <div class="features">
                            <h3>🌟 Tính năng dành cho Bác sĩ</h3>
                            <ul class="feature-list">
                                <li>Quản lý lịch hẹn khám bệnh trực tuyến</li>
                                <li>Kê đơn thuốc điện tử an toàn và tiện lợi</li>
                                <li>Theo dõi hồ sơ sức khỏe bệnh nhân</li>
                                <li>Tư vấn và trò chuyện trực tiếp với bệnh nhân</li>
                                <li>Nhận thông báo lịch hẹn và yêu cầu khám</li>
                                <li>Xem đánh giá và phản hồi từ bệnh nhân</li>
                            </ul>
                        </div>
                        
                        <div class="divider"></div>
                        
                        <div class="message" style="font-size: 14px; color: #6b7280;">
                            <p><strong>Lưu ý:</strong> Link xác thực có hiệu lực trong vòng <strong>1 giờ</strong>. Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email này hoặc liên hệ với quản trị viên.</p>
                        </div>
                    </div>
                    
                    <div class="footer">
                        <p><strong>HealthAI Platform</strong> | Chăm sóc sức khỏe thông minh</p>
                        <p>Email hỗ trợ: <a href="mailto:support@healthai.com">support@healthai.com</a></p>
                        <p style="margin-top: 15px; color: #9ca3af;">© 2026 HealthAI. All rights reserved.</p>
                    </div>
                </div>
            </body>
            </html>
        `
    };

    try {
        if (!EMAIL_ENABLED) {
            console.log(`⚠️  Email service disabled. Would send doctor welcome to: ${doctorEmail}`);
            console.log(`📧 Verification link: ${verificationLink}`);
            return true;
        }
        await transporter.sendMail(mailOptions);
        console.log(`✅ Email chào mừng bác sĩ đã gửi tới: ${doctorEmail}`);
        return true;
    } catch (error) {
        console.error('❌ Lỗi khi gửi email bác sĩ:', error.message);
        return false;
    }
};

module.exports = { sendVerificationEmail, sendResetPasswordEmail, sendDoctorWelcomeEmail };