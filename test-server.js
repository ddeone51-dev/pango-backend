// Simple test server to debug Render deployment
console.log('🚀 Starting test server...');
console.log('Environment variables:');
console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('PORT:', process.env.PORT);
console.log('JWT_SECRET exists:', !!process.env.JWT_SECRET);
console.log('MONGODB_URI exists:', !!process.env.MONGODB_URI);

try {
  console.log('📦 Loading dependencies...');
  const express = require('express');
  console.log('✅ Express loaded');
  
  const mongoose = require('mongoose');
  console.log('✅ Mongoose loaded');
  
  console.log('🔌 Testing route imports...');
  require('./src/routes/index.js');
  console.log('✅ All routes loaded successfully');
  
  console.log('🎯 Test server completed successfully!');
  process.exit(0);
  
} catch (error) {
  console.error('❌ Error during test:', error.message);
  console.error('Stack:', error.stack);
  process.exit(1);
}
