const mongoose = require('mongoose');
const Driver = require('./models/Driver');

// Sample driver data for testing
const sampleDrivers = [
  {
    name: "John Kamau Mwangi",
    idNumber: "32145678",
    licensePlate: "KCA 123A",
    busCompany: "Nairobi City Express",
    age: 35,
    phone: "+254701234567",
    email: "john.kamau@nairobiexpress.co.ke",
    licenseNumber: "DL2019001234",
    experienceYears: 8,
    status: "active"
  },
  {
    name: "Mary Wanjiku Njeri",
    idNumber: "28976543",
    licensePlate: "KBA 456B",
    busCompany: "Karen-Langata Shuttles",
    age: 42,
    phone: "+254712345678",
    email: "mary.wanjiku@karenlangata.co.ke",
    licenseNumber: "DL2017005678",
    experienceYears: 12,
    status: "active"
  },
  {
    name: "David Otieno Ochieng",
    idNumber: "30567890",
    licensePlate: "KBZ 789C",
    busCompany: "Eastlands Connect",
    age: 28,
    phone: "+254723456789",
    email: "david.otieno@eastlandsconnect.co.ke",
    licenseNumber: "DL2020009876",
    experienceYears: 5,
    status: "active"
  },
  {
    name: "Grace Akinyi Ouma",
    idNumber: "33445566",
    licensePlate: "KBP 321D",
    busCompany: "Westlands Express",
    age: 39,
    phone: "+254734567890",
    email: "grace.akinyi@westlandsexpress.co.ke",
    licenseNumber: "DL2018002345",
    experienceYears: 10,
    status: "inactive"
  },
  {
    name: "Peter Kiprotich Bett",
    idNumber: "29887766",
    licensePlate: "KBL 654E",
    busCompany: "Rift Valley Transport",
    age: 45,
    phone: "+254745678901",
    email: "peter.kiprotich@riftvalley.co.ke",
    licenseNumber: "DL2016007890",
    experienceYears: 15,
    status: "suspended"
  }
];

async function seedDrivers() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bus_passenger_connect');
    console.log('Connected to MongoDB');

    // Clear existing drivers
    await Driver.deleteMany({});
    console.log('Cleared existing drivers');

    // Insert sample drivers
    const insertedDrivers = await Driver.insertMany(sampleDrivers);
    console.log(`Inserted ${insertedDrivers.length} sample drivers`);

    // Display summary
    const stats = await Driver.aggregate([
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 }
        }
      }
    ]);

    console.log('\nDriver Statistics:');
    stats.forEach(stat => {
      console.log(`${stat._id}: ${stat.count}`);
    });

    process.exit(0);
  } catch (error) {
    console.error('Error seeding drivers:', error);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  seedDrivers();
}

module.exports = { sampleDrivers, seedDrivers };
