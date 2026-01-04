const cloudinary = require('cloudinary').v2;
const streamifier = require('streamifier');

// 1. CẤU HÌNH (Dùng thông tin bạn vừa gửi)
cloudinary.config({
    cloud_name: 'dckvzpy22',
    api_key: '748466159865798',
    api_secret: '-2sUgv0do1si6oIvr91CykRga9c' // <--- QUAN TRỌNG: Hãy paste API Secret vào đây
});

// 2. HÀM UPLOAD (Dùng chung cho toàn dự án)
const uploadToCloudinary = (fileBuffer, folderName) => {
    return new Promise((resolve, reject) => {
        // Tạo luồng upload lên Cloudinary
        const uploadStream = cloudinary.uploader.upload_stream(
            {
                folder: folderName, // Ví dụ: 'health_ai/avatars'
                resource_type: 'auto' // Tự động nhận diện ảnh/video
            },
            (error, result) => {
                if (error) return reject(error);
                // Trả về kết quả (chứa URL ảnh)
                resolve(result);
            }
        );
        // Đẩy dữ liệu từ RAM (Buffer) vào luồng upload
        streamifier.createReadStream(fileBuffer).pipe(uploadStream);
    });
};

module.exports = { uploadToCloudinary };