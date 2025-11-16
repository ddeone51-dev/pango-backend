# 🚀 Quick Setup - Get SMS & Email API Credentials

## ✅ **Current Status:**
Your app works RIGHT NOW without any setup!
- ✅ Verification codes appear in the **backend terminal**
- ✅ Just copy/paste them to test
- ✅ To send **real SMS and emails**, follow the steps below

---

## 📱 **OPTION 1: Get SMS API (Africa's Talking)**

### **Step 1: Sign Up (FREE)**
1. **Go to:** https://account.africastalking.com/auth/register
2. Click **"Sign Up"**
3. Fill in your details:
   - Name
   - Email
   - Password
   - Phone number (Tanzanian: +255XXXXXXXXX)
4. Click **"Create Account"**

### **Step 2: Verify Your Account**
- Check your email inbox
- Click the verification link
- You'll be redirected to Africa's Talking dashboard

### **Step 3: Get API Credentials**
1. After login, click **"Sandbox App"** in the left sidebar
2. You'll see:
   - **Username:** `sandbox`
   - **API Key:** Click "Settings" → "API Key" → "Generate"
3. **Copy both:**
   ```
   Username: sandbox
   API Key: atsk_1234567890abcdef... (your actual key)
   ```

### **Step 4: Add Test Phone Number**
**IMPORTANT for Sandbox testing!**
1. In Sandbox app, click **"Launch Simulator"**
2. Click **"Add Phone Number"**
3. Enter your phone: `+255XXXXXXXXX`
4. Click **"Add"**

✅ **Now your phone can receive test SMS!**

---

## 📧 **OPTION 2: Get Email API (Gmail - FREE)**

### **Step 1: Enable 2-Factor Authentication**
1. **Go to:** https://myaccount.google.com/security
2. Scroll to **"2-Step Verification"**
3. Click **"Get Started"**
4. Follow the steps (verify with your phone)
5. Complete setup

### **Step 2: Generate App Password**
1. **Go to:** https://myaccount.google.com/apppasswords
2. You might need to sign in again
3. Under **"Select app"**: Choose **"Mail"** or type "Pango"
4. Under **"Select device"**: Choose your device
5. Click **"Generate"**
6. You'll see a **16-character password** like:
   ```
   abcd efgh ijkl mnop
   ```
