const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();
const User = require('../src/models/User');

async function detailedDebugAdminLogin() {
  try {
    console.log('🔍 Detailed debugging admin login...');
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
    console.log('Password hash length:', admin.password ? admin.password.length : 0);
    console.log('Password hash preview:', admin.password ? admin.password.substring(0, 20) + '...' : 'null');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Test password matching step by step
    console.log('🔐 Testing password match step by step...');
    console.log('Test password:', testPassword);
    console.log('Test password length:', testPassword.length);
    
    // Test with bcrypt directly
    console.log('\n🧪 Testing with bcrypt directly...');
    const directMatch = await bcrypt.compare(testPassword, admin.password);
    console.log('Direct bcrypt compare result:', directMatch);
    
    // Test with the model method
    console.log('\n🧪 Testing with model method...');
    const modelMatch = await admin.matchPassword(testPassword);
    console.log('Model matchPassword result:', modelMatch);

    // Create a fresh hash and test
    console.log('\n🧪 Creating fresh hash and testing...');
    const freshHash = await bcrypt.hash(testPassword, 10);
    console.log('Fresh hash length:', freshHash.length);
    console.log('Fresh hash preview:', freshHash.substring(0, 20) + '...');
    
    const freshMatch = await bcrypt.compare(testPassword, freshHash);
    console.log('Fresh hash match result:', freshMatch);

    // Update the admin password with fresh hash
    console.log('\n🔄 Updating admin password with fresh hash...');
    admin.password = freshHash;
    await admin.save();
    
    // Test again
    const finalMatch = await admin.matchPassword(testPassword);
    console.log('Final match result:', finalMatch);

    console.log('\n🎉 Admin login debugging complete!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📧 Email:', adminEmail);
    console.log('🔑 Password:', testPassword);
    console.log('✅ Password should work:', finalMatch);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error debugging admin login:', error.message);
    console.error('Stack trace:', error.stack);
    process.exit(1);
  }
}

detailedDebugAdminLogin();
