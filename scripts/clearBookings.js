const mongoose = require('mongoose');
const Booking = require('../src/models/Booking');
require('dotenv').config();

async function clearAllBookings() {
  try {
    console.log('🚀 Starting to clear all existing bookings...');
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Delete ALL existing bookings
    const deletedCount = await Booking.deleteMany({});
    console.log(`🗑️  Deleted ${deletedCount.deletedCount} existing bookings`);

    console.log('\n🎉 All bookings cleared successfully!');
    console.log('✨ You can now test fresh bookings with the new payment confirmation system\n');

    await mongoose.connection.close();
    console.log('✅ Database connection closed');
    process.exit(0);

  } catch (error) {
    console.error('❌ Error clearing bookings:', error);
    process.exit(1);
  }
}

// Run the cleaner
clearAllBookings();

