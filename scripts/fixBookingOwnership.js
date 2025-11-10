const mongoose = require('mongoose');
const Booking = require('../src/models/Booking');
const User = require('../src/models/User');
require('dotenv').config();

async function fixBookingOwnership() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Find the booking
    const booking = await Booking.findById('68fe9fafaeb5fcdc89722827');
    if (!booking) {
      console.log('❌ Booking not found');
      return;
    }

    // Find or create the correct user
    let user = await User.findOne({ email: 'ddeone52@gmail.com' });
    if (!user) {
      console.log('Creating user ddeone52@gmail.com...');
      user = new User({
        email: 'ddeone52@gmail.com',
        password: 'temp123',
        profile: {
          firstName: 'Ddeone',
          lastName: 'Mwita'
        },
        phoneNumber: '+255767310875',
        role: 'guest',
        isEmailVerified: true
      });
      await user.save();
    }

    // Update booking ownership
    booking.guestId = user._id;
    await booking.save();

    console.log('✅ Booking ownership fixed!');
    console.log(`   Booking ID: ${booking._id}`);
    console.log(`   Guest: ${user.email}`);
    console.log(`   Status: ${booking.status}`);

    await mongoose.connection.close();
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

fixBookingOwnership();

