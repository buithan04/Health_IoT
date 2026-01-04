// routes/doctor_routes.js
const express = require('express');
const router = express.Router();
const doctorController = require('../controllers/doctor_controller');
const { authenticateToken } = require('../middleware/authMiddleware');

// --- PUBLIC / PATIENT ROUTES ---
router.get('/', authenticateToken, doctorController.getAllDoctors);
router.post('/review', authenticateToken, doctorController.reviewDoctor);

// --- [MỚI] Lấy danh sách loại dịch vụ khám (Appointment Types) ---
// Đặt trước route /:id để tránh bị nhầm là ID bác sĩ
router.get('/appointment-types', authenticateToken, doctorController.getAppointmentTypes);


// --- DOCTOR DASHBOARD ROUTES ---
router.get('/dashboard-stats', authenticateToken, doctorController.getDashboardStats);
// Đặt dòng này vào khu vực DOCTOR DASHBOARD ROUTES
router.get('/analytics', authenticateToken, doctorController.getAnalytics);
router.get('/appointments', authenticateToken, doctorController.getDoctorAppointments);
router.get('/appointments/:id', authenticateToken, doctorController.getAppointmentDetail);
router.put('/appointments/:id', authenticateToken, doctorController.respondToAppointment);

router.get('/availability', authenticateToken, doctorController.getAvailability);
router.post('/availability', authenticateToken, doctorController.saveAvailability);

// --- [MỚI] Đăng ký ngày nghỉ phép (Doctor Time Off) ---
router.post('/time-off', authenticateToken, doctorController.addTimeOff);

router.get('/notifications', authenticateToken, doctorController.getNotifications);
router.get('/:id/reviews', doctorController.getDoctorReviews);
router.get('/patient-record/:id', authenticateToken, doctorController.getPatientRecord);


// --- [MỚI] Routes quản lý dịch vụ ---
router.post('/services', authenticateToken, doctorController.addService);
router.put('/services/:id', authenticateToken, doctorController.editService);
router.delete('/services/:id', authenticateToken, doctorController.deleteService);

// --- [MỚI] Lấy danh sách bệnh nhân của bác sĩ ---
router.get('/patients', authenticateToken, doctorController.getMyPatients);
// --- [MỚI] Lấy thống kê sức khỏe của bệnh nhân ---
router.get('/patients/:id/health-stats', authenticateToken, doctorController.getPatientHealthStats);

// --- [MỚI] Routes quản lý ghi chú ---
router.get('/notes', authenticateToken, doctorController.getNotes);
router.post('/notes', authenticateToken, doctorController.createNote);
router.put('/notes/:id', authenticateToken, doctorController.updateNote);
router.delete('/notes/:id', authenticateToken, doctorController.deleteNote);

// --- KHU VỰC PROFILE (Thêm vào TRƯỚC dòng router.get('/:id'...)) ---

// 1. Route lấy profile của chính mình
// Frontend gọi: /doctors/profile/me
router.get('/profile/me', authenticateToken, doctorController.getMyProfile);

// 2. Route cập nhật thông tin chuyên môn
// Frontend gọi: /doctors/profile/professional-info
router.put('/profile/professional-info', authenticateToken, doctorController.updateProfessionalInfo);


// --- ROUTE CHI TIẾT (Luôn để cuối cùng) ---
router.get('/:id', authenticateToken, doctorController.getDoctorDetail);

module.exports = router;