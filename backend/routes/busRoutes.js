const express = require('express');
const router = express.Router();
const busController = require('../controllers/busController');
const { protect, authorize } = require('../middlewares/auth');

// Get all buses - public
router.get('/', busController.getAllBuses);

// Get a single bus by ID - public
router.get('/:id', busController.getBusById);

// Protected routes - admin only
router.post(
  '/', 
  protect, 
  authorize('admin'), 
  busController.createBus
);

router.put(
  '/:id', 
  protect, 
  authorize('admin'), 
  busController.updateBus
);

router.delete(
  '/:id', 
  protect, 
  authorize('admin'), 
  busController.deleteBus
);

// Update bus status - for drivers and admins
router.patch(
  '/:id/status', 
  protect, 
  authorize('driver', 'admin'), 
  busController.updateBusStatus
);

module.exports = router;
