-- ====================================================================
-- DATABASE MIGRATIONS - SCHEMA MANAGEMENT
-- File này chứa tất cả migrations để tạo/sửa database schema
-- ====================================================================

-- Bắt đầu transaction
BEGIN;

-- ====================================================================
-- USERS & AUTHENTICATION
-- ====================================================================

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'patient',
    is_verified BOOLEAN DEFAULT FALSE,
    avatar_url TEXT,
    reset_password_token VARCHAR(10),
    reset_password_expires TIMESTAMPTZ,
    fcm_token TEXT,
    verification_token VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS profiles (
    user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(100),
    phone_number VARCHAR(20),
    date_of_birth DATE,
    gender VARCHAR(10),
    address TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- DOCTORS
-- ====================================================================

CREATE TABLE IF NOT EXISTS doctor_professional_info (
    doctor_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    specialty VARCHAR(100),
    hospital_name VARCHAR(150),
    years_of_experience INTEGER,
    bio TEXT,
    consultation_fee NUMERIC(10,2),
    rating_average NUMERIC(3,2) DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    license_number VARCHAR(50),
    education TEXT,
    languages TEXT[],
    clinic_address TEXT,
    clinic_images TEXT[]
);

CREATE TABLE IF NOT EXISTS doctor_schedules (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    day_of_week INTEGER,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS doctor_time_off (
    id SERIAL PRIMARY KEY,
    doctor_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS doctor_notes (
    id SERIAL PRIMARY KEY,
    doctor_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- APPOINTMENTS
-- ====================================================================

CREATE TABLE IF NOT EXISTS appointment_types (
    id SERIAL PRIMARY KEY,
    doctor_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    duration_minutes INTEGER DEFAULT 30,
    price NUMERIC(10,2),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS appointments (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    doctor_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    appointment_date TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    notes TEXT,
    type_id INTEGER REFERENCES appointment_types(id),
    cancellation_reason TEXT,
    is_reviewed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS doctor_reviews (
    id SERIAL PRIMARY KEY,
    doctor_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    patient_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    appointment_id INTEGER REFERENCES appointments(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- PATIENT HEALTH INFO
-- ====================================================================

CREATE TABLE IF NOT EXISTS patient_health_info (
    patient_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    height NUMERIC(5,2),
    weight NUMERIC(5,2),
    blood_type VARCHAR(10),
    medical_history TEXT,
    allergies TEXT,
    insurance_number VARCHAR(50),
    occupation VARCHAR(100),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    lifestyle_info JSONB,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS patient_thresholds (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    metric_type VARCHAR(50) NOT NULL,
    min_val NUMERIC,
    max_val NUMERIC,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- MEDICATIONS
-- ====================================================================

CREATE TABLE IF NOT EXISTS medication_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS manufacturers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) UNIQUE NOT NULL,
    country VARCHAR(100),
    website TEXT
);

CREATE TABLE IF NOT EXISTS active_ingredients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS medications (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    registration_number VARCHAR(50),
    category_id INTEGER REFERENCES medication_categories(id),
    manufacturer_id INTEGER REFERENCES manufacturers(id),
    unit VARCHAR(50) NOT NULL,
    packing_specification VARCHAR(255),
    usage_route VARCHAR(50),
    usage_instruction TEXT,
    price NUMERIC(10,2) DEFAULT 0,
    stock INTEGER DEFAULT 0,
    min_stock INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS medication_ingredients (
    medication_id INTEGER NOT NULL REFERENCES medications(id) ON DELETE CASCADE,
    ingredient_id INTEGER NOT NULL REFERENCES active_ingredients(id),
    content VARCHAR(100),
    PRIMARY KEY (medication_id, ingredient_id)
);

CREATE TABLE IF NOT EXISTS medication_reminders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    medication_name VARCHAR(255) NOT NULL,
    instruction VARCHAR(255),
    reminder_time TIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- PRESCRIPTIONS
-- ====================================================================

CREATE TABLE IF NOT EXISTS prescriptions (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    doctor_id INTEGER NOT NULL REFERENCES users(id),
    diagnosis TEXT,
    notes TEXT,
    chief_complaint TEXT,
    clinical_findings TEXT,
    follow_up_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS prescription_items (
    id SERIAL PRIMARY KEY,
    prescription_id INTEGER NOT NULL REFERENCES prescriptions(id) ON DELETE CASCADE,
    medication_id INTEGER NOT NULL REFERENCES medications(id),
    medication_name_snapshot VARCHAR(255),
    quantity VARCHAR(50) NOT NULL,
    dosage_instruction TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- HEALTH RECORDS & ECG
-- ====================================================================

CREATE TABLE IF NOT EXISTS health_records (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    packet_id VARCHAR(50),
    heart_rate INTEGER,
    spo2 NUMERIC(5,2),
    temperature NUMERIC(5,2),
    sleep_hours NUMERIC(4,2),
    measured_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ecg_readings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(50),
    packet_id VARCHAR(50),
    data_points JSONB,
    sample_rate INTEGER DEFAULT 250,
    duration_seconds INTEGER,
    average_heart_rate INTEGER,
    result VARCHAR(100) DEFAULT 'Chưa có kết luận',
    measured_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ai_diagnoses (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    health_record_id INTEGER REFERENCES health_records(id),
    ecg_reading_id INTEGER REFERENCES ecg_readings(id),
    model_type VARCHAR(20),
    diagnosis_result VARCHAR(255),
    confidence_score NUMERIC(5,4),
    severity_level VARCHAR(20),
    is_alert_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS mqtt_health_data (
    id BIGSERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    topic_name VARCHAR(255) NOT NULL,
    heart_rate INTEGER,
    blood_pressure_systolic INTEGER,
    blood_pressure_diastolic INTEGER,
    temperature NUMERIC(5,2),
    spo2 NUMERIC(5,2),
    steps INTEGER,
    calories INTEGER,
    sleep_hours NUMERIC(4,2),
    device_id VARCHAR(100),
    raw_data JSONB,
    received_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- MEDICAL ATTACHMENTS
-- ====================================================================

CREATE TABLE IF NOT EXISTS medical_attachments (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    uploaded_by INTEGER REFERENCES users(id),
    appointment_id INTEGER REFERENCES appointments(id),
    file_url TEXT NOT NULL,
    file_type VARCHAR(50),
    file_name VARCHAR(255),
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- CONVERSATIONS & MESSAGES
-- ====================================================================

CREATE TABLE IF NOT EXISTS conversations (
    id BIGSERIAL PRIMARY KEY,
    last_message_content TEXT,
    last_message_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS participants (
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (conversation_id, user_id)
);

CREATE TABLE IF NOT EXISTS messages (
    id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text',
    status VARCHAR(20) DEFAULT 'sent',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- NOTIFICATIONS
-- ====================================================================

CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    related_id INTEGER,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- ARTICLES (Health News)
-- ====================================================================

CREATE TABLE IF NOT EXISTS articles (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    content_url TEXT,
    category VARCHAR(100),
    published_at TIMESTAMPTZ,
    source_name VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- INDEXES FOR PERFORMANCE
-- ====================================================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_appointments_patient ON appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_medications_category ON medications(category_id);
CREATE INDEX IF NOT EXISTS idx_medications_name ON medications(name);
CREATE INDEX IF NOT EXISTS idx_prescriptions_patient ON prescriptions(patient_id);
CREATE INDEX IF NOT EXISTS idx_prescriptions_doctor ON prescriptions(doctor_id);
CREATE INDEX IF NOT EXISTS idx_conversations_id ON conversations(id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_health_records_user ON health_records(user_id);
CREATE INDEX IF NOT EXISTS idx_health_records_measured_at ON health_records(measured_at);
CREATE INDEX IF NOT EXISTS idx_ecg_readings_user ON ecg_readings(user_id);

-- ====================================================================
-- CALL HISTORY (Video/Audio Calls)
-- ====================================================================

CREATE TABLE IF NOT EXISTS call_history (
    id SERIAL PRIMARY KEY,
    call_id VARCHAR(255) NOT NULL UNIQUE,
    caller_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    call_type VARCHAR(20) NOT NULL CHECK (call_type IN ('video', 'audio')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('calling', 'connected', 'completed', 'declined', 'missed', 'cancelled')),
    duration INTEGER DEFAULT 0,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for call_history
CREATE INDEX IF NOT EXISTS idx_call_history_caller ON call_history(caller_id);
CREATE INDEX IF NOT EXISTS idx_call_history_receiver ON call_history(receiver_id);
CREATE INDEX IF NOT EXISTS idx_call_history_created ON call_history(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_call_history_call_id ON call_history(call_id);

-- Comments for call_history
COMMENT ON TABLE call_history IS 'Lịch sử cuộc gọi video/audio';
COMMENT ON COLUMN call_history.call_id IS 'ID duy nhất của cuộc gọi';
COMMENT ON COLUMN call_history.caller_id IS 'ID người gọi';
COMMENT ON COLUMN call_history.receiver_id IS 'ID người nhận';
COMMENT ON COLUMN call_history.call_type IS 'Loại cuộc gọi: video hoặc audio';
COMMENT ON COLUMN call_history.status IS 'Trạng thái: calling, connected, completed, declined, missed, cancelled';
COMMENT ON COLUMN call_history.duration IS 'Thời lượng cuộc gọi (giây)';
COMMENT ON COLUMN call_history.start_time IS 'Thời gian bắt đầu cuộc gọi';
COMMENT ON COLUMN call_history.end_time IS 'Thời gian kết thúc cuộc gọi';

-- Commit transaction
COMMIT;

-- Log success
DO $$
BEGIN
    RAISE NOTICE '✅ Database schema migrations completed successfully!';
END $$;
