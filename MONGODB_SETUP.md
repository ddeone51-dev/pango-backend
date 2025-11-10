# MongoDB Atlas Setup Guide

## Quick Setup (5 minutes)

### Step 1: Create Free MongoDB Atlas Account

1. Go to: https://www.mongodb.com/cloud/atlas/register
2. Sign up with your email (or use Google/GitHub)
3. Choose **FREE** tier (M0 Sandbox)

### Step 2: Create a Cluster

1. After signup, click **"Build a Database"**
2. Choose **FREE** tier (M0)
3. Choose a **Cloud Provider & Region** (AWS - closest to you)
4. Click **"Create Cluster"**

### Step 3: Create Database User

1. On the **Security Quickstart** page:
   - **Username**: `pangouser`
   - **Password**: Create a strong password (save it!)
   - Click **"Create User"**

2. **IMPORTANT**: Copy your username and password!

### Step 4: Add IP Address

1. Still on Security page:
   - Click **"Add My Current IP Address"**
   - **OR** Click **"Allow Access from Anywhere"** (for development only)
     - This adds `0.0.0.0/0` - allows all IPs
   - Click **"Finish and Close"**

### Step 5: Get Connection String

1. Click **"Connect"** on your cluster
2. Choose **"Connect your application"**
3. Copy the connection string, it looks like:
   ```
   mongodb+srv://pangouser:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```

4. **Replace** `<password>` with your actual password
5. **Add** database name `pango` before the `?`:
   ```
   mongodb+srv://pangouser:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/pango?retryWrites=true&w=majority
   ```

### Step 6: Update Your .env File

Replace the `MONGODB_URI` in your `backend/.env` file:

```env
MONGODB_URI=mongodb+srv://pangouser:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/pango?retryWrites=true&w=majority
```

### Step 7: Restart Backend

```bash
cd backend
npm run dev
```

You should see: **"MongoDB Connected: cluster0.xxxxx.mongodb.net"**

---

## Alternative: Install Local MongoDB

If you prefer local development:

### Windows:
1. Download: https://www.mongodb.com/try/download/community
2. Run installer
3. Use connection string: `mongodb://localhost:27017/pango`

### Using Docker:
```bash
docker run -d -p 27017:27017 --name mongodb mongo:latest
```

---

## Troubleshooting

**Error: "bad auth"**
- Check username/password are correct
- Make sure you replaced `<password>` with actual password

**Error: "connection timeout"**
- Check IP whitelist in MongoDB Atlas
- Add `0.0.0.0/0` for development

**Error: "ECONNREFUSED"**
- MongoDB service not running (local)
- Check connection string format

---

## Test Your Connection

Run this in a new terminal:
```bash
cd backend
node -e "require('mongoose').connect(process.env.MONGODB_URI || 'YOUR_URI_HERE').then(() => console.log('✅ Connected!')).catch(e => console.log('❌ Error:', e.message))"
```

---

**Need help?** The free tier gives you:
- 512 MB storage
- Shared RAM
- Perfect for development and testing
- No credit card required!






















