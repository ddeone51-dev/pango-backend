# Pesapal API 3.0 Integration Guide
## Complete Step-by-Step Best Practices

> **Based on real-world implementation experience with extensive testing and debugging**

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [API Configuration](#api-configuration)
4. [Core Implementation](#core-implementation)
5. [Testing Strategy](#testing-strategy)
6. [Production Deployment](#production-deployment)
7. [Common Pitfalls & Solutions](#common-pitfalls--solutions)
8. [Best Practices](#best-practices)

---

## Prerequisites

### 1. Pesapal Account Setup
- [ ] Create Pesapal merchant account
- [ ] Complete KYC verification
- [ ] Obtain sandbox credentials (Consumer Key & Secret)
- [ ] Obtain production credentials (Consumer Key & Secret)

### 2. Development Environment
- [ ] Node.js backend server (Express.js recommended)
- [ ] Frontend app (React Native, Flutter, or Web)
- [ ] HTTPS domain for IPN endpoint
- [ ] ngrok or similar tool for local testing

---

## Environment Setup

### 1. Create Configuration File
```typescript
// constants/pesapal.ts
export const PESAPAL_CONFIG = {
  SANDBOX: {
    BASE_URL: 'https://cybqa.pesapal.com/pesapalv3/api', // Note: /api suffix is CRITICAL
    CONSUMER_KEY: 'your_sandbox_consumer_key',
    CONSUMER_SECRET: 'your_sandbox_consumer_secret',
  },
  PRODUCTION: {
    BASE_URL: 'https://www.pesapal.com/api',
    CONSUMER_KEY: 'your_production_consumer_key',
    CONSUMER_SECRET: 'your_production_consumer_secret',
  },
  IPN_URL: 'https://your-domain.com/api/pesapal-ipn',
  CALLBACK_URL: 'yourapp://payment/callback',
  CANCELLATION_URL: 'yourapp://payment/cancel',
};
```

### 2. Backend Server Setup (Express.js)
```javascript
// server.js
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// IPN endpoint
app.post('/api/pesapal-ipn', (req, res) => {
  console.log('=== PESAPAL IPN RECEIVED ===');
  console.log('Timestamp:', new Date().toISOString());
  console.log('Headers:', req.headers);
  console.log('Body:', req.body);
  console.log('===============================');
  
  // Process IPN data
  const { OrderTrackingId, OrderMerchantReference, PaymentStatus } = req.body;
  
  // Update your database with payment status
  // Handle successful payments
  // Send confirmation emails, etc.
  
  res.status(200).json({ success: true, message: 'IPN received' });
});

app.listen(3000, () => {
  console.log('🚀 IPN Server running on port 3000');
});
```

---

## API Configuration

### 1. Authentication Service
```typescript
// services/pesapalApiService.ts
class PesapalApiService {
  private config = PESAPAL_CONFIG.SANDBOX; // Switch to PRODUCTION when ready

  async getBearerToken(): Promise<string> {
    const authUrl = `${this.config.BASE_URL}/Auth/RequestToken`;
    
    const response = await fetch(authUrl, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'YourApp/1.0'
      },
      body: JSON.stringify({
        consumer_key: this.config.CONSUMER_KEY,
        consumer_secret: this.config.CONSUMER_SECRET
      })
    });

    const responseText = await response.text();
    
    if (!response.ok || !responseText) {
      throw new Error(`Authentication failed: ${response.status}`);
    }
    
    const data = JSON.parse(responseText);
    return data.token;
  }
}
```

### 2. IPN Registration
```typescript
async registerIPN(ipnUrl: string): Promise<string> {
  const token = await this.getBearerToken();
  const registerUrl = `${this.config.BASE_URL}/URLSetup/RegisterIPN`;
  
  const response = await fetch(registerUrl, {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
      'User-Agent': 'YourApp/1.0'
    },
    body: JSON.stringify({
      url: ipnUrl,
      ipn_notification_type: 'POST'
    })
  });

  const responseText = await response.text();
  
  if (!response.ok || !responseText) {
    throw new Error(`IPN registration failed: ${response.status}`);
  }
  
  const data = JSON.parse(responseText);
  return data.ipn_id;
}
```

### 3. Order Submission
```typescript
async submitOrder(
  amount: number,
  currency: string,
  description: string,
  customerEmail: string,
  customerFirstName: string,
  customerLastName: string,
  ipnId: string,
  merchantReference: string
): Promise<OrderResponse> {
  const token = await this.getBearerToken();
  const orderUrl = `${this.config.BASE_URL}/Transactions/SubmitOrderRequest`;
  
  const orderData = {
    id: merchantReference,
    currency: currency,
    amount: amount,
    description: description, // Keep it simple: "Premium Subscription"
    callback_url: PESAPAL_CONFIG.CALLBACK_URL,
    notification_id: ipnId,
    billing_address: {
      phone_number: null, // Use null for optional fields
      email_address: customerEmail,
      country_code: "TZ", // Or your country code
      first_name: customerFirstName,
      last_name: customerLastName,
      line_1: null,
      line_2: null,
      city: null,
      state: null,
      postal_code: null,
      zip_code: null
    }
  };

  const response = await fetch(orderUrl, {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
      'User-Agent': 'YourApp/1.0'
    },
    body: JSON.stringify(orderData)
  });

  const responseText = await response.text();
  
  if (!response.ok || !responseText) {
    throw new Error(`Order submission failed: ${response.status} - ${responseText}`);
  }
  
  const data = JSON.parse(responseText);
  
  if (!data.redirect_url) {
    throw new Error('No redirect URL received from Pesapal');
  }
  
  return data;
}
```

---

## Testing Strategy

### 1. Local Development Setup
```bash
# Start your backend server
npm start

# In another terminal, expose your server
ngrok http 3000

# Update your IPN_URL with the ngrok URL
# Example: https://abc123.ngrok.io/api/pesapal-ipn
```

### 2. Test IPN Endpoint
```bash
# Test your IPN endpoint
curl -X POST https://your-ngrok-url.ngrok.io/api/pesapal-ipn \
  -H "Content-Type: application/json" \
  -d '{"test": "data", "OrderTrackingId": "test123"}'
```

### 3. Create Test Service
```typescript
// services/pesapalTestService.ts
class PesapalTestService {
  async testCompleteFlow(): Promise<void> {
    try {
      console.log('🧪 Testing complete flow...');
      
      // Step 1: Auth
      const token = await this.getBearerToken();
      console.log('✅ Auth successful');
      
      // Step 2: IPN Registration
      const ipnId = await this.registerIPN('https://webhook.site/test');
      console.log('✅ IPN registered:', ipnId);
      
      // Step 3: Order Submission
      const order = await this.submitOrder(
        1, // Minimal amount
        'USD',
        'Test Order', // Simple description
        'test@example.com',
        'Test',
        'User',
        ipnId,
        `test_${Date.now()}`
      );
      
      console.log('✅ Order successful:', order.redirect_url);
      
    } catch (error) {
      console.error('❌ Test failed:', error);
    }
  }
}
```

---

## Production Deployment

### 1. Environment Variables
```bash
# .env
PESAPAL_PRODUCTION_KEY=your_production_key
PESAPAL_PRODUCTION_SECRET=your_production_secret
PESAPAL_IPN_URL=https://your-domain.com/api/pesapal-ipn
```

### 2. Switch to Production
```typescript
// Update your service to use production config
private config = process.env.NODE_ENV === 'production' 
  ? PESAPAL_CONFIG.PRODUCTION 
  : PESAPAL_CONFIG.SANDBOX;
```

### 3. SSL Certificate
- Ensure your IPN endpoint has valid SSL certificate
- Test HTTPS connectivity from Pesapal servers

---

## Common Pitfalls & Solutions

### ❌ **Pitfall 1: Wrong Base URL**
```typescript
// WRONG
BASE_URL: 'https://cybqa.pesapal.com/pesapalv3'

// CORRECT
BASE_URL: 'https://cybqa.pesapal.com/pesapalv3/api'
```

### ❌ **Pitfall 2: Complex Descriptions**
```typescript
// WRONG - Too complex
description: "Premium Monthly Subscription with Advanced Features"

// CORRECT - Simple
description: "Premium Subscription"
```

### ❌ **Pitfall 3: Long Merchant References**
```typescript
// WRONG - Too long
merchantReference: `app_premium_monthly_${timestamp}_${userId}_${randomString}`

// CORRECT - Simple
merchantReference: `premium_monthly_${timestamp}`
```

### ❌ **Pitfall 4: Hardcoded Billing Address**
```typescript
// WRONG - Hardcoded values
billing_address: {
  phone_number: "255123456789",
  line_1: "123 Main Street",
  city: "Dar es Salaam"
}

// CORRECT - Use null for optional fields
billing_address: {
  phone_number: null,
  line_1: null,
  city: null,
  // ... other fields as null
}
```

### ❌ **Pitfall 5: IPN URL Reuse**
```typescript
// WRONG - Reusing same IPN URL
// Always register fresh IPN for each order

// CORRECT - Fresh IPN each time
const ipnId = await this.registerIPN(this.config.IPN_URL);
```

---

## Best Practices

### 1. Error Handling
```typescript
try {
  const orderResponse = await pesapalApiService.processSubscription(/* ... */);
  // Handle success
} catch (error) {
  console.error('Payment Error:', error.message);
  // Show user-friendly error message
  Alert.alert('Payment Error', 'Unable to process payment. Please try again.');
}
```

### 2. Rate Limiting
```typescript
// Add delays between API calls
await new Promise(resolve => setTimeout(resolve, 2000));
```

### 3. Logging
```typescript
// Log important events
console.log('Payment initiated:', merchantReference);
console.log('Payment completed:', orderTrackingId);
```

### 4. Security
- Never expose consumer secret in frontend
- Use environment variables for credentials
- Validate IPN signatures (if implemented by Pesapal)
- Use HTTPS for all endpoints

### 5. User Experience
```typescript
// Show loading states
const [loading, setLoading] = useState(false);

// Handle payment flow
const handlePayment = async () => {
  setLoading(true);
  try {
    const orderResponse = await pesapalApiService.processSubscription(/* ... */);
    await WebBrowser.openBrowserAsync(orderResponse.redirect_url);
  } catch (error) {
    Alert.alert('Error', error.message);
  } finally {
    setLoading(false);
  }
};
```

---

## Implementation Checklist

### Development Phase
- [ ] Set up Pesapal sandbox account
- [ ] Create configuration file
- [ ] Implement authentication service
- [ ] Implement IPN registration
- [ ] Implement order submission
- [ ] Create test service
- [ ] Test complete flow locally
- [ ] Test with ngrok

### Production Phase
- [ ] Obtain production credentials
- [ ] Set up production server
- [ ] Configure SSL certificate
- [ ] Update IPN URL
- [ ] Test production flow
- [ ] Monitor IPN endpoint
- [ ] Set up error monitoring

### Maintenance
- [ ] Monitor payment success rates
- [ ] Check IPN endpoint logs
- [ ] Update credentials when needed
- [ ] Test after Pesapal updates

---

## Support & Resources

- **Pesapal Documentation**: https://developer.pesapal.com/
- **Sandbox Testing**: Use test credentials for development
- **Support**: Contact Pesapal support for production issues
- **Community**: Join Pesapal developer community

---

*This guide is based on extensive real-world implementation experience and includes all the lessons learned from common pitfalls and debugging sessions.*
