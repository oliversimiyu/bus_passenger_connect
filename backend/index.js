require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const morgan = require('morgan');
const path = require('path');

// Import routes
const busRouteRoutes = require('./routes/busRouteRoutes');
const userRoutes = require('./routes/userRoutes');
const locationUpdateRoutes = require('./routes/locationUpdateRoutes');
const busRoutes = require('./routes/busRoutes');
const driverRoutes = require('./routes/driverRoutes');
const authRoutes = require('./routes/authRoutes');

// Initialize express app
const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(morgan('dev'));

// Serve static files for admin dashboard
app.use('/admin', express.static(path.join(__dirname, 'public/admin')));

// Redirect /admin to login page by default
app.get('/admin', (req, res) => {
  res.redirect('/admin/login.html');
});

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('MongoDB connection error:', err));

// Routes
app.use('/api/routes', busRouteRoutes);
app.use('/api/users', userRoutes);
app.use('/api/location', locationUpdateRoutes);
app.use('/api/buses', busRoutes);
app.use('/api/drivers', driverRoutes);
app.use('/api/auth', authRoutes);

// Basic route
app.get('/', (req, res) => {
  res.json({ message: 'Bus Passenger Connect API is running' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
