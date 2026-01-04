// workers/scheduler.js
const cron = require('node-cron');
const { pool } = require('../config/db');
const notifService = require('../services/notification_service');

const startScheduler = () => {
    console.log("⏰ Scheduler đã bật...");

    cron.schedule('* * * * *', async () => {
        // LẤY GIỜ VIỆT NAM CHUẨN
        const now = new Date();
        const vnTime = new Date(now.toLocaleString('en-US', { timeZone: 'Asia/Ho_Chi_Minh' }));

        const currentHour = String(vnTime.getHours()).padStart(2, '0');
        const currentMinute = String(vnTime.getMinutes()).padStart(2, '0');
        const timeString = `${currentHour}:${currentMinute}`;

        // In ra để xem Server đang chạy giờ nào
        console.log(`⏳ Scanning appointments at: ${timeString}`);

        try {
            // Tìm kiếm các nhắc nhở khớp giờ (HH:mm%)
            const query = `
                SELECT * FROM medication_reminders 
                WHERE is_active = TRUE 
                AND reminder_time::text LIKE $1
            `;
            const result = await pool.query(query, [`${timeString}%`]);

            if (result.rows.length > 0) {
                console.log(`💊 Tìm thấy ${result.rows.length} người cần uống thuốc!`);

                for (const reminder of result.rows) {
                    await notifService.createNotification({
                        userId: reminder.user_id,
                        title: 'Đến giờ uống thuốc 💊',
                        message: `Đừng quên: ${reminder.medication_name} - ${reminder.instruction}`,
                        type: 'MEDICATION_REMINDER',
                        relatedId: reminder.id
                    });
                    console.log(`✅ Đã tạo thông báo cho User ${reminder.user_id}`);
                }
            }
        } catch (error) {
            console.error("❌ Lỗi Scheduler:", error);
        }
    });
};

module.exports = { startScheduler };