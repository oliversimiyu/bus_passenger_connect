const mongoose = require('mongoose');

const locationUpdateSchema = new mongoose.Schema({
  busId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Bus',
    required: true
  },
  routeId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'BusRoute',
    required: true
  },
  position: {
    latitude: {
      type: Number,
      required: true
    },
    longitude: {
      type: Number,
      required: true
    }
  },
  speed: {
    type: Number,
    default: 0
  },
  heading: {
    type: Number,
    default: 0
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

// Index for efficient queries
locationUpdateSchema.index({ busId: 1, timestamp: -1 });
locationUpdateSchema.index({ routeId: 1, timestamp: -1 });

module.exports = mongoose.model('LocationUpdate', locationUpdateSchema);
