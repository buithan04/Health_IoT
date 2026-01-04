const appointmentService = require('../services/appointment_service');
const notifService = require('../services/notification_service');

// 1. Lấy lịch rảnh (7 ngày)
const getAvailability = async (req, res) => {
    try {
        const { doctorId } = req.query;
        // Kiểm tra doctorId
        if (!doctorId) {
            return res.status(400).json({ error: "Thiếu doctorId" });
        }

        // Gọi service
        const data = await appointmentService.get7DayAvailability(doctorId);
        res.json(data);
    } catch (error) {
        console.error("Lỗi getAvailability:", error);
        res.status(500).json({ error: "Lỗi server" });
    }
};

// 2. Đặt lịch mới (Patient)
// 2. Đặt lịch mới (Patient)
// 2. Đặt lịch mới (Patient) -> Cần báo cho Bác sĩ
const bookAppointment = async (req, res) => {
    try {
        const userId = req.user.id;
        const { doctorId, appointmentDate, reason, typeId } = req.body;

        if (!doctorId || !appointmentDate) {
            return res.status(400).json({ error: "Thiếu thông tin bác sĩ hoặc ngày khám" });
        }

        const appointmentId = await appointmentService.createAppointment({
            userId,
            doctorId,
            date: appointmentDate,
            reason,
            typeId: typeId ? parseInt(typeId) : null
        });

        // --- [THÊM ĐOẠN NÀY] Gửi thông báo & Push cho Bác sĩ ---
        // Lấy tên bệnh nhân từ req.user (đã được middleware auth gán vào)
        const patientName = req.user.full_name || req.user.email || "Bệnh nhân mới";

        await notifService.createNotification({
            userId: doctorId, // Gửi tới ID Bác sĩ
            title: '📅 Yêu cầu đặt lịch mới',
            message: `${patientName} muốn đặt lịch khám vào ${appointmentDate}.`,
            type: 'NEW_REQUEST', // Loại này để App Bác sĩ mở màn hình chi tiết
            relatedId: appointmentId
        });
        // -------------------------------------------------------

        res.json({ message: "Đặt lịch thành công", appointmentId });
    } catch (error) {
        console.error("Lỗi đặt lịch:", error);
        res.status(400).json({ error: error.message });
    }
};

// 3. Hủy lịch (Patient) - Thay thế cho updateStatus cũ
const cancelAppointment = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;
        const { reason, cancellationReason } = req.body;

        const finalReason = cancellationReason || reason || "Người dùng hủy";

        const success = await appointmentService.cancelAppointment(id, userId, finalReason);

        if (!success) return res.status(404).json({ error: "Không tìm thấy lịch hẹn hoặc lỗi quyền hạn" });

        const detail = await appointmentService.getAppointmentDetail(id);
        if (detail) {
            await notifService.createNotification({
                userId: detail.doctorId,
                title: '⚠️ Lịch hẹn bị hủy',
                message: `Bệnh nhân ${detail.patientName || ''} đã hủy lịch. Lý do: ${finalReason}`,
                type: 'APPOINTMENT_CANCELLED',
                relatedId: id
            });
        }

        res.json({ message: "Đã hủy lịch hẹn" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// 4. Lấy lịch của tôi
const getMyAppointments = async (req, res) => {
    try {
        const list = await appointmentService.getMyAppointments(req.user.id);
        res.json(list);
    } catch (error) {
        res.status(500).json({ error: "Lỗi server" });
    }
};

// 5. Chi tiết
const getAppointmentDetail = async (req, res) => {
    try {
        const detail = await appointmentService.getAppointmentDetail(req.params.id);
        if (!detail) return res.status(404).json({ error: "Không tìm thấy" });
        res.json(detail);
    } catch (error) {
        res.status(500).json({ error: "Lỗi server" });
    }
};

// 6. Đổi lịch
const rescheduleAppointment = async (req, res) => {
    try {
        const { appointmentId, appointmentDate, reason, typeId } = req.body;
        if (!appointmentId || !appointmentDate || !typeId) {
            return res.status(400).json({ error: "Thiếu thông tin đổi lịch" });
        }

        const success = await appointmentService.rescheduleAppointment(appointmentId, appointmentDate, reason, typeId);

        if (success) res.json({ message: "Đổi lịch thành công" });
        else res.status(404).json({ error: "Không tìm thấy lịch hẹn" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};


// [QUAN TRỌNG] Export đúng tên hàm
module.exports = {
    getAvailability,
    bookAppointment,
    cancelAppointment, // Đã đổi tên từ updateStatus thành cancelAppointment
    getMyAppointments,
    getAppointmentDetail,
    rescheduleAppointment
};