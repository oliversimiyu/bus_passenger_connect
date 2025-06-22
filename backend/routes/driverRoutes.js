const express = require('express');
const router = express.Router();
const {
  getAllDrivers,
  getDriverById,
  createDriver,
  updateDriver,
  deleteDriver,
  getDriverStats,
  authenticateDriver,
  changeDriverPassword,
  getDriverProfile,
  regenerateQRCode
} = require('../controllers/driverController');
const { adminAuth } = require('../middlewares/adminAuth');

// Driver authentication routes (public)
router.post('/auth/login', authenticateDriver);

// Driver profile routes (requires driver auth)
router.get('/profile', authenticateDriver, getDriverProfile);
router.post('/change-password', authenticateDriver, changeDriverPassword);

// Admin routes (requires admin auth)
router.get('/stats', adminAuth, getDriverStats);
router.get('/', adminAuth, getAllDrivers);
router.get('/:id', adminAuth, getDriverById);
router.post('/', adminAuth, createDriver);
router.put('/:id', adminAuth, updateDriver);
router.delete('/:id', adminAuth, deleteDriver);
router.post('/:id/regenerate-qr', adminAuth, regenerateQRCode);

module.exports = router;
