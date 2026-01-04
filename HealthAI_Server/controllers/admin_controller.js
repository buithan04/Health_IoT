// controllers/admin_controller.js
const adminService = require('../services/admin_service');

/**
 * Lấy thống kê dashboard
 */
const getDashboardStats = async (req, res) => {
    try {
        const stats = await adminService.getDashboardStats();
        res.json({
            success: true,
            stats
        });
    } catch (error) {
        console.error('Error in getDashboardStats:', error);
        res.status(500).json({
            success: false,
            error: 'Lỗi lấy thống kê'
        });
    }
};

/**
 * Lấy hoạt động gần đây
 */
const getRecentActivities = async (req, res) => {
    try {
        const limit = parseInt(req.query.limit) || 20;
        const activities = await adminService.getRecentActivities(limit);
        res.json({
            success: true,
            activities
        });
    } catch (error) {
        console.error('Error in getRecentActivities:', error);
        res.status(500).json({
            success: false,
            error: 'Lỗi lấy hoạt động'
        });
    }
};

/**
 * Lấy danh sách người dùng
 */
const getAllUsers = async (req, res) => {
    try {
        const filters = {
            role: req.query.role,
            isVerified: req.query.isVerified === 'true' ? true : req.query.isVerified === 'false' ? false : undefined,
            search: req.query.search
        };

        const users = await adminService.getAllUsers(filters);
        res.json({ users });
    } catch (error) {
        console.error('Error in getAllUsers:', error);
        res.status(500).json({ error: 'Lỗi lấy danh sách người dùng' });
    }
};

/**
 * Lấy thông tin một người dùng
 */
const getUserById = async (req, res) => {
    try {
        const userId = req.params.id;
        const users = await adminService.getAllUsers({ search: '' });
        const user = users.find(u => u.id === parseInt(userId));

        if (!user) {
            return res.status(404).json({ error: 'Không tìm thấy người dùng' });
        }

        res.json(user);
    } catch (error) {
        console.error('Error in getUserById:', error);
        res.status(500).json({ error: 'Lỗi lấy thông tin người dùng' });
    }
};

/**
 * Cập nhật người dùng
 */
const createUser = async (req, res) => {
    try {
        const userData = req.body;
        const newUser = await adminService.createUser(userData);
        res.status(201).json({
            message: 'Tạo người dùng thành công',
            user: newUser
        });
    } catch (error) {
        console.error('Error in createUser:', error);
        if (error.message.includes('Email đã tồn tại')) {
            return res.status(400).json({ error: error.message });
        }
        res.status(500).json({ error: 'Lỗi tạo người dùng' });
    }
};

/**
 * Cập nhật người dùng
 */
const updateUser = async (req, res) => {
    try {
        const userId = req.params.id;
        const userData = req.body;

        await adminService.updateUser(userId, userData);
        res.json({ message: 'Cập nhật người dùng thành công' });
    } catch (error) {
        console.error('Error in updateUser:', error);
        res.status(500).json({ error: 'Lỗi cập nhật người dùng' });
    }
};

/**
 * Xóa người dùng
 */
const deleteUser = async (req, res) => {
    try {
        const userId = req.params.id;

        // Không cho xóa chính mình
        if (parseInt(userId) === req.user.id) {
            return res.status(400).json({ error: 'Không thể xóa tài khoản của chính bạn' });
        }

        await adminService.deleteUser(userId);
        res.json({ message: 'Xóa người dùng thành công' });
    } catch (error) {
        console.error('Error in deleteUser:', error);

        if (error.statusCode) {
            return res.status(error.statusCode).json({ error: error.message });
        }

        res.status(500).json({ error: 'Lỗi xóa người dùng' });
    }
};

/**
 * Lấy danh sách bác sĩ
 */
const getAllDoctors = async (req, res) => {
    try {
        const doctors = await adminService.getAllDoctors();
        res.json({ doctors });
    } catch (error) {
        console.error('Error in getAllDoctors:', error);
        res.status(500).json({ error: 'Lỗi lấy danh sách bác sĩ' });
    }
};

/**
 * Lấy danh sách lịch hẹn
 */
