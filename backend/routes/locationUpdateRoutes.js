const express = require('express');
const router = express.Router();
const locationUpdateController = require('../controllers/locationUpdateController');
const { protect, authorize } = require('../middlewares/auth');

// Create a new location update - only for drivers and admins
router.post(
  '/', 
  protect, 
  authorize('driver', 'admin'), 
  locationUpdateController.createLocationUpdate
);

// Get location updates for a specific route - public
router.get(
  '/route/:routeId', 
  locationUpdateController.getLocationUpdatesForRoute
);

// Get most active routes based on recent updates - public
router.get(
  '/active', 
  locationUpdateController.getActiveRoutes
);

// Get location history for a specific bus - admin and drivers only
router.get(
  '/history/:busId', 
  protect, 
  authorize('driver', 'admin'), 
  locationUpdateController.getBusLocationHistory
);

module.exports = router;
