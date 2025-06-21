const mongoose = require('mongoose');
const dotenv = require('dotenv');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const BusRoute = require('../models/BusRoute');
const Bus = require('../models/Bus');

// Load environment variables
dotenv.config({ path: `${__dirname}/../.env` });

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('MongoDB connected for seeding'))
  .catch(err => {
    console.error('MongoDB connection error:', err);
    process.exit(1);
  });

// Sample data
const users = [
  {
    name: 'Admin User',
    email: 'admin@busconnect.com',
    password: 'admin12345',
    role: 'admin',
    phoneNumber: '+254700000000'
  },
  {
    name: 'Driver One',
    email: 'driver1@busconnect.com',
    password: 'driver12345',
    role: 'driver',
    phoneNumber: '+254700000001'
  },
  {
    name: 'Passenger One',
    email: 'passenger1@example.com',
    password: 'passenger12345',
    role: 'passenger',
    phoneNumber: '+254700000002'
  }
];

const routes = [
  {
    name: 'Nairobi City Express',
    description: 'Express route connecting Westlands to Nairobi CBD',
    startLocation: {
      latitude: -1.2641,
      longitude: 36.8028
    },
    endLocation: {
      latitude: -1.2921,
      longitude: 36.8219
    },
    waypoints: [
      {
        latitude: -1.2747,
        longitude: 36.8085,
        name: 'Parklands'
      },
      {
        latitude: -1.2819,
        longitude: 36.8184,
        name: 'University of Nairobi'
      },
      {
        latitude: -1.2880,
        longitude: 36.8208,
        name: 'Central Park'
      }
    ],
    distanceInKm: 7.8,
    estimatedTimeInMinutes: 35,
    fareAmount: 80,
    schedule: [
      { day: 'Monday', departureTime: '07:00' },
      { day: 'Monday', departureTime: '08:00' },
      { day: 'Monday', departureTime: '17:00' },
      { day: 'Tuesday', departureTime: '07:00' },
      { day: 'Tuesday', departureTime: '08:00' },
      { day: 'Tuesday', departureTime: '17:00' },
      { day: 'Wednesday', departureTime: '07:00' },
      { day: 'Wednesday', departureTime: '08:00' },
      { day: 'Wednesday', departureTime: '17:00' },
      { day: 'Thursday', departureTime: '07:00' },
      { day: 'Thursday', departureTime: '08:00' },
      { day: 'Thursday', departureTime: '17:00' },
      { day: 'Friday', departureTime: '07:00' },
      { day: 'Friday', departureTime: '08:00' },
      { day: 'Friday', departureTime: '17:00' }
    ]
  },
  {
    name: 'Karen - Langata Line',
    description: 'Route connecting Karen and Langata residential areas to the city',
    startLocation: {
      latitude: -1.3278,
      longitude: 36.7437
    },
    endLocation: {
      latitude: -1.2921,
      longitude: 36.8219
    },
    waypoints: [
      {
        latitude: -1.3201,
        longitude: 36.7834,
        name: 'Karen Shopping Center'
      },
      {
        latitude: -1.3233,
        longitude: 36.7953,
        name: 'Hardy'
      },
      {
        latitude: -1.3152,
        longitude: 36.8036,
        name: 'Langata'
      }
    ],
    distanceInKm: 14.2,
    estimatedTimeInMinutes: 55,
    fareAmount: 100,
    schedule: [
      { day: 'Monday', departureTime: '06:30' },
      { day: 'Monday', departureTime: '07:30' },
      { day: 'Monday', departureTime: '17:30' },
      { day: 'Tuesday', departureTime: '06:30' },
      { day: 'Tuesday', departureTime: '07:30' },
      { day: 'Tuesday', departureTime: '17:30' },
      { day: 'Wednesday', departureTime: '06:30' },
      { day: 'Wednesday', departureTime: '07:30' },
      { day: 'Wednesday', departureTime: '17:30' },
      { day: 'Thursday', departureTime: '06:30' },
      { day: 'Thursday', departureTime: '07:30' },
      { day: 'Thursday', departureTime: '17:30' },
      { day: 'Friday', departureTime: '06:30' },
      { day: 'Friday', departureTime: '07:30' },
      { day: 'Friday', departureTime: '17:30' }
    ]
  },
  {
    name: 'Eastlands Connect',
    description: 'Route serving the Eastern suburbs to Nairobi Central',
    startLocation: {
      latitude: -1.2864,
      longitude: 36.8751
    },
    endLocation: {
      latitude: -1.2921,
      longitude: 36.8219
    },
    waypoints: [
      {
        latitude: -1.2832,
        longitude: 36.8588,
        name: 'Buruburu'
      },
      {
        latitude: -1.2909,
        longitude: 36.8461,
        name: 'Gikomba'
      },
      {
        latitude: -1.2917,
        longitude: 36.8322,
        name: 'Muthurwa'
      }
    ],
    distanceInKm: 9.5,
    estimatedTimeInMinutes: 40,
    fareAmount: 70,
    schedule: [
      { day: 'Monday', departureTime: '06:00' },
      { day: 'Monday', departureTime: '07:00' },
      { day: 'Monday', departureTime: '18:00' },
      { day: 'Tuesday', departureTime: '06:00' },
      { day: 'Tuesday', departureTime: '07:00' },
      { day: 'Tuesday', departureTime: '18:00' },
      { day: 'Wednesday', departureTime: '06:00' },
      { day: 'Wednesday', departureTime: '07:00' },
      { day: 'Wednesday', departureTime: '18:00' },
      { day: 'Thursday', departureTime: '06:00' },
      { day: 'Thursday', departureTime: '07:00' },
      { day: 'Thursday', departureTime: '18:00' },
      { day: 'Friday', departureTime: '06:00' },
      { day: 'Friday', departureTime: '07:00' },
      { day: 'Friday', departureTime: '18:00' }
    ]
  }
];

const buses = [
  {
    busNumber: 'KAA-001B',
    capacity: 42,
    licenseNumber: 'KAA001B',
    currentStatus: 'out-of-service'
  },
  {
    busNumber: 'KBB-002C',
    capacity: 35,
    licenseNumber: 'KBB002C',
    currentStatus: 'out-of-service'
  },
  {
    busNumber: 'KCC-003D',
    capacity: 42,
    licenseNumber: 'KCC003D',
    currentStatus: 'out-of-service'
  }
];

// Seed data
const seedData = async () => {
  try {
    // Clear existing data
    await User.deleteMany({});
    await BusRoute.deleteMany({});
    await Bus.deleteMany({});

    console.log('Previous data cleared');

    // Create users with hashed passwords
    const hashedUsers = await Promise.all(
      users.map(async (user) => {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(user.password, salt);
        return { ...user, password: hashedPassword };
      })
    );

    const createdUsers = await User.insertMany(hashedUsers);
    console.log(`${createdUsers.length} users created`);

    // Create routes
    const createdRoutes = await BusRoute.insertMany(routes);
    console.log(`${createdRoutes.length} routes created`);

    // Create buses
    const createdBuses = await Bus.insertMany(buses);
    console.log(`${createdBuses.length} buses created`);

    console.log('Data seeded successfully');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding data:', error);
    process.exit(1);
  }
};

// Run the seed function
seedData();
