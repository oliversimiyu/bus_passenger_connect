const express = require('express');
const router = express.Router();
const busRouteController = require('../controllers/busRouteController');
const { protect, authorize } = require('../middlewares/auth');

// Public routes - no authentication needed
router.get('/', busRouteController.getAllRoutes);
router.get('/search', busRouteController.searchRoutes);
router.get('/nearby', busRouteController.getNearbyRoutes);
router.get('/active', busRouteController.getActiveRoutes);
router.get('/:id', busRouteController.getRouteById);

// Protected routes - admin only
router.post(
  '/', 
  protect, 
  authorize('admin'), 
  busRouteController.createRoute
);

router.put(
  '/:id', 
  protect, 
  authorize('admin'), 
  busRouteController.updateRoute
);

router.delete(
  '/:id', 
  protect, 
  authorize('admin'), 
  busRouteController.deleteRoute
);

module.exports = router;
