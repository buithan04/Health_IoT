const axios = require('axios');
const https = require('https'); // 1. Thêm thư viện https
const { pool } = require('../config/db');

// API Key (Lưu ý: Bạn nên đưa vào biến môi trường .env để bảo mật)
const API_KEY = '16e45671465f49fba73f25b2a9c368ca';

const fetchAndSaveArticles = async () => {
    console.log("🔄 Đang kết nối NewsAPI (Chế độ ép buộc IPv4)...");

    try {
        // 2. Cấu hình Agent để ép dùng IPv4
        const agent = new https.Agent({
            family: 4 // Quan trọng: Chỉ dùng IPv4, bỏ qua IPv6 gây lỗi
        });

        // 3. Gọi API với cấu hình tối ưu
        const response = await axios.get('https://newsapi.org/v2/everything', {
            params: {
                q: '"sức khỏe" OR "y tế"', // Tự động mã hóa URL an toàn
                language: 'vi',
                sortBy: 'publishedAt',
                apiKey: API_KEY,
                pageSize: 20 // Lấy 20 bài mới nhất
            },
            timeout: 30000, // Tự ngắt sau 10s nếu mạng treo
            httpsAgent: agent, // Áp dụng agent IPv4 vào đây
            headers: {
                'User-Agent': 'Health-News-Crawler/1.0' // Giúp tránh bị chặn bởi Firewall
            }
        });

        const articles = response.data.articles;

        if (!articles || articles.length === 0) {
            console.log("⚠️ API trả về danh sách rỗng.");
            return;
        }

        let count = 0;
        for (const article of articles) {
            // Lọc bỏ bài lỗi
            if (!article.urlToImage || !article.title || article.title === '[Removed]') continue;

            const query = `
                INSERT INTO articles (title, description, category, source_name, image_url, content_url, published_at)
                VALUES ($1, $2, 'Tin tức y tế', $3, $4, $5, $6)
                ON CONFLICT (content_url) DO NOTHING
            `;

            const res = await pool.query(query, [
                article.title,
                article.description || 'Bấm để đọc chi tiết...',
                article.source.name || 'Internet',
                article.urlToImage,
                article.url,
                article.publishedAt
            ]);

            if (res.rowCount > 0) count++;
        }

        if (count > 0) {
            console.log(`✅ Đã cập nhật thêm ${count} bài viết mới.`);
        } else {
            console.log("ℹ️ Không có bài mới (Dữ liệu đã tồn tại).");
        }

    } catch (error) {
        // Xử lý lỗi chi tiết để dễ debug
        if (error.code === 'ETIMEDOUT') {
            console.error("❌ Lỗi Mạng: Kết nối bị quá hạn (Timeout). Kiểm tra lại internet.");
        } else if (error.response) {
            console.error(`❌ Lỗi API (${error.response.status}):`, error.response.data.message);
        } else {
            console.error("❌ Lỗi không xác định:", error.message);
        }
    }
};

module.exports = { fetchAndSaveArticles };