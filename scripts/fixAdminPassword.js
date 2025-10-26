const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();
const User = require('../src/models/User');

async function fixAdminPassword() {
  try {
    console.log('🔧 Fixing admin password (bypassing pre-save hook)...');
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
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Create a fresh hash
    console.log('🔐 Creating fresh password hash...');
    const freshHash = await bcrypt.hash(testPassword, 10);
    console.log('Fresh hash created successfully');

    // Update password directly in the database (bypassing Mongoose hooks)
    console.log('💾 Updating password directly in database...');
    await User.updateOne(
      { email: adminEmail },
      { password: freshHash }
    );

    // Verify the fix
    console.log('✅ Verifying password fix...');
    const updatedAdmin = await User.findOne({ email: adminEmail }).select('+password');
    const isMatch = await updatedAdmin.matchPassword(testPassword);
    console.log('Password match result:', isMatch);

    if (isMatch) {
      console.log('\n🎉 Admin password fixed successfully!');
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.log('📧 Email:', adminEmail);
      console.log('🔑 Password:', testPassword);
      console.log('✅ Login should work now!');
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } else {
      console.log('❌ Password fix failed!');
    }

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error fixing admin password:', error.message);
    console.error('Stack trace:', error.stack);
    process.exit(1);
  }
}

fixAdminPassword();
