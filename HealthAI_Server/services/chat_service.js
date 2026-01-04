const { pool } = require('../config/db');

// Get all conversations for a user
const getUserConversations = async (userId) => {
    const query = `
        SELECT DISTINCT ON (c.id)
            c.id,
            c.last_message_content as "lastMessage",
            c.last_message_at,
            
            CASE 
                WHEN p.user_id = $1 THEN pr2.full_name 
                ELSE pr1.full_name
            END as "partnerName",
            
            CASE 
                WHEN p.user_id = $1 THEN u2.avatar_url 
                ELSE u1.avatar_url
            END as "partnerAvatar",

            CASE 
                WHEN p.user_id = $1 THEN u2.id
                ELSE u1.id
            END as "partnerId"

        FROM conversations c
        JOIN participants p ON c.id = p.conversation_id
        
        JOIN users u1 ON p.user_id = u1.id
        JOIN profiles pr1 ON u1.id = pr1.user_id
        
        LEFT JOIN participants p2 ON c.id = p2.conversation_id AND p2.user_id != p.user_id
        LEFT JOIN users u2 ON p2.user_id = u2.id
        LEFT JOIN profiles pr2 ON u2.id = pr2.user_id
        
        WHERE p.user_id = $1
        ORDER BY c.id, c.last_message_at DESC
    `;
    const result = await pool.query(query, [userId]);

    return result.rows.map(row => ({
        ...row,
        // Format time trả về client nếu cần, hoặc để client tự format
        timeDisplay: row.last_message_at ? new Date(row.last_message_at).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }) : ''
    }));
};

const getMessages = async (conversationId) => {
    // SỬA CÂU QUERY: Join thêm bảng profiles để lấy full_name
    const query = `
        SELECT 
            m.id, m.conversation_id, m.sender_id as "senderId", 
            m.content, m.message_type as "type", m.created_at,
            u.avatar_url as "senderAvatar",
            pr.full_name as "senderName", -- [THÊM MỚI] Lấy tên người gửi
            m.status,
            m.is_read
        FROM messages m
        JOIN users u ON m.sender_id = u.id
        LEFT JOIN profiles pr ON u.id = pr.user_id -- [THÊM JOIN]
        WHERE m.conversation_id = $1
        ORDER BY m.created_at DESC
    `;
    const result = await pool.query(query, [conversationId]);
    return result.rows;
};

const saveMessage = async (conversationId, senderId, content, type = 'text') => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // [FIX] Kiểm tra conversation có tồn tại không
        const checkConv = await client.query(
            'SELECT id FROM conversations WHERE id = $1',
            [conversationId]
        );

        if (checkConv.rows.length === 0) {
            await client.query('ROLLBACK');
            const error = new Error(`Conversation ID ${conversationId} không tồn tại trong database`);
            error.code = 'CONVERSATION_NOT_FOUND';
            throw error;
        }

        // Insert message
        const insertQuery = `
            INSERT INTO messages (conversation_id, sender_id, content, message_type)
            VALUES ($1, $2, $3, $4)
            RETURNING id, created_at
        `;
        const res = await client.query(insertQuery, [conversationId, senderId, content, type]);

        // Update conversation last message
        const lastMsgContent = type === 'text' ? content : (type === 'image' ? '[Hình ảnh]' : '[Tệp đính kèm]');
        await client.query(`
            UPDATE conversations 
            SET last_message_content = $1, last_message_at = NOW() 
            WHERE id = $2
        `, [lastMsgContent, conversationId]);

        await client.query('COMMIT');

        // Trả về đúng format mà Frontend (ChatMessage.fromJson) mong đợi
        return {
            id: res.rows[0].id,
            conversation_id: conversationId,
            senderId: senderId,
            content: content,
            type: type,
            created_at: res.rows[0].created_at
        };
    } catch (e) {
        await client.query('ROLLBACK');
        throw e;
    } finally {
        client.release();
    }
};

const getOrCreateConversation = async (user1, user2) => {
    // 1. Check existing conversation (1-1)
    // Query này tìm conversation có đúng 2 người này tham gia
    const checkQuery = `
        SELECT c.id 
        FROM conversations c
        JOIN participants p1 ON c.id = p1.conversation_id
        JOIN participants p2 ON c.id = p2.conversation_id
        WHERE p1.user_id = $1 AND p2.user_id = $2
        GROUP BY c.id
        LIMIT 1
    `;
    const checkRes = await pool.query(checkQuery, [user1, user2]);

    if (checkRes.rows.length > 0) return checkRes.rows[0].id;

    // 2. Create new
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        const convRes = await client.query(`INSERT INTO conversations DEFAULT VALUES RETURNING id`);
        const convId = convRes.rows[0].id;

        await client.query(`INSERT INTO participants (conversation_id, user_id) VALUES ($1, $2), ($1, $3)`, [convId, user1, user2]);

        await client.query('COMMIT');
        return convId;
    } catch (e) {
        await client.query('ROLLBACK');
        throw e;
    } finally {
        client.release();
    }
};
// [THÊM MỚI HÀM NÀY VÀO CUỐI FILE]
const markMessagesAsRead = async (conversationId, readerId) => {
    const client = await pool.connect();
    try {
        // [FIX MESSENGER LOGIC]
        // Cập nhật TẤT CẢ tin nhắn từ partner thành 'read'
        // Điều kiện: Người gửi KHÔNG PHẢI là người đang đọc (sender_id != readerId)
        // Logic Messenger: Khi user XEM chat, tất cả messages từ partner đều phải là 'seen'
        const query = `
            UPDATE messages
            SET status = 'read', is_read = TRUE
            WHERE conversation_id = $1 
            AND sender_id != $2
            RETURNING id, sender_id, created_at
        `;
        const result = await client.query(query, [conversationId, readerId]);

        console.log(`   📊 Marked ${result.rows.length} messages as read`);

        // Trả về danh sách các tin nhắn vừa được update để Socket biết mà báo cho người kia
        return result.rows;
    } catch (e) {
        console.error("Lỗi markMessagesAsRead:", e);
        return [];
    } finally {
        client.release();
    }
};

module.exports = {
    getUserConversations,
    getMessages,
    saveMessage,
    getOrCreateConversation,
    markMessagesAsRead
};