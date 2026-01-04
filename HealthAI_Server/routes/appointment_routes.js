const express = require('express');
const router = express.Router();
const appointmentController = require('../controllers/appointment_controller');
const { authenticateToken } = require('../middleware/authMiddleware');

// Middleware xác thực
router.use(authenticateToken);

// 1. GET: Lấy lịch rảnh
// Nếu controller chưa export getAvailability, dòng này sẽ gây lỗi Crash
router.get('/availability', appointmentController.getAvailability);

// 2. POST: Đặt lịch
router.post('/book', appointmentController.bookAppointment);

// 3. PUT: Hủy lịch (Lưu ý: dùng cancelAppointment thay vì updateStatus)
router.put('/:id/status', appointmentController.cancelAppointment);

// 4. GET: Lịch sử khám
router.get('/my-appointments', appointmentController.getMyAppointments);

// 5. GET: Chi tiết
router.get('/:id', appointmentController.getAppointmentDetail);

// 6. POST: Đổi lịch
router.post('/reschedule', appointmentController.rescheduleAppointment);

module.exports = router;