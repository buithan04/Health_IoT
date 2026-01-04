const articleService = require('../services/article_service');

const getArticles = async (req, res) => {
    try {
        // Lấy tham số từ URL: /api/articles?category=...&search=...
        const { category, search } = req.query;

        // Gọi service với cả 2 tham số
        const list = await articleService.getArticles(category, search);

        res.json(list);
    } catch (error) {
        console.error("Lỗi lấy bài viết:", error);
        res.status(500).json({ error: "Lỗi server" });
    }
};

module.exports = { getArticles };