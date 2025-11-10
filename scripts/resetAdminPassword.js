const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const User = require('../src/models/User');

async function resetAdminPassword() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    const admin = await User.findOne({ email: 'admin@pango.com' });
    if (!admin) {
      console.log('❌ Admin user not found!');
      return;
    }

    // Set a simple password for testing
    const newPassword = 'admin123';
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    
    admin.password = hashedPassword;
    await admin.save();

    console.log('✅ Admin password reset successfully!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📧 Email: admin@pango.com');
    console.log('🔑 Password: admin123');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    await mongoose.connection.close();
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

resetAdminPassword();

