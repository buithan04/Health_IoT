// routes/predict_routes.js
const express = require('express');
const router = express.Router();

// Dòng này đã đúng
const { handleMlpPrediction, handleEcgPrediction } = require('../controllers/predict_controller');

// SỬA DÒNG NÀY: Thêm dấu {}
const { authenticateToken } = require('../middleware/authMiddleware');


// Bây giờ 'authenticateToken' là một hàm, và code dưới đây sẽ chạy đúng
router.post('/mlp', authenticateToken, handleMlpPrediction);
router.post('/ecg', authenticateToken, handleEcgPrediction);


module.exports = router;