const doctorService = require('../services/doctor_service');
const notifService = require('../services/notification_service');
const { pool } = require('../config/db');

// --- CÁC HÀM GET CƠ BẢN ---
const getAllDoctors = async (req, res) => {
    try {
        const doctors = await doctorService.getAllDoctors(req.query.q);
        res.json(doctors);
    } catch (e) { res.status(500).json({ error: "Lỗi server" }); }
};

const getDoctorDetail = async (req, res) => {
    try {
        const doc = await doctorService.getDoctorById(req.params.id);
        if (!doc) return res.status(404).json({ error: "Không tìm thấy" });
        res.json(doc);
    } catch (e) { res.status(500).json({ error: "Lỗi server" }); }
};

const reviewDoctor = async (req, res) => {
    try {
        const { doctorId, appointmentId, rating, comment } = req.body;
        await doctorService.createReview(req.user.id, { doctorId, appointmentId, rating, comment });

        await notifService.createNotification({
            userId: doctorId,
            title: '⭐ Đánh giá mới',
            message: `Bạn nhận được ${rating} sao từ bệnh nhân.`,
            type: 'NEW_REVIEW',
            relatedId: appointmentId
        });
        res.json({ message: "Đánh giá thành công" });
    } catch (e) { res.status(400).json({ error: e.message }); }
};

// --- CÁC HÀM DASHBOARD (DOCTOR ONLY) ---

const getDashboardStats = async (req, res) => {
    try {
        const stats = await doctorService.getDashboardStats(req.user.id);
        res.json(stats);
    } catch (e) { res.status(500).json({ error: "Lỗi server" }); }
};

const getDoctorAppointments = async (req, res) => {
    try {
        const list = await doctorService.getDoctorAppointments(req.user.id, req.query);
        res.json(list);
    } catch (e) { res.status(500).json({ error: "Lỗi server" }); }
};

const getAppointmentDetail = async (req, res) => {
    try {
        const detail = await doctorService.getAppointmentDetail(req.user.id, req.params.id);
        if (!detail) return res.status(404).json({ error: "Không tìm thấy" });
        res.json(detail);
    } catch (e) { res.status(500).json({ error: "Lỗi server" }); }
};

const respondToAppointment = async (req, res) => {
    try {
        const doctorId = req.user.id;
        const { id } = req.params;
        const { status, reason, cancellationReason } = req.body;
        const finalReason = cancellationReason || reason;

        const updated = await doctorService.respondToAppointment(doctorId, id, status, finalReason);
        if (!updated) return res.status(404).json({ error: "Không thể cập nhật" });

        const detail = await doctorService.getAppointmentDetail(doctorId, id);
        if (detail && detail.patientId) {
            let title = '', msg = '', type = '';
            if (status === 'confirmed') {
                title = 'Lịch hẹn được duyệt ✅';
                msg = `Bác sĩ đã xác nhận lịch hẹn vào ${detail.fullDateTimeStr || 'sắp tới'}.`;
                type = 'APPOINTMENT_CONFIRMED';
            } else if (status === 'cancelled') {
                title = 'Lịch hẹn bị hủy ❌';
                msg = `Bác sĩ hủy lịch. Lý do: ${finalReason || 'Bận đột xuất'}.`;
                type = 'APPOINTMENT_CANCELLED';
            } else if (status === 'completed') {
                title = 'Khám hoàn tất 🎉';
                msg = 'Buổi khám đã kết thúc. Vui lòng đánh giá bác sĩ.';
                type = 'APPOINTMENT_COMPLETED';
            }
            if (title) {
                await notifService.createNotification({
                    userId: detail.patientId,
                    title, message: msg, type, relatedId: id
                });
            }
        }
        res.json({ message: "Cập nhật thành công" });
    } catch (e) { res.status(500).json({ error: e.message }); }
};

// --- CÁC HÀM BỊ THIẾU (ĐÃ ĐƯỢC BỔ SUNG LẠI) ---

const getAvailability = async (req, res) => {
    try {
        const userId = req.user.id;
        const { date } = req.query;
        const data = await doctorService.getDoctorAvailability(userId, date);
        res.json(data);
    } catch (error) { res.status(500).json({ error: "Lỗi lấy lịch rảnh" }); }
};

