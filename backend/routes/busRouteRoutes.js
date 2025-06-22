const express = require('express');
const router = express.Router();
const busRouteController = require('../controllers/busRouteController');
const { adminAuth } = require('../middlewares/adminAuth');

// GET /api/routes/stats - Get route statistics (admin only)
router.get('/stats', adminAuth, busRouteController.getRouteStats);

// GET /api/routes - Get all routes with pagination and filters (admin only)
router.get('/', adminAuth, busRouteController.getAllRoutes);

// GET /api/routes/:id - Get single route by ID (admin only)
router.get('/:id', adminAuth, busRouteController.getRouteById);

// POST /api/routes - Create new route (admin only)
router.post('/', adminAuth, busRouteController.createRoute);

// PUT /api/routes/:id - Update route (admin only)
router.put('/:id', adminAuth, busRouteController.updateRoute);

// DELETE /api/routes/:id - Delete route (admin only)
router.delete('/:id', adminAuth, busRouteController.deleteRoute);

module.exports = router;
