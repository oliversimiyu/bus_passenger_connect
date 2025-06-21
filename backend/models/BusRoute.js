const mongoose = require('mongoose');

const busRouteSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true
  },
  startLocation: {
    type: {
      latitude: Number,
      longitude: Number
    },
    required: true
  },
  endLocation: {
    type: {
      latitude: Number,
      longitude: Number
    },
    required: true
  },
  waypoints: [
    {
      latitude: Number,
      longitude: Number,
      name: String
    }
  ],
  distanceInKm: {
    type: Number,
    required: true
  },
  estimatedTimeInMinutes: {
    type: Number,
    required: true
  },
  fareAmount: {
    type: Number,
    required: true
  },
  isActive: {
    type: Boolean,
    default: true
  },
  schedule: [
    {
      day: {
        type: String,
        enum: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
      },
      departureTime: String
    }
  ]
}, { timestamps: true });

module.exports = mongoose.model('BusRoute', busRouteSchema);
