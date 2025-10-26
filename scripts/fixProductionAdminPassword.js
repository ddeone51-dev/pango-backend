const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();
const User = require('../src/models/User');

async function fixProductionAdminPassword() {
  try {
    console.log('🔧 Fixing admin password on PRODUCTION database...');
    console.log('Connecting to MongoDB...');
    console.log('MongoDB URI:', process.env.MONGODB_URI);
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    const adminEmail = 'admin@pango.com';
    const testPassword = 'admin123';

    // Find ALL admin users
    console.log('🔍 Searching for admin users...');
    const allAdmins = await User.find({ role: 'admin' });
    console.log(`Found ${allAdmins.length} admin users:`);
    allAdmins.forEach((admin, index) => {
      console.log(`  ${index + 1}. ${admin.email} (${admin.profile.firstName} ${admin.profile.lastName})`);
    });

    // Find the specific admin user
    const admin = await User.findOne({ email: adminEmail }).select('+password');
    
    if (!admin) {
      console.log('❌ Admin user not found! Creating new admin user...');
      
      // Create new admin user
      const newAdmin = new User({
        email: adminEmail,
        phoneNumber: '+255000000000', // Dummy phone number
        password: testPassword, // Will be hashed by pre-save hook
        role: 'admin',
        profile: {
          firstName: 'Admin',
          lastName: 'User'
        },
        accountStatus: 'active'
      });
      
      await newAdmin.save();
      console.log('✅ New admin user created!');
    } else {
      console.log('📋 Found existing admin user');
      console.log('Email:', admin.email);
      console.log('Role:', admin.role);
      console.log('Status:', admin.accountStatus);
      
      // Create a fresh hash and update directly
      console.log('🔐 Creating fresh password hash...');
      const freshHash = await bcrypt.hash(testPassword, 10);
      
      console.log('💾 Updating password directly in database...');
      await User.updateOne(
        { email: adminEmail },
        { 
          password: freshHash,
          accountStatus: 'active' // Ensure account is active
        }
      );
      
      console.log('✅ Password updated successfully!');
    }

    // Verify the fix
    console.log('✅ Verifying password fix...');
    const updatedAdmin = await User.findOne({ email: adminEmail }).select('+password');
    if (updatedAdmin) {
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
        console.log('❌ Password verification failed!');
      }
    } else {
      console.log('❌ Could not find admin user after update!');
    }

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error fixing admin password:', error.message);
    console.error('Stack trace:', error.stack);
    process.exit(1);
  }
}

fixProductionAdminPassword();
