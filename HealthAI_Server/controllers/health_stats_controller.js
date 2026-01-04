// controllers/health_stats_controller.js
// Backend API cho thống kê và theo dõi sức khỏe bệnh nhân

const { pool } = require('../config/db');

/**
 * GET /api/health-stats/:userId
 * Lấy thống kê sức khỏe theo thời gian (day, week, month)
 * Query params: period (day|week|month), type (heartRate|spo2|temperature|all)
 */
const getHealthStats = async (req, res) => {
    const { userId } = req.params;
    const { period = 'day', type = 'all' } = req.query;

    try {
        // Xác định khoảng thời gian
        let interval;
        let groupBy;
        let timeFormat;

        switch (period) {
            case 'day':
                interval = '24 hours';
                groupBy = `DATE_TRUNC('hour', measured_at)`;
                timeFormat = 'HH24:00';
                break;
            case 'week':
                interval = '7 days';
                groupBy = `DATE_TRUNC('day', measured_at)`;
                timeFormat = 'YYYY-MM-DD';
                break;
            case 'month':
                interval = '30 days';
                groupBy = `DATE_TRUNC('day', measured_at)`;
                timeFormat = 'YYYY-MM-DD';
                break;
            default:
                interval = '24 hours';
                groupBy = `DATE_TRUNC('hour', measured_at)`;
                timeFormat = 'HH24:00';
        }

        // Query dữ liệu theo type
        let query;
        let params;

        if (type === 'all') {
            // Lấy tất cả metrics
            query = `
                SELECT 
                    ${groupBy} as time_bucket,
                    TO_CHAR(${groupBy}, '${timeFormat}') as time_label,
                    AVG(heart_rate)::NUMERIC(5,2) as avg_heart_rate,
                    MIN(heart_rate) as min_heart_rate,
                    MAX(heart_rate) as max_heart_rate,
                    AVG(spo2)::NUMERIC(5,2) as avg_spo2,
                    MIN(spo2) as min_spo2,
                    MAX(spo2) as max_spo2,
                    AVG(temperature)::NUMERIC(4,2) as avg_temperature,
                    MIN(temperature) as min_temperature,
                    MAX(temperature) as max_temperature,
                    COUNT(*) as data_points
                FROM health_records
                WHERE user_id = $1
                  AND measured_at >= NOW() - INTERVAL '${interval}'
                GROUP BY ${groupBy}
                ORDER BY time_bucket ASC
            `;
            params = [userId];
        } else {
            // Lấy một metric cụ thể
            const columnMap = {
                heartRate: 'heart_rate',
                spo2: 'spo2',
                temperature: 'temperature'
            };
            const column = columnMap[type];

            if (!column) {
                return res.status(400).json({ error: 'Invalid type parameter' });
            }

            query = `
                SELECT 
                    ${groupBy} as time_bucket,
                    TO_CHAR(${groupBy}, '${timeFormat}') as time_label,
                    AVG(${column})::NUMERIC(5,2) as value,
                    MIN(${column}) as min_value,
                    MAX(${column}) as max_value,
                    COUNT(*) as data_points
                FROM health_records
                WHERE user_id = $1
                  AND measured_at >= NOW() - INTERVAL '${interval}'
                GROUP BY ${groupBy}
                ORDER BY time_bucket ASC
            `;
            params = [userId];
        }

        const result = await pool.query(query, params);

        // Tính toán summary statistics
        let summary = {};
        if (type === 'all') {
            const summaryQuery = `
                SELECT 
                    AVG(heart_rate)::NUMERIC(5,2) as avg_heart_rate,
                    AVG(spo2)::NUMERIC(5,2) as avg_spo2,
                    AVG(temperature)::NUMERIC(4,2) as avg_temperature,
                    MIN(measured_at) as first_reading,
                    MAX(measured_at) as last_reading,
                    COUNT(*) as total_readings
                FROM health_records
                WHERE user_id = $1
                  AND measured_at >= NOW() - INTERVAL '${interval}'
            `;
            const summaryResult = await pool.query(summaryQuery, [userId]);
            summary = summaryResult.rows[0] || {};
        }

        res.json({
            success: true,
            data: result.rows,
            summary,
            period,
            type,
            count: result.rows.length
        });

    } catch (error) {
        console.error('❌ Error fetching health stats:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch health statistics',
            message: error.message
        });
    }
};

