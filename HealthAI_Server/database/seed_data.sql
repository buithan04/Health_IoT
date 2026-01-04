-- ====================================================================
-- SEED DATA - DATABASE INITIAL DATA
-- File này chứa tất cả dữ liệu khởi tạo cho database
-- ====================================================================

-- Bắt đầu transaction
BEGIN;

-- ====================================================================
-- CLEAR EXISTING DATA - Xóa tất cả dữ liệu cũ trước khi seed
-- ====================================================================
TRUNCATE TABLE 
    medication_ingredients, prescription_items, prescriptions,
    medications, medication_categories, manufacturers, active_ingredients,
    appointments, appointment_types, health_records, ecg_readings, ai_diagnoses,
    mqtt_health_data, medical_attachments, messages, conversations, participants,
    notifications, medication_reminders, articles, doctor_reviews, doctor_time_off,
    doctor_notes, doctor_schedules, patient_thresholds, patient_health_info,
    doctor_professional_info, profiles, users
RESTART IDENTITY CASCADE;

-- ====================================================================
-- SEED USERS (Admin, Doctors, Patients)
-- ====================================================================

-- Admin user (id: 1) - than.95.cvan@gmail.com / admin123
INSERT INTO users (id, email, password, role, is_verified, created_at) OVERRIDING SYSTEM VALUE VALUES
(1, 'than.95.cvan@gmail.com', '$2b$10$EJHqII/yOJw7HOnMfYMif.X0HHiBZIduUoQn88BZjNhlltPgtrYVW', 'admin', TRUE, NOW())
ON CONFLICT (email) DO UPDATE SET 
    password = EXCLUDED.password,
    role = EXCLUDED.role,
    is_verified = EXCLUDED.is_verified;

-- Doctor users (id: 2-8)
INSERT INTO users (id, email, password, role, is_verified, created_at) OVERRIDING SYSTEM VALUE VALUES
(2, 'doctor1@healthai.com', '$2b$10$EJHqII/yOJw7HOnMfYMif.X0HHiBZIduUoQn88BZjNhlltPgtrYVW', 'doctor', TRUE, NOW()),
(3, 'doctor2@healthai.com', '$2b$10$EJHqII/yOJw7HOnMfYMif.X0HHiBZIduUoQn88BZjNhlltPgtrYVW', 'doctor', TRUE, NOW()),
(4, 'doctor3@healthai.com', '$2b$10$EJHqII/yOJw7HOnMfYMif.X0HHiBZIduUoQn88BZjNhlltPgtrYVW', 'doctor', TRUE, NOW()),
(5, 'doctor4@healthai.com', '$2b$10$EJHqII/yOJw7HOnMfYMif.X0HHiBZIduUoQn88BZjNhlltPgtrYVW', 'doctor', TRUE, NOW()),
(6, 'doctor5@healthai.com', '$2b$10$EJHqII/yOJw7HOnMfYMif.X0HHiBZIduUoQn88BZjNhlltPgtrYVW', 'doctor', TRUE, NOW()),
(7, 'doctor6@healthai.com', '$2b$10$EJHqII/yOJw7HOnMfYMif.X0HHiBZIduUoQn88BZjNhlltPgtrYVW', 'doctor', TRUE, NOW()),
(8, 'doctor7@healthai.com', '$2b$10$EJHqII/yOJw7HOnMfYMif.X0HHiBZIduUoQn88BZjNhlltPgtrYVW', 'doctor', TRUE, NOW())
ON CONFLICT (email) DO NOTHING;

-- Patient user (id: 9)
INSERT INTO users (id, email, password, role, is_verified, created_at) OVERRIDING SYSTEM VALUE VALUES
(9, 'patient@healthai.com', '$2b$10$EJHqII/yOJw7HOnMfYMif.X0HHiBZIduUoQn88BZjNhlltPgtrYVW', 'patient', TRUE, NOW())
ON CONFLICT (email) DO NOTHING;

-- Reset sequence
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));

-- ====================================================================
-- SEED PROFILES
-- ====================================================================

