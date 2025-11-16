# 🚀 How to Start Backend Server

## ⚠️ The Issue
When you go to `http://localhost:3000/admin`, you get **"Site can't be reached"**

**Reason:** Backend server is NOT running!

---

## ✅ Solution: Start the Backend

### **Step 1: Open a Terminal/Command Prompt**

**Windows:**
- Press `Windows + R`
- Type `cmd` 
- Press Enter
- A black command window opens

**Mac/Linux:**
- Open Terminal application

---

### **Step 2: Navigate to Backend Folder**

In the terminal, type:
```bash
cd c:\pango\backend
```

Press Enter.

You should see:
```
C:\pango\backend>
```

---

### **Step 3: Start the Server**

Type:
```bash
npm start
```

Press Enter.

**Wait** for the server to fully start. You should see messages like:

```
> pango-backend@1.0.0 start
> node src/server.js

✓ MongoDB connected
✓ Server running on port 3000
✓ Admin panel available at http://localhost:3000/admin
```

When you see these messages, the server is READY! ✅

---

## 🌐 Now Access Admin Panel

Once the server is running (you see the messages above):

1. **Open your browser** (Chrome, Firefox, Safari, etc.)
2. **Go to:** `http://localhost:3000/admin`
3. **You should now see the login screen!**

Login with:
- **Email:** `admin@pango.co.tz`
- **Password:** `AdminPassword123!`

---

## 🎯 After Login

You should now see:
- ✅ Dashboard with stats
- ✅ Sidebar with all sections
- ✅ **NEW: "Host Payouts" menu item** (after Hosts)

---

## ⚠️ Important Notes

### **Keep Terminal Open**
- ❌ Do NOT close the terminal window
- ✅ Leave it open while using the admin panel
- The server must stay running!

### **If Terminal Closes**
- Just restart it (repeat Steps 1-3)
- The server will start again

### **If Server Won't Start**
Check for error messages in the terminal. Common issues:

| Error | Solution |
|-------|----------|
| "Port 3000 already in use" | Another app is using port 3000. Restart computer or use different port. |
| "MongoDB connection failed" | Make sure MongoDB is running. Start MongoDB separately. |
| "Cannot find module" | Run `npm install` first, then `npm start` |
| Permission denied | Try running terminal as Administrator (Windows) |

---

## 📋 Step-by-Step Summary

```
1. Open Terminal/Command Prompt
2. Type: cd c:\pango\backend
3. Press Enter
4. Type: npm start
5. Press Enter
6. WAIT for messages that say "Server running on port 3000"
7. Open browser
8. Go to: http://localhost:3000/admin
9. Login
10. Click "Host Payouts" in sidebar to see new feature!
```

---

## ✅ Verification

The server is running when you see:
```
✓ Server running on port 3000
✓ MongoDB connected
```

The terminal will show new messages as you use the admin panel. This is normal!

---

## 🎉 Success!

Once you see the admin panel with "Host Payouts" section:
- ✅ Backend is running
- ✅ Admin panel is working
- ✅ New features are ready!

---

## 💡 Troubleshooting

**Q: How do I know if the server is running?**
A: You can access `http://localhost:3000/admin`. If it loads, server is running!

**Q: What if I close the terminal by accident?**
A: Just open a new terminal and run `npm start` again from `c:\pango\backend`

**Q: Can I close the terminal after starting?**
A: No! The terminal must stay open for the server to keep running.

**Q: How do I stop the server?**
A: Press `Ctrl+C` in the terminal. This stops the server.

---

**Now start your backend and enjoy the admin panel!** 🚀

