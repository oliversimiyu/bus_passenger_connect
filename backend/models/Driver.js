const mongoose = require('mongoose');

const driverSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  idNumber: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  licensePlate: {
    type: String,
    required: true,
    trim: true
  },
  busCompany: {
    type: String,
    required: true,
    trim: true
  },
  age: {
    type: Number,
    required: true,
    min: 18,
    max: 70
  },
  phone: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    trim: true,
    lowercase: true
  },
  status: {
    type: String,
    enum: ['active', 'inactive', 'suspended'],
    default: 'active'
  },
  licenseNumber: {
    type: String,
    required: true,
    trim: true
  },
  experienceYears: {
    type: Number,
    default: 0
  },
  qrCode: {
    type: String,
    unique: true,
    sparse: true // Allows multiple documents with null/undefined values
  },
  password: {
    type: String,
    select: false // Don't include password in queries by default
  },
  authToken: {
    type: String,
    select: false
  },
  tokenExpiry: {
    type: Date,
    select: false
  },
  lastLogin: {
    type: Date
  },
  isAccountActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Create indexes for better query performance
driverSchema.index({ idNumber: 1 });
driverSchema.index({ licensePlate: 1 });
driverSchema.index({ busCompany: 1 });
driverSchema.index({ status: 1 });

module.exports = mongoose.model('Driver', driverSchema);
