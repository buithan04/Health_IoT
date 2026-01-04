const chatService = require('../services/chat_service');
// Giả sử file cloudinary.js export hàm uploadToCloudinary
const { uploadToCloudinary } = require('../config/cloudinary');

// 1. Bắt đầu Chat
const startChat = async (req, res) => {
    try {
        const myId = req.user.id;
        const { partnerId } = req.body;

        if (!partnerId) return res.status(400).json({ error: "Thiếu partnerId" });

        // Đảm bảo partnerId và myId khác nhau
        if (myId == partnerId) return res.status(400).json({ error: "Không thể chat với chính mình" });

        const conversationId = await chatService.getOrCreateConversation(myId, partnerId);
        res.json({ conversationId });
    } catch (error) {
        console.error("Lỗi start chat:", error);
        res.status(500).json({ error: "Lỗi server" });
    }
};

// 2. Lấy danh sách chat
const getConversations = async (req, res) => {
    try {
        const myId = req.user.id;
        const list = await chatService.getUserConversations(myId);
        res.json(list);
    } catch (error) {
        console.error("Lỗi lấy danh sách chat:", error);
        res.status(500).json({ error: "Lỗi server" });
    }
};

// 3. Lấy nội dung tin nhắn
const getMessages = async (req, res) => {
    try {
        const { id } = req.params; // conversationId
        const messages = await chatService.getMessages(id);
        res.json(messages);
    } catch (error) {
        console.error("Lỗi lấy tin nhắn:", error);
        res.status(500).json({ error: "Lỗi server" });
    }
};

// 4. Upload file/ảnh cho Chat
const uploadAttachment = async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ error: "Chưa chọn file" });

        // Upload lên folder 'health_ai_chat'
        const result = await uploadToCloudinary(req.file.buffer, 'health_ai_chat');

        res.json({
            url: result.secure_url,
            type: result.resource_type === 'image' ? 'image' : 'file' // Chuẩn hóa type trả về cho Flutter
        });
    } catch (error) {
        console.error("Lỗi upload chat:", error);
        res.status(500).json({ error: "Lỗi server khi upload" });
    }
};

// [THÊM MỚI] Hàm gửi tin nhắn
const sendMessage = async (req, res) => {
    try {
        const senderId = req.user.id;
        // Frontend cần gửi: conversationId, content, type ('text'/'image'), receiverId (người nhận)
        const { conversationId, content, type, receiverId } = req.body;

        if (!conversationId || !content) {
            return res.status(400).json({ error: "Thiếu thông tin tin nhắn" });
        }

        // 1. Lưu tin nhắn vào DB
        // Giả định chatService có hàm saveMessage. Nếu chưa có, bạn cần thêm vào service.
        const message = await chatService.saveMessage({
            conversationId,
            senderId,
            content,
            type: type || 'text'
        });

        // 2. Bắn Socket trực tiếp (Để hiện ngay lập tức nếu đang mở app)
        if (global.io) {
            global.io.to(conversationId).emit('NEW_MESSAGE_SOCKET', message);
        }

        // 3. [QUAN TRỌNG] Gửi Thông báo Push (FCM)
        // Để người nhận biết có tin nhắn khi đang tắt app
        if (receiverId && receiverId != senderId) {
            const senderName = req.user.full_name || "Ai đó";
            const notifContent = type === 'image' ? 'Đã gửi một ảnh 📷' : content;

            await notifService.createNotification({
                userId: receiverId, // ID người nhận
                title: `Tin nhắn từ ${senderName}`,
                message: notifContent,
                type: 'NEW_MESSAGE',
                relatedId: conversationId // Để bấm vào nhảy thẳng vào phòng chat
            });
        }

        res.json(message);
    } catch (error) {
        console.error("Lỗi gửi tin nhắn:", error);
        res.status(500).json({ error: "Lỗi server khi gửi tin nhắn" });
    }
};

module.exports = {
    startChat,
    getConversations,
    getMessages,
    uploadAttachment,
    sendMessage
};