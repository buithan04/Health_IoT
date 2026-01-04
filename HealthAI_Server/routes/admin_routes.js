// routes/admin_routes.js
const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin_controller');
const { checkAdminRole } = require('../middleware/admin_middleware');

// Áp dụng middleware checkAdminRole cho tất cả routes
router.use(checkAdminRole);

// Dashboard endpoints
router.get('/dashboard/stats', adminController.getDashboardStats);
router.get('/dashboard/activities', adminController.getRecentActivities);

// Legacy endpoints (for backward compatibility)
router.get('/stats', adminController.getDashboardStats);
router.get('/recent-activities', adminController.getRecentActivities);

// User management
router.get('/users', adminController.getAllUsers);
router.get('/users/:id', adminController.getUserById);
router.post('/users', adminController.createUser);
router.put('/users/:id', adminController.updateUser);
router.delete('/users/:id', adminController.deleteUser);

// Doctor management
router.get('/doctors', adminController.getAllDoctors);
router.get('/doctors/:id', adminController.getDoctorById);
router.put('/doctors/:id', adminController.updateDoctor);
router.delete('/doctors/:id', adminController.deleteDoctor);

// Patient management
router.get('/patients', adminController.getAllPatients);
router.get('/patients/:id', adminController.getPatientById);
router.post('/patients', adminController.createPatient);
router.put('/patients/:id', adminController.updatePatient);
router.delete('/patients/:id', adminController.deletePatient);

// Appointment management
router.get('/appointments', adminController.getAllAppointments);

// Prescription management
router.get('/prescriptions', adminController.getAllPrescriptions);

// Medication management
router.get('/medications', adminController.getAllMedications);
router.get('/medication-categories', adminController.getMedicationCategories);
router.get('/medications/categories', adminController.getMedicationCategories); // Alternative endpoint
router.get('/manufacturers', adminController.getManufacturers);
router.get('/active-ingredients', adminController.getActiveIngredients);
router.post('/medications/import', adminController.importMedications);
router.get('/medications/:id', adminController.getMedicationById);
router.post('/medications', adminController.createMedication);
router.put('/medications/:id', adminController.updateMedication);
router.delete('/medications/:id', adminController.deleteMedication);

module.exports = router;
