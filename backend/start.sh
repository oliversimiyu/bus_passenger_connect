#!/bin/bash

# Navigate to the backend directory
cd /home/codename/CascadeProjects/bus-passenger-connect/backend

# Install required dependencies
echo "Installing dependencies..."
npm install bcryptjs jsonwebtoken

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
  echo "Creating .env file..."
  echo "PORT=5000" > .env
  echo "MONGODB_URI=mongodb://localhost:27017/bus_passenger_connect" >> .env
  echo "JWT_SECRET=bus_passenger_connect_secret_key_replace_in_production" >> .env
fi

# Check if MongoDB is running
echo "Checking MongoDB status..."
if docker ps | grep mongodb > /dev/null; then
  echo "MongoDB is running in Docker."
else
  echo "MongoDB is not running. Starting MongoDB in Docker..."
  docker run -d -p 27017:27017 --name mongodb mongo:latest
  
  if [ $? -ne 0 ]; then
    echo "Failed to start MongoDB in Docker. Please start it manually."
    echo "You can start MongoDB with: docker run -d -p 27017:27017 --name mongodb mongo:latest"
    exit 1
  fi
  
  echo "MongoDB started successfully in Docker."
fi

# Seed the database
echo "Seeding the database..."
npm run seed

# Start the server
echo "Starting the server..."
npm run dev
