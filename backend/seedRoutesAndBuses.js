const mongoose = require('mongoose');
const BusRoute = require('./models/BusRoute');
const Bus = require('./models/Bus');

// Sample routes data
const sampleRoutes = [
    {
        name: 'Downtown Express',
        description: 'Direct route from downtown to business district',
        startLocation: { latitude: 40.7128, longitude: -74.0060 },
        endLocation: { latitude: 40.7589, longitude: -73.9851 },
        distanceInKm: 8.5,
        estimatedTimeInMinutes: 45,
        fareAmount: 3.50,
        isActive: true,
        schedule: [
            { day: 'Monday', departureTime: '06:00' },
            { day: 'Tuesday', departureTime: '06:00' },
            { day: 'Wednesday', departureTime: '06:00' },
            { day: 'Thursday', departureTime: '06:00' },
            { day: 'Friday', departureTime: '06:00' }
        ]
    },
    {
        name: 'University Line',
        description: 'Route connecting university campus to city center',
        startLocation: { latitude: 40.6892, longitude: -74.0445 },
        endLocation: { latitude: 40.7128, longitude: -74.0060 },
        distanceInKm: 6.2,
        estimatedTimeInMinutes: 30,
        fareAmount: 2.75,
        isActive: true,
        schedule: [
            { day: 'Monday', departureTime: '07:00' },
            { day: 'Tuesday', departureTime: '07:00' },
            { day: 'Wednesday', departureTime: '07:00' },
            { day: 'Thursday', departureTime: '07:00' },
            { day: 'Friday', departureTime: '07:00' }
        ]
    },
    {
        name: 'Airport Shuttle',
        description: 'Express service to international airport',
        startLocation: { latitude: 40.7128, longitude: -74.0060 },
        endLocation: { latitude: 40.6413, longitude: -73.7781 },
        distanceInKm: 15.3,
        estimatedTimeInMinutes: 60,
        fareAmount: 8.00,
        isActive: true,
        schedule: [
            { day: 'Monday', departureTime: '05:30' },
            { day: 'Tuesday', departureTime: '05:30' },
            { day: 'Wednesday', departureTime: '05:30' },
            { day: 'Thursday', departureTime: '05:30' },
            { day: 'Friday', departureTime: '05:30' },
            { day: 'Saturday', departureTime: '06:00' },
            { day: 'Sunday', departureTime: '06:00' }
        ]
    },
    {
        name: 'Suburban Route',
        description: 'Connecting suburban areas to main city',
        startLocation: { latitude: 40.8176, longitude: -73.9782 },
        endLocation: { latitude: 40.7128, longitude: -74.0060 },
        distanceInKm: 12.7,
        estimatedTimeInMinutes: 55,
        fareAmount: 4.25,
        isActive: false,
        schedule: []
    }
];

// Sample buses data
const sampleBuses = [
    {
        busNumber: 'BUS-001',
        licenseNumber: 'NYC-1234',
        capacity: 45,
        currentStatus: 'in-service'
    },
    {
        busNumber: 'BUS-002',
        licenseNumber: 'NYC-5678',
        capacity: 40,
        currentStatus: 'in-service'
    },
    {
        busNumber: 'BUS-003',
        licenseNumber: 'NYC-9012',
        capacity: 50,
        currentStatus: 'maintenance'
    },
    {
        busNumber: 'BUS-004',
        licenseNumber: 'NYC-3456',
        capacity: 35,
        currentStatus: 'out-of-service'
    },
    {
        busNumber: 'BUS-005',
        licenseNumber: 'NYC-7890',
        capacity: 42,
        currentStatus: 'in-service'
    }
];

async function seedRoutesAndBuses() {
    try {
        // Connect to MongoDB
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bus_passenger_connect');
        console.log('Connected to MongoDB');

        // Clear existing data
        await BusRoute.deleteMany({});
        await Bus.deleteMany({});
        console.log('Cleared existing routes and buses');

        // Insert sample routes
        const insertedRoutes = await BusRoute.insertMany(sampleRoutes);
        console.log(`Inserted ${insertedRoutes.length} sample routes`);

        // Assign some routes to buses
        const routeIds = insertedRoutes.map(route => route._id);
        sampleBuses[0].currentRouteId = routeIds[0]; // Downtown Express
        sampleBuses[1].currentRouteId = routeIds[1]; // University Line
        sampleBuses[4].currentRouteId = routeIds[2]; // Airport Shuttle

        // Insert sample buses
        const insertedBuses = await Bus.insertMany(sampleBuses);
        console.log(`Inserted ${insertedBuses.length} sample buses`);

        console.log('\nSample data created successfully!');
        console.log('Routes:');
        insertedRoutes.forEach(route => {
            console.log(`- ${route.name}: $${route.fareAmount} (${route.distanceInKm}km)`);
        });
        
        console.log('\nBuses:');
        insertedBuses.forEach(bus => {
            console.log(`- ${bus.busNumber}: ${bus.currentStatus} (${bus.capacity} seats)`);
        });

    } catch (error) {
        console.error('Error seeding data:', error);
    } finally {
        await mongoose.disconnect();
        console.log('Disconnected from MongoDB');
    }
}

// Run the seeding function
if (require.main === module) {
    require('dotenv').config();
    seedRoutesAndBuses();
}

module.exports = { seedRoutesAndBuses };
