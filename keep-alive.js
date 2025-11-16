const https = require('https');

// Your Render.com backend URL
const BACKEND_URL = 'https://pango-backend.onrender.com/api/v1/health';

function pingServer() {
  console.log(`Pinging server at ${new Date().toISOString()}`);
  
  https.get(BACKEND_URL, (res) => {
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      console.log('✅ Server responded:', data);
    });
  }).on('error', (err) => {
    console.error('❌ Error pinging server:', err.message);
  });
}

// Ping every 10 minutes (600000 ms)
setInterval(pingServer, 10 * 60 * 1000);

// Ping immediately
pingServer();

console.log('🔄 Keep-alive script started. Pinging every 10 minutes...');





