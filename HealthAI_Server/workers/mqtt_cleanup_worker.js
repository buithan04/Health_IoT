// HealthAI_Server/workers/mqtt_cleanup_worker.js
// Worker to cleanup MQTT data older than 1 month
// Runs every day at 2 AM

const cron = require('node-cron');
const mqttService = require('../services/mqtt_service');

class MQTTCleanupWorker {
    constructor() {
        this.isRunning = false;
        this.schedule = '0 2 * * *'; // Every day at 2 AM
    }

    /**
     * Start the cleanup worker
     */
    start() {
        console.log('🚀 Starting MQTT Cleanup Worker...');
        console.log(`📅 Schedule: ${this.schedule} (Every day at 2 AM)`);

        // Schedule daily cleanup
        this.cronJob = cron.schedule(this.schedule, async () => {
            await this.runCleanup();
        });

        console.log('✅ MQTT Cleanup Worker started successfully');
    }

    /**
     * Run cleanup task
     */
    async runCleanup() {
        if (this.isRunning) {
            console.log('⚠️ Cleanup already running, skipping...');
            return;
        }

        try {
            this.isRunning = true;
            console.log('🧹 Running MQTT data cleanup task...');
            console.log(`⏰ Time: ${new Date().toISOString()}`);

            const deletedCount = await mqttService.cleanupOldData();

            console.log(`✅ Cleanup completed successfully`);
            console.log(`📊 Deleted records: ${deletedCount}`);

            // Log to database
            await this.logCleanup(deletedCount);

        } catch (error) {
            console.error('❌ Error during MQTT cleanup:', error);
        } finally {
            this.isRunning = false;
        }
    }

    /**
     * Run cleanup immediately (for manual trigger)
     */
    async runNow() {
        console.log('🚀 Manual cleanup triggered');
        await this.runCleanup();
    }

    /**
     * Log cleanup activity to database
     */
    async logCleanup(deletedCount) {
        try {
            const { pool } = require('../config/db');

            const query = `
                INSERT INTO system_logs (
                    log_type,
                    message,
                    details,
                    created_at
                ) VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
            `;

            await pool.query(query, [
                'mqtt_cleanup',
                'MQTT data cleanup completed',
                JSON.stringify({ deletedCount, timestamp: new Date() })
            ]).catch(() => {
                // Ignore if system_logs table doesn't exist
                console.log('ℹ️ system_logs table not available, skipping log');
            });

        } catch (error) {
            console.error('⚠️ Could not log cleanup activity:', error.message);
        }
    }

    /**
     * Stop the worker
     */
    stop() {
        if (this.cronJob) {
            this.cronJob.stop();
            console.log('⏹️ MQTT Cleanup Worker stopped');
        }
    }

    /**
     * Get worker status
     */
    getStatus() {
        return {
            isRunning: this.isRunning,
            schedule: this.schedule,
            nextRun: this.cronJob && this.cronJob.nextDates ? this.cronJob.nextDates() : null
        };
    }
}

// Create singleton instance
const mqttCleanupWorker = new MQTTCleanupWorker();

module.exports = mqttCleanupWorker;
