const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  password: {
    type: String,
    required: true
  },
  role: {
    type: String,
    enum: ['passenger', 'driver', 'admin'],
    default: 'passenger'
  },
  phoneNumber: {
    type: String,
    trim: true
  },
  profilePicture: {
    type: String
  },
  savedRoutes: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'BusRoute'
  }],
  tripHistory: [{
    routeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'BusRoute'
    },
    startTime: Date,
    endTime: Date,
    fare: Number,
    status: {
      type: String,
      enum: ['completed', 'cancelled', 'in-progress'],
      default: 'in-progress'
    }
  }]
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
