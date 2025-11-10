const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

async function testUpdateRole() {
  try {
    console.log('🔧 Testing update-role endpoint...');
    
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

    // Try to update role
    console.log('\n🔄 Updating role to admin...');
    const updateResponse = await fetch(`${baseUrl}/users/update-role`, {
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
    console.log('Update response:', updateResult);

    if (updateResponse.ok) {
      console.log('✅ Role updated successfully!');
      console.log('New role:', updateResult.data.role);
    } else {
      console.log('❌ Role update failed:', updateResult.message);
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
        console.log('✅ Admin role is now correct! You can login to the admin panel!');
      } else {
        console.log('❌ Role is still not admin');
      }
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

testUpdateRole();

