const mongoose = require('mongoose');
require('dotenv').config();
const User = require('../src/models/User');

async function updateAdminRole() {
  try {
    console.log('🔧 Updating admin role in production database...');
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    const adminEmail = 'admin@pango.com';

    // Find the admin user
    const admin = await User.findOne({ email: adminEmail });
    
    if (!admin) {
      console.log('❌ Admin user not found!');
      await mongoose.connection.close();
      process.exit(1);
    }

    console.log('📋 Current Admin Details:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('Email:', admin.email);
    console.log('Current Role:', admin.role);
    console.log('Status:', admin.accountStatus);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Update role to admin
    console.log('🔄 Updating role to admin...');
    admin.role = 'admin';
    admin.accountStatus = 'active';
    await admin.save();

    console.log('✅ Role updated successfully!');
    console.log('New role:', admin.role);

    console.log('\n🎉 Admin user is ready!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📧 Email:', adminEmail);
    console.log('🔑 Password: admin123');
    console.log('👑 Role: admin');
    console.log('✅ Status: active');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error updating admin role:', error.message);
    process.exit(1);
  }
}

updateAdminRole();
