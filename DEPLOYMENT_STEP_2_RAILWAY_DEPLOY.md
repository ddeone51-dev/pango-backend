# Step 2: Deploy Backend to Railway

## ✅ Previous Step Complete
Your code is now on GitHub: https://github.com/ddeone51-dev/pango-backend

---

## 🎯 Goal
Deploy your backend to Railway so it runs in the cloud 24/7.

---

## 📝 Instructions - Follow Carefully!

### **A. Sign Up for Railway**

1. **Open:** https://railway.app
2. **Click:** "Start a New Project" (top-right)
3. **Click:** "Login with GitHub"
4. **Authorize Railway** when prompted
5. You'll see Railway dashboard

---

### **B. Deploy Your Backend**

1. **Click:** "New Project" button

2. **Select:** "Deploy from GitHub repo"

3. **Find and select:** `ddeone51-dev/pango-backend`
   - You should see your repository in the list
   - Click on it

4. **Railway will automatically:**
   - ✅ Detect it's a Node.js project
   - ✅ Run `npm install`
   - ✅ Start the server
   - ✅ This takes 2-3 minutes

5. **Watch the build logs:**
   - You'll see it installing dependencies
   - Building the project
   - Starting the server
   - Wait for "✅ Deployed successfully"

---

### **C. Generate Public URL**

After deployment succeeds:

1. **Click** on your deployed service (it shows "pango-backend")

2. **Go to** "Settings" tab

3. **Scroll down** to "Networking" section

4. **Click:** "Generate Domain"
   - Railway will create a URL like:
   - `pango-backend-production-abc123.up.railway.app`

5. **IMPORTANT: Copy this URL!**
   - You'll need it for the mobile app
   - Save it somewhere safe

---

### **D. Test Your Production Backend**

1. **Open your browser**

2. **Visit:**
   ```
   https://YOUR-RAILWAY-URL.up.railway.app/api/v1
   ```

3. **You should see:**
   ```json
   {
     "message": "Pango API",
     "version": "1.0.0",
     "documentation": "/api-docs"
   }
   ```

4. **Test listings endpoint:**
   ```
   https://YOUR-RAILWAY-URL.up.railway.app/api/v1/listings
   ```

   **You should see:** Empty array (no listings yet - that's normal!)
   ```json
   {
     "success": true,
     "data": {
       "listings": [],
       "pagination": {...}
     }
   }
   ```

---

## ⚠️ Expected Issue: Database Not Connected

Railway backend will deploy successfully, but you'll see an error about MongoDB connection.

**This is normal!** We'll fix it in the next step by adding MongoDB Atlas.

---

## ✅ When This Step is Complete

You should have:
- ✅ Railway account created
- ✅ Backend deployed to Railway
- ✅ Production URL obtained (e.g., `https://pango-backend-production-xyz.up.railway.app`)
- ⚠️ MongoDB connection pending (next step)

---

## 📝 What to Tell Me Next

**When you've deployed to Railway, tell me:**

1. ✅ "Deployed to Railway"
2. Your production URL (the Railway domain)

Example: "Deployed! URL is pango-backend-production-abc123.up.railway.app"

Then we'll set up MongoDB Atlas and connect everything!

---

## 🆘 If You Get Stuck

**Common issues:**

**Issue:** "Can't find repository"
- Solution: Make sure you authorized Railway to access your GitHub repos

**Issue:** "Build failed"
- Solution: Check build logs - usually a missing dependency

**Issue:** "Server not starting"
- Solution: Normal! MongoDB is not connected yet (next step)

---

**Ready? Go to https://railway.app and let's deploy!** 🚀






