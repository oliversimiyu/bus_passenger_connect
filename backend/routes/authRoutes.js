const express = require('express');
const router = express.Router();
const {
    login,
    verifyToken,
    logout,
    changePassword
} = require('../controllers/authController');
const { adminAuth } = require('../middlewares/adminAuth');

// POST /api/auth/login - Admin login
router.post('/login', login);

// GET /api/auth/verify - Verify token
router.get('/verify', verifyToken);

// POST /api/auth/logout - Admin logout
router.post('/logout', adminAuth, logout);

// POST /api/auth/change-password - Change password
router.post('/change-password', adminAuth, changePassword);

module.exports = router;
