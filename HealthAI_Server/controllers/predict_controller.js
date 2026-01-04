const predictService = require('../services/predict_service');

const notifService = require('../services/notification_service'); // Đảm bảo import đúng

const handleMlpPrediction = async (req, res) => {
    try {
        // Cập nhật: Nhận thêm sys_bp, dia_bp
        const { heart_rate, spo2, temperature, sys_bp, dia_bp, packet_id } = req.body;
        const userId = req.user.id;

        if (!heart_rate || !spo2 || !temperature) {
            return res.status(400).json({ error: 'Thiếu thông tin chỉ số cơ bản (HR, SpO2, Temp)' });
        }

        const result = await predictService.processVitals(userId, {
            heart_rate, spo2, temperature, sys_bp, dia_bp, packet_id
        });

        // Gửi thông báo nếu nguy hiểm
        if (result.severity === 'DANGER' || result.severity === 'WARNING') {
            await notifService.createNotification({
                userId: userId,
                title: '⚠️ Cảnh báo sức khỏe',
                message: `AI phát hiện: ${result.result}. Kiểm tra ngay!`,
                type: 'HEALTH_ALERT',
                relatedId: result.recordId
            });
        }

        res.status(200).json({ message: "Phân tích hoàn tất", data: result });
    } catch (error) {
        console.error("Lỗi MLP:", error);
        res.status(500).json({ error: "Lỗi server: " + error.message });
    }
};

// ... (Giữ nguyên handleEcgPrediction, chỉ cần đảm bảo import predictService mới)

const handleEcgPrediction = async (req, res) => {
    try {
        // Nhận thêm device_id, packet_id, average_heart_rate
        const { data, device_id, packet_id, average_heart_rate } = req.body;
        const userId = req.user.id;

        if (!data || !Array.isArray(data)) {
            return res.status(400).json({ error: 'Dữ liệu ECG không hợp lệ' });
        }

        const result = await predictService.processECG(userId, {
            dataPoints: data,
            device_id,
            packet_id,
            average_heart_rate
        });

        res.status(200).json({ message: "Đã phân tích ECG", data: result });
    } catch (error) {
        console.error("Lỗi ECG:", error);
        res.status(500).json({ error: "Lỗi server" });
    }
};

module.exports = {
    handleMlpPrediction,
    handleEcgPrediction
};