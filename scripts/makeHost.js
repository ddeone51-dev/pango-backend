const mongoose = require('mongoose');
const User = require('../src/models/User');
require('dotenv').config();

async function makeHost() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');
    
    // Get all users to show options
    const users = await User.find({}, 'email role');
    
    console.log('📋 Available users:');
    users.forEach((user, index) => {
      console.log(`   ${index + 1}. ${user.email} (${user.role})`);
    });
    
    if (users.length === 0) {
      console.log('\n❌ No users found. Please register a user first.');
      process.exit(1);
    }
    
    // Make all non-admin users hosts
    const updated = await User.updateMany(
      { role: { $ne: 'admin' } },
      { $set: { role: 'host' } }
    );
    
    console.log(`\n✅ Updated ${updated.modifiedCount} user(s) to HOST role`);
    
    // Show updated users
    const updatedUsers = await User.find({}, 'email role');
    console.log('\n📋 Updated users:');
    updatedUsers.forEach((user) => {
      console.log(`   - ${user.email} → ${user.role.toUpperCase()}`);
    });
    
    console.log('\n🎉 Done! All users are now hosts.');
    console.log('\nYou can now:');
    console.log('  1. Logout and login again in the mobile app');
    console.log('  2. Go to Profile → Host Dashboard');
    console.log('  3. Tap "Add Listing" to create your property\n');
    
    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

makeHost();























