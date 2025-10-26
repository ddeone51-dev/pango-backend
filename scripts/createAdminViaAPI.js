const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();
const User = require('../src/models/User');

async function createAdminViaAPI() {
  try {
    console.log('🔧 Creating admin user via API...');
    
    const adminData = {
      email: 'admin@pango.com',
      phoneNumber: '+255000000000',
      password: 'admin123',
      profile: {
        firstName: 'Admin',
        lastName: 'User'
      }
    };

    // Try to register the admin user
    const response = await fetch('https://pango-backend.onrender.com/api/v1/auth/register', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(adminData)
    });

    const result = await response.json();
    
    if (response.ok) {
      console.log('✅ Admin user created successfully via API!');
      console.log('Response:', result);
    } else {
      console.log('⚠️ Registration failed, trying to update existing user...');
      console.log('Error:', result);
      
      // If user already exists, try to login to test
      const loginResponse = await fetch('https://pango-backend.onrender.com/api/v1/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          email: 'admin@pango.com',
          password: 'admin123'
        })
      });
      
      const loginResult = await loginResponse.json();
      console.log('Login test result:', loginResult);
    }

  } catch (error) {
    console.error('❌ Error creating admin via API:', error.message);
  }
}

createAdminViaAPI();
