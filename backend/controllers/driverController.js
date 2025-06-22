const Driver = require('../models/Driver');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const QRCode = require('qrcode');
const { v4: uuidv4 } = require('uuid');

// Get all drivers
const getAllDrivers = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    // Build query based on filters
    let query = {};
    
    if (req.query.status) {
      query.status = req.query.status;
    }
    
    if (req.query.busCompany) {
      query.busCompany = { $regex: req.query.busCompany, $options: 'i' };
    }
    
    if (req.query.search) {
      query.$or = [
        { name: { $regex: req.query.search, $options: 'i' } },
        { idNumber: { $regex: req.query.search, $options: 'i' } },
        { licensePlate: { $regex: req.query.search, $options: 'i' } },
        { phone: { $regex: req.query.search, $options: 'i' } }
      ];
    }

    const drivers = await Driver.find(query)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Driver.countDocuments(query);

    res.json({
      drivers,
      currentPage: page,
      totalPages: Math.ceil(total / limit),
      totalDrivers: total
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get driver by ID
const getDriverById = async (req, res) => {
  try {
    const driver = await Driver.findById(req.params.id);
    if (!driver) {
      return res.status(404).json({ error: 'Driver not found' });
    }
    res.json(driver);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Create new driver with automatic account and QR code generation
const createDriver = async (req, res) => {
  try {
    const driverData = req.body;
    
    // Generate unique QR code identifier
    const qrCodeId = uuidv4();
    
    // Generate default password (driver can change later)
    const defaultPassword = `driver${Math.random().toString(36).slice(-6)}`;
    const hashedPassword = await bcrypt.hash(defaultPassword, 10);
    
    // Create QR code data with driver details
    const qrData = {
      type: 'DRIVER_AUTH',
      driverId: qrCodeId,
      name: driverData.name,
      idNumber: driverData.idNumber,
      busCompany: driverData.busCompany,
      licensePlate: driverData.licensePlate,
      timestamp: new Date().toISOString()
    };
    
    // Generate QR code as base64 string
    const qrCodeBase64 = await QRCode.toDataURL(JSON.stringify(qrData), {
      width: 300,
      margin: 2,
      color: {
        dark: '#000000',
        light: '#FFFFFF'
      }
    });
    
    // Create driver with additional fields
    const newDriver = new Driver({
      ...driverData,
      qrCode: qrCodeBase64,
      password: hashedPassword,
      isAccountActive: true
    });
    
    const savedDriver = await newDriver.save();
    
    // Remove password from response
    const driverResponse = savedDriver.toObject();
    delete driverResponse.password;
    
    res.status(201).json({
      success: true,
      message: 'Driver registered successfully with QR code generated',
      driver: driverResponse,
      credentials: {
        temporaryPassword: defaultPassword,
        message: 'Please ask the driver to change this password on first login'
      }
    });
    
  } catch (error) {
    console.error('Error creating driver:', error);
    
    if (error.code === 11000) {
      const field = Object.keys(error.keyPattern)[0];
      return res.status(400).json({
        success: false,
        error: `Driver with this ${field} already exists`
      });
    }
    
    res.status(400).json({
      success: false,
      error: error.message || 'Error creating driver'
    });
  }
};

// Driver authentication for mobile app
const authenticateDriver = async (req, res) => {
  try {
    const { idNumber, password, qrCodeData } = req.body;
    
    let driver;
    
    if (qrCodeData) {
      // Authenticate using QR code
      try {
        const qrData = JSON.parse(qrCodeData);
        if (qrData.type !== 'DRIVER_AUTH') {
          return res.status(400).json({
            success: false,
            message: 'Invalid QR code type'
          });
        }
        
        driver = await Driver.findOne({ 
          idNumber: qrData.idNumber,
          qrCode: { $exists: true } 
        }).select('+password');
        
      } catch (error) {
        return res.status(400).json({
          success: false,
          message: 'Invalid QR code format'
        });
      }
    } else {
      // Traditional login with ID and password
      if (!idNumber || !password) {
        return res.status(400).json({
          success: false,
          message: 'ID number and password are required'
        });
      }
      
      driver = await Driver.findOne({ idNumber }).select('+password');
    }
    
    if (!driver) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }
    
    if (!driver.isAccountActive) {
      return res.status(401).json({
        success: false,
        message: 'Account is deactivated. Please contact administrator.'
      });
    }
    
    // For QR code auth, skip password check
    if (!qrCodeData) {
      const isValidPassword = await bcrypt.compare(password, driver.password);
      if (!isValidPassword) {
        return res.status(401).json({
          success: false,
          message: 'Invalid credentials'
        });
      }
    }
    
    // Generate JWT token
    const token = jwt.sign(
      { 
        id: driver._id,
        idNumber: driver.idNumber,
        type: 'driver'
      },
      process.env.JWT_SECRET || 'default_secret',
      { expiresIn: '7d' }
    );
    
    // Update last login
    driver.lastLogin = new Date();
    driver.authToken = token;
    driver.tokenExpiry = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
    await driver.save();
    
    // Remove sensitive data from response
    const driverResponse = driver.toObject();
    delete driverResponse.password;
    delete driverResponse.authToken;
    
    res.json({
      success: true,
      message: 'Authentication successful',
      driver: driverResponse,
      token,
      expiresIn: '7d'
    });
    
  } catch (error) {
    console.error('Driver authentication error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during authentication'
    });
  }
};

// Change driver password
const changeDriverPassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const driverId = req.user.id; // From JWT middleware
    
    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Current password and new password are required'
      });
    }
    
    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'New password must be at least 6 characters long'
      });
    }
    
    const driver = await Driver.findById(driverId).select('+password');
    if (!driver) {
      return res.status(404).json({
        success: false,
        message: 'Driver not found'
      });
    }
    
    const isValidPassword = await bcrypt.compare(currentPassword, driver.password);
    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }
    
    const hashedNewPassword = await bcrypt.hash(newPassword, 10);
    driver.password = hashedNewPassword;
    await driver.save();
    
    res.json({
      success: true,
      message: 'Password changed successfully'
    });
    
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during password change'
    });
  }
};

