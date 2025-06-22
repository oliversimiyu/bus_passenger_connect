const jwt = require('jsonwebtoken');
const Driver = require('../models/Driver');

const JWT_SECRET = process.env.JWT_SECRET || 'default_secret';

// Driver authentication middleware
const driverAuth = async (req, res, next) => {
    try {
        const token = req.headers.authorization?.replace('Bearer ', '');
        
        if (!token) {
            return res.status(401).json({
                success: false,
                message: 'Access denied. No token provided.'
            });
        }

        const decoded = jwt.verify(token, JWT_SECRET);
        
        // Check if this is a driver token
        if (decoded.type !== 'driver') {
            return res.status(403).json({
                success: false,
                message: 'Access denied. Driver privileges required.'
            });
        }

        // Verify driver still exists and is active
        const driver = await Driver.findById(decoded.id);
        if (!driver || !driver.isAccountActive) {
            return res.status(401).json({
                success: false,
                message: 'Invalid token or account deactivated.'
            });
        }

        req.user = {
            id: driver._id,
            idNumber: driver.idNumber,
            type: 'driver'
        };
        
        next();
    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({
                success: false,
                message: 'Token expired. Please login again.'
            });
        }
        
        return res.status(401).json({
            success: false,
            message: 'Invalid token.'
        });
    }
};

module.exports = { driverAuth };
