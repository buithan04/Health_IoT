const express = require('express');
const router = express.Router();
const controller = require('../controllers/article_controller');
const { authenticateToken } = require('../middleware/authMiddleware');

router.get('/', authenticateToken, controller.getArticles);

module.exports = router;