/**
 * GET /api/health-stats/:userId/latest
 * Lấy dữ liệu sức khỏe mới nhất
 */
const getLatestHealthData = async (req, res) => {
    const { userId } = req.params;

    try {
        const query = `
            SELECT 
                heart_rate,
                spo2,
                temperature,
                measured_at,
                device_id
            FROM health_records
            WHERE user_id = $1
            ORDER BY measured_at DESC
            LIMIT 1
        `;

        const result = await pool.query(query, [userId]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                error: 'No health data found for this user'
            });
        }

        res.json({
            success: true,
            data: result.rows[0]
        });

    } catch (error) {
        console.error('❌ Error fetching latest health data:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch latest health data',
            message: error.message
        });
    }
};

/**
 * GET /api/health-stats/:userId/trends
 * Lấy xu hướng sức khỏe (tăng/giảm/ổn định)
 */
const getHealthTrends = async (req, res) => {
    const { userId } = req.params;
    const { days = 7 } = req.query;

    try {
        const query = `
            WITH daily_avg AS (
                SELECT 
                    DATE_TRUNC('day', measured_at) as day,
                    AVG(heart_rate) as avg_hr,
                    AVG(spo2) as avg_spo2,
                    AVG(temperature) as avg_temp
                FROM health_records
                WHERE user_id = $1
                  AND measured_at >= NOW() - INTERVAL '${days} days'
                GROUP BY DATE_TRUNC('day', measured_at)
                ORDER BY day ASC
            )
            SELECT 
                day,
                avg_hr::NUMERIC(5,2),
                avg_spo2::NUMERIC(5,2),
                avg_temp::NUMERIC(4,2),
                LAG(avg_hr) OVER (ORDER BY day) as prev_hr,
                LAG(avg_spo2) OVER (ORDER BY day) as prev_spo2,
                LAG(avg_temp) OVER (ORDER BY day) as prev_temp
            FROM daily_avg
        `;

        const result = await pool.query(query, [userId]);

        // Tính trend (increasing, decreasing, stable)
        const trends = result.rows.map(row => {
            const hr_trend = row.prev_hr ?
                (row.avg_hr > row.prev_hr * 1.05 ? 'increasing' :
                    row.avg_hr < row.prev_hr * 0.95 ? 'decreasing' : 'stable') : 'N/A';

            const spo2_trend = row.prev_spo2 ?
                (row.avg_spo2 > row.prev_spo2 * 1.02 ? 'increasing' :
                    row.avg_spo2 < row.prev_spo2 * 0.98 ? 'decreasing' : 'stable') : 'N/A';

            const temp_trend = row.prev_temp ?
                (row.avg_temp > row.prev_temp * 1.01 ? 'increasing' :
                    row.avg_temp < row.prev_temp * 0.99 ? 'decreasing' : 'stable') : 'N/A';

            return {
                day: row.day,
                heart_rate: { value: row.avg_hr, trend: hr_trend },
                spo2: { value: row.avg_spo2, trend: spo2_trend },
                temperature: { value: row.avg_temp, trend: temp_trend }
            };
        });

        res.json({
            success: true,
            data: trends,
            days: parseInt(days)
        });

    } catch (error) {
        console.error('❌ Error fetching health trends:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch health trends',
            message: error.message
        });
    }
};

module.exports = {
    getHealthStats,
    getLatestHealthData,
    getHealthTrends
};
