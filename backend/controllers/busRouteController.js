const BusRoute = require('../models/BusRoute');

// Get all routes
exports.getAllRoutes = async (req, res) => {
  try {
    const routes = await BusRoute.find({ isActive: true });
    res.status(200).json(routes);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving routes', error: error.message });
  }
};

// Get a single route by ID
exports.getRouteById = async (req, res) => {
  try {
    const route = await BusRoute.findById(req.params.id);
    if (!route) {
      return res.status(404).json({ message: 'Route not found' });
    }
    res.status(200).json(route);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving route', error: error.message });
  }
};

// Create a new route
exports.createRoute = async (req, res) => {
  try {
    const newRoute = new BusRoute(req.body);
    const savedRoute = await newRoute.save();
    res.status(201).json(savedRoute);
  } catch (error) {
    res.status(400).json({ message: 'Error creating route', error: error.message });
  }
};

// Update a route
exports.updateRoute = async (req, res) => {
  try {
    const updatedRoute = await BusRoute.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!updatedRoute) {
      return res.status(404).json({ message: 'Route not found' });
    }
    
    res.status(200).json(updatedRoute);
  } catch (error) {
    res.status(400).json({ message: 'Error updating route', error: error.message });
  }
};

// Delete a route (soft delete by setting isActive to false)
exports.deleteRoute = async (req, res) => {
  try {
    const route = await BusRoute.findByIdAndUpdate(
      req.params.id,
      { isActive: false },
      { new: true }
    );
    
    if (!route) {
      return res.status(404).json({ message: 'Route not found' });
    }
    
    res.status(200).json({ message: 'Route deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting route', error: error.message });
  }
};

// Search routes by name or description
exports.searchRoutes = async (req, res) => {
  try {
    const { query } = req.query;
    
    if (!query) {
      return res.status(400).json({ message: 'Search query is required' });
    }
    
    const routes = await BusRoute.find({
      isActive: true,
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { description: { $regex: query, $options: 'i' } }
      ]
    });
    
    res.status(200).json(routes);
  } catch (error) {
    res.status(500).json({ message: 'Error searching routes', error: error.message });
  }
};

// Get nearby routes based on user's location
exports.getNearbyRoutes = async (req, res) => {
  try {
    const { latitude, longitude, radius = 5 } = req.query;
    
    if (!latitude || !longitude) {
      return res.status(400).json({ message: 'Latitude and longitude are required' });
    }
    
    // Convert string parameters to numbers
    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    const radiusInKm = parseFloat(radius);
    
    if (isNaN(lat) || isNaN(lng) || isNaN(radiusInKm)) {
      return res.status(400).json({ message: 'Invalid location parameters' });
    }
    
    // Find routes with start or end points within the specified radius
    // Using simplified distance calculation for performance
    const routes = await BusRoute.find({
      isActive: true,
      $or: [
        // Check if start location is nearby
        {
          'startLocation.latitude': { $gte: lat - 0.05, $lte: lat + 0.05 },
          'startLocation.longitude': { $gte: lng - 0.05, $lte: lng + 0.05 }
        },
        // Check if end location is nearby
        {
          'endLocation.latitude': { $gte: lat - 0.05, $lte: lat + 0.05 },
          'endLocation.longitude': { $gte: lng - 0.05, $lte: lng + 0.05 }
        },
        // Check if any waypoint is nearby
        {
          'waypoints': {
            $elemMatch: {
              'latitude': { $gte: lat - 0.05, $lte: lat + 0.05 },
              'longitude': { $gte: lng - 0.05, $lte: lng + 0.05 }
            }
          }
        }
      ]
    });
    
    // Calculate actual distances and filter by radius
    const nearbyRoutes = routes.filter(route => {
      // Check start point distance
      const startDistance = calculateDistance(
        lat, lng, 
        route.startLocation.latitude, 
        route.startLocation.longitude
      );
      
      if (startDistance <= radiusInKm) return true;
      
      // Check end point distance
      const endDistance = calculateDistance(
        lat, lng, 
        route.endLocation.latitude, 
        route.endLocation.longitude
      );
      
      if (endDistance <= radiusInKm) return true;
      
      // Check waypoints
      for (const waypoint of route.waypoints) {
        const waypointDistance = calculateDistance(
          lat, lng, 
          waypoint.latitude, 
          waypoint.longitude
        );
        
        if (waypointDistance <= radiusInKm) return true;
      }
      
      return false;
    });
    
    res.status(200).json(nearbyRoutes);
  } catch (error) {
    res.status(500).json({ message: 'Error finding nearby routes', error: error.message });
  }
};

// Get active routes based on recent location updates
exports.getActiveRoutes = async (req, res) => {
  try {
    const { hours = 24 } = req.query;
    const hoursAgo = new Date(Date.now() - hours * 60 * 60 * 1000);
    
    // Get routes that have had recent location updates
    const LocationUpdate = require('../models/LocationUpdate');
    
    const activeUpdates = await LocationUpdate.aggregate([
      {
        $match: {
          timestamp: { $gte: hoursAgo }
        }
      },
      {
        $group: {
          _id: '$routeId',
          busCount: { $addToSet: '$busId' },
          updateCount: { $sum: 1 },
          latestUpdate: { $max: '$timestamp' }
        }
      },
      {
        $project: {
          routeId: '$_id',
          busCount: { $size: '$busCount' },
          updateCount: 1,
          latestUpdate: 1
        }
      }
    ]);
    
    // Get route details for active routes
    const activeRouteIds = activeUpdates.map(update => update.routeId);
    const routes = await BusRoute.find({ _id: { $in: activeRouteIds } });
    
    // Combine route data with activity data
    const activeRoutes = routes.map(route => {
      const activity = activeUpdates.find(update => 
        update.routeId.toString() === route._id.toString()
      );
      
      return {
        ...route.toObject(),
        busCount: activity?.busCount || 0,
        updateCount: activity?.updateCount || 0,
        latestUpdate: activity?.latestUpdate
      };
    });
    
    // Sort by most recent activity
    activeRoutes.sort((a, b) => new Date(b.latestUpdate) - new Date(a.latestUpdate));
    
    res.status(200).json(activeRoutes);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving active routes', error: error.message });
  }
};

// Helper function to calculate distance between two points using Haversine formula
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of the Earth in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  const distance = R * c; // Distance in km
  
  return distance;
}