const getAllAppointments = async (req, res) => {
    try {
        const filters = {
            status: req.query.status,
            date: req.query.date
        };

        const appointments = await adminService.getAllAppointments(filters);
        res.json({ appointments });
    } catch (error) {
        console.error('Error in getAllAppointments:', error);
        res.status(500).json({ error: 'Lỗi lấy danh sách lịch hẹn' });
    }
};

/**
 * Lấy danh sách đơn thuốc
 */
const getAllPrescriptions = async (req, res) => {
    try {
        const prescriptions = await adminService.getAllPrescriptions();
        res.json({ prescriptions });
    } catch (error) {
        console.error('Error in getAllPrescriptions:', error);
        res.status(500).json({ error: 'Lỗi lấy danh sách đơn thuốc' });
    }
};

/**
 * ===== MEDICATION MANAGEMENT =====
 */

/**
 * Lấy danh sách thuốc
 */
const getAllMedications = async (req, res) => {
    try {
        const filters = {
            category: req.query.category,
            search: req.query.search
        };

        const medications = await adminService.getAllMedications(filters);
        res.json({ medications });
    } catch (error) {
        console.error('Error in getAllMedications:', error);
        res.status(500).json({ error: 'Lỗi lấy danh sách thuốc' });
    }
};

/**
 * Lấy thông tin thuốc theo ID
 */
const getMedicationById = async (req, res) => {
    try {
        const medication = await adminService.getMedicationById(req.params.id);
        res.json(medication);
    } catch (error) {
        console.error('Error in getMedicationById:', error);
        res.status(404).json({ error: 'Không tìm thấy thuốc' });
    }
};

/**
 * Tạo thuốc mới
 */
const createMedication = async (req, res) => {
    try {
        const medication = await adminService.createMedication(req.body);
        res.status(201).json(medication);
    } catch (error) {
        console.error('Error in createMedication:', error);
        res.status(500).json({ error: 'Lỗi tạo thuốc mới' });
    }
};

/**
 * Cập nhật thuốc
 */
const updateMedication = async (req, res) => {
    try {
        const medication = await adminService.updateMedication(req.params.id, req.body);
        res.json(medication);
    } catch (error) {
        console.error('Error in updateMedication:', error);
        res.status(500).json({ error: 'Lỗi cập nhật thuốc' });
    }
};

/**
 * Xóa thuốc
 */
const deleteMedication = async (req, res) => {
    try {
        await adminService.deleteMedication(req.params.id);
        res.json({ success: true, message: 'Xóa thuốc thành công' });
    } catch (error) {
        console.error('Error in deleteMedication:', error);
        res.status(500).json({ error: 'Lỗi xóa thuốc' });
    }
};

/**
 * Import thuốc từ Excel
 */
const importMedications = async (req, res) => {
    try {
        const { medications } = req.body;

        if (!medications || !Array.isArray(medications)) {
            return res.status(400).json({ error: 'Dữ liệu không hợp lệ' });
        }

        const result = await adminService.importMedications(medications);
        res.json(result);
    } catch (error) {
        console.error('Error in importMedications:', error);
        res.status(500).json({ error: 'Lỗi import thuốc' });
    }
};

/**
 * Lấy danh sách danh mục thuốc
 */
const getMedicationCategories = async (req, res) => {
    try {
        const categories = await adminService.getMedicationCategories();
        res.json({ categories });
    } catch (error) {
        console.error('Error in getMedicationCategories:', error);
        res.status(500).json({ error: 'Lỗi lấy danh mục thuốc' });
    }
};

/**
 * Lấy danh sách nhà sản xuất
 */
const getManufacturers = async (req, res) => {
    try {
        const manufacturers = await adminService.getManufacturers();
        res.json({ manufacturers });
    } catch (error) {
        console.error('Error in getManufacturers:', error);
        res.status(500).json({ error: 'Lỗi lấy danh sách nhà sản xuất' });
    }
};

/**
 * Lấy danh sách hoạt chất
 */
const getActiveIngredients = async (req, res) => {
    try {
        const activeIngredients = await adminService.getActiveIngredients();
        res.json({ activeIngredients });
    } catch (error) {
        console.error('Error in getActiveIngredients:', error);
        res.status(500).json({ error: 'Lỗi lấy danh sách hoạt chất' });
    }
};

/**
 * Lấy thông tin bác sĩ theo ID
 */
