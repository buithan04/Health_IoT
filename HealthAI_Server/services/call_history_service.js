// ============================================
// CALL HISTORY SERVICE
// ============================================
const { pool } = require('../config/db');

/**
 * Lưu lịch sử cuộc gọi vào database
 */
async function saveCallHistory({
    callId,
    callerId,
    receiverId,
    callType, // 'video' hoặc 'audio'
    status, // 'completed', 'declined', 'missed', 'cancelled'
    duration, // Thời lượng cuộc gọi (giây), null nếu không kết nối
    startTime,
    endTime
}) {
    try {
        const query = `
      INSERT INTO call_history 
        (call_id, caller_id, receiver_id, call_type, status, duration, start_time, end_time, created_at)
      VALUES 
        ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
      RETURNING *
    `;

        const result = await pool.query(query, [
            callId,
            callerId,
            receiverId,
            callType,
            status,
            duration,
            startTime,
            endTime
        ]);

        console.log(`✅ [CALL_HISTORY] Saved: ${callType} call from ${callerId} to ${receiverId} - ${status}`);
        return result.rows[0];
    } catch (error) {
        console.error('❌ [CALL_HISTORY] Error saving:', error);
        throw error;
    }
}

/**
 * Lấy lịch sử cuộc gọi của user
 */
async function getUserCallHistory(userId, limit = 50) {
    try {
        const query = `
      SELECT 
        ch.*,
        caller.email as caller_email,
        caller.avatar_url as caller_avatar,
        cp.full_name as caller_name,
        receiver.email as receiver_email,
        receiver.avatar_url as receiver_avatar,
        rp.full_name as receiver_name
      FROM call_history ch
      LEFT JOIN users caller ON ch.caller_id = caller.id
      LEFT JOIN profiles cp ON caller.id = cp.user_id
      LEFT JOIN users receiver ON ch.receiver_id = receiver.id
      LEFT JOIN profiles rp ON receiver.id = rp.user_id
      WHERE ch.caller_id = $1 OR ch.receiver_id = $1
      ORDER BY ch.created_at DESC
      LIMIT $2
    `;

        const result = await pool.query(query, [userId, limit]);
        return result.rows;
    } catch (error) {
        console.error('❌ [CALL_HISTORY] Error fetching history:', error);
        throw error;
    }
}

/**
 * Cập nhật trạng thái cuộc gọi
 */
async function updateCallStatus(callId, status, duration = null, endTime = null) {
    try {
        const query = `
      UPDATE call_history 
      SET 
        status = $2,
        duration = COALESCE($3, duration),
        end_time = COALESCE($4, end_time),
        updated_at = NOW()
      WHERE call_id = $1
      RETURNING *
    `;

        const result = await pool.query(query, [callId, status, duration, endTime]);

        if (result.rows.length > 0) {
            console.log(`✅ [CALL_HISTORY] Updated call ${callId}: ${status}`);
            return result.rows[0];
        }

        return null;
    } catch (error) {
        console.error('❌ [CALL_HISTORY] Error updating status:', error);
        throw error;
    }
}

/**
 * Lấy thống kê cuộc gọi của user
 */
async function getCallStatistics(userId) {
    try {
        const query = `
      SELECT 
        COUNT(*) as total_calls,
        COUNT(*) FILTER (WHERE status = 'completed') as completed_calls,
        COUNT(*) FILTER (WHERE status = 'declined') as declined_calls,
        COUNT(*) FILTER (WHERE status = 'missed') as missed_calls,
        COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled_calls,
        COUNT(*) FILTER (WHERE call_type = 'video') as video_calls,
        COUNT(*) FILTER (WHERE call_type = 'audio') as audio_calls,
        SUM(duration) FILTER (WHERE status = 'completed') as total_duration
      FROM call_history
      WHERE caller_id = $1 OR receiver_id = $1
    `;

        const result = await pool.query(query, [userId]);
        return result.rows[0];
    } catch (error) {
        console.error('❌ [CALL_HISTORY] Error fetching statistics:', error);
        throw error;
    }
}

module.exports = {
    saveCallHistory,
    getUserCallHistory,
    updateCallStatus,
    getCallStatistics
};
