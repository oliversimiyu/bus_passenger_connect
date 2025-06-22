const Bus = require('../models/Bus');

// Get all buses with pagination and filtering
exports.getAllBuses = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;
    
    // Build query
    let query = {};
    
    // Search functionality
    if (req.query.search) {
      query.$or = [
        { busNumber: { $regex: req.query.search, $options: 'i' } },
        { licenseNumber: { $regex: req.query.search, $options: 'i' } }
      ];
    }
    
    // Status filter
    if (req.query.status) {
      query.currentStatus = req.query.status;
    }
    
    const buses = await Bus.find(query)
      .populate('currentRouteId', 'name description')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);
    
    const total = await Bus.countDocuments(query);
    
    res.status(200).json({
      success: true,
      buses,
      pagination: {
        current: page,
        pages: Math.ceil(total / limit),
        total
      }
    });
  } catch (error) {
    res.status(500).json({ 
      success: false,
      message: 'Error retrieving buses', 
      error: error.message 
    });
  }
};

// Get bus statistics
exports.getBusStats = async (req, res) => {
  try {
    const total = await Bus.countDocuments();
    const inService = await Bus.countDocuments({ currentStatus: 'in-service' });
    const outOfService = await Bus.countDocuments({ currentStatus: 'out-of-service' });
    const maintenance = await Bus.countDocuments({ currentStatus: 'maintenance' });
    const withRoutes = await Bus.countDocuments({ currentRouteId: { $exists: true, $ne: null } });
    
    res.status(200).json({
      success: true,
      stats: {
        total,
        inService,
        outOfService,
        maintenance,
        withRoutes,
        withoutRoutes: total - withRoutes
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error retrieving bus statistics',
      error: error.message
    });
  }
};

// Get a single bus by ID
exports.getBusById = async (req, res) => {
  try {
    const bus = await Bus.findById(req.params.id);
    if (!bus) {
      return res.status(404).json({ message: 'Bus not found' });
    }
    res.status(200).json(bus);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving bus', error: error.message });
  }
};

// Create a new bus
exports.createBus = async (req, res) => {
  try {
    const newBus = new Bus(req.body);
    const savedBus = await newBus.save();
    res.status(201).json(savedBus);
  } catch (error) {
    res.status(400).json({ message: 'Error creating bus', error: error.message });
  }
};

// Update a bus
exports.updateBus = async (req, res) => {
  try {
    const updatedBus = await Bus.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!updatedBus) {
      return res.status(404).json({ message: 'Bus not found' });
    }
    
    res.status(200).json(updatedBus);
  } catch (error) {
    res.status(400).json({ message: 'Error updating bus', error: error.message });
  }
};

// Delete a bus
exports.deleteBus = async (req, res) => {
  try {
    const bus = await Bus.findByIdAndDelete(req.params.id);
    
    if (!bus) {
      return res.status(404).json({ message: 'Bus not found' });
    }
    
    res.status(200).json({ message: 'Bus deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting bus', error: error.message });
  }
};

// Update bus status
exports.updateBusStatus = async (req, res) => {
  try {
    const { status, routeId } = req.body;
    
    if (!status) {
      return res.status(400).json({ message: 'Status is required' });
    }
    
    const updatedBus = await Bus.findByIdAndUpdate(
      req.params.id,
      { 
        currentStatus: status,
        ...(routeId && { currentRouteId: routeId })
      },
      { new: true, runValidators: true }
    );
    
    if (!updatedBus) {
      return res.status(404).json({ message: 'Bus not found' });
    }
    
    res.status(200).json(updatedBus);
  } catch (error) {
    res.status(400).json({ message: 'Error updating bus status', error: error.message });
  }
};
