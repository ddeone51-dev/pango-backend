const mongoose = require('mongoose');
const Booking = require('../src/models/Booking');
const User = require('../src/models/User');
require('dotenv').config();

async function fixBookingForMwitaDeone() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Find the booking
    const booking = await Booking.findById('68fe9fafaeb5fcdc89722827');
    if (!booking) {
      console.log('❌ Booking not found');
      return;
    }

    // Find user "Mwita Deone" - try different variations
    let user = await User.findOne({ 
      $or: [
        { 'profile.firstName': 'Mwita', 'profile.lastName': 'Deone' },
        { 'profile.firstName': 'Deone', 'profile.lastName': 'Mwita' },
        { 'profile.firstName': 'Mwita' },
        { 'profile.firstName': 'Deone' },
        { email: { $regex: /mwita/i } },
        { email: { $regex: /deone/i } }
      ]
    });

    if (!user) {
      console.log('❌ User "Mwita Deone" not found');
      console.log('Available users:');
      const allUsers = await User.find({}, 'email profile.firstName profile.lastName');
      allUsers.forEach(u => {
        console.log(`   - ${u.profile?.firstName} ${u.profile?.lastName} (${u.email})`);
      });
      return;
    }

    console.log(`✅ Found user: ${user.profile?.firstName} ${user.profile?.lastName} (${user.email})`);

    // Update booking ownership
    booking.guestId = user._id;
    await booking.save();

    console.log('✅ Booking ownership fixed!');
    console.log(`   Booking ID: ${booking._id}`);
    console.log(`   Guest: ${user.profile?.firstName} ${user.profile?.lastName}`);
    console.log(`   Email: ${user.email}`);
    console.log(`   Status: ${booking.status}`);

    await mongoose.connection.close();
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

fixBookingForMwitaDeone();