INSERT INTO profiles (user_id, full_name, phone_number, date_of_birth, gender, address) VALUES
(1, 'Quản trị viên', '0901234567', '1990-01-01', 'Nam', 'Hà Nội, Việt Nam'),
(2, 'BS. Nguyễn Văn An', '0912345671', '1980-05-15', 'Nam', 'Hà Nội'),
(3, 'BS. Trần Thị Bình', '0912345672', '1985-08-20', 'Nữ', 'TP.HCM'),
(4, 'BS. Lê Văn Cường', '0912345673', '1978-03-10', 'Nam', 'Đà Nẵng'),
(5, 'BS. Phạm Thị Dung', '0912345674', '1988-11-25', 'Nữ', 'Hà Nội'),
(6, 'BS. Hoàng Văn Em', '0912345675', '1982-07-18', 'Nam', 'Cần Thơ'),
(7, 'BS. Đỗ Thị Phương', '0912345676', '1990-02-28', 'Nữ', 'Hải Phòng'),
(8, 'BS. Vũ Văn Giang', '0912345677', '1975-12-05', 'Nam', 'Huế'),
(9, 'Nguyễn Văn Test', '0987654321', '1995-06-15', 'Nam', '123 Nguyễn Trãi, Hà Nội')
ON CONFLICT (user_id) DO NOTHING;

-- ====================================================================
-- SEED DOCTOR PROFESSIONAL INFO
-- ====================================================================

INSERT INTO doctor_professional_info (doctor_id, specialty, hospital_name, years_of_experience, bio, consultation_fee, rating_average, review_count, license_number) VALUES
(2, 'Nội khoa', 'Bệnh viện Bạch Mai', 15, 'Chuyên gia nội khoa với hơn 15 năm kinh nghiệm', 300000, 4.8, 245, 'BS-001234'),
(3, 'Sản phụ khoa', 'Bệnh viện Từ Dũ', 12, 'Bác sĩ sản phụ khoa giàu kinh nghiệm', 350000, 4.9, 189, 'BS-001235'),
(4, 'Nhi khoa', 'Bệnh viện Nhi đồng 1', 18, 'Chuyên khoa nhi với nhiều năm thực hành', 280000, 4.7, 312, 'BS-001236'),
(5, 'Tim mạch', 'Viện Tim Mạch Quốc gia', 10, 'Bác sĩ tim mạch trẻ, năng động', 400000, 4.6, 156, 'BS-001237'),
(6, 'Da liễu', 'Bệnh viện Da liễu TP.HCM', 14, 'Chuyên gia da liễu hàng đầu', 320000, 4.8, 203, 'BS-001238'),
(7, 'Tai Mũi Họng', 'Bệnh viện Đa khoa Hà Nội', 8, 'Bác sĩ TMH với kỹ thuật hiện đại', 290000, 4.5, 134, 'BS-001239'),
(8, 'Thần kinh', 'Bệnh viện 115', 20, 'Giáo sư thần kinh học kỳ cựu', 450000, 4.9, 278, 'BS-001240')
ON CONFLICT (doctor_id) DO NOTHING;

-- ====================================================================
-- SEED PATIENT HEALTH INFO
-- ====================================================================

INSERT INTO patient_health_info (patient_id, height, weight, blood_type, allergies, emergency_contact_name, emergency_contact_phone) VALUES
(9, 175, 70, 'A', 'Không', 'Nguyễn Văn B', '0123456789')
ON CONFLICT (patient_id) DO NOTHING;

-- ====================================================================
-- SEED MEDICATION CATEGORIES
-- ====================================================================

INSERT INTO medication_categories (name, description) VALUES
('Giảm đau - Hạ sốt', 'Thuốc giảm đau và hạ sốt'),
('Kháng sinh', 'Thuốc kháng sinh điều trị nhiễm khuẩn'),
('Tim mạch', 'Thuốc điều trị bệnh tim mạch'),
('Tiêu hóa', 'Thuốc điều trị các bệnh về tiêu hóa'),
('Hô hấp', 'Thuốc điều trị bệnh về đường hô hấp'),
('Thần kinh', 'Thuốc điều trị bệnh thần kinh'),
('Da liễu', 'Thuốc điều trị bệnh về da'),
('Vitamin & Khoáng chất', 'Vitamin và các chất bổ sung'),
('Kháng histamin', 'Thuốc chống dị ứng'),
('Corticoid', 'Thuốc chống viêm steroid'),
('Tiểu đường', 'Thuốc điều trị bệnh tiểu đường'),
('Mắt', 'Thuốc nhỏ mắt và điều trị bệnh về mắt'),
('Tai', 'Thuốc nhỏ tai')
ON CONFLICT (name) DO NOTHING;

