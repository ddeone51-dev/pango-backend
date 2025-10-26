const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();
const User = require('../src/models/User');

async function debugAdminLogin() {
  try {
    console.log('🔍 Debugging admin login...');
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    const adminEmail = 'admin@pango.com';
    const testPassword = 'admin123';

    // Find the admin user
    const admin = await User.findOne({ email: adminEmail }).select('+password');
    
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
    console.log('Status:', admin.accountStatus);
    console.log('Created:', admin.createdAt);
    console.log('Password hash exists:', !!admin.password);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Test password matching
    console.log('🔐 Testing password match...');
    const isMatch = await admin.matchPassword(testPassword);
    console.log('Password match result:', isMatch);

    if (!isMatch) {
      console.log('❌ Password does not match!');
      console.log('Resetting password...');
      
      const hashedPassword = await bcrypt.hash(testPassword, 10);
      admin.password = hashedPassword;
      await admin.save();
      
      console.log('✅ Password reset successfully!');
      
      // Test again
      const isMatchAfterReset = await admin.matchPassword(testPassword);
      console.log('Password match after reset:', isMatchAfterReset);
    }

    // Check account status
    if (admin.accountStatus !== 'active') {
      console.log('⚠️  Account status is not active:', admin.accountStatus);
      console.log('Setting account status to active...');
      admin.accountStatus = 'active';
      await admin.save();
      console.log('✅ Account status set to active!');
    }

    console.log('\n🎉 Admin login should work now!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📧 Email:', adminEmail);
    console.log('🔑 Password:', testPassword);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error debugging admin login:', error.message);
    process.exit(1);
  }
}

debugAdminLogin();
