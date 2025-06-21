const LocationUpdate = require('../models/LocationUpdate');
const Bus = require('../models/Bus');

// Create a new location update
exports.createLocationUpdate = async (req, res) => {
  try {
    const { busId, routeId, position, speed, heading } = req.body;
    
    // Create new location update
    const newLocationUpdate = new LocationUpdate({
      busId,
      routeId,
      position,
      speed,
      heading,
      timestamp: new Date()
    });
    
    const savedLocationUpdate = await newLocationUpdate.save();
    
    // Update the bus's current location and last updated time
    await Bus.findByIdAndUpdate(busId, {
      currentLocation: position,
      lastUpdated: new Date()
    });
    
    res.status(201).json(savedLocationUpdate);
  } catch (error) {
    res.status(400).json({ message: 'Error creating location update', error: error.message });
  }
};

// Get latest location updates for a specific route
exports.getLocationUpdatesForRoute = async (req, res) => {
  try {
    const { routeId } = req.params;
    
    // Find buses currently on this route
    const buses = await Bus.find({ 
      currentRouteId: routeId,
      currentStatus: 'in-service'
    });
    
    if (!buses || buses.length === 0) {
      return res.status(200).json([]);
    }
    
    const busIds = buses.map(bus => bus._id);
    
    // Get the latest location update for each bus
    const locationUpdates = await Promise.all(
      busIds.map(async (busId) => {
        const latestUpdate = await LocationUpdate.findOne({ 
          busId,
          routeId
        }).sort({ timestamp: -1 });
        
        if (latestUpdate) {
          const bus = buses.find(b => b._id.toString() === busId.toString());
          return {
            ...latestUpdate.toObject(),
            busNumber: bus.busNumber
          };
        }
        return null;
      })
    );
    
    // Filter out nulls
    const filteredUpdates = locationUpdates.filter(update => update !== null);
    
    res.status(200).json(filteredUpdates);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving location updates', error: error.message });
  }
};

// Get location history for a specific bus
exports.getBusLocationHistory = async (req, res) => {
  try {
    const { busId } = req.params;
    const { from, to } = req.query;
    
    let query = { busId };
    
    // Add time range if provided
    if (from || to) {
      query.timestamp = {};
      if (from) query.timestamp.$gte = new Date(from);
      if (to) query.timestamp.$lte = new Date(to);
    }
    
    const locationHistory = await LocationUpdate.find(query)
      .sort({ timestamp: 1 })
      .limit(100); // Limit to prevent too large responses
    
    res.status(200).json(locationHistory);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving location history', error: error.message });
  }
};

// Get most active routes based on recent location updates
exports.getActiveRoutes = async (req, res) => {
  try {
    const { hours = 24 } = req.query;
    const hoursAgo = new Date();
    hoursAgo.setHours(hoursAgo.getHours() - parseInt(hours));
    
    // Aggregate location updates by route to find most active routes
    const activeRoutes = await LocationUpdate.aggregate([
      // Filter for recent updates
      { 
        $match: { 
          timestamp: { $gte: hoursAgo } 
        } 
      },
      // Group by routeId and count updates
      { 
        $group: { 
          _id: "$routeId", 
          updateCount: { $sum: 1 },
          lastUpdate: { $max: "$timestamp" },
          busCount: { $addToSet: "$busId" }
        } 
      },
      // Add bus count
      { 
        $addFields: { 
          busCount: { $size: "$busCount" } 
        } 
      },
      // Sort by update count
      { 
        $sort: { 
          updateCount: -1 
        } 
      },
      // Limit to top 10
      { 
        $limit: 10 
      },
      // Lookup route details
      {
        $lookup: {
          from: "busroutes",
          localField: "_id",
          foreignField: "_id",
          as: "routeDetails"
        }
      },
      // Unwind route details
      {
        $unwind: {
          path: "$routeDetails",
          preserveNullAndEmptyArrays: true
        }
      },
      // Project final result
      {
        $project: {
          routeId: "$_id",
          _id: 0,
          updateCount: 1,
          busCount: 1,
          lastUpdate: 1,
          name: "$routeDetails.name",
          description: "$routeDetails.description",
          startLocation: "$routeDetails.startLocation",
          endLocation: "$routeDetails.endLocation",
          distanceInKm: "$routeDetails.distanceInKm",
          estimatedTimeInMinutes: "$routeDetails.estimatedTimeInMinutes",
          fareAmount: "$routeDetails.fareAmount"
        }
      }
    ]);
    
    res.status(200).json(activeRoutes);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving active routes', error: error.message });
  }
};
