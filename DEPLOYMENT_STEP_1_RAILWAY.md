# Step 1: Deploy Backend to Railway.app

## 🎯 Goal
Get your backend running on the cloud so users can access it from anywhere.

---

## ✅ What You Need
- GitHub account
- Your backend code (ready in `C:\pango\backend`)
- 10 minutes

---

## 📝 Instructions

### **A. Sign Up for Railway**

1. **Go to:** https://railway.app
2. **Click:** "Start a New Project"
3. **Click:** "Login with GitHub"
4. **Authorize** Railway to access GitHub
5. **Done!** You're logged in

---

### **B. Create GitHub Repository**

Before deploying, we need to push your code to GitHub.

**Run these commands in PowerShell:**

```powershell
cd C:\pango\backend

# Initialize Git (if not already done)
git init

# Create .gitignore
@"
node_modules/
.env
logs/
uploads/
*.log
.DS_Store
"@ | Out-File -FilePath .gitignore -Encoding utf8

# Add all files
git add .

# Commit
git commit -m "Initial commit - Production ready backend"
```

**Now create a repository on GitHub:**
1. Go to https://github.com/new
2. Repository name: `pango-backend`
3. Make it **Private** (recommended)
4. Click "Create repository"
5. Copy the commands shown (they'll look like):

```bash
git remote add origin https://github.com/YOUR_USERNAME/pango-backend.git
git branch -M main
git push -u origin main
```

Run those commands in your PowerShell window.

---

### **C. Deploy to Railway**

1. **In Railway Dashboard:**
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose `pango-backend`
   - Railway automatically detects Node.js!

2. **Wait for deployment** (2-3 minutes)
   - You'll see build logs
   - Wait for "✅ Deployed"

3. **Get your Production URL:**
   - Click on your service
   - Go to "Settings" tab
   - Click "Generate Domain"
   - You'll get something like: `pango-backend-production-xyz.up.railway.app`
   - **SAVE THIS URL!**

---

### **D. Add Environment Variables**

In Railway dashboard:

1. **Click** on your project
2. **Go to** "Variables" tab
3. **Add these variables:**

```
NODE_ENV=production
PORT=3000
JWT_SECRET=your-super-secure-random-secret-key-here
JWT_EXPIRE=30d
EMAIL_SERVICE=gmail
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
EMAIL_FROM=noreply@pango.co.tz
FRONTEND_URL=https://pango.co.tz
MAX_FILE_SIZE=5242880
FILE_UPLOAD_PATH=./uploads
```

**Important:** We'll add `MONGODB_URI` in the next step!

4. **Click "Add" for each variable**

---

### **E. Your Production URL**

After deployment, you'll have:
```
https://pango-backend-production-xyz.up.railway.app
```

**Test it:**
```
https://YOUR-URL/api/v1/listings
```

You should see JSON data!

---

## ✅ When Complete

You should have:
- ✅ Railway account
- ✅ GitHub repository with backend code
- ✅ Backend deployed to Railway
- ✅ Production URL obtained

**Write down your production URL - you'll need it for the mobile app!**

---

## 🔄 Next Step

Once Railway deployment is complete, we'll:
- Set up MongoDB Atlas (free cloud database)
- Connect it to Railway
- Test production backend

**Let me know when you've:**
1. Created GitHub repository
2. Deployed to Railway
3. Have your production URL

Then we'll move to Step 2!






