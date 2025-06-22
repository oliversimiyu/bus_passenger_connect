const express = require('express');
const router = express.Router();
const busController = require('../controllers/busController');
const { adminAuth } = require('../middlewares/adminAuth');

// GET /api/buses/stats - Get bus statistics (admin only)
router.get('/stats', adminAuth, busController.getBusStats);

// GET /api/buses - Get all buses with pagination and filters (admin only)
router.get('/', adminAuth, busController.getAllBuses);

// GET /api/buses/:id - Get single bus by ID (admin only)
router.get('/:id', adminAuth, busController.getBusById);

// POST /api/buses - Create new bus (admin only)
router.post('/', adminAuth, busController.createBus);

// PUT /api/buses/:id - Update bus (admin only)
router.put('/:id', adminAuth, busController.updateBus);

// DELETE /api/buses/:id - Delete bus (admin only)
router.delete('/:id', adminAuth, busController.deleteBus);

// PUT /api/buses/:id/status - Update bus status (admin only)
router.put('/:id/status', adminAuth, busController.updateBusStatus);

module.exports = router;
