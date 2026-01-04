const userService = require('../services/user_service');

// --- 1. Upload Avatar ---
const uploadAvatar = async (req, res) => {
    try {
        // Kiểm tra xem có file được gửi lên không
        if (!req.file) {
            return res.status(400).json({ error: "Vui lòng chọn ảnh để tải lên" });
        }

        const userId = req.user.id;

        // QUAN TRỌNG: Dùng req.file.buffer (vì ta dùng memoryStorage trong routes)
        // Gọi service để upload lên Cloudinary
        const newAvatarUrl = await userService.uploadUserAvatar(userId, req.file.buffer);

        res.json({
            message: "Cập nhật ảnh đại diện thành công",
            avatarUrl: newAvatarUrl // Trả về link https://res.cloudinary.com/...
        });

    } catch (error) {
        console.error("Lỗi Upload Avatar Controller:", error);
        res.status(500).json({ error: "Lỗi server khi upload ảnh" });
    }
};

// --- 2. Lấy thông tin Profile ---
// --- 2. Lấy thông tin Profile (ĐÃ CẬP NHẬT) ---
const getUserProfile = async (req, res) => {
    try {
        const userId = req.user.id;
        const userInfo = await userService.getUserProfile(userId);

        if (!userInfo) {
            return res.status(404).json({ error: "Không tìm thấy người dùng" });
        }

        res.json({
            id: userInfo.id,
            email: userInfo.email,
            full_name: userInfo.full_name || userInfo.email,
            avatar_url: userInfo.avatar_url,
            phone_number: userInfo.phone_number,
            gender: userInfo.gender,
            date_of_birth: userInfo.date_of_birth,
            address: userInfo.address,

            // Hành chính
            insurance_number: userInfo.insurance_number,
            emergency_contact_name: userInfo.emergency_contact_name,
            emergency_contact_phone: userInfo.emergency_contact_phone,
            occupation: userInfo.occupation,

            // Sức khỏe
            height: userInfo.height,
            weight: userInfo.weight,
            medical_history: userInfo.medical_history,
            allergies: userInfo.allergies,
            blood_type: userInfo.blood_type, // [QUAN TRỌNG] Thêm dòng này để Frontend nhận được
            lifestyle_info: userInfo.lifestyle_info
        });

    } catch (error) {
        console.error("Lỗi lấy Profile:", error);
        res.status(500).json({ error: "Lỗi server" });
    }
};

const updateProfile = async (req, res) => {
    try {
        const userId = req.user.id;
        // req.body có thể chỉ chứa { height, weight } HOẶC { full_name, address }
        // Service đã xử lý logic COALESCE nên không lo bị ghi đè null
        await userService.updateUserProfile(userId, req.body);

        res.json({ message: "Cập nhật thành công" });
    } catch (error) {
        console.error("Lỗi update profile:", error);
        res.status(500).json({ error: "Lỗi server" });
    }
};



// --- 5. Lấy danh sách đánh giá của tôi (MỚI) ---
const getMyReviews = async (req, res) => {
    try {
        const userId = req.user.id;

        const reviews = await userService.getUserReviews(userId);

        res.json(reviews); // Trả về danh sách mảng []

    } catch (error) {
        console.error("Lỗi lấy reviews:", error);
        res.status(500).json({ error: "Lỗi server khi lấy danh sách đánh giá" });
    }
};
const updateFcmToken = async (req, res) => {
    try {
        const { fcmToken } = req.body;
        const userId = req.user.id;

        // Gọi Service xử lý
        await userService.updateUserFcmToken(userId, fcmToken);

        res.json({ success: true });
    } catch (error) {
        console.error("Lỗi update FCM Token:", error);
        res.status(500).json({ error: error.message });
    }
};

module.exports = {
    uploadAvatar,
    getUserProfile,
    updateProfile,
    getMyReviews,
    updateFcmToken
};