const mongoose = require('mongoose');

const busSchema = new mongoose.Schema({
  busNumber: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  capacity: {
    type: Number,
    required: true
  },
  licenseNumber: {
    type: String,
    required: true,
    unique: true
  },
  currentRouteId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'BusRoute'
  },
  currentStatus: {
    type: String,
    enum: ['in-service', 'out-of-service', 'maintenance'],
    default: 'out-of-service'
  },
  currentLocation: {
    latitude: Number,
    longitude: Number
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

module.exports = mongoose.model('Bus', busSchema);
