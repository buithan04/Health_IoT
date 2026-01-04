-- Migration: Create call_history table
-- Description: Lưu lịch sử cuộc gọi video/audio

CREATE TABLE IF NOT EXISTS call_history (
    id SERIAL PRIMARY KEY,
    call_id VARCHAR(255) NOT NULL UNIQUE,
    caller_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    call_type VARCHAR(20) NOT NULL CHECK (call_type IN ('video', 'audio')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('calling', 'connected', 'completed', 'declined', 'missed', 'cancelled')),
    duration INTEGER DEFAULT 0, -- Thời lượng cuộc gọi (giây)
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_call_history_caller ON call_history(caller_id);
CREATE INDEX IF NOT EXISTS idx_call_history_receiver ON call_history(receiver_id);
CREATE INDEX IF NOT EXISTS idx_call_history_created ON call_history(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_call_history_call_id ON call_history(call_id);

-- Comments
COMMENT ON TABLE call_history IS 'Lịch sử cuộc gọi video/audio';
COMMENT ON COLUMN call_history.call_id IS 'ID duy nhất của cuộc gọi';
COMMENT ON COLUMN call_history.caller_id IS 'ID người gọi';
COMMENT ON COLUMN call_history.receiver_id IS 'ID người nhận';
COMMENT ON COLUMN call_history.call_type IS 'Loại cuộc gọi: video hoặc audio';
COMMENT ON COLUMN call_history.status IS 'Trạng thái: calling, connected, completed, declined, missed, cancelled';
COMMENT ON COLUMN call_history.duration IS 'Thời lượng cuộc gọi (giây)';
COMMENT ON COLUMN call_history.start_time IS 'Thời gian bắt đầu cuộc gọi';
COMMENT ON COLUMN call_history.end_time IS 'Thời gian kết thúc cuộc gọi';
