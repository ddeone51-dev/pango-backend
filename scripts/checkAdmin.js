const mongoose = require('mongoose');
require('dotenv').config();
const User = require('../src/models/User');

async function checkAdmin() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    const admin = await User.findOne({ email: 'admin@pango.com' });
    
    if (!admin) {
      console.log('❌ Admin user not found!');
      await mongoose.connection.close();
      process.exit(1);
    }

    console.log('📋 Admin User Details:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('Email:', admin.email);
    console.log('Role:', admin.role);
    console.log('Name:', admin.profile.firstName, admin.profile.lastName);
    console.log('Status:', admin.status);
    console.log('Created:', admin.createdAt);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    if (admin.role !== 'admin') {
      console.log('⚠️  User role is NOT admin. Fixing...');
      admin.role = 'admin';
      await admin.save();
      console.log('✅ Role updated to admin!\n');
    } else {
      console.log('✅ User has admin role!\n');
    }

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

checkAdmin();