7. **COPY IT NOW!** (You can't see it again, but you can generate new ones)

### **Step 3: Save Your Credentials**
```
Email: your.email@gmail.com
App Password: abcdefghijklmnop (remove spaces: 16 characters)
```

---

## 🔧 **Add Credentials to Backend**

### **Option A: Using Terminal (Recommended)**

**Open PowerShell in the backend folder** and run:

```powershell
cd C:\pango\backend

# Create .env file
@"
# Server Configuration
PORT=3000
NODE_ENV=development

# Database
MONGODB_URI=mongodb+srv://techlandtz_db_user:C86zikhnrHw3oKXS@cluster0.5uvn2fu.mongodb.net/pango

# JWT Configuration
JWT_SECRET=pango_super_secret_jwt_key_2024
JWT_EXPIRE=7d

# Email Configuration (Gmail)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=YOUR_EMAIL_HERE@gmail.com
EMAIL_PASS=YOUR_16_CHAR_PASSWORD_HERE
EMAIL_FROM=Pango <noreply@pango.co.tz>

# SMS Configuration (Africa's Talking)
AFRICASTALKING_USERNAME=sandbox
AFRICASTALKING_API_KEY=YOUR_API_KEY_HERE
AFRICASTALKING_SENDER_ID=Pango
"@ | Out-File -FilePath .env -Encoding UTF8
```

**Then edit the .env file** to add your actual credentials:
1. Open `backend\.env` in any text editor (Notepad, VS Code, etc.)
2. Replace:
   - `YOUR_EMAIL_HERE@gmail.com` → your actual Gmail
   - `YOUR_16_CHAR_PASSWORD_HERE` → your App Password (no spaces)
   - `YOUR_API_KEY_HERE` → your Africa's Talking API key

---

### **Option B: Manual Creation**

**Create a file named `.env` in the `backend` folder** with this content:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database
MONGODB_URI=mongodb+srv://techlandtz_db_user:C86zikhnrHw3oKXS@cluster0.5uvn2fu.mongodb.net/pango

# JWT Configuration
JWT_SECRET=pango_super_secret_jwt_key_2024
JWT_EXPIRE=7d

# Email Configuration (Gmail)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=your.email@gmail.com
EMAIL_PASS=abcdefghijklmnop
EMAIL_FROM=Pango <noreply@pango.co.tz>

# SMS Configuration (Africa's Talking)
AFRICASTALKING_USERNAME=sandbox
AFRICASTALKING_API_KEY=atsk_your_key_here
AFRICASTALKING_SENDER_ID=Pango
```

**Replace with your actual credentials!**

---

## 🎯 **Testing Options**

### **Option 1: Test NOW (No Setup Needed)**
✅ **Works immediately!**

1. Keep backend running
2. Register in the app
3. Choose Email or Phone verification
4. **Check backend terminal** for code:
   ```
   info: 📱 VERIFICATION CODE: 123456
   ```
   or
   ```
   info: 📧 VERIFICATION TOKEN: abc123xyz
   ```
5. Copy code → Paste in app
6. ✅ Verified!

---

### **Option 2: Real SMS & Email (After Setup)**
✅ **After adding credentials**

1. Add credentials to `.env` file (see above)
2. **Restart backend:**
   ```powershell
   cd C:\pango\backend
   npm run dev
   ```
3. Terminal will show:
   ```
   info: Email service initialized
   info: Africa's Talking SMS service initialized
   ```
4. Register in app
5. **Real SMS/Email sent!**
6. Check your phone or inbox
7. Enter code from SMS/email
8. ✅ Verified!

---

## 🔍 **Troubleshooting**

### **Backend shows: "Email credentials not configured"**
✅ **This is NORMAL!** It means development mode is active.
- Codes will appear in terminal
- Copy/paste to test
- OR add credentials to send real emails

### **Backend shows: "SMS will be logged only"**
✅ **This is NORMAL!** Same as above.
- Codes logged in terminal
- OR add Africa's Talking credentials

### **Port 3000 already in use**
```powershell
# Kill the process on port 3000
Get-Process -Id (Get-NetTCPConnection -LocalPort 3000).OwningProcess | Stop-Process -Force

# Then restart
npm run dev
```

---

## 📊 **Summary**

| Method | Setup Time | Cost | Best For |
|--------|------------|------|----------|
| **Terminal Codes** | ✅ 0 min | FREE | Testing now |
| **Gmail** | 5-10 min | FREE | Email verification |
| **Africa's Talking** | 10-15 min | FREE (Sandbox) | SMS verification |

---

## 🎉 **Quick Links**

**Africa's Talking:**
- Sign up: https://account.africastalking.com/auth/register
- Dashboard: https://account.africastalking.com/apps/sandbox
- Docs: https://developers.africastalking.com/

**Gmail:**
- 2FA Setup: https://myaccount.google.com/security
- App Passwords: https://myaccount.google.com/apppasswords
- Help: https://support.google.com/accounts/answer/185833

---

## 💡 **Recommendation**

**For RIGHT NOW:**
1. ✅ Keep testing with terminal codes (works perfectly!)
2. ✅ Test all features
3. ✅ Make sure everything works

**For PRODUCTION:**
1. Get Gmail App Password (5 min) - **Do this first** (easier)
2. Get Africa's Talking account (15 min) - **Do this later**
3. Add both to `.env`
4. Restart backend
5. 🎉 **Production ready!**

---

**Your app is working NOW! Add credentials when you're ready for real SMS/emails.** 🚀







