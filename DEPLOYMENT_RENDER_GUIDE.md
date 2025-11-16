# Deploy Backend to Render.com

## ✅ You're signed up with GitHub!

Perfect! Render is actually easier than Railway for deployments.

---

## 📝 Step-by-Step Deployment

### **A. Create Web Service**

1. **In Render Dashboard:**
   - You should see "Get started by creating a new resource"
   - Click **"New +"** button (top-right)
   - Select **"Web Service"**

2. **Connect Repository:**
   - You should see your repository: **`pango-backend`**
   - If you don't see it, click "Configure account" and grant access
   - Click **"Connect"** next to `pango-backend`

---

### **B. Configure Service**

You'll see a configuration form. Fill it in:

**Name:**
```
pango-backend
```

**Region:**
```
Frankfurt (EU Central) or Singapore (closest to Tanzania)
```

**Branch:**
```
main
```

**Root Directory:**
```
(leave blank)
```

**Runtime:**
```
Node
```
*(Should auto-detect)*

**Build Command:**
```
npm install
```

**Start Command:**
```
node src/server.js
```

**Instance Type:**
```
Free
```
*(Select the free tier)*

---

### **C. Add Environment Variables**

**IMPORTANT:** Before clicking "Create Web Service", scroll down to "Environment Variables"

Click **"Add Environment Variable"** and add these:

```
NODE_ENV = production
PORT = 3000
JWT_SECRET = pango-super-secure-jwt-secret-key-2025
JWT_EXPIRE = 30d
EMAIL_SERVICE = gmail
EMAIL_USER = your-email@gmail.com
EMAIL_PASSWORD = your-app-password
EMAIL_FROM = noreply@pango.co.tz
FRONTEND_URL = https://pango.co.tz
MAX_FILE_SIZE = 5242880
FILE_UPLOAD_PATH = ./uploads
```

**NOTE:** We'll add `MONGODB_URI` in the next step after setting up MongoDB Atlas!

---

### **D. Create Web Service**

1. **Click:** "Create Web Service" (bottom of page)

2. **Wait for deployment** (2-5 minutes)
   - You'll see build logs
   - npm install running
   - Starting server
   - Eventually: "Live" with a green dot ✅

3. **Your Production URL:**
   - At the top, you'll see your URL
   - It looks like: `https://pango-backend.onrender.com`
   - **COPY THIS URL!**

---

## ⚠️ Expected Behavior

**The deployment will succeed BUT:**
- Backend will show as "Live" ✅
- But it won't work yet ⚠️
- **Why?** No database connected (MongoDB)

**This is NORMAL!** We'll add MongoDB Atlas in the next step.

---

## ✅ When This Step is Complete

Tell me:
1. ✅ "Deployed to Render"
2. Your production URL (e.g., `pango-backend.onrender.com`)

Then we'll set up MongoDB Atlas!

---

## 🆘 Troubleshooting

**Issue:** "Repository not showing"
- Click "Configure account" in GitHub repos section
- Grant Render access to your repos

**Issue:** "Build failed"
- Check build logs
- Usually it's a missing environment variable (we'll add database next)

**Issue:** "Service not starting"
- Normal if MongoDB URI is missing
- We'll fix in next step

---

**Ready? Follow the steps above and tell me when you see your Render URL!** 🚀






