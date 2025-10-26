const express = require('express');
const mongoose = require('mongoose');
require('dotenv').config();
const User = require('../src/models/User');

const app = express();

// Simple endpoint to check database connection and admin user
app.get('/debug-admin', async (req, res) => {
  try {
    console.log('🔍 Debug endpoint called');
    console.log('MongoDB URI:', process.env.MONGODB_URI);
    
    // Check if connected
    const isConnected = mongoose.connection.readyState === 1;
    console.log('Database connected:', isConnected);
    
    if (!isConnected) {
      await mongoose.connect(process.env.MONGODB_URI);
      console.log('Connected to database');
    }
    
    // Find admin user
    const admin = await User.findOne({ email: 'admin@pango.com' }).select('+password');
    
    if (!admin) {
      return res.json({
        success: false,
        message: 'Admin user not found',
        mongoUri: process.env.MONGODB_URI,
        connected: isConnected
      });
    }
    
    // Test password
    const testPassword = 'admin123';
    const isMatch = await admin.matchPassword(testPassword);
    
    res.json({
      success: true,
      message: 'Admin user found',
      admin: {
        email: admin.email,
        role: admin.role,
        status: admin.accountStatus,
        passwordMatch: isMatch
      },
      mongoUri: process.env.MONGODB_URI,
      connected: isConnected
    });
    
  } catch (error) {
    console.error('Debug error:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      mongoUri: process.env.MONGODB_URI
    });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Debug server running on port ${PORT}`);
});
