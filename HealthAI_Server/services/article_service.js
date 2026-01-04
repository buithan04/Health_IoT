const { pool } = require('../config/db');

// Hàm lấy bài viết có hỗ trợ Lọc & Tìm kiếm
const getArticles = async (category, searchQuery) => {
    // SỬA LẠI TÊN BẢNG TẠI ĐÂY: 'articles' thay vì 'health_articles'
    let query = `SELECT * FROM articles`;
    let conditions = [];
    let params = [];
    let paramIndex = 1;

    // 1. Logic lọc theo danh mục
    if (category && category !== 'Tất cả' && category !== '') {
        conditions.push(`category = $${paramIndex}`);
        params.push(category);
        paramIndex++;
    }

    // 2. Logic tìm kiếm (Tìm trong tiêu đề HOẶC mô tả, không phân biệt hoa thường)
    if (searchQuery && searchQuery !== '') {
        conditions.push(`(title ILIKE $${paramIndex} OR description ILIKE $${paramIndex})`);
        params.push(`%${searchQuery}%`); // Dấu % để tìm kiếm gần đúng
        paramIndex++;
    }

    // 3. Ghép các điều kiện WHERE
    if (conditions.length > 0) {
        query += ` WHERE ` + conditions.join(' AND ');
    }

    // 4. Sắp xếp mới nhất trước
    query += ` ORDER BY published_at DESC`;

    try {
        const result = await pool.query(query, params);
        return result.rows;
    } catch (error) {
        console.error("Lỗi truy vấn bài viết:", error);
        throw error;
    }
};
module.exports = { getArticles };