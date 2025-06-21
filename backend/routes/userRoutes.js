const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { protect, authorize } = require('../middlewares/auth');

// Public routes
router.post('/register', userController.register);
router.post('/login', userController.login);

// Protected routes - require authentication
router.get('/profile', protect, userController.getProfile);
router.put('/profile', protect, userController.updateProfile);
router.post('/routes/save', protect, userController.saveRoute);
router.get('/routes/saved', protect, userController.getSavedRoutes);

// Admin routes
router.get(
  '/all', 
  protect, 
  authorize('admin'), 
  async (req, res) => {
    try {
      const users = await require('../models/User').find().select('-password');
      res.status(200).json(users);
    } catch (error) {
      res.status(500).json({ message: 'Error retrieving users', error: error.message });
    }
  }
);

module.exports = router;
