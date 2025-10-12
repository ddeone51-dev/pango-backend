/**
 * Create Admin User Script
 * 
 * Usage:
 *   node scripts/createAdmin.js
 * 
 * This script creates an admin user in the database
 */

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const readline = require('readline');
require('dotenv').config();

const User = require('../src/models/User');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function question(query) {
  return new Promise(resolve => rl.question(query, resolve));
}

async function createAdminUser() {
  try {
    // Connect to MongoDB
    console.log('🔌 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    // Check if admin already exists
    const existingAdmin = await User.findOne({ role: 'admin' });
    if (existingAdmin) {
      console.log('⚠️  Admin user already exists:');
      console.log(`   Email: ${existingAdmin.email}`);
      console.log(`   Phone: ${existingAdmin.phoneNumber}\n`);
      
      const proceed = await question('Do you want to create another admin user? (yes/no): ');
      if (proceed.toLowerCase() !== 'yes') {
        console.log('❌ Cancelled.\n');
        process.exit(0);
      }
    }

    // Get admin details
    console.log('\n📝 Enter Admin Details:\n');
    
    const email = await question('Email: ');
    const phoneNumber = await question('Phone (e.g., +255712345678): ');
    const firstName = await question('First Name: ');
    const lastName = await question('Last Name: ');
    const password = await question('Password (min 8 characters): ');

    // Validate inputs
    if (!email || !phoneNumber || !firstName || !lastName || !password) {
      console.log('\n❌ All fields are required!\n');
      process.exit(1);
    }

    if (password.length < 8) {
      console.log('\n❌ Password must be at least 8 characters long!\n');
      process.exit(1);
    }

    if (!phoneNumber.match(/^\+255\d{9}$/)) {
      console.log('\n❌ Phone number must be in format +255XXXXXXXXX\n');
      process.exit(1);
    }

    // Check if user already exists
    const existing = await User.findOne({ 
      $or: [{ email }, { phoneNumber }] 
    });

    if (existing) {
      console.log('\n❌ User with this email or phone already exists!\n');
      process.exit(1);
    }

    // Hash password
    console.log('\n🔐 Hashing password...');
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create admin user
    console.log('👤 Creating admin user...');
    const admin = await User.create({
      email,
      phoneNumber,
      password: hashedPassword,
      role: 'admin',
      profile: {
        firstName,
        lastName,
        bio: 'System Administrator'
      },
      isActive: true,
      isVerified: true
    });

    console.log('\n✅ Admin user created successfully!\n');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📧 Email:', admin.email);
    console.log('📱 Phone:', admin.phoneNumber);
    console.log('👤 Name:', `${admin.profile.firstName} ${admin.profile.lastName}`);
    console.log('🔑 Role:', admin.role);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    console.log('🎯 Next Steps:');
    console.log('   1. Start the backend server: npm run dev');
    console.log('   2. Open admin panel: http://localhost:3000/admin');
    console.log('   3. Login with the credentials above\n');

  } catch (error) {
    console.error('\n❌ Error creating admin user:', error.message);
    if (error.code === 11000) {
      console.log('   → User with this email or phone already exists\n');
    }
  } finally {
    rl.close();
    await mongoose.disconnect();
    process.exit(0);
  }
}

// Run the script
console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('🎛️  Pango Admin User Creation Tool');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

createAdminUser();






