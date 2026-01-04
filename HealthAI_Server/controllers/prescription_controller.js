const prescriptionService = require('../services/prescription_service');
const notifService = require('../services/notification_service');

const getMyPrescriptions = async (req, res) => {
    try {
        const userId = req.user.id;
        const list = await prescriptionService.getMyPrescriptions(userId);
        res.json(list);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Lỗi lấy danh sách đơn thuốc" });
    }
};

const getDetail = async (req, res) => {
    try {
        const { id } = req.params;
        const detail = await prescriptionService.getPrescriptionDetail(id);
        if (!detail) return res.status(404).json({ error: "Không tìm thấy đơn thuốc" });
        res.json(detail);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Lỗi lấy chi tiết" });
    }
};
const create = async (req, res) => {
    try {
        const doctorId = req.user.id;
        // Frontend gửi: patientId, diagnosis, notes, medications
        const { patientId, diagnosis, notes, medications } = req.body;

        if (!patientId || !medications || !medications.length) {
            return res.status(400).json({ error: "Thiếu thông tin bệnh nhân hoặc thuốc" });
        }

        // Truyền Object vào service
        const presId = await prescriptionService.createPrescription({
            doctorId,
            patientId,
            diagnosis: diagnosis || '',
            notes: notes || '',
            chiefComplaint: req.body.chiefComplaint,   // Nếu có
            clinicalFindings: req.body.clinicalFindings, // Nếu có
            medications // Array: [{name, quantity, instruction}]
        });

        // Notify Patient
        await notifService.createNotification({
            userId: patientId,
            title: '💊 Đơn thuốc mới',
            message: 'Bác sĩ vừa kê một đơn thuốc cho bạn.',
            type: 'NEW_PRESCRIPTION',
            relatedId: presId
        });

        res.json({ message: "Kê đơn thành công", prescriptionId: presId });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Lỗi tạo đơn thuốc" });
    }
};
// [MỚI] API tìm thuốc
const getMedications = async (req, res) => {
    try {
        const { q } = req.query; // Lấy từ khóa tìm kiếm từ URL (?q=panadol)
        const list = await prescriptionService.searchMedications(q);
        res.json(list);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Lỗi tìm thuốc" });
    }
};

module.exports = { getMyPrescriptions, getDetail, create, getMedications };