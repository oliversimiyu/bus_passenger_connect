# Bus Passenger Connect - Real-time Backend

This project implements a backend solution for the Bus Passenger Connect Flutter application, replacing static sample data with real-time data storage and retrieval through a Node.js backend with MongoDB.

## Project Structure

```
backend/
  controllers/       # Logic for handling requests
  middlewares/       # Authentication and other middleware
  models/            # MongoDB schemas
  routes/            # API route definitions
  utils/             # Utility functions and scripts
  index.js           # Main server file
  package.json       # Project dependencies
  .env               # Environment configuration
```

## Setup Instructions

### Prerequisites

- Node.js (v14 or later)
- MongoDB (v4.4 or later)
- Flutter (for the mobile app)

### Setting up the Backend

1. Navigate to the backend directory:
   ```
   cd /home/codename/CascadeProjects/bus-passenger-connect/backend
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Make sure MongoDB is running:
   ```
   mongod --dbpath /var/lib/mongodb
   ```

4. Seed the database with initial data:
   ```
   npm run seed
   ```

5. Start the server:
   ```
   npm run dev
   ```

   The server will start on port 5000 (or the port specified in your .env file).

### Running with the Quick Start Script

Alternatively, you can use the included start script:

```
./start.sh
```

This script will install dependencies, ensure MongoDB is running, seed the database, and start the server.

### Connecting the Flutter App

1. Update the API configuration in the Flutter app:
   - For Android emulator: Use `10.0.2.2:5000` as the base URL
   - For physical devices: Use your machine's IP address and port

2. Run the Flutter app with the real backend:
   ```
   cd /home/codename/CascadeProjects/bus-passenger-connect/bus_passenger_connect
   ./run_real.sh
   ```

## API Endpoints

### Authentication
- POST `/api/users/register` - Register a new user
- POST `/api/users/login` - Login and get authentication token
- GET `/api/users/profile` - Get current user profile (requires auth)
- PUT `/api/users/profile` - Update user profile (requires auth)

### Bus Routes
- GET `/api/routes` - Get all active routes
- GET `/api/routes/:id` - Get a specific route
- GET `/api/routes/search?query=example` - Search routes
- POST `/api/routes` - Create a new route (admin only)
- PUT `/api/routes/:id` - Update a route (admin only)
- DELETE `/api/routes/:id` - Delete a route (admin only)

### Bus Management
- GET `/api/buses` - Get all buses
- GET `/api/buses/:id` - Get a specific bus
- POST `/api/buses` - Create a new bus (admin only)
- PUT `/api/buses/:id` - Update a bus (admin only)
- DELETE `/api/buses/:id` - Delete a bus (admin only)
- PATCH `/api/buses/:id/status` - Update bus status (drivers and admin)

### Location Updates
- POST `/api/location` - Create a new location update (drivers and admin)
- GET `/api/location/route/:routeId` - Get location updates for a route
- GET `/api/location/history/:busId` - Get location history for a bus (drivers and admin)

## Default User Accounts

After seeding the database, the following accounts will be available:

- **Admin**
  - Email: admin@busconnect.com
  - Password: admin12345

- **Driver**
  - Email: driver1@busconnect.com
  - Password: driver12345

- **Passenger**
  - Email: passenger1@example.com
  - Password: passenger12345

## Development Notes

- The backend implements JWT authentication with role-based authorization
- All routes for the frontend are stored in MongoDB
- The bus locations are updated in real-time and stored in the database
- The API can be easily extended to add additional features in the future
