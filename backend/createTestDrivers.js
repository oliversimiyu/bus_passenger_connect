const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const QRCode = require('qrcode');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

// Import models
const Driver = require('./models/Driver');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bus_management', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const createTestDrivers = async () => {
  try {
    console.log('Creating test drivers...');

    // Clear existing drivers
    await Driver.deleteMany({});
    console.log('Cleared existing drivers');

    // Test drivers data
    const testDrivers = [
      {
        name: 'John Doe',
        idNumber: '12345678',
        licensePlate: 'ABC123',
        busCompany: 'City Transport',
        age: 35,
        phone: '+254712345678',
        email: 'john.doe@transport.com',
        licenseNumber: 'DL123456',
        experienceYears: 10,
        status: 'active'
      },
      {
        name: 'Jane Smith',
        idNumber: '87654321',
        licensePlate: 'XYZ789',
        busCompany: 'Metro Lines',
        age: 42,
        phone: '+254723456789',
        email: 'jane.smith@metro.com',
        licenseNumber: 'DL789012',
        experienceYears: 15,
        status: 'active'
      },
      {
        name: 'Michael Johnson',
        idNumber: '11223344',
        licensePlate: 'DEF456',
        busCompany: 'Express Transit',
        age: 28,
        phone: '+254734567890',
        email: 'michael.j@express.com',
        licenseNumber: 'DL345678',
        experienceYears: 5,
        status: 'active'
      }
    ];

    for (const driverData of testDrivers) {
      // Generate default password (ID number)
      const defaultPassword = driverData.idNumber;
      const hashedPassword = await bcrypt.hash(defaultPassword, 10);

      // Generate QR code ID
      const qrCodeId = uuidv4();

      // Create QR code data
      const qrData = {
        type: 'DRIVER_AUTH',
        driverId: qrCodeId,
        name: driverData.name,
        idNumber: driverData.idNumber,
        busCompany: driverData.busCompany,
        licensePlate: driverData.licensePlate,
        timestamp: new Date().toISOString()
      };

      // Generate QR code string
      const qrCodeString = await QRCode.toDataURL(JSON.stringify(qrData));

      // Create driver with authentication data
      const driver = new Driver({
        ...driverData,
        password: hashedPassword,
        qrCode: qrCodeString,
        isAccountActive: true,
        createdAt: new Date(),
        updatedAt: new Date()
      });

      await driver.save();
      console.log(`Created driver: ${driver.name} (ID: ${driver.idNumber})`);
      console.log(`  Default password: ${defaultPassword}`);
      console.log(`  QR Code generated: ${qrCodeString.substring(0, 50)}...`);
    }

    console.log('\nTest drivers created successfully!');
    console.log('\nYou can now test driver authentication with:');
    console.log('- ID: 12345678, Password: 12345678 (John Doe)');
    console.log('- ID: 87654321, Password: 87654321 (Jane Smith)');
    console.log('- ID: 11223344, Password: 11223344 (Michael Johnson)');

  } catch (error) {
    console.error('Error creating test drivers:', error);
  } finally {
    mongoose.connection.close();
  }
};

// Run the script
createTestDrivers();
