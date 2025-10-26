const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

async function createAdminUser() {
  try {
    console.log('🔧 Creating admin user via API...');
    
    const baseUrl = 'https://pango-backend.onrender.com/api/v1';
    
    // First, try to register a new admin user
    const registerData = {
      email: 'admin@pango.com',
      phoneNumber: '+255000000000',
      password: 'admin123',
      firstName: 'Admin',
      lastName: 'User'
    };

    console.log('📝 Attempting to register admin user...');
    const registerResponse = await fetch(`${baseUrl}/auth/register`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(registerData)
    });

    const registerResult = await registerResponse.json();
    console.log('Register response:', registerResult);

    if (registerResponse.ok) {
      console.log('✅ Admin user registered successfully!');
      console.log('Now updating role to admin...');
      
      // Login to get token
      const loginResponse = await fetch(`${baseUrl}/auth/login`, {
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
      console.log('Login response:', loginResult);

      if (loginResponse.ok) {
        console.log('✅ Login successful!');
        console.log('Token:', loginResult.data.token);
        
        // Update user role to admin
        const updateResponse = await fetch(`${baseUrl}/users/profile`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${loginResult.data.token}`
          },
          body: JSON.stringify({
            role: 'admin'
          })
        });

        const updateResult = await updateResponse.json();
        console.log('Update role response:', updateResult);

        if (updateResponse.ok) {
          console.log('🎉 Admin user created and role updated successfully!');
        } else {
          console.log('⚠️ Role update failed, but user was created');
        }
      } else {
        console.log('⚠️ Login failed, but user was registered');
      }
    } else {
      console.log('⚠️ Registration failed:', registerResult.message);
      
      // Try to login with existing credentials
      console.log('🔐 Trying to login with existing credentials...');
      const loginResponse = await fetch(`${baseUrl}/auth/login`, {
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
      console.log('Login attempt result:', loginResult);

      if (loginResponse.ok) {
        console.log('✅ Login successful with existing user!');
        console.log('User role:', loginResult.data.user.role);
      } else {
        console.log('❌ Login failed:', loginResult.message);
      }
    }

  } catch (error) {
    console.error('❌ Error creating admin user:', error.message);
  }
}

createAdminUser();