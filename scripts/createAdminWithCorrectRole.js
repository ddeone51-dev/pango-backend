const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

async function createAdminWithCorrectRole() {
  try {
    console.log('🔧 Creating admin user with correct role...');
    
    const baseUrl = 'https://pango-backend.onrender.com/api/v1';
    
    // First, delete any existing admin users
    console.log('🗑️ Attempting to delete existing admin user...');
    try {
      const deleteResponse = await fetch(`${baseUrl}/users/delete-admin`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json'
        }
      });
      console.log('Delete response:', await deleteResponse.text());
    } catch (e) {
      console.log('Delete endpoint not available, continuing...');
    }

    // Register new admin user
    const registerData = {
      email: 'admin@pango.com',
      phoneNumber: '+255000000000',
      password: 'admin123',
      firstName: 'Admin',
      lastName: 'User'
    };

    console.log('📝 Registering new admin user...');
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
        console.log('User role:', loginResult.data.user.role);
        
        // Try to update role through profile update
        console.log('🔄 Attempting to update role through profile...');
        const profileResponse = await fetch(`${baseUrl}/users/profile`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${loginResult.data.token}`
          },
          body: JSON.stringify({
            role: 'admin'
          })
        });

        const profileResult = await profileResponse.json();
        console.log('Profile update response:', profileResult);

        // Try alternative endpoint
        console.log('🔄 Attempting to update role through alternative endpoint...');
        const altResponse = await fetch(`${baseUrl}/users/role`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${loginResult.data.token}`
          },
          body: JSON.stringify({
            role: 'admin'
          })
        });

        const altResult = await altResponse.json();
        console.log('Alternative update response:', altResult);

        // Test final login
        console.log('🔐 Testing final login...');
        const finalLoginResponse = await fetch(`${baseUrl}/auth/login`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            email: 'admin@pango.com',
            password: 'admin123'
          })
        });

        const finalLoginResult = await finalLoginResponse.json();
        console.log('Final login result:', finalLoginResult);
        
        if (finalLoginResponse.ok) {
          console.log('🎉 Final login successful!');
          console.log('Final user role:', finalLoginResult.data.user.role);
        }
      }
    } else {
      console.log('❌ Registration failed:', registerResult.message);
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

createAdminWithCorrectRole();
