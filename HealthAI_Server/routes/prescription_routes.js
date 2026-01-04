const express = require('express');
const router = express.Router();
const controller = require('../controllers/prescription_controller');
const { authenticateToken } = require('../middleware/authMiddleware');

// GET /api/prescriptions/my-prescriptions (Cho bệnh nhân)
router.get('/my-prescriptions', authenticateToken, controller.getMyPrescriptions);

// POST /api/prescriptions (Tạo đơn - Cho bác sĩ) - Đổi từ /create thành / cho chuẩn REST
router.post('/', authenticateToken, controller.create);

// [MỚI] Route tìm thuốc
router.get('/medications', authenticateToken, controller.getMedications);

// GET /api/prescriptions/:id (Chi tiết - Cho cả 2)
router.get('/:id', authenticateToken, controller.getDetail);

module.exports = router;