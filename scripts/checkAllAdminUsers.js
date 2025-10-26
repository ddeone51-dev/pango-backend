const mongoose = require('mongoose');
require('dotenv').config();
const User = require('../src/models/User');

async function checkAllAdminUsers() {
  try {
    console.log('🔍 Checking all admin users in database...');
    console.log('Connecting to MongoDB...');
    console.log('MongoDB URI:', process.env.MONGODB_URI);
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    // Find ALL users with admin@pango.com email
    const adminUsers = await User.find({ email: 'admin@pango.com' });
    
    console.log(`Found ${adminUsers.length} users with email admin@pango.com:`);
    adminUsers.forEach((user, index) => {
      console.log(`\n${index + 1}. User ID: ${user._id}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Role: ${user.role}`);
      console.log(`   Status: ${user.accountStatus}`);
      console.log(`   Created: ${user.createdAt}`);
      console.log(`   Updated: ${user.updatedAt}`);
    });

    // Find ALL users with admin role
    const allAdmins = await User.find({ role: 'admin' });
    console.log(`\nFound ${allAdmins.length} users with admin role:`);
    allAdmins.forEach((user, index) => {
      console.log(`\n${index + 1}. User ID: ${user._id}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Role: ${user.role}`);
      console.log(`   Status: ${user.accountStatus}`);
    });

    // Update ALL admin@pango.com users to have admin role
    console.log('\n🔄 Updating ALL admin@pango.com users to admin role...');
    const updateResult = await User.updateMany(
      { email: 'admin@pango.com' },
      { 
        role: 'admin',
        accountStatus: 'active'
      }
    );
    
    console.log(`✅ Updated ${updateResult.modifiedCount} users`);

    // Verify the update
    const updatedAdmins = await User.find({ email: 'admin@pango.com' });
    console.log('\n📋 Updated Admin Users:');
    updatedAdmins.forEach((user, index) => {
      console.log(`\n${index + 1}. User ID: ${user._id}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Role: ${user.role}`);
      console.log(`   Status: ${user.accountStatus}`);
    });

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error checking admin users:', error.message);
    process.exit(1);
  }
}

checkAllAdminUsers();