// Get driver profile
const getDriverProfile = async (req, res) => {
  try {
    const driverId = req.user.id;
    
    const driver = await Driver.findById(driverId);
    if (!driver) {
      return res.status(404).json({
        success: false,
        message: 'Driver not found'
      });
    }
    
    res.json({
      success: true,
      driver
    });
    
  } catch (error) {
    console.error('Get driver profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// Regenerate QR code for driver
const regenerateQRCode = async (req, res) => {
  try {
    const { id } = req.params;
    
    const driver = await Driver.findById(id);
    if (!driver) {
      return res.status(404).json({
        success: false,
        message: 'Driver not found'
      });
    }
    
    // Generate new QR code data
    const qrData = {
      type: 'DRIVER_AUTH',
      driverId: uuidv4(),
      name: driver.name,
      idNumber: driver.idNumber,
      busCompany: driver.busCompany,
      licensePlate: driver.licensePlate,
      timestamp: new Date().toISOString()
    };
    
    // Generate new QR code
    const qrCodeBase64 = await QRCode.toDataURL(JSON.stringify(qrData), {
      width: 300,
      margin: 2,
      color: {
        dark: '#000000',
        light: '#FFFFFF'
      }
    });
    
    driver.qrCode = qrCodeBase64;
    await driver.save();
    
    res.json({
      success: true,
      message: 'QR code regenerated successfully',
      qrCode: qrCodeBase64
    });
    
  } catch (error) {
    console.error('Regenerate QR code error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// Update driver
const updateDriver = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    // Remove sensitive fields from update data
    delete updateData.qrCode;
    delete updateData.password;
    delete updateData.authToken;
    delete updateData.tokenExpiry;

    const driver = await Driver.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    );

    if (!driver) {
      return res.status(404).json({ error: 'Driver not found' });
    }

    res.json({ driver });
  } catch (error) {
    console.error('Error updating driver:', error);
    res.status(500).json({ error: error.message });
  }
};

// Delete driver
const deleteDriver = async (req, res) => {
  try {
    const { id } = req.params;

    const driver = await Driver.findByIdAndDelete(id);

    if (!driver) {
      return res.status(404).json({ error: 'Driver not found' });
    }

    res.json({ message: 'Driver deleted successfully' });
  } catch (error) {
    console.error('Error deleting driver:', error);
    res.status(500).json({ error: error.message });
  }
};

// Get driver statistics
const getDriverStats = async (req, res) => {
  try {
    const stats = await Driver.aggregate([
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 }
        }
      }
    ]);

    const total = await Driver.countDocuments();
    
    // Format stats for easier frontend consumption
    const formattedStats = {
      total,
      active: 0,
      inactive: 0,
      suspended: 0
    };

    stats.forEach(stat => {
      formattedStats[stat._id] = stat.count;
    });

    // Get company distribution
    const companyStats = await Driver.aggregate([
      {
        $group: {
          _id: '$busCompany',
          count: { $sum: 1 }
        }
      },
      { $sort: { count: -1 } },
      { $limit: 5 }
    ]);

    res.json({
      statusStats: formattedStats,
      companyStats
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  getAllDrivers,
  getDriverById,
  createDriver,
  updateDriver,
  deleteDriver,
  getDriverStats,
  authenticateDriver,
  changeDriverPassword,
  getDriverProfile,
  regenerateQRCode
};
