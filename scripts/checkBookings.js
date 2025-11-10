const mongoose = require('mongoose');
const Booking = require('../src/models/Booking');
require('dotenv').config();

async function checkBookings() {
  try {
    console.log('🔍 Checking bookings in database...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    const count = await Booking.countDocuments();
    console.log(`📊 Total bookings in database: ${count}`);

    if (count > 0) {
      const bookings = await Booking.find().limit(5);
      console.log('\n📋 Sample bookings:');
      bookings.forEach((booking, index) => {
        console.log(`   ${index + 1}. ID: ${booking._id}`);
        console.log(`      Status: ${booking.status}`);
        console.log(`      Created: ${booking.createdAt}`);
        console.log(`      Guest: ${booking.guestDetails?.fullName || 'Unknown'}`);
        console.log('');
      });
    }

    await mongoose.connection.close();
    console.log('✅ Database connection closed');
    process.exit(0);

  } catch (error) {
    console.error('❌ Error checking bookings:', error);
    process.exit(1);
  }
}

checkBookings();

