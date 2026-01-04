const express = require('express');
const router = express.Router();
const controller = require('../controllers/reminder_controller');
const { authenticateToken } = require('../middleware/authMiddleware');

router.use(authenticateToken); // Bảo vệ tất cả route

router.get('/', controller.getAll);
router.post('/', controller.create);
router.put('/:id', controller.update);
router.delete('/:id', controller.remove);

module.exports = router;