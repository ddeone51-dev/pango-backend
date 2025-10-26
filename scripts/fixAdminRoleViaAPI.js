const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

async function fixAdminRoleViaAPI() {
  try {
    console.log('🔧 Fixing admin role via API...');
    
    const baseUrl = 'https://pango-backend.onrender.com/api/v1';
    
    // Login first
    console.log('🔐 Logging in...');
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
    console.log('Login result:', loginResult);

    if (!loginResponse.ok) {
      console.log('❌ Login failed:', loginResult.message);
      return;
    }

    console.log('✅ Login successful!');
    console.log('Current role:', loginResult.data.user.role);
    
    const token = loginResult.data.token;
    const userId = loginResult.data.user._id;

    // Try to update role through different endpoints
    const endpoints = [
      `${baseUrl}/users/profile`,
      `${baseUrl}/users/${userId}`,
      `${baseUrl}/users/me`,
      `${baseUrl}/users/update-role`
    ];

    for (const endpoint of endpoints) {
      console.log(`\n🔄 Trying endpoint: ${endpoint}`);
      
      try {
        const updateResponse = await fetch(endpoint, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({
            role: 'admin'
          })
        });

        const updateResult = await updateResponse.json();
        console.log(`Response from ${endpoint}:`, updateResult);

        if (updateResponse.ok) {
          console.log(`✅ Success with ${endpoint}!`);
        }
      } catch (error) {
        console.log(`❌ Error with ${endpoint}:`, error.message);
      }
    }

    // Test final login
    console.log('\n🔐 Testing final login...');
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
      
      if (finalLoginResult.data.user.role === 'admin') {
        console.log('✅ Admin role is now correct!');
      } else {
        console.log('❌ Role is still not admin');
      }
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

fixAdminRoleViaAPI();