const saveAvailability = async (req, res) => {
    try {
        const userId = req.user.id;
        const { date, slots } = req.body;
        await doctorService.saveDoctorAvailability(userId, date, slots);
        res.json({ message: "Lưu thành công" });
    } catch (error) { res.status(500).json({ error: "Lỗi lưu lịch" }); }
};

const addTimeOff = async (req, res) => {
    try {
        const userId = req.user.id;
        const { startDate, endDate, reason } = req.body;
        await doctorService.addTimeOff(userId, startDate, endDate, reason);
        res.json({ message: "Đăng ký nghỉ phép thành công" });
    } catch (error) { res.status(500).json({ error: "Lỗi server" }); }
};

const getNotifications = async (req, res) => {
    try {
        const userId = req.user.id;
        const notifs = await notifService.getMyNotifications(userId);
        res.json(notifs);
    } catch (error) { res.status(500).json({ error: "Lỗi lấy thông báo" }); }
};

// --- CÁC HÀM KHÁC (PROFILE, SERVICES, PATIENTS...) ---

const getMyProfile = async (req, res) => {
    const doc = await doctorService.getDoctorById(req.user.id);
    if (doc) res.json(doc); else res.status(404).json({ error: "Not found" });
};

const updateProfessionalInfo = async (req, res) => {
    try {
        // [FIX] Truyền toàn bộ req.body thay vì chỉ lấy specialty, experience
        await doctorService.updateProfessionalInfo(req.user.id, req.body);
        res.json({ message: "Cập nhật thành công" });
    } catch (e) {
        console.error(e);
        res.status(500).json({ error: "Lỗi server" });
    }
};

const getAppointmentTypes = async (req, res) => {
    const types = await doctorService.getAppointmentTypes(req.query.doctorId);
    res.json(types);
};
const addService = async (req, res) => {
    await doctorService.createService(req.user.id, req.body);
    res.json({ message: "Thêm thành công" });
};
const editService = async (req, res) => {
    await doctorService.updateService(req.user.id, req.params.id, req.body);
    res.json({ message: "Sửa thành công" });
};
const deleteService = async (req, res) => {
    await doctorService.deleteService(req.user.id, req.params.id);
    res.json({ message: "Xóa thành công" });
};

const getMyPatients = async (req, res) => res.json(await doctorService.getMyPatients(req.user.id));
const getPatientHealthStats = async (req, res) => res.json(await doctorService.getPatientHealthStats(req.params.id));
const getAnalytics = async (req, res) => res.json(await doctorService.getAnalytics(req.user.id, req.query.period || 'week'));

// --- GHI CHÚ (NOTES) ---
const getNotes = async (req, res) => {
    try {
        const notes = await doctorService.getNotes(req.user.id);
        res.json(notes);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const createNote = async (req, res) => {
    try {
        const { content } = req.body;
        const newNote = await doctorService.createNote(req.user.id, content);
        res.json(newNote);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const updateNote = async (req, res) => {
    try {
        const updated = await doctorService.updateNote(req.user.id, req.params.id, req.body.content);
        res.json(updated);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const deleteNote = async (req, res) => {
    try {
        const success = await doctorService.deleteNote(req.user.id, req.params.id);
        res.json({ success });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const getDoctorReviews = async (req, res) => res.json(await doctorService.getReviewsByDoctorId(req.params.id));
const getPatientRecord = async (req, res) => res.json(await doctorService.getPatientRecord(req.params.id));

module.exports = {
    getAllDoctors, getDoctorDetail, reviewDoctor,
    getDashboardStats, getDoctorAppointments, getAppointmentDetail, respondToAppointment,
    getMyProfile, updateProfessionalInfo,
    getAppointmentTypes, addService, editService, deleteService,
    getMyPatients, getPatientHealthStats, getAnalytics,
    getNotes, createNote, updateNote, deleteNote,
    getDoctorReviews, getPatientRecord,
    getAvailability, saveAvailability, addTimeOff, getNotifications
    // Bỏ các dòng trùng lặp ở dưới đi
};