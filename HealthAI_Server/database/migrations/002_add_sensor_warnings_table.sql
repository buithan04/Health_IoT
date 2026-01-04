-- ====================================================================
-- Migration: Add sensor_warnings table
-- Purpose: Track sensor validation failures for user visibility
-- Created: 2026-01-04
-- ====================================================================

-- Create table for sensor warnings
CREATE TABLE IF NOT EXISTS sensor_warnings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(50),
    warning_type VARCHAR(50) NOT NULL, -- 'vital_signs', 'ecg_signal', 'sensor_error'
    severity VARCHAR(20) DEFAULT 'warning', -- 'info', 'warning', 'error', 'critical'
    message TEXT NOT NULL,
    details TEXT,
    sensor_data JSONB, -- Store problematic sensor readings
    resolved BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_sensor_warnings_user_id ON sensor_warnings(user_id);
CREATE INDEX IF NOT EXISTS idx_sensor_warnings_device_id ON sensor_warnings(device_id);
CREATE INDEX IF NOT EXISTS idx_sensor_warnings_created_at ON sensor_warnings(created_at);
CREATE INDEX IF NOT EXISTS idx_sensor_warnings_resolved ON sensor_warnings(resolved);
CREATE INDEX IF NOT EXISTS idx_sensor_warnings_type_severity ON sensor_warnings(warning_type, severity);

-- Create GIN index for JSONB sensor_data queries
CREATE INDEX IF NOT EXISTS idx_sensor_warnings_sensor_data ON sensor_warnings USING gin(sensor_data);

-- Comment on table
COMMENT ON TABLE sensor_warnings IS 'Stores sensor validation warnings to notify users about data quality issues';
COMMENT ON COLUMN sensor_warnings.warning_type IS 'Type of sensor issue: vital_signs, ecg_signal, sensor_error';
COMMENT ON COLUMN sensor_warnings.severity IS 'Warning severity level: info, warning, error, critical';
COMMENT ON COLUMN sensor_warnings.sensor_data IS 'JSONB containing problematic sensor readings for analysis';
COMMENT ON COLUMN sensor_warnings.resolved IS 'Flag indicating if the sensor issue has been fixed';