-- ====================================================================
-- SEED MANUFACTURERS
-- ====================================================================

INSERT INTO manufacturers (name, country) VALUES
('DHG Pharma', 'Việt Nam'),
('Traphaco', 'Việt Nam'),
('Hasan Dermapharm', 'Việt Nam'),
('Imexpharm', 'Việt Nam'),
('Pymepharco', 'Việt Nam'),
('Hau Giang Pharma', 'Việt Nam'),
('Boston Pharma', 'Việt Nam'),
('Abbott', 'Hoa Kỳ'),
('Sanofi', 'Pháp'),
('Domesco', 'Việt Nam'),
('Mediplantex', 'Việt Nam'),
('Stada', 'Đức'),
('Mekophar', 'Việt Nam'),
('Agimexpharm', 'Việt Nam'),
('Novartis', 'Thụy Sĩ'),
('Pfizer', 'Hoa Kỳ'),
('GSK', 'Anh'),
('Roche', 'Thụy Sĩ')
ON CONFLICT (name) DO NOTHING;

-- ====================================================================
-- SEED MEDICATIONS (50 loại thuốc thực tế)
-- ====================================================================

INSERT INTO medications (name, registration_number, category_id, manufacturer_id, unit, usage_route, packing_specification, price, stock, min_stock, is_active) VALUES
('Paracetamol 500mg', 'VD-12345-16', 1, 3, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 2000, 1000, 100, TRUE),
('Amoxicillin 500mg', 'VD-12346-16', 2, 1, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 5000, 800, 100, TRUE),
('Vitamin C 1000mg', 'VD-12347-16', 8, 2, 'Viên', 'Uống', 'Hộp 6 vỉ x 10 viên', 8000, 500, 50, TRUE),
('Ibuprofen 400mg', 'VD-12348-16', 1, 4, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 3500, 750, 100, TRUE),
('Cetirizine 10mg', 'VD-12349-16', 9, 5, 'Viên', 'Uống', 'Hộp 6 vỉ x 10 viên', 2500, 600, 80, TRUE),
('Omeprazole 20mg', 'VD-12350-16', 4, 6, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 4000, 400, 50, TRUE),
('Metformin 500mg', 'VD-12351-16', 11, 7, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 3000, 900, 100, TRUE),
('Atorvastatin 10mg', 'VD-12352-16', 3, 8, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 12000, 300, 50, TRUE),
('Amlodipine 5mg', 'VD-12353-16', 3, 9, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 8000, 450, 60, TRUE),
('Azithromycin 250mg', 'VD-12354-16', 2, 10, 'Viên', 'Uống', 'Hộp 2 vỉ x 3 viên', 15000, 200, 30, TRUE),
('Cephalexin 500mg', 'VD-12355-16', 2, 11, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 7000, 600, 80, TRUE),
('Ciprofloxacin 500mg', 'VD-12356-16', 2, 12, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 9000, 550, 70, TRUE),
('Dexamethasone 0.5mg', 'VD-12357-16', 10, 13, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 2000, 400, 50, TRUE),
('Prednisone 5mg', 'VD-12358-16', 10, 14, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 1800, 350, 50, TRUE),
('Losartan 50mg', 'VD-12359-16', 3, 9, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 6500, 500, 60, TRUE),
('Aspirin 100mg', 'VD-12360-16', 3, 8, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 2500, 800, 100, TRUE),
('Diclofenac 50mg', 'VD-12361-16', 1, 4, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 3000, 600, 80, TRUE),
('Ranitidine 150mg', 'VD-12362-16', 4, 6, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 2800, 550, 70, TRUE),
('Loratadine 10mg', 'VD-12363-16', 9, 5, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 3500, 450, 60, TRUE),
('Salbutamol 4mg', 'VD-12364-16', 5, 17, 'Viên', 'Uống', 'Hộp 6 vỉ x 10 viên', 4500, 350, 50, TRUE),
('Vitamin B Complex', 'VD-12365-16', 8, 2, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 5000, 600, 80, TRUE),
('Calcium + Vitamin D3', 'VD-12366-16', 8, 2, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 7500, 400, 50, TRUE),
('Folic Acid 5mg', 'VD-12367-16', 8, 2, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 2200, 500, 60, TRUE),
('Simvastatin 20mg', 'VD-12368-16', 3, 8, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 9000, 300, 40, TRUE),
('Glimepiride 2mg', 'VD-12369-16', 11, 7, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 8500, 250, 40, TRUE),
('Gliclazide 80mg', 'VD-12370-16', 11, 7, 'Viên', 'Uống', 'Hộp 6 vỉ x 10 viên', 7000, 280, 40, TRUE),
('Bisoprolol 5mg', 'VD-12371-16', 3, 9, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 6000, 320, 50, TRUE),
('Clopidogrel 75mg', 'VD-12372-16', 3, 9, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 15000, 200, 30, TRUE),
('Pantoprazole 40mg', 'VD-12373-16', 4, 6, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 5500, 400, 50, TRUE),
('Esomeprazole 20mg', 'VD-12374-16', 4, 6, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 6500, 350, 50, TRUE),
('Domperidone 10mg', 'VD-12375-16', 4, 10, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 3500, 500, 60, TRUE),
('Loperamide 2mg', 'VD-12376-16', 4, 10, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 2800, 450, 60, TRUE),
('Mebeverine 135mg', 'VD-12377-16', 4, 10, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 8000, 300, 40, TRUE),
('Montelukast 10mg', 'VD-12378-16', 5, 17, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 12000, 250, 30, TRUE),
('Prednisolone 5mg', 'VD-12379-16', 10, 14, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 2500, 400, 50, TRUE),
('Betahistine 16mg', 'VD-12380-16', 6, 9, 'Viên', 'Uống', 'Hộp 6 vỉ x 10 viên', 4500, 350, 50, TRUE),
('Piracetam 800mg', 'VD-12381-16', 6, 13, 'Viên', 'Uống', 'Hộp 6 vỉ x 10 viên', 5500, 300, 40, TRUE),
('Diazepam 5mg', 'VD-12382-16', 6, 13, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 3000, 200, 30, TRUE),
('Meloxicam 7.5mg', 'VD-12383-16', 1, 4, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 4500, 400, 50, TRUE),
('Tramadol 50mg', 'VD-12384-16', 1, 16, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 8000, 150, 30, TRUE),
('Acetylcysteine 200mg', 'VD-12385-16', 5, 17, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 3500, 450, 60, TRUE),
('Bromhexine 8mg', 'VD-12386-16', 5, 17, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 2500, 500, 70, TRUE),
('Dextromethorphan 15mg', 'VD-12387-16', 5, 17, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 3000, 450, 60, TRUE),
('Diphenhydramine 25mg', 'VD-12388-16', 9, 5, 'Viên', 'Uống', 'Hộp 10 vỉ x 10 viên', 2800, 400, 50, TRUE),
('Alprazolam 0.5mg', 'VD-12389-16', 6, 16, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 6000, 180, 30, TRUE),
('Gabapentin 300mg', 'VD-12390-16', 6, 16, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 10000, 200, 30, TRUE),
('Acyclovir 400mg', 'VD-12391-16', 7, 17, 'Viên', 'Uống', 'Hộp 3 vỉ x 10 viên', 6500, 250, 40, TRUE),
('Fluconazole 150mg', 'VD-12392-16', 7, 16, 'Viên', 'Uống', 'Hộp 1 vỉ x 1 viên', 8000, 300, 50, TRUE),
('Levofloxacin 500mg', 'VD-12393-16', 2, 12, 'Viên', 'Uống', 'Hộp 1 vỉ x 5 viên', 12000, 200, 30, TRUE),
('Clarithromycin 500mg', 'VD-12394-16', 2, 8, 'Viên', 'Uống', 'Hộp 1 vỉ x 7 viên', 18000, 150, 25, TRUE)
ON CONFLICT DO NOTHING;

-- Commit transaction
COMMIT;

-- Log success
DO $$
BEGIN
    RAISE NOTICE '✅ Seed data inserted successfully!';
    RAISE NOTICE '📊 Summary:';
    RAISE NOTICE '   - Admin: than.95.cvan@gmail.com (password: admin123)';
    RAISE NOTICE '   - Users: 9 (1 admin, 7 doctors, 1 patient)';
    RAISE NOTICE '   - Medication categories: 13';
    RAISE NOTICE '   - Manufacturers: 18';
    RAISE NOTICE '   - Medications: 50';
END $$;