const getDoctorById = async (req, res) => {
    try {
        const doctor = await adminService.getDoctorById(req.params.id);
        if (!doctor) {
            return res.status(404).json({
                success: false,
                error: 'Không tìm thấy bác sĩ'
            });
        }
        res.json({
            success: true,
            doctor
        });
    } catch (error) {
        console.error('Error in getDoctorById:', error);
        res.status(500).json({
            success: false,
            error: 'Lỗi lấy thông tin bác sĩ'
        });
    }
};

/**
 * Cập nhật bác sĩ
 */
const updateDoctor = async (req, res) => {
    try {
        const doctor = await adminService.updateDoctor(req.params.id, req.body);
        res.json({
            success: true,
            message: 'Cập nhật bác sĩ thành công',
            doctor
        });
    } catch (error) {
        console.error('Error in updateDoctor:', error);
        res.status(500).json({
            success: false,
            error: 'Lỗi cập nhật bác sĩ'
        });
    }
};

/**
 * Xóa bác sĩ
 */
const deleteDoctor = async (req, res) => {
    try {
        await adminService.deleteDoctor(req.params.id);
        res.json({
            success: true,
            message: 'Xóa bác sĩ thành công'
        });
    } catch (error) {
        console.error('Error in deleteDoctor:', error);
        res.status(500).json({
            success: false,
            error: 'Lỗi xóa bác sĩ'
        });
    }
};

/**
 * Lấy danh sách bệnh nhân
 */
const getAllPatients = async (req, res) => {
    try {
        const patients = await adminService.getAllPatients();
        res.json({
            success: true,
            patients
        });
    } catch (error) {
        console.error('Error in getAllPatients:', error);
        res.status(500).json({
            success: false,
            error: 'Lỗi lấy danh sách bệnh nhân'
        });
    }
};

/**
 * Lấy thông tin bệnh nhân theo ID
 */
const getPatientById = async (req, res) => {
    try {
        const patient = await adminService.getPatientById(req.params.id);
        if (!patient) {
            return res.status(404).json({
                success: false,
                error: 'Không tìm thấy bệnh nhân'
            });
        }
        res.json({
            success: true,
            patient
        });
    } catch (error) {
        console.error('Error in getPatientById:', error);
        res.status(500).json({
            success: false,
            error: 'Lỗi lấy thông tin bệnh nhân'
        });
    }
};

/**
 * Tạo bệnh nhân mới
 */
const createPatient = async (req, res) => {
    try {
        const patient = await adminService.createPatient(req.body);
        res.status(201).json({
            success: true,
            patient
        });
    } catch (error) {
        console.error('Error in createPatient:', error);
        res.status(500).json({
            success: false,
            error: error.message || 'Lỗi tạo bệnh nhân'
        });
    }
};

/**
 * Cập nhật thông tin bệnh nhân
 */
const updatePatient = async (req, res) => {
    try {
        const patient = await adminService.updatePatient(req.params.id, req.body);
        res.json({
            success: true,
            patient
        });
    } catch (error) {
        console.error('Error in updatePatient:', error);
        res.status(500).json({
            success: false,
            error: error.message || 'Lỗi cập nhật bệnh nhân'
        });
    }
};

/**
 * Xóa bệnh nhân
 */
const deletePatient = async (req, res) => {
    try {
        await adminService.deletePatient(req.params.id);
        res.json({
            success: true,
            message: 'Xóa bệnh nhân thành công'
        });
    } catch (error) {
        console.error('Error in deletePatient:', error);
        res.status(500).json({
            success: false,
            error: 'Lỗi xóa bệnh nhân'
        });
    }
};

module.exports = {
    getDashboardStats,
    getRecentActivities,
    getAllUsers,
    getUserById,
    createUser,
    updateUser,
    deleteUser,
    getAllDoctors,
    getDoctorById,
    updateDoctor,
    deleteDoctor,
    // Patient management
    getAllPatients,
    getPatientById,
    createPatient,
    updatePatient,
    deletePatient,
    // Appointment & Prescription
    getAllAppointments,
    getAllPrescriptions,
    // Medication management
    getAllMedications,
    getMedicationById,
    createMedication,
    updateMedication,
    deleteMedication,
    importMedications,
    getMedicationCategories,
    getManufacturers,
    getActiveIngredients
};
