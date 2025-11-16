# 🔍 Admin Payment Information Viewing - Quick Guide

## Overview
Admins can now view **all payment and payout information** for hosts directly from the admin panel.

---

## 2 Ways to View Host Payment Info

### **Method 1: Via Individual Host Profile** ✅
```
Endpoint: GET /api/v1/admin/users/:id
Auth: Admin token required
```

**Response includes:**
- Host's bank account details
- Mobile money information
- Setup status
- Verification status

**Example:**
```bash
GET /api/v1/admin/users/68e678ea9851a06c9994a1cf
Authorization: Bearer admin_token_here
```

---

### **Method 2: Via Bulk Payout Settings Viewer** ✅ (NEW)
```
Endpoint: GET /api/v1/admin/hosts/payout-settings
Auth: Admin token required
```

**Features:**
- View all hosts at once
- Search by name, email, or phone
- Filter by payout method
- Filter by verification status
- Paginated results
- Masked sensitive data

**Examples:**

1️⃣ **View all hosts' payout settings (page 1):**
```bash
GET /api/v1/admin/hosts/payout-settings?page=1&limit=20
```

2️⃣ **Search specific host:**
```bash
GET /api/v1/admin/hosts/payout-settings?search=John%20Doe
```

3️⃣ **View only bank account hosts:**
```bash
GET /api/v1/admin/hosts/payout-settings?method=bank_account
```

4️⃣ **View verified payout settings:**
```bash
GET /api/v1/admin/hosts/payout-settings?verified=true
```

5️⃣ **Combined filters:**
```bash
GET /api/v1/admin/hosts/payout-settings?search=John&method=mobile_money&verified=false
```

---

## 🔒 Security: What Data is Masked?

| Information | Display Format | Reason |
|------------|----------------|--------|
| Bank Account # | `****6789` | Privacy |
| Phone Number | `0700****` | Privacy |
| Account Password | Not shown | Security |

---

## 📊 Response Example

```json
{
  "success": true,
  "data": {
    "hosts": [
      {
        "id": "68e678ea9851a06c9994a1cf",
        "email": "host@example.com",
        "phoneNumber": "+255700000000",
        "name": "John Doe",
        "hostStatus": "approved",
        "payoutSettings": {
          "method": "bank_account",
          "isSetupComplete": true,
          "verified": false,
          "lastUpdatedAt": "2024-01-15T10:30:00Z",
          "bankAccount": {
            "accountName": "John Doe",
            "accountNumber": "****6789",  // Masked
            "bankName": "CRDB Bank"
          },
          "mobileMoney": null
        },
        "joinedAt": "2023-11-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "pages": 3
    }
  }
}
```

---

## ✅ Checklist: What Info Can Admin See?

✅ Host name and contact info  
✅ Payout method (bank or mobile)  
✅ Bank name and account holder name  
✅ Last 4 digits of bank account  
✅ Mobile money provider  
✅ Last 4 digits of phone number  
✅ Setup completion status  
✅ Verification status  
✅ When payment info was last updated  
✅ Host approval status  

❌ Full bank account numbers  
❌ Full phone numbers  
❌ Passwords  
❌ Personal ID documents  

---

## 🎯 Common Use Cases

### **1. Verify Host Before Releasing Payment**
```bash
# Check if host has payout settings configured
GET /api/v1/admin/hosts/payout-settings?search=John%20Doe
# Response shows if payout is setup and verified
```

### **2. Find All Unverified Hosts**
```bash
# Get hosts whose payout hasn't been verified
GET /api/v1/admin/hosts/payout-settings?verified=false
# Helps identify hosts who need verification
```

### **3. Check Specific Host's Bank Info**
```bash
# View detailed payout for one host
GET /api/v1/admin/users/68e678ea9851a06c9994a1cf
# Response includes full bank/mobile details
```

### **4. Monthly Payout Audit**
```bash
# Get all hosts with mobile money payouts
GET /api/v1/admin/hosts/payout-settings?method=mobile_money
# Useful for reconciliation
```

---

## 🚀 Getting Started

### **Step 1: Get Your Admin Token**
```bash
POST /api/v1/auth/login
{
  "email": "admin@pango.co.tz",
  "password": "your_password"
}
# Response includes: { token: "jwt_token" }
```

### **Step 2: Make Authenticated Request**
```bash
curl -X GET "http://localhost:3000/api/v1/admin/hosts/payout-settings" \
  -H "Authorization: Bearer jwt_token"
```

### **Step 3: Parse Response**
```javascript
const response = await fetch(
  'http://localhost:3000/api/v1/admin/hosts/payout-settings',
  {
    headers: { 'Authorization': 'Bearer jwt_token' }
  }
);

const data = await response.json();
console.log(data.data.hosts); // Array of hosts with payout info
```

---

## 🛠️ API Query Parameters

| Parameter | Type | Example | Description |
|-----------|------|---------|-------------|
| `page` | number | `?page=1` | Page number (default: 1) |
| `limit` | number | `?limit=20` | Records per page (default: 20) |
| `search` | string | `?search=John` | Search name/email/phone |
| `method` | string | `?method=bank_account` | Filter by payout method |
| `verified` | boolean | `?verified=true` | Filter by verification status |

---

## ❌ Error Handling

| Status | Meaning | Solution |
|--------|---------|----------|
| 200 | Success | ✅ Data returned successfully |
| 401 | Unauthorized | 🔐 Check token is valid and not expired |
| 403 | Forbidden | 👤 Ensure user is admin role |
| 404 | Not Found | 🔍 Check user ID is correct |
| 500 | Server Error | ⚠️ Check backend logs |

---

## 📈 Response Pagination

```json
{
  "pagination": {
    "page": 1,          // Current page
    "limit": 20,        // Records per page
    "total": 150,       // Total records
    "pages": 8          // Total pages
  }
}
```

**Navigate pages:**
```bash
# Page 2
GET /api/v1/admin/hosts/payout-settings?page=2

# Page 3 with 50 items per page
GET /api/v1/admin/hosts/payout-settings?page=3&limit=50
```

---

## 💡 Pro Tips

1. **Always check `isSetupComplete`** before trusting payout info
2. **Verify `verified` status** before processing large payouts
3. **Use search** to quickly find specific hosts
4. **Use method filter** to audit payment channels
5. **Check `lastUpdatedAt`** to see when info was last changed

---

## 🔗 Related Endpoints

| Endpoint | Purpose |
|----------|---------|
| `GET /api/v1/admin/users/:id` | View single user (with payout) |
| `GET /api/v1/admin/hosts` | List all hosts |
| `GET /api/v1/admin/payments/transactions` | View payment transactions |
| `PUT /api/v1/admin/users/:id` | Update user info |

---

## 📞 Need Help?

- Check `ADMIN_PAYOUT_VIEWING_FEATURE.md` for detailed documentation
- Review API response examples
- Check backend logs for errors

---

**✅ Feature is ready to use!**